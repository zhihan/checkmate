function s = not(s)

% Compute complement of a region.
%
% Syntax:
%   "s2 = not(s1)" or "s2 = ~s1"
%
% Description 
%   Given a region "s1", the function returns the region "s2" which is the
%   set complement of "s1". 
%
% Examples:
%   * Suppose "s1 = region(5,[1 3 4])".
%
%   * "s2 = ~s1" returns a region "s2" of containing state 2 and 5.
%
% Implementation:
%   Perform bit-wise NOT operation on between look-up table of the input
%   region.
%
% See Also:
%   region,set_state,isinregion,isuniverse,isempty,and,or

N = s.nstate;
BIT_MAX = s.wordsize;
nword = ceil(N/BIT_MAX);
for idx = 1:nword-1
  s.table(idx) = bitcmp(s.table(idx),BIT_MAX);
end
remainder = rem(N,BIT_MAX);
if remainder == 0
  s.table(nword) = bitcmp(s.table(nword),BIT_MAX);
else
  s.table(nword) = bitcmp(s.table(nword),remainder);
end
return
