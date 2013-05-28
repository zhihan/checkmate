function s = set_state(s,i,val)

% Method to modify a "region" object.
%
% Syntax:
%   "s = set_state(s,i,val)"
%
% Description:
%   A "region" object represents a subset of states in a finite-state
%   machine (FSM). A "region" object is implemented as a look-up truth table
%   whose k-th entry indicates whether the k-th state in the FSM belongs to
%   the region or not. This function sets the truth value of the "i"-th
%   state in the region "s" to "val" and returns resulting region object. If
%   "val" = 1, the "i"-th state is included in the region. If "val" = 0, the
%   "i"-th state is excluded from the region. The state index "i" must be
%   between 1 and "nstate" (the number of states in the FSM, see
%   below).
%
% Examples:
%   * "s = set_state(s,3,1)" includes the third state of the FSM in the
%     region "s".
%
%   * "s = set_state(s,3,0)" excludes the third state of the FSM in the
%     region "s".
%
% Implementation:
%
%   A region object consists of three fields listed below.
% 
%   * "nstate" Number of states in the FSM.
%
%   * "table" Truth table (array of integers) indicating the states in
%     the region 
%
%   * "wordsize" Number of bits in each integer in the truth table array
%
%   Each integer word in table contains the truth value (bits) for
%   "wordsize" states. Thus, the truth value for the k-th state in the FSM
%   can be found in the "rem(k,wordsize)"-th bit of the
%   "ceil(k/wordsize)"-th word in the table where "rem" and "ceil" are
%   standard MATLAB remainder and ceiling functions,
%   respectively. Currently, each word in the table is a "uint32" (unsigned
%   32-bit integer) and "wordsize" is set to 32.
%
% See Also:
%   region,isinregion,isuniverse,isempty,and,or,not

if (i < 1) || (i > s.nstate)
  error('State index must be between 1 to %d for this object.',s.nstate);
end

BIT_MAX = s.wordsize;
wordidx = ceil(i/BIT_MAX);
remainder = rem(i,BIT_MAX);
if remainder == 0
  s.table(wordidx) = double(bitset(s.table(wordidx),BIT_MAX,val));
else
  s.table(wordidx) = double(bitset(s.table(wordidx),remainder,val));
end
return
