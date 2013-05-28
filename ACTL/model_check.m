function spec = model_check(ACTLspec)

% Perform `model checking` on the global transition system given the
% specification.
%
% Syntax:
%   "spec = model_check(ACTLspec)"
% 
% Description:
%   Given the input string "ACTLspec" containing the ACTL
%   specification. Parse the specification according to the ACTL grammar
%   into a parse tree and evaluate the specification using the ACTL model
%   checking routines "checkA*()". Return the set of states in the global
%   transition system "GLOBAL_TRANSITION" that satisfies the ACTL
%   specification in the "region" object "spec".
%
% See Also:
%   match_paren,identerm,parse,compile_ap,build_ap,evaluate,
%   checkAF,checkAG,checkAR,checkAU,checkAX

global GLOBAL_SPEC_TREE
global GLOBAL_AP_BUILD_LIST

% match parentheses
match_paren(ACTLspec,0);
% identify terminal symbols in the ACTL specification string and
% parse the symbols to obtain parse tree for the specification
GLOBAL_SPEC_TREE = parse(identerm(ACTLspec));
[GLOBAL_SPEC_TREE,GLOBAL_AP_BUILD_LIST] = ...
    compile_ap(GLOBAL_SPEC_TREE);
spec = evaluate(GLOBAL_SPEC_TREE);

