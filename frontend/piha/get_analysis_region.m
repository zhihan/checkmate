function AR = get_analysis_region(scsbH)

% Compose overall analysis region from analysis region for each SCS block.
CAR = [];
dAR = [];
for k = 1:length(scsbH)
  ARk = evalin('base',get_param(scsbH(k),'AR'));
  [CE,dE,Ck,dk] = linearcon_data(ARk);
  if ~isempty(CE) || ~isempty(dE)
    blockname = get_param(scsbH(k),'name');
    error('CheckMate:PIHA','Invalid analysis region for block ''%s''', blockname);
  end
  CAR = [          CAR                zeros(size(CAR,1),size(Ck,2))
    zeros(size(Ck,1),size(CAR,2))           Ck                ];
  dAR = [dAR; dk];
end
AR = linearcon([],[],CAR,dAR);
return

% ----------------------------------------------------------------------------
