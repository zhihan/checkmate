function [C,d] = cell_ineq(boundary,hpflags)
% CELL_INEQ returns the inequality constaints of a certain cell
%
% Example 
% [C,d] = cell_ineq(boundary,hpflags)
%
%
global GLOBAL_PIHA

hyperplanes = GLOBAL_PIHA.Hyperplanes;

%This function was changed to reflect the fact that 'hpflags' 
% is no longer the same length as HYPERPLANES,
%rather it is the length of 'boundary' and each element relates 
% to the side of the hp which makes up the
%boundary
%
% Last change: 11/18/2002 JPK

m = length(boundary);

% assert(m > 0);
n = size(hyperplanes{boundary(1)}.c, 2);

C = zeros(m,n); 
d = zeros(m,1);

for k = 1:length(boundary)
  if hpflags(k)
    C(k,:) = hyperplanes{boundary(k)}.c;
    d(k) =  hyperplanes{boundary(k)}.d;
  else
    C(k,:) =  -hyperplanes{boundary(k)}.c;
    d(k) =  -hyperplanes{boundary(k)}.d;
  end
end

