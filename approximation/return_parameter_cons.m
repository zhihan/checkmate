function Pcon = return_parameter_cons()

% Get the parameter constraints for the given `location`.
%
% Syntax:
%   "Pcon = location_invariant(srcloc)"
%
% Description:
%   Return the "linearcon" object representing the parameter constraints for
%   the `location` specified by the "srcloc".
%
% See Also:
%   piha,linearcon

% 02/06/02 Ansgar
% At this stage the function returns a global constraint independant from 
% the location; this might be changed in the future

global GLOBAL_PIHA


C = []; d  = [];
CE= []; dE = [];


for i= 1:length(GLOBAL_PIHA.SCSBlocks)
    if GLOBAL_PIHA.SCSBlocks{i}.paradim>0
    PaCs = GLOBAL_PIHA.SCSBlocks{i}.pacs;
    [CEi,dEi,Ci,di] = linearcon_data(PaCs);

    [CE_length,CE_width]=size(CE);
    [C_length,C_width]=size(C);
    [CEi_length,CEi_width]=size(CEi);
    [Ci_length,Ci_width]=size(Ci);
    
    CE=[CE   zeros(CE_length,CEi_width);
        zeros(CEi_length,CE_width)  CEi];
    dE=[dE;dEi];

    C= [C   zeros(C_length,Ci_width);
        zeros(Ci_length,C_width)  Ci];
    d= [d;di];
    end;
end;
Pcon = linearcon(CE,dE,C,d);

return
