% environment
g = 9.807;
sample_time = 1/2000;

att_control_rate = 1/100;
rate_control_rate = 1/400;
servo_rate = 1/100; % 100 hz servo


% Contact model
contact.translation.spring = 3100;
contact.translation.damper = 100;
contact.translation.friction = 0.5;
contact.translation.vd = 0.02;
contact.translation.maxFriction = 20;
contact.translation.maxNormal = 80;

contact.rotation.spring = 2;
contact.rotation.damper = 1;
contact.rotation.friction = 0.03;
control.rotation.maxMoment = 0.1;
control.rotation.friction = 0.025;
control.rotation.vd = 0.2;

% rocket dynamics
m = 0.544; % kg
r_o = 0.0399; % m
r_i = 0.0381;
h = 0.4; % m
com = 0.215; % m
initial_euler = [0, 0*12*pi/180, 0];
att_setpoint_euler = [0, 0, 0];

TVC_angle_offset = [
    0.0;  % yaw
    0*-0.7*pi/180]; % pitch

armTVC = [
    0.0
    0.0
    0.1064];


% I_xx = (1/12) * m * (3*(r_o^2- r_i^2) + h^2) + m * com^2;% inertia as measured by pitch and roll
I_xx = 0.00628;
I_yy = I_xx; 
I_zz = (1/2) * m * r_o^2;

inertia = [I_xx, 0,    0;
     0,    I_yy, 0;
     0,    0,    I_zz];


% rocket aerodynamics
c_d = 0.2;

% tvc characterization
alpha_rate = 1;
alpha_att = 1;
max_angle = 8*pi/180;

% nlhw = load("sysid/nlhw.mat").nlhw13;
% ss_tvc = load("sysid/ss_tvc.mat").ss1;

tf_tvc = load("sysid/tf_tvc.mat").tf2;


%% mount estimate
r1 = 81.3e-3;

r2 = 140e-3;

I = 0.5 * 0.140 * (r1^2 + r2^2)

% % lin sys temp
% G_temp = linsys7(2)
% [num, den] = ss2tf(G_temp.A, G_temp.B, G_temp.C, G_temp.D)
% G = minreal(tf(num,den));