function v = vertices(a) 

    if nargin == 0
        v.list = [];
    elseif isa(a,'vertices')
        v.list = a.list;
    elseif isa(a,'double')
        v.list = a;
    end
    v = class(v, 'vertices');
end
