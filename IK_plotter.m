subject='T006';
cond={'Normal','0mm','4mm','8mm','12mm','16mm'};
colors={'k','r','y','g','b','m'};
segstart=[1,101,401,601,801];
segend=[100,400,600,800,1000];
X=categorical({'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});
X = reordercats(X,{'Early Stance','Mid Stance','Terminal Stance','Accelerating Swing','Decelerating Swing'});
for i=1:length(cond)
    filename=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_IK.mat');
    load(filename)
    iddata{i}=avmat; idstd{i}=stdmat; idhead{i}=headlist;
    if i>2
        filename=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond{i},'_r.mat');
        load(filename)
        rdata{i}=avmat; rstd{i}=stdmat;
    end
    for j=1:length(idhead) %ID IK columns
        if strcmp(idhead{i}{j},'hip_flexion_r')
            iid(1)=j;
        elseif strcmp(idhead{i}{j},'hip_flexion_l')
            iid(2)=j;
        elseif strcmp(idhead{i}{j},'knee_angle_r')
            iid(3)=j;
        elseif strcmp(idhead{i}{j},'knee_angle_l')
            iid(4)=j;
        elseif strcmp(idhead{i}{j},'ankle_angle_r')
            iid(5)=j;
        elseif strcmp(idhead{i}{j},'ankle_angle_l')
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
    if i==5
        subplot(1,2,1)
    end
    hold on
    for j=1:length(cond)
        plot(.1:.1:100,a(j,:),colors{j})
        %plot(.1:.1:100,a(j,:)-b(j,:),strcat(colors{j},'--'))
        %plot(.1:.1:100,a(j,:)+b(j,:),strcat(colors{j},'--'))
    end
    title(strcat(subject,' ',idhead{iid(i)}(i),'Inverse Kinematics'))
    xlabel('Percent Gait Cycle')
    ylabel(strcat(idhead{iid(i)}(i),' (deg)'))
    legend(cond)
    hold off
    if i==5
        subplot(1,2,2)
        hold on
        for j=3:6
            plot(.1:.1:100,rdata{j},colors{j})
        end
        title(strcat(subject,' AFO Torque'))
        xlabel('Percent Gait Cycle')
        ylabel('AFO Torque (Nm)')
        legend(cond{3:6})
        hold off
    end
end