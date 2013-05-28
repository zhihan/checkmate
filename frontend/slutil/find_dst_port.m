function dst = find_dst_port(srcblock,srcport)

% Find destination block and port of a simulink block
%
% Syntax:
%   "dst = find_dst_port(srcblock,srcport)"
%
% Description:
%   "find_dst_port(srcblock,srcport)" returns the destination block and
%   port for port "srcport" in block "srcblock" in the specified system.
%   The destination information is returned in a structure array with one
%   element for each destination, and two fields in each element.
%   ".block" containing the handle for the destination block and ".port"
%   containing a string specifying the destination port. 
%
% See Also:
%   find_src_port,find_line_dst

% Input: 
%   srcblock - Handle or pathname for the source block
%   srcport  - String specifying source port 
%              ('1','2', ... , 'Trigger', 'Enable')
% Output: 
%   dst.block - Handle for destination block
%   dst.port  - String specifying destination port

dst = [];
if ~isa(srcblock,'double')
  srcblock = get_param(srcblock,'Handle');
end
parent = get_param(srcblock,'Parent');
lines = get_param(parent,'Lines');
for k = 1:length(lines)
   if (lines(k).SrcBlock == srcblock) & strcmp(lines(k).SrcPort,srcport)
      dst = find_line_dst(lines(k));
      break;
   end
end

return
