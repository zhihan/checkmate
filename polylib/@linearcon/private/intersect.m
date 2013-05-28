function CON = intersect(CONfeas,CONadd, varargin)
    
    h1 = CONfeas;
    h2 = CONadd;
    
    H.A = [h1.CI; h2.CI];
    H.B = [h1.dI; h2.dI];
    
    linstart = size(H.B,1) + 1;
    
    H.A = [H.A; h1.CE; h2.CE];
    H.B = [H.B; h1.dE; h2.dE];
    linend = size(H.B, 1);
    
    if (linend >= linstart)
        H.lin = linstart: linend;
    end
    
    h = cddmex('reduce_h', H);
    
    CE = h.A(h.lin,:);
    dE = h.B(h.lin,:);
    
    nonlin = setdiff(1:size(h.A,1), h.lin);
    CI = h.A(nonlin,:);
    dI = h.B(nonlin,:);
    CON = linearcon(CE,dE,CI,dI);
end
    
