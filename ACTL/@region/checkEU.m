function EfUg = checkEU(f,g)

% Evaluate the `computation tree logic (CTL)` expression "E f U g". 
%
% Syntax:
%   "EfUg = checkEU(f,g)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and "region" objects "f" and "g", compute the
%   region "EfUg" corresponding to the CTL expression "E f U g".
%
% Implementation:
%   "GLOBAL_REV_TRANSITION" is a cell array of whose "i"-th entry is a
%   vector of source states for each state "i" in the transition
%   system. "checkEU()" uses a similar algorithm to the function "reach()"
%   to find the set of states reachable from the region "g" in the reverse
%   transition system along the paths in the region "f".
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEX

% Note that the REVERSE transition must be given for the result to be
% correct!

% global global variables
global GLOBAL_REV_TRANSITION

% local global variables
global VISITED REGION_F

N = length(GLOBAL_REV_TRANSITION);
REGION_F = f;
VISITED = region(N,'false');

% perform depth first search using the reverse transition
% from all states in region g along the paths where f is true
for i = 1:N
  if isinregion(g,i) && ~isinregion(VISITED,i)
    visit(i);
  end
end

EfUg = VISITED;
return

% -----------------------------------------------------------------------------

function visit(node)

% global global variables
global GLOBAL_REV_TRANSITION

% local global variables
global VISITED REGION_F

% Mark current node as "visited"
VISITED = set_state(VISITED,node,1);

% Visit all unvisited children
parents = GLOBAL_REV_TRANSITION{node};
for j = 1:length(parents)
  if ~isinregion(VISITED,parents(j)) && isinregion(REGION_F,parents(j))
    visit(parents(j))
  end
end
return
