function st = check_model_syntax(sys)

% Check syntax of a CheckMate model
%
% Syntax:
%   "st = check_model_syntax(sys)"
%
% Description:
%   "check_model_syntax(sys)" returns "1" if "sys" conforms to proper
%   CheckMate syntax, otherwise, "check_model_syntax(sys)" returns "0".
%
% Note:
%   Currently, proper CheckMate syntax requires that the names of
%   polyhedral threshold and finite state machine blocks (PTHBs) &
%   (FSMBs) begin with a lower case letter and contain only letters,
%   numbers, or underscores. 

% Set default return status to 1
st = true;

% ----------------------
% Check PTHB block names
% ----------------------

pthb_list = ...
    find_system(sys,'SearchDepth',2,'MaskType','PolyhedralThreshold');
for k = 1:length(pthb_list)
    name = get_param(pthb_list{k},'Name');
    if ~valid_block_name(name)
        fprintf(1,'\007Invalid polyhedral threshold block name ''%s''.\n',name)
        fprintf(1,['PTHB name must be a lower case letter followed by' ...
            ' letters, numbers, or _''s.'])
        st = false;
        return
    end
end

% ----------------------
% Check FSMB block names
% ----------------------

fsmb_list = ...
    find_system(sys,'SearchDepth',2,'MaskType','Stateflow');
for k = 1:length(fsmb_list)
    name = get_param(fsmb_list{k},'Name');
    if ~valid_block_name(name)
        fprintf(1,'\007Invalid finite state machine block name ''%s''.\n',name)
        fprintf(1,['FSMB name must be a lower case letter followed by' ...
            ' letters, numbers, or _''s.'])
        st = false;
        return
    end
end

% -----------------------------------------------------------------------------

function st = valid_block_name(name)

st = true;
for l = 1:length(name)
    ch = name(l);
    if (l == 1)
        % first character
        if ~islowercase(ch)
            st = false;
            return
        end
    else
        % second character on
        if ~((ch == '_') || isletter(ch) || isnumber(ch))
            st = false;
            return
        end
    end
end

% -----------------------------------------------------------------------------

function st = islowercase(ch)

st = ('a' <= ch) && (ch <= 'z');

% -----------------------------------------------------------------------------

function st = isnumber(ch)

st = ('0' <= ch) && (ch <= '9');


