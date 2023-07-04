% Closed-loop modeling of intrinsic cardiac nervous system contributions to respiratory sinus arrhythmia
% Michelle Gee
% June 15, 2023

% Elisabetta Iavarone, June 27, 2023: modified to run with compiled Matlab and accept command line arguments as input parameters

% Script to run model with alternative VNS stimulation frequency and plot
% output heart rate, systemic arterial pressure, and left ventricular
% elastance

%clear; close all;
function ICN_model_osparc_mcc_func(kVNS_aff, kVNS_eff)
        %% ICN parameter values
    Params = [0.857242 12.624676 13.811104 3.230162 1.988567 18.375719 521.217197 3.003231 2.415242 17.718990 14.183806 13.356069 3.329861 2.661685 5.642977 0.066794];
    kRSA = 0.5;
    
    sprintf('Setting up Simulink model with inputs VNS_aff:%.2f and kVNS_eff:%.2f', str2num(kVNS_aff), str2num(kVNS_eff))

    % Define simulink input
    mdlName = 'ICN_model_v15_VNS'; % Note: start time original 0.5, now 0.4 (see MG's email on June 30)
    simIn = Simulink.SimulationInput(mdlName);
    simIn = simIn.setVariable('minval_NA_PN',Params(1));
    simIn = simIn.setVariable('fmax_NA_PN',Params(2));
    simIn = simIn.setVariable('midptNA_PN',Params(3));
    simIn = simIn.setVariable('kNA', Params(4));
    simIn = simIn.setVariable('minval_LCN',Params(5));
    simIn = simIn.setVariable('fmax_LCN',Params(6));
    simIn = simIn.setVariable('midptLCN',Params(7));
    simIn = simIn.setVariable('kLCN',Params(8));
    simIn = simIn.setVariable('minval_DMV_PN',Params(9));
    simIn = simIn.setVariable('fmax_DMV_PN',Params(10));
    simIn = simIn.setVariable('midptDMV_PN',Params(11));
    simIn = simIn.setVariable('kDMV_PN',Params(12));
    simIn = simIn.setVariable('LCN_fevEmaxgain', Params(13));
    simIn = simIn.setVariable('LCN_BRgain', Params(14));
    simIn = simIn.setVariable('LCN_CPgain', Params(15));
    simIn = simIn.setVariable('LCN_feshgain',Params(16));
    simIn = simIn.setVariable('kRSA', kRSA);
    simIn = simIn.setVariable('kVNS_aff', str2num(kVNS_aff));
    simIn = simIn.setVariable('kVNS_eff', str2num(kVNS_eff));
  
    simIn = simulink.compiler.configureForDeployment(simIn);
    
    % Run simulation
    simOut = sim(simIn);

    %% RR interval calculation
    simTime = simOut.time;
    tbase = [150 270];
    tbaseIdx        = find(simTime>= tbase(1)  & simTime <= tbase(2));

    time = simOut.time(tbaseIdx);
    phi = simOut.Phi(tbaseIdx);

    % RR interval calculation for baseline interval
    % Determine indices for when phi=0 (beginning and end of heart beat)
    for i = length(phi):-1:2
        if phi(i) == phi(i-1)
            phi(i-1) = [];
            time(i-1) = [];
        end
    end

    RRidx = find(~phi);
    RRtimes = time(RRidx);
    RRbaseSim = diff(RRtimes);

    % RR interval calculation for stimulation interval
    time = simOut.time(tbaseIdx);
    phi = simOut.Phi(tbaseIdx);

    % Determine indices for when phi=0 (beginning and end of heart beat)
    for i = length(phi):-1:2
        if phi(i) == phi(i-1)
            phi(i-1) = [];
            time(i-1) = [];
        end
    end

    RRidx = find(~phi);
    RRtimes = time(RRidx);
    RR = diff(RRtimes);

    timePlot = RRtimes;%repelem(RRtimes,2);
    %timePlot(1) = []; % get rid of first entry and last time entry to align
    timePlot(end) = [];
    
    %% Plot
    plotlim = [150 270];
    simTime         = simOut.time; % time output vector from simulation
    tplotIdx       = find(simTime>= plotlim(1) & simTime <= plotlim(2));

    % Plot formatting
    fs = 12; % font size
    lw = 2; % line width
    rows = 3; % subplot dimensions
    cols = 1;

    
    % RR interval, systemic arterial pressure, left ventricular elastance
    fig = figure(1);

    % Do not show figure
    set(fig, 'visible', 'off')
    
    % Systemic arterial pressure (Psa)
    subplot(rows,cols,1);
    %In the new implementation, ts_Psa is not a timeseries anymore, so getsampleusingtime can't be used
    %plot(getsampleusingtime(ts_Psa,plotlim(1),plotlim(2)),'b','LineWidth',lw)

    
    plot(simOut.Psa_TS.time(tplotIdx), simOut.Psa_TS.signals.values(tplotIdx), 'b','LineWidth',lw);
    title(sprintf('VNS Afferents %.2f, VNS efferents %.2f', str2num(kVNS_aff), str2num(kVNS_eff)), 'FontWeight','Normal');
    ylabel({'Mean arterial'; 'pressure (mm Hg)'},'FontSize',fs);
    xlabel('');
    ax = gca;
    set(gca,'FontSize',fs);
    xlim(plotlim);

    % Left ventricular elastance (Emaxlv)
    subplot(rows,cols,2);
    %In the new implementation, Emaxlv is not a timeseries anymore, so getsampleusingtime can't be used
    %plot(getsampleusingtime(simOut.Emaxlv,plotlim(1),plotlim(2)),'b','LineWidth',lw)
    plot(simOut.Emaxlv.time(tplotIdx), simOut.Emaxlv.signals.values(tplotIdx),'b','LineWidth',lw);
    ylabel({'Left ventricular'; 'elastance (mm Hg/mL)'},'FontSize',fs);
    xlabel('Time (s)','FontSize',fs);
    ax = gca;
    set(gca,'FontSize',fs);
    xlim(plotlim);

    % RR interval
    subplot(rows,cols,3);
    stairs(timePlot,RR,'b','LineWidth',lw);
    xlabel('Time (s)');
    ylabel('RR interval (s)');
    xlim(plotlim);

    % save figure
    set(gca,'FontSize',fs);
    set(gcf, 'Position',  [10, 10, 700, 600]);
    saveas(gcf, 'RR_Psa_Emaxlv.png');
    
    % Export processed data to plot with other tools
    % RR intervals
    T = table(timePlot,RR, 'VariableNames', { 'Time (s)', 'RR interval (s)'});
    writetable(T, 'RRintervals.txt');
    % Systemic arterial pressure (Psa)RR intervals
    T = table(simOut.Psa_TS.time(tplotIdx), simOut.Psa_TS.signals.values(tplotIdx), 'VariableNames', { 'Time (s)', 'Mean arterial pressure (mm Hg)'} );
    writetable(T, 'ArterialPressure.txt');
    % Left ventricular elastance (Emaxlv)
    T = table(simOut.Emaxlv.time(tplotIdx), simOut.Emaxlv.signals.values(tplotIdx), 'VariableNames', { 'Time (s)', 'Left ventricular elastance (mm Hg/mL)'} );
    writetable(T, 'Elastance.txt');    
end