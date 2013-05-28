function plot(con,color)

% Plot a linear constraint object 
%
% Syntax:
%   "plot(con)"
%
%   "plot(con,color)"
%
% Description:
%   "plot(con)" plots the linear constraint object "con" in blue.
%   "plot(con,color)" plots "con" in the color specified in the rgb row
%   vector "color=[r g b]". 
%
% Note:
%   "@linearcon/plot" first converts the linear constraint object to a
%   polyhedron object, and then uses "@polyhedron/plot" to create the
%   figure.
%
% See Also:
%   linearcon,plot

if nargin == 1
  color = [0 0 1];
end

plot(polyhedron(con),color)
