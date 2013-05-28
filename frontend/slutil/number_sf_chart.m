function number_sf_chart(sys,option)

% Number the states from Stateflow in a Simulink system
%
% Syntax:
%   "number_sf_chart(sys,option)"
%
% Description:
%   "number_sf_chart(sys,option)" numbers the states of any or all
%   Stateflow charts in the Simulink system "sys".  If "option" is set to
%   "'allcharts'" then "number_sf_chart(sys,option)" numbers all
%   Stateflow charts in "sys".  If "option" is set to "'currentchart'"
%   then "number_sf_chart(sys,option)" numbers only the current Stateflow
%   chart.
%
% See Also:
%   sf_tool

switch option
case 'allcharts',
  number_all_charts(sys);
case 'currentchart',
  number_current_chart;
otherwise,
  error('Unknown option.')
end
return

% -----------------------------------------------------------------------------

function number_current_chart()

chartID = sf('Private','currentchart');
number_chart(chartID,'alphabetically');
return

% -----------------------------------------------------------------------------

function number_all_charts(sys)

machineID = get_machine_id(sys);
if isempty(machineID)
  fprintf(1,'\007Cannot find machine id for Simulink model "%s"!!!\n',sys)
  return
end

% Find all charts in the current model (machine)
chartAll = sf('get','all','chart.id');               % all chart ID's 
chartID = sf('find',chartAll,'.machine',machineID);  % all charts of machine
% Update events and data for all charts found
for k = 1:length(chartID)
  number_chart(chartID(k),'alphabetically');
end
return

% -----------------------------------------------------------------------------

function number_chart(chartID,option)

statesAll = sf('get','all','state.id');          % all state ID's 
states_array = sf('find',statesAll,'.chart',chartID);  % all states of the choosen chart
% convert to cell array
states = cell(size(states_array));
for k = 1:length(states)
   states{k} = states_array(k);
end

switch option
case 'alphabetically', % sort state names alphabetically
   fprintf(1,'numbering states in ''%s'' alphabetically.\n', ...
           sf('get',chartID,'.name'))
   states = quick_sort(states,'compare_name');
otherwise,
   fprintf(1,'numbering states in ''%s'' in order found originally.\n', ...
           sf('get',chartID,'.name'))
end

for k = 1:length(states)
   name = sf('get',states{k},'.name');
   label = sprintf('%s\nentry: q = %d;',name,k);
   sf('set',states{k},'.labelString',label);
   fprintf(1,'%d: name = %s id = %d\n',k,name,states{k})
end
return

% -----------------------------------------------------------------------------

function result = compare_name(s1,s2)

name1 = sf('get',s1,'state.name');
name2 = sf('get',s2,'state.name');
N1 = length(name1);
N2 = length(name2);
k = 1;
while (k <= N1) & (k <= N2)
   if (name1(k) ~= name2(k))     
      result = (name1(k) < name2(k));
      return
   else
      k = k + 1;
   end   
end
result = (N1 < N2);
return

% -----------------------------------------------------------------------------

function S = quick_sort(S,compare_function)

% quick sort of cell array according to value assigned to each element
L = length(S);
M = floor(L/2);
if (L > 1)
   S1 = {};
   for k = 1:M
      S1{length(S1)+1} = S{k};
   end
   S2 = {};
   for k = M+1:L
      S2{length(S2)+1} = S{k};
   end
   S1 = quick_sort(S1,compare_function);
   S2 = quick_sort(S2,compare_function);
   S = combine_list(S1,S2,compare_function)';
end
return

% -----------------------------------------------------------------------------

function S = combine_list(S1,S2,compare_function)

L1 = length(S1); L2 = length(S2);
k1 = 1; k2 = 1;
S = {};
while (k1 <= L1) & (k2 <= L2)   
   if feval(compare_function,S1{k1},S2{k2})
      S{length(S)+1} = S1{k1};
      k1 = k1 + 1;
   else
      S{length(S)+1} = S2{k2};
      k2 = k2 + 1;
   end
end
if (k1 > L1)
   for k = k2:L2
      S{length(S)+1} = S2{k};
   end
else
   for k = k1:L1
      S{length(S)+1} = S1{k};
   end
end
return

% -----------------------------------------------------------------------------

function machineID = get_machine_id(sys)

possibleID = sf('find','all','machine.name',sys);
machineID = [];
for k = 1:length(possibleID)
  if strcmp(sys,sf('get',possibleID(k),'.name'))
    machineID = possibleID(k);
    break;
  end
end
return
