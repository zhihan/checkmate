function curr_states = refine_dead_code(inter, refinement, curr_states)

curr_states{j}.polytope=inter;
if ~isempty(refinement{k}.mapping)
    if ~isempty(curr_states{j}.mapping)
        tmp_mapping={};
        for s=1:length(curr_states{j}.mapping)
            for t=1:length(refinement{k}.mapping)
                if isfeasible(refinement{k}.mapping{t},curr_states{j}.mapping{s})
                    tmp_mapping{end+1}=refinement{k}.mapping{t} & ...
                        curr_states{j}.mapping{s};
                end
            end
        end
        curr_states{j}.mapping = tmp_mapping;
        tmp_dest={};
        for s=1:length(curr_states{j}.destination)
            for t=1:length(refinement{k}.destination)
                if (refinement{k}.destination{t}.location==curr_states{j}.destination{s}.location) && ...
                        (refinement{k}.destination{t}.cell==curr_states{j}.destination{s}.cell) && ...
                        isfeasible(refinement{k}.destination{t}.mapping{1},curr_states{j}.destination{s}.mapping{1})
                    tmp_dest{end+1} = curr_states{j}.destination{s};
                    tmp_dest{end}.mapping{1}= refinement{k}.destination{t}.mapping{1}& ...
                        curr_states{j}.destination{s}.mapping{1};
                    break;
                end
            end
        end
        curr_states{j}.destination=tmp_dest;
    else
        curr_states{j}.mapping = refinement{k}.mapping;
        curr_states{j}.destination=refinement{k}.destination;
    end
end
curr_states{j}.null_event=curr_states{j}.null_event & refinement{k}.null_event;
curr_states{j}.time_limit=curr_states{j}.time_limit & refinement{k}.time_limit;
curr_states{j}.out_of_bound=curr_states{j}.out_of_bound & refinement{k}.out_of_bound;
tmp_terminal = {};
for s=1:length(curr_states{j}.terminal)
    for t=1:length(refinement{k}.terminal)
        if curr_states{j}.terminal{s}==refinement{k}.terminal{t}
            tmp_terminal{end+1}=curr_states{j}.terminal{s};
            break;
        end
    end
end
curr_states{j}.terminal=tmp_terminal;
curr_states{j}.split=refinement{k}.split;

