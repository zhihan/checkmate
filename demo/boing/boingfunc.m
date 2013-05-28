function [sys,type,reset]=boingfunc(x,u)

type='linear';

switch u
case 1
    sys.A=[0 0 0;0 0 1;0 0 0];
    sys.b=[1 0 -1]';
    reset.A=[1 0 0;0 1 0;0 0  -0.9];
    reset.B=[0;0;0];
otherwise
    sys.A=zeros(3,3);
    sys.b= zeros(3,1);
    reset.A=[1 0 0;0 1 0;0 0 1];
    reset.B=[0;0;0];
end
return    