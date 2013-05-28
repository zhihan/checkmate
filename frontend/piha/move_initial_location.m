function [locations] = move_initial_location(locations, q0)

if (size(q0,1)~=1) || ~all(locations{1}.q==q0(1,:))
    relocation_count = 1;
    for i=1:size(q0,1)
        for j=1:length(locations)
            if all(locations{j}.q==q0(i,:))

                location_to_move =locations{j};
                location_from_move=locations{relocation_count};
                locations{relocation_count}= location_to_move;
                locations{j}= location_from_move;
                relocation_count=relocation_count +1;

            end%if
            if relocation_count > size(q0,1)
                break
            end
        end%for
    end%for
end%end