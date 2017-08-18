clearvars

% Load in TPWS and FD files.
% Note if you want to process multiple files, use dir() to get file names.
% From a folder, and a "for" loop.

% Set to 1 or true if you want to see plots
makePlots = 1;

% option 1: Run on all data ignoring flagged events:
inputTPWS = 'I:\Macey Rafter - GOM\Foraging Test\GOM_MC_12_disk02a_Delphin_TPWS1.mat';
inputFD = 'I:\Macey Rafter - GOM\Foraging Test\GOM_MC_12_disk02a_Delphin_FD1.mat';
outputFile = 'I:\Macey Rafter - GOM\Foraging Test\outputBouts_allClicks.mat';
load(inputTPWS,'MTT')
load(inputFD)
goodClickTimes = setdiff(MTT,zFD);

% option 2: Run on only the flagged click times
% inputID = 'I:\Macey Rafter - GOM\Foraging Test\GOM_MC_12_disk02a_Delphin_ID1.mat';
% outputFile = 'I:\Macey Rafter - GOM\Foraging Test\outputBouts_flaggedClicks.mat';
% load(inputID)
% goodClickTimes = zID(:,1);

% Make a vector of hour bins
startClickTime = datevec(min(goodClickTimes));
endClickTime = datevec(max(goodClickTimes));

hourStart = datenum([startClickTime(1:4),0,0]);
hourEnd = datenum([endClickTime(1:3),endClickTime(4)+1,0,0]);
%%
hourVector = hourStart:(1/24):hourEnd;
binInt = 10; % within hour bin in seconds
secInt = 1/(24*60*60/binInt);% interval to use within hours as datenum


clickTSstore = zeros(length(hourVector),60*60/binInt);
zeroCrossMat = nan(length(hourVector),1);
nClicksInHour = nan(length(hourVector),1);
hourOfDay = nan(length(hourVector),1);

boutStartDiffStore = [];
boutEndDiffStore = [];
boutDurStore = [];
offDurStore = [];
boutNum = [];

statsBoutStartDiffStore = [];
statsBoutEndDiffStore = [];
statsBoutDurStore = [];
statsOffDurStore = [];


[nClicks, ~, clickIdx] = histcounts(goodClickTimes,hourVector);
iC = 1; % counter
% For each hour:
for iH = 1:length(nClicks)
    if nClicks(iH)>=100
        clickSet = goodClickTimes(clickIdx==iH);
        
        % 1) Split hour into N second bins
        thisBinStart = hourVector(iH);
        thisBinEnd = hourVector(iH+1);
        hourOfDay(iC,1) = hour(hourVector(iH));% save me!
        secondVector = thisBinStart:secInt:thisBinEnd;
        hourDateNum(iC,1) = thisBinStart;% save me!
        
        % 2) bin the clicks by N seconds
        [nClicksSec,~] = histcounts(clickSet,secondVector);
        clickTSstore(iC,:) = nClicksSec;% save me!
        smoothTS = smooth(nClicksSec,6,'lowess');
        Y = prctile(nClicksSec(nClicksSec>0),50);
        tfVec = smoothTS>=Y; % vector of 0/1 telling you if there are more than 5 clicks in bin
        
        boutStart = find(diff(tfVec) == 1);
        boutEnd = find(diff(tfVec) == -1);
        % are any bout Starts after the last End? get rid of them if so
        boutStart(boutStart>max(boutEnd)) = [];
        % get rid of bout ends that preceed any start
        boutEnd(boutEnd<min(boutStart)) = [];
        
        
        offDur = boutStart(2:end)- boutEnd(1:end-1);
        shortOff = find(offDur<=3);
        boutStart(shortOff+1) = [];
        boutEnd(shortOff) = [];
        onDur = boutEnd - boutStart;
        shortOn = find(onDur<2);
        boutStart(shortOn) = [];
        boutEnd(shortOn) = [];

        if length(boutStart)>=3
            boutStartDiffStore{iC,1} = diff(boutStart);
            boutEndDiffStore{iC,1}  = diff(boutEnd);
            boutDurStore{iC,1}  = boutEnd-boutStart;
            offDurStore{iC,1}  = boutStart(2:end)- boutEnd(1:end-1);
            boutNum(iC,1) = length(boutStart);
            statsBoutStartDiffStore(iC,:) = [median(boutStartDiffStore{iC,1}),...
                mean(boutStartDiffStore{iC,1}),...
                std(boutStartDiffStore{iC,1})./mean(boutStartDiffStore{iC,1})];
            statsBoutEndDiffStore(iC,:) = [median(boutEndDiffStore{iC,1}),...
                mean(boutEndDiffStore{iC,1}),...
                std(boutEndDiffStore{iC,1})./mean(boutEndDiffStore{iC,1})];
            statsBoutDurStore(iC,:) = [median(boutDurStore{iC}),...
                mean(boutDurStore{iC}),...
                std(boutDurStore{iC})./mean(boutDurStore{iC})];
            statsOffDurStore(iC,:) = [median(offDurStore{iC}),...
                mean(offDurStore{iC}),...
                std(offDurStore{iC})./mean(offDurStore{iC})];
            iC = iC +1;
            % you can comment the stuff below out if you don't want plots
            if makePlots && iC==65
                figure(10);clf
                plot(smoothTS)
                title(sprintf('Threshold = %0.0f',Y))
                hold on
                plot(nClicksSec,'k')
                plot(boutStart,zeros(size(boutStart)),'og','MarkerFaceColor','g')
                plot(boutEnd,zeros(size(boutEnd)),'or','MarkerFaceColor','r')
                1;
            end
        end
    end
end
%  boutStartDiffStore,boutEndDiffStore,boutDurStore,offDurStore,...
%      boutNum,statsBoutStartDiffStore,statsBoutEndDiffStore,statsBoutDurStore,...
%      statsOffDurStore 
save(outputFile,'statsBoutStartDiffStore','hourDateNum')
