function st = get_linearcon_param(con,param)

% Retrieve a parameter of a linear constraint object
%
% Syntax:
%   "A = get_linearcon_param(con,p)"
%
% Description:
%   "get_linearcon_param(con,p)" returns the parameter "p" from the
%   linear constraint object "con".  "p" is one of "'CE'","'dE'","'CI'","'dI'"
%   from the CEx=dE and CIx<=dI representation of the linear constraints.
%
% Example:
%   Given a linear constraint object, "con" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1),
%
%
%
%   "A = get_linearcon_param(con,'dI')"
%
%
%
%   results in
%
%
%
%   "A ="
%
%   "4"
%
%   "-2"
%
%   "3"
%
%   "-1"
%
%
%
%
% See Also:
%   linearcon,linearcon_data

switch param
  case 'CE'
    st = con.CE;
  case 'dE'
    st = con.dE;
  case 'CI'
    st = con.CI;
  case 'dI'
    st = con.dI;
  otherwise,
    error(['Invalid @linearcon parameter ''' param '''.'])
end

