function EGf = checkEG(f)

% Evaluate the `computation tree logic (CTL)` expression "EG f". 
%
% Syntax:
%   "EGf = checkEG(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and the "region" object "f", compute the region
%   "EGf" corresponding to the CTL expression "EG f".
%
% Implementation:
%   "GLOBAL_REV_TRANSITION" is a cell array of whose "i"-th entry is a
%   vector of source states for each state "i" in the transition
%   system. "checkEG()" first calls "findSCCf()" to find non-trivial
%   `strongly connected components (SCC)` in the region "f" in the global
%   transition system and then computes the set of backward reachable states
%   along the path in the region "f" from the states in these non-trivial
%   SCCs.
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkER,checkEU,checkEX

% Note that the REVERSE transition must be given for the result
% to be correct!

% global global variables
global GLOBAL_REV_TRANSITION

% local global variables
global VISITED REGION_F

N = length(GLOBAL_REV_TRANSITION);

% Start by including into EGf states which are a member of some non-trivial
% strongly connected component of TRANSITION restricted to region f.
EGf = region(N,'false');
scc = findSCCf(f);
for k = 1:length(scc)
  if (length(scc{k}) > 1)
    % If an SCC contains more than one states, it is non-trivial,
    nontrivial = true;
  else
    % Otherwise, this SCC contains only one node s. It is non-trivial
    % if s has a self-loop.
    s = scc{k}(1);
    nontrivial = ismember(s,GLOBAL_REV_TRANSITION{s});
  end
  % add all states in non-trivial SCC to EGf. 
  if nontrivial
    for l = 1:length(scc{k})
      EGf = set_state(EGf,scc{k}(l),1);
    end
  end
end

% Local global variable initializations before depth first search
REGION_F = f;
VISITED = region(N,'false');

% Perform depth first search using the REVERSE transition
% from all states in region EGf computed above, along 
% the paths where f is true.
for i = 1:N
  if isinregion(EGf,i) && ~isinregion(VISITED,i)
    visit(i);
  end
end

EGf = VISITED;
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
