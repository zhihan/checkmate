function EfRg = checkER(f,g)

% Evaluate the `computation tree logic (CTL)` expression "E f R g". 
%
% Syntax:
%   "EfRg = checkER(f,g)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and the "region" objects "f" and "g", compute
%   the region corresponding to the CTL expression "E f R g".
%
% Implementation:
%   Use the CTL identity 
%
%   "E f R g = ~(A ~f U ~g)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkEU,checkEX

EfRg = ~checkAU(~f,~g);
return
