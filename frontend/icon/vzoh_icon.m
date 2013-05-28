function data = vzoh_icon(coord)

% Generate point for drawing symbol for VZOH.
%
% Syntax:
%   "data = vzoh_icon(coord)"
%
% Description:
%   If "coord = 1", "poly_icon(coord)" returns a row vector containing
%   the sin of five points equally distributed between 0 and 2*pi.  Otherwise,
%   "poly_icon(coord)" returns the cos.
%
% Note:
%   "poly_icon()" is used in generating the mask icon for the CheckMate
%   variable zero-order hold blocks (VZOHs) in Simulink.

N = 100;
theta = [0:N]*2*pi/N;
b = sqrt(2)/2;
switch coord
   
case 1
  data = [sin(theta)];
  
case 2
  data = [cos(theta)];
  
case 3
  data = [-b  b 0 -b b -b];
   
case 4
  data = [-b -b 0  b b -b];
   
end
