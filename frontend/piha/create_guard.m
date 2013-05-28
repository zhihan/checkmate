function [guard_cells,guard_cell_event_flags,guard_compl_cells] =      create_guard(cond_expr,event_expr,pthbHandle,pthb,NAR,only_condition_inputs_flag)
% moved

% This procedure divides up the analysis region and returns pointers
% to cells that describe a guard region.

global CELLS

guard_cells=[];
guard_compl_cells=[];
guard_cell_event_flags=[];

% Find all PTHBs which appear in condition expression.
guard_pthbs = [];
for i = 1:length(pthbHandle)
    name = get_param(pthbHandle(i),'name');
    % Need to fix the code below since findstr() will return all
    % matching substrings, which may be incorrect.
    if ~isempty(findstr(cond_expr,name))
        guard_pthbs=[guard_pthbs i];
    end
end

% Find all PTHBs which appear in event expression. Also, create the
% list of all hyperplanes associated with event PTHBs.
event_pthbs = [];
event_hps = [];
for i = 1:length(pthbHandle)
    name = get_param(pthbHandle(i),'name');
    % Need to fix the code below since findstr() will return all
    % matching substrings, which may be incorrect.
    if ~isempty(findstr(event_expr,name))
        event_pthbs = [event_pthbs i];
        event_hps = union(event_hps,pthb{i}.hps);
    end
end

% Find overall transition expression, which is the conjunction of
% event and condition expressions.
if ~isempty(cond_expr) && ~isempty(event_expr)
    trans_expr= ['(' event_expr ')&(' cond_expr ')'];
elseif ~isempty(event_expr)
    trans_expr = event_expr;
elseif ~isempty(cond_expr)
    trans_expr = cond_expr;
else
    error('CheckMate:PIHA', 'No transition expression found.')
end

% Initialize the state-space partition with the analysis region as
% a single cell in the partition. The partition will be refined
% iteratively by subtracting each PTHB off each cell in the
% partition in each pass.
[CAR,dAR] = cell_ineq(1:NAR,ones(1,NAR));
partition.poly = linearcon([],[],CAR,dAR);
partition.pthflags = -1*ones(1,length(pthbHandle));

% Refine the state space partition with PTHBs associated with
% condition and event expressions, respectively.
pthbs_used = [guard_pthbs event_pthbs];
partition = partition_ss(partition,pthbs_used,pthb);

% Classify each cell in the partition created above as 'guard' or
% 'guard complement' cells. Add new cells in the partition just
% created to the global cell list CELLS. The result of this function
% will point to regions in this cell list.
for k = 1:length(partition)

    % Find the boundary hyperplane indices along with their direction
    % and event flags in the global hyperplane list HYPERPLANES.
    [CEk,dEk,CIk,dIk] = linearcon_data(partition(k).poly);
    [boundary,hpflags] = ineq2cell(CIk,dIk);
    pthflags = partition(k).pthflags;

    % Test to see if the current cell is a 'repeat' of a region that was
    % already created in the global cell list CELLS.
    repeat_test = is_repeat(boundary,hpflags);
    if repeat_test == 0
        new = length(CELLS)+1;
        CELLS{new}.boundary = boundary;
        CELLS{new}.hpflags = hpflags;
        CELLS{new}.pthflags = pthflags;
    end

    % Test to see if current cell satisfies overall transition
    % expression. If it does, add current cell to guard list. If it does
    % not, add current cell to guard complement list.

    % First replace PTHB names in the transition expression with their
    % logical values for the current cell.
    test_expr = trans_expr;
    for pthb_index = pthbs_used
        flag = pthflags(pthb_index);
        name = get_param(pthbHandle(pthb_index),'name');
        % Need to fix the code below since strrep() will also replace
        % matching substrings, which may be incorrect.
        test_expr = strrep(test_expr,name,num2str(flag));
    end
    % Now evaluate transition expression.
    test = eval(test_expr);

    if test
        % Compute event flags for the current cell boundary hyperplanes.
        if only_condition_inputs_flag
            event_flags = ones(size(boundary));
        else
            event_flags = zeros(size(boundary));
        end
        [temp,iboundary] = intersect(boundary,event_hps);
        event_flags(iboundary) = 1;
        guard_cell_event_flags{end+1} = event_flags;
        % Add the current cell index (w.r.t. CELLS) to the list of guard cells.
        if repeat_test == 0
            guard_cells = [guard_cells new];
        else
            guard_cells = [guard_cells repeat_test];
        end
    else
        % Add the current cell index (w.r.t. CELLS) to the list of guard
        % complement cells.
        if repeat_test == 0
            guard_compl_cells = [guard_compl_cells new];
        else
            guard_compl_cells = [guard_compl_cells repeat_test];
        end
    end

end

return
% -----------------------------------------------------------------------------
