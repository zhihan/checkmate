function [Xdot,type] = slidingmode(X,q,p)

% Switched continuous dynamics function for the 5D ETC model
%
% Syntax:
%   "[sys,type] = updownnonlinear(x,u)"
%
% Description:
%   "updown_nonlinear(x,q,p)" returns the state derivatives, and the type of system
%   dynamics as a function of "x", the current continuous state vector,
%   and "q", the discrete input vector to the switched continuous
%   system, and a parameter "p".  In this demonstration, the system type is "'nonlinear'", 
%   and thestate derivatives are returned as a constant vector of rates.
%
% See Also:
%   verify

    type = 'nonlinear';

      
% load etc definition
    etc_def
% just to avoid that the function alpha gets called
    alpha=[0 0 1 0];
 

% computing the filter output
Xdot1= red_fil.A(1,:)*[x1;x2]*X+ red_fil.B(1)*alpha_des;
Xdot2= red_fil.A(2,:)*[x1;x2]*X+ red_fil.B(2)*alpha_des;




% behavior of plant and controller
Xdot3=omega*X;


% Now the difficult part. The dynamics for the angular speed
% First, define the sign for the silding mode contoller (using input from fsm mode)

signsurf=([-1 0 1]*([2 1 3]==q(1))');

% Second, we derive the sign of omega from the output of fsm coulomb
signomega=([-1 0 1]*([2 1 3]==q(2))');

% Then, depending on the sliding mode determine the input

switch signsurf
case 0,
    iA=1/Kt*(Ks*alpha + Kd*omega + J*ufddotA-lambda*J*(omega-ufdotA))-(n/layereps)*surfA;
    iB=1/Kt*(-Ks*alpha_eq +J*ufddotB + Kf *signomega +lambda*J*ufdotB)-(n/layereps)*surfB; 
otherwise,
    iA=1/Kt*(Ks*alpha + Kd*omega + J*ufddotA-lambda*J*(omega-ufdotA));
    iB=1/Kt*(-Ks*alpha_eq + J*ufddotB + Kf *signomega+lambda*J*ufdotB)- n* signsurf; 
end;

   
% Next, determine wheter the acuator saturates. Choose the fsm depending on the sliding mode.

if iA*X+iB<0
      iA=[0 0 0 0];
      iB=0;
elseif iA*X+iB>maxmotoramps
      iA=[0 0 0 0];
      iB=5.4545;
end;

        
%calculate the behavior for omega
Xdot4=1/J*(-Kd*omega - Ks*p(1)*alpha + Kt*iA)*X+...
      1/J*(-Kf*signomega + Ks*p(1)*p(2)*alpha_eq + Kt*iB);


% build the system
if  q(1)==0
    Xdot=zeros(4,1);
else
    Xdot=[Xdot1;Xdot2;Xdot3;Xdot4];
end;

%YEAH!
return