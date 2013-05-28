function q = get_state(f)
% GET_STATE returns the list of states
%
%  q = get_state(f)
%  get the sets of state in f and return it as a vector.
    q = 1:f.nstate;
    for i=1:f.nstate
        if ~isinregion(f,i)
            q(i) = -1;
        end
    end
    q = q(q>0);
end