function st = isuniverse(s)

% Check if a region of a finite-state machine is the universe set (the
% set of all states). 
%
% Syntax:
%   "st = isuniverse(s)"
%
% Description:
%   Returns 1 if the region "s" is the universe set, i.e. all bits in the
%   look-up table are 1, and returns 0 otherwise.
%
% See Also:
%   region,set_state,isinregion,isempty,and,or,not

st = isempty(~s);
