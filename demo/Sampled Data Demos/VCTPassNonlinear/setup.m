function setup()

% Setup function for the vct
%
% Syntax:
%   "setup"
%
% Description:
%   "setup" sets various model and verification parameters for the
%   variable cam timing system.  In this demo, parameters are set as variables in
%   the Matlab base workspace and specified in the model using the
%   variable names.
%
% See Also:
%   global_var,bounce_param

% declare global variables in base work space
evalin('base','global_var');

% declare global variables here
global_var


%Note:  changing params here means that they must be changed in the vct_sys file as well.
ref = 18;
T = .008;
Ki = .01;
Kd = .0004;
Kp = .025;

assignin('base','ref',ref);
assignin('base','T',T);
assignin('base','Ki',Ki);
assignin('base','Kd',Kd);
assignin('base','Kp',Kp);




% sat hi 1.  The union of sat hi 1 and 2 is the guard region for entering sat hi
assignin('base','sat_hi_1',linearcon([],[],[1 0 0; .7 .49 0], [ref-10;.7*ref]));

% sat hi 2
assignin('base','sat_hi_2',linearcon([],[],[ 1 0 0 ], ( ref - 15 )));

% sat low 1.  The union of sat low 1 and 2 is the guard region for entering sat low
assignin('base','sat_low_1',linearcon([],[],[-1 0 0; .7 .49 0], [-ref-10;.7*ref]));

% sat low 2
assignin('base','sat_low_2',linearcon([],[],[ -1 0 0 ], ( -ref - 15 )));



%The following line is an ICS for showing a set of points that violates the specification
%of not making more than one discrete state transition.
assignin('base','vct_ICS',{linearcon([],[],[ eye(3) ; -eye(3) ],[ 2 ; 20 ; .1 ; 0 ; 20 ; .1 ])});


%The following line is an ICS for showing a set of points that violates the specification
%of not making more than one discrete state transition.
%assignin('base','vct_ICS',{linearcon([],[],[ eye(3) ; -eye(3) ],[ 32 ; -17 ; .1 ; -31.5 ; 18 ; 0 ])});

assignin('base','vct_AR',linearcon([],[],[ eye(3) ; -eye(3) ],[ 40 ; 30 ; 1 ; 5 ; 30 ; 1 ]));
assignin('base','period',[ T T ]);
assignin('base','phase',[0 0]);
assignin('base','jitter',[0 0]);

% setup verification parameters
GLOBAL_SYSTEM = 'vct';
GLOBAL_APARAM = 'vct_param';
GLOBAL_SPEC={};
GLOBAL_SPEC{1} = '(AG ((cntrl_mode == sat_hi)|(AG ~cntrl_mode == sat_hi)))';


return
