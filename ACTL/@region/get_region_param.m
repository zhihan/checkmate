function val = get_region_param(s,param)

% Get a parameter of a "region" object.
%
% Syntax:
%   "val = get_region_param(s,param)"
%
% Description:
%   Returns the field specified by the string "param" in the structure
%   for the "region" object "s".
% 
% Examples:
%   * Suppose "s = region(5,[1 3 4])".
%
%   * "val = get_region_param(s,'nstate')" returns the total number of
%     states in the universe set for the region "s", which is 5.
%
% See Also:
%   region

val = s.(param);

