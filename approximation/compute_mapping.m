function [destination,null_event,time_limit,out_of_bound,terminal] = ...
    compute_mapping(X0, srcloc, srccell)

% 	Compute the `mapping set` to encapsulate compute_mapping_SD and
%	compute_mapping_no_SD
%
% Example
%   [destination,null_event,time_limit,out_of_bounds,terminal_out] = ...
%		compute_mapping(X0,sttype,Tstamp,srcloc,srcface)
%
% Description:
%   A `mapping set` is the set of states on the boundary faces of the
%   location `invariant` that can be reached under the given continuous
%   dynamics from the initial continuous set. The inputs to this function
%   are
%
%   * "X0": a "linearcon" object representing the initial continuous set
%     for which the mapping is to be computed.
%
%   * "sttype": type of state for "X0" which is either an `initial` or
%     `face` state ('init' or 'face').
%
%   * "srcloc": source location.
%
%	 * "srccell": cell region of source
%
%	 * "Tstamp": Time interval to be used when verifying time bounds and
%					 for sampled-data computations.
%
%
%   The outputs of this function are
%
%   * "mapping": a one-dimensional cell array with the same number of elements
%     as the number of faces of the location invariant. Each element
%     "MAPPING{i}" is a cell array of polytopes constituting the mapping set
%     on the "i"-th face of the invariant.
%
%	 * "destination" contains information about where the flowpipe lands
%
%
%   * "null_event": a boolean flag indicating that the flow pipe computation
%     was terminated because it can be concluded that the subsequent flow
%     pipe segments will remain inside "INV" forever.
%
%   * "time_limit": a boolean flag indicating that the flow pipe computation
%     was terminated because the time limit "max_time" was exceeded.
%
% Implementation:
%   Call the mapping computation routine corresponding to the type of the
%   composite continuous dynamics of all SCSBs for the given location
%   ("fs_lin_map" for `linear` (affine) dynamics, "fs_nonlin_map" for
%   `nonlinear` dynamics, and "clk_map" for `clock` dynamics). For `face`
%   states, if it is possible to determine that all vector field on the
%   polytop is going out of the the invariant (for `linear` and `clock`
%   dynamics only), return the polytope itself as the mapping.
%
% See Also:
%   fs_nonlin_map,fs_lin_map,clk_map

global GLOBAL_PIHA

sampled_transition = zeros(1,length(GLOBAL_PIHA.Locations{srcloc}.transitions));
for i=1:length(GLOBAL_PIHA.Locations{srcloc}.transitions)
    if ~isempty(GLOBAL_PIHA.Locations{srcloc}.transitions{i}.clock)
        sampled_transition(i) = 1;
    end
end

[dest,null_event,time_limit,out_of_bound,terminal] = ...
    compute_mapping_no_SD(X0,srcloc,srccell);

destination = dest;
var_length = length(dest);
for i=1:var_length
    destination{i}.transition_theta=0;
end

return

