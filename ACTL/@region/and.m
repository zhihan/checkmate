function a = and(a,b)

% Compute the intersection between two regions.
%
% Syntax:
%   "s3 = and(s1,s2)" or "s3 = s1 & s2" 
%
% Description:
%   Given two regions "s1" and "s2", the function returns the region "s3"
%   which is the intersection between "s1" and "s2".
%
% Examples:
%   * Suppose "s1 = region(5,[1 3 4])" and "s2 = region(5,[2 4])".
%
%   * "s3 = s1 & s2" returns a region "s3" containing only state 4.
%
% Implementation:
%   Perform bit-wise AND operation between the look-up table from the two
%   regions. The input regions  must have the same number of states and
%   same word size for the look-up table, otherwise, the function will
%   issue an error message.
%
% See Also:
%   region,set_state,isinregion,isuniverse,isempty,or,not

% Check compatibility between two region objects
if (a.nstate == b.nstate) && (a.wordsize == b.wordsize)
  N = a.nstate;
  BIT_MAX = b.wordsize;
  nword = ceil(N/BIT_MAX);
  for idx = 1:nword
    a.table(idx) = bitand(a.table(idx),b.table(idx));
  end   
else
  error('Incompatible region objects given.')
end
return
