function xdot = overall_system_ode(t,x,flag,ode_param,p) %#ok

% Get overall system derivative vector for the given the FSM state vector.
%
% Syntax:
%   "xdot = overall_system_ode(t,x,flag,ode_param)"
%
% Description:
%   Return the composite derivative vector "xdot" for the given FSM state
%   vector "q" and the SCSBs information are stored in "SCSBlocks".
%
% Implementation:
%   For the "k"-th SCSB, compute the vector "uk", the outputs of FSMBs in
%   "q" in the order that they feed into the "k"-th SCSB in the Simulink
%   diagram. Use "uk" to call the `switching function` for the SCSB to
%   obtain the derivative vector for that block.  Stack the derivative
%   vectors from the SCSBs together to form the overall (composite)
%   derivative vector.
%
% See Also:
%   piha,overall_system_clock,overall_system_matrix

global GLOBAL_PIHA
global evalnumber

evalnumber=evalnumber+1;
if nargin<=4
    p=[];
end;


q = ode_param;
xdot = [];
startx = 0;
startp = 0;
for k = 1:length(GLOBAL_PIHA.SCSBlocks)
  nx = GLOBAL_PIHA.SCSBlocks{k}.nx;
  np = GLOBAL_PIHA.SCSBlocks{k}.paradim;
  swfunck = GLOBAL_PIHA.SCSBlocks{k}.swfunc;
  uk = q(GLOBAL_PIHA.SCSBlocks{k}.fsmbindices);
  xdot = [xdot; deriv(swfunck,x(startx+1:startx + nx),uk,p(startp+1:startp + np))];
  startx = startx + nx;
  startp = startp + np;
end


return

% -----------------------------------------------------------------------------

function xdot = deriv(swfunc,x,u,p)

if nargin >2 && ~isempty(p)
    [sys,type] = feval(swfunc,x,u,p);
else
    [sys,type] = feval(swfunc,x,u);
end;
switch type
  case {'clock','nonlinear'}
    xdot = sys;
  case 'linear',
    % If the differential equation type is linear dx/dt = Ax + b, the returned
    % sys from swfunc is a structure containing the matrix A and the vector b.
    xdot = sys.A*x + sys.b;
  otherwise,
    error(['Unknown dynamics type ''' type '''!!!'])
end
return
