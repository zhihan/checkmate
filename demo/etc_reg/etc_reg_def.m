% Constants, measured from physical system  (each is normalized by J)
KsJ = 390;             % (rad/s^2) / rad
KdJ = 0.1;             % (rad/s^2) / (rad/s)
KfJ = 140;             % (rad/s^2)
Ra = 1.7;		        % ohms
theta_eq = -0.25;	    % rad
KtRaJ = 140;

% Assumptions
J = 5e-5; 	            % kg-m^2

% Derived constants
Ks = KsJ*J;	        % N-m/rad assumed springconstant
Ks_real=Ks*J;       % real springconstant
Kf = KfJ*J; 	        % N-m
Kd = KdJ*J;            % N-m/rad/s

% Actuators parameters
minmotoramps = 0.0;
maxmotoramps = 5.4545; %Derived for actuator and driver (Ansgar)

% Power Electronics
Ra = 1.7;               % resistance of motor windings (Ohms)
Rc = 1.5;               % resistance of RC filter (Ohms)
Rbat = 0.5;             % internal resistance of battery (Ohms)
L = 1.5e-3;             % motor winding inductance (Henrys)
C = 1.5e-3;             % capacitance of RC filter (Farads)

Kt = Ra*J*KtRaJ;      % N-m/A, derived constant

% Controller - Servo Control parameters
% Observer and controller parameters
lambda = 60;
n = 2.0;                %Amps



% epsilon on the boundary layer around the swithing surface
layereps=0.05;
sliding_factor=1;% in [0,1] usually 1;

% Stepsize
alpha_des=(pi/2)*(89.8/90);


% To define the thresholds for the saturation on the input we first have
% to compute the part of the imput that depends on the state.
% x1 first state variable of filter
% x2 2nd state variable of filter
% x3 alpha
% x4 omega
% x5 clock of test automaton
% x6 constant modelling the mode

x1=[0 0];
x2=[0 0];
x3=[1 0];
x4=[0 1];
x5=[0 0];



% First, define the sliding surface
surfA=lambda*(x3)+(x4);
surfB=-lambda*alpha_des;


