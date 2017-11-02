%% Method To calculate SDOP Response Spectra
clear
close
clc

%% Initailize Paramaters
% import hbr.str_eng.fn_sdof_th
dt = 0.01;
T = 0.001:0.05:3.001;
% T = 1;
damp_ratio = 0.00;

%% Load in EQ data
load(['ground_motions' filesep 'data_ground_accel_th.mat']);
% load(['data_ground_motion' filesep 'data_atc_63_spectra.mat']);

%% Run SDOF response spectra\
eq_list = fieldnames(pga_th_g);
num_eq = numel(eq_list);
for i = 1:1
    ag = pga_th_g.(eq_list{i});
    time_vec = dt:dt:(length(ag)*dt);
    for j = 1:length(T)
        [psuedoAccelerationTH, displacementTH, accelerationTH] = fn_sdof_th(T(j), damp_ratio, ag, dt);

        total_eq_time = length(ag)*dt;
        time_step = (length(ag)/length(accelerationTH))*dt;
        old_time_vec = dt:dt:total_eq_time;
        new_time_vec = time_step:time_step:total_eq_time;
        new_eq_vec = interp1([0,old_time_vec],[0;ag],new_time_vec);
        
        max_sa(i,j) = max(abs(new_eq_vec'-accelerationTH));
        max_sa_psuedo(i,j) = max(abs(psuedoAccelerationTH));  
        
%         hold on
%         grid on
%         legend('Location','eastoutside') 
%         xlabel('time (s)')
%         ylabel('disp (in)')
%         plot1 = plot(new_time_vec,displacementTH*386,'DisplayName','Displacement');
%         saveas(plot1,'Newmark_disp.png')
%         hold off
%         close
% 
%         hold on
%         grid on
%         legend('Location','eastoutside') 
%         xlabel('time (s)')
%         ylabel('accel (g)')
%         plot2 = plot(new_time_vec,new_eq_vec,'DisplayName','Ground Motion');
%         plot2 = plot(new_time_vec,new_eq_vec'-accelerationTH,'DisplayName','Absoulte Acceleration');
%         saveas(plot2,'Newmark_accel.png')
%         hold off
%         close
        
    end
end

% med_spectra = median(max_sa,1);
% med_spectra_psuedo = median(max_sa_psuedo,1);
% med_pre_calc_spectra = median(sa_full_table(5:end,2:end),2);

%% Create Mean Response Spectra
hold on
grid on
xlabel('Period (s)')
ylabel('Sa (g)')
% for i = 2:length(sa_full_table(1,:))
%     plot(sa_full_table(5:end,1),sa_full_table(5:end,i),'b','lineWidth',0.5)
% end
for i = 1:length(max_sa_psuedo(:,1))
    plot3 = plot(T,max_sa(i,:),'b','lineWidth',0.5);
    plot3 = plot(T,max_sa_psuedo(i,:),'k','lineWidth',0.5);
end
% plot(sa_full_table(5:end,1),med_pre_calc_spectra,'r','lineWidth',2.5)
% plot(T,mean_spectra,'c','lineWidth',2.5)
% plot(T,med_spectra_psuedo,'k','lineWidth',2)
saveas(plot3,'Jack_spectra.png')
hold off
close
