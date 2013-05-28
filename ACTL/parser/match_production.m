function [match,idx] = match_production(top,rule)

idx = 1;
match = 0;
while (idx+length(rule)-1 <= length(top)) && ~(match)
  match = 1;
  for k = 1:length(rule)
    if ~strcmp(top{idx+k-1}.symbol,rule{k})
      match = 0;
      break;
    end
  end
  if ~match
    idx = idx + 1;
  end
end

% -----------------------------------------------------------------------------
