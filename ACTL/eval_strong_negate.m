function f = eval_strong_negate(node)
% EVAL_STRONG_NEGATE Evaluate strong negation of a given sparse tree
%
% Example 
%   f = eval_strong_negate(node)
%

global GLOBAL_AP

symbol = node.symbol;
production = node.production;
value = node.value;

switch symbol
  case 'sf',
    % evaluate state formula according to production type
    switch production,
      case 'not_ap',
	f = evaluate(node.value{2});  % evaluate it
      case 'ap',
	f = ~evaluate(node.value{1}); %evaluate its negation
      case 'AX',
	f = checkAX(eval_strong_negate(node.value{3}));
      case 'AF',
	f = checkAG(eval_strong_negate(node.value{3}));
      case 'AG',
	f = checkAF(eval_strong_negate(node.value{3}));
      case 'AU',
	f = checkAR(eval_strong_negate(node.value{2}), eval_strong_negate(node.value{4}));
      case 'AR',
	f = checkAU(eval_strong_negate(node.value{2}),eval_strong_negate(node.value{4}));
      case 'and',
	f = eval_strong_negate(node.value{1}) || eval_strong_negate(node.value{3});
      case 'or',
	f =  eval_strong_negate(node.value{1}) && eval_strong_negate(node.value{3});
      case 'parentheses',
	f =  eval_strong_negate(node.value{2});
      otherwise
	error('Unknown production type ''%s''.',production);
    end
  case 'ap',
    % evaluate atomic proposition
    if isfield(GLOBAL_AP,value)
      f = ~GLOBAL_AP.(value);
    else
      error('Unknown atomic proposition name ''%s''.',value);
    end
  otherwise,
    error('Unknown node symbol ''%s''.',symbol);
end
