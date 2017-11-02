% Run Truss Tcl file in opensees
clear
close
clc

tic
%% Initial Setup 
import tools.*

%% Define Analysis parameters
analysis.id = 'test';
analysis.type = 4; % 1 = static force analysis, 2 = pushover analysis, 3 = dynamic analysis, 4 = calculate spectra
analysis.max_displ = 1; % only for pushover analsys
analysis.time_step = 0.01;

% Create Outputs Directory
output_dir = ['Analysis' filesep analysis.id];
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

% Define EQ ground motion
analysis.eq_dir = 'ground_motions/ATC_63_far_feild';
eqs = dir([analysis.eq_dir filesep '*eq_*']);
num_eqs = length(eqs);

%% Define Model Parameters
% 2d linear model single frame, 1 bay, uniform members
num_bays = 0;
num_stories = 1;
story_ht_in = 1000;
bay_width_in = 240;
foundation_fix = [1 1 1];
story_mass = 1;
story_force_k = 0;
story_weight_k = story_mass*386;
damp_ratio = 0.0;
E = 60000;
A = 9999999999999;
I = 13824;

if analysis.type == 4
    periods = 0.001:0.05:3.001;
%     periods = 1;
else
    periods = sqrt(story_mass/(3*E*I/story_ht_in^3))*2*pi();
end

%% Main Analysis
for i = 1:1
    % EQ this run
    analysis.eq_name = eqs(i).name;
    dt = 0.01;
    eq = load([analysis.eq_dir filesep analysis.eq_name]);
    
    for j = 1:length(periods)
        % Model properties for this run
        I = (story_mass * story_ht_in^3) / (3 * (periods(j)/(2*pi))^2 * E );
        T = sqrt(story_mass/(3*E*I/story_ht_in^3))*2*pi
        
        %% Create Model Databases
        [ node, element ] = fn_model_table( num_stories, num_bays, story_ht_in, bay_width_in, foundation_fix, story_mass, story_weight_k, story_force_k, A, E, I );

        %% Write TCL file
        fn_build_model( analysis.id, node, element )
        fn_define_recorders( analysis, node.id, element.id )
        fn_define_loads( analysis, damp_ratio, node, dt )
        fn_define_analysis( analysis, node.id, eq, dt )
        
        %% Run Opensees
        command = ['opensees ' 'Analysis' filesep analysis.id filesep 'run_analysis.tcl'];
        system(command);

        %% Load outputs and plot
        % Nodal Displacement (i)
        node.disp_x = dlmread([output_dir filesep 'nodal_disp_x.txt'],' ')';
        node.disp_y = dlmread([output_dir filesep 'nodal_disp_y.txt'],' ')';

        % Nodal Reaction (k)
        node.reac_x = dlmread([output_dir filesep 'nodal_reaction_x.txt'],' ')';
        node.reac_y = dlmread([output_dir filesep 'nodal_reaction_y.txt'],' ')';
        
        % Nodal Acceleration (in/s2)
        node.accel_x = dlmread([output_dir filesep 'nodal_accel_x.txt'],' ')';
        node.accel_y = dlmread([output_dir filesep 'nodal_accel_y.txt'],' ')';

        % Element Forces
        for k = 1:length(element.id)
            ele_force = dlmread([output_dir filesep 'element_' num2str(k) '_force.txt'],' ');
            element.fx1{k} = ele_force(:,1)';
            element.fy1{k} = ele_force(:,2)';
            element.mz1{k} = ele_force(:,3)';
            element.fx2{k} = ele_force(:,4)';
            element.fy2{k} = ele_force(:,5)';
            element.mz2{k} = ele_force(:,6)';
        end

        %% Display Results
        if analysis.type == 1 % static load analysis
            disp(element)
        elseif analysis.type == 2 % pushover analysis
            if num_bays ==0
                plot(abs(node.disp_x(end,:)),abs(node.reac_x(1,:)));
            else
                plot(abs(node.disp_x(end,:)),abs(sum(node.reac_x(1:(num_bays+1),:))));
            end
            grid on
        elseif analysis.type == 3 % dynamic analysis
            plot(node.disp_x(end,:))
        elseif analysis.type == 4 % spectra analysis
            total_eq_time = length(eq)*dt;
            old_time_vec = dt:dt:total_eq_time;
            new_time_vec = analysis.time_step:analysis.time_step:total_eq_time;
            new_eq_vec = interp1([0,old_time_vec],[0;eq],new_time_vec);
            
            sa(j) = max(abs(new_eq_vec-node.accel_x(end,:)/386));
            psa(j) = max(abs(((2*pi/T)^2)*node.disp_x(end,:)/386));
            
%             figure
%             hold on
%             grid on
%             legend('Location','eastoutside') 
%             xlabel('time (s)')
%             ylabel('disp (in)')
%             plot1 = plot(new_time_vec,node.disp_x(end,:),'DisplayName','Displacement');
%             saveas(plot1,'DC_disp.png')
%             hold off
%             close
% 
%             figure
%             hold on
%             grid on
%             legend('Location','eastoutside') 
%             xlabel('time (s)')
%             ylabel('accel (g)')
%             plot2 = plot(new_time_vec,new_eq_vec,'DisplayName','Ground Motion');
%             plot2 = plot(new_time_vec,new_eq_vec-node.accel_x(end,:)/386,'DisplayName','Absoulte Acceleration');
%             saveas(plot2,'DC_accel.png')
%             hold off
%             close
            
        else
            error('Unkown Analysis Type')
        end
    end
end

if analysis.type == 4 % spectra analysis
%     med_sa = median(sa);
%     med_sd = median(sd);
%     med_psa = median(psa);
    
    figure
    hold on
    grid on
    xlabel('Period (s)')
    ylabel('Sa (g)')
%     for i = 1:length(sa(:,1))
        plot3 = plot(periods,sa,'r','lineWidth',1);
        plot3 = plot(periods,psa,'k','lineWidth',0.5);
%     end
%     plot(periods,med_sa,'k','lineWidth',2)
%     plot(periods,med_sd,'r','lineWidth',2.5)
%     plot(periods,med_psa,'k','lineWidth',2)
    saveas(plot3,'DC_spectra.png')
    hold off
    close
end

toc
