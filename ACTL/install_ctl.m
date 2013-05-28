function install_ctl()
% INSTALL_CTL install the CTL package
path = fileparts(mfilename('fullpath'));
addpath(path);

subdir = {'witness','parser', 'graph'};
for i = 1:length(subdir)
    addpath(fullfile(path, subdir{i}));
end