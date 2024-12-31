% environment
g = 9.807;
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

armTVC = [
    0
    -0.001
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

sample_time = 1/416;
alpha_rate = 1;
alpha_att = 1;
max_angle = 8*pi/180;