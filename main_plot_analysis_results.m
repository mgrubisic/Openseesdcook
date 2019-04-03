function [ ] = main_plot_analysis_results( model, analysis, ele_prop_table )
% Description: Main script that compiles interesting results and creates
% visuals.

% Created By: Dustin Cook
% Date Created: 1/3/2019

% Inputs:

% Outputs:

% Assumptions:


%% Initial Setup
% Import Packages
import plotting_tools.*
import asce_41.*

% Define Read and Write Directories
read_dir = [analysis.out_dir filesep 'asce_41_data'];
read_dir_opensees = [analysis.out_dir filesep 'opensees_data'];
plot_dir = [analysis.out_dir filesep 'analysis_plots'];
% fn_make_directory( plot_dir )

% Load Analysis Data
load([read_dir filesep 'element_analysis.mat'])
load([read_dir filesep 'story_analysis.mat'])
load([read_dir filesep 'hinge_analysis.mat'])
load([read_dir filesep 'model_analysis.mat'])
load([read_dir filesep 'node_analysis.mat'])
% node = readtable([analysis.out_dir filesep 'model_data' filesep 'node.csv'], 'ReadVariableNames', true);
% load([read_dir_opensees filesep 'node_analysis.mat']) % Could probably change these to read from model inputs instead of the opensses analysis

if sum(analysis.type_list == 1) > 0 % Dynamic Analysis was run as part of this proceedure
    load([read_dir_opensees filesep 'gm_data.mat'])
end

if analysis.plot_recordings
    load([pwd filesep 'ground_motions' filesep 'ICSB_recordings' filesep 'recorded_edp_profile.mat']);
end

if exist([analysis.out_dir filesep 'backbones'],'dir')
    backbones = load([analysis.out_dir filesep 'backbones' filesep 'element_analysis.mat']);
end

%% Cyclic Analysis
if sum(analysis.type_list == 3) > 0 % Cyclic was run as part of this proceedure
    if analysis.element_plots
        % Load Pushover Results
        cyclic_read_dir = [analysis.out_dir filesep 'cyclic'];
        cyclic_analysis = load([cyclic_read_dir filesep 'analysis_options.mat']);
        if cyclic_analysis.analysis.nonlinear ~= 0 && exist('backbones','var') % Is the pushover nonlinear?
            % Plot Hinge Response
            cyclic_hinge = load([cyclic_read_dir filesep 'hinge_analysis.mat']);
            fn_plot_hinge_response( cyclic_read_dir, cyclic_read_dir, cyclic_hinge.hinge, backbones.element, ele_prop_table, node, analysis.hinge_stories_2_plot )
        end
    end
end

%% Pushover Analysis
if sum(analysis.type_list == 2) > 0 % Pushover was run as part of this proceedure
    pushover_read_dir = [analysis.out_dir filesep 'pushover'];
    pushover_analysis = load([pushover_read_dir filesep 'analysis_options.mat']);
    pushover_story_TH = load([pushover_read_dir filesep 'story_TH.mat']);
    % Plot Building Pushovers
    fn_plot_pushover( pushover_read_dir, 'x', story.story_dead_load, pushover_story_TH.story_TH.base_shear_x_TH )
    if strcmp(model.dimension,'3D')
        fn_plot_pushover( pushover_read_dir, 'z', story.story_dead_load, pushover_story_TH.story_TH.base_shear_z_TH )
    end
    
    if analysis.element_plots
        % Plot PM Diagrams for each element
%         fn_plot_PM_response( pushover_read_dir, pushover_read_dir, element, analysis.hinge_stories_2_plot )

        % Plot Hinge Response
        if pushover_analysis.analysis.nonlinear ~= 0 && exist('backbones','var') % Is the pushover nonlinear?
            pushover_hinge = load([pushover_read_dir filesep 'hinge_analysis.mat']);
            fn_plot_hinge_response( pushover_read_dir, pushover_read_dir, pushover_hinge.hinge, backbones.element, ele_prop_table, node, analysis.hinge_stories_2_plot )
        end
    end
end

%% Dynamic Analysis
if sum(analysis.type_list == 1) > 0 % Dynamic Analysis was run as part of this proceedure 
    %% ASCE 41 Acceptance Plots
    if strcmp(analysis.proceedure,'LDP') % Linear Procedures
        %% Plot DCR
        plot_variable = {'all', 'M', 'V', 'P'};
        frame_lines = {'ext', 'int'};
        if strcmp(model.dimension,'3D')% for 3D linear analysis
            for i = 1:length(plot_variable)
                for j = 1:length(frame_lines)
                    fn_plot_building( element.(['DCR_max_' plot_variable{i}]), element, node, ['DCR_view_' plot_variable{i} '_' frame_lines{j}], plot_dir, '3D', 'linear', frame_lines{j} )
                    fn_plot_building( element.(['DCR_raw_max_' plot_variable{i}]), element, node, ['DCR_view_' plot_variable{i} '_' frame_lines{j} '_raw'], plot_dir, '3D', 'raw', frame_lines{j} )
                end
            end

        else
            for i = 1:length(plot_variable)
                fn_plot_building_2D( element.(['DCR_max_' plot_variable{i}]), element, node, ['DCR_view_' plot_variable{i}], plot_dir,  'linear' )
                fn_plot_building_2D( element.(['DCR_raw_max_' plot_variable{i}]), element, node, ['DCR_view_' plot_variable{i} '_raw'], plot_dir,  'raw' )
            end
        end
    elseif strcmp(analysis.proceedure,'NDP') % Nonlinear Procedures
        %% Plot Hinge accpetance
        % Elevation
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Frame 1', plot_dir, 'x', 71, 1571, 0, 0 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Frame 2', plot_dir, 'x', 71, 1571, 300, 300 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Frame 3', plot_dir, 'x', 71, 1571, 600, 600 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Frame 4', plot_dir, 'x', 71, 1571, 900, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - West Upper Wall', plot_dir, 'z', 0, 0, 0, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Lower Wall 1', plot_dir, 'z', 71, 71, 0, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Lower Wall 2', plot_dir, 'z', 671, 671, 0, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Lower Wall 3', plot_dir, 'z', 971, 971, 0, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - Lower Wall 4', plot_dir, 'z', 1271, 1271, 0, 900 )
%         fn_plot_building_nl_3d( hinge, element, node, 'Acceptance Plot - East Upper Wall', plot_dir, 'z', 1500, 2000, 0, 900 )
        

        % Plan View
%         fn_plot_plan_view( hinge, element, node, 1, 'Story 1 Columns - Bottom', plot_dir )
%         fn_plot_plan_view( hinge, element, node, 2, 'Story 1 Columns - Top', plot_dir )

        %% Plot Element Scatter
%         fn_plot_element_scatter( element, 'column', story, hinge, plot_dir )
%         fn_plot_element_scatter( element, 'beam', story, hinge, plot_dir )
%         fn_plot_element_scatter( element, 'wall', story, hinge, plot_dir )
    end

    %% ASCE 41 Target Displacement
    [ target_disp_in.x ] = fn_spectra_and_target_displ( model, story, ground_motion, 'x' );
    if strcmp(model.dimension,'3D')
        if isfield(ground_motion,'z')
            [ target_disp_in.z ] = fn_spectra_and_target_displ( model, story, ground_motion, 'z' );
        else
          target_disp_in.z = NaN;
        end
    end        

    %% Filter accels
%     dirs_ran = {'x', 'z'};
%     import file_exchange.fn_accel_filter
%     import opensees.post_process.*
%     low_freq = 0; % hardcode to no high pass filter
%     for n = 1:height(node)
%         if node.record_disp(n)
%             load([read_dir_opensees filesep 'node_TH_' num2str(node.id(n)) '.mat'],'nd_TH')
%             for d = 1:2
%                 [ node_accel_filtered ] = fn_fft_accel_filter( nd_TH.accel_x_rel_TH, 0.01, 0.01:0.01:50, analysis.filter_high_freq, low_freq );
%                 nd_TH.(['accel_' dirs_ran{d} '_rel_TH']) = node_accel_filtered; % Convert to G  
%                 nd_TH.(['accel_' dirs_ran{d} '_abs_TH']) = node_accel_filtered + eq.(dirs_ran{d})';
%                 node.(['max_accel_' dirs_ran{d} '_rel'])(n) = max(abs(node_accel_filtered));
%                 node.(['max_accel_' dirs_ran{d} '_abs'])(n) = max(abs(node_accel_filtered + eq.(dirs_ran{d})'));
%             end
%             save([read_dir_opensees filesep 'node_TH_' num2str(node.id(n)) '.mat'],'nd_TH')
%         end
%     end
%     
%     for d = 1:2
%         [ story.(['max_accel_' dirs_ran{d}]) ] = fn_calc_max_repsonse_profile( node.(['max_accel_' dirs_ran{d} '_abs']), story, node, 0 );
%         story.(['max_accel_center_' dirs_ran{d}]) = node.(['max_accel_' dirs_ran{d} '_abs'])(node.center == 1 & node.record_accel == 1 & node.story > 0);
%     end
    
    %% Load in Recordings to compare with EDPs and Time Histories
    if analysis.plot_recordings
%         % Plot EDP Profiles
%         fn_plot_edp_profiles( plot_dir, ground_motion.x.pga, model, story, target_disp_in.x, 'x', record_edp)
%         if strcmp(model.dimension,'3D') && isfield(ground_motion,'z')
%             fn_plot_edp_profiles( plot_dir, ground_motion.z.pga, model, story, target_disp_in.z, 'z', record_edp )
%         end
% % 
% %         Plot specific TH comparisons
%         fn_plot_main_response_history( plot_dir, read_dir_opensees, node, analysis, eq_analysis_timespace, eq.x, ground_motion.x.eq_dt, 'x', record_edp )
%         if strcmp(model.dimension,'3D') && isfield(ground_motion,'z')
%             fn_plot_main_response_history( plot_dir, read_dir_opensees, node, analysis, eq_analysis_timespace, eq.z, ground_motion.z.eq_dt, 'z', record_edp )
%         end
    else
% %         Plot EDP Profiles
%         fn_plot_edp_profiles( plot_dir, ground_motion.x.pga, model, story, target_disp_in.x, 'x' )
%         if strcmp(model.dimension,'3D') && isfield(ground_motion,'z')
%             fn_plot_edp_profiles( plot_dir, ground_motion.z.pga, model, story, target_disp_in.z, 'z' )
%         end
% 
% %         Plot specific TH comparisons
%         fn_plot_main_response_history( plot_dir, read_dir_opensees, node, analysis, eq_analysis_timespace, eq.x, ground_motion.x.eq_dt, 'x' )
%         if strcmp(model.dimension,'3D') && isfield(ground_motion,'z')
%             fn_plot_main_response_history( plot_dir, read_dir_opensees, node, analysis, eq_analysis_timespace, eq.z, ground_motion.z.eq_dt, 'z' )
%         end
% 
    end

    %% Plots Element results for Dynamic analysis
    if analysis.element_plots
        % Plot PM Diagrams for each element
%         fn_plot_PM_response( plot_dir, read_dir, element, analysis.hinge_stories_2_plot )

        % Plot Hinge Response
        if exist('backbones','var')
            load([read_dir filesep 'hinge_analysis.mat'])
            fn_plot_hinge_response( plot_dir, read_dir_opensees, hinge, backbones.element, ele_prop_table, node, analysis.hinge_stories_2_plot, eq_analysis_timespace )
        end
    end
    
    %% Compile outputs table and write csv file
    idx = 0;
    if analysis.plot_recordings
        for i = 1:length(dirs_ran)
            idx = idx + 1;
            outputs.type{idx,:} = ['Record-' dirs_ran{i}];
            outputs.period(idx,:) = NaN; % Maybe figures out a way to do this automaticly
            outputs.max_roof_drift(idx,:) = record_edp.max_disp.(dirs_ran{i})(end) / sum(story.story_ht);
            outputs.max_roof_drift_center(idx,:) = record_edp.max_disp_center.(dirs_ran{i})(end) / sum(story.story_ht);
            rel_disp = record_edp.max_disp.(dirs_ran{i})(2:end) - record_edp.max_disp.(dirs_ran{i})(1:(end-1));
            outputs.max_drift(idx,:) = max( rel_disp(1:height(story)) ./ story.story_ht);
            outputs.max_first_story_drift_center(idx,:) = record_edp.max_disp_center.(dirs_ran{i})(2) / story.story_ht(1);
            end_of_record = 5/ground_motion.(dirs_ran{i}).eq_dt;
            roof_disp_TH = record_edp.disp_TH_roof.(dirs_ran{i});
            outputs.residual_drift(idx,:) = abs(mean(roof_disp_TH((end-end_of_record):end))) / sum(story.story_ht);
            outputs.max_base_shear(idx,:) = NaN;
            outputs.max_roof_accel(idx,:) = record_edp.max_accel.(dirs_ran{i})(end);   
            outputs.max_roof_accel_center(idx,:) = record_edp.max_accel_center.(dirs_ran{i})(end); 
        end
    end
    
    for i = 1:length(dirs_ran)
        idx = idx + 1;
        outputs.type{idx,:} = ['Analysis-' dirs_ran{i}];
        outputs.period(idx,:) = model.(['T1_' dirs_ran{i}]);
        outputs.max_roof_drift(idx,:) = story.(['max_disp_' dirs_ran{i}])(end) / sum(story.story_ht);
        outputs.max_roof_drift_center(idx,:) = story.(['max_disp_center_' dirs_ran{i}])(end) / sum(story.story_ht);
        outputs.max_drift(idx,:) = max(story.(['max_drift_' dirs_ran{i}]));
        outputs.max_first_story_drift_center(idx,:) = story.(['max_disp_center_' dirs_ran{i}])(1) / story.story_ht(1);
        outputs.residual_drift(idx,:) = story.(['residual_disp_' dirs_ran{i}])(end) / sum(story.story_ht);
        outputs.max_base_shear(idx,:) = story.(['max_reaction_' dirs_ran{i}])(1);
        outputs.max_roof_accel(idx,:) = story.(['max_accel_' dirs_ran{i}])(end);
        outputs.max_roof_accel_center(idx,:) = story.(['max_accel_center_' dirs_ran{i}])(end);
    end
    
    % Save as csv
    outputs_table = struct2table(outputs);
    writetable(outputs_table,[analysis.out_dir filesep 'analysis_summary.csv'])
end



end

