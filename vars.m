% environment
g = 9.807;

% rocket dynamics
m = 1;
r = 0.1;
h = 0.3;

armTVC = [
    0
    0
    0.4];

I_xx = (1/12) * m * (3*r^2 + h^2);
I_yy = I_xx; 
I_zz = (1/2) * m * r^2;

inertia = [I_xx, 0,    0;
     0,    I_yy, 0;
     0,    0,    I_zz];


% rocket aerodynamics
c_d = 0.2;