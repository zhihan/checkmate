function invariant=intersect_complements(locations,loc)

%This function takes all of the complements of all if the guards for the location 'loc'
%and intersects them.  The resulting regions are the 'invariant'.

global CELLS

previous_invariant=locations{loc}.transitions{1}.guard_compl;

if length(locations{loc}.transitions)>1
    %Intersect the first set of complements with the 2nd.  Then intersect that result
    %with the 3rd, and so on

    for j=2:length(locations{loc}.transitions)
        % moved

        new_guard_compl=locations{loc}.transitions{j}.guard_compl;
        invariant=[];

        for k=1:length(new_guard_compl)

            new_cell=new_guard_compl(k);
            new_hps=CELLS{new_cell}.boundary;
            new_hpflags=CELLS{new_cell}.hpflags;
            new_pthflags=CELLS{new_cell}.pthflags;
            for i=1:length(previous_invariant)

                existing_guard_compl=previous_invariant(i);
                old_hps=CELLS{existing_guard_compl}.boundary;
                old_hpflags=CELLS{existing_guard_compl}.hpflags;
                old_pthflags=CELLS{existing_guard_compl}.pthflags;
                [intersection_boundary,intersection_hpflags]=clean_up_boundary(old_hps,new_hps,old_hpflags,new_hpflags);
                if ~isempty(intersection_boundary)
                    repeat_test=is_repeat(intersection_boundary,intersection_hpflags);
                    if repeat_test~=0
                        %************************************************
                        %Since this CELL already exists, just point to the existing CELL
                        invariant=[invariant repeat_test];
                        %Now update existing pthb flag list
                        for p=1:length(old_pthflags)
                            if old_pthflags(p)~=-1
                                pthflags(p)=old_pthflags(p);
                            elseif new_pthflags(p)~=-1
                                pthflags(p)=new_pthflags(p);
                            elseif CELLS{repeat_test}.pthflags(p)~=-1
                                pthflags(p)=CELLS{repeat_test}.pthflags(p);
                            else
                                pthflags(p)=-1;
                            end
                        end
                        %***********************************************

                    else
                        new_cell=length(CELLS)+1;

                        %************************************
                        CELLS{new_cell}.boundary = intersection_boundary;
                        CELLS{new_cell}.hpflags = intersection_hpflags;
                        for p=1:length(old_pthflags)
                            if old_pthflags(p)~=-1
                                pthflags(p)=old_pthflags(p);
                            elseif new_pthflags(p)~=-1
                                pthflags(p)=new_pthflags(p);
                            else
                                pthflags(p)=-1;
                            end
                        end
                        CELLS{new_cell}.pthflags = pthflags;
                        %*************
                        invariant=[invariant new_cell];
                    end
                end
            end
        end
        previous_invariant=invariant;

    end

else
    invariant=previous_invariant;
end

if isempty(invariant)
    name=locations{loc}.state;
    fprintf(1,'\nWARNING: Location "')
    for i=1:size(name,1)
        fprintf(1,'%s ',name(i,:))
    end
    fprintf(1,'" has no guard invariant.\n')
end

return

% ----------------------------------------------------------------------------
