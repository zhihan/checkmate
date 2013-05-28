function setup_ph()
% Setup function for the ph plant demonstration
%
% Syntax:
%   "setup_ph"
%
% Description:
%   "setup" sets various model and verification parameters for the
%   ph_plant demonstration.  In this demo, parameters are set as variables in
%   the Matlab base workspace and specified in the model using the
%   variable names.
% 
%   ph_plant is a model of a chemical control system.  See the readme.txt file 
%   in the ph_plant directory for a complete description of (and getting started guide for)
%   the ph_plant example.
% 
%
% See Also:
%   global_var,ph_param

% declare global variables in base work space
evalin('base','global_var');

% declare global variables locally
global_var



%----------------------------------------------------------------------%
%Switched Continuous System driveline:                                 %
%----------------------------------------------------------------------%

   
ICS_CE = [];
ICS_dE = [];
ICS_CI = [1 0;-1 0;0 1;0 -1];
ICS_dI = [0.1;0;7.15;-7.1];

assignin('base','PH_ICS',{linearcon(ICS_CE,ICS_dE,ICS_CI,ICS_dI)});

AR_C = [1 0;-1 0;0 1;0 -1];
AR_d = [1.2;0;7.3;-6.7];
  
assignin('base','PH_AR',linearcon([],[],AR_C,AR_d));

PAR_C = [1;-1];
PAR_d = [0.15;-0.05];
assignin('base','PH_PAR',linearcon([],[],PAR_C,PAR_d));

%-------------------------------------------------------------------------%
%HYPERPLANES Low_PH,  High_PH,  Tank_full, PH_Normal
%-------------------------------------------------------------------------%

%hyperplane Low_PH
C = [0 1];
d = 6.8;
con = linearcon([],[],C,d);
assignin('base','lowph',con);

%hyperplane High_PH
C = [0 -1];
d = -7.2;
con = linearcon([],[],C,d);
assignin('base','highph',con);

%hyperplane PH_Normal
C = [0 1];
d = 7;
con = linearcon([],[],C,d);
assignin('base','phnormal',con);

%hyperplane Tank_full
C = [-1 0];
d = -1;
con = linearcon([],[],C,d);
assignin('base','tankfull',con);


%-------------------------------------------------------------%
% setup verification parameters                               %
%-------------------------------------------------------------%

GLOBAL_SYSTEM = 'ph_plant';
GLOBAL_APARAM = 'ph_param';
GLOBAL_SPEC ={};
%GLOBAL_SPEC{1} = 'AF (controller == reach )& (AG ~out_of_bound) & AG (~controller == avoid)';

return
