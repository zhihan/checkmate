function INV = location_invariant(loc_idx)

% Get the `invariant` for the given `location`.
%
% Syntax:
%   "INV = location_invariant(loc_idx)"
%
% Description:
%   Return the "linearcon" object representing the `invariant` polytope for
%   the `location` specified by the "loc_idx".
%
% See Also:
%   piha,linearcon

global GLOBAL_PIHA

p = GLOBAL_PIHA.Locations{loc_idx}.p;
boundary = GLOBAL_PIHA.Cells{p}.boundary;
hpflags = GLOBAL_PIHA.Cells{p}.hpflags;
[C,d] = cell_ineq(boundary,hpflags);
INV = linearcon([],[],C,d);

