function s = region(N,init)

% "region" class constructor.
%
% Syntax:
%   "s = region(N,init)"
%
% Description:
%   A "region" object represents a subset of states in a finite-state
%   machine (FSM). The "region" class constructor creates a "region" object
%   "s" given the number of the states in the FSM, "N", and the initialization
%   option, "init". A "region" object is implemented as a look-up truth
%   table whose k-th entry indicates whether the k-th state in the FSM
%   belongs to the region or not. There are three initialization
%   options.
%
%   * "'false'" Initialize the region to the empty set (no state is in the
%     region).
%
%   * "'true'" Initialize the region to the universe set (all states are in the
%     region).
%
%   * "[i1 i2 ... im]" Initialize the region to include the states given
%     by the list of indices.
% 
% Examples:
%   * "s = region(5,'true')" returns a region in an FSM with 5 states
%     containing all 5 states.
%
%   * "s = region(5,[1 3 4])" returns a region in an FSM with 5 states
%     containing only the first, third, and fourth states.
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
%   set_state,isinregion,isuniverse,isempty,and,or,not

BIT_MAX = 32;
if nargin == 0
  s.nstate = 0;
  s.wordsize = BIT_MAX;
  s.table = double(cm_false(0,BIT_MAX));
  s = class(s,'region');
else 
  s.nstate = N;
  s.wordsize = BIT_MAX;
  switch class(init)
    case 'char',
      switch init
	case 'true',
	  s.table = double(cm_true(N,BIT_MAX));
	case 'false',
	  s.table = double(cm_false(N,BIT_MAX));
	otherwise,
	  error('Unknown init option.')
      end
      s = class(s,'region');
    case 'double',
      s.table = double(cm_false(N,BIT_MAX));
      s = class(s,'region');
      for k = 1:length(init)
        s = set_state(s,init(k),1);
      end
    otherwise,
      error('Unknown init option.')
  end
end

% -----------------------------------------------------------------------------

function table = cm_true(N,BIT_MAX)

nwords = ceil(N/BIT_MAX);
table = uint32(zeros(nwords,1));
if nwords > 0
  for k = 1:nwords-1
    table(k) = bitcmp(0,BIT_MAX);
  end
  remainder = rem(N,BIT_MAX);
  if remainder > 0
    table(nwords) = bitcmp(0,remainder);
  else
    table(nwords) = bitcmp(0,BIT_MAX);
  end   
  return
end

% -----------------------------------------------------------------------------

function table = cm_false(N,BIT_MAX)

nwords = ceil(N/BIT_MAX);
table = uint32(zeros(nwords,1));
return
