function approx_param = parameters(q) 

% This file contains all of the numerical paramters used for verification of the system.
% For each value, a default parameter is used unless the user specifies one.
% Added by Jim Kapinski 2/2002.
% Some values added by OS, 06/2002.

global GLOBAL_APARAM
global GLOBAL_ODE_PAR
global GLOBAL_OPTIM_PAR

% >>>>>>>>>>>> Parameter Change -- OS -- 06/13/02 <<<<<<<<<<<<
% change of 'approx_param.W' moved to verify.m
% >>>>>>>>>>>> -------------- end --------------- <<<<<<<<<<<<


%List of default parameters.
%***************************************************************************************************************************
approx_param.dir_tol = [];                      % tolerance in the direction (angle offset)
approx_param.var_tol = [];                      % length of the projection in the cell
approx_param.size_tol = [];                     % maximum size of each piece
approx_param.T = 1;                             % size of each flowpipe segment
approx_param.quantization_resolution = []; 
approx_param.max_bissection = 3;                % maximum number of bissection for simulation reachability
approx_param.max_time = Inf;                    % maximum time of processing
approx_param.reachability_depth = Inf; 
approx_param.W = []; 

approx_param.min_angle 		= 5;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.med_angle 		= 10;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.extra_angle	= 30;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.max_angle 		= 110;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.unbound_angle = 160;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.edge_factor = 2;				    % Factor to decide if edge will be dropped in the mapping
approx_param.edge_med_length = 1000;	        % Factor to decide if an edge is too small (compared to the mean) to be eliminate

%New parameters as of 2/2002
approx_param.grow_size = 1e-3;                  % For growing operations (when there is a loss of dimension), objects are
                                                % grown by this much ON EACH SIDE.
approx_param.max_func_calls = 1e3;              % Maximum number of function evaluations allowed for fmincon operations.
                                                % Note that this value will be multiplied by the system dimension.
approx_param.func_tol = 1e-4;                   % Termination tolerance on the function value for fmincon operations.
                                                % Note that this number will be multiplied by the time step size for 
                                                % shrink wrapping operations during flowpipe computations.
approx_param.max_iter = 1e4;                   % Number of iterations for fmincon calls. Note that this number will
                                                % be multiplied by the dimension of the problem.

%Polyhedral object parameters                                                
approx_param.poly_epsilon = 1e-9;               %   *'epsilon'--tolerance used in feasibility check
approx_param.poly_bigM = 1e9;                   %   *'bigM'--big M used to check constraint's redundancy
approx_param.poly_point_tol = 1e-12;            %   *'point_tol' tolerance used in point comparison (distance based)
approx_param.poly_vector_tol = 1e-9;            %   *'vector_tol' tolerance used in vector comparison (direction based)
approx_param.poly_hyperplane_tol = 1e-9;        %   *'hyperplane_tol'--tolerance used in hyperplane comparison
approx_param.poly_bloat_tol = 1e-5;             %   *'bloat_tol'--tolerance used to bloat a polyhedron in flat dimensions
approx_param.hull_flag = 'hyperrectangle';      %   *'hull_flag'--flag to choose between computation of a convex hull ('convexhull') or an oriented hyperrectangular hull ('hyperrectangle')
approx_param.optimize_facet = true;
approx_param.poly_svd_tol = 1e-6;               %   *'svd_tol'--tolerance below which singular values are considered to be zero
approx_param.verbosity = 0;                     %   *'verbosity'--determines on a scale from 0 to 2 how much feedback is given during verification


%Step responses
approx_param.step_rel_tol = 1e-5;               % Relative tolerance for step responses.
approx_param.step_abs_tol = 1e-6;              % Absolute tolerance for step responses.

approx_param.perform_init_reachability = 1;     %Flag that tells CheckMate if initial reachability should be performed or not.
                                                %('1' means perform initial reachability and '0' means do not)

%***************************************************************************************************************************


% Replace default parameters with user-defined values:
if ~isempty(GLOBAL_APARAM) && ~isempty(which(GLOBAL_APARAM))
   param_temp=feval(GLOBAL_APARAM,q);
   fieldlist=fieldnames(param_temp);
   for i=1:length(fieldlist)
      if isfield(approx_param,fieldlist{i})
         approx_param.(fieldlist{i})= param_temp.(fieldlist{i});
      else
         error('CheckMate:Parameter:WrongField', ...
         'User-specified parameter "%s" is invalid!',fieldlist{i});       
      end
   end
end

% Struct with parameters for numerical ODE solution:
GLOBAL_ODE_PAR = odeset('RelTol',approx_param.step_rel_tol,'AbsTol',approx_param.step_abs_tol);

% Struct with parameters for numerical ODE solution:
GLOBAL_OPTIM_PAR = optimset('Display','off','LargeScale','off');


return

