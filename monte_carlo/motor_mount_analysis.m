N_trials = 1000;
results = zeros(N_trials, 1);

end_pitch_rate = [];
end_yaw_rate = [];
lateral_offsets = [];
angular_offsets = [];

simIn = Simulink.SimulationInput.empty(0, N_trials);

for i=1:N_trials
    simIn(i) = Simulink.SimulationInput('main');
    % simIn(i) = simIn(i).setModelParameter('SimulationMode', 'rapid');

    % distribution of angular offset - assume uniform distribution from -0.5 deg
    % to 0.5 deg offset in both mount angles
    L_deg = 0.5; 
    L_rad = deg2rad(L_deg);
    offset_pitch_trial = -L_rad + (2 * L_rad) * rand();
    offset_yaw_trial = -L_rad + (2 * L_rad) * rand();
    
    % distribution of mount lateral offset - assume uniform distribution from
    % -0.5 mm to 0.5 mm
    L_shift = 0.0005; % 0.5mm
    d_z_trial = -L_shift + (2 * L_shift) * rand(); % yaw
    d_y_trial = -L_shift + (2 * L_shift) * rand(); % pitch

    % distribution of inertia uncertainty (gaussian)
    % with mean u = 0.00628. assuming tolerance of +- 20%, 3 sigma = 20% * u
    % thus 
    mu_inertia = 0.00628;
    std_inertia = 0.20 * mu_inertia / 3;
    
    ixx_trial = max(mu_inertia + std_inertia * randn(), 1e-10);
    iyy_trial = max(mu_inertia + std_inertia * randn(), 1e-10);

    % randomize cross coupling centered around 0 - guess a small std of 1e-6
    iyz_trial = 1e-6 * randn();
    ixz_trial = 1e-6 * randn();

    inertia_trial = [ixx_trial, 0,    ixz_trial;
                     0,   iyy_trial, iyz_trial;
                     ixz_trial,    iyz_trial,    4.3303e-04];
    
    TVC_angle_offset_val = [offset_yaw_trial; offset_pitch_trial]; 
    armTVC_val = [d_z_trial; d_y_trial; 0.1064];
    
    angular_offsets(:, i) = TVC_angle_offset_val;
    lateral_offsets(:, i) = armTVC_val;


    % set sim variables
    simIn(i) = simIn(i).setModelParameter('SimulationMode', 'accelerator');
    simIn(i) = simIn(i).setModelParameter('FastRestart', 'on');

    simIn(i) = simIn(i).setVariable('inertia', inertia_trial);
    simIn(i) = simIn(i).setVariable('TVC_angle_offset', TVC_angle_offset_val);
    simIn(i) = simIn(i).setVariable('armTVC', armTVC_val);

end

% Run sim
% simOut = parsim(simIn, 'UseParallel', true, 'UseFastRestart', 'on', 'SetupFcn', @() sldemo_parallel_rapid_accel_sims_script_setup('main'));

tic;
simOut = parsim(simIn, 'UseParallel', true, 'UseFastRestart', 'on', 'TransferBaseWorkspaceVariables', 'on'); 
toc;

% Extract results
for i = 1:N_trials
    rate = simOut(i).logsout.get('Wb').Values.Data;
    end_pitch_rate(i) = rate(end, 2);
    end_yaw_rate(i) = rate(end, 1);
end

%% plotting 

% Convert end pitch rates from radians to degrees
end_pitch_rate_deg = end_pitch_rate * 180/pi;

% Convert input offsets to degrees and millimeters
pitch_angular_offset_deg = angular_offsets(2, :) * 180/pi; % Pitch angular offset
shift_y_mm = lateral_offsets(2, :) * 1000; % Lateral Y shift (pitch plane) in mm

figure('Name', '1. End Pitch Rate Distribution');

% Histogram of End Pitch Rate
histogram(end_pitch_rate_deg, 40, 'FaceColor', [0.1 0.5 0.7]);
xlabel('End Pitch Rate (°)');
ylabel('Number of Trials');
grid on;

sgtitle(['Monte Carlo End Pitch Rate Distribution (N=' num2str(N_trials) ' Trials)']);

% Sensitivity to Offsets (Scatter Plots)
figure('Name', '2. Sensitivity Scatter Plots');

% Subplot 1: End Pitch Rate vs. Angular Offset
subplot(1, 2, 1);
scatter(pitch_angular_offset_deg, end_pitch_rate_deg, 10, 'filled', 'MarkerFaceAlpha', 0.6);
title('End Pitch Rate vs. Angular Offset');
xlabel('Initial Angular Offset (degrees)');
ylabel('End Pitch Rate (degrees)');
grid on;

% Subplot 2: End Pitch Rate vs. Lateral Shift
subplot(1, 2, 2);
scatter(shift_y_mm, end_pitch_rate_deg, 10, 'filled', 'MarkerFaceAlpha', 0.6);
title('End Pitch Rate vs. Lateral Shift');
xlabel('Initial Lateral Shift (mm)'); 
ylabel('End Pitch Rate (degrees)');
grid on;

sgtitle('Sensitivity to Manufacturing Offsets');