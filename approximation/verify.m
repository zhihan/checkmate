function verify(varargin)

% Perform verification of a CheckMate model.
%
% Syntax:
%   "verify"
%
%   "verify -option1 -option2 ..."
%
% Description:
%   "verify" uses the parameters returned by the function contained in
%   "GLOBAL_APARAM" to perform verification of the ACTL specification in
%   "GLOBAL_SPEC" on the system named in "GLOBAL_SYSTEM".  These global
%   variables must be set up and the model in "GLOBAL_SYSTEM" must be open
%   prior to invoking the "verify" command.  This can be accomplished
%   manually or via an m-file script or function.  "verify -option1
%   -option2 ..." allows for any combination of the options described
%   below.
%
%   *"step <step>" execute only the single verification step "step"
%
%   *"resume" continue the verification process using the current
%   workspace data
%
%   *"nopause" refine the quotient system without prompting the user for
%   input
%
%   *"save <savefile>" save the workspace data after each iteration using
%   "savefileN.mat" to save the data after the Nth iteration
%
%   *"close" close the Simulink model after the PIHA has been constructed
%
%   *"discard" throw away all unreachable states in each iteration
%
% Examples:
%   See the examples in CMRoot/demo.
%
% Implementation:
%   The "verify" routine is divided into several steps:
%
%
%
%   The first step is "'piha_conversion'".  In this step, the analysis
%   region (AR) is partitioned into cells using the hyperplanes from each
%   of the polyhedral threshold blocks (PTHBs), and locations are created
%   from combinations of these cells, and the discrete states of the
%   system.  The set of locations is intersected with the `initial
%   continuous set (ICS)` from the CheckMate model to find the set of
%   `initial locations`.  The intial locations are then used to build a
%   polyhedral invariant hybrid automaton (PIHA) representation of the
%   system.  Finally, the PIHA is stored for future use in the global
%   variable "GLOBAL_PIHA".
%
%
%
%   In the next step, "'iauto_part'", the PIHA is discretized and a few
%   special states are added to each location to form the initial
%   approximating automaton.  This approximating automaton is stored in
%   the variable "GLOBAL_AUTOMATON".
%
%
%
%   "'iauto_build'" builds the initial automaton iteratively.  During this
%   step, the routine computes the mappings for the states in the
%   approximating automaton "GLOBAL_AUTOMATON" that are reachable from the
%   initial states and updates the transition relation. If new states are
%   found, then mappings are computed for those states, and the process
%   is repeated until no new states are found.  This step concludes by
%   generating a generic transition system "GLOBAL_TRANSITION" which is
%   used to perform the actual ACTL verification.
%
%
%
%   Next, in the step "'parse_spec'", the ACTL specification is processed
%   and several related global variables are set up.  "GLOBAL_SPEC_TREE"
%   contains the parsed ACTL specification in a tree structure.
%   "GLOBAL_AP_BUILD_LIST" contains the parse tree modified by collapsing
%   the raw terminal symbols into the appropriate CheckMate atomic
%   propostions.
%
%
%
%   In the "'refinement_decision'" step, the ACTL specification is
%   evaluated in relation to the current approximating automaton.  If
%   "GLOBAL_AUTOMATON" satisfies the specification, then the user is
%   informed that the system already satisfies the specification and no
%   refinement is necessary.  If the system does not satisfy the
%   specification, the user is presented with a list of states that could
%   be refined ("GLOBAL_TBR") to form a better approximation, and
%   prompted for a decision continue.  The user can press any key to
%   continue, or press ctrl-C to break the program.  The workspace data
%   can be saved, and used to continue the verification at a later time.
%
%
%
%   If the current approximation already satisfies the ACTL
%   specification, then the next step is "'done'" and the routine
%   terminates.  However, if the system does not satisfy the
%   specification, and the user chooses to continue, the next step is
%   "'refine_automaton'" and the process continues.
%
%
%
%   In the "'refine_automaton'" step, the polytope for each state listed
%   in "GLOBAL_TBR" is split into multiple polytopes.  These refined
%   states are placed in "GLOBAL_NEW_AUTOMATON" along with copies of the
%   states that are not refined.  The indices of the newly split states in
%   "GLOBAL_NEW_AUTOMATON" are added to the cell array
%   "GLOBAL_RAUTO_REMAP_LIST". This is the list of states for which the
%   mapping set needs to be re-computed.
%
%
%
%   "'rauto_mapping'" takes the state indices in "GLOBAL_RAUTO_REMAP_LIST"
%   and re-computes the mapping from those states in
%   "GLOBAL_NEW_AUTOMATON".  Once the mapping is completed for the new
%   approximating automaton, the transitions must be updated as well.
%
%
%
%   "'rauto_transition'" updates the transitions in
%   "GLOBAL_NEW_AUTOMATON", to reflect the changes caused by the refinement
%   of "GLOBAL_AUTOMATON".  Once this step is finished, the refinement is
%   complete and "GLOBAL_NEW_AUTOMATON" contains the newly refined
%   approximating automaton.
%
%
%
%   The next step, "'update_automaton'" updates the workspace variables
%   in preparation for the next iteration of the verification process.
%   "GLOBAL_AUTOMATON" is updated to contain a copy of
%   "GLOBAL_NEW_AUTOMATON", "GLOBAL_NEW_AUTOMATON" is reset to an empty cell
%   array, and the iteration counter, "GLOBAL_ITERATION", is incremented by
%   one.
%
%
%
%   The final step in the refinement process is to update the generic
%   transition system in "GLOBAL_TRANSITION".  This is accomplished by
%   generateing a new generic transition system from the updated
%   "GLOBAL_AUTOMATON" and replacing the old "GLOBAL_TRANSITION" with
%   the new transition system.
%
%
%
%   From this point, the process returns to the "'parse_spec'" step, and
%   repeats until the current approximation satisfies the ACTL
%   specification, or until the user chooses to break the program.
%   The progress of the routine is saved in the variable
%   "GLOBAL_PROGRESS", so that the routine can be stopped and restarted
%   from almost any point in the process.
%
% See Also:
%   validate,piha,iauto_part,iauto_build,parse,compile_ap,build_ap,evaluate,
%   refine_auto,rauto_mapping,rauto_tran,auto2xsys

%
% Last change: 11/18/2002 JPK


%init_time = cputime;
% Declare global variables (see the file global_var.m for details)
initial_time=cputime;
global_var;

GLOBAL_APPROX_PARAM=parameters(1);
try_before_iauto_build=0;
[single_step_flag, start_flag, pause_flag, save_flag, ...
    savefile, close_flag, discard_flag] = check_input(nargin, varargin);

while ~ismember(GLOBAL_PROGRESS.step,{'done'})
    switch GLOBAL_PROGRESS.step
        case 'piha_conversion'
            fprintf(1,'Performing PIHA conversion.\n')
            init_time = cputime;
            piha(GLOBAL_SYSTEM);
            GLOBAL_TIME_ELAPSED.piha_conversion = cputime - init_time;
            fprintf(1,'PIHA conversion completed in %6.2f seconds.\n',GLOBAL_TIME_ELAPSED.piha_conversion)
            if close_flag
                close_system(GLOBAL_SYSTEM)
            end
            next_step = 'iauto_part';
        case 'iauto_part',
            fprintf(1,'\n')
            init_time = cputime;
            iauto_part;
            GLOBAL_TIME_ELAPSED.iauto_part= cputime - init_time;
            fprintf(1,'reachability analysis and initial partition completed in %6.2f seconds.\n',GLOBAL_TIME_ELAPSED.iauto_part)
            next_step = 'iauto_build';
        case 'iauto_build'
            if try_before_iauto_build
                auto2xsys;
                next_step = 'parse_spec';
            else
                fprintf(1,'\n')
                continu = isfield(GLOBAL_PROGRESS,'idx');
                init_time = cputime;
                iauto_build(continu);
                GLOBAL_TIME_ELAPSED.iauto_build(length(GLOBAL_TIME_ELAPSED.iauto_build)+1)= cputime - init_time;
                fprintf(1,'construction of transition system completed in %6.2f seconds.\n',...
                    GLOBAL_TIME_ELAPSED.iauto_build(length(GLOBAL_TIME_ELAPSED.iauto_build)))
                if discard_flag
                    remove_unreachables;
                end
                next_step = 'parse_spec';
            end
        case 'parse_spec'
            %Test Stateflow state names.  If any are named 'avoid' or 'reach' create
            %a new specification automatically.  The specification should be AG~avoid
            %and/or AFreach.  Added by Jim K 2/10/2002.
            parse_spec();
            next_step = 'refinement_decision';
        case 'refinement_decision',
            next_step = make_decision();
        case 'refine_automaton',
            if save_flag
                save([savefile num2str(GLOBAL_ITERATION)])
            end
            if pause_flag
                fprintf(1,'Please resume verification to refine the abstraction.\n')
                return
            end
            refine_auto();
            next_step = 'rauto_mapping';
        case 'rauto_mapping',
            fprintf(1,'\n')
            continu = isfield(GLOBAL_PROGRESS,'idx');
            rauto_mapping(continu);
            %next_step = 'rauto_transition';
            next_step = 'update_automaton';
        case 'rauto_transition',
            fprintf(1,'\n')
            continu = isfield(GLOBAL_PROGRESS,'idx');
            rauto_tran(continu);
            next_step = 'update_automaton';
        case 'update_automaton',
            GLOBAL_AUTOMATON = GLOBAL_NEW_AUTOMATON; %#ok
            GLOBAL_ITERATION = GLOBAL_ITERATION + 1;
            GLOBAL_NEW_AUTOMATON = {};
            next_step = 'auto_to_xsystem';
        case 'auto_to_xsystem',
            fprintf(1,'\nGenerating generic transition system.\n')
            % flatten out GLOBAL_AUTOMATON to generic transition system
            % GLOBAL_TRANSITION, the reverse transition system is also obtained in
            % GLOBAL_REV_TRANSITION
            auto2xsys;
            if discard_flag
                remove_unreachables;
            end
            next_step = 'parse_spec';
        otherwise,
            error('CheckMate:UnknownStep', ...
                ['Unknown verification step ''' GLOBAL_PROGRESS.step  '''.'])
    end
    GLOBAL_PROGRESS.step = next_step;
    if isfield(GLOBAL_PROGRESS,'idx')
        GLOBAL_PROGRESS = rmfield(GLOBAL_PROGRESS,'idx');
    end
    % If single step option is specified then stop.
    if single_step_flag
        break;
    end
end

if strcmp(GLOBAL_PROGRESS.step,'done') && save_flag
    save([savefile num2str(GLOBAL_ITERATION)])
end

GLOBAL_TIME_ELAPSED.total_time = cputime - initial_time;
fprintf('total verification time is %8.2f seconds.\n',GLOBAL_TIME_ELAPSED.total_time)

return

function [single_step_flag, start_flag, pause_flag, save_flag, ...
    savefile, close_flag, discard_flag] = check_input(n, var)

global GLOBAL_PROGRESS GLOBAL_ITERATION GLOBAL_TIME_ELAPSED

% Default flags
start_flag = 1;
single_step_flag = 0;
save_flag = 0;
savefile = '';
pause_flag = 1;
close_flag = 0;
discard_flag = 0;
GLOBAL_TIME_ELAPSED={};
GLOBAL_TIME_ELAPSED.iauto_part=0;
GLOBAL_TIME_ELAPSED.iauto_build=[];
GLOBAL_TIME_ELAPSED.total_time=0;

if start_flag
    GLOBAL_PROGRESS.step = 'piha_conversion';
    GLOBAL_ITERATION = 0;
end

if isempty(GLOBAL_PROGRESS)
    GLOBAL_PROGRESS.step={'done'};
    fprintf(1,'There is no previous verification process to continue.\n');
end

k = 1;
while k <= n
    switch var{k}
        case '-step',
            single_step_flag = 1;
            start_flag = 0;
            k = k+1;
            GLOBAL_PROGRESS.step = var{k};
        case '-resume',
            start_flag = 0;
        case '-nopause',
            pause_flag = 0;
        case '-save',
            save_flag = 1;
            k = k+1;
            savefile = var{k};
        case '-close',
            close_flag = 1;
        case '-discard',
            discard_flag = 1;
        case '-verbose',
            GLOBAL_APPROX_PARAM.verbosity = max(1,GLOBAL_APPROX_PARAM.verbosity);
        otherwise
            error('CheckMate:UnknownOptions',['Unknown option ''' var{k} '''.'])
    end
    k = k+1;
end
