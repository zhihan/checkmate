function approx_param = ph_param(q)

approx_param = [];
approx_param.dir_tol = [];							% tolerance in the direction (angle offset)
approx_param.var_tol = 10e-4;						% length of the projection in the cell
approx_param.size_tol = 10e-4;						% maximum size of each piece
approx_param.W = [1 0;0 1];	%matrix to square the axes to avoid numerical problems 
approx_param.T = 0.4;								% size of each flowpipe segmen
approx_param.max_bissection    = 6;				% maximum number of bissection for simulation reachability
approx_param.max_time = 10;						% maximum time of processing
approx_param.quantization_resolution = 0.01;	%
approx_param.reachability_depth = 50;			    % Max depth (number of transitions) 
approx_param.min_angle 		= 5;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.med_angle 		= 10;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.extra_angle	= 30;					% Angle value (degrees) for eliminating faces in the mapping
approx_param.max_angle 		= 110;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.unbound_angle = 160;				% Angle value (degrees) for eliminating faces in the mapping
approx_param.edge_factor = 2;						% Factor to decide if edge will be dropped in the mapping
approx_param.edge_med_length = 1000;				% Factor to decide if an edge is too small (compared to the mean) to be eliminate
return
