subject='T006';
cond={'Normal','0mm','4mm','8mm','12mm','16mm'};
colors={'k','r','y','g','b','m'};
segstart=[1,101,401,601,801];
segend=[100,400,600,800,1000];
X=categorical({'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});
X = reordercats(X,{'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});
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
end
for i=1:length(idhead)
    a=zeros([length(cond),1000]);
    b=zeros([length(cond),1000]);
    for j=1:length(cond)
        a(j,:)=iddata{j}(i,:);
        b(j,:)=idstd{j}(i,:);
        for k=1:length(segstart)
            m(k,j)=mean(iddata{j}(i,segstart(k):segend(k)));
        end
    end
    figure
    subplot(1,2,1)
    hold on
    for j=1:length(cond)
        plot(.1:.1:100,a(j,:),colors{j})
        %plot(.1:.1:100,a(j,:)-b(j,:),strcat(colors{j},'--'))
        %plot(.1:.1:100,a(j,:)+b(j,:),strcat(colors{j},'--'))
    end
    hold off
    subplot(1,2,2)
    bar(X,m)
    
end
