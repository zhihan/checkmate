function [locations, fsmb2scsb] = create_locations(sfdata, pthb, NAR, fsmbHandle, scsbHandle, pthbHandle)

k=ones(1,length(sfdata));
%Find the total number of possible locations
no_loc=1;
for j=1:length(sfdata)
    machine{j}.states=sf('get',sfdata{j}.StateflowChartID,'.states');
    no_loc=no_loc*length(machine{j}.states);
end
locations=[];

% Reset operation. It maps the FSMB to SCSB
% Ansgar Fehnker 09/16/2002

% Compute which fsmb is connceted to which scsb
for k0 =1:length(fsmbHandle)
    fsmb2scsb{k0} = [];
end

for k1 = 1:length(scsbHandle)
    if strcmp(get_param(scsbHandle(k1),'use_reset'),'on')
        inputfsmb_Handle = trace_scsb_input(scsbHandle(k1),'reset');
        % The error checking in trace_scsb_input ensures that only one FSMB
        % is returned in inputfsmb_Handle.
        fsmbindex = find(inputfsmb_Handle == fsmbHandle);
        fsmb2scsb{fsmbindex} = [fsmb2scsb{fsmbindex} k1];
    end
end

%Find all possible locations by attempting all combinations of states
%and machines
for j=1:no_loc

    %Test each combination to see if it is a null state
    for i=1:length(sfdata)
        q(i)=machine{i}.states(k(i));
    end
    null_state=is_terminal_state(q);
    if null_state==0
        new=length(locations)+1;
        number_trans=0;
        for l=1:length(q)
            % "only_condition_inputs_flag" added by JimK (11/2002).  The purpose of the flag
            % is to notify "create_guard" if there are only condition inputs into the stateflow
            % block.  If this is the case, all edges should be flagged as event edges.
            if isempty(sfdata{l}.InputEvent)
                only_condition_inputs_flag = 1;
            else
                only_condition_inputs_flag = 0;
            end
            transitions=sf('get',q(l),'.srcTransitions');
            names=sf('get',transitions,'.labelString');
            for p=1:size(names,1)
                number_trans=number_trans+1;
                locations{new}.transitions{number_trans}.id=transitions(p);
                [event_expr,condition_expr,clock,reset_flag]=process_label_string(names(p,:),sfdata,l,{});
                [total_expression,event_expression,condition_expression]=find_cond_expr(sfdata,condition_expr,event_expr,l);
                locations{new}.transitions{number_trans}.expression=total_expression;
                locations{new}.transitions{number_trans}.clock=clock;
                locations{new}.transitions{number_trans}.idx=l;    % Zhi add this to record the index of transition in q
                locations{new}.transitions{number_trans}.source=sf('get',transitions(p),'.src.id');
                locations{new}.transitions{number_trans}.destination=sf('get',transitions(p),'.dst.id');
                locations{new}.transitions{number_trans}.destination_name=sf('get',sf('get',transitions(p),'.dst.id'),'.name');
                locations{new}.transitions{number_trans}.reset_flag=reset_flag;

                % Stores the scsb that defines the reset
                locations{new}.transitions{number_trans}.reset_scs_index=fsmb2scsb{l};

                %Find guard region.  Result will be pointers to cell locations which describe this guard
                [guard_cells,guard_cell_event_flags,guard_compl_cells]=create_guard(condition_expression,event_expression,pthbHandle,pthb,NAR,only_condition_inputs_flag);
                locations{new}.transitions{number_trans}.guard=guard_cells;
                locations{new}.transitions{number_trans}.guard_cell_event_flags=guard_cell_event_flags;
                locations{new}.transitions{number_trans}.guard_compl=guard_compl_cells;

            end %for
        end%for
        %Use guard complements from every transition from this location to compute
        %the 'invariant' for this location.  The idea is to intersect all of the
        %complements of the guards for this location.  This is done iteratively by
        %intersecting the first guard complement with the next, then taking the result
        %and intersecting it with the 3rd and so on (i.e  ( A and B ) and C ....)
        %       clean_loc=clean_transition(locations{new});
        %        locations{new}.transitions=clean_loc.transitions;
        locations{new}.q=q;
        locations{new}.state=sf('get',q,'.name');
        locations{new}.interior_cells=[];
        invariant=intersect_complements(locations,new);
        locations{new}.interior_cells=invariant;
    end%if
    for n=1:length(k)
        if k(n)+1<=length(machine{n}.states)
            k(n)=k(n)+1;
            break;
        else
            k(n)=1;
        end%if
    end%for
end%for
