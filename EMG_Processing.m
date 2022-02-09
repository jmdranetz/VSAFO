%EMG Processing
clear variables
%Input file names
subject='T006';
cond='16mm';
trial='';
%GRFname='C:\OpenSim\4.1\Models\VSAFO\T003\T003_VSAFO\Normal_Walking01_OG_grf.mot';
%EMGname='C:\OpenSim\4.1\Models\VSAFO\T003\T003_VSAFO\Normal_Walking01_OG_EMG.csv';
GRFname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Data\',cond,'_Walking',trial,'_grf.mot');
EMGname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Data\',cond,'_Walking',trial,'_EMG.csv');
Outname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond,'_EMG.mat');
headlist={'RGM','LRF','RVM','LVM','RRF','LGM','RMH','LMH','RLH','LLH','RMG','LMG','RS','LS','RTA','LTA'};
passtimes=[3.27,	4.42;
10.15,	11.33;
15.87,	17.06;
23.27,	24.36;
28.45,	29.56;
35.64,	36.73;
41.07,	42.19;
48.42,	49.32;
53.22,	54.35;
60.35,	61.46];

A=importdata(GRFname);
GRFdata=A.data;
fphead=[0 0];

B=importdata(EMGname);
% btemp=[B.data(:,1),B.data(:,3:2:end)];
% clear B.data
% B.data=btemp;
for i=1:length(B.colheaders) %ID's EMG time column
    if strcmp(B.colheaders(i),'time')
        iathead=i;
    end
end
hpvar=50;
lpvar=5;
bworder=4;
samfreq=1/(B.data(2,iathead)-B.data(1,iathead));

gpass=[]; %ID's good passes
for i=1:length(passtimes)
    if ~isnan(passtimes(i,1))
        gpass=[gpass i];
    end
end
for i=1:length(A.colheaders) %ID's GRF columns
    if strcmp(A.colheaders(i),'time')
        thead=i;
    elseif strcmp(A.colheaders(i),'1_ground_force_vy')
        fphead(1)=i;
    elseif strcmp(A.colheaders(i),'2_ground_force_vy')
        fphead(2)=i;
    end
end

for c = 1:2 %Check if the force plate is activated to find HS's
    a = 0; fp{c}=[];
    for i = 1:length(GRFdata)
        if a == 0
            if GRFdata(i,fphead(c)) > 20 
                fp{c} = [fp{c} i];
                a = 1;
            end
        end
        if a == 1
            if GRFdata(i,fphead(c)) < 10
                a = 0;
            end
        end
    end
end
gtimes=zeros(size(passtimes));
intmat{1}=[];
for j=2:min(size(B.data))
    intmat{j}=[];
end
wholefilt=zeros(size(B.data));
wholefilt(:,1)=B.data(:,1);
for i=2:min(size(B.data))
    wholefilt(:,i)=EMGFilter(B.data(:,i),hpvar,lpvar,bworder,samfreq);
end
for i=gpass
    for c=1:2 %finds closest HS before IA data
        fpb{c}=0; fpu{c}=[];
        for j=1:length(fp{c})
            if GRFdata(fp{c}(j),thead)<passtimes(i,1)
                fpb{c}=[fpb{c} fp{c}(j)]; %HS's before pass
            else
                fpu{c}=[fpu{c} fp{c}(j)]; %HS's during or after pass
            end
        end
        fpmax{c}=max(fpb{c}); %HS before IA data
        fpmin{c}=min(fpu{c}); %HS during IA data
    end
    gtimes(i,1)=find(B.data(:,iathead)==passtimes(i,1));
    gtimes(i,2)=find(B.data(:,iathead)==passtimes(i,2));
    EMGfilt{i}(:,1)=B.data(gtimes(i,1):gtimes(i,2),1);
    for j=2:min(size(B.data))
        %EMGfilt{i}(:,j)=EMGFilter(B.data(gtimes(i,1):gtimes(i,2),j),hpvar,lpvar,bworder,samfreq);
        EMGfilt{i}(:,j)=wholefilt(gtimes(i,1):gtimes(i,2),j);
    end
    if fpmax{2}<fpmax{1} %right foot led
        iaratio=(passtimes(i,2)-passtimes(i,1))./(passtimes(i,2)-GRFdata(fpmax{1},thead));
        iacount=round(1000.*iaratio);
        for j=2:min(size(B.data))
            intval=interp1(EMGfilt{i}(:,1),EMGfilt{i}(:,j),linspace(EMGfilt{i}(1,1),EMGfilt{i}(end,1),iacount));
            introw=[NaN([1,1000-iacount]) intval];
            intmat{j}=[intmat{j}; introw];
        end
    else %left foot led
        iaratio=(passtimes(i,2)-passtimes(i,1))./(passtimes(i,2)-GRFdata(fpmax{2},thead));
        iacount=round(1000.*iaratio);
        splitratio=(GRFdata(fpmin{1},thead)-passtimes(i,1))./(passtimes(i,2)-GRFdata(fpmax{2},thead));
        splitcount=round(1000.*splitratio); %splits left foot led by the RHS
        for j=2:min(size(B.data))
            intval=interp1(EMGfilt{i}(:,1),EMGfilt{i}(:,j),linspace(EMGfilt{i}(1,1),EMGfilt{i}(end,1),iacount));
            introw=[intval(splitcount+1:end) NaN([1,1000-iacount]) intval(1:splitcount)]; %starts row at the RHS
            intmat{j}=[intmat{j}; introw];
        end
    end
end

avmat=zeros([min(size(B.data))-1,1000]);
stdmat=zeros([min(size(B.data))-1,1000]);
for j=1:min(size(B.data))-1 %averaging interpolated data
    for k=1:1000
        avmat(j,k)=mean(intmat{j+1}(~isnan(intmat{j+1}(:,k)),k),1);
        stdmat(j,k)=std(intmat{j+1}(~isnan(intmat{j+1}(:,k)),k));
    end
    figure
    hold on
    plot(0:.1:99.9,avmat(j,:),'b',0:.1:99.9,avmat(j,:)+stdmat(j,:),'c',0:.1:99.9,avmat(j,:)-stdmat(j,:),'c')
    title(strcat(cond,{' '},headlist{j}))
    xlabel('Percent Gait Cycle')
    ylabel('EMG (mV)')
    hold off
end
save(Outname,'avmat','stdmat','headlist');