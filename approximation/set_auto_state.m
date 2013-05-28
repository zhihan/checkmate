function set_auto_state(whichauto,st,param)

% Set a parameter of the specified state in the specified `approximating
% automaton`.
%
% Syntax:
%   "set_auto_state(whichauto,st,param,val)"
%
% Description:
%   The inputs to this function are
%
%   * "whichauto": specify whether the current automaton
%     ("GLOBAL_AUTOMATON") or the new automaton ("GLOBAL_NEW_AUTOMATON")
%     should be accessed.  The new automaton is the automaton resulting from
%     the refinement of the current automaton. Possible values are "'current'"
%     and "'new'".
%
%   * "st": state index. A state index is a row vector of length 2 or 3. An
%     `initial state` has an index of the form "[l s]" where "l" is the
%     `location` number and "s" is the `state` number. A `face state` has an
%     idex of the form "[l f s]" where "l" is the `location` number, "f" is
%     the `face` number, and "s" is the `state` number.
%
%   * "param": string specifying the parameter field to be set (see comments
%     in "iauto_part.m" for the complete list of parameters for each automaton
%     state).
%
%   * "val": the value for the parameter to be set
%
% Example:
%   * "set_auto_state('current',[1 2 3],'polytope',P)" assigns the "linearcon"
%   object "P" as the polytope associated with state 3 on face 2 of the
%   invariant polytope in location 1.
%
% See Also:
%   get_auto_state,iauto_part,iauto_build

switch whichauto
case 'current'
  eval_str = 'GLOBAL_AUTOMATON';
case 'new'
  eval_str = 'GLOBAL_NEW_AUTOMATON';
otherwise
  error('CheckMate:SetState:Unknown', ...
      ['Unknown choice of approximating automaton ''' whichauto '''.'])
end

if length(st) == 2
  eval_str = [eval_str '{st(1)}.initstate{st(2)}'];
else
  eval_str = [eval_str '{st(1)}.face{st(2)}.state{st(3)}'];
end
eval_str = [eval_str '.' param ' = val;'];
eval(eval_str)
return
