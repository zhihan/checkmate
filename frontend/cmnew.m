function cmnew()

% Create a new CheckMate model in Simulink
%
% Syntax:
%   "cmnew"
%
% Description:
%   "cmnew" opens a new (untitled) Simulink diagram containing the permissible 
%   blocks for use in building a CheckMate model. 
%
% See Also:
%   verify,validate

template = 'template';
sys = unique_sys_name;
new_system(sys)

if isempty(find_system('Name',template))
  % Open template but hide it from view
  load_system(template)
end
location = get_param(template,'Location');
set_param(sys,'Location',location);

% Copy all blocks from template
blocks = get_param(template,'Blocks');
for k = 1:length(blocks)
  add_block([template '/' blocks{k}],[sys '/' blocks{k}]);
end

open_system(sys)
return

% -----------------------------------------------------------------------------

function sys = unique_sys_name()

sys = 'untitled';
count = 0;
while ~isempty(find_system('SearchDepth',0,'Name',sys))
  count = count + 1;
  sys = ['untitled' num2str(count)];
end
return
