function machine_id = get_machine_id(sys)

% the Stateflow function returns all block names whose begining substring
% matches with the name given in sys. thus, we have to make sure that we get
% an exact match.

possible_id = sf('find','all','machine.name',sys);
machine_id = [];
for k = 1:length(possible_id)
  name = sf('get',possible_id(k),'.name');
  if strcmp(name,sys)
    machine_id = possible_id(k);
    break;
  end
end
return

