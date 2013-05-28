function result = rauto_ischild(idx,srcloc,mapping)

% Check if the specified `face` state is a valid destination state given a
% `mapping set` and a source location in the new `approximating automaton`
% (the one obtained after the refinement).
%
% Syntax:
%   "result = rauto_ischild(idx,srcloc,mapping)"
%
% Description:
%   The inputs to this function are
%
%   * "idx": the index for the `face` state in "GLOBAL_NEW_AUTOMATON" to be
%     checked. A `face state` index is of the form "[l f s]" where "l" is the
%     `location` number, "f" is the `face` number, and "s" is the `state`
%     number.
%
%   * "srcloc": the source location
%
%   * "mapping": the `mapping set`, which is a cell array of "linearcon"
%     objects. A `mapping set` is the set of states on the boundary faces of
%     the location `invariant` that can be reached under the given continuous
%     dynamics from the initial continuous set.
%
%   The output "result" is a boolean flag indicating whether the specified
%   state is a valid destination for the given mapping set and the source
%   location.
%
% Implementation:
%   Find the invariant face of the source location that leads to the
%   location containing the specified destination state. Intersect the
%   polytopes in the mapping set on the source face with the polytope for
%   the specified state. Return 1 in "result" if a feasible intersection is
%   found, otherwise return 0.
%
% See Also:
%   rauto_mapping,rauto_tran

% Global variables (used as reference only in this function)
global GLOBAL_PIHA 

if isempty(mapping)
  error('CheckMate:RAuto:NoMapping','Empty mapping given.')
else
  dstloc = idx(1);
  
  % find the face on the source location for which the state idx is on
  found = 0;
  for k = 1:length(GLOBAL_PIHA.Locations{srcloc}.transitions)
    transitions_k = GLOBAL_PIHA.Locations{srcloc}.transitions{k};
    for m = 1:length(transitions_k)
      if strcmp(transitions_k(m).type,'regular') && ...
	    (dstloc == transitions_k(m).destination)
	srcface = k;
	found = 1;
	break;
      end
    end
    if found
      break;
    end
  end
  if ~found
    error('CheckMate:RAuto:WrongTransision',['Warning: Impossible destination location ' ... 
          'indicated in the given state index.'])
    result = 0;
    return
  end

  % find intersection between mapping on the source face and states on the
  % destination face
  result = 0;
  polytope = get_auto_state('new',idx,'polytope');
  for k = 1:length(mapping{srcface})
    if isfeasible(polytope,mapping{srcface}{k})
      result = 1;
      break;
    end
  end
end

return
