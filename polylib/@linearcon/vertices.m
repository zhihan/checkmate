function v = vertices(con,option)

% Convert a linear constraint object to a vertices object 
%
% Syntax:
%   "vtcs = vertices(con)"
%
% Description:
%   "vertices(con)" returns a new vertices object containing the vertices
%   of the linear constraint object "con". 
%
% Examples:
%   Given the linear constraint object "con" representing a cube with
%   corners at (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2),
%   (4,3,0), (4,3,2), (4,1,0), and (4,1,2),
%
%
%
%     "vtcs = vertices(con)"
%
%
%
%   returns "vtcs", a vertices object containing the list of triples
%   given above.
%
% See Also:
%   linearcon,vertices

CE = con.CE; dE = con.dE;
CI = con.CI; dI = con.dI;
if nargin ==1
    if length(dE)==1
        option=1;
    else
        option=1;
    end
end
v = [];

if isempty(CI) 
    return
end

switch option
    case 0
        n_total = size(CI,2);
        n_free = n_total-length(dE);
        
        if length(dI)>=n_free
            
            COMBO = nchoosek([1:length(dI)],n_free);
            
            for i = 1:size(COMBO,1)
                C = CE; d = dE;
                %        for j = 1:length(COMBO(i,:))
                C = [C; CI(COMBO(i,:),:)];
                d = [d; dI(COMBO(i,:),:)];
               %        end
                if rank(C) == n_total   
                    vi = C\d;
                    if feasible_point(con,vi)
                        v = [v  vi];
                    end
                end
            end
            v = vertices(v);
        else
            v=[];
        end
    case 1  % use cddmex
       H=struct('A',[CE;CI],'B',[dE;dI],'lin',(1:size(dE,1))');
       V = cddmex('extreme',H);
       v = vertices(V.V');

end

return

