function src = find_src_port(dstblock,dstport)

% Find source block and port for Simulink blocks
%
% Syntax:
%   "src = find_src_port(dstblock,dstport)"
%
% Description:
%   "find_src_port(dstblock,dstport)" returns the source block and port
%   for the destination port "dstport" on block "dstblock" in the specified
%   system.  This information is returned as a structure with fields,
%   ".block" containing the handle for the source block and ".port" with
%   a string specifying the source port.
%
% See Also:
%   find_dst_port,find_line_dst

% Input: 
%   sys      - Handle or pathname for system
%   dstblock - Handle or pathname for the destination block
%   dstport  - String specifying destination port 
%              ('1','2', ... , 'Trigger', 'Enable')
% Output: 
%   src.block - Handle for source block
%   src.port  - String specifying source port

src = [];
if ~isa(dstblock,'double')
  dstblock = get_param(dstblock,'Handle');
end
parent = get_param(dstblock,'Parent');
lines = get_param(parent,'Lines');
found = 0;
for k = 1:length(lines)
  if lines(k).SrcBlock ~= -1
    dst = find_line_dst(lines(k));
    for l = 1:length(dst)
      if (dst{l}.block == dstblock) && strcmp(dst{l}.port,dstport)
        found = 1;
        break;
      end
    end
  end
  if found
    src.block = lines(k).SrcBlock;
    src.port = lines(k).SrcPort;
    break;
  end
end

if isempty(src)
  fprintf(1,'Warning: Input ''%s'' of ''%s'' is not connected.\n',dstport, ...
          get_param(dstblock,'Name'))
end
return
