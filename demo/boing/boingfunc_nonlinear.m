function [sys,type,reset]=boingfunc_nonlinear(x,u)

type='nonlinear';

if nargin<3
    p=0.5;
end;
%v is the wind-friction term.
v=p;

switch u
case 1
    sys(1,1)=1;
    sys(2,1)=x(3);
    sys(3,1)=-v*(x(3)^2)*(sign(x(3)))-1;
    reset.A=[1 0 0;0 1 0;0 0  -0.9];
    reset.B=[0;0;0];
otherwise
    sys=[0;0;0];
    reset.A=[1 0 0;0 1 0;0 0 1];
    reset.B=[0;0;0];
end
return    