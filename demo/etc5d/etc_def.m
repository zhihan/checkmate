% Constants, measured from physical system  (each is normalized by J)
	KsJ = 390;             % (rad/s^2) / rad
	KdJ = 0.1;             % (rad/s^2) / (rad/s)
	KfJ = 140;             % (rad/s^2)
	Ra = 1.7;		        % ohms
	alpha_eq = -0.25;	    % rad
	KtRaJ = 140;
	
% Assumptions
	J = 5e-5; 	            % kg-m^2
	
% Derived constants
	Ks = KsJ*J;	        % N-m/rad assumed springconstant
    Kf = KfJ*J; 	        % N-m
	Kd = KdJ*J;            % N-m/rad/s

% Actuators parameters
	minmotoramps = 0.0;
	maxmotoramps = 5.4545;  % Derived for actuator and driver 

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

% fifth order filter with a char. poly.
	%pf = poly([-80, -80, -90, -90, -100]);
    %alphaF = tf(pf(length(pf)), pf);
 
% Obtaining the 5 order filter in ss-form, and reducing the order (ANSGAR)
    %alpha_ss=idss(alphaF);
    %red_fil=idmodred(alpha_ss,2);
    red_fil.A=[ -4.88427742237871  34.99395943211615
               -34.99395943211584 -61.05770052698014];
    red_fil.B=[ -2.66753528921079
                -5.86307059814278];
    red_fil.C=[-2.66753528921082   5.86307059814278];
    red_fil.D=[0.10613443134267];

    
% epsilon on the boundary layer around the swithing surface
    layereps=0.05;
    
    
% Stepsize
    alpha_des=(pi/2)*(89.8/90);

    
% To define the thresholds for the saturation on the input we first have 
% to compute the part of the imput that depends on the state.
% x1 first state variable of filter
% x2 2nd state variable of filter
% x3 alpha
% x4 omega


x1=[1 0 0 0];
x2=[0 1 0 0];
alpha=[0 0 1 0];
omega=[0 0 0 1];


% the filtered input and its derivatives
ufA=red_fil.C*[x1;x2];
ufB=red_fil.D *alpha_des;
ufdotA=red_fil.C*red_fil.A*[x1;x2];
ufdotB=red_fil.C*red_fil.B*alpha_des;
ufddotA=red_fil.C*red_fil.A*red_fil.A*[x1;x2];
ufddotB=red_fil.C*red_fil.A*red_fil.B*alpha_des; 


% First, define the sliding surface
surfA=lambda*(alpha-ufA)+(omega-ufdotA);
surfB=-lambda*ufB-ufdotB;

