function yesno = feasible(CE, dE, CI, dI)
    m = size(CI,1);
    d = size(CE,1);
    
    H.A = [CI; CE];
    H.B = [dI; dE];
    H.lin = m+1:m+d;
    
    p = cddmex('find_interior', H);
    
    if p.objlp >= -1e-5
        yesno = true;
    else 
        yesno = false;
    end
end