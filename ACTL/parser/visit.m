function node = visit(node)
% Traverse a parse tree to remove leaf nodes of atomic propositions

global AP_NAME AP_BUILD_INFO

% traverse the tree to find atomic propositions
if strcmp(node.symbol,'ap')
  switch node.production
    case 'polyap',
      apname = node.value{1}.value;
      if ~ismember(apname,AP_NAME)
        AP_NAME{end+1} = apname;
        AP_BUILD_INFO{end+1} = {'polyap'};
      end
      % replace subtree by a single leaf node representing apname
      node.production = 'none';
      node.value = apname;
    case 'fsmap',
      fsmname = node.value{1}.value;
      statename = node.value{3}.value;
      apname = [fsmname '_in_' statename];
      if ~ismember(apname,AP_NAME)
        AP_NAME{end+1} = apname;
        AP_BUILD_INFO{end+1} = {'fsmap' fsmname statename};
      end
      % replace subtree by a single leaf node representing this finite
      % state machine atomic proposition
      node.production = 'none';
      node.value = apname;
    otherwise,
      error(['Unknown production ''' node.production  ''' for atomic proposition'])
  end
else
  if ~ischar(node.value)
    for k = 1:length(node.value)
      node.value{k} = visit(node.value{k});
    end
  end
end
