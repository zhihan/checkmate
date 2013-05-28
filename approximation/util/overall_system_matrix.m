function [A,b] = overall_system_matrix(SCSBlocks,q)

% Get overall system matrix in the case where every SCSB has `linear`
% (actually affine) dynamics for the given the FSM state vector.
%
% Syntax:
%   "[A,b] = overall_system_matrix(SCSBlocks,q)"
%
% Description: 
%   Return the composite state matrix "A" and input vector "b" representing
%   the affine dynamics
%
%
%
%   "dx/dt = Ax + b"
%
%
%
%   for the given FSM state vector "q" and the SCSBs information are stored
%   in "SCSBlocks".
%
% Note:
%   It must be checked before calling this function that the overall system
%   indeed has "'linear'" dynamics for the FSM state vector "q".
%
% Implementation:
%   For the "k"-th SCSB, compute the vector "uk", the outputs of FSMBs in
%   "q" in the order that they feed into the "k"-th SCSB in the Simulink
%   diagram. Use "uk" to call the `switching function` for the SCSB to
%   obtain the matrix-vector pair for that block.  Stack the matrices and
%   vectors from the SCSBs together to form the overall (composite)
%   matrix-vecotr pair. Issue an error message if the dynamics type of some
%   SCSB is not "'linear'" for the given FSM vector "q".
%
% See Also:
%   piha,overall_system_clock,overall_system_ode

A = []; b = [];
for k = 1:length(SCSBlocks)
  nxk = SCSBlocks{k}.nx;
  swfunck = SCSBlocks{k}.swfunc;
  uk = q(SCSBlocks{k}.fsmbindices);
  [sys,type] = feval(swfunck,zeros(nxk,1),uk);
  Ak = sys.A; bk = sys.b;
  if ~strcmp(type,'linear')
    error('Overall system is not linear!!!!')
  end
  A = [            A               zeros(size(A,1),size(Ak,2))
       zeros(size(Ak,1),size(A,2))            Ak              ];
  b = [b; bk];
end
return
