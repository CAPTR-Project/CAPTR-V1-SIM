clc;
format long g

%% find linearized system transfer function

sys = load("linear_analysis/pitch_rate/linsys_pitchrate.mat").linsys1;

Ts = sys.Ts;

% convert to continuous system
sys_c = d2c(sys, 'tustin');

% find tf
[num, den] = ss2tf(sys_c.A, sys_c.B, sys_c.C, sys_c.D)
G = minreal(tf(num, den))

%% controller design
controls_designer_session = load("linear_analysis/pitch_rate/ControlSystemDesignerSession.mat").ControlSystemDesignerSession;
controlSystemDesigner(controls_designer_session);