function install(cmd)

% Install CheckMate by adding CheckMate's m-files to MATLAB's path.
%
% Syntax:
%   "install(root)"
%
% Description:
%   CheckMate can be installed by calling "install(root)" with the string
%   "root" containing the path to CheckMate's root directory. If the
%   argument "root" is not specified, it is assumed that the current
%   directory is the root directory of CheckMate.
%
% See Also:
%   AboutCheckMate,HelpCheckMate

root = pwd;

if nargin < 1
  cmd = '';
end

adddir(root);
adddir([root '/frontend']);
cd ([root filesep 'frontend']);
compilescsb(cmd);
cd (root);

adddir([root '/frontend/icon'])
adddir([root '/frontend/slutil'])
adddir([root '/frontend/piha'])
adddir([root '/ACTL']);
install_ctl;
adddir([root '/approximation']);
adddir([root '/approximation/partition'])
adddir([root '/approximation/flowpipe'])
adddir([root '/approximation/flowpipe/clock'])
adddir([root '/approximation/flowpipe/linear'])
adddir([root '/approximation/flowpipe/nonlinear'])
adddir([root '/approximation/util'])
adddir([root '/polylib']);
cd([root '/polylib/src/']);
compilecdd(cmd);
cd(root);
adddir([root '/exploration']);



fprintf(1,'CheckMate installed at ''%s''.\n',root)
type([root '/disclaim.txt'])
fprintf(1,'\nNOTE: To save CheckMate paths, select "Set Path" from File menu and press Save.\n\n');
fprintf(1,'Type cmhelp for help using CheckMate.\n\n');



return

% ------------------------------------------------------------------------------------

function adddir(directory)

if isempty(dir(directory))
  error('CheckMate:Install', ['Directory ' directory ' not found!'])
else
  addpath(directory)
end
