subject='T003';
cond={'Normal','0mm','4mm','8mm','12mm','16mm'};
mcolor={'k','r','y','g','b','m'};
figure
hold on
for i=1:6
    Outname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_EMG.mat');
    load(Outname);
    plot(0:.1:99.9,avmat(11,:),mcolor{i})
    %plot(0:.1:99.9,avmat(11,:),mcolor{i},0:.1:99.9,avmat(11,:)+stdmat(11,:),strcat('--',mcolor{i}),0:.1:99.9,avmat(11,:)-stdmat(11,:),strcat('--',mcolor{i}))
end
title('RMedGas EMG')
legend(cond)
xlabel('Percent Gait Cycle')
ylabel('EMG (mV)')
hold off