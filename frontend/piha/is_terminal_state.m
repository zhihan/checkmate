function result = is_terminal_state(q)

result = 1;
for k = 1:length(q)
  parent_chart = sf('get',q(k),'.chart');
  transitionsAll = sf('get',parent_chart,'.transitions');
  qk_transitions = sf('find',transitionsAll,'.src.id',q(k));
  if ~isempty(qk_transitions)
    result = 0;
    break;
  end
end
return

