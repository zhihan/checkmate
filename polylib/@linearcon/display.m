function display(con)

% Command window display of a linear constraint object
%
% Syntax:
%   "con"
%
%   "display(con)"
%
% Description:
%   "display(con)" is called whenever a linear constraint object needs to be
%   displayed in the Matlab command window.
%
% Examples:
%   The command sequence 
%
%
%
%     "CE = [0 0 1]; dE = 0;"
%
%     "CI = [1 0 0;-1 0 0;0 1 0;0 -1 0]; dI = [4;-2;3;-1];"
%
%     "con = linearcon(CE,dE,CI,dI)"
%
%
%
%   results in
%
%
%
%     "con =
%
%       "[ 0.000000 0.000000 1.000000 ]x = 0.000000"
%
%       "[ 1.000000 0.000000 0.000000 ]x <= 4.000000"
%
%       "[ -1.000000 0.000000 0.000000 ]x <= -2.000000"
%
%       "[ 0.000000 1.000000 0.000000 ]x <= 3.000000"
%
%       "[ 0.000000 -1.000000 0.000000 ]x <= -1.000000"
%
%
%
% See Also:
%   linearcon

fprintf(1,['\n' inputname(1) ' ='])

CE = con.CE; dE = con.dE;
CI = con.CI; dI = con.dI;

if isempty(CE) & isempty(CI)
  fprintf(1,' empty\n\n')
else
  fprintf(1,'\n')
end

for k = 1:length(dE)
  fprintf(1,'   [ ')
  fprintf(1,'%f ',CE(k,:))
  fprintf(1,']x = %f\n',dE(k))
end

for k = 1:length(dI)
  fprintf(1,'   [ ')
  fprintf(1,'%f ',CI(k,:))
  fprintf(1,']x <= %f\n',dI(k))
end

return



