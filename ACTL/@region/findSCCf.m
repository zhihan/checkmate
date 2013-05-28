function SCC = findSCCf(f)

% Find `strongly connected components (SCC)` within a region of the
% global transition system.
%
% Syntax:
%   "SCC = findsccf(f)"
%
% Description:
%   Given a finite-state transition system and its reverse transition system
%   stored in the global variables GLOBAL_TRANSITION and
%   GLOBAL_REV_TRANSITION, compute the `strongly connected components (SCC)`
%   in the global transition system. An SCC is a subgraph such that each
%   state is reachable from every other state in the subgraph. This function
%   finds SCCs within the set of state specified by the "region" object
%   "f". The output "SCC" is a cell array. Each cell is a vector of state
%   indices representing an SCC in the global transition system.
%
% Implementation:
%   The algorithm for finding the SCCs is adapted from the book `Algorithms
%   in C` by Sedgewick.
%
% See Also:
%   region,auto2xsys,reach,checkAF,checkAG,checkAR,checkAU,checkAX,
%   checkEF,checkEG,checkER,checkEU,checkEX

% Find strongly connected components (SCC) of global transition structure
% GLOBAL_TRANSITION restricted to the region f.
% SCC is a cell array. SCC{i} is a list of states comprising an SCC.

% global global variable
global GLOBAL_TRANSITION

% local global variables
global REGION VISIT_NUMBER VISIT_COUNTER STACK

% Initializations
REGION = f;
VISIT_NUMBER = zeros(1,length(GLOBAL_TRANSITION));
VISIT_COUNTER = 0;
SCC = {};

for k = 1:length(GLOBAL_TRANSITION)
    if isinregion(REGION,k) && (VISIT_NUMBER(k) == 0)
        STACK = [];
        local_visit(k);
    end
end

    function min = local_visit(node)

        % Increment visit counter and update visit number for current node
        VISIT_COUNTER = VISIT_COUNTER + 1;
        VISIT_NUMBER(node) = VISIT_COUNTER;

        % Initialize min to current node
        min = VISIT_NUMBER(node);

        % Push current node onto the stack
        STACK(length(STACK)+1) = node;

        % Get the destination list for current node
        dst = GLOBAL_TRANSITION{node};
        for klocal = 1:length(dst)
            % only consider transitions to other nodes in region f
            if isinregion(REGION,dst(klocal))
                % if node dst(k) has not been visited, visit it
                % otherwise, get its visit number
                if (VISIT_NUMBER(dst(klocal)) == 0)
                    temp = local_visit(dst(klocal));
                else
                    temp = VISIT_NUMBER(dst(klocal));
                end
                if (temp < min)
                    min = temp;
                end
            end
        end

        if (min == VISIT_NUMBER(node))
            top = length(STACK);
            stop = 0;
            while ~stop
                VISIT_NUMBER(STACK(top)) = Inf;
                if (STACK(top) == node)
                    stop = 1;
                else
                    top = top - 1;
                end
            end
            SCC{length(SCC)+1} = STACK(top:end);
            STACK = STACK(1:top-1);
        end
    end

end
% ----------------------------------------------------------------------------


