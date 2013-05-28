function AfRg = checkAR(f,g)

% Evaluate the `computation tree logic (CTL)` expression "A f R g". 
%
% Syntax:
%   "AfRg = checkAR(f,g)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and the "region" objects "f" and "g", compute
%   the region corresponding to the CTL expression "A f R g".
%
% Implementation:
%   Use the CTL identity 
%
%   "A f R g = ~(E ~f U ~g)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEU,checkEX

AfRg = ~checkEU(~f,~g);
return
