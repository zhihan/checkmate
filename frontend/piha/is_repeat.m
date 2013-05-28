function test=is_repeat(boundary,hpflags)

%This function tests if CELLS already contains a region described by the HP's
%in the vector 'boundary'

global CELLS

test=0;
size=length(CELLS);
for i=1:size
    if length(intersect(boundary,CELLS{i}.boundary))==length(boundary)&& length(boundary)==length(CELLS{i}.boundary)

        %If all boundary HP's are equal, cell must be tested to see if all HP sides are
        %also equal.  (Added by JPK 6/2002)
        not_eq=0;
        for j=1:length(boundary)
            [dum1,dum2,member_num]=intersect(boundary(j),CELLS{i}.boundary);
            if hpflags(j)~=CELLS{i}.hpflags(member_num)
                not_eq=1;
                break;
            end
        end
        if ~not_eq
            test=i;
            break;
        end
    end
end

return

%-----------------------------------------------------------------------------
