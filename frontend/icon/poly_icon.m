function data = poly_icon(coord)

% Generate sin or cos of five points equally distributed between 0 and 2*pi
%
% Syntax:
%   "data = poly_icon(coord)"
%
% Description:
%   If "coord = 1", "poly_icon(coord)" returns a row vector containing
%   the sin of five points equally distributed between 0 and 2*pi.  Otherwise,
%   "poly_icon(coord)" returns the cos.
%
% Note:
%   "poly_icon()" is used in generating the mask icon for the CheckMate
%   polyhedral threshold blocks (PTHBs) in Simulink.

N = 5;
theta = [0:N]*2*pi/N;
if coord == 1
  data = sin(theta);
else
  data = cos(theta);
end
