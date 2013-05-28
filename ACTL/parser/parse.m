function top = parse(top)

% Parse the cell array of terminal symbols into a tree using ACTL grammar
% in `positive normal form`.
%
% Syntax:
%   "top = parse(top)"
%
% Description:
%   Parse the ACTL expression specified by the string (cell array) of
%   terminal symbols in "top" and return the parse tree in "top" if the
%   parsing is successful. The productions in the positive normal form ACTL
%   grammar are listed, in order of precedence, below.
%
%   * `ap` --> `name` "==" `name`
%
%   * `ap` --> `name`
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
%   where `ap` and `sf` are the variables for an `atomic proposition` and
%   a `state formula`, respectively. Note that in the positive normal
%   form ACTL, only universal path quatifier A is allowed and negations
%   must be applied directly to atomic propositions.
%
% Implementation:
%   The parsing is done iteratively in a `bottom-up` manner. In each
%   iteration, the function "parse()" searches for the highest precedence
%   production rule that could be applied to a sequence of the top level
%   nodes in the parse tree. If a valid production is found, that
%   sequence of top level nodes is replaced by a single node with the
%   nodes in the production sequence as its children. The parsing
%   continues until a single node remains at the top level. If a valid
%   production cannot be found, the `key symbols`, one of which is
%   assigned to each production, are used to issue the error message
%   suggesting a specific production rule that is violated.
%
% See Also:
%   identerm,compile_ap,build_ap,evaluate,model_check

global PRODUCTION

PRODUCTION = {};
% Define productions for the positive normal form grammar of ACTL 
% in order of precedence. In positive normal form ACTL, only universal 
% path quatifier A is allowed and negations must be applied directly 
% to atomic propositions.

% ap --> name == name
create_production('fsmap', 'ap', {}, {'name' '==' 'name'})
% ap --> name
create_production('polyap', 'ap', {}, {'name'})
% sf --> ~ap
create_production('not_ap', 'sf', {'~'}, {'~' 'ap'});
% sf --> ap
create_production('ap', 'sf', {}, {'ap'});
% sf --> AX sf
create_production('AX', 'sf', {'X'}, {'A' 'X' 'sf'});
% sf --> AF sf
create_production('AF', 'sf', {'F'}, {'A' 'F' 'sf'});
% sf --> AG sf
create_production('AG', 'sf', {'G'}, {'A' 'G' 'sf'});
% sf --> A sf U sf
create_production('AU', 'sf', {'U'}, {'A' 'sf' 'U' 'sf'});
% sf --> A sf R sf
create_production('AR', 'sf', {'R'}, {'A' 'sf' 'R' 'sf'});
% sf --> sf & sf
create_production('and', 'sf', {'&'}, {'sf' '&' 'sf'});
% sf --> sf | sf
create_production('or', 'sf', {'|'}, {'sf' '|' 'sf'});
% sf --> ( sf )
create_production('parentheses', 'sf', {'(',')'}, {'(' 'sf' ')'});

% Parse the cell array of terminals in top from bottom up. Successful
% parsing of ACTL expression should yield a single symbol node in the cell
% array top. A symbol node represents a terminal or a variable symbol. For
% our implementation of ACTL, we have the following terminals
%
%     ( ) ~ & | X F G U R A == name
%
% where name is a name string described in the m-file identerm.m. The
% variables are ap (atomic proposition) and sf (state formula).
%
% A symbol for a path formula is not needed since we combine path formulae
% into production for AX, AF, AG, AU, and AR.  Each symbol node in the parse
% tree has the following format.
%
%     node.symbol     : type name of terminal or variable symbols (string)
%     node.production : name of production that is used to obtain the
%                       symbol's value (next field). valid only for state
%                       formula symbol
%     node.value      : cell array of symbol nodes comprising the current
%                       symbol value

DEBUG = 0;
if DEBUG
  print_nodes(top)
end
production_found = 1;
while (length(top) > 1) || production_found
  % Search for the highest precedence production that can be applied.
  production_found = 0;
  k = 1;
  while (k <= length(PRODUCTION)) && ~production_found
    [production_found,idx] = match_production(top,PRODUCTION{k}.rule);
    if ~production_found
      k = k + 1;
    end
  end
  
  if production_found
    % If a matching production is found, apply the production rule to 
    % replace the sequence of nodes by a node representing a
    % state formula.
    top = apply_production(top,idx,PRODUCTION{k});
  else
    if length(top) > 1
      % If no matching production is found, find the production with the
      % highest precedence such that one of its key symbols is present
      % in the sequence of top nodes.
      k = 1;
      while (k <= length(PRODUCTION)) && ~find_key_symbol(top,PRODUCTION{k}.key_symbol)

        k = k + 1;
      end
      % If a production with a key symbol present in top is found
      % display its production rule in the syntax error message.
      % Otherwise, signify an unknown syntax error.
      if (k <= length(PRODUCTION))
        errmsg = sprintf('The following rule is violated:\n');
        errmsg = [errmsg PRODUCTION{k}.rule{1}]; %#ok
        for l = 2:length(PRODUCTION{k}.rule)
          errmsg = [errmsg ' ' PRODUCTION{k}.rule{l}]; %#ok
        end
        error(errmsg)
      else
        error('Unknown syntax error.')
      end
    end
  end
  if DEBUG
    print_nodes(top)
  end
end
top = top{1};
return

% -----------------------------------------------------------------------------
