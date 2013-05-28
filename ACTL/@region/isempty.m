function st = isempty(s)

% Check if a region of a finite-state machine is the empty set. 
%
% Syntax:
%   "st = isempty(s)"
%
% Description:
%   Returns 1 if the region "s" is empty, i.e. all bits in the look-up table
%   are 0, and returns 0 otherwise.
%
% See Also:
%   region,set_state,isinregion,isuniverse,and,or,not

st = 1;
N = s.nstate;
BIT_MAX = s.wordsize;
if N > 0
  nwords = ceil(N/BIT_MAX);
  for k = 1:nwords-1
    if bitcmp(0,BIT_MAX) && s.table(k)
      st = 0;
      return
    end
  end
  remainder = rem(N,BIT_MAX);
  if remainder > 0
    if bitcmp(0,remainder) && s.table(nwords)
      st = 0;
      return
    end
  else
    if bitcmp(0,BIT_MAX) && s.table(nwords)
      st = 0;
      return
    end
  end
end
return
