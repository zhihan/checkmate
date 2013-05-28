function tail = match_paren(str,open_paren_flag)

% Match pairs of parentheses in the given string.
%
% Syntax:
%   "match_param(str,0)" or "tail = match_paren(str,open_paren_flag)"
%
% Description:
%   Match pairs parentheses in the input string "str". The boolean flag
%   "open_paren_flag" is used in the recursion to indicate whether the
%   opening parenthesis has been found at the called level. If the matching
%   fails, the function issues an error message and stop the
%   execution. Otherwise, the function return the tail end of the string in
%   "tail" after the closing parenthesis is found. The matching then
%   continued on the tail end of the string at the caller level. The return
%   string "tail" and "open_paren_flag" should be used only by the
%   recursion. The user should call this funbction on a string with
%   "open_paren_flag = 0" and no output argument as shown in the first form
%   of the syntax.

idx = 1;
while idx <= length(str)
   ch = str(idx);
   % ONLY ONE of these should execute in each loop
   % (1) opening parenthesis
   if ch == '('
      str = match_paren(str(idx+1:length(str)),1);
      idx = 1;
   else
      % (2) closing parenthesis
      if ch == ')'
         if (open_paren_flag)
           tail = str(idx+1:length(str));
         else
           error('unmatched ")".')
         end
         return
      else
         % (3) otherwise, do nothing
         idx = idx + 1;
      end
   end
end

if open_paren_flag
   error('unmatched "(".')
else
   tail = '';
end
return
