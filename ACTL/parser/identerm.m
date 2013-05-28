function terminal = identerm(str)

% Identify `terminal symbols` to be parsed by the ACTL parser.
%
% Example
%   terminal = identerm(str)
%
% Description:
%   Indentify the `terminal symbols` for the ACTL `grammar` in the input
%   string "str" and create the ouput cell array "terminal" of the
%   terminal symbols. There are 3 types of terminal symbols in our
%   implementation of the ACTL grammar
%
%   * `single characters`: "'~'","'&'","'|'","'('","')'","'X'","'F'",
%     "'G'","'U'","'R'","'A'"
%
%   * `equal sign`: "'=='"
%
%   * `name`: a string starting with a LOWERCASE alphabet followed by
%     LOWERCASE alphabets, numbers ("'1'", ..., "'9'"), or underscores
%     ('"_"').
%
%   Each terminal symbol in the output cell array is a structure with the
%   following fields
%
%   * "symbol", one of the single character symbols, "'=='", or "'name'".
%
%   * "production", the `production` in the ACTL grammar to be applied (see
%     help on function "parse.m"). This field is set to "'none'" for all
%     terminal symbols.
%
%   * "value". For `single charater` and `equal sign` symbols, this field
%     has the same value as the field "symbol". For the `name` symbols,
%     this field contains actual the name string for the symbol.
%
% See Also:
%   parse,compile_ap,build_ap,evaluate,model_check


SPECIAL_CHARACTERS = {'~','&','|','(',')','X','F','G','U','R','A'};

% Implement the terminal identifier as a state machine.

SINGLE_CHARACTER  = 0;
NAME_ENTER        = 1;
NAME_DURING       = 2;
EQUAL_ENTER       = 4;
EQUAL_EXIT        = 5;

state = SINGLE_CHARACTER;
idx = 1;
terminal = {};

while (idx <= length(str))
    ch = str(idx);

    % parser state transition
    switch state
        case {SINGLE_CHARACTER,EQUAL_EXIT}
            if islowercase(ch)
                state = NAME_ENTER;
            elseif ch == '=';
                state = EQUAL_ENTER;
            elseif ~(isspace(ch) || ismember(ch,SPECIAL_CHARACTERS))
                error([error_header(str,idx) 'Invalid character.'])
            else
                state = SINGLE_CHARACTER;
            end
        case {NAME_ENTER,NAME_DURING}
            if ismember(ch,SPECIAL_CHARACTERS) || isspace(ch)
                state = SINGLE_CHARACTER;
            elseif ch == '=';
                state = EQUAL_ENTER;
            elseif islowercase(ch) || isnumber(ch) || (ch == '_')
                state = NAME_DURING;
            else
                error([error_header(str,idx) ...
                    'Invalid identifier name.']);
            end
        case EQUAL_ENTER
            if (ch == '=')
                state = EQUAL_EXIT;
            else
                error([error_header(str,idx) '= must be followed by another =.']);
            end
        otherwise
            error('Unknown parse state.')
    end

    
    switch state
        case SINGLE_CHARACTER
            if ~isspace(ch)
                terminal{end+1} = create_terminal(ch,ch); %#ok
            end
        case NAME_ENTER
            terminal{end+1} = create_terminal('name',ch); %#ok
        case NAME_DURING
            terminal{end}.value = [terminal{end}.value ch]; %#ok
        case EQUAL_EXIT
            terminal{end+1} = create_terminal('==','=='); %#ok
    end

    idx = idx + 1;
end

if state == EQUAL_ENTER
    error([error_header(str,idx-1) ...
        'Unfinished ''==''.']);
end


% -----------------------------------------------------------------------------

function terminal = create_terminal(symbol,value)
% This routine creates a terminal symbol node

terminal.symbol = symbol;
terminal.production = 'none';
terminal.value = value;

% -----------------------------------------------------------------------------

function st = islowercase(ch)
st = ('a' <= ch) & (ch <= 'z');

% -----------------------------------------------------------------------------

function st = isnumber(ch)

st = ('0' <= ch) & (ch <= '9');

% -----------------------------------------------------------------------------

function header = error_header(str,idx)

l1 = sprintf('%s...\n',str(1:idx));
l2 = sprintf('%s|\n',blanks(idx-1));
header = [l1 l2];

