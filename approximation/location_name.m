function str = location_name(loc)

global GLOBAL_PIHA

% The state names stored in the .state field of the locations are
% character matrices, i.e. each row of .state contains the name
% of each component state.
name = GLOBAL_PIHA.Locations{loc}.state;
str = '(';
for k = 1:size(name,1)
  if (k > 1)
    str = [str ','];
  end
  str = [str deblank(name(k,:))];
end
str = [str ')'];

return