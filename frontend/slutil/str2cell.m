function c = str2cell(s)

% Convert a string into a cell array of words
%
% Syntax:
%   "c = str2cell(s)"
%
% Description:
%   "str2cell(s)" returns the string "s" as a cell array of words.
%
% Note:
%   Words are considered to be groups of letters seperated by white
%   spaces.

c = {};
while ~isempty(s)
	[temp,s] = strtok(s);
	if ~isempty(temp)
		c{length(c)+1} = temp;
	end
end
return
