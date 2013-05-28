function INV = return_region(cell)

% Get the `invariant` for the given `location`.
%
% Syntax:
%   "INV = return_region(cell)"
%
% Description:
%   Return the "linearcon" object representing the `invariant` polytope for
%   the `location` specified by the "cell".
%
% See Also:
%   piha,linearcon

% The routine is changed by Dong Jia. Instead of return a single linearcon
% object, it returns a set of linearcon objects.

global GLOBAL_PIHA

% The perform_face_partitioning flag dictates when face partitioning is
% used.  Face partitioning is when a cell region is split up into the
% its center and several sliver regions on the faces of the cell.
% JPK 11/2003

boundary = GLOBAL_PIHA.Cells{cell}.boundary;
hpflags = GLOBAL_PIHA.Cells{cell}.hpflags;
[C,d] = cell_ineq(boundary,hpflags);
INV{1} = linearcon([],[],C,d);
return
