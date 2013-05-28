function refine_auto()

% Refine the current `approximating automaton`.
%
% Syntax:
%   "refine_auto(discard_flag)"
%
% Description:
%   Refine the partition of the initial continuous set and the invariant
%   interior_regions in the current approximating automaton (stored in the global
%   variable "GLOBAL_AUTOMATON") by splitting the polytopes associated with
%   the states in the refinement list "GLOBAL_TBR". The refinement result is
%   stored the global variable "GLOBAL_NEW_AUTOMATON". The input
%   "discard_flag" is a boolean flag indicating whether the states that are
%   definitely unreachable should be discarded from "GLOBAL_NEW_AUTOMATON".
%
% Implementation:
%   The set of states `to be refined` are given in the "region" object
%   "GLOBAL_TBR". The state indices in "GLOBAL_TBR" are indices to the
%   generic transition system "GLOBAL_TRANSITION" generated from
%   "GLOBAL_AUTOMATON" using the function "auto2xsys". The correspondence
%   between states in "GLOBAL_AUTOMATON" and "GLOBAL_TRANSITION" can be
%   obtained using the variables "GLOBAL_AUTO2XSYS_MAP" and
%   "GLOBAL_XSYS2AUTO_MAP" (see the m-file "auto2xsys.m" for more detail).
%
%
%
%   The refinement procedure proceeds as follows. The polytope for each
%   state listed in "GLOBAL_TBR", whether it is an `initial` or a `interior_region`
%   state, is split into multiple polytopes before they are entered in
%   "GLOBAL_NEW_AUTOMATON". Other states that are not refined are simply
%   copied over to "GLOBAL_NEW_AUTOMATON". The indices of the newly split
%   states in "GLOBAL_NEW_AUTOMATON" are added to the cell array
%   "GLOBAL_RAUTO_REMAP_LIST". This is the list of states for which the
%   mapping set needs to be computed. The state indices in
%   "GLOBAL_RAUTO_REMAP_LIST" are row vectors of length 2 or 3. An `initial
%   state` has an index of the form "[l s]" where "l" is the `location`
%   number and "s" is the `state` number. A `interior_region state` has an idex of the
%   form "[l f s]" where "l" is the `location` number, "f" is the `face`
%   number, and "s" is the `state` number.
%
%
%
%   Since the face state indices in "GLOBAL_AUTOMATON" and
%   "GLOBAL_NEW_AUTOMATON" can be different even for a state that is not
%   refined and simply copied over, the links between the states in both
%   automata are stored in the global variable "GLOBAL_RAUTO_FACE_MAP",
%   which is a hierachical cell array where "GLOBAL_RAUTO_FACE_MAP{l}{f}{s}"
%   maps the state "s" on face "f" in location "l" in "GLOBAL_AUTOMATON" to
%   (possibly) multiple states in "GLOBAL_NEW_AUTOMATON". There are two
%   cases for each cell array entry "GLOBAL_RAUTO_FACE_MAP{l}{f}{s}".
%
%   * "GLOBAL_RAUTO_FACE_MAP{l}{f}{s} = [s1]". In this case, state "s" on face
%     "f" in location "l" in "GLOBAL_AUTOMATON" is not refined and is the same
%     as state "s1" on face "f" in location "l" of "GLOBAL_NEW_AUTOMATON".
%
%   * "GLOBAL_RAUTO_FACE_MAP{l}{f}{s} = [s1 ... sn]". In this case, state "s"
%     on face "f" in location "l" in "GLOBAL_AUTOMATON" is split into states
%     "s1" through "sn" on face "f" in location "l" of "GLOBAL_NEW_AUTOMATON".
%
%   The ".children" field for each state in "GLOBAL_NEW_AUTOMATON" are
%   inherited from the same state or the parent state (in case of a split)
%   in "GLOBAL_AUTOMATON". Thus, the indices in the ".children" field must
%   be updated to correspond to the indices in "GLOBAL_NEW_AUTOMATON". The
%   variable "GLOBAL_RAUTO_FACE_MAP" is used for this purpose. For a state
%   in "GLOBAL_AUTOMATON" that is split into multiple states in
%   "GLOBAL_NEW_AUTOMATON", its index is replaced by multiple indices of
%   those newly split states, as done in the function "update_children".
%
%
%
%   The `initial` and `face` states are refined differently. An `initial`
%   state is always split into two states by the function "split_polytope"
%   whereas a `face` state can be split into more than two states by the
%   function "refine_face_state". The function "refine_face_state" is
%   implemented as follows.
%
%   * Find the `source states` for the `destination` state to be refined.
%
%   * Initialize the partition representing the refinement of the destination
%     state with the polytope for that state. List all source states as the
%     `potential source states` for this polytope.
%
%   * For each source state, find the mapping set on the invariant face that
%     is the common face between the invariants of the source and the
%     destination states and over approximate the mapping set on that face
%     by a rectangular polytope called the `bounding box` (see the file
%     flow_reach.m for more detail on the bounding box calculation). Split
%     every polytope in the partition into the part that overlaps with the
%     bounding box (the intersection) and the part that does not overlap
%     with the bounding box (the set difference). Remove the source state
%     from the list of potential source state for all polytopes resulting
%     from the set subtraction, since the mapping set from the source state
%     definitely does not intersect with any of these polytopes.
%
%   * Repeat the above step for all source states. This basically splits the
%     polytope for the destination state into parts that can be reached from
%     different combinations of source states. If the "discard_flag" is set,
%     throw away all polytopes for which the list of potential source states
%     is empty. These polytopes are certainly not reachable from the initial
%     states because they are not reachable by any source states of the
%     original destination state to be refined.
%
%   * If no refinement takes place after all of the above has been applied,
%     call the function "split_polytope" to split the polytope into two
%     subsets as done for the refinement of an `initial` state.
%
% See Also:
%   verify,flow_reach,rauto_mapping,rauto_tran,auto2xsys,region

% input global variables
global GLOBAL_PIHA
global GLOBAL_AUTOMATON
global GLOBAL_AUTO2XSYS_MAP
global GLOBAL_TBR
global GLOBAL_APPROX_PARAM

% output global variables
global GLOBAL_NEW_AUTOMATON    % Approximating automaton refined from
% GLOBAL_AUTOMATON. Mappings for the
% refined states are not computed yet and
% children field for each state still need
% to be updated.
global GLOBAL_RAUTO_REMAP_LIST % lists of refined states in
% GLOBAL_NEW_AUTOMATON for which the
% mapping needs to be computed
global GLOBAL_RAUTO_FACE_MAP   % state map from face states in
% GLOBAL_AUTOMATON to face states in
% GLOBAL_NEW_AUTOMATON

% GLOBAL_RAUTO_REMAP_LIST is a cell array whose element is either
%    [loc initstate]  for initial state or
%    [loc face state] for face state.

GLOBAL_NEW_AUTOMATON = {};
GLOBAL_RAUTO_REMAP_LIST = [];
untouched_states=[];

% refine initial states first
for loc = GLOBAL_PIHA.InitialLocation_Cells(:,1)
    GLOBAL_NEW_AUTOMATON{loc}.initstate = {};
    for state = 1:length(GLOBAL_AUTOMATON{loc}.initstate)
        % find the corresponding index in GLOBAL_TRANSITION for the initial
        % state "state" in location "loc"
        XSYSidx = GLOBAL_AUTO2XSYS_MAP.init_state_map{loc}{state};
        % refine this state if it is in the "to-be-refined" set
        if isinregion(GLOBAL_TBR,XSYSidx)
            %clc
            fprintf(1,'refining location %d : initstate %d\n',loc,state)
            drawnow

            % split the associated polytope
            [con1,con2] = split_polytope( ...
                GLOBAL_AUTOMATON{loc}.initstate{state}.polytope,GLOBAL_APPROX_PARAM.W);

            temp = GLOBAL_AUTOMATON{loc}.initstate{state};
            temp.mapping = {};

            temp.polytope = con1;
            new = length(GLOBAL_NEW_AUTOMATON{loc}.initstate)+1;
            GLOBAL_NEW_AUTOMATON{loc}.initstate{new} = temp;

            temp.polytope = con2;
            new = length(GLOBAL_NEW_AUTOMATON{loc}.initstate)+1;
            GLOBAL_NEW_AUTOMATON{loc}.initstate{new} = temp;

            % put both new states in the "remap" list
            next = length(GLOBAL_RAUTO_REMAP_LIST)+1;
            GLOBAL_RAUTO_REMAP_LIST{next} = [loc new-1];
            next = length(GLOBAL_RAUTO_REMAP_LIST)+1;
            GLOBAL_RAUTO_REMAP_LIST{next} = [loc new];
        else
            % if current state is not to be refined, retain all the information
            % except that children and out-of-bound flag must be fixed later.
            temp = GLOBAL_AUTOMATON{loc}.initstate{state};
            new = length(GLOBAL_NEW_AUTOMATON{loc}.initstate)+1;
            GLOBAL_NEW_AUTOMATON{loc}.initstate{new} = temp;
            untouched_states=[untouched_states ; loc new 0];
        end
    end
end

% Only need to keep track of the refinement by mapping face states from
% GLOBAL_AUTOMATON to GLOBAL_NEW_AUTOMATON since children states for all
% states are face states. There are two cases for each entry of
% GLOBAL_RAUTO_FACE_MAP{l}{f}{s}.
%   (i) GLOBAL_RAUTO_FACE_MAP{l}{f}{s} = [s1]
%       In this case, state s on face f in location l in GLOBAL_AUTOMATON is
%       not refined and is the same as state s1 on face f in location l
%       of GLOBAL_NEW_AUTOMATON.
%  (ii) GLOBAL_RAUTO_FACE_MAP{l}{f}{s} = [s1 ... sn]
%       In this case, state s on face f in location l in GLOBAL_AUTOMATON is
%       split into state s1 and sn on face f in location l of
%       GLOBAL_NEW_AUTOMATON.

GLOBAL_RAUTO_FACE_MAP = {};

% refine face partition states
for loc = 1:length(GLOBAL_AUTOMATON)

    if ~isempty(GLOBAL_AUTOMATON{loc})
        GLOBAL_NEW_AUTOMATON{loc}.interior_region = {};
        GLOBAL_RAUTO_FACE_MAP{loc} = {};

        for interior_region = 1:length(GLOBAL_AUTOMATON{loc}.interior_region)
            GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state = {};
            GLOBAL_RAUTO_FACE_MAP{loc}{interior_region} = {};

            for state = 1:length(GLOBAL_AUTOMATON{loc}.interior_region{interior_region}.state)

                % find the corresponding index in GLOBAL_TRANSITION for the interior_region
                % state "state" on interior_region "interior_region" in location "loc"
                XSYSidx = GLOBAL_AUTO2XSYS_MAP.interior_state_map{loc}{interior_region}{state};
                % refine this state if it is in the "to-be-refined" set

                if isinregion(GLOBAL_TBR,XSYSidx)
                    % clc
                    fprintf(1,'refining location %d : interior_region %d : state %d\n', ...
                        loc,interior_region,state)
                    drawnow
                    % refine the associated polytope
                    [refinement_temp,non_reachable] = refine_interior_region_state(XSYSidx);

                    %Only use the members of 'refinement' that are reachable.
                    refinement=[];
                    for i=1:length(refinement_temp)
                        if ~ismember(i,non_reachable)
                            refinement{length(refinement)+1}=refinement_temp{i};
                        end
                    end
                    temp = GLOBAL_AUTOMATON{loc}.interior_region{interior_region}.state{state};
                    temp.mapping = {};
                    for k = 1:length(refinement)
                        temp.polytope = refinement{k};
                        new = length(GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state)+1;
                        GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{new} = temp;
                    end
                    GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state} = ...
                        (new-length(refinement)+1):new;

                    % put all new states in the "remap" list
                    for k = 1:length(refinement)
                        next = length(GLOBAL_RAUTO_REMAP_LIST)+1;
                        GLOBAL_RAUTO_REMAP_LIST{next} = ...
                            [loc interior_region (new-length(refinement)+k)];
                    end
                else
                    % if current state is not to be refined, retain all the information
                    % except that children and out-of-bound flag must be fixed later.
                    temp = GLOBAL_AUTOMATON{loc}.interior_region{interior_region}.state{state};
                    new = length(GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state)+1;
                    GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{new} = temp;
                    GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state} = new;
                    untouched_states=[untouched_states ; loc interior_region new];
                end
            end
        end
    end
end

% Update children for each state where each child state (which must be a
% face state) is mapped from the old index in GLOBAL_AUTOMATON to the new
% index for GLOBAL_NEW_AUTOMATON. Any child state that is split in the
% refinement is mapped accordingly into multiple children in
% GLOBAL_NEW_AUTOMATON.

for l = GLOBAL_PIHA.InitialLocation_Cells(:,1)
    for s = 1:length(GLOBAL_NEW_AUTOMATON{l}.initstate)

        [children, mapping]=update_children(...
            GLOBAL_NEW_AUTOMATON{l}.initstate{s}.children,l,s,0,untouched_states);
        GLOBAL_NEW_AUTOMATON{l}.initstate{s}.children=children;
        GLOBAL_NEW_AUTOMATON{l}.initstate{s}.mapping=mapping;
    end
end

for l = 1:length(GLOBAL_NEW_AUTOMATON)
    if ~isempty(GLOBAL_NEW_AUTOMATON{l})
        for f = 1:length(GLOBAL_NEW_AUTOMATON{l}.interior_region)
            for s = 1:length(GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state)
                [children,mapping] = update_children(...
                    GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state{s}.children,l,f,s,untouched_states);
                GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state{s}.children=children;
                GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state{s}.mapping=mapping;
            end
        end
    end
end
return

% -----------------------------------------------------------------------------

function [children_new,mapping] = update_children(children,src_loc,src_int_region,src_st,untouched_states)

global GLOBAL_RAUTO_FACE_MAP
global GLOBAL_NEW_AUTOMATON

%Update the children.  If the state was not on the 'to be refined' list,
%and the 'child' was on the 'to be refined' list, then intersect the
%mapping with the child to see if it is still a child.
have_not_been_refined_flag=ismember([src_loc src_int_region src_st],untouched_states,'rows');
mapping=[];

children_new = [];
for k = 1:size(children,1)
    loc = children(k,1);
    interior_region = children(k,2);
    state = children(k,3);
    map = GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state};
    for l = 1:length(map)
        if have_not_been_refined_flag && ~ismember(children(k,:),untouched_states,'rows')
            if src_st==0
                inters=GLOBAL_NEW_AUTOMATON{src_loc}.initstate{src_int_region}.mapping{k}&...
                    GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{map(l)}.polytope;
                if ~isempty(inters)
                    children_new = [children_new; loc interior_region map(l)];
                    mapping{length(mapping)+1}=inters;
                end
            else
                inters=GLOBAL_NEW_AUTOMATON{src_loc}.interior_region{src_int_region}.state{src_st}.mapping{k}&...
                    GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{map(l)}.polytope;
                if ~isempty(inters)
                    children_new = [children_new; loc interior_region map(l)];
                    mapping{length(mapping)+1}=inters;
                end
            end
        elseif have_not_been_refined_flag && ismember(children(k,:),untouched_states,'rows')
            children_new = [children_new; loc interior_region map(l)];
            mapping{length(mapping)+1} = GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{map(l)}.polytope;
        else
            children_new = [children_new; loc interior_region map(l)];
        end
    end
end

% -----------------------------------------------------------------------------

function [refinement,non_reachable] = refine_interior_region_state(XSYSidx)

global GLOBAL_REV_TRANSITION
global GLOBAL_XSYS2AUTO_MAP
global GLOBAL_APPROX_PARAM

%This function returns:
%   1) 'refinement' - A vector of polytopes  of the state
%   2) 'non_reachable' - a index vector. It contains information about which elements
%       of 'refinement' are not reachable by any of the original parents.

% Find location for the given state
tmp = GLOBAL_XSYS2AUTO_MAP{XSYSidx};

% Find parent states
parents = GLOBAL_REV_TRANSITION{XSYSidx};

% Find the polytope associated with the state to be refined
polytope = get_auto_state('current',tmp,'polytope');

%Start refinement with the polytope associated with the state to be refined
refinement = {polytope};
reachable=[];

for k = 1:length(parents)
    % Find location for each parent state
    idx = GLOBAL_XSYS2AUTO_MAP{parents(k)};
    % Find the index (from the source) to the mapping that leads to the destination
    index = find_src_mapping_index(idx,tmp);
    % Get the mapping of the parent on the face found above
    mapping = get_auto_state('current',idx,['mapping{' num2str(index) '}']);


    [CE,dE,CI,dI] = linearcon_data(mapping);
    if isempty(dE)
        mappingbox = linearcon(-CE,-dE,CI,dI);
    else
        mappingbox = grow_polytope_for_iautobuild(CE,dE,CI,dI,tmp);
    end

    refinement_new = refinement;

    for l = 1:length(refinement)
        % Split the lth patch in the refinement into the part that is not in
        % mapping box and the part that overlaps with the mapping box.
        overlap = refinement{l} & mappingbox;
        reachflag=ismember(l,reachable);
        if ~isempty(overlap)
            %new = length(refinement_new)+1;
            refinement_new{l} = overlap;
            if ~reachflag
                reachable=[reachable l];
            end


            diff = refinement{l} - mappingbox;
            if ~isempty(diff)
                for m = 1:length(diff)
                    new = length(refinement_new)+1;
                    refinement_new{new} = diff{m};
                    if reachflag==1
                        reachable=[reachable new];
                    end

                end
            else
                fprintf(1,'dropped %d polytopes\n',length(diff))
            end
        end
    end
    refinement = refinement_new;
end

if length(refinement) == 1
    % if no refinement has been made, bisection the polytope
    [con1,con2] = split_polytope(polytope,GLOBAL_APPROX_PARAM.W);
    refinement = {con1 con2};
    reachable=[1 2];
end

non_reachable=setdiff(1:length(refinement),reachable);

return

% -----------------------------------------------------------------------------

function index = find_src_mapping_index(src,dst)

global GLOBAL_AUTOMATON

if length(src)==3
    [dum1,dum2,index]=intersect(dst, ...
        GLOBAL_AUTOMATON{src(1)}.interior_region{src(2)}.state{src(3)}.children,'rows');
else
    [dum1,dum2,index]=intersect(dst, ...
        GLOBAL_AUTOMATON{src(1)}.initstate{src(2)}.children,'rows');
end


if isempty(index)
    error('Checkmate:RAuto:WrongTransition',['refine_auto.m: Impossible destination location ' ...
        'indicated in the given state index.'])
    index = 0;
    return
end
return

