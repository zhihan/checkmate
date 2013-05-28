function partition = partition_ss(partition,guard_pthbs,pthb)

% Partition the continuous state space using the analysis region
% hyperplanes and all hyperlanes from the relevant polydral threshold
% blocks (PTHBs) for the current location
%
% Syntax:
%   "SSTREE,leaves = new_partition_ss(guard_pthbs,pthbHandle,pthb,NAR)"
%
% Description:
%   "partition_ss(AR,NBDHP,pthbHandle)" returns a list of regions in
%   the continuous state space.  The hp's used to create these regions
%   are all of the hp's associated with the pthb's which are relevant
%   in the current location.  The method used to divied the analysis
%   region is described below.
%
% -PTHB's are considered one at a time
%
% -The first hyperplane of this PTHB bisects the analysis region.  Two
% regions result, one which is associted with the PTHB and one which
% is not.
% 
% -The next hyperplane is used to bisect only the latter region.  This
% is repeated for the remaining hyperplanes.  The following
% illustrates this:
% 
%
% Analysis region with first PTHB:
%+-------------------------+
%|AR                       |
%|                         |
%|                         |
%|                         |
%|        +---+            |
%|        |   |            | 
%|        |   |            |
%|        +---+            |
%|                         |
%|                         |
%|                         |
%|                         |
%|                         |
%|                         |
%+-------------------------+
%
%
% Partitioning of AR using new method:
%+-------------------------+
%|AR                       |
%|                         |
%|                         |
%|                 1       |
%|--------+---+------------|
%|        |4  |            | 
%|  3     |   |            |
%|--------+---+            |
%|            |            |
%|            |            |
%|            |            |
%|            |2           |
%|            |            |
%|            |            |
%+-------------------------+
%
%
% -The next PTHB is introduced.  All vertices of this polyhedron are
% calculated.
%
% -Every vertex associated with this PTHB will lie within a region
% created in the previous steps.  Each hyperplane associated with
% vertices within a region is used to bisect that region in the same
% fashion the analysis region was partitioned in the initial steps
% (see above illustration).
%
% -Next each PTHB hyperplane is tested to see if it bisects an
% existing region.  Hyperplanes are considered individually.  Each new
% hyperplane is intersected with hyperplanes describing existing
% invariants (i.e. the hyperplanes bounding existing regions).
% Vertices which are created from these intersection are calculated.
% If a vertex satisfies the existing invariant as well as the new
% PTHB, the hyperplane is used to partition the existing region.  The
% following illustrates this:
%
%
% New region added to previous example:
%+-------------------------+
%|AR                       |
%|                         |
%|  +--+                   |
%|  |  |                   |
%|--+--+--+---+------------|
%|  |  |  |   |            | 
%|  |  |  |   |            |
%|--+--+--+---+            |
%|  |  |      |            |
%|  |  |      |            |
%|  +--+      |            |
%|            |            |
%|            |            |
%|            |            |
%+-------------------------+
%
%
% New hyperplanes added due to new
% region:
%+-------------------------+
%|AR                       |
%|         1               |
%|--+--+-------------------|
%| 3|  |2                  |
%|--+--+--+---+------------|
%|  |  |  |   |            | 
%| 8|  |7 |   |            |
%|--+--+--+---+            |
%|  |  |      |            |
%| 6|  |5     |            |
%|--+--+------|            |
%|        4   |            |
%|            |            |
%|            |            |
%+-------------------------+
%
% See Also:
%   piha



% For each polyhedron associated with each PTHB.
for pthb_idx = guard_pthbs
  pthb_poly = linearcon([],[],pthb{pthb_idx}.c,pthb{pthb_idx}.d);
  % For each polyhedral cell in the state-space partition.
  for cell_idx = 1:length(partition)
      if ~isfeasible(partition(cell_idx).poly, pthb_poly)
          partition(cell_idx).pthflags(pthb_idx) = 0;
      else      
          common = partition(cell_idx).poly & pthb_poly;
          % Append new cells to the partition array resulting from the set
          % subtraction of current PTHB polyhedron from the current cell.
          diff = partition(cell_idx).poly - pthb_poly;
          for k = 1:length(diff)
              % Inherit the PTH flags from the current cell before it is
        % broken up. Then set the PTH flag for the current PTHB to
        % 0 for each new cell.
              new_cell = partition(cell_idx);
              new_cell.poly = diff{k};
              new_cell.pthflags(pthb_idx) = 0;
              partition = [partition new_cell];
          end
          % Replace the current cell with its intersection with the PTHB
          % polyhedron and set its PTH flag for the current PTHB to 1.
          partition(cell_idx).poly = common;
          partition(cell_idx).pthflags(pthb_idx) = 1;
      end
  end % for each cell
end % for each PTHB

return