function d = optimize_facets(sys_eq, ode_param, ...
        X0, t0, tf, Pcon, Siminf, C)

[CE,dE,CI,dI] = linearcon_data(X0);
[CPE,dPE,CPI,dPI] = linearcon_data(Pcon);

global GLOBAL_APPROX_PARAM

CIn=size(CI,1);
CPIn=size(CPI,1);
xdim=dim(X0);
pdim=dim(Pcon);

% Remember the dimensions of the state space.
dimension=xdim;
fminCI=[zeros(1,xdim) 1 zeros(1,pdim); zeros(1,xdim) -1 zeros(1,pdim);];%CIm+1
fmindI=[tf;-t0];

if ~isempty(CI)
    fminCI=[fminCI;CI,zeros(CIn,pdim+1)];%CPIm+1
    fmindI=[fmindI;dI];
end;

if ~isempty(CPI)
    fminCI=[fminCI;zeros(CPIn,xdim+1),CPI];%CIm+1
    fmindI=[fmindI;dPI];
end;

% (2) equality constraints
CEn=size(CE);
CPEn=size(CPE);

fminCE=[];
fmindE=[];
if ~isempty(CE)
    fminCE=[CE,zeros(CEn,pdim+1)];%CPIm+1
    fmindE=dE;
end;
if ~isempty(CPE)
    if ~isempty(fminCE)
        fminCE=[fminCE;zeros(CPEn,xdim+1) CPE];%CIm+1
        fmindE=[fmindE;dPE];
    else
        fminCE=[zeros(CPEn,xdim+1) CPE];%CIm+1
        fmindE=dPE;
    end;
end;

tolerance = GLOBAL_APPROX_PARAM.func_tol;
maxiter = GLOBAL_APPROX_PARAM.max_iter;
if (tf-t0)>0
    actual_tolerance = (tf-t0)*tolerance;
else
    actual_tolerance = tolerance;
end


options = optimset;
options.TolFun =actual_tolerance;%f(3) of foptions
options.MaxIter = maxiter*size(C,2);%f(14) of foptions
options.Display='off';
options.Diagnostics='off';
options.LargeScale='off';
options.Algorithm = 'active-set';

% (4) Optimize for each direction

for l = 1:size(C,1)
    n_vector = C(l,:)';

    % compute the best initial state
    % Store in " tindex"  the index of the time elements of  the vector Siminf(1).T that are greater than t0
    %
    [ts,tindex]=setdiff(Siminf(1).T.*(Siminf(1).T>=t0),0);
    % Computer the max arg i C'x(i)
    [minnx,nx_index]=min(-n_vector'*Siminf(1).X(tindex,:)');
    Pinit=Siminf(1).P0;
    Xinit=Siminf(1).X0;
    Tinit=Siminf(1).T(tindex(nx_index));
    for k0=2:length(Siminf)
        [ts,tindex]=setdiff(Siminf(k0).T.*(Siminf(k0).T>=t0),0);
        [nx,nx_index]=min(-n_vector'*Siminf(k0).X(tindex,:)');
        if nx<minnx
            minnx=nx;
            Pinit=Siminf(k0).P0;
            Xinit=Siminf(k0).X0;
            Tinit=Siminf(k0).T(tindex(nx_index));
        end;
    end;

    [Xopt,dl] = fmincon('stretch_func_ode',[Xinit;Tinit;Pinit], fminCI,fmindI, fminCE,fmindE,[],[],[],options,...
        sys_eq,ode_param,n_vector,t0,tf,dimension);


    d(l,1)=-dl;
end