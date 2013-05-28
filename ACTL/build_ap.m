function atomic_propositions = build_ap(ap_build_list)

% Build regions corresponding to the atomic propositions specified in the
% input list.
% 
% Syntax:
%   "build_ap(ap_build_list)"
% 
% Description:
%   Builds "region" objects for the atomic propositions specified in the
%   input list "ap_build_list", which is a cell array. 
%
% Implementation:
%   Each element of "ap_build_list" is a structure with the following
%   fields.
%
%   * "name", the name of the atomic proposition. For a `polyhedral
%     threshold atomic proposition (PTHAP)`, this is the name of the
%     corresponding PTHB. For a `finite-state machine atomic proposition`
%     (FSMAP) of the form "<FSMB> == <state>", the name is
%     "<FSMB>_in_<state>". For example, the FSMAP "switch == on" will
%     be named "switch_in_on".
%
%   * "build_info". This is the field that is used to specify the type
%     of each atomic proposition. For a PTHAP, "build_info" is simply
%     "'polyap'". For an FSMAP, "build_info" is a cell array of the form
%     "{'fsmap' fsmname statename}". For example, "build_info" for the
%     FSMAP "switch == on" is "{'fsmap' 'switch' 'on'}".
%
%   A "region" object is computed for each atomic proposition as
%   follows. For a PTHAP, include all states such that the "pthflags" for
%   cell of the parent location is true for the corresponding PTHB. There
%   are 4 special atomic propositions which have the same form as a PTHAP,
%   namely "null_event", "time_limit", "out_of_bound", and
%   "indeterminate". For each of these atomic propositions, the
%   corresponding special terminal states in all locations are included in
%   the "region" object. For an FSMAP, include all states such that the FSM
%   state of the parent location indicates that the FSMB specified in the
%   FSMAP is in the state specified in the FSMAP. See help on "piha.m" for
%   more information of the data structure of `locations` in the PIHA. See
%   help on "auto2xsys.m" for the correspondence between states in
%   "GLOBAL_AUTOMATON" and states in "GLOBAL_TRANSITION".
%
%
%
%   Put the "region" computed for each atomic proposition in the field with
%   the same name as the atomic proposition in the output variable
%   "atomic_propositions". For example, the region corresponding to an FSMAP
%   named "switch_in_on" is stored in "atomic_propositions.switch_in_on".
%
% See Also:
%   parse,identerm,compile_ap,evaluate,model_check,piha,auto2xsys


atomic_propositions = [];
for k = 1:length(ap_build_list)
  switch ap_build_list{k}.build_info{1}
    case 'polyap',
      temp = build_poly_ap(ap_build_list{k}.name);
    case 'fsmap',
      fsmname = ap_build_list{k}.build_info{2};
      statename = ap_build_list{k}.build_info{3};
      temp = build_fsm_ap(fsmname,statename);
    otherwise
      error(['Invalid atomic proposition type ''' ap_build_list{k}.build_info{1} '''.'])
  end
  atomic_propositions.(ap_build_list{k}.name) = temp;
end



