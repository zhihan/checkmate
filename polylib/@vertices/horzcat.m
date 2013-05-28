function v = horzcat(v1,v2)

% Concatenate two vertices objects 
%
% Syntax:
%   "vtcs = horzcat(v1,v2)"
%
%   "vtcs = [v1 v2]"
%
% Description:
%   "horzcat(v1,v2)" returns a vertices object containing the points from
%   "v1" with the points from "v2" appended.  "v2" can be passed as a
%   list of points, which will first be converted to a vertices object then
%   added to "v1".
%
% Examples:
%   Given a vertices object, "v1" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "v2 = [
%
%   "2 2 4 4"
%
%   "1 3 3 1"
%
%   "2 2 2 2];"
%
%   "vtcs = horzcat(v1,v2)"
%
%
%
%   results in "vcts" a vertices object representing a cube with corners
%   at (x1,x2,x3) triples (2,1,0), (2,3,0), (4,3,0), (4,1,0), (2,1,2),
%   (2,3,2), (4,3,2), and (4,1,2).
%
% See Also:
%   vertices

if ~isa(v2,'vertices')
  v2 = vertices(v2);
end

if isempty(v1) || isempty(v2) || (dim(v1) ~= dim(v2))
  disp('VERTICES/OR: different dimensions given')
  return
end

v = vertices([v1.list v2.list]);
