function [ ] = fn_define_loads( story_force_k, story_wieght_k, analysis_id, damp_ratio, analsys_type )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Write Loads File
file_name = ['Analysis' filesep analysis_id filesep 'loads.tcl'];
fileID = fopen(file_name,'w');

% Define Gravity Loads (node id, axial, shear, moment)
fprintf(fileID,'# Define Gravity Loads (node id, axial, shear, moment) \n');
fprintf(fileID,'pattern Plain 1 Linear {  \n');
fprintf(fileID,'   load 3 0.0 %d 0.0 \n', story_wieght_k/2);
fprintf(fileID,'   load 4 0.0 %d 0.0 \n', story_wieght_k/2);
fprintf(fileID,'} \n');

% Define Static Lateral Load Patter
fprintf(fileID,'# Define Load Pattern \n');
fprintf(fileID,'pattern Plain 2 Linear { \n');
fprintf(fileID,'  load 3 %d 0.0 0.0 \n', story_force_k);
fprintf(fileID,'} \n');

% For Dynamic Analysis
if analsys_type == 3
    % Define Seismic Excitation Load
    fprintf(fileID,'# Define Seismic Excitation Pattern \n');
    fprintf(fileID,'timeSeries Path 1 -dt 0.005 -filePath ground_motions/A10000.tcl -factor 386 \n'); % timeSeries Path $tag -dt $dt -filePath $filePath <-factor $cFactor> <-useLast> <-prependZero> <-startTime $tStart>
    fprintf(fileID,'pattern UniformExcitation 3 1 -accel 1 \n'); % pattern UniformExcitation $patternTag $dir -accel $tsTag <-vel0 $vel0> <-fact $cFactor>

    % Define Damping
    fprintf(fileID,'# set damping based on first eigen mode \n');
    fprintf(fileID,'set freq [expr [eigen -fullGenLapack 1]**0.5] \n');
    fprintf(fileID,'  rayleigh 0. 0. 0. [expr 2*%d/$freq] \n', damp_ratio);
end

% Close File
fclose(fileID);

end

