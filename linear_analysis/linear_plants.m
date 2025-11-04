%% TF from pitch servo to pitch rate (plant for att rate controller)
G_rate = minreal(tf([-0.017463471379055, 11.6423142527021, -2587.18094504468, 191643.032966257], ...
    [1, 35.9182674299634, 622.376679243638, 0]));

%% rate compensator
C_rate = minreal(tf([0.0032072, 0.0353636, 0.01688], [0.00048, 1, 0]));

%% TF from rate command to pitch angle (plant for att controller)
s = tf('s');
G_CL = minreal(feedback(C_rate*G_rate, 1));
G_att = minreal(G_CL * 1/s)