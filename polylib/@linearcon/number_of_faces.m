function n = number_of_faces(con)

% Find the number of faces on the region represented by a linear
% constraint object  
%
% Syntax:
%   "n = number_of_faces(con)"
%
% Description:
%   "number_of_faces(con)" returns the number of faces on the region
%   represented by "con".  This is equivalent to the number of rows in
%   the linear inequality matrix CI used to construct the linear
%   constraint object.
%
% Examples:
%   Given the linear constraint object "con" representing a square in the
%   plane x3=0 with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1).
%
%
%
%     "n = number_of_faces(con)"
%
%
%
%   returns
%
%
%
%     "n = 4"
%
%
%
% See Also:
%   linearcon,poly_face

n = length(con.dI);
return