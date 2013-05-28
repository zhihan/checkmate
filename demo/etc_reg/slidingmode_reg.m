function [sys,type] = slidingmode_reg(X,q,p)

% Switched continuous dynamics function for the bounce demonstration
%
% Syntax:
%   "[sys,type] = updownnonlinear(x,u)"
%
% Description:
%   "updown(x,u)" returns the state derivatives, and the type of system
%   dynamics as a function of "x", the current continuous state vector,
%   and "u", the discrete input vector to the switched continuous
%   system.  In this demonstration, the system type is "'clock'", and the
%   state derivatives are returned as a constant vector of rates.
%
% See Also:
%   verify
    type = 'nonlinear';

      
% x1 first state variable of filter
% x2 2nd state variable of filter
% x3 alpha
% x4 omega
% x5 constant modelling the mode


etc_reg_def;

% behavior of plant and controller
a3=x4;
b3=0;

if q==4
    signsurf=0;
else
    signsurf=1;
end


  

% Second, we derive the sign of omega from the output of fsm coulomb

switch q
    case 1    
    signomega= -1;
    
    case 2
    signomega= 0;
    
    case 3
    signomega= 1;
    
    otherwise
    signomega=0;
end    




% Then, depending on the sliding mode determine the input

switch signsurf
case 0,
    iA=1/Kt*(Ks*x3 + Kd*x4 -lambda*J*(x4))-(n/layereps)*surfA;
    iB=1/Kt*(-Ks*theta_eq  + Kf *signomega )-(n/layereps)*surfB; 
otherwise,
    iA=1/Kt*(Ks*x3 + Kd*x4 -lambda*J*(x4));
    iB=1/Kt*(-Ks*theta_eq  + Kf *signomega)- n* signsurf; 
end;

if (iA*X+iB)>maxmotoramps 
    %fprintf('plant input %3.3f saturates\n',iA*X+iB)
    iA=[0 0];
    iB=maxmotoramps;
elseif  (iA*X+iB)<0
    %fprintf('plant input %3.3f saturates\n',iA*X+iB)
    iA=[0 0];
    iB=0;
end;

%calculate the behavior for omega
a4=1/J*(-Kd*x4 - Ks*p(1)*x3 + Kt*iA);
b4=1/J*(-Kf*signomega + Ks*p(1)*p(2)*theta_eq + Kt*iB);



% build the system
if  q==4 || q==0
    sys=zeros(2,1);
%    sys.b=zeros(2,1);
else
    sys=[a3;a4]*X+[b3;b4];
end;

%YEAH!
return