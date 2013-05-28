function [Pf, Siminf] = simulate_points(X0,sys_eq,ode_param,tf,Pcon)
X0=vertices(X0);
Siminf= repmat(struct('X0',[],'P0',[],'T',[],'X',[]), length(X0), 1);

%The following 3 lines and the above 'if' statement was changed to accomodate
%the case when the constraint set is empty.  Ansgar Fehnker 3/2002.

[CPE,dPE,CPI,dPI] = linearcon_data(Pcon);
Pcon=linearcon(CPE,dPE,[CPE;-CPE;CPI],[dPE;-dPE;dPI]);
Param=vertices(Pcon);
Vf = [];
if isempty(Param) 
    for k = 1:length(X0)
        [T,X] = ode45(sys_eq,[0 tf],X0(k),[],ode_param);
        Vf = [Vf X(end,:)'];
         Siminf(k)= struct('X0',X0(k),'P0',[],'T',T,'X',X);
    end
else
    for i=1:length(Param)
        for k = 1:length(X0)
            [T,X] = ode45(sys_eq,[0 tf],X0(k),[],ode_param,Param(i));
            Vf = [Vf X(end,:)'];
            Siminf(k)= struct('X0',X0(k),'P0',Param(i),'T',T,'X',X);
        end
    end
end
Pf = vertices(Vf);
return




