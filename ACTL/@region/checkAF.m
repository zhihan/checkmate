function AFf = checkAF(f)

% Evaluate the `computation tree logic (CTL)` expression "AF f". 
%
% Syntax:
%   "AFf = checkAF(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and a "region" object "f", compute the region
%   corresponding to the CTL expression "AF f".
%
% Implementation:
%   Use the CTL identity 
%
%   "AF f = ~(EG ~f)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEU,checkEX

AFf = ~checkEG(~f);
return
