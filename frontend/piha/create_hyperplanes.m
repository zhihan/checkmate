function [pthb,NAR]=create_hyperplanes(NBDHP,AR,pthb)

global GLOBAL_PIHA
global GLOBAL_APPROX_PARAM

% This function creates the list of hyperplanes. It originally resided in the
% 'partition_ss' function, but it has become necessary to have the hp's before
% the state space is divided.

% Put hyperplanes constituting the boundary of AR at the beginning of the
% hyperplane list.

[CE,dE,CAR,dAR] = linearcon_data(AR);
hyperplanes = {};
for k = 1:length(dAR)
    hyperplanes{k}.pthb = -1;
    hyperplanes{k}.index = k;
    hyperplanes{k}.c = CAR(k,:);
    hyperplanes{k}.d = dAR(k);
end
NAR = length(hyperplanes);

hyperplane_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;
counter_hyperplanes = NAR;

for k = 1:length(NBDHP)
    dup=0;
    for j=1:counter_hyperplanes
        c1 = hyperplanes{j}.c;
        b1 = hyperplanes{j}.d;
        c = NBDHP{k}.c;
        b = NBDHP{k}.d;
        MATRIX = [c1 b1; c b];
        if rank(MATRIX,hyperplane_tol) < 2
            dup=1;
            i=NBDHP{k}.pthb;
            pthb{i}.hps=[pthb{i}.hps j];
            break;
        else
            dup=0;
        end
    end
    if dup==0
        counter_hyperplanes = counter_hyperplanes+1;
        hyperplanes{counter_hyperplanes}.pthb = NBDHP{k}.pthb;
        hyperplanes{counter_hyperplanes}.index = NBDHP{k}.index;
        hyperplanes{counter_hyperplanes}.c = NBDHP{k}.c;
        hyperplanes{counter_hyperplanes}.d = NBDHP{k}.d;
    end
end

%Sort out which HP's go with which pthb
for n=NAR+1:length(hyperplanes)
    j=hyperplanes{n}.pthb;
    if j~=-1
        pthb{j}.hps=[pthb{j}.hps n];
    end
end

GLOBAL_PIHA.Hyperplanes = hyperplanes;

return
