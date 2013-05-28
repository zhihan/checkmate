function dst = find_line_dst(line)

% Find destination points of a line in Simulink
%
% Syntax:
%   "dst = find_line_dst(line)"
%
% Description:
%   "find_line_dst(line)" returns a structure array containing the
%   destination points of "line".  Tne information is returned in a
%   structure array with one element for each destination, and two fields
%   in each element.  ".block" contains the handle of the destination
%   block and ".port" which is a string specifying the destination port.
%
% See Also:
%   find_dst_port

dst = {};
if isempty(line.Branch)
  if (line.DstBlock ~= -1)
    dst{1}.block = line.DstBlock;
    dst{1}.port = line.DstPort;
  end
else
  for k = 1:length(line.Branch)
    dstk = find_line_dst(line.Branch(k));
    for l = 1:length(dstk)
      dst{length(dst)+1} = dstk{l};
    end
  end
end
return
