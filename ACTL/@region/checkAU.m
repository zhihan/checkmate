function AfUg = checkAU(f,g)

% Evaluate the `computation tree logic (CTL)` expression "A f U g". 
%
% Syntax:
%   "AfUg = checkAU(f,g)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables "GLOBAL_TRANSITION" and
%   "GLOBAL_REV_TRANSITION" and the "region" objects "f" and "g", compute
%   the region corresponding to the CTL expression "A f U g".
%
% Implementation:
%   Use the CTL identity 
%
%   "A f U g = ~(E ~g U (~f & ~g)) & ~(EG ~g)"
%
% See Also:
%   region,auto2xsys,reach,findSCCf,checkAF,checkAG,checkAR,checkAX,
%   checkEF,checkEG,checkER,checkEU,checkEX

AfUg = ~checkEU(~g,~f & ~g) & ~checkEG(~g);
return
