function next_step = make_decision()
global GLOBAL_SPEC GLOBAL_AP GLOBAL_AP_BUILD_LIST GLOBAL_SPEC_TREE GLOBAL_TBR GLOBAL_TRANSITION;

fprintf(1,'\nMaking refinement decision.\n')
% build regions in the transition system GLOBAL_TRANSITION
% for atomic propositions in the build list
GLOBAL_TBR = region();

for i=1:length(GLOBAL_SPEC)-1
    GLOBAL_AP = build_ap(GLOBAL_AP_BUILD_LIST{i});
    % compute region in GLOBAL_TRANSITION corresponding to
    % ACTL specification
    spec = evaluate(GLOBAL_SPEC_TREE{i});
    % compute initial state region
    init = init_states;
    if isempty(init & ~spec)
        %Give explicit output for the cases where the user did not specify an ACTL
        %expression (i.e. the case where a state was named 'avoid'/'reach').  Added
        %by Jim K 2/10/2002.
        if i>(length(GLOBAL_SPEC)-GLOBAL_SPEC{length(GLOBAL_SPEC)}-1)
            if ~isempty(findstr('avoid',GLOBAL_SPEC{i}))
                temp=GLOBAL_AP_BUILD_LIST{i}{2}.build_info{3};
                avoid_state_name = temp;
                fprintf(1,'\nSystem never enters the state "%s"\n\n',avoid_state_name);
            elseif ~isempty(findstr('reach',GLOBAL_SPEC{i}))
                temp=GLOBAL_AP_BUILD_LIST{i}{2}.build_info{3};
                reach_state_name = temp;
                fprintf(1,'\nSystem enters the state "%s" in all cases.\n\n',reach_state_name);
            end
        else
            fprintf(1,['\nSystem already satisfies specification %d. No refinement' ...
                ' necessary.\n\n'],i)
        end
        refine(i)=0;
    else
        if i>(length(GLOBAL_SPEC)-GLOBAL_SPEC{length(GLOBAL_SPEC)}-1)
            if ~isempty(findstr('avoid',GLOBAL_SPEC{i}))
                temp=GLOBAL_AP_BUILD_LIST{i}{2}.build_info{3};
                avoid_state_name = temp;
                fprintf(1,'\nSystem does not satisfy the specification of nevering entering the state "%s"\n',avoid_state_name);
                fprintf(1,'The transition system may be too conservative.\n');
                fprintf(1,'Computing the set of states in the transition system that will be refined in order\n');
                fprintf(1,'to perform another verification attempt.\n\n');
            elseif ~isempty(findstr('reach',GLOBAL_SPEC{i}))
                temp=GLOBAL_AP_BUILD_LIST{i}{2}.build_info{3};
                reach_state_name = temp;
                fprintf(1,'\nSystem does not satisfy the specification of always entering the state "%s"\n',reach_state_name);
                fprintf(1,'The transition system may be too conservative.\n');
                fprintf(1,'Computing the set of states in the transition system that will be refined in order\n');
                fprintf(1,'to perform another verification attempt.\n\n');
            end
        else
            fprintf(1,['\nSystem does not satisfy specification %d.\n' ...
                'Computing the "to-be-refined" (TBR) set.\n\n'],i)
        end
        % compute the set of states that violate the bisimulation
        % condition, i.e. states that have more than one child.
        not_bisim = region(length(GLOBAL_TRANSITION),'false');
        for k = 1:length(GLOBAL_TRANSITION)
            if (length(GLOBAL_TRANSITION{k}) > 1)
                not_bisim = set_state(not_bisim,k,1);
            end
        end
        GLOBAL_TBR = (reach(init & ~spec) & not_bisim)|GLOBAL_TBR;
        if isempty(GLOBAL_TBR)
            fprintf(1,['No meaningful refinement to be done and ' ...
                'system does not satisfy specification.\n\n'])
            refine(i)=0;
        else
            refine(i)=1;
        end
    end
end

if ~all(refine)
    next_step='done';
else
    next_step='refine_automaton';
end
%Now remove automatically generated CTL expressions from the list of GLOBAL_SPEC's
GLOBAL_SPEC_TEMP={};
for i=1:length(GLOBAL_SPEC)-GLOBAL_SPEC{length(GLOBAL_SPEC)}-1
    GLOBAL_SPEC_TEMP{i}=GLOBAL_SPEC{i};
end
GLOBAL_SPEC=GLOBAL_SPEC_TEMP;