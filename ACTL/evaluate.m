function f = evaluate(node)

% Evaluate the ACTL formula stored in the pare tree.
% 
% Syntax:
%   "f = evaluate(node)"
% 
% Description:
%   Given a parse tree "node" for an ACTL formula, compute the "region"
%   object corresponding to the ACTL formula.
%
% Implementation:
%   The "region" object for each atomic proposition is given as a field with
%   the same name as the atomic proposition in the global variable
%   "GLOBAL_AP". For example, the region corresponding to an atomic
%   proposition "p" can be obtained using "GLOBAL_AP.p".  Compute the
%   "region" object for each node with the symbols "sf" (state formula) and
%   "ap" (atomic proposition) in the parse tree recursively as follows. For
%   an "ap" node (base case), simply return the corresponding field in
%   "GLOBAL_AP". For an "sf" node (recursion), use the production in the
%   ACTL grammar to call the corresponding ACTL computation routine
%   "checkA*()" and "evaluate()" recursively. Possible productions for an
%   "sf" node, listed in the order of precedence, are
%
%   * `sf` --> "~"`ap`
%
%   * `sf` --> `ap`
%
%   * `sf` --> "AX" `sf`
%
%   * `sf` --> "AF" `sf`
%
%   * `sf` --> "AG" `sf`
%
%   * `sf` --> "A" `sf` "U" `sf`
%
%   * `sf` --> "A" `sf` "R" `sf`
%
%   * `sf` --> `sf` "&" `sf`
%
%   * `sf` --> `sf` "|" `sf`
%
%   * `sf` --> "(" `sf` ")"
%
% See Also:
%   parse,identerm,compile_ap,build_ap,model_check,piha,auto2xsys,
%   checkAF,checkAG,checkAR,checkAU,checkAX

global GLOBAL_AP

symbol = node.symbol;
production = node.production;
value = node.value;

switch symbol
  case 'sf',
    % evaluate state formula according to production type
    switch production,
      case 'not_ap',
	f = ~evaluate(node.value{2});
      case 'ap',
	f = evaluate(node.value{1});
      case 'AX',
	f = checkAX(evaluate(node.value{3}));
      case 'AF',
	f = checkAF(evaluate(node.value{3}));
      case 'AG',
	f = checkAG(evaluate(node.value{3}));
      case 'AU',
	f = checkAU(evaluate(node.value{2}),evaluate(node.value{4}));
      case 'AR',
	f = checkAR(evaluate(node.value{2}),evaluate(node.value{4}));
      case 'and',
	f = evaluate(node.value{1}) & evaluate(node.value{3});
      case 'or',
	f = evaluate(node.value{1}) | evaluate(node.value{3});
      case 'parentheses',
	f = evaluate(node.value{2});
      otherwise
	error('Unknown production type ''%s''.',production);
    end
  case 'ap',
    % evaluate atomic proposition
    if isfield(GLOBAL_AP,value)
        f = GLOBAL_AP.(value);
    else
        error('Unknown atomic proposition name ''%s''.',value);
    end
  otherwise,
    error('Unknown node symbol ''%s''.',symbol);
end
