%calculates VSAFO reaction forces to add to base grf data

%imports GRF
A=importdata('C:\OpenSim\4.1\Models\VSAFO\T006\Data\16mm_Walking_grf.mot');


%imports IK
fi='C:\OpenSim\4.1\Models\VSAFO\T006\IK\16mm\16mm_p';
fe='.mot';
gpass=[];
for i=1:10 %checks which passes have a file and imports
    if isfile(strcat(fi,string(i),fe))
        B=importdata(strcat(fi,string(i),fe));
        IK{i}=B.data;
        gpass=[gpass i];
    end
end
for i=1:length(B.colheaders) %ID's GRF columns
    if strcmp(B.colheaders(i),'ankle_angle_r')
        ahead=i;
    end
end

%4 spring VSAFO model to find effective angle ratio
%initial parameters
Lmax=0.044;
W=0.0125;
Xi=sqrt(Lmax^2-W^2);
stiff=2*49980;

%input screw length (m)
ds=[0 0.004 0.008 0.012 0.016];
ps=[0 0.004 0.008 0.012 0.016];

dL=sqrt(W.^2+(Xi-ds).^2);
pL=sqrt(W.^2+(Xi-ps).^2);
dtheta=acos(W./dL);
ptheta=acos(W./pL);
rot=zeros([100 length(ds).*length(ps)]);
dx=zeros([100 length(ds).*length(ps)]);
ddx=zeros([100 length(ds).*length(ps)]);
dtau=zeros([100 length(ds).*length(ps)]);
px=zeros([100 length(ds).*length(ps)]);
pdx=zeros([100 length(ds).*length(ps)]);
ptau=zeros([100 length(ds).*length(ps)]);
tau=zeros([100 length(ds).*length(ps)]);
for i=1:length(ds)
    for j=1:length(ps)
        rot(:,(length(ds))*(i-1)+j)=linspace(-ptheta(j),dtheta(i),100);
        for k=1:length(rot)
            dx(k,(length(ds))*(i-1)+j)=sqrt(dL(i).^2+W.^2-2.*dL(i).*W.*cos(dtheta(i)-rot(k,(length(ds))*(i-1)+j)));
            px(k,(length(ds))*(i-1)+j)=sqrt(pL(j).^2+W.^2-2.*pL(j).*W.*cos(ptheta(j)+rot(k,(length(ds))*(i-1)+j)));
        end
        ddx(:,(length(ds))*(i-1)+j)=(Xi-.008)-dx(:,(length(ds))*(i-1)+j);
        pdx(:,(length(ds))*(i-1)+j)=(Xi-.008)-px(:,(length(ds))*(i-1)+j);
        dtau(:,(length(ds))*(i-1)+j)=W.*-1.*stiff.*ddx(:,(length(ds))*(i-1)+j);
        ptau(:,(length(ds))*(i-1)+j)=W.*stiff.*pdx(:,(length(ds))*(i-1)+j);
        for k=1:length(rot)
            if dtau(k,(length(ds))*(i-1)+j)>0
                dtau(k,(length(ds))*(i-1)+j)=0;
            end
            if ptau(k,(length(ds))*(i-1)+j)<0
                ptau(k,(length(ds))*(i-1)+j)=0;
            end
        end
        tau(:,(length(ds))*(i-1)+j)=dtau(:,(length(ds))*(i-1)+j)+ptau(:,(length(ds))*(i-1)+j);
    end
end
for i=1:length(ds)
    C{i}=[rad2deg(rot(:,length(ds)*(i-1)+i)),tau(:,length(ds)*(i-1)+i)];
end

%creates new grf columns
r1=zeros([length(A.data) 9]);
for i=gpass
    st=find(A.data(:,1)==IK{i}(1,1));
    ed=find(A.data(:,1)==IK{i}(end,1));
    VIK=interp1(IK{i}(:,1),IK{i}(:,ahead),A.data(st:ed,1),'spline');
    VTorque=interp1(C{3}(:,1),C{3}(:,2),VIK,'spline');
    r1(st:ed,9)=VTorque;
end
r2=-r1;
%apply r1 to talus and r2 to tibia