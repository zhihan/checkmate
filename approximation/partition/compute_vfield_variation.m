
function [fmin,fmax] = compute_vfield_variation(patch,A)

global GLOBAL_OPTIM_PAR

[CE,dE,CI,dI] = linearcon_data(patch);
xmin = linprog(CE*A,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
%xmin = lp(CE*A,[CE; CI],[dE; dI],[],[],[],length(dE));
fmin = CE*A*xmin;
xmax = linprog(-CE*A,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
%xmax = lp(-CE*A,[CE; CI],[dE; dI],[],[],[],length(dE));
fmax = CE*A*xmax;
return
