function [event_expr,cond_expr,clock,reset_flag] = process_label_string(labelString,sfdata,sf_machine,clockHandle)

% Assume that the condition expression lies between brackets
% (this should have been checked previously).
%Also assume that if there is a clock associated with this transition, it
%appears as the first element in the expression and that it is 'and'ed
%with the rest of the expression.
%Example: [(clock1==1)&((A==1)&B==1))]
clock=[];

start = findstr(labelString,'[');

%Find where the reset event starts (if there is one)
reset_start=findstr(labelString,'/');
reset_flag=0;

if ~isempty(start)
   event_expr = labelString(1:start-1);
elseif ~isempty(reset_start)
   event_expr = labelString(1:reset_start-1);
else
   event_expr= labelString;
end

% Test to see if the SF machine has event inputs but this transition
% does not.  Added by JPK (11/2002).
if isempty(event_expr)&&~isempty(sfdata{sf_machine}.InputEvent)
   error('CheckMate:PIHA' ,...
       ['Stateflow machine has event inputs, but at least one transition '    'does not have an event associated with it.']);
% moved
end

if ~isempty(reset_start)
if ~isempty(findstr('reset',labelString(reset_start+1:length(labelString))))
         reset_flag=1;
else
         error('CheckMate:PIHA', 'Invalid reset event.')
end
end


  stop = findstr(labelString,']');

  %Test for a clocked event in the event section of the labelstring
  for i=1:length(sfdata{sf_machine}.Clock)
     name=sfdata{sf_machine}.Clock{i}.Name;
     name=deblank(name);
     is_clock=strcmp(name,event_expr);
     if is_clock
        event_expr=[];
        zoh_block=sfdata{sf_machine}.Clock{i}.ClockHandle;
        [dum1,dum2,clock]=intersect(zoh_block,clockHandle);
        break;
     end
  end

 cond_expr = labelString(start+1:stop-1);



return

% ----------------------------------------------------------------------------
