function [initial_conditions,locations_updated] = find_initial_conditions(X0,locations_list)

%This function finds the list of continuous set, the discrete set, the initial cells
% and the initial location for the initial conditions set X0.
% INPUT
% X0 : a Linearcon object with the state-space region defined as the initial condition
% locations_list : set of locations. We will assume that the default initial location is one (01)
% scsbList : List of SCSB with parameters. For reset purposes.
%
% OUTPUT
% initial_conditions: Cell array with the following fields:
%
%   .continuousSet    = linearcon object with the region for the initial region
%   .initialCells          = cell where the initial conditon is located
%   .discreteCells      = configuration of the SFM when in this element (value of vector q)
%   .initialLocation    = Location where the initial condition is located
%
% locations: list of locations updated for some guard;
% In the future, this routine will receive a structure containing the state (q) and X0.

global CELLS

ICL{1}.location = 01;
ICL{1}.X0        = X0;

for counter_list = 1:length(ICL)

    init_loc = ICL{counter_list}.location;
    X0       = ICL{counter_list}.X0;
    initial_invariant=locations_list{init_loc}.interior_cells;
    init_cond ={};

    for j=1:length(X0)

        for i=1:length(initial_invariant)

            [C,d] = cell_ineq(CELLS{initial_invariant(i)}.boundary,CELLS{initial_invariant(i)}.hpflags);
    	    INV = linearcon([],[],C,d);

            if isfeasible(X0{j},INV)

                init_counter = length(init_cond);
                init_cond{init_counter+1}.continuousSet      = and(X0{j},INV);
                init_cond{init_counter+1}.initialCells            = initial_invariant(i);
                init_cond{init_counter+1}.discreteSet           = locations_list{01}.q;
                init_cond{init_counter+1}.initialLocation      = 01;

           end%if

       end%if

    end%if

    %Test to see if any of the initial continuous set either a.) satifies a guard or b.) is outside of the
    %analysis region.
    disc_state = locations_list{init_loc}.q;
    transitions=locations_list{init_loc}.transitions;

    for i=1:length(transitions)

        guards=transitions{i}.guard;

        for j=1:length(guards)
    	    [C,d] = cell_ineq(CELLS{guards(j)}.boundary,CELLS{guards(j)}.hpflags);
    	    GUARD = linearcon([],[],C,d);

            for m=1:length(X0)

                if isfeasible(X0{m},GUARD)

                    if isempty(transitions{i}.clock)

                        error('CheckMate:PIHA', ...
                        ['Some section of the initial continuous set satisfies the guard of the initial location.'                       	'  This section will be neglected.']);
% moved

                    else

                        init_counter = length(init_cond);
                        init_cond{init_counter+1}.continuousSet      = and(X0{m},GUARD);
                        init_cond{init_counter+1}.initialCells            = guards(j);
                        init_cond{init_counter+1}.discreteSet           = disc_state;
                        init_cond{init_counter+1}.initialLocation       = 01;
                        [dum1,dum2,cell_idx]=intersect(guards(j),locations_list{init_loc}.interior_cells);
                        if isempty(cell_idx)
                            locations_list{init_loc}.interior_cells(length(locations_list{init_loc}.interior_cells)+1)= guards(j);

                        end%if

                    end %if

                end %if

            end %for

        end%for

    end%for

end%for

initial_conditions      = init_cond;
locations_updated    = locations_list;

return

% -----------------------------------------------------------------------------
