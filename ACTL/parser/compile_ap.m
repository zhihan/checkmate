function [tree,ap_build_list] = compile_ap(tree)

% Compile the list of atomic propositions present in the parse tree
% obtained from the function "parse()".
%
% Example:
%   [tree,ap_build_list] = compile_ap(tree)
% 
% Description:
%   The list of atomic propositions found in the parse tree is compiled
%   so that "region" objects corresponding to the atomic propositions can
%   be constructed later. "compile_ap()" also replaces each `ap` subtree
%   in the parse tree by a single `ap` leaf node.
% 
% Implementation:
%   For the atomic proposition founds in the parse tree, "compile_ap()"
%   collects the information nesscessary to build the corresponding "region"
%   object in the output cell array "ap_build_list". Each element of
%   "ap_build_list" is a structure with the following fields.
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
%   The output variables "tree" (with the `ap` subtrees replaced by a single
%   leaf) and "ap_build_list" are used subsequently by the function
%   "build_ap()".
%
% See Also:
%   parse,identerm,build_ap,evaluate,model_check

global AP_NAME AP_BUILD_INFO

AP_NAME = {};
AP_BUILD_INFO = {};
% Depth first search on parse tree for all atomic propositions
tree = visit(tree);

ap_build_list = cell(1,length(AP_NAME));
for k = 1:length(AP_NAME)
  ap_build_list{k}.name = AP_NAME{k};
  ap_build_list{k}.build_info = AP_BUILD_INFO{k};
end
