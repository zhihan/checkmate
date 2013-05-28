function assign_children(X0,state_num,location_number,cell)

global GLOBAL_PIHA
global GLOBAL_AUTOMATON

% initialize the initial state and put it into the queue
init = [];
init.polytope = X0;
init.location = location_number;
init.cell=cell;
init.state=state_num;
queue = insert_queue([],init);

first = true;
while ~isempty(queue)
    % remove a state from the head of the queue and compute the mapping for it
    [queue,state] = remove_queue(queue);
    X0 = state.polytope;
    loc = state.location;
    cell=state.cell;
    state_idx=state.state;
    % Perform further reachability analysis if the maximum path depth is
    % not exceeded.
    % if entering this loop for the first time, set the state type to
    % 'init'

    [mapping_region, destination] = find_children(loc, state_idx, cell, first);

    %Identify which loc-cell-state the destination mappings landed in:
    %------------------------------------------------------------------------------
    destination_states=[];
    for i=1:length(destination)
        dst_loc      =   destination{i}.location;
        dst_cell     =   destination{i}.cell;
        dst_mapping  =   destination{i}.mapping;
        dst_theta    =   destination{i}.transition_theta;

        [dum1,dum2,cell_indx]=intersect(dst_cell,GLOBAL_PIHA.Locations{dst_loc}.interior_cells);
        %*************************************************************************************************
        %This section adds a new region to the PIHA because a guard region was entered and the transition was
        %not taken.
        if dst_loc==loc && isempty(cell_indx)
            add_region(loc,dst_cell);
            [dum1,dum2,cell_indx]=intersect(dst_cell,GLOBAL_PIHA.Locations{dst_loc}.interior_cells);
        end
        %**************************************************************************************************

        % save debug_test dst_loc cell_indx
        for j=1:length(GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state)
            inters=dst_mapping & GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state{j}.polytope;

            if ~isempty(inters)  % code to be changed by Izaias Silva%
                %Assign this state which the mapping 'hits' to the appropriate children field in
                %GLOBAL_AUTOMATON
                if ~first
                    [dum1,dum2,old_cell]=intersect(cell,GLOBAL_PIHA.Locations{loc}.interior_cells);

                    if isempty(GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.children) || ...
                        isempty(intersect(GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}...
                            .children,[dst_loc cell_indx j],'rows'))
                        GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.children=[...
                            GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.children ; dst_loc cell_indx j];
                        already_exist =0;

                        for n=1:length(GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.mapping)
                            inter1=and(inters,GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.mapping{n});

                            if ~isempty(inter1)

                                if isempty(minus(inters,inter1))
                                    already_exist = 1;
                                end
                            end %if%
                        end %for%

                        if ~already_exist
                            GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.mapping...
                                {length(GLOBAL_AUTOMATON{loc}.interior_region{old_cell}.state{state_idx}.mapping)+1}=inters;
                        end %if%

                        GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state{j}.non_reachable=0;
                    end
                else

                    if isempty(GLOBAL_AUTOMATON{loc}.initstate{state_num}.children) || ...
                            isempty(intersect(GLOBAL_AUTOMATON{loc}.initstate{state_num}.children,[dst_loc cell_indx j],'rows'))
                        GLOBAL_AUTOMATON{loc}.initstate{state_num}.children=[...
                            GLOBAL_AUTOMATON{loc}.initstate{state_num}.children ; dst_loc cell_indx j];
                        already_exist = 0;

                        for n=1:length(GLOBAL_AUTOMATON{loc}.initstate{state_num}.mapping)
                            inter1=and(inters,GLOBAL_AUTOMATON{loc}.initstate{state_num}.mapping{n});

                            if ~isempty(inter1)

                                if isempty(minus(inters,inter1))
                                    already_exist = 1;
                                end
                            end
                        end
                        if ~already_exist
                            GLOBAL_AUTOMATON{loc}.initstate{state_num}.mapping...
                                {length(GLOBAL_AUTOMATON{loc}.initstate{state_num}.mapping)+1}=inters;
                        end
                        GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state{j}.non_reachable=0;
                    end
                end
                %Also provide information to add this state to the queue
                next=length(destination_states)+1;
                destination_states{next}.polytope=...
                    GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state{j}.polytope;
                destination_states{next}.location=dst_loc;
                destination_states{next}.cell=dst_cell;
                destination_states{next}.state=j;
                destination_states{next}.transition_theta = dst_theta;
            end  %if ~isempty(inters)%
        end %for j=1:length(GLOBAL_AUTOMATON{dst_loc}.interior_region{cell_indx}.state)%
    end %i=1:length(destination)%
    %------------------------------------------------------------------------------

    %Add the states found above to the queue
    for k = 1:length(destination_states)

        newstate = {};
        newstate.polytope = destination_states{k}.polytope;
        newstate.location = destination_states{k}.location;
        newstate.cell = destination_states{k}.cell;
        newstate.state = destination_states{k}.state;
        if ~GLOBAL_AUTOMATON{newstate.location}.interior_region{cell_indx}.state{newstate.state}.visited
            queue = insert_queue(queue,newstate);
        end
        GLOBAL_AUTOMATON{newstate.location}.interior_region{cell_indx}.state{newstate.state}.visited=1;
    end

    first = 0;

end

return

