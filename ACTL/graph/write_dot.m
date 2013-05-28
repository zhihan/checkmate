function filename = write_dot(varargin)
% WRITE_DOT writes the merge diagnostics graph to a DOT file.
%
% writes the merge diagnostics graph to a DOT file, where filename is
% the path to the DOT file.

if nargin<1
    filename = [tempname '.dot'];
else
    filename = varargin{1};
end

s = s_write_dot();

[fid, message] = fopen(filename,'w');
if fid<0
    error(message);
    return;
end
fprintf(fid, s);
fclose(fid);

function s = s_write_dot()
% WRITE_DOT writes the merge graph to a string in DOT format.
%
%  s = write_dot(nodelist, conn)
% writes the merge graph represented by nodelist, conn to a string
% s which is the DOT representation of the graph.

% Created by Zhi Han 

global GLOBAL_TRANSITION GLOBAL_AP

s = sprintf('digraph G{ \n');
%write nodes

labels = fields(GLOBAL_AP);
newlabels = {};
for j=1:length(labels)
    if ~strcmpi(labels{j},'true') && ~strcmpi(labels{j}, 'false')
        newlabels{end+1} = labels{j}; %#ok
    end
end
labels = newlabels;

for i=1:length(GLOBAL_TRANSITION)
    label = '';
    for j=1:length(labels)
        if isinregion(GLOBAL_AP.(labels{j}), i)
            label = horzcat(label, labels{j});
        end
    end
    s = [s sprintf('\t') '"' mat2str(i)]; %#ok
    if isempty(label)
        s = [s '"']; %#ok
    else
        s = [s '" [label="' mat2str(i) ' ' label '"]']; %#ok
    end
    s = [s sprintf('[shape=circle]')]; %#ok
    s = [s sprintf('\n')]; %#ok
end

% end of nodes
s = [s sprintf('\n')];
% write edges

for i=1:length(GLOBAL_TRANSITION)
    for j=1:length(GLOBAL_TRANSITION{i})
        s = [s sprintf('\t') '"' mat2str(i) '"']; %#ok
        s = [s sprintf('->')]; %#ok
        s = [s sprintf('"%d"\n',GLOBAL_TRANSITION{i}(j))]; %#ok
    end
end


s = [s sprintf('\n}')];

