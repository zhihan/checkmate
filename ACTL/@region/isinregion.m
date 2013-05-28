function st = isinregion(s,i)

% Check if the specified state is in the region.
%
% Syntax:
%   "st = isinregion(s,i)"
%
% Description:
%   Returns 1 if the state specified by the index "i" is in the region
%   "s" and returns 0 otherwise.
%
% Examples:
%   * Suppose a region "s" is defined by "s = region(5,[1 3 4])".
%
%   * "isinregion(s,4)" returns 1.
%
%   * "isinregion(s,2)" returns 0.
%
% See Also:
%   region,set_state,isuniverse,isempty,and,or,not

if (i < 1) || (i > s.nstate)
  error('State index must be between 1 to %d for this object.',s.nstate);
end

BIT_MAX = s.wordsize;
wordidx = ceil(i/BIT_MAX);
remainder = rem(i,BIT_MAX);
if remainder == 0
  st = bitget(double(s.table(wordidx)),BIT_MAX);
else
  st = bitget(double(s.table(wordidx)),remainder);
end
return
