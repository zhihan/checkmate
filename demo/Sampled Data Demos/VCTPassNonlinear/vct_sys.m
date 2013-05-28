function [sys,type] = vct_sys(x,u)

% Switched continuous dynamics and specification of
% difference equations the plant and controller respectively for the VCT (nonlinear version) demonstration
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
%     x = [ x ; z ; up]    
%     
% where x is the continuous state-vector (the plant state),
% z is the discrete-time state vector (the controller state), and up is the controller output vector.
% 
% The output vector, sys, is assumed to have the following form:
% 
%     sys = [ dx/dt ; z(n+1) ; up(n)].
% 
% The continuous time derivates of z are assumed to be zero.  So the continuous variables evolve
% during a sample period.  Then the z variables are updated at the next sample instant.
%     
% See Also:
%   verify


                

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
A  = 0;
b  = 1169.003676;
r  = -584.5018752;
C  = 1;
Ap = [ .3 0 ; 0 1 ];
bp = [ -1 ; -T ];
rp = [ ref ; T*ref ];


%Type specifies the kind of continuous dynamics in the plant.
type = 'nonlinear';
%The only thing that switches with the mode in this system is the output
%equation for the controller.
switch u
case 3,
   %PID control, non-saturated 
   Cp = [ -.49*Kd Ki ];
   Dp = -( Kp + .7*Kd );
   rpp = .5 + ref*( Kp + .7*Kd );

   
case 4, 
   %Proportional controller, non-saturated 
   Cp = [ 0 0 ];
   Dp = -10;
   rpp= 10*ref;
 

case 1,
   %Controller output saturated high
   Cp = [ 0 0 ];
   Dp = 0;
   rpp= 1;
   
   
case 2,
   %Controller output saturated low
   Cp = [ 0 0 ];
   Dp = 0;
   rpp= 0;
  
   
otherwise, 
   A  = 0;
   b  = 0;
   r  = 0;
   C  = 0;
   Ap = [ 0 0 ; 0 0 ];
   bp = [ 0 ; 0 ];
   rp = [ 0 ; 0 ]; 
   Cp = [0 0]; 
   Dp = 0;
   rpp = 0;

    
end

sys(1,1) = A*x(1)+b*x(4) + r;
sys(2:3,1) = Ap*x(2:3,1) + bp*C*x(1) + rp;
sys(4,1) = Cp*x(2:3,1) + Dp*C*x(1) + rpp;

return




