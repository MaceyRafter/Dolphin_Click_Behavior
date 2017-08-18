clearvars
makePlot = 0;
% Load in TPWS and FD files.
% Note if you want to process multiple files, use dir() to get file names.
% From a folder, and a "for" loop.
inputTPWS = 'E:\bigDL\Code\GOM_MC_12_disk02a_Delphin_TPWS1.mat';
inputFD = 'E:\bigDL\Code\GOM_MC_12_disk02a_Delphin_FD1.mat';

load(inputTPWS,'MTT')
load(inputFD)
% Get rid of false click detection times
goodClickTimes = setdiff(MTT,zFD);


% % option 2: Run on only the flagged click times
% inputID = 'E:\bigDL\Code\GOM_MC_12_disk02a_Delphin_ID1.mat';
% outputFile = 'E:\bigDL\Code\outputBouts_flaggedClicks.mat';
% load(inputID)
% goodClickTimes = zID(:,1);

% Make a vector of hour bins
startClickTime = datevec(min(goodClickTimes));
endClickTime = datevec(max(goodClickTimes));

hourStart = datenum([startClickTime(1:4),0,0]);
hourEnd = datenum([endClickTime(1:3),endClickTime(4)+1,0,0]);

hourVector = hourStart:(1/24):hourEnd;
binInt = 10; % within hour bin in seconds
secInt = 1/(24*60*60/binInt);% interval to use within hours as datenum

clickTSstore = zeros(length(hourVector),60*60/binInt);
zeroCrossMat = nan(length(hourVector),1);
nClicksInHour = nan(length(hourVector),1);
% For each hour:
keepHour = [];
for iH = 1:length(hourVector)-1
    % 1) find all the clicks in the hour
    thisBinStart = hourVector(iH);
    thisBinEnd = hourVector(iH+1);
    secondVector = thisBinStart:secInt:thisBinEnd;
    clickSet = goodClickTimes(goodClickTimes>=thisBinStart & ...
        goodClickTimes<thisBinEnd);
    nClicksInHour(iH,1) = length(clickSet);
    
    % 2) bin the clicks by second
    [nClicks,~] = histcounts(clickSet,secondVector);
    clickTSstore(iH,:) = nClicks;
    
    if nClicksInHour(iH,1)>=100
        % 3) compute autocorrelation of timeseries

        [xCorrScore,lags]= xcorr(clickTSstore(iH,:),180);
        lagSec = lags*binInt;
        xCorrScore = xCorrScore(floor(length(xCorrScore)/2):end);
        lagSec = lagSec(floor(length(xCorrScore)/2):end);
        xCorrSmooth = smooth(xCorrScore,24,'lowess');
        xCorrSmoothDiff = diff(xCorrSmooth);
        
        zeroCross = NaN;
        iL = 1;
        iS = 1;
        diffVal = [];
        while iL < length(xCorrSmoothDiff)
            if xCorrSmoothDiff(iL)>0 && xCorrSmoothDiff(iL+1)<0 &&...
                (xCorrSmoothDiff(iL) - xCorrSmoothDiff(iL+1))>=10
                diffVal(iS) = xCorrSmoothDiff(iL) - xCorrSmoothDiff(iL+1);
                zeroCross(iS) = iL; 
                iS = iS +1;
            end
            iL = iL+1;
        end
        zeroCrossMat(iH,1) = iL; % index of first cross corr peak
        % Plot to verify that things are working
        figure(13);clf
        subplot(2,1,1)
        plot(secondVector(1:end-1), nClicks)
        datetick
        subplot(2,1,2)
        plot(xCorrScore./max(xCorrScore),'k') % original cross correlation
        hold on
        xCorrSmoothNorm = xCorrSmooth./max(xCorrSmooth);

        [peakSet,peakLoc] = findpeaks(xCorrSmoothNorm,'MinPeakProminence',.05);

        if length(peakSet)>1
            keepHour(iH,1) = 1;
            if makePlot
                plot(xCorrSmoothNorm,'b')% smoothed cross correlation
                findpeaks(xCorrSmoothNorm,'MinPeakProminence',.1);
                pause
            end
        else
            keepHour(iH,1) = 0;
            if makePlot
                plot(xCorrSmoothNorm,'r','linewidth',2)% smoothed cross correlation
                pause
            end
        end
        
    end
    if mod(iH,100)==0
        fprintf('analyzing hour %0.0f of %0.0f\n',iH, length(hourVector)-1)
    end
end

hoursSaved = sum(keepHour);
hoursTotal = length(keepHour);
sprintf('Done: %0.0f good hours out %0.0f checked.\n',hoursSaved,hoursTotal')


% clickTS_positiveHours = clickTSstore(nClicksInHour>=100,:);
% 
% testTimeSeries = clickTS_positiveHours(32,:);
% startBout % List of bout start times.
% endBout % List of bout end times.
