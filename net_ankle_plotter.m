subject='T006';
cond={'Normal','0mm','4mm','8mm','12mm','16mm'};
colors={'k','r','y','g','b','m'};
X=categorical(cond);
X = reordercats(X,cond);
for i=1:length(cond)
    filename=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_ID.mat');
    load(filename)
    iddata{i}=avmat; idstd{i}=stdmat; idhead{i}=headlist;
    for j=1:length(idhead) %ID CMC columns
        if strcmp(idhead{i}{j},'hip_flexion_r_moment')
            iid(1)=j;
        elseif strcmp(idhead{i}{j},'hip_flexion_l_moment')
            iid(2)=j;
        elseif strcmp(idhead{i}{j},'knee_angle_r_moment')
            iid(3)=j;
        elseif strcmp(idhead{i}{j},'knee_angle_l_moment')
            iid(4)=j;
        elseif strcmp(idhead{i}{j},'ankle_angle_r_moment')
            iid(5)=j;
        elseif strcmp(idhead{i}{j},'ankle_angle_l_moment')
            iid(6)=j;
        end
    end
    if i>2
        filename=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_r.mat');
        load(filename)
        rdata{i}=avmat; rstd{i}=stdmat;
    end
end
a=zeros([length(cond),1000]);
b=zeros([length(cond),1000]);
c=zeros([length(cond),1000]);
for j=1:length(cond)
    a(j,:)=iddata{j}(5,:);
    am(j)=min(iddata{j}(5,:));
    b(j,:)=idstd{j}(5,:);
    if j>2
        c(j,:)=rdata{j};
        cm(j)=min(rdata{j});
    end
end
figure
subplot(1,2,1)
hold on
area(.1:.1:100,[a(4,:);c(4,:)]')
hold off
subplot(1,2,2)
bar(X,[am',cm'],'stacked')
