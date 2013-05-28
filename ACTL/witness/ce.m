function [q,t]=ce(ACTLspec)
% CE generate a counterexample for a given ACTL spec
%
% Example
%    [q, t] = ce(ACTLspec);



global GLOBAL_SPEC_TREE;
global GLOBAL_AP_BUILD_LIST;

match_paren(ACTLspec,0);
GLOBAL_SPEC_TREE = parse(identerm(ACTLspec));
[GLOBAL_SPEC_TREE,GLOBAL_AP_BUILD_LIST] = ...
    compile_ap(GLOBAL_SPEC_TREE);
[q,t] = witgraph(GLOBAL_SPEC_TREE,1);