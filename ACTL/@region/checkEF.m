function EFf = checkEF(f)

% Evaluate the `computation tree logic (CTL)` expression "EF f". 
%
% Syntax:
%   "EFf = checkEF(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and a "region" object "f", compute the region
%   corresponding to the CTL expression "EF f".
%
% Implementation:
%   Use the CTL identity 
%
%   "EF f = E true U f"
%
%   where "true" is the set of all states in the global transition system.
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEG,checkER,checkEU,checkEX

global GLOBAL_REV_TRANSITION

true = region(length(GLOBAL_REV_TRANSITION),'true');
EFf = checkEU(true,f);
return
