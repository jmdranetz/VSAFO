%VSAFO ID
%Takes in IK and grf_r data with trial start/stop times
%Computes Inverse Dynamics to find ankle, knee, hip reaction loads
% ----------------------------------------------------------------------- %
import org.opensim.modeling.*

%input variables
subject='T003';
cond='8mm';
modelname='C:\OpenSim\4.1\Models\VSAFO\T003\T003_VSAFO_Scaled.osim';
freq=6;
%setup files
id_setupfile='C:\OpenSim\4.1\Models\VSAFO\Ref_ID_Setup.xml';

ik_file=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\IK\',cond,'\VSAFO_',cond,'_p');
ik_file_cap='.mot';
grf_file=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\',cond,'_grf_r.xml');
prefix=strcat(subject,'_',cond,'_p');
outdir=strcat('C:\OpenSim\4.1\Models\VSAFO\',subject,'\ID\',cond);

gpass=[];
for i=1:10 %checks which passes have a file
    if isfile(strcat(ik_file,string(i),ik_file_cap))
        gpass=[gpass i];
    end
end

for i=gpass
    idtool=InverseDynamicsTool(id_setupfile);
    model = Model(modelname);
    model.initSystem();
    
    idtool.setModel(model);
    idtool.setCoordinatesFileName(strcat(ik_file,string(i),ik_file_cap));
    idtool.setExternalLoadsFileName(grf_file);
    motData=Storage(strcat(ik_file,string(i),ik_file_cap));
    initial_time=motData.getFirstTime();
    final_time=motData.getLastTime();
    idtool.setStartTime(initial_time);
    idtool.setEndTime(final_time);
    idtool.setLowpassCutoffFrequency(freq);
    idtool.setResultsDir(outdir);
    idtool.setOutputGenForceFileName(strcat(prefix,num2str(i),'.sto'));
    fprintf(['Performing ID on pass # ' num2str(i) '\n']);
    idtool.run();
end