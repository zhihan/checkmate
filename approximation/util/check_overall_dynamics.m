function overall_dynamics = check_overall_dynamics(SCSBlocks,q)

% Get the type of composite dynamics of the all switched continuous
% system blocks (SCSB) for a given finite-state machine state vector.
%
% Syntax:
%   "overall_dynamics = check_overall_dynamics(SCSBlocks,q)"
% 
% Description:
%   Use the given FSM state vector "q" as the input to the SCSBs. Get the
%   dynamics type for each SCSB by calling its `switching function` with the
%   states of the FSMBs in "q" in the order that they feed into the input of
%   the SCSB. If the dynamics types for all SCSBs are "'linear'", return
%   "'linear'" as the overall dynamics. If the dynamics types for all SCSBs
%   are "'clock'", return "'clock'" as the overall dynamics. Otherwise,
%   return "'nonlinear'" as the overall dynamics.
%
% See Also:
%   piha

all_linear = 1;
all_clock = 1;
for k = 1:length(SCSBlocks)
  nx = SCSBlocks{k}.nx;
  if ~isempty(SCSBlocks{k}.nz)
      nx=nx+SCSBlocks{k}.nz;
      nx=nx+SCSBlocks{k}.nup;
  end
  swfunc = SCSBlocks{k}.swfunc;
  u = q(SCSBlocks{k}.fsmbindices);

  
  % Check whether there are parameters. If there are parameter we have 
  % (currently) to use the routines for the nonlinear case. 
  if SCSBlocks{k}.paradim~=0 
      [CPE,dPE,CPI,dPI] = linearcon_data(SCSBlocks{k}.pacs);
      Pcon=linearcon(CPE,dPE,[CPE;-CPE;CPI],[dPE;-dPE;dPI]);
      P0=vertices(Pcon);
      p0=P0(1); 
      all_linear = 0;
      all_clock = 0;
      [sys,type] = feval(swfunc,ones(nx,1),u,p0);
  else 
      [sys,type] = feval(swfunc,ones(nx,1),u);
  end;
  
  if ~strcmp(type,'linear')
    all_linear = 0;
  end
   if ~strcmp(type,'clock')
    all_clock = 0;
  end
end


if all_linear
  overall_dynamics = 'linear';
elseif all_clock
  overall_dynamics = 'clock';
else
  overall_dynamics = 'nonlinear';
end
return
