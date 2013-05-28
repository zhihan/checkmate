function trace = extract_trace(sysinfo)

% Extract a discrete trace transistion system from Simulink simulation
% data
%
% Syntax:
%   "trace = extract_trace(sysinfo)"
%
% Description:
%   "extract_trace(sysinfo)" uses simulation data from the main workspace
%   and system information contained in "sysinfo" to set up the variable
%   GLOBAL_TRANSISTION and return a structure array with the following
%   fields for each trace location pointed to by GLOBAL_TRANSITION.
%
%   * ".t" time at location entry
%
%   * ".x" continuous state upon entry of location
%
%   * ".q" discrete state upon entry of location
%
%   * ".special" used to indicate end of the trace, and condition under
%   which the trace ended.  the four possible values are
%   "time_limit","terminal","null_event", or "out_of_bound"
%
% See Also:
%   validate

global GLOBAL_TRANSITION
global GLOBAL_REV_TRANSITION
global GLOBAL_APPROX_PARAM

% t - time (scalar)
% x - continuous state vector
% q - discrete (FSM) state vector
% pth - polyhedral threshold vector
t = evalin('caller',sysinfo.clk{1}.variable);

x = [];
for k = 1:length(sysinfo.scsbList)
    x = [x evalin('caller',sysinfo.scsbList{k}.variable)];
end
% Check if the continuous trajectory ended because it went out-of-bound
C = get_linearcon_param(sysinfo.AR,'CI');
d = get_linearcon_param(sysinfo.AR,'dI');
epsilon = GLOBAL_APPROX_PARAM.poly_epsilon;
out_of_bound = 0;
for k = 1:length(d)
    if (C(k,:)*x(size(x,1),:)' > d(k)-epsilon)
        out_of_bound = 1;
        break;
    end
end

q = [];
for k = 1:length(sysinfo.fsmbList)
    q = [q evalin('caller',sysinfo.fsmbList{k}.variable)];
end

pth = [];
for k = 1:length(sysinfo.pthbList)
    pth = [pth evalin('caller',sysinfo.pthbList{k}.variable)];
end

equilibrium = 0;
idx = length(t)-1;
if (idx >= 1) && ...
        all(q(idx,:) == q(idx+1,:)) && all(pth(idx,:) == pth(idx+1,:))
    diff = x(idx,:) - x(idx-1,:);
    if sqrt(diff*diff') < 1e-3
        equilibrium = 1;
    end
end

if 0
    % Delete the beginning of the trace where q == 0
    idx = 1;
    while all(q(idx,:) == 0)
        idx = idx + 1;
    end
    N = length(t);
    t = t(idx:N,:);
    x = x(idx:N,:);
    q = q(idx:N,:);
    pth = pth(idx:N,:);
end

% Collapse consecutive samples with the same discrete signal values,
% i.e. same q and pthb, and retain only the first one.
idx = 1;
while idx < length(t)
    if all(q(idx,:) == q(idx+1,:)) && all(pth(idx,:) == pth(idx+1,:))
        N = length(t);
        t = [t(1:idx,:); t(idx+2:N,:)];
        x = [x(1:idx,:); x(idx+2:N,:)];
        q = [q(1:idx,:); q(idx+2:N,:)];
        pth = [pth(1:idx,:); pth(idx+2:N,:)];
    else
        idx = idx + 1;
    end
end

% Build a simple transition graph representing the trace.
GLOBAL_TRANSITION = {};
trace = {};
for k = 1:length(t)
    trace{k}.t = t(k,:);
    trace{k}.x = x(k,:);
    trace{k}.q = q(k,:);
    trace{k}.pth = pth(k,:);
    trace{k}.special = {};
    GLOBAL_TRANSITION{k} = k+1;
end

% Determine how the trace ended. There are 4 cases.
% (i) the trajectory simply got cut off by the simulation time limit
% (ii) the trajectory went of the analysis region
% (iii) last state is a terminal state
% (iv) null event occurs (equilibrium, limit-cycles, etc..)
% We will only handle the first three cases for now.

N = length(t);
% Case (i) is the default.
trace{N}.special = 'time_limit';
GLOBAL_TRANSITION{N} = N;
GLOBAL_REV_TRANSITION = revtran(GLOBAL_TRANSITION);


if out_of_bound
    trace{N}.special = 'out_of_bound';
else
    % If the last state is a terminal state, indicate so in the .special
    % field of the last state in the trace.
    terminal = 1;
    for k = 1:length(trace{N}.q)
        if ~(sysinfo.fsmbList{k}.states{trace{N}.q(k)}.terminal)
            terminal = 0;
            break;
        end
    end
    if terminal
        trace{N}.special = 'terminal';
    else
        if equilibrium
            trace{N}.special = 'null_event';
        end
    end
end
