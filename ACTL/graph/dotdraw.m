function dotdraw(dotFile, ext)
% use callgraphviz

[sourcepath, sourcename] = fileparts(which(dotFile));

dotOption = ['-T' ext];
targetFile = [sourcepath, filesep, sourcename, '.', ext];
promptLicense = 'PromptLicense';
status = loc_callgraphviz('dot', dotOption, ...
    dotFile,'-o',targetFile);
if status ~= 0
    msgId = 'merge_checker:GeneratingDot';
    error(msgId, 'Error occured while generating file ''%s''.', dotFile);
end

end

%=======================================================
function status = loc_callgraphviz(varargin)
% Call the graphviz in the bin\ directory
algorithm = lower(varargin{1});
curpath = fileparts(mfilename('fullpath'));
graphviz_cmd = algorithm;
% Don't use the first two arguments
for i=2:nargin
    theArg = strtrim(varargin{i});
    if any(isspace(theArg)) && ~ismember(theArg(1),{'-','''','"'})
        varargin{i} = ['"' varargin{i} '"'];
    end
    varargin{i} = [' ' varargin{i}];
end

status =system([ graphviz_cmd  varargin{2:end}]);
end