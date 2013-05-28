function blockH = find_masked_blocks(sys,masktype)

% Find masked blocks in a flat Simulink system
%
% Example
%   "blockH = find_masked_blocks(sys,masktype)"
%
% Description:
%   "find_masked_blocks(sys,masktype)" returns an array of handles to all
%   blocks in "sys" of type "masktype".
%
% Note:
%   find_masked_blocks assumes a flat Simulink system which means
%   that it will not search below the root level in the system
%   hierarchy. 

% Find all masked blocks in the current system, assuming flat simulink
% model.
blocks = find_system(sys,'SearchDepth',1,'MaskType',masktype);

% Get the simulink handle for each block and put it in a vector
a = get_param(blocks, 'Handle');
if iscell(a)
    blockH = [a{:}];
else
    blockH = a;
end

