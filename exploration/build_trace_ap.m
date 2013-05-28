function atomic_propositions = build_trace_ap(ap_build_list,sysinfo,trace)

% Build atomic proposition regions for a single discrete trace 
%
% Syntax:
%   "atomic_propositions = build_trace_ap(ap_build_list,sysinfo,trace)"
%
% Description:
%   "build_trace_ap(ap_build_list,sysinfo,trace)" returns a structure of
%   region objects containing the locations in "trace" that satisfy the
%   atomic propositions (APs) in "ap_build_list".  The fields in the structure
%   are named after the APs in "ap_build_list" and each field contains
%   the region object satisfying the AP for which it is named.  Necessary
%   system information is passed to the function using the "sysinfo"
%   structure.
%
% See Also:
%   build_ap,compile_sys_info,validate

atomic_propositions = [];
for k = 1:length(ap_build_list)
  switch ap_build_list{k}.build_info{1}
    case 'polyap',
      temp = build_poly_ap(ap_build_list{k}.name,sysinfo,trace);
    case 'fsmap',
      fsmname = ap_build_list{k}.build_info{2};
      statename = ap_build_list{k}.build_info{3};
      temp = build_fsm_ap(fsmname,statename,sysinfo,trace);
    otherwise
      error('CheckMate:Explore:InvalidAP', ['Invalid atomic proposition type ''' ... 
            ap_build_list{k}.build_info{1} '''.'])
  end
  atomic_propositions.(ap_build_list{k}.name) = temp;
end

% -----------------------------------------------------------------------------

function ap = build_poly_ap(apname,sysinfo,trace)

global GLOBAL_TRANSITION

% build region for apname if it is a new atomic proposition
N = length(GLOBAL_TRANSITION);
switch apname
  case {'null_event','time_limit','out_of_bound','indeterminate'},
    ap = region(N,'false');
    if strcmp(trace{N}.special,apname)
      ap = set_state(ap,N,1);
    end
  otherwise,
    % otherwise apname must be PTHB name
    found = 0;
    for k = 1:length(sysinfo.pthbList)
      if strcmp(apname,sysinfo.pthbList{k}.name)
        found = 1;
        pthidx = k;
        break
      end
    end
    if found
      ap = region(N,'false');
      for k = 1:N
	pthflags = trace{k}.pth;
	if pthflags(pthidx)
	  ap = set_state(ap,k,1);
	end
      end
    else
      error('CheckMate:InvalidAP', ...
          ['Invalid atomic proposition name ''' apname '''.'])
    end
end

% -----------------------------------------------------------------------------

function ap = build_fsm_ap(fsmname,statename,sysinfo,trace)

global GLOBAL_TRANSITION

found = 0;
for k = 1:length(sysinfo.fsmbList)
  if strcmp(fsmname,sysinfo.fsmbList{k}.name)
    fsmidx = k;
    found = 1;
    break;
  end
end
if ~found
  error('CheckMate:InvalidFSM', ...
      ['Invalid FSM block name ''' fsmname '''.'])
end

found = 0;
for k = 1:length(sysinfo.fsmbList{fsmidx}.states)
  if strcmp(statename,sysinfo.fsmbList{fsmidx}.states{k}.name)
    stateidx = k;
    found = 1;
    break;
  end
end
if ~found
  error('CheckMate:InvalidState', ...
  ['Invalid state name ''' statename ''' for FSM block ''' ...
        fsmname '''.'])
end

N = length(GLOBAL_TRANSITION);
ap = region(N,'false');
for k = 1:N
  if (trace{k}.q(fsmidx) == stateidx)
    ap = set_state(ap,k,1);
  end
end
return
