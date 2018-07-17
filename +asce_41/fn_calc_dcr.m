function [ element, DCR_max_raw ] = fn_calc_dcr( element, perform_level, c1, c2, seismicity )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

element.DCR_P_raw = element.Pmax ./ element.Pn;
element.DCR_M_raw = element.Mmax ./ element.Mn_aci;
for i = 1:length(element.id)
    if strcmp(element.type{i},'column')
        element.DCR_V_raw(i,1) = element.Vmax(i) / element.Vn(i);
    elseif strcmp(element.type{i},'beam')
        element.DCR_V_raw(i,1) = element.Vmax(i) / element.Vn_aci(i);
    else
        element.DCR_V_raw(i,1) = 1;
    end
end
DCR_max_raw = max([element.DCR_P_raw; element.DCR_V_raw; element.DCR_M_raw]);

% Modify DCR by m factor for deformation controlled (ASSUME ALL MOMENTS ARE DEFORMATION CONTROLLED)
element.DCR_M = element.DCR_M_raw ./ element.(['m_' perform_level]);
element.DCR_V = element.DCR_V_raw ./ element.(['m_' perform_level]);

% Calculate Quf for force controlled actions (ASSUME ALL AXIAL IS FORCE CONTROLLED)
if strcmp(perform_level,'cp')
    x = 1;
else
    x = 1.3;
end
if strcmp(seismicity,'high')
    j = 2;
elseif strcmp(seismicity,'high')
    j = 1.5;
else
    j = 1;
end
P_quf_factors = x/(c1*c2*j); % ONLY SUPPOSED TO APPLY TO EQ DEMANDS, NOT GRAVITY (UPDATE)
element.DCR_P = P_quf_factors*element.DCR_P_raw;

% Total DCR
element.DCR_total = max([element.DCR_M,element.DCR_V,element.DCR_P],[],2);
element.DCR_total_raw = max([element.DCR_M_raw,element.DCR_V_raw,element.DCR_P_raw],[],2);


end

