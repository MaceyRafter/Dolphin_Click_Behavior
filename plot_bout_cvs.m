cd('I:\Macey Rafter - GOM\Foraging Test')
allClicks = load('outputBouts_allClicks.mat');
flaggedClicks = load('outputBouts_flaggedClicks.mat');

figure(11);clf
plot(allClicks.statsBoutStartDiffStore(:,3),'*')

[~,J,I]=intersect(round(flaggedClicks.hourDateNum*1000),round(allClicks.hourDateNum*1000));

hold on
plot(I,allClicks.statsBoutStartDiffStore(I,3),'*r')


figure(12);clf
plot(allClicks.hourDateNum,allClicks.statsBoutStartDiffStore(:,3),'*')
hold on
plot(allClicks.hourDateNum(I),allClicks.statsBoutStartDiffStore(I,3),'*r')
datetick