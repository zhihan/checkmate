function t = get_transitions(f)
% GET_TRANSITIONS returns the subgraph in f
%
% t = get_transitions(f)
% returns the set of transitions in f
    
global GLOBAL_TRANSITION
t = [];
for i=1:length(GLOBAL_TRANSITION)
    if isinregion(f, i)
        outgoing = GLOBAL_TRANSITION{i};
        for j=1:length(outgoing)
            if isinregion(f, j)
                t = vertcat(t, [i, j]);
            end
        end
    end
end