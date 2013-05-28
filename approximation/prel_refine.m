function prel_refine(reachable)

global GLOBAL_AUTOMATON;
global GLOBAL_PIHA;

fprintf(1,'\n Starting preliminary refinement.\n');
len_reachable = length(reachable);

%Loop through the reachable set
for m = 2:length(reachable)
    rlocation = reachable(m).location;
    [dum1,dum2,int_reg] = intersect(reachable(m).cell,GLOBAL_PIHA.Locations{rlocation}.interior_cells);
    polytope = reachable(m).polytope;

    %Get current states for this face
    state = GLOBAL_AUTOMATON{rlocation}.interior_region{int_reg}.state;
    refinement = {};

    %Loop through current states and break apart based on reachable
    %set mapping.
    for n = 1:length(state)
        temp = state{n};
        overlap = polytope & state{n}.polytope;
        if ~isempty(overlap)
            [CE,dE,CI,dI]=linearcon_data(overlap);
            box = grow_polytope_for_iautopart(CE,dE,CI,dI,state{n}.polytope);
            temp.polytope = (box&return_invariant(reachable(m).cell));
            temp.mapping  = reachable(m).mapping;
            temp.non_reachable = 0;
            % >>>>>>>>>>>> Recording Reachability Results (Intermedia States) -- DJ -- 06/30/03 <<<<<<<<<<<<
            % Recording reachability results for intermedia results.
            % Added by Dong Jia to record all information from reachability
            % analysis.
            temp.destination=reachable(m).destination;
            temp.null_event=reachable(m).null_event;
            temp.time_limit=reachable(m).time_limit;
            temp.out_of_bound=reachable(m).out_of_bound;
            temp.terminal=reachable(m).terminal;
            % >>>>>>>>>>>> -------------- end (Recording Reachability Results (Intermedia States)) --------------- <<<<<<<<<<<<
            % >>>>>>>>>>>> Split Flag -- DJ -- 06/30/03 <<<<<<<<<<<<
            % Add a flag split to indicate whether a state is created by splitting a
            % previous state. Added by Dong Jia
            temp.split = 0;
            % >>>>>>>>>>>> -------------- end (Split Flag) --------------- <<<<<<<<<<<<
            refinement{end+1} = temp;
            fprintf(1,'\n  state %d/%d created.\n',m,len_reachable);
        end
    end

    if ~isempty(refinement)
        for n=1:length(refinement)
            refinement{n}.split=1;
        end
    end

    % This part find new reachable regions and add them to the structure called 'refinement'.
    % At the end, the structure 'refinement' is copied to
    % GLOBAL_AUTOMATON{LOCATION}.interior_Region{REGION}.state
    % The cycle then repeats itself for length of structure 'reachable'.
    % >>>>>>>>>>>> Getting States for Current Cell -- DJ -- 06/30/03 <<<<<<<<<<<<
    % Get the state list for current cell to refine.
    % Added by Dong Jia
    curr_states = GLOBAL_AUTOMATON{rlocation}.interior_region{int_reg}.state;
    % >>>>>>>>>>>> -------------- end (Getting States for Current Cell) --------------- <<<<<<<<<<<<
    % >>>>>>>>>>>> State Refinement (while part)-- DJ -- 06/30/03 <<<<<<<<<<<<
    % In the while loop, all states will be checked to see if they intersect
    % with each other. If so, the two intersected states will be partitioned.
    % The following while-end loop is added by Dong Jia
    k=0;
    while 1
        k=k+1;
        if k>length(refinement)
            break;
        end
        % >>>>>>>>>>>> -------------- end (State Refinement (while part)) --------------- <<<<<<<<<<<<
        % >>>>>>>>>>>> Eliminating non_reachable-- DJ -- 06/30/03 <<<<<<<<<<<<
        % The field non_reachable is not used to judge whether one state might need to be
        % refined. The if-end is commented by Dong Jia
        %       if ~(GLOBAL_AUTOMATON{rlocation}.interior_region{int_reg}.state{j}.non_reachable)
        % >>>>>>>>>>>> -------------- end (Eliminating non_reachable) --------------- <<<<<<<<<<<<
        intersect_flag=1;
        for j=1:length(curr_states)
            poly=curr_states{j}.polytope;
            if isfeasible(poly,refinement{k}.polytope)
                inter=refinement{k}.polytope&poly;
                intersect_flag=0;
                % The if-elseif-else-end block
                % is to consider special cases when one set is a subset of the other one.
                if issubset(refinement{k}.polytope,poly)
                    %   poly contain a state in the refinement list. in
                    %   this case poly will be partitioned. All states
                    %   generated from poly-inter are appended to the
                    %   curr_states list and curr_state{j} is updated by
                    %   inter.
                    GA_not=poly-inter;
                    for i=1:length(GA_not)
                        curr_states{length(curr_states)+1}=curr_states{j};
                        curr_states{length(curr_states)}.polytope=GA_not{i};
                        % >>>>>>>>>>>> Updating split (Case 1) -- DJ -- 06/30/03 <<<<<<<<<<<<
                        % Updating the field split for newly created states
                        % Added by Dong Jia
                        if ~curr_states{j}.non_reachable
                            curr_states{length(curr_states)}.split=1;
                        end
                        % >>>>>>>>>>>> -------------- end (Updating split (Case 1)) --------------- <<<<<<<<<<<<
                    end
                    % >>>>>>>>>>>> Update Information for inter (case 1)-- DJ -- 06/30/03 <<<<<<<<<<<<
                    % Updating reachability information for inter. If curr_state{j} is not a
                    % reachable set computed from  a initial set, update the reachability
                    % infor from refinement{k}. Otherwise, update the reachability infor by the
                    % intersection of the corresponding fields in curr_state{j} and
                    % refinement{k}.
                    % Added by Dong Jia
                    if curr_states{j}.non_reachable
                        curr_states{j}=refinement{k};
                        curr_states{j}.polytope=inter;
                    else
                        curr_states = refine_dead_code(inter, refinement, curr_states);
                    end
                    % >>>>>>>>>>>> -------------- end (Update Information for inter (case 1)) --------------- <<<<<<<<<<<<
                    break;
                end
            end %if isfeasible...

        end %for j=1....
        if intersect_flag
            curr_states{length(curr_states)+1} = refinement{k};
        end
        %       end %if ~(GLO...
        % >>>>>>>>>>>> -------------- end (State Partition) --------------- <<<<<<<<<<<<
    end %while 1
    GLOBAL_AUTOMATON{rlocation}.interior_region{int_reg}.state = curr_states;
end
return