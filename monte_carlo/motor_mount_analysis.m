
N_trials = 1000;
results = zeros(N_trials, 1);

max_pitch = [];
max_yaw = [];
lateral_offsets = [];
angular_offsets = [];

for i=1:N_trials
    % distribution of angular offset - assume uniform distribution from -0.5 deg
    % to 0.5 deg offset in both mount angles
    L_deg = 0.5; 
    L_rad = deg2rad(L_deg);
    offset_pitch_trial = -L_rad + (2 * L_rad) * rand();
    offset_yaw_trial = -L_rad + (2 * L_rad) * rand();
    
    % % distribution of mount lateral offset - assume uniform distribution from
    % -0.5 mm to 0.5 mm
    L_shift = 0.0005; % 0.5mm
    d_z_trial = -L_shift + (2 * L_shift) * rand(); % yaw
    d_y_trial = -L_shift + (2 * L_shift) * rand(); % pitch
    
    angle_offset_block_path = "main/Rocket Dynamics1/TVC dynamics/TVC Forces and Torques/tvc_angle_offset";
    lateral_offset_block_path = "main/Rocket Dynamics1/TVC dynamics/TVC Forces and Torques/moment_arm";

    TVC_angle_offset_val = [offset_yaw_trial; offset_pitch_trial]; 
    armTVC_val = [d_z_trial; d_y_trial; 0.1064];
    
    angular_offsets(:, i) = TVC_angle_offset_val;
    lateral_offsets(:, i) = armTVC_val;

    set_param(angle_offset_block_path, 'Value', mat2str(TVC_angle_offset_val)); 
    set_param(lateral_offset_block_path, 'Value', mat2str(armTVC_val));

    % run sim
    out = sim('main.slx', 'FastRestart', 'on');
    rate_data = out.logsout.get('Wb').Values.Data;
    max_pitch(i) = max(abs(rate_data(:, 2)));
    max_yaw(i) = max(abs(rate_data(:, 1)));

    i
    i/N_trials

end

%% plotting 
% --- 1. Prepare Data for Plotting Clarity ---

% Convert max angles (outputs) from radians to degrees
max_pitch_deg = max_pitch * 180/pi;
max_yaw_deg = max_yaw * 180/pi;

% Convert input offsets to degrees and millimeters
pitch_angular_offset_deg = angular_offsets(2, :) * 180/pi; % Pitch angular offset
shift_y_mm = lateral_offsets(2, :) * 1000; % Lateral Y shift (pitch plane) in mm

% --- 2. Figure 1: Distribution of Maximum Stability Angles ---
% This shows how likely the rocket is to wobble by a certain amount.

figure('Name', '1. Outcome Distribution (Robustness)');

% Subplot 1: Pitch Stability Histogram
subplot(1, 2, 1);
histogram(max_pitch_deg, 40, 'FaceColor', [0.1 0.5 0.7]);
title('Distribution of Max Pitch Rate');
xlabel('Max Absolute Pitch Rate (\circ)');
ylabel('Number of Trials');
grid on;

% Subplot 2: Yaw Stability Histogram
subplot(1, 2, 2);
histogram(max_yaw_deg, 40, 'FaceColor', [0.7 0.3 0.1]);
title('Distribution of Max Yaw Rate');
xlabel('Max Absolute Yaw Rate (\circ)');
ylabel('Number of Trials');
grid on;

sgtitle(['Monte Carlo Performance Distribution (N=' num2str(N_trials) ' Trials)']);

% --- 3. Figure 2: Sensitivity to Offsets (Scatter Plots) ---
% This shows the relationship between input uncertainty and stability output.

figure('Name', '2. Sensitivity Scatter Plots');

% Subplot 1: Max Pitch vs. Angular Offset
subplot(1, 2, 1);
scatter(pitch_angular_offset_deg, max_pitch_deg, 10, 'filled', 'MarkerFaceAlpha', 0.6);
title('Pitch Rate vs. Angular Offset');
xlabel('Initial Angular Offset (degrees)');
ylabel('Max Pitch Rate Reached (degrees)');
grid on;

% Subplot 2: Max Pitch vs. Lateral Shift
subplot(1, 2, 2);
scatter(shift_y_mm, max_pitch_deg, 10, 'filled', 'MarkerFaceAlpha', 0.6);
title('Pitch Rate vs. Lateral Shift');
xlabel('Initial Lateral Shift (mm)'); 
ylabel('Max Pitch Rate Reached (degrees)');
grid on;

sgtitle('Sensitivity to Manufacturing Offsets');