function sys = get_root_system(sys)

% Get the root level system for a given subsystem
%
% Syntax:
%   "root = get_root_system(sys)"
%
% Description:
%   "get_root_system(sys)" returns the root level system (system with no
%   parents in the hierarchy) containing the subsystem "sys".

parent = get_param(sys,'Parent');
while ~isempty(parent)
  sys = parent;
  parent = get_param(sys,'Parent');
end
return
