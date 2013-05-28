function u = unique(v)

% Remove all redundant points from a vertices object 
%
% Syntax:
%   "V = unique(vtcs)"
%
% Description:
%   "unique(vtcs)" returns a vertices object containing the points from
%   "vtcs" with all repetitions removed.
%
% Examples:
%   Given a vertices object, "vtcs" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "v2 = ["
%
%   "2 2"
%
%   "1 3"
%
%   "0 0];"
%
%   "vtcs = [vtcs v2];"
%
%   "V = unique(vtcs)"
%
%
%
%   returns "V" a vertices object representing the same square but
%   containing two less points than the modified vtcs.
%
% See Also:
%   vertices 

u = vertices;
for k = 1:length(v)
  vk = v.list(:,k);
  u = u | vk;
end
