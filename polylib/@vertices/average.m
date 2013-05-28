function v_avg = average(V)

% Average value of a vertices object
%
% Syntax:
%   "A = average(vtcs)"
%
% Description:
%   "average(vtcs)" returns a column vector containing the average value
%   of the points represented by "vtcs" (i.e. find the average value of
%   each dimension of "vtcs").
%
% Examples:
%
%
%
%   "a = ["
%
%   "2 2 4 4"
%
%   "1 3 3 1"
%
%   "0 0 0 0];"
%
%   "vtcs = vertices(a);"
%
%   "A = average(vtcs)"
%
%
%
%   returns 
%
%
%
%   "A ="
%
%   "3"
%
%   "2"
%
%   "0"
%
%
%
% See Also:
%   vertices

v_avg = mean(V.list,2);

