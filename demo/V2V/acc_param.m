function approx_param = acc_param(q) 

% This is the paramter file for the Boing example.  This file contains all of the numerical
% paramters used for verification of the system.
%  
%   Boing is a model of a bouncing ball.  See the readme.txt file 
%   in the boing directory for a complete description of (and getting started guide for)
%   the boing example.

approx_param.dir_tol = [];                      % tolerance in the direction (angle offset)
approx_param.var_tol = [];                      % length of the projection in the cell
approx_param.size_tol = [];                     % maximum size of each piece
approx_param.W = eye(3);                        % matrix to square the axes to avoid numerical problems 
approx_param.T = 0.1;                             % size of each flowpipe segmen
approx_param.quantization_resolution = []; 
approx_param.max_bissection =6;                % maximum number of bissection for simulation reachability
approx_param.max_time = 30;                    % maximum time of processing
approx_param.reachability_depth = 6; 

approx_param.min_angle 		= 5;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.med_angle 		= 10;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.extra_angle	= 30;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.max_angle 		= 110;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.unbound_angle = 160;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.edge_factor = 2;				    % Factor to decide if edge will be dropped in the mapping
approx_param.edge_med_length = 1000;	        % Factor to decide if an edge is too small (compared to the mean) to be eliminate
approx_param.perform_init_reachability = 1;     %Flag that decides if initial reachability is perform or not.

approx_param.step_rel_tol = 1e-2;               % Relative tolerance for step responses.
approx_param.step_abs_tol = 1e-3;              % Absolute tolerance for step responses.
approx_param.func_tol = 1e-3;                   % Termination tolerance on t

approx_param.hull_flag = 'hyperrectangle';

