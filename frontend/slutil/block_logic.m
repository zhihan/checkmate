function expression = block_logic(block,sfiptype)

% Find the logical expression at a block output 
%
% Syntax:
%   "expression = block_logic(block,sfiptype)"
%
% Description:
%   "block_logic(block,sfiptype)" returns the logical expression at the
%   output of CheckMate block "block".  "sfiptype" tells what type of
%   Stateflow input is fed by "block"'s output.
%
% Note:
%   In CheckMate, event inputs to Stateflow blocks must consist solely of
%   logical combinations of polyhedral threshold block (PTHB) outputs.
%
% See Also:
%   sf_input_expression


type = check_block_type(block);
switch type
case 'PolyhedralThreshold',
  expression = get_param(block,'Name');
case 'Stateflow',
  if ~strcmp(sfiptype,'data')
    errmsg = ['Invalid block "' get_param(block,'Name') '" found.' ...
              sprintf('\n') ...
              'Stateflow blocks not allowed in path to any event input.'];
    error(errmsg)
  end
  expression = get_param(block,'Name');
case 'Constant',
  if ~strcmp(sfiptype,'data')
    errmsg = ['Invalid block "' get_param(block,'Name') '" found.' ...
              sprintf('\n') ...
              'Constant blocks are not allowed in path to any event input.'];
    error(errmsg)
  end
  expression = get_param(block,'Value');
case {'AND','OR'},
  expression = and_or_term(block,type,sfiptype);
case 'NAND',
  expression = and_or_term(block,'AND',sfiptype);
  expression = ['~' expression];
case 'NOR',
  expression = and_or_term(block,'OR',sfiptype);
  expression = ['~' expression];
case 'NOT',
	src = find_src_port(block,num2str(1));
	expression = block_logic(src.block,sfiptype);
  expression = ['~' expression];
case 'XOR',
  expression = xor_term(block,sfiptype);
case 'RelationalOperator',
  if ~strcmp(sfiptype,'data')
    errmsg = ['Invalid block "' get_param(block,'Name') '" found.' ...
              sprintf('\n') ...
              'Relational operators not allowed in path to any event input.'];
    error(errmsg)
  end
  op = get_param(block,'Operator');
  src1 = find_src_port(block,'1');
  src2 = find_src_port(block,'2');
  expression = ['(' block_logic(src1.block,sfiptype) ' ' op ' ' ...
                    block_logic(src2.block,sfiptype) ')'];
otherwise,
  error(sprintf('Invalid block "%s" found.',get_param(block,'Name')))
end

return


% -----------------------------------------------------------------------------

function type = check_block_type(block)

BlockType = get_param(block,'BlockType');
switch BlockType
case 'SubSystem',
  MaskType = get_param(block,'MaskType');
  switch MaskType
  case {'Stateflow','PolyhedralThreshold'}
    type = MaskType;
  otherwise,
    type = '';
  end
case 'Logic',
  type = get_param(block,'Operator');
case {'RelationalOperator','Constant'}
  type = BlockType;
otherwise,
  type = '';
end
return

% -----------------------------------------------------------------------------

function expression = and_or_term(block,term_type,sfiptype)

switch term_type,
case 'AND'
  op = ' & ';
case 'OR'
  op = ' | ';
end

n = eval(get_param(block,'Inputs'));
src = find_src_port(block,num2str(1));
expression = block_logic(src.block,sfiptype);
for k = 2:n
  src = find_src_port(block,num2str(k));
  expression = [expression op block_logic(src.block,sfiptype)];
end
expression = ['(' expression ')'];

return

% -----------------------------------------------------------------------------

function expression = xor_term(block,sfiptype)

n = eval(get_param(block,'Inputs'));
src = find_src_port(block,num2str(1));
expression = block_logic(src.block,sfiptype);
for k = 2:n
  src = find_src_port(block,num2str(k));
  expression = ['xor(' expression ',' block_logic(src.block,sfiptype) ')'];
end

return
