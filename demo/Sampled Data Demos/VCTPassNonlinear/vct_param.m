function approx_param =vct_param(q)

% Set verification parameters for the vct
%
% Syntax:
%   "approx_param = pcontrol_param(q)"
%
% Description:
%   "pcontrol_param(q)" sets approximation parameters used by CheckMate in the
%   verification procedure.  The parameters are returned in a structure
%   with the following fields: 
%
%   *".dir_tol" tolerance for patch "single-sided-ness" 
%
%   *".var_tol" tolerance for patch vector field variation relative to the
%   vector field variation on the parent invariant face
%
%   *".size_tol" tolerance for patch size 
%
%   *".W" (diagonal) weighting matrix 
%
%   *".T" time step for flow pipe computation
%
%   *".max_time" time limit (sec) for mapping computation
%
%   *".eq_tol" equilibrium termination tolerance for mapping computation 
%
%   *".quantization_resolution" resolution for partition refinement
%
%   *".reachability_depth" maximum depth of initial partition reachability
%   analysis
%
% See Also:
%   setup

approx_param.hull_flag = 'hyperrectangle';
approx_param.dir_tol = [];
approx_param.var_tol = [];
approx_param.size_tol = [];
approx_param.W = eye(2);
approx_param.T = [];
approx_param.quantization_resolution = [];
approx_param.max_time = .01;
approx_param.reachability_depth = Inf;
approx_param.max_bissection    = 6;				% maximum number of bissection for simulation reachability

approx_param.quantization_resolution = 0.01;	%
approx_param.min_angle 		= 5;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.med_angle 		= 10;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.extra_angle	= 30;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.max_angle 		= 110;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.unbound_angle = 160;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.edge_factor = 2;						% Factor to decide if edge will be dropped in the mapping
approx_param.edge_med_length = 1000;				% Factor to decide if an edge is too small (compared to the mean) to be eliminate
