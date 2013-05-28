function scsbH = trace_pthb_input(pthbH)

% Find handles and order of switched continuous system blocks (SCSBs)
% connected to a polyhedral threshold block (PTHB)
%
% Syntax:
%   "scsbH = trace_pthb_input(pthbH)"
%
% Description:
%   "trace_pthb_input(pthbH)" returns an ordered list of the SCSBs
%   connected to the input of the PTHB with handle "pthbH".
%
% See Also:
%   trace_mux_network,trace_scsb_input

% Output: A vector of handles for SCSBs in the order that they connect to the
%         input of pthbH
 
if ~(strcmp(get(pthbH,'BlockType'),'SubSystem') && ...
     strcmp(get(pthbH,'MaskType'),'PolyhedralThreshold'))
  error('CheckMate:PIHA:WrongBlock', ...
      'Input block must be a polyhedral threshold block.')
end
scsbH = trace_mux_network(pthbH,'1');
for k = 1:length(scsbH)
  if ~(strcmp(get_param(scsbH(k),'BlockType'),'S-Function') && ...
       strcmp(get_param(scsbH(k),'MaskType'),'SwitchedContinuousSystem'))
    errmsg = ['Invalid block "' get_param(scsbH(k),'Name') ...
              '" connected to polyhedral threshold block "' ...
              get_param(pthbH,'Name') '".'];
    error('CheckMate:PIHA:InvalidBlock', errmsg)
  end
end
