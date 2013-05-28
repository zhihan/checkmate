function top_new = apply_production(top,idx,production)
% APPLY_PRODUCTION Apply production to sequence of symbol nodes. 
%
% Example:
%   top_new = apply_production(top,idx,production)
% 
% Replace the whole sequence of nodes by
% a single state formula node that contains this sequence of nodes in its
% value.

top_new = cell(1,idx-1);
for l = 1:idx-1
  top_new{l} = top{l};
end
top_new{idx}.symbol = production.var;
top_new{idx}.production = production.name;
top_new{idx}.value = {};
for l = idx:idx+length(production.rule)-1
  top_new{idx}.value{l-idx+1} = top{l};
end
for l = idx+length(production.rule):length(top)
  top_new{l-length(production.rule)+1} = top{l};
end
return

