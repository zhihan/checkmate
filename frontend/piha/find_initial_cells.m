function icell = find_initial_cells(X0,locations,AR)

%This function intersects linearcon object representing one piece of ICS with
%each CELL in invariant location

global CELLS

icell=[];
initial_invariant=locations.interior_cells;

if ~issubset(X0,AR)
    fprintf('\nSome part of the initial continuous set is outside of the analysis region.  \nPress any key to continue anyhow.\n')
    pause;
end

for i=1:length(initial_invariant)
	[C,d] = cell_ineq(CELLS{initial_invariant(i)}.boundary,CELLS{initial_invariant(i)}.hpflags);
	INV = linearcon([],[],C,d);
	if isfeasible(X0,INV)
   	icell=[icell initial_invariant(i)];
	end
end

%Test to see if any of the initial continuous set either a.) satifies a guard or b.) is outside of the
%analysis region.
transitions=locations.transitions;
guards=[];
for k=1:length(transitions)
   guards=union(guards,transitions{k}.guard);
end

for i=1:length(guards)
	[C,d] = cell_ineq(CELLS{guards(i)}.boundary,CELLS{guards(i)}.hpflags);
	GUARD = linearcon([],[],C,d);
	if isfeasible(X0,GUARD)
      fprintf(['Some section of the initial continuous set satisfies'                 'the guard \nof the initial location.'       	' This section will be neglected.\n\n  Press any key to continue.'])
% moved
% moved
    pause;
	end
end





return

