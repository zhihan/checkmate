function a = or(a,b)

% Compute the union of two regions.
%
% Syntax:
%   "s3 = or(s1,s2)" or "s3 = s1 | s2"
%
% Description:
%   Given two regions "s1" and "s2", the function returns the region "s3"
%   which is the union of "s1" and "s2".
%
% Examples:
%   * Suppose "s1 = region(5,[2 5])" and "s2 = region(5,[4])".
%
%   * "s3 = s1 | s2" returns a region "s3" containing states 2, 4, and 5.
%
% Implementation:
%   Perform bit-wise OR operation between the look-up table from the two
%   regions. The input regions must have the same number of states and
%   same word size for the look-up table, otherwise, the function will
%   issue an error message.
%
% See Also:
%   region,set_state,isinregion,isuniverse,isempty,and,not

% Check compatibility between two region objects
if (a.nstate == b.nstate) && (a.wordsize == b.wordsize)
  N = a.nstate;
  BIT_MAX = b.wordsize;
  nword = ceil(N/BIT_MAX);
  for idx = 1:nword
    a.table(idx) = bitor(a.table(idx),b.table(idx));
  end   
elseif isempty(a)&& ~isempty(b)
    a=b;
elseif isempty(b)&& ~isempty(a)
    % empty
elseif isempty(a)&&isempty(b)
    a=region;
else
  error('Incompatible region objects given.')
end
return
