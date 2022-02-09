%Inputs .trc file and pass times and runs batch segmented IK
import org.opensim.modeling.*

setupfile='C:\OpenSim\4.1\Models\VSAFO\T005\IK\vsafoscale.xml';
trc_file='C:\OpenSim\4.1\Models\VSAFO\T006\Data\VSAFO_16mm_Marker.trc';
results_folder='C:\OpenSim\4.1\Models\VSAFO\T006\IK\16mm\';

%good pass times
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


ikTool=InverseKinematicsTool(setupfile);

% Load the model and initialize
model = Model('C:\OpenSim\4.1\Models\VSAFO\T006\T006_VSAFO_Scaled.osim');
model.initSystem();
% Tell Tool to use the loaded model
ikTool.setModel(model);

for i=1:length(passtimes)
    if ~isnan(passtimes(i,1))
        ikTool.setName('T006_VSAFO_Scaled');
        ikTool.setMarkerDataFileName(trc_file);
        ikTool.setStartTime(passtimes(i,1));
        ikTool.setEndTime(passtimes(i,2));
        ikTool.setOutputMotionFileName(fullfile(results_folder,strcat('16mm_p',num2str(i),'.mot')));
        fprintf(['Performing IK on pass # ' num2str(i) '\n']);
        ikTool.run();
    end
end
