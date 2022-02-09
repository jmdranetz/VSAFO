# Description of programs in this repository

----------------------------------------------

Three files: Segmented_IK.m, VSAFO_ID.m, and VSAFO_Pipeline.m are scripts with OpenSim and require additional setup:
https://simtk-confluence.stanford.edu:8443/display/OpenSim/Scripting+with+Matlab

Segemented_IK.m: batch processing of Inverse Kinematics
Input: .osim model file, .xml setup file, .trc file with marker data, pass time data
Output: .mot file with IK data

VSAFO_ID.m: batch processing of Inverse Dynamics
Input: .osim model file, .xml setup file, .mot files with segmented IK data, .xml file that reference the .mot file with grf data
Output: .sto files with ID data

VSAFO_Pipeline.m: combined batch processing of RRA and CMC
Input: .osim model file, .xml setup files for both RRA and CMC, .mot files with segmented IK data,
.xml files that reference the .mot files with grf data, pass time data
Output: rra outputs, rra adjusted models, cmc outputs

----------------------------------------------

VSAFO_Rfinder.m: calculates the torque applied by the AFO based on the motion
Input: .mot file with GRF data, .mot files with segmented IK data
Output: r1 and r2 variables to be added manually to .mot file with GRF to create the _r.mot files

EMG_Processing.m: filters, segments, interpolates, and plots EMG data (uses the EMGFilter.m function)
Input: .mot file with GRF data, .csv file with EMG data, pass time data
Output: .mat file with interpolated EMG data, plots of EMG data

EMGFilter.m: function used in EMG_Processing.m to filter EMG data
Input: Filter settings, a column of raw EMG data
Output: A column of filtered EMG data

SLWB_finder.m: calculates step length and walking base (step width) for each walking condition
Input: .trc file with marker data, pass time data
Output: .mat file with SL/WB means and standard deviations

SLWB_plots: plots the SL/WB data
Input: .mat file with SL/WB means and standard deviations
Output: plots of SL's/WB's for each condition

interpolate_r.m: interpolates the AFO torque data
Input: _r.mot file with GRF and AFO torque data, .sto files with ID data (only used for pass time data)
Output: .mat file with interpolated AFO torque data

interpolate_IK.m: interpolates the inverse kinematic data
Input: .mot file with GRF, .mot files with IK data
Output: .mat file with interpolated IK data

interpolate_ID.m: interpolates the inverse dynamic data
Input: .mot file with GRF, .sto files with ID data
Output: .mat file with interpolated ID data

interpolate_CMC.m: interpolates the computed muscle control force data
Input: .mot file with GRF, .sto files with CMC force data
Output: .mat file with interpolated CMC force data

interpolate_CMCactivation.m: interpolates the computed muscle control activation data
Input: .mot file with GRF, .sto file with CMC activation data
Output: .mat file with interpolated CMC activation data

IK_plotter.m: plots inverse kinematic data
Input: .mat files with interpolated IK data (for each condition), .mat files with AFO torque data (for each condition with AFO torque)
Output: plots of inverse kinematics, adding a second plot next to the right ankle angle plot showing the applied ankle torque

ID_plotter.m: plots inverse dynamic data
Input: .mat files with interpolated ID data (for each condition)
Output: plots of inverse dynamics, shown as line and bar plots (segmented by gait events)

EMGplot.m: secondary script used for plotting EMG data
Input: .mat file with interpolated EMG data
Output: plots of EMG data

CMC_error_visualzer.m: plots various CMC variables to check quality of CMC data
Input: .mot file with GRF data, .sto files with with CMC force data
Outputs: plots of interpolated muscle forces (means and std's), plots of residual force actuators

CMCEMG_Compare.m: generates comparison plots of scaled EMG and CMC data
Input: .mat files with EMG and CMC data
Output: plots normalized (scaled) EMG and CMC data, shown as line and bar plots (segmented by gait events)
