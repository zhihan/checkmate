function acc_setup()
evalin('base','global_var');
global_var;

% Guards:
%

gear1to2=linearcon([],[],[-1 0 0 ;0 -1 0],[0;-6.67]);
assignin('base','gear1to2',gear1to2);
gear2to3=linearcon([],[],[-1 0 0;0 -1 0],[0;-14.21]);
assignin('base','gear2to3',gear2to3);
gear3to4=linearcon([],[],[-1 0 0;0 -1 0],[0;-29.78]);
assignin('base','gear3to4',gear3to4);

L=5;
hyst=1;
sigma=1.5;

toacc=linearcon([],[],[1 -sigma 0],L-hyst);
assignin('base','toacc',toacc);
tocc=linearcon([],[],[-1 sigma 0],-L-hyst);
assignin('base','tocc',tocc);


toerror=linearcon([],[],[1 0 0],0);
assignin('base','collide',toerror);

%Analysis Region
Analysis_Region=linearcon([],[],[-1 0 0; 1 0 0 ; 0 -1 0; 0 1 0;0 0 1;0 0 -1],[1; 1000; 1; 46; 4;4]);
assignin('base','Analysis_Region',Analysis_Region);
%Initial
Initial_Set{1}=linearcon([],[],[-1 0 0; 1 0 0; 0 -1 0; 0 1 0;0 0 1; 0 0 -1],[-20; 40; 0; 1; 0.101;-0.099]);
assignin('base','Initial_Set',Initial_Set);

GLOBAL_SYSTEM = 'acc';
GLOBAL_APARAM = 'acc_param';
GLOBAL_SPEC={};

return