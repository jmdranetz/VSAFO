%This is the VSAFO OpenSim Pipeline
%Takes in IK and grf_r data with trial start/stop times
%Performs RRA RRA kinematics and adjusted models for each pass
%Loads the adjusted models and performs CMC on each pass
% ----------------------------------------------------------------------- %

import org.opensim.modeling.*

%setup files
rra_setupfile='C:\OpenSim\4.1\Models\VSAFO\T005\RRA\RRASetup.xml';
cmc_setupfile='C:\OpenSim\4.1\Models\VSAFO\T005\CMC\CMCSetup.xml';
ik_file='C:\OpenSim\4.1\Models\VSAFO\T006\IK\16mm\16mm_p';
ik_file_cap='.mot';
grf_file='C:\OpenSim\4.1\Models\VSAFO\T006\16mm_grf_r.xml';
rra_model_file='C:\OpenSim\4.1\Models\VSAFO\T006\RRA_models\16mm\T006_16mm_p';
rra_model_file_cap='_rra.osim';
rra_results_folder='C:\OpenSim\4.1\Models\VSAFO\T006\RRA\16mm\';
cmc_results_folder='C:\OpenSim\4.1\Models\VSAFO\T006\CMC\16mm\';
prefix='T006_16mm_p';
rra_q_file='C:\OpenSim\4.1\Models\VSAFO\T006\RRA\16mm\T006_16mm_p';
rra_q_file_cap='_Kinematics_q.sto';
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

gpass=[];
for i=1:10 %checks which passes have a file
    if isfile(strcat(ik_file,string(i),ik_file_cap))
        gpass=[gpass i];
    end
end

for i=gpass
    rraTool=RRATool(rra_setupfile); %loading RRA
    model = Model('C:\OpenSim\4.1\Models\VSAFO\T006\T006_VSAFO_Scaled.osim');
    model.initSystem();
    
    rraTool.setDesiredKinematicsFileName(strcat(ik_file,string(i),ik_file_cap));
    rraTool.setOutputModelFileName(strcat(rra_model_file,string(i),rra_model_file_cap));
    rraTool.setInitialTime(passtimes(i,1));
    rraTool.setFinalTime(passtimes(i,2));
    rraTool.setResultsDir(rra_results_folder);
    rraTool.setExternalLoadsFileName(grf_file);
    rraTool.setName(strcat(prefix,num2str(i)));
    fprintf(['Performing RRA on pass # ' num2str(i) '\n']);
    rraTool.run();
end

for i=gpass
    cmcTool=CMCTool(cmc_setupfile); %loading CMC
    model = Model(strcat(rra_model_file,string(i),rra_model_file_cap));
    model.initSystem();
    
    cmcTool.setDesiredKinematicsFileName(strcat(rra_q_file,string(i),rra_q_file_cap));
    cmcTool.setInitialTime(passtimes(i,1));
    cmcTool.setFinalTime(passtimes(i,2));
    cmcTool.setResultsDir(cmc_results_folder);
    cmcTool.setExternalLoadsFileName(grf_file);
    cmcTool.setName(strcat(prefix,num2str(i)));
    fprintf(['Performing CMC on pass # ' num2str(i) '\n']);
    cmcTool.run();
end