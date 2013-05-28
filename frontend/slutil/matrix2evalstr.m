function evalstr = matrix2evalstr(M)

% Convert a matrix to a string for use with eval
%
% Syntax:
%   "evalstr = matrix2evalstr(M)"
%
% Description:
%   "matrix2evalstr(M)" returns a string "evalstr" such that
%   "eval(evalstr)" returns the original matrix "M".  

evalstr = '[';
for k = 1:size(M,1)
  evalstr = [evalstr num2str(M(k,:)) ';'];
end
evalstr = [evalstr ']'];
return

