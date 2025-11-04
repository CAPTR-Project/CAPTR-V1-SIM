clc;
format long g

%% controller design
% controls_designer_session = load("linear_analysis/pitch_rate/ControlSystemDesignerSession.mat").ControlSystemDesignerSession;
controlSystemDesigner(G_att);