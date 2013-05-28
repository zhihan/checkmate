function [too_big,con1,con2] = split_if_too_big(patch,size_tol,W)

global GLOBAL_OPTIM_PAR

[CE,dE,CI,dI] = linearcon_data(patch);

Z = null(CE);
dmax = -Inf;
for k = 1:size(Z,2)
  nk = W*Z(:,k);
  xmin = linprog(nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  xmax = linprog(-nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  dk = nk'*(xmax-xmin);
  if (dk > dmax)
    dmax = dk;
    n = nk;
    b = nk'*(xmax+xmin)/2;
  end
end

if (dmax > size_tol)
  too_big = 1;
  con1 = patch & linearcon([],[],n',b);
  con2 = patch & linearcon([],[],-n',-b);
else
  too_big = 0;
  con1 = linearcon;
  con2 = linearcon;
end
return
