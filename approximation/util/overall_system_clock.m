function v = overall_system_clock(SCSBlocks,q)

% Get overall system `clock` vector in the case where every SCSB has `clock`
% dynamics for the given the FSM state vector.
%
% Syntax:
%   "v = overall_system_clock(SCSBlocks,q)"
%
% Description:
%   Return the composite clock vector "v" for the given FSM state vector
%   "q" and the SCSBs information are stored in "SCSBlocks".
%
% Note:
%   It must be checked before calling this function that the overall system
%   indeed has "'clock'" dynamics for the FSM state vector "q".
%
% Implementation:
%   For the "k"-th SCSB, compute the vector "uk", the outputs of FSMBs in
%   "q" in the order that they feed into the "k"-th SCSB in the Simulink
%   diagram. Use "uk" to call the `switching function` for the SCSB to
%   obtain the clock vector for that block. Stack the clock vectors from the
%   SCSBs together to form the overall (composite) clock vector. Issue an
%   error message if the dynamics type of some SCSB is not "'clock'" for the
%   given FSM vector "q".
%
% See Also:
%   piha,overall_system_matrix,overall_system_ode

v = [];
for k = 1:length(SCSBlocks)
  nxk = SCSBlocks{k}.nx;
  swfunck = SCSBlocks{k}.swfunc;
  uk = q(SCSBlocks{k}.fsmbindices);
  [vk,type] = feval(swfunck,zeros(nxk,1),uk);
  if ~strcmp(type,'clock')
    error('Overall system is not of type ''clock''!!!!')
  end
  v = [v; vk];
end
return
