function state_number = get_state_number(state_id)

% We assume the label strings in the Stateflow diagram have the following
% format.
%
%      <state_name>
%      entry: u = <state_number>;
%

labelString = sf('get',state_id,'.labelString');
% Skip all the white spaces at the end.
k = length(labelString);
while (k >= 1) && (isspace(labelString(k)) || (labelString(k) == ';'))
  k = k - 1;
end
% Search backwards until a non-numeric character is found.
labelString = labelString(1:k);
while (k >= 1) && (labelString(k) >= '0') && (labelString(k) <= '9')
  k = k - 1;
end
labelString = labelString(k+1:length(labelString));
state_number = str2double(labelString);
return

% ----------------------------------------------------------------------------
