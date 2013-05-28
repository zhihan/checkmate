function p = subsref(v,S)

% Subscript referencing for vertices objects
%
% Syntax:
%   "p = subsref(vtcs,i)"
%
%   "p = vtcs(i)"
%
% Description:
%   "vtcs(i)" returns the coordinates of the "i"th point stored in
%   "vtcs".
%
% Examples:
%
%
%
%   "a = ["
%
%   "2 2 4 4"
%
%   "1 3 3 1"
%
%   "0 0 0 0];"
%
%   "vtcs = vertices(a);"
%
%   "p = vtcs(3)"
%
%
%
%   returns 
%
%
%
%   "p ="
%
%   "4"
%
%   "3"
%
%   "0"
%
%
%
% See Also:
%   vertices,find_index



p = [];
if strcmpi(S.type,'.') && strcmpi(S.subs,'list')
    p = v.list;
    return
end

if ~all(S.type == '()')
  disp('VERTICES/SUBSREF: invalid vertices referencing')
  return
end

if length(S.subs) > 1
  disp('VERTICES/SUBSREF: invalid vertices referencing')
  return
end

subs = S.subs{1};
if ~isa(subs,'double')
  disp('VERTICES/SUBSREF: invalid vertices referencing')
  return
end

[m,n] = size(subs);
if (m > 1) && (n > 1)
  disp('VERTICES/SUBSREF: invalid vertices referencing')
  return
end

p = v.list(:,subs);
