function [ ] = fn_define_analysis( output_dir, analysis, nodes, ground_motion )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%% Define Parameters
if analysis.type == 1 % static load analysis
    int_controller = 'LoadControl 1';
    num_steps = 1;
    analysis_str_id = 'Static';
    time_step = 0;
elseif analysis.type == 2 % pushover analysis
    control_node = nodes(end);
    control_dof = 1;
    num_steps = 10;
    step_size = analysis.max_disp / num_steps;
    int_controller = ['DisplacementControl ' num2str(control_node) ' ' num2str(control_dof) ' ' num2str(step_size)]; 
    analysis_str_id = 'Static';
    time_step = 0;
elseif analysis.type == 3 || analysis.type == 4 % dynamic analysis
    gamma = 0.5; %trapezoidal
    beta = 0.25;
    int_controller = ['Newmark' ' ' num2str(gamma) ' ' num2str(beta)];
    analysis_str_id = 'Transient';
    time_step = analysis.time_step;
    num_steps = (ground_motion.x.eq_length*ground_motion.x.eq_dt)/time_step;
else
    error('Unkown Analysis Type')
end

%% Write Loads File
file_name = [output_dir filesep 'run_analysis.tcl'];
fileID = fopen(file_name,'w');

% Clear set up for this analysis
fprintf(fileID,'wipe \n');

% Build Model and Analysis Parameters
fprintf(fileID,'source %s/model.tcl \n', output_dir);
if analysis.run_eigen
    fprintf(fileID,'source %s/eigen.tcl \n', output_dir);
end
fprintf(fileID,'source %s/loads.tcl \n', output_dir);
fprintf(fileID,'source %s/recorders.tcl \n', output_dir);

% ANALYSIS DEFINITION
fprintf(fileID,'wipeAnalysis \n');

% Define Constraints
fprintf(fileID,'constraints Transformation \n');

% Define the DOF_numbered object
fprintf(fileID,'numberer RCM \n');

% Construct Linear Solver and linear SOE Objects
fprintf(fileID,'system BandGeneral \n');

% Test for Convergence
fprintf(fileID,'test NormDispIncr 1.0e-4 10000 \n');

% Define Solution Algorithm
% fprintf(fileID,'algorithm Linear \n');
fprintf(fileID,'algorithm Newton \n');
% fprintf(fileID,'algorithm KrylovNewton \n');

% Define Each Load Step
fprintf(fileID,'integrator %s \n',int_controller);

% Define analysis type
fprintf(fileID,'analysis %s \n',analysis_str_id);

%% Run the Analysis
fprintf(fileID,'analyze %i %f \n',round(num_steps), time_step);
fprintf(fileID,'puts "Done!" \n');
fprintf(fileID,'wipe \n');

% Close File
fclose(fileID);


end
