function [xdot,type]=testclock(x,q);

type='clock';

if  q==2
    xdot=1;
else
    xdot=0;
end;
reset=0;