function copy_model(src,dst)

% Copy a Simulink model
%
% Syntax:
%   "copy_model(src,dst)"
%
% Description:
%   "copy_model(src,dst)" creates a copy, "dst", of the Simulink system "src".
%
% See Also:
%   validate

% Create new system and copy the location information from the source system
new_system(dst);
location = get_param(src,'Location');
set_param(dst,'Location',location);

% Copy all blocks from the source system
blocks = get_param(src,'Blocks');
for k = 1:length(blocks)
  add_block([src '/' blocks{k}],[dst '/' blocks{k}]);
end

% Copy all lines (recursively) from the source system
lines = get_param(src,'Lines');
for k = 1:length(lines)
  copy_line(lines(k),dst)
end
return

% -----------------------------------------------------------------------------

function copy_line(line,dst)

Points = line.Points;
k = 1;
while (k < size(Points,1))
  if all(Points(k,:) == Points(k+1,:))
    Points = [Points(1:k,:); Points(k+2:size(Points,1),:)];
  else
    k = k + 1;
  end
end
if size(Points,1) > 1
  add_line(dst,Points);
end

for k = length(line.Branch):-1:1
  copy_line(line.Branch(k),dst);
end
return
