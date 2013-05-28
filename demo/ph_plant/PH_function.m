function [sys,type] = PH_function(x,u)

% Switched continuous dynamics function for the Ph Plant system
%
% Syntax:
%   "[sys,type] = PH_function(x,u)"
%
% Description:
%   "ph_function(x,u)" returns the state derivatives, and the type of system
%   dynamics as a function of "x", the current continuous state vector,
%   and "u", the discrete input vector to the switched continuous
%   system.  In this demonstration, the system type is "'clock'", and the
%   state derivatives are returned as a constant vector of rates.
%
% See Also:
%   verify
ph=0.1;
pH_corr=0.8;
prod =0.1;
corr = prod*0.2;
type = 'clock';

   
switch u,
      
   case 1,
   	sys = [prod ph]';
      
   case 2,
   	sys = [prod+corr -pH_corr+ph]';
      
   case 3,
   	sys = [prod+corr  pH_corr+ph]';
      
   otherwise,
   	sys = [0 0]';
      
   end
   










