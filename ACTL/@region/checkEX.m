function EXf = checkEX(f)

% Evaluate the `computation tree logic (CTL)` expression "EX f". 
%
% Syntax:
%   "EXf = checkEX(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and a "region" object "f", compute the region
%   "EXf" corresponding to the CTL expression "EX f".
%
% Implementation:
%   "GLOBAL_REV_TRANSITION" is a cell array of whose "i"-th entry is a
%   vector of source states for each state "i" in the transition
%   system. "checkEX()" collects the source states for all states in the
%   region "f".
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEU

global GLOBAL_REV_TRANSITION

N = length(GLOBAL_REV_TRANSITION);
EXf = region(N,'false');
for i = 1:N
  % if state i is in region f, include all of its parents in EXf
  if isinregion(f,i)
    parents = GLOBAL_REV_TRANSITION{i};
    for j = 1:length(parents)
      EXf = set_state(EXf,parents(j),1);
    end
  end
end
return
