function [q,t]=witgraph(node,qw)
% WITGRAPH - construct a witness sub-graph of the node
%
%  [q,t]=witgraph(node,qw)
% Given an ACTL formula, find the counterexample graph
%
%
%
% Created by Zhi Han on 10-16-2003 
% derived from the evaluate function 

global GLOBAL_AP

symbol = node.symbol;
production = node.production;
value = node.value;
q = [];
t = [];
switch symbol
  case 'sf',
    % evaluate state formula according to production type
    switch production,
      case 'not_ap',
        q = qw;
      case 'ap',
        q = qw;
      case 'AX',
	[q,t] = witAX(node,qw);
      case 'AF',
	[q,t] = witAF(node,qw);
      case 'AG',
	[q,t] = witAG(node,qw);
      case 'AU',
        [q,t] = witAU(node, qw);
      case 'AR',
	[q,t]= witAR(node,qw);
      case 'and',
	error('Cannot generate Witness for logic expressions');
      case 'or',
	error('Cannot generate Witness for logic expressions');
      case 'parentheses',
	[q,t] = witgraph(node.value{2},qw);
      otherwise
	error('Unknown production type ''%s''.',production);
    end
  case 'ap',
    % evaluate atomic proposition
    if isfield(GLOBAL_AP,value)
        q = qw;
    else
      error('Unknown atomic proposition name ''%s''.',value);
    end
  otherwise,
    error('Unknown node symbol ''%s''.',symbol);
end
