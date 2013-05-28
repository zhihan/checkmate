function [CEnew, dEnew, CInew, dInew] = remove_implicit_linear(CE, dE, CI, dI)
% remove implicit linearity in the linear constraints
    
    m = size(dI,1);
    d = size(dE,1);

    H.A = [CI; CE];
    H.B = [dI; dE];
    H.lin = m+1: m+d;
    
    r = cddmex('implicit_linear',H);
    
    if ~isempty(r)
        selector = true(size(CI,1),1);
        selector(r) = false;
        CInew = CI(selector, :);
        dInew = dI(selector, :);
        
        Rimp = [CI(r, :) dI(r, :);
                CE dE];
        [R, jb] = rref(Rimp);
        Radd = Rimp(1:length(jb), :);
        CEnew = Radd(:,1:end-1);
        dEnew = Radd(:,end);
        
    else
        CInew = CI;
        dInew = dI;
        CEnew = CE;
        dEnew = dE;
    end
    
end