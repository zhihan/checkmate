function Tr = revtran(T)

% Compute the `reverse` transition system for the given transition system.
% 
% Syntax:
%   "Tr = revtran(T)"
%
% Description:
%   A `transition system` is represented by a cell array with each element
%  in the cell array corresponding to a state in the transition system. In
%   the input transition system "T", "T{k}" is a vector of indices to
%   destination states. A `reverse` transition system is computed by
%   swapping the source and the destination for each transition,
%   i.e. reversing all the arrows in the original transition system.
%
% See Also:
%   auto2xsys,region

% Compute the reverse transitions of T
Tr = cell(size(T));
for i = 1:length(T)
  Ti = T{i};
  % In the reverse transtion syste, include state i in the destinations
  % for every one of its destination in the original transition system.
  for j = 1:length(Ti)
    Tr{Ti(j)} = [Tr{Ti(j)} i];
  end
end
