function display(s)

% Display the content of a "region" object.
%
% Description:
%   By calling "display(s)" or simply typing "s" without the semicolon at
%   the command line, the content of the region "s" is displayed in the
%   MATLAB command window.
%
% See Also:
%   region,set_state,isinregion,isuniverse

fprintf(1,'Total states: %d\n',s.nstate)
fprintf(1,'States in region: ')
if isempty(s)
  fprintf(1,'None')
elseif isuniverse(s)
  fprintf(1,'All')
else
  for k = 1:s.nstate
    if isinregion(s,k)
      fprintf(1,'\t%d',k)
    end
  end
end
fprintf(1,'\n')
