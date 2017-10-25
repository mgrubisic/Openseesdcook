function [ ] = fn_define_loads( analysis, damp_ratio, node, dt )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Write Loads File
file_name = ['Analysis' filesep analysis.id filesep 'loads.tcl'];
fileID = fopen(file_name,'w');

% Define Gravity Loads (node id, axial, shear, moment)
fprintf(fileID,'# Define Gravity Loads (node id, axial, shear, moment) \n');
fprintf(fileID,'timeSeries Linear 1 \n');
fprintf(fileID,'pattern Plain 1 1 {  \n');
for i = 1:length(node.id)
    fprintf(fileID,'   load %d 0.0 -%f 0.0 \n', node.id(i), node.weight(i));
end
fprintf(fileID,'} \n');

%% Write Gravity System Analysis
fprintf(fileID,'## GRAVITY ANALYSIS \n');
fprintf(fileID,'constraints Plain \n');
fprintf(fileID,'numberer Plain \n');
fprintf(fileID,'system BandGeneral \n');
fprintf(fileID,'integrator LoadControl 0.1 \n');
fprintf(fileID,'analysis Static	 \n');
fprintf(fileID,'analyze 10 \n');
fprintf(fileID,'loadConst -time 0.0 \n');

% Define Static Lateral Load Patter
fprintf(fileID,'# Define Load Pattern \n');
fprintf(fileID,'pattern Plain 2 Linear { \n');
for i = 1:length(node.id)
    fprintf(fileID,'  load %d %f 0.0 0.0 \n', node.id(i), node.force(i));
end
fprintf(fileID,'} \n');

% For Dynamic Analysis
if analysis.type == 3 || analysis.type == 4
    % Define Seismic Excitation Load
    fprintf(fileID,'# Define Seismic Excitation Pattern \n');
    fprintf(fileID,'timeSeries Path 2 -dt %f -filePath %s/%s -factor 386. \n',dt, analysis.eq_dir, analysis.eq_name); % timeSeries Path $tag -dt $dt -filePath $filePath <-factor $cFactor> <-useLast> <-prependZero> <-startTime $tStart>
    fprintf(fileID,'pattern UniformExcitation 3 1 -accel 2 \n'); % pattern UniformExcitation $patternTag $dir -accel $tsTag <-vel0 $vel0> <-fact $cFactor>
% 
    % Define Damping
    fprintf(fileID,'# set damping based on first eigen mode \n');
    fprintf(fileID,'set freq [expr [eigen -fullGenLapack 1]**0.5] \n');
    fprintf(fileID,'set period [expr 1/$freq] \n');
    fprintf(fileID,'puts $period \n');
    fprintf(fileID,'rayleigh 0 0 0 [expr %d*2/$freq] \n', damp_ratio);
end

% Close File
fclose(fileID);

end

