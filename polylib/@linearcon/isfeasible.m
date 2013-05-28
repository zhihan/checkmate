function test = isfeasible(a,b)

% Determine whether or not the intersection of two linear constraint objects
% exists.
%
% Syntax:
%   "C = isfeasible(a,b)"
%
% Description:
%   "isfeasible(a,b)" returns a "0" if the intersection of "a" and "b" is
%   empty, otherwise, "isfeasible(a,b)" returns "1".
%
% Examples:
%   Given two linear constraint objects, "a" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1) and "b", another square in the same plane with corners at (2,1),
%   (2,2), (3,1), and (3,2), 
%
%
%
%   "C = isfeasible(a,b)"
%
%
%
%   returns "1".
%
% See Also:
%   linearcon,and

if isa(b,'polyhedron')
  b = linearcon(b);
end


if isa(b,'linearcon')
    CE = [a.CE; b.CE];
    dE = [a.dE; b.dE];
    CI = [a.CI; b.CI];
    dI = [a.dI; b.dI];
    
    if feasible(CE,dE, CI, dI)
        [CEnew, dEnew, CInew, dInew] = ...
            remove_implicit_linear(CE, dE, CI, dI);
        
        if isempty(a.dE) && isempty(b.dE)
            test = size(CEnew,1) < 1;
        else
            test = size(CEnew,1) < 2;
        end
    else
        test = false;
    end
    
end

