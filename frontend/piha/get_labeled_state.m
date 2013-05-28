function state_number = get_labeled_state(state_id)

state_number = [];
for k = 1:length(state_id)
  state_number(k) = get_state_number(state_id(k));
end
return

