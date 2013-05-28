function [sys,type,reset]=acc_dyn(x,u)
type='nonlinear';
[sys,reset.A,reset.B]=acc_dynamics(x,u);

return
%-----------------------------------------------------------
function [xdot,A,r]=acc_dynamics(x,loc)

%  The hybrid dynamics of the car steering example.
%

A=[];
r=[];
% Parameters:
sigma=1.5;
lambda=0.8;
k2=0.5;
L=5;
hyst=1;
des_vel=30;
lead_vel=25;
lead_acc=0;

% Continuous variables
%
% dist_abs  absolute distance
% dist_vel  velocity distance
% act_vel   actual velocity following car
% act_acc   actual acceleration following car



dist_abs=x(1);
act_vel=x(2);
Pm = x(3);

% Auxilliary
% 
% des_acc  
% acc_par

% Location  gear    mode
%   1       1       cc
%   2       2       cc
%   3       3       cc
%   4       4       cc
%   5       1       acc
%   6       2       acc
%   7       3       acc
%   8       4       acc


switch loc
    case 1,     
       des_acc=0.9*(des_vel-act_vel);
       dist_vel=lead_vel-act_vel;
       Rtrans =.3423; %differs from gear to gear
   case 2,     
       des_acc=0.9*(des_vel-act_vel);
       dist_vel=lead_vel-act_vel;
       Rtrans =.6378; %differs from gear to gear
case 3,     
       des_acc=0.9*(des_vel-act_vel);
       dist_vel=lead_vel-act_vel;
      Rtrans =1.0; %differs from gear to gear
   case 4,     
       des_acc=0.9*(des_vel-act_vel);
       dist_vel=lead_vel-act_vel;
       Rtrans =1.4184; %differs from gear to gear
   case 5,   
       u=[lead_vel;dist_abs;lead_acc;act_vel;sigma;lambda;k2;L];
       des_acc=(-(u(6)+u(7)*(1+u(6)*u(5)))*u(4)+u(6)*u(7)*u(2)+(u(6)+u(7))*u(1)-u(6)*u(7)*u(8)+u(3))/(1+u(5)*u(6));
       dist_vel=lead_vel-act_vel;
       Rtrans =.3423; %differs from gear to gear
   case 6,   
       u=[lead_vel;dist_abs;lead_acc;act_vel;sigma;lambda;k2;L];
       des_acc=(-(u(6)+u(7)*(1+u(6)*u(5)))*u(4)+u(6)*u(7)*u(2)+(u(6)+u(7))*u(1)-u(6)*u(7)*u(8)+u(3))/(1+u(5)*u(6));
       dist_vel=lead_vel-act_vel;
       Rtrans =.6378; %differs from gear to gear
   case 7,   
       u=[lead_vel;dist_abs;lead_acc;act_vel;sigma;lambda;k2;L];
       des_acc=(-(u(6)+u(7)*(1+u(6)*u(5)))*u(4)+u(6)*u(7)*u(2)+(u(6)+u(7))*u(1)-u(6)*u(7)*u(8)+u(3))/(1+u(5)*u(6));
       dist_vel=lead_vel-act_vel;
       Rtrans =1; %differs from gear to gear
   case 8,   
       u=[lead_vel;dist_abs;lead_acc;act_vel;sigma;lambda;k2;L];
       des_acc=(-(u(6)+u(7)*(1+u(6)*u(5)))*u(4)+u(6)*u(7)*u(2)+(u(6)+u(7))*u(1)-u(6)*u(7)*u(8)+u(3))/(1+u(5)*u(6));
       dist_vel=lead_vel-act_vel;
       Rtrans =1.4184; %differs from gear to gear
   otherwise,  
      dist_vel=0;
      act_acc=0;
      Rtrans = 1;
      des_acc = 1;
end
%**************************************************************************
% A New variable Pm ( pressure of air in the manifold) is added to the model
%   The model has been augmented to
%         dist_vel' = lead_vel - acc_vel
%         acc_vel' =(a* Pm + b) / beta 
%         Pm' = w_e (eta * (beta * a_des - b)/a - eta * Pm)  (Unit N/m^2)
%           
% Note: The initial value of Pm is NOT zero! Pm is scaled by 1000;
%  Constants used:
         a = 2.18;
         b = -0.04;
         eta = 0.036;
               Je = .169; %kg/m^2
               Rfd = 0.3267;
               Rg = Rtrans* Rfd;
               r = .323; %m
               Jwheels = 2.603; %kg*m^2
               M = 1701; %kg
         beta = (Je+Rg^2*(Jwheels + r^2*M))/(Rg*r); %kg*m
         %  added a constant load for 
         L = 100;
% ************************************************************************

%********************************************************
%  Implementation of the additional variable Pm
% *******************************************************
scale = 1000;
act_acc =(a* Pm * scale + b -L ) / beta;
Pm_dot = act_vel * (eta * (beta * des_acc - b)/a - eta * Pm*scale) / (r * Rg);
Pm_dot = Pm_dot/scale;
%*********************************************************
%  End of crack
%*********************************************************
xdot=[dist_vel;act_acc;Pm_dot];

return
