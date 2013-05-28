function rauto_mapping(continu)

% Compute the mapping for the states in the new `approximating automaton`
% (the automaton obtained after the refinement). Progress is saved in a
% global variable so that the verification may be stopped and continud
% at a later time.
%
% Syntax:
%   "rauto_mapping(continu)"
%
% Description:
%   The inputs to this function are
%
%   * "continu": a flag indicating whether the CheckMate verification
%     step implemented in this function should be started from scratch or
%     continud from the last break point.
%
% Implementation:
%   The list of states in "GLOBAL_NEW_AUTOMATON" for which the `mapping set`
%   should be computed is given in the global variable
%   "GLOBAL_RAUTO_REMAP_LIST", which is a cell array containing state
%   indices. A state index is of length 2 for an `initial` state and of
%   length 3 for a `face` state. Call the function "compute_mapping" to
%   compute the mapping set for each of these states.
%
%   The progress of this function is saved in the global variable
%   "GLOBAL_PROGRESS". For this function, "GLOBAL_PROGRESS" has the
%   following fields.
%
%   * ".step". This field is always set to "'rauto_mapping'" for the
%     CheckMate verification step implemented in this function.
%
%   * ".idx". Index of the current state in "GLOBAL_RAUTO_REMAP_LIST" for
%   which the mapping is being computed. Note that ".idx" is the index to an
%   element in "GLOBAL_RAUTO_REMAP_LIST", not the index to a state in
%   "GLOBAL_NEW_AUTOMATON".
%
% See Also:
%   verify,compute_mapping,set_auto_state,get_auto_state,refine_auto

global GLOBAL_NEW_AUTOMATON
global GLOBAL_PROGRESS
global GLOBAL_RAUTO_REMAP_LIST
global GLOBAL_PIHA

% >>>>>>>>>>>> Parameter Change -- OS -- 06/13/02 <<<<<<<<<<<<

% use of param-file eliminated

% >>>>>>>>>>>> -------------- end --------------- <<<<<<<<<<<<

if continu
    if ~ismember(GLOBAL_PROGRESS.step,{'rauto_mapping'})
        error('CheckMate:RAuto:WorngStep', ['Inconsistent continu step ''' GLOBAL_PROGRESS.step ...
            ''' (expected ''rauto_mapping'').'])
    end
    start = GLOBAL_PROGRESS.idx;
else
    start = 1;
    temp.step = 'rauto_mapping';
    temp.idx = 1;
    GLOBAL_PROGRESS = temp;
end

total = length(GLOBAL_RAUTO_REMAP_LIST)-start+1;
computed = 0;
t_start = clock;
for idx = start:length(GLOBAL_RAUTO_REMAP_LIST)
    GLOBAL_PROGRESS.idx = idx;
    stidx = GLOBAL_RAUTO_REMAP_LIST{idx};

    % display some info
    if (length(stidx) == 2) % if initial state
        str = sprintf('loc %d : initstate %d (%d/%d)', ...
            stidx(1),stidx(2),computed+1,total);
    else % if face state
        str = sprintf('loc %d : face %d : state %d (%d/%d)', ...
            stidx(1),stidx(2),stidx(3),computed+1,total);
    end
    if (computed > 0)
        time_to_go = etime(clock,t_start)/computed*(total-computed)/3600;
        if time_to_go > 1
            str = [str sprintf(' -- %f hr to go',time_to_go)];
        else
            time_to_go = time_to_go*60;
            str = [str sprintf(' -- %f min to go',time_to_go)];
        end
    end
    %clc;
    fprintf(1,'Computing mappings.\n'); fprintf(1,'%s\n',str); drawnow

    % begin computing mapping
    indeterminate = get_auto_state('new',stidx,'indeterminate');
    X0 = get_auto_state('new',stidx,'polytope');
    % if indeterminate flag is not set then compute the mapping
    if (indeterminate == 0)
        if length(stidx) == 2
            cell=GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.cell;
            [destination,null_event,time_limit,out_of_bounds,terminal] = ...
                compute_mapping(X0,'init',[],stidx(1),cell);
            GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.null_event=null_event;
            GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.time_limit=time_limit;

            if(length(stidx)==3)
                GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.state{stidx(3)}.out_of_bounds=out_of_bounds;
                GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.state{stidx(3)}.terminal=terminal;
            end

        else
            cell=GLOBAL_PIHA.Locations{stidx(1)}.interior_cells(stidx(2));
            [destination,null_event,time_limit,out_of_bounds,terminal] = ...
                compute_mapping(X0,'face',[],stidx(1),cell);
            GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.null_event=null_event;
            GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.time_limit=time_limit;
            GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.out_of_bounds=out_of_bounds;
            GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.terminal=terminal;

        end

        %Identify which loc-cell-state the destination mappings landed in:
        %------------------------------------------------------------------------------
        if(length(stidx)==3)
            pot_children=GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.children;
        else
            pot_children=GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.children;
        end
        children_temp=[];

        for i=1:length(destination)
            dst_loc=destination{i}.location;
            dst_cell=destination{i}.cell;
            dst_mapping=destination{i}.mapping;
            [dum1,dum2,cell_index]=intersect(dst_cell,GLOBAL_PIHA.Locations{dst_loc}.interior_cells);

            for j=1:size(pot_children,1)
                if (dst_loc==pot_children(j,1)) && (cell_index==pot_children(j,2))
                    inters=dst_mapping&GLOBAL_NEW_AUTOMATON{pot_children(j,1)}.interior_region{pot_children(j,2)}.state{pot_children(j,3)}.polytope;
                    if ~isempty(inters)
                        %Assign this state which the mapping 'hits' to the appropriate children field in
                        %GLOBAL_AUTOMATON
                        if length(stidx)~=2
                            if isempty(intersect(children_temp,pot_children(j,:),'rows'))
                                children_temp = [children_temp ; pot_children(j,:)];
                                GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.mapping...
                                    {length(GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.mapping)+1}=inters;
                            end
                        else
                            if isempty(intersect(children_temp,pot_children(j,:),'rows'))
                                children_temp = [children_temp ; pot_children(j,:)];
                                GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.mapping...
                                    {length(GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.mapping)+1}=inters;

                            end
                        end %if length...
                    end %if ~isempty...
                end %if (dst_loc...
            end %for j=...
        end %for i=...

        if length(stidx)~=2
            GLOBAL_NEW_AUTOMATON{stidx(1)}.interior_region{stidx(2)}.state{stidx(3)}.children=children_temp;
        else
            GLOBAL_NEW_AUTOMATON{stidx(1)}.initstate{stidx(2)}.children=children_temp;
        end

    else
        fprintf(1,'Indeterminate state, skip mapping computation.\n')
    end

    computed = computed + 1;
end
fprintf(1,'\n')

return