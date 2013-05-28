function SEG= wrap_segment(sys_eq,ode_param,X0,t0,tf,Pcon,Siminf,SP0,SPf)

global GLOBAL_APPROX_PARAM;

% Compute convex hull from these extreme points
V = [SP0.list, SPf.list];
[CE,dE,C,d] = linearcon_data(linearcon(polyhedron(V)));

if ~GLOBAL_APPROX_PARAM.optimize_facet
    SEG=linearcon([],[],C,d);
else
    d_optim = optimize_facets(sys_eq, ode_param, ...
        X0, t0, tf, Pcon, Siminf, C);
    SEG=linearcon([],[],C,d_optim);
end
    
