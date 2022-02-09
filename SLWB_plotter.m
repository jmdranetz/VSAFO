%SLWB plotter
a=zeros([6,2]);
subject='T005';
cond={'Normal','0mm','4mm','8mm','12mm','16mm'};
for i=1:length(a)
    filename=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_SL_WB.mat');
    load(filename)
    a(i,:)=slwb;
    b(i,:)=std_slwb;
end
X = categorical({'Normal','0mm','4mm','8mm','12mm','16mm'});
X = reordercats(X,{'Normal','0mm','4mm','8mm','12mm','16mm'});
figure
c=bar(a);
hold on
[ngroups, nbars] = size(a);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x(i,:) = c(i).XEndPoints;
end
errorbar(x',a,b,'k','linestyle','none')
hold off
set(gca,'xticklabel',X)
title(strcat(subject,' Kinematic Parameters'))
ylabel('mm')
legend('Step Length','Walking Base','Location','east')