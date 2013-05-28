function chart_id = find_chart_id(machine_id,block_name)

possible_id = sf('find','all','chart.machine',machine_id,...
    'chart.name',block_name);
% moved
chart_id = [];
for l = 1:length(possible_id)
  name = sf('get',possible_id(l),'.name');
  if strcmp(name,block_name)
    chart_id = possible_id(l);
    break;
  end
end
return

