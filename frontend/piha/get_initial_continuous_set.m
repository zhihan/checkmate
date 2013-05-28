function X0 = get_initial_continuous_set(scsbH)

% Get initial continuous set (ICS) for each SCS block. Each ICS is a cell
% array of @linearcon objects.
ICS = {};
for k = 1:length(scsbH)
  ICS{k} = evalin('base',get_param(scsbH(k),'ICS'));
  if (length(ICS{k}) < 1)
    blockname = get_param(scsbH(k),'name');
    error('CheckMate:PIHA', ...
        ['Invalid initial continuous set specified for block '''  	blockname '''.'])
% moved
  end
end

X0 = {};
idx = ones(1,length(scsbH));
stop = 0;
while ~stop
  % Compose combinations of overall ICS from ICS for each SCS block.
  ICS_CE = []; ICS_dE = [];
  ICS_CI = []; ICS_dI = [];
  for k = 1:length(scsbH)
    [CEk,dEk,CIk,dIk] = linearcon_data(ICS{k}{idx(k)});
    ICS_CE = [           ICS_CE            zeros(size(ICS_CE,1),size(CEk,2))
      zeros(size(CEk,1),size(ICS_CE,2))           CEk               ];
    ICS_dE = [ICS_dE; dEk];
    ICS_CI = [           ICS_CI            zeros(size(ICS_CI,1),size(CIk,2))
      zeros(size(CIk,1),size(ICS_CI,2))           CIk               ];
    ICS_dI = [ICS_dI; dIk];
  end
  % Put each combination into the cell array
  X0{length(X0)+1} = linearcon(ICS_CE,ICS_dE,ICS_CI,ICS_dI);

  % Increment the combination index
  k = length(scsbH);
  while (k >= 1)
    idx(k) = idx(k) + 1;
    if (idx(k) > length(ICS{k}))
      idx(k) = 1;
      k = k - 1;
    else
      k = -1;
    end
  end
  stop = (k == 0);
end

return

% ----------------------------------------------------------------------------
