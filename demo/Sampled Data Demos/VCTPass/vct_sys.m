function [sys,type,reset] = vct_sys(x,u)

% Switched continuous dynamics and specification of
% difference equations the plant and controller respectively for the variable cam timing system 
% verification.
%
% Syntax:
%   "[sys,type] = vct_sys(x,u)"
%
% Description:
%
% "vct_sys(x,u)" returns the state derivatives, controller update equations, and the type of
% continuous system.  The function is given a controller/plant discrete state (an integer, u), and 
% it returns a vector representing the continuous-time state variable derivatives along with the
% discrete-time update equations for the controller states and outputs.  The vector x is assumed to
% have the form:
%     
%     x = [ x ; z ]    
%     
% where x is the continuous state-vector (the plant state),
% z is the discrete-time state vector (the controller state), and up is the controller output vector.
% 
% The output vector, sys, is assumed to have the following form:
% 
%     sys = [ dx/dt ; z(n+1) ].
% 
% The continuous time derivates of z are assumed to be zero.  So the continuous variables evolve
% during a sample period.  Then the z variables are updated at the next sample instant.
%
% For the linear case, reachability makes use of the A and b matrices for the plant and controller.
% In this case, sys should have the following structure:
% 
%     sys.A  = plant A matrix
%     sys.b  = plant b matrix
%     sys.r  = plant r vector
%     sys.C  = plant C matrix
%     sys.Ap = controller state A matrix
%     sys.bp = controller state b matrix
%     sys.rp = controller state r vector
%     sys.Cp = controller C matrix
%     sys.Dp = controller D matrix
%     sys.rpp= controller output r vector
% 
% where the system equations are assumed to be:
% 
%     dxp/dt = A*x+b*up+r
%     
%     y = C*x
%     
%     z(n+1) = Ap*z(n)+bp*y+rp
%     
%     up(n) = Cp*z(n)+Dp*y(n)+rpp
%     
%     
% See Also:
%   verify

% For this particular system, the state varaibles and plant and controller outputs are as follows:
% 
%     x1      =   plant state.  This is the position of the hybraulic actuator that is being controlled.
%     y       =   actuator position.  This is equal to the plant state.
%     z1      =   filter state.  A discrete-time filter is used by the controller.  The filter is used 
%                 as a band-limited differentiator.  Its output is used for both the derivative term of
%                 the PID controller and to make the controller mode-switch decision.
%     z2      =   integrator state.  This is the state of the integrator within the PID controller.
%     u       =   current output.  This is the amount of current used to actuate a solenoid for the 
%                 hydraulic actuator.
                

%Define constants:
%PID constants
Ki = .01;
Kd = .0004;
Kp = .025;
%Sample time
T = .008;
%Reference signal (actuator setpoint)
%Note:  changing params here means that they must be changed in the setup file as well.
ref = 18;

% The plant and the controller state behave the same way in every control mode (the controller state always
% behaves the same, just the output behaves differently).  So define those dynamics here.
sys.A  = 0;
sys.b  = 1169.003676;
sys.r  = -584.5018752;
sys.C  = 1;
sys.Ap = [ .3 0 ; 0 1 ];
sys.bp = [ -1 ; -T ];
sys.rp = [ ref ; T*ref ];


%Type specifies the kind of continuous dynamics in the plant.
type = 'linear';
%The only thing that switches with the mode in this system is the output
%equation for the controller.
switch u
case 3,
   %PID control, non-saturated 
   sys.Cp = [ -.49*Kd Ki ];
   sys.Dp = -( Kp + .7*Kd );
   sys.rpp = .5 + ref*( Kp + .7*Kd );
 
case 4,
   %PID control, non-saturated (in null region)
   sys.Cp = [ -.49*Kd Ki ];
   sys.Dp = -( Kp + .7*Kd );
   sys.rpp = .5 + ref*( Kp + .7*Kd );   

case 1,
   %Controller output saturated high
   sys.Cp = [ 0 0 ];
   sys.Dp = 0;
   sys.rpp= 1;
   
   
case 2,
   %Controller output saturated low
   sys.Cp = [ 0 0 ];
   sys.Dp = 0;
   sys.rpp= 0;
  
   
otherwise, 
   sys.A  = 0;
   sys.b  = 0;
   sys.r  = 0;
   sys.C  = 0;
   sys.Ap = [ 0 0 ; 0 0 ];
   sys.bp = [ 0 ; 0 ];
   sys.rp = [ 0 ; 0 ]; 
   sys.Cp = [0 0]; 
   sys.Dp = 0;
   sys.rpp = 0;

    
end
   reset = x;


return




