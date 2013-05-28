function create_production(name,var,key_symbol,rule)

global PRODUCTION

% Each production LHS --> RHS has the following structure:
%   PRODUCTION{i}.name       : production identifier
%   PRODUCTION{i}.var        : LHS variable
%   PRODUCTION{i}.key_symbol : Key symbols to look for if error occurs
%   PRODUCTION{i}.rule       : RHS string of variables and terminals
new = length(PRODUCTION)+1;
PRODUCTION{new}.name = name;
PRODUCTION{new}.var = var;
PRODUCTION{new}.key_symbol = key_symbol;
PRODUCTION{new}.rule = rule;
return

% -----------------------------------------------------------------------------
