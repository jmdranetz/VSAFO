%visualizes error in CMC results
%Input file names
subject='T006';
cond='Normal';
hasr='';
trial='';
GRFname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Data\',cond,'_Walking',trial,'_grf',hasr,'.mot');
headlist={'gaslat_r','gaslat_l','gasmed_r','gasmed_l','tibant_r','tibant_l','soleus_r','soleus_l','bflh_r','bflh_l','recfem_r','recfem_l','vasmed_r','vasmed_l','hip_flexion_r_reserve','hip_flexion_l_reserve','knee_angle_r_reserve','knee_angle_l_reserve','ankle_angle_r_reserve','ankle_angle_l_reserve'};
fi=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\CMC\',cond,'\',subject,'_',cond,'_p');
fe='_Actuation_force.sto';
Outname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond,'_CMC.mat');

A=importdata(GRFname);
GRFdata=A.data;
fphead=[0 0];
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

gpass=[];
for i=1:10 %checks which passes have a file and imports
    if isfile(strcat(fi,string(i),fe))
        B=importdata(strcat(fi,string(i),fe));
        IA{i}=B.data;
        gpass=[gpass i];
    end
end
iahead=zeros([1,length(headlist)]);
for i=1:length(B.colheaders) %ID's IA columns
    if strcmp(B.colheaders(i),'time')
        iathead=i;
    end
end
for j=1:length(headlist)
    for i=1:length(B.colheaders)
        if strcmp(B.colheaders(i),headlist{j})
            iahead(j)=i;
        end
    end
end

for j=1:length(iahead)
    intmat{j}=[];
end
for i=gpass
    for c=1:2 %finds closest HS before IA data
        fpb{c}=[0]; fpu{c}=[];
        for j=1:length(fp{c})
            if GRFdata(fp{c}(j),thead)<IA{i}(1,iathead)
                fpb{c}=[fpb{c} fp{c}(j)];
            else
                fpu{c}=[fpu{c} fp{c}(j)];
            end
        end
        fpmax{c}=max(fpb{c}); %HS before IA data
        fpmin{c}=min(fpu{c}); %HS during IA data
    end
    if fpmax{2}<fpmax{1} %right foot led
        iaratio=(IA{i}(end,iathead)-IA{i}(1,iathead))./(IA{i}(end,iathead)-GRFdata(fpmax{1},thead));
        iacount=round(1000.*iaratio);
        for j=1:length(iahead)
            intval=interp1(IA{i}(:,iathead),IA{i}(:,iahead(j)),linspace(IA{i}(1,iathead),IA{i}(end,iathead),iacount));
            introw=[NaN([1,1000-iacount]) intval];
            intmat{j}=[intmat{j}; introw];
        end
    else %left foot led
        iaratio=(IA{i}(end,iathead)-IA{i}(1,iathead))./(IA{i}(end,iathead)-GRFdata(fpmax{2},thead));
        iacount=round(1000.*iaratio);
        splitratio=(GRFdata(fpmin{1},thead)-IA{i}(1,iathead))./(IA{i}(end,iathead)-GRFdata(fpmax{2},thead));
        splitcount=round(1000.*splitratio); %splits left foot led by the RHS
        for j=1:length(iahead)
            intval=interp1(IA{i}(:,iathead),IA{i}(:,iahead(j)),linspace(IA{i}(1,iathead),IA{i}(end,iathead),iacount));
            introw=[intval(splitcount+1:end) NaN([1,1000-iacount]) intval(1:splitcount)]; %starts row at the RHS
            intmat{j}=[intmat{j}; introw];
        end
    end
end

avmat=zeros([length(iahead),1000]);
stdmat=zeros([length(iahead),1000]);
for j=1:length(iahead) %averaging interpolated data
    for k=1:1000
        avmat(j,k)=mean(intmat{j}(~isnan(intmat{j}(:,k)),k),1);
        stdmat(j,k)=std(intmat{j}(~isnan(intmat{j}(:,k)),k));
    end
    figure
    hold on
    plot(0:.1:99.9,avmat(j,:),'b',0:.1:99.9,avmat(j,:)+stdmat(j,:),'c',0:.1:99.9,avmat(j,:)-stdmat(j,:),'c')
    title(strcat(cond,{' '},headlist{j}))
    xlabel('Percent Gait Cycle')
    ylabel('Muscle Force (N)')
    hold off
end

figure
hold on
plot(0:.1:99.9,avmat(3,:),'k')
for i=1:length(gpass)
    plot(0:.1:99.9,intmat{3}(i,:))
end
title(strcat(cond,{' '},headlist{3}))
xlabel('Percent Gait Cycle')
ylabel('Muscle Force (N)')
hold off
