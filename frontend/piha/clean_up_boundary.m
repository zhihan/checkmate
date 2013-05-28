function [boundary_new,hpflags_new] = clean_up_boundary(first_boundary, ...
    second_boundary,first_hpflags,second_hpflags)

global GLOBAL_PIHA
global GLOBAL_APPROX_PARAM

hyperplanes = GLOBAL_PIHA.Hyperplanes;

[c1,d1]=cell_ineq(first_boundary,first_hpflags);
[c2,d2]=cell_ineq(second_boundary,second_hpflags);

a=linearcon([],[],c1,d1);
b=linearcon([],[],c2,d2);

if ~isfeasible(a, b)
    boundary_new=[];
    hpflags_new=[];
else
    boundary=[first_boundary second_boundary];
    hpflags=[first_hpflags second_hpflags];

    [CBND,dBND] = cell_ineq(boundary,hpflags);
    [CE,dE,CI,dI] = linearcon_data(clean_up(linearcon([],[],CBND,dBND)));

    %Use the following to indicate which hpflags elements will still be valid
    hp_flag_index=[];

    if (length(dI) == length(dBND))
        boundary_new = boundary;
    else
        hyperplane_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;
        boundary_new = [];
        for k = 1:length(boundary)
            ck = hyperplanes{boundary(k)}.c;
            dk = hyperplanes{boundary(k)}.d;
            found = 0;
            for l = 1:length(dI)
                if rank([CI(l,:) dI(l); ck dk],hyperplane_tol) == 1
                    found = 1;
                    break;
                end
            end
            if found && ~ismember(boundary(k),boundary_new)
                boundary_new = [boundary_new boundary(k)];
                hp_flag_index=[hp_flag_index k];
            end
        end

        %Create new hpflags vector
        for j=1:length(hp_flag_index)
            hpflags_new(j)=hpflags(hp_flag_index(j));
        end
    end
end
