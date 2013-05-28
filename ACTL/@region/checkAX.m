function AXf = checkAX(f)

% Evaluate the `computation tree logic (CTL)` expression "AX f". 
%
% Syntax:
%   "AXf = checkAX(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and a "region" object "f", compute the region
%   corresponding to the CTL expression "AX f".
%
% Implementation:
%   Use the CTL identity 
%
%   "AX f = ~(EX ~f)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,
%   checkEF,checkEG,checkER,checkEU,checkEX

AXf = ~checkEX(~f);
return
