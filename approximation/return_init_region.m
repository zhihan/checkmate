function INV = return_init_region(cell)

% Get the `invariant` for the given `location`.
%
% Syntax:
%   "INV = return_init_region(cell)"
%
% Description:
%   Return the "linearcon" object representing the `invariant` polytope for
%   the `location` specified by the "cell".
%
% See Also:
%   piha,linearcon

% This routine acts the same as the previous return_region routine.

global GLOBAL_PIHA 
boundary = GLOBAL_PIHA.Cells{cell}.boundary;
hpflags = GLOBAL_PIHA.Cells{cell}.hpflags;

[C,d] = cell_ineq(boundary,hpflags);
INV = linearcon([],[],C,d);

return
