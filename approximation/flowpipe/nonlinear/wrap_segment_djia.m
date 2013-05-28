function SEG = wrap_segment_djia(sys_eq,ode_param,X0,t0,tf,Pcon,Siminf,SEG, INV)
global GLOBAL_APPROX_PARAM;
[CE,dE,C,d] = linearcon_data(SEG);
[CE,dE,CI,dI] = linearcon_data(X0);
[CPE,dPE,CPI,dPI] = linearcon_data(Pcon);

%This section has been altered (3/2002) to accomodate lower dimensional linearcon
%objects.  This was introduced specifically for parametric analysis.
% (1) inequality constraints

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
CEn=size(CE,1);
CPEn=size(CPE,1);

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

% (3) Set the optimization parameters

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

% Finding Intersection -- DJ -- 06/30/03
[CE_INV,dE_INV,CI_INV,dI_INV]=linearcon_data(INV);
[CE_INTER,dE_INTER,CI_INTER]=linearcon_data(SEG&INV);
[CI_t,CI_idx]=intersect(CI_INV,CI_INTER,'rows');
% >>>>>>>>>>>> -------------- end (Finding Intersection) --------------- <<<<<<<<<<<<

% Bound the approximation be each face of the invariant that intersects
% with the hyperrectangle hull. The compuation is performed in both
% position and negative direction of the norm of each face. In the
% following codes, the variables end with 1 are for the positive direction
% computation and those end with with 2 are for the negative direction
% computaiton.
for l = 1:length(CI_idx)
    n_vector = CI_INV(CI_idx(l),:)';

    % compute the best initial state
    % Store in " tindex"  the index of the time elements of  the vector Siminf(1).T that are greater than t0
    %
    [ts,tindex]=setdiff(Siminf(1).T.*(Siminf(1).T>=t0),0);
    % Computer the max arg i C'x(i)
    [minnx1,nx_index1]=min(-n_vector'*Siminf(1).X(tindex,:)');
    minnx2=min(n_vector'*Siminf(1).X(tindex,:)');
    Pinit1=Siminf(1).P0;
    Xinit1=Siminf(1).X0;
    Tinit1=Siminf(1).T(tindex(nx_index1));
    Pinit2=Siminf(1).P0;
    Xinit2=Siminf(1).X0;
    Tinit2=Siminf(1).T(tindex(nx_index1));
    for k0=2:length(Siminf)
        [ts,tindex]=setdiff(Siminf(k0).T.*(Siminf(k0).T>=t0),0);
        [nx1,nx_index1]=min(-n_vector'*Siminf(k0).X(tindex,:)');
        [nx2,nx_index2]=min(n_vector'*Siminf(k0).X(tindex,:)');
        if nx1<minnx1
            minnx1=nx1;
            Pinit1=Siminf(k0).P0;
            Xinit1=Siminf(k0).X0;
            Tinit1=Siminf(k0).T(tindex(nx_index1));
        end;
        if nx2<minnx2
            minnx2=nx2;
            Pinit2=Siminf(k0).P0;
            Xinit2=Siminf(k0).X0;
            Tinit2=Siminf(k0).T(tindex(nx_index2));
        end;
    end;

    dl1=-minnx1;
    if dl1<=dI_INV(CI_idx(l))
        [Xopt,dl1] = fmincon('stretch_func_ode',[Xinit1;Tinit1;Pinit1], fminCI,fmindI, fminCE,fmindE,[],[],[],options,...
            sys_eq,ode_param,n_vector,t0,tf,dimension);
        dl1=-dl1;
    end


    dl2=-minnx2;
    if dl2<=-dI_INV(CI_idx(l))
        [Xopt,dl2] = fmincon('stretch_func_ode',[Xinit2;Tinit2;Pinit2], fminCI,fmindI, fminCE,fmindE,[],[],[],options,...
            sys_eq,ode_param,-n_vector,t0,tf,dimension);
        dl2=-dl2;
    end

    if dl1<=dI_INV(CI_idx(l))
        C=[C;n_vector'];
        d=[d;dl1];
    end
    if dl2<=-dI_INV(CI_idx(l))
        C=[C;-n_vector'];
        d=[d;dl2];
    end
end
%  end (Bounding Approximation by Faces)
SEG = linearcon([],[],C,d);