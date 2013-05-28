function [MAPPING,null_event,time_limit] = ...
    fs_nonlin_map(sys_eq,ode_param,X0,INV,Pcon,T,max_time)

% Compute the `mapping set` from an initial continuous set to the boundary
% of the given `invariant` set under the given `nonlinear` continuous
% dynamics using flow pipe approximations with fixed time steps.
%
% Syntax:
%   "[MAPPING,null_event,time_limit] = fs_nonlin_map(sys_eq,ode_param,X0,INV,T,max_time)"
%
% Description:
%   The inputs are
%
%   * "sys_eq": string containing file name of the derivative function
%     for the ODE
%
%   * "ode_param": optional parameters for the ODE file
%
%   * "X0": a "linearcon" object representing initial set
%
%   * "INV": a "linearcon" object represeting the invariant set
%
%   * Pcon : A linearcon object representing the constraint on the parameters.
%
%   * "T": time step for the flow pipe approximations
%
%   * "max_time": absolute time limit for the flow pipe computations
%
%   The outputs are
%
%   * "MAPPING": a one-dimensional cell array with the same number of elements
%     as the number of faces of "INV". Each element "MAPPING{i}" is a cell
%     array of polytopes constituting the mapping set on the "i"-th face of
%     "INV".
%
%   * "null_event": a boolean flag indicating that the flow pipe computation
%     was terminated because it can be concluded that the subsequent flow
%     pipe segments will remain inside "INV" forever.
%
%   * "time_limit": a boolean flag indicating that the flow pipe computation
%     was terminated because the time limit "max_time" was exceeded.
%
% Implementation:
%   The `mapping set` is the subset of the faces of the invariant "INV" that
%   can be reached from the initial continuous state set "X0" under the
%   nonlinear continuous dynamics. The mapping set is computed by
%   intersecting the flow pipe segment computed in each time step with the
%   boundary of "INV".
%
%
%
%   The first flow pipe segment requires a special treatment. Often times,
%   we obtain "X0" back from the intersection of the first flow pipe segment
%   and the boundary of "INV". The intersection is a valid mapping only if
%   all vector field on it is pointing out of "INV". To rule out spurious
%   mappings resulting from the intersection of the the first flow pipe
%   segment with the boundary of "INV", we drop the intersection of the
%   first segment on any face of "INV" such that the segment lies completely
%   inside of it.
%
%
%
%
%   Terminate the computation when one or more of these criteria are met.
%
%   * `The flow pipe segment lies completely outside of "INV"`. In this,
%     case all trajectories of "X0" must have gone past the "INV"
%     boundary.
%
%   * `The time interval for the current flow pipe segment has exceeded the
%     time limit "max_time"`. In this case, we may not have a truly
%     conservative approximation of the mapping set because we do not know
%     whether the subsequent flow pipe segments can reach the invariant
%     boundary or not. Set the "time_limit" flag to 1 to indicate this
%     case.
%
%   Since we currently do not have the method to determine conclusively if
%   the subsequent flow pipe segments will remain inside the invariant
%   forever, the "null_event" flag is always set to 0.
%
% See Also:
%   seg_approx_ode,stretch_func_ode,linearcon

% Set PLOT to 1 to visualize the flow pipe computations for 2-D/3-D
% continuous dynamics, otherwise set PLOT to 0

% Set PLOT to 1 to visualize the flow pipe computations for 2-D/3-D
% continuous dynamics, otherwise set PLOT to 0
%
% changed to enable parametric verification. Pcon contains the parameter
% constraints.

fprintf(1,'\nComputing flow pipe segments:\n')
counter = 0;
N = number_of_faces(INV);
MAPPING = cell(N,1);
sample_points = vertices(X0);
t0 = 0;
first = 1;
time_limit = 0;
partially_inside = 1;
while (~time_limit && partially_inside)
    if mod(counter,15)==0
        fprintf('\n');
    end
    fprintf('%3i ',counter+1);
    [Pk,sample_points,intersect_flag] = seg_approx_ode(sys_eq,ode_param, ...
        X0,INV,sample_points,t0,t0+T,Pcon);


    % >>>>>>>>>>>> Intersection Computation -- DJ -- 06/30/03 <<<<<<<<<<<<
    % If the segment intersection with the boundary of the invariant, compute the intersection.
    if intersect_flag
        mapk = invariant_boundary_intersect(INV,Pk);
    else
        mapk={};
    end
    % >>>>>>>>>>>> -------------- end (Intersection Computation) --------------- <<<<<<<<<<<<

    if first
        % Special treatment of the first flow pipe segment. For each face of
        % INV, check if the segment has gone through any part of it. If the
        % segment lies completely in the negative half-space of the face,
        % then the vector field on X0 must be going towards the inside of INV
        % and we drop any mapping that is found on this face.
        [temp1,temp2,CINV,dINV] = linearcon_data(INV);
        for l = 1:N
            cl = CINV(l,:); dl = dINV(l);
            positive_half_space = linearcon([],[],-cl,-dl);
            if ~isfeasible(Pk,positive_half_space)
                mapk{l} = {};
            end
        end
        first = 0;
    end

    for l = 1:length(mapk)
        if ~isempty(mapk{l})
            new = length(MAPPING{l})+1;
            MAPPING{l}{new} = mapk{l};
        end
    end

    partially_inside = isfeasible(Pk,INV);
    t0 = t0+T;
    time_limit = t0 > max_time;

    % check for recurrent flowpipe segments
    % set the null_event flag is this is the case
    if issubset(Pk,X0)
        null_event = 1;
    else
        null_event=0;
    end;
    counter = counter + 1;
end

fprintf(1,'\n')
return




