%Script that inputs marker and finds the step length and
%walking base
clear variables
%Input file names
subject='T005';
cond='16mm';
trial='';
Markername=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Data\',cond,'_Walking',trial,'_Marker.trc');
Outname=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\Interpolated_Results\',cond,'_SL_WB.mat');
%good pass times
passtimes=[7.94,	9.06;
17.51,	18.55;
NaN,	NaN;
34.01,	35.04;
41.43,	42.5;
49.67,	50.7;
57.64,	58.74;
66.12,	67.22;
73.57,	74.7;
82.11,	83.16];

opts = delimitedTextImportOptions("NumVariables", 141);
% Specify range and delimiter
opts.DataLines = [7, Inf];
opts.Delimiter = "\t";
% Specify column names and types
opts.VariableNames = ["Frame", "Time", "RASI", "VarName4", "VarName5", "RPSI", "VarName7", "VarName8", "LPSI", "VarName10", "VarName11", "LASI", "VarName13", "VarName14", "RSAT", "VarName16", "VarName17", "RLAT", "VarName19", "VarName20", "RIAT", "VarName22", "VarName23", "RFIB", "VarName25", "VarName26", "RASH", "VarName28", "VarName29", "RLML", "VarName31", "VarName32", "RMML", "VarName34", "VarName35", "RCAL", "VarName37", "VarName38", "RMT5", "VarName40", "VarName41", "RTOE", "VarName43", "VarName44", "LFIB", "VarName46", "VarName47", "LMML", "VarName49", "VarName50", "LASH", "VarName52", "VarName53", "LLML", "VarName55", "VarName56", "LSAT", "VarName58", "VarName59", "LIAT", "VarName61", "VarName62", "LLAT", "VarName64", "VarName65", "LCAL", "VarName67", "VarName68", "LMT5", "VarName70", "VarName71", "LTOE", "VarName73", "VarName74", "LABK", "VarName76", "VarName77", "RABK", "VarName79", "VarName80", "CLAV", "VarName82", "VarName83", "CEV7", "VarName85", "VarName86", "RACR", "VarName88", "VarName89", "LACR", "VarName91", "VarName92", "LSAA", "VarName94", "VarName95", "LIAA", "VarName97", "VarName98", "LLHE", "VarName100", "VarName101", "LMHE", "VarName103", "VarName104", "LUHD", "VarName106", "VarName107", "LRSP", "VarName109", "VarName110", "LUSP", "VarName112", "VarName113", "RSAA", "VarName115", "VarName116", "RIAA", "VarName118", "VarName119", "RLHE", "VarName121", "VarName122", "RUHD", "VarName124", "VarName125", "RRSP", "VarName127", "VarName128", "RUSP", "VarName130", "VarName131", "RLFC", "VarName133", "VarName134", "LLFC", "VarName136", "VarName137", "RMHE", "VarName139", "VarName140", "VarName141"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, "VarName141", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "VarName141", "EmptyFieldRule", "auto");
% Import the data
A=readtable(Markername,opts);
% Clear temporary variables
clear opts

headnames=A.Properties.VariableNames; %finds headers
for i=1:length(headnames)
    if strcmp(headnames{i},'Time')
        timehead=i;
    elseif strcmp(headnames{i},'RCAL')
        rchead=i;
    elseif strcmp(headnames{i},'LCAL')
        lchead=i;
    end 
end

%finds SL and WB each pass
sw=zeros([10,2]);
for i=1:length(passtimes)
    if ~isnan(passtimes(i,1))
        clear rcoord lcoord dist
        rcoord=A{(find(A.Time==passtimes(i,1)):find(A.Time==passtimes(i,2))),rchead:2:rchead+2};
        lcoord=A{(find(A.Time==passtimes(i,1)):find(A.Time==passtimes(i,2))),lchead:2:lchead+2};
        for j=1:length(rcoord)
            dist(j)=sqrt((rcoord(j,1)-lcoord(j,1)).^2+(rcoord(j,1)-lcoord(j,1)).^2);
        end
        maxcoord=find(dist==max(dist));
        sw(i,:)=[abs(rcoord(maxcoord,1)-lcoord(maxcoord,1)),abs(rcoord(maxcoord,2)-lcoord(maxcoord,2))];
    end
end
a(:,1)=sw(find(sw(:,1)~=0));
a(:,2)=sw(find(sw(:,2)~=0),2);
slwb=mean(a,1);
std_slwb=std(a,1);
save(Outname,'slwb','std_slwb')