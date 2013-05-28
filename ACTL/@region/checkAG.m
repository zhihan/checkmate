function AGf = checkAG(f)

% Evaluate the `computation tree logic (CTL)` expression "AG f". 
%
% Syntax:
%   "AGf = checkAG(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and a "region" object "f", compute the region
%   corresponding to the CTL expression "AG f".
%
% Implementation:
%   Use the CTL identity 
%
%   "AG f = ~(EF ~f)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,
%   checkEF,checkEG,checkER,checkEU,checkEX

AGf = ~checkEF(~f);
return
