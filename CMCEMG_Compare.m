load('C:\OpenSim\4.1\Models\VSAFO\T003\Interpolated_Results\8mm_CMC')
CMCdata=avmat; CMChead=headlist;
load('C:\OpenSim\4.1\Models\VSAFO\T003\Interpolated_Results\8mm_EMG')
EMGdata=avmat; EMGhead=headlist;
mus={'rmg','rta','rso','rbf','rrf','rvm'};
for i=1:length(CMChead) %ID CMC columns
    if strcmp(CMChead{i},'gasmed_r')
        icmc(1)=i;
    elseif strcmp(CMChead{i},'tibant_r')
        icmc(2)=i;
    elseif strcmp(CMChead{i},'soleus_r')
        icmc(3)=i;
    elseif strcmp(CMChead{i},'bflh_r')
        icmc(4)=i;
    elseif strcmp(CMChead{i},'recfem_r')
        icmc(5)=i;
    elseif strcmp(CMChead{i},'vasmed_r')
        icmc(6)=i;
    end
end
for i=1:length(EMGhead) %ID EMG columns
    if strcmp(EMGhead{i},'RMG')
        iemg(1)=i;
    elseif strcmp(EMGhead{i},'RTA')
        iemg(2)=i;
    elseif strcmp(EMGhead{i},'RS')
        iemg(3)=i;
    elseif strcmp(EMGhead{i},'RLH')
        iemg(4)=i;
    elseif strcmp(EMGhead{i},'RRF')
        iemg(5)=i;
    elseif strcmp(EMGhead{i},'RVM')
        iemg(6)=i;
    end
end
for i=1:length(mus)
    maxemg(i)=max(EMGdata(iemg(i),:));
    maxcmc(i)=max(CMCdata(icmc(i),:));
end

segstart=[1,101,401,601,801];
segend=[100,400,600,800,1000];
X=categorical({'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});
X = reordercats(X,{'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});

for j=1:length(mus)
    actmean{j}=zeros([length(segstart),3]);
    for i=1:length(segstart)
        a=CMCdata(icmc(j),segstart(i):segend(i)); % cmc
        b=EMGdata(iemg(j),segstart(i):segend(i))./maxemg(j).*maxcmc(j); %normalize emg
        actmean{j}(i,1)=mean(a);
        actmean{j}(i,2)=mean(b);
        actmean{j}(i,3)=abs(mean(b)-mean(a));
    end
    figure
    hold on
    subplot(1,2,1)
    title(mus{j});
    plot(.1:.1:100,CMCdata(icmc(j),:),.1:.1:100,EMGdata(iemg(j),:)./maxemg(j).*maxcmc(j))
    title(mus{j});
    xlabel('Percent Gait Cycle')
    ylabel('Normalized Activation')
    legend('cmc','emg')
    
    subplot(1,2,2)
    B=bar(X,actmean{j}(:,1:2));
    xtips1=B(1).XEndPoints;
    ytips1=B(1).YEndPoints;
    xtips2=B(2).XEndPoints;
    ytips2=B(2).YEndPoints;
    xs=(xtips1+xtips2)./2;
    ys=max([ytips1;ytips2],[],1);
    diffs=string(abs(B(2).YData-B(1).YData));
    text(xs,ys,diffs,'HorizontalAlignment','center','VerticalAlignment','bottom')
    hold off
end
