function setup_reg()

% Setup function for the bounce demonstration
%
% Syntax:
%   "setup"
%
% Description:
%   "setup" sets various model and verification parameters for the
%   bounce demonstration.  In this demo, parameters are set as variables in
%   the Matlab base workspace and specified in the model using the
%   variable names.
%
% See Also:
%   global_var,bounce_param


etc_reg_def


% tot hier

% declare global variables in base work space
evalin('base','global_var');

% declare global variables here
global_var

% define thresholds
assignin('base','clock_geq100',linearcon([],[],[-1],[-0.1]));
assignin('base','clock_geq40',linearcon([],[],[-1 ],[-0.04]));

assignin('base','clock_AR',linearcon([],[],[1;-1],[150;1]));
assignin('base','clock_ICS',{linearcon([],[],[1;-1],[0;0])});



assignin('base','five_percent',linearcon([],[],[-1 0 ;1 0 ],[-0.95;1.05]*alpha_des));
assignin('base','alpha_in_pm2',linearcon([],[],[-1 0 ;1 0 ],[-0.98;1.02]*alpha_des));


assignin('base','above_surf',linearcon([],[],-surfA,surfB-layereps));
assignin('base','below_surf',linearcon([],[],surfA,-surfB-layereps));

assignin('base','turn_left',linearcon([],[],[0 1],-layereps));
assignin('base','turn_right',linearcon([],[],[0 -1],-layereps));

C_inner = [surfA; -surfA;0 1; 0 -1];
d_inner = [-surfB+0.5*layereps;surfB+0.5*layereps;-layereps;4];


assignin('base','inner_box',linearcon([],[],C_inner,d_inner));



% definition of the analysis region
AR_C = [    1 0 
            -1 0 
            0 1 
            0 -1 ];
AR_d = [10;0.5;150;150];
assignin('base','etc_AR',linearcon([],[],AR_C,AR_d));
 
% defineing the inital set
ICS_CI = [1 0;
         -1 0
          0  1
          0 -1];
ICS_dI = [alpha_des*1.045;-alpha_des*1.025;-0.18;0.22];
%ICS_dI = [alpha_des+0.5*layereps/lambda;-alpha_des+0.5*layereps/lambda;0.5*layereps;0.5*layereps];
%ICS_CI=AR_C;
%ICS_dI=[0;0; ;0;0 ;0;0];
C_outer = [1 0; -1 0 ;0 1; 0 -1];
d_outer = [alpha_des*1.04;-alpha_des*1.003;-0.1;0.2];

assignin('base','etc_ICS',{linearcon([],[],C_outer,d_outer)});


%assignin('base','etc_ICS',{linearcon([],[],ICS_CI,ICS_dI)});
PC_CI=[1 0;-1 0;0 1;0 -1];
PC_dI=[[1.2;-0.8];[1.2;-0.8]];
assignin('base','etc_PaCs',linearcon([],[],PC_CI,PC_dI));


% setup verification parameters
GLOBAL_SYSTEM = 'etc_reg';
GLOBAL_APARAM = 'etc_reg_param';
GLOBAL_SPEC={};

return
