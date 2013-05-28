function setup5d()

% Setup function for the bounce demonstration
%
% Syntax:
%   "setup"
%
% Description:
%   "setup" sets various model and verification parameters for the
%   5d ETC model.  In this demo, parameters are set as variables in
%   the Matlab base workspace and specified in the model using the
%   variable names.
%
% See Also:
%   global_var,bounce_param




etc_def

% tot hier

% declare global variables in base work space
evalin('base','global_var');

% declare global variables here
global_var

% define thresholds

assignin('base','above_surf',linearcon([],[],-surfA,surfB-layereps));
assignin('base','below_surf',linearcon([],[],surfA,-surfB-layereps));

assignin('base','turn_left',linearcon([],[],[0 0 0 1],-layereps));
assignin('base','turn_right',linearcon([],[],[0 0 0 -1],-layereps));

assignin('base','alpha_geq90',linearcon([],[],[0 0 -1 0 ],[-0.9]*alpha_des));
assignin('base','alpha_geq10',linearcon([],[],[0 0 -1 0 ],[-0.1]*alpha_des));

assignin('base','clock_AR',linearcon([],[],[1;-1],[150;1]));
assignin('base','clock_ICS',{linearcon([],[],[1;-1],[0;0])});

assignin('base','clock_geq100',linearcon([],[],[-1],[-0.1]));

% definition of the analysis region
AR_C = [     1 0 0 0
            -1 0 0 0
            0  1 0 0
            0 -1 0 0
            0 0  1 0
            0 0 -1 0
            0 0 0  1
            0 0 0 -1];
AR_d = [0.5;0.5;0.5;0.5;10;0.5;150;150];
assignin('base','etc_AR',linearcon([],[],AR_C,AR_d));
 


% defineing the inital set
%initally the filter everything is assumed to be insteady state
init_eq = [red_fil.A red_fil.B [0 ;0] ];
%ICS_CI = [init_eq;- init_eq;
%        0 0 1 0 
%        0 0 -1 0
%        0 0 0  1
%        0 0 0 -1];
%ICS_dI = [zeros(4,1);0;0; 0;0 ];
ICS_CI=AR_C;
ICS_dI=[0;0 ;0;0; ;0;0; ;0;0];

assignin('base','etc_ICS',{linearcon([],[],ICS_CI,ICS_dI)});

PC_CI=[1 0;-1 0;0 1;0 -1];
PC_dI=[[1.2;-0.8];[1.2;-0.8]];
assignin('base','etc_PaCs',linearcon([],[],PC_CI,PC_dI));


% setup verification parameters
GLOBAL_SYSTEM = 'etc5d';
GLOBAL_APARAM = 'etc_param';
GLOBAL_SPEC = {};
return
