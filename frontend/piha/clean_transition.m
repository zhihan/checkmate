function clean_loc=clean_transition(location)
counter=1;
for i=1:length(location.transitions)
    if location.transitions{i}.id>0
        cur_guard=location.transitions{i}.guard;
        for j=i+1:length(location.transitions)
            if ~isempty(cur_guard)&&~isempty(location.transitions{j}.guard)
                %(isempty(cur_guard)&isempty(location.transitions{j}.guard))
                if length(cur_guard)==length(location.transitions{j}.guard)
                    if (all(cur_guard==location.transitions{j}.guard))

                        location.transitions{i}.source=[location.transitions{i}.source location.transitions{j}.source];
                        location.transitions{i}.destination=[location.transitions{i}.destination location.transitions{j}.destination];
                        location.transitions{i}.idx=[location.transitions{i}.idx location.transitions{j}.idx];

                        % If either of the transitions resets, we should reset on the composite transion, too. Ansgar
                        location.transitions{i}.reset_flag=max(location.transitions{i}.reset_flag, location.transitions{j}.reset_flag);
                        location.transitions{i}.reset_scs_index=setdiff(                             [location.transitions{i}.reset_flag*location.transitions{i}.reset_scs_index, location.transitions{j}.reset_flag*location.transitions{j}.reset_scs_index],0);
                        % moved

                        location.transitions{j}.id=-1;
                    end   %if
                end %if
            end %if
        end   %for j
        clean_loc.transitions{counter}=location.transitions{i};
        counter=counter+1;
    end   %if location


end   %for i

