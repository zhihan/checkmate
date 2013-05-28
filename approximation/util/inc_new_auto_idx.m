function next = inc_new_auto_idx(idx)

% Increment given state index for the global variable "GLOBAL_NEW_AUTOMATON"
% by 1. "GLOBAL_AUTOMATON" is the global variable for the new `quotient
% transition system` obtained after the refinement.
%
% Syntax:
%   "next = inc_auto_idx(idx)"
%
% Description:
%   Given the state index "idx" for "GLOBAL_NEW_AUTOMATON", increment the
%   index by one and return the result in "next"
%
% Implementation:
%   A state index for "GLOBAL_NEW_AUTOMATON" is a row vector of length 2 or
%   3. An `initial state` has an index of the form "[l s]" where "l" is the
%   `location` number and "s" is the `state` number. A `face state` has an
%   idex of the form "[l f s]" where "l" is the `location` number, "f" is
%   the `face` number, and "s" is the `state` number.
%
%
%
%   The state index is incremented from the right. If the resulting index at
%   the current position has gone past the number of location, face, or
%   state corresponding to that index position, reset the index at the
%   current position to 1, increment the next index on the left by 1, and
%   check the result again to see of the next index on the left should be
%   incremented. If the resulting index does not correspond to a valid state
%   in "GLOBAL_NEW_AUTOMATON", keep incrementing until a valid index is
%   found. If no valid index is found and the location index has gone past
%   the length of the locations in "GLOBAL_NEW_AUTOMATON", do the
%   following: 
%   
%   * If the current index is an `initial` state, then reset the index to the
%     first `face` state "[1 1 1]" and repeat the above process.
%
%   * If the current index is a `face` state, then we have gone past the
%     last state in "GLOBAL_NEW_AUTOMATON". In this case, return an empty
%     matrix "[]".
%
% Note:
%   This function is identical to "inc_auto_idx()" except that it references
%   the variable "GLOBAL_NEW_AUTOMATON" rather than "GLOBAL_AUTOMATON".
%
% See Also:
%   inc_auto_idx

global GLOBAL_NEW_AUTOMATON

stop = 0;
while ~stop
  if (length(idx) == 2) % must be an initial state
    idx(2) = idx(2) + 1;
    is_init_loc = isfield(GLOBAL_NEW_AUTOMATON{idx(1)},'initstate');
    if (~is_init_loc) || ...
          (is_init_loc && (idx(2) > length(GLOBAL_NEW_AUTOMATON{idx(1)}.initstate)))
      idx(2) = 1;
      idx(1) = idx(1) + 1;
    end
    if (idx(1) > length(GLOBAL_NEW_AUTOMATON))
      idx = [1 1 1];
    end
  elseif (length(idx) == 3) % must be a face state
    idx(3) = idx(3) + 1;
    if (idx(3) > length(GLOBAL_NEW_AUTOMATON{idx(1)}.face{idx(2)}.state))
      idx(3) = 1;
      idx(2) = idx(2) + 1;
    end
    if (idx(2) > length(GLOBAL_NEW_AUTOMATON{idx(1)}.face))
      idx(2) = 1;
      idx(1) = idx(1) + 1;
    end
    if (idx(1) > length(GLOBAL_NEW_AUTOMATON))
      idx = [];
    end
  else
    idx = [];
  end
  stop = is_valid_new_auto_idx(idx) | isempty(idx);
end
next = idx;
