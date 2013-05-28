function plot_tran(coordinates)
% PLOT_TRAN - plot the global transition systems
%   using the give coordinates

global GLOBAL_TRANSITION;
handle = zeros(1,length(GLOBAL_TRANSITION));
for i=1:length(GLOBAL_TRANSITION)
    src = coordinates(i,:);
    handle(i) = rectangle('position', [src 0.1 0.1], 'curvature', 1);
    txt = text(src(1),src(2), num2str(i),'verticalalignment','top');
    r.out =[];
    r.in = [];
    r.label =txt ;
    set(handle(i), 'userdata', r);
end

for i=1:length(GLOBAL_TRANSITION)
    src = coordinates(i,:);
    to = GLOBAL_TRANSITION{i};
    for j=1:length(to)
        if to(j)~=i
            dst = coordinates(to(j),:);
            tran = plot([src(1), dst(1)],[src(2) dst(2)],'-');
            arrow = plot_arrow(src,dst);
            set(tran, 'userdata', arrow);
            r = get(handle(i), 'userdata');
            r.out = [r.out tran];
            set (handle(i), 'userdata', r);  %add to the src
            r = get(handle(to(j)), 'userdata');
            r.in = [r.in tran];
            set (handle(to(j)), 'userdata', r);  %add to the dst
        else
            set (handle(i), 'LineStyle', ':');  %add to the src
        end
    end
    
end

%---------------------------------------
function arrow=plot_arrow(src,dst)
direction = (dst - src)/norm(dst-src);
pert = null(direction)';
startc = pert*0.02 + dst - direction*0.05;
termc = -pert*0.02 + dst - direction*0.05;
arrow= plot([startc(1), dst(1), termc(1)], [startc(2), dst(2), termc(2)],'-');
return