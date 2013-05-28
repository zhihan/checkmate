function result = is_valid_new_auto_idx(idx)

% Check if the given state index for the global variable
% "GLOBAL_NEW_AUTOMATON" is valid.
%
% Syntax:
%   "result = is_valid_new_auto_idx(idx)"
%
% Description:
%   For an `initial state` index "[l s]", check if
%   "GLOBAL_NEW_AUTOMATON{l}.initstate{s}" exists. For a `face state` index
%   "[l f s]", check if "GLOBAL_NEW_AUTOMATON{l}.face{f}.state{s}"
%   exists. Return 1 if the given state index is valid and 0 otherwise.
%
% Note:
%   This function is identical to "is_valid_auto_idx()" except that it
%   references the variable "GLOBAL_NEW_AUTOMATON" rather than
%   "GLOBAL_AUTOMATON".
%
% See Also:
%   inc_auto_idx,inc_new_auto_idx,is_valid_new_auto_idx

global GLOBAL_NEW_AUTOMATON

if length(idx) == 2 % must be an initial state
  if isfield(GLOBAL_NEW_AUTOMATON{idx(1)},'initstate')
    result = (idx(1) >= 1) & (idx(1) <= length(GLOBAL_NEW_AUTOMATON)) & ...
        (idx(2) >= 1) & ...
        (idx(2) <= length(GLOBAL_NEW_AUTOMATON{idx(1)}.initstate));
  else
    result = 0;
  end
elseif length(idx) == 3  % must be a face state
  result = (idx(1) >= 1) & (idx(1) <= length(GLOBAL_NEW_AUTOMATON)) & ...
      (idx(2) >= 1) & ...
      (idx(2) <= length(GLOBAL_NEW_AUTOMATON{idx(1)}.face)) & ...
      (idx(3) >= 1) & ...
      (idx(3) <= length(GLOBAL_NEW_AUTOMATON{idx(1)}.face{idx(2)}.state));
else
  result = 0;
end
return
