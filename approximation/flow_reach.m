function [reachable,time_limit] = flow_reach(X0,l0,cell)

% Perform conservative reachability analysis using `flow pipe
% approximations` from the given initial location and continuous set.
%
% Syntax:
%   "reachable = flow_reach(X0,l0,cell)"
%
% Description:
%   Given the initial location "l0" and the cell region "cell" and the
%   "linearcon" object "X0" representing the initial continuous set, use
%   `flow pipe approximations` to conservatively approximate the reachable
%   polytopes at the location entry points that along the trajectories from
%   the polytope "X0" in location "l0". The input "param_file" is a string
%   containing the user specified m-file function that returns the
%   approiximation parameters.
%
%
%
%   The output "reachable" is a structure array representing the
%   reachable polytopes with the following fields
%
%   * ".polytope": a "linearcon" object representing the entry polytope
%
%   * " .mapping"; a "linearcon" object representing the reachable set 
%     starting with the polytope.
%
%   * ".location": the location index
%
%   * ".face": the index to the invariant face of the location that the
%     polytope belongs to.
%
%   * ".depth": an integer counting the number of FSM state switches (not
%     the location switches) along the trajectory that leads to the current
%     polytope.
%
% Implementation:
%   Get the approximation parameters by calling parameter file with the FSM
%   state vector "q". The relevant approximation parameters for this
%   function are: 
%
%   * "W": "nxn" diagonal weighting matrix
%
%   * "quantization_resolution": the resolution for the `bounding box`
%     computation (weighted by "W").
%
%   * "reachability_depth": an integer specifying the maximum number of FSM
%     state switches that is allowed along any path before the reachability
%     analysis is terminated. This parameter must be independent of the
%     FSM state vector "q".
%
%   The initial polytope is put at the head of the queue and the set of
%   reachable polytope is computed using breadth-first search as follows. A
%   polytope is removed from the queue and appended to the output array
%   "reachable". If the depth count for that polytope is less than
%   "reachability_depth", the `mapping set` is computed for that polytope,
%   otherwise do nothing. If the continuous dynamics for the current
%   location is not of type "'clock'", the mapping set on each face of the
%   invariant is then over approximated by a single rectangular polytope,
%   called the `bounding box` in the source code (see the in-file comments
%   for more detail on the bounding box computation). For "'clock'"
%   dynamics, no over approximation is performed, i.e. the bounding box is
%   the mapping itself. Each bounding box is then put into the queue with
%   the depth count incremented if the FSM state in the destination location
%   of the bounding box is different from the source location. The process
%   continues until the queue is empty, meaning that there is no more
%   polytope to be processed.
%
% See Also:
%   iauto_part,compute_mapping,linearcon

global GLOBAL_PIHA 
global GLOBAL_APPROX_PARAM

% reachability depth should be independent of fsm discrete state q

max_depth = GLOBAL_APPROX_PARAM.reachability_depth;

% initialize the initial state and put it into the queue
mapping_state=[];
destination_loc =[];
destination_cell = [];
time_limit = 0;
init = [];
init.polytope = X0;
init.mapping = {};
init.location = l0;
init.cell=cell;
init.Tstamp = [0 0];
init.depth = 0;
init.destination_loc=[];
init.destination_cell=[];
% >>>>>>>>>>>> Field Initialization (Initial State) -- DJ -- 06/30/03 <<<<<<<<<<<<
% Added by Dong Jia to initialize fields for the initial state
init.destination={};
init.null_event=0;
init.time_limit=0;
init.out_of_bound=0;
init.terminal={};
% >>>>>>>>>>>> -------------- end (Field Initialization (Initial State)) --------------- <<<<<<<<<<<<
queue = insert_queue([],init);

first = 1;
reachable = [];
while ~isempty(queue)
  % remove a state from the head of the queue and compute the mapping for it
  [queue,state] = remove_queue(queue);
  reachable = [reachable state];
  X0 = state.polytope; 
  loc = state.location; 
  cell=state.cell;
  Tstamp= state.Tstamp;
  depth = state.depth;
  % Perform further reachability analysis if the maximum path depth is
  % not exceeded.
  if (depth < max_depth)
    % if entering this loop for the first time, set the state type to
    % 'init'
    % clc;
    if first
      sttype = 'init';
      first = 0;
      fprintf(1,'depth %d: initial state in location %d cell region %d.\n', ...
              depth,loc,cell)
    else
      sttype = 'face';
      fprintf(1,'depth %d: in location %d cell region %d.\n',depth,loc,cell)
    end
    [destination,null_event,time_limit,out_of_bound,terminal] = ...
        compute_mapping(X0,loc,cell);
    
% >>>>>>>>>>>> Recording Reachability Results  -- DJ -- 06/30/03 <<<<<<<<<<<<
% Added by Dong Jia to record all information from reachability
% analysis.
    len_reachable=length(reachable);
    reachable(len_reachable).destination=destination;
    reachable(len_reachable).null_event=null_event;
    reachable(len_reachable).time_limit=time_limit;
    reachable(len_reachable).out_of_bound=out_of_bound;
    reachable(len_reachable).terminal=terminal;
% >>>>>>>>>>>> -------------- end (Recording Reachability Results) --------------- <<<<<<<<<<<<
    
    overall_dynamics = check_overall_dynamics(GLOBAL_PIHA.SCSBlocks, ...
                                              GLOBAL_PIHA.Locations{loc}.q);
    mapping_state = {};
    destination_loc=[];
    destination_cell=[];
    destination_Tstamp = [];
    for k = 1:length(destination)
      dst_loc      =   destination{k}.location;
      dst_cell     =   destination{k}.cell;
      dst_mapping  =   destination{k}.mapping;
      dst_theta    =   destination{k}.transition_theta;
      if dst_theta
        transition_theta_flag=1;
      end
% >>>>>>>>>>>> Checking Set Containment -- DJ -- 06/30/03 <<<<<<<<<<<<
% Added by Dong Jia to see if the new reachable set is a subset of a
% previous reachable set.
      isasubset=0;
      for m=1:length(reachable)-1
          if issubset(dst_mapping,reachable(m).polytope)
              isasubset=1;
              mapping_state{k}=destination{k}.mapping;
              break;
          end
      end
% >>>>>>>>>>>> -------------- end (Checking Set Containment) --------------- <<<<<<<<<<<<
% >>>>>>>>>>>> Hanling New Set -- DJ -- 06/30/03 <<<<<<<<<<<<
% The following if-end pair is added by Dong Jia. Only when the reachable
% set is new, it is added to the que.
      if ~isasubset
          [dum1,dum2,cell_indx] = ...
              intersect(dst_cell,GLOBAL_PIHA.Locations{dst_loc}.interior_cells);
          % ***********************************************************************
          % This section adds a new region to the PIHA because a guard region
          % was entered and the transition was not taken.
          if dst_loc==loc && isempty(cell_indx)
            add_region(loc,dst_cell);
            [dum1,dum2,cell_indx] = ...
                intersect(dst_cell,GLOBAL_PIHA.Locations{dst_loc}.interior_cells);
          end
          % ***********************************************************************
          newstate = {};
          newstate.polytope = destination{k}.mapping;
          newstate.mapping  = {};  
          newstate.location = destination{k}.location;
          newstate.cell = destination{k}.cell;
          newstate.Tstamp = destination{k}.Tstamp;
          newstate.depth = depth + ...
              (loc ~= destination{k}.location | destination{k}.transition_theta);
          newstate.destination_loc=[];
          newstate.destination_cell=[];
% >>>>>>>>>>>> Field Initialization (New States) -- DJ -- 06/30/03 <<<<<<<<<<<<
% Added by Dong Jia to record all information from reachability
% analysis.
		  newstate.destination={};
		  newstate.null_event=0;
		  newstate.time_limit=0;
		  newstate.out_of_bound=0;
		  newstate.terminal={};
% >>>>>>>>>>>> -------------- end (Field Initialization (New State)) --------------- <<<<<<<<<<<<
          queue = insert_queue(queue,newstate);
          mapping_state{k}=destination{k}.mapping;
          destination_loc(k)=destination{k}.location;
          destination_cell(k)=destination{k}.cell;
      end
% >>>>>>>>>>>> -------------- end (Handling New Set) --------------- <<<<<<<<<<<<
    end
% >>>>>>>>>>>> Updating Reachability Mapping -- DJ -- 06/30/03 <<<<<<<<<<<<
% Added by Dong Jia to record the mapping information
      reachable(length(reachable)).mapping = mapping_state;
      reachable(length(reachable)).destination_loc = destination_loc;
      reachable(length(reachable)).destination_cell = destination_cell;
% >>>>>>>>>>>> -------------- end (Updating Reachability Mapping) --------------- <<<<<<<<<<<<
  end

% =========================================================================
% Commented by Dong Jia from
%   reachable(length(reachable)).mapping = mapping_state;
%   reachable(length(reachable)).destination_loc = destination_loc;
%   reachable(length(reachable)).destination_cell = destination_cell;
% =========================================================================

end

return

