function [total_expression,event_expression,condition_expression] = find_cond_expr(sfdata,cond_expr,event_expr,sf_machine)

%This function will take the condition expression and represent it as
%a logical function in terms of the PTHB's

data=sfdata{sf_machine}.InputData;
condition_expression=cond_expr;
if ~isempty(cond_expr)
    if cond_expr(1)==' '|| cond_expr(length(cond_expr))==' '
        error('CheckMate:Stateflow', ...
            'Stateflow condition xpressions cannot have leading or trailing spaces.')
    end
end
total_expression=cond_expr;

for i=1:length(data)
    name=data{i}.Name;
    where=findstr(name,cond_expr);
    if (~isempty(where))&&length(cond_expr)>=length(name)
        replace_at=[];
        for n=where

            %The following code only checks to see if the character before and after the
            %matched strings are non-characters.  This protects against the following case:
            %cond_expr='region1==1'  and sfdata.name='region'
            %******************************************************************************
            if n>1&&(n+length(name))<=length(cond_expr)
                if ~(isletter(cond_expr(n-1))||isletter(cond_expr(n+length(name)))||...
                        ~isempty(findstr(cond_expr(n-1),'0123456789'))|| ...
                        ~isempty(findstr(cond_expr(n+length(name)),'0123456789')))
                    replace_at=[replace_at n];
                end
            elseif (n+length(name))<=length(cond_expr)
                if ~(isletter(cond_expr(n+length(name)))||~isempty(findstr(cond_expr(n+length(name)),'0123456789')))
                    replace_at=[replace_at n];
                end
            elseif n>1
                if ~(isletter(cond_expr(n-1))|| ...
                    ~isempty(findstr(cond_expr(n-1),'0123456789')))
                    replace_at=[replace_at n];
                end

            end %end if where(
            % moved

        end %end for n=where

        %Perform the all replacements necessary for the 'name' condition
        index_old=1;
        condition_expression_new=[];
        for j=1:length(replace_at)
            condition_expression_new = [condition_expression_new condition_expression(index_old:replace_at(j)-1)];
            condition_expression_new = [condition_expression_new data{i}.Expression];
            index_old=replace_at(j)+length(name);
        end
        condition_expression_new = [condition_expression_new condition_expression(index_old:length(condition_expression))];
        condition_expression = condition_expression_new;
        cond_expr=condition_expression;

    end %end if (~isempty
    % moved
end %end for i=1:
% moved
event_expression=[];
%Now concatenate the event expression onto the condition expression:
for i=1:length(sfdata{sf_machine}.InputEvent)
    input_expression=sfdata{sf_machine}.InputEvent{i}.Expression;
    input_event_name=sfdata{sf_machine}.InputEvent{i}.Name;
    if strcmp(deblank(input_event_name),deblank(event_expr))
        if ~isempty(condition_expression)
            total_expression=strcat('(',input_expression,')&(',condition_expression,')');
        else
            total_expression=input_expression;
        end
        event_expression=input_expression;
        break;
    end

end

return

% -----------------------------------------------------------------------------
