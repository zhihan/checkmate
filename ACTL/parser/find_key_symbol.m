function found = find_key_symbol(top,key_symbol)

found = 0;
for idx = 1:length(top)
  if ismember(top{idx}.symbol,key_symbol)
    found = 1;
    break
  end
end
return
