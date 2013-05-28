function reachf = reach(f)

% Find the set of reachable states in the global transition system.
%
% Syntax:
%   "reachf = reach(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION", compute the set of states "reachf" that are
%   reachable from the set of states "f". Both "f" and "reachf" are "region"
%   objects.
%
% Implementation:
%   "GLOBAL_TRANSITION" is a cell array of whose "i"-th entry is a vector of
%   destination states for each state "i" in the transition system. The
%   function "reach" performs depth first search from all states in the
%   input region "f". Using the global variable "VISITED", the algorithm
%   complexity is linear in the number of states in the transition
%   system. The variable "VISITED" is global only within the scope of this
%   m-file.
%
% See Also:
%   region,auto2xsys,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEU,checkEX

% global global variable
global GLOBAL_TRANSITION

% local global variable
global VISITED

N = length(GLOBAL_TRANSITION);
VISITED = region(N,'false');

% perform depth first search from all states in region f
for i = 1:N
  if isinregion(f,i) && ~isinregion(VISITED,i)
    visit(i);
  end
end

reachf = VISITED;
return

% -----------------------------------------------------------------------------

function visit(node)

% global global variable
global GLOBAL_TRANSITION

% local global variable
global VISITED

% Mark current node as "visited"
VISITED = set_state(VISITED,node,1);

% Visit all unvisited children
children = GLOBAL_TRANSITION{node};
for k = 1:length(children)
  if ~isinregion(VISITED,children(k))
    visit(children(k))
  end
end
return
