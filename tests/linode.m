function dydt = linode(t,y, varargin)
A = varargin{1}{1};
b = varargin{1}{2};

dydt = A * y + b;