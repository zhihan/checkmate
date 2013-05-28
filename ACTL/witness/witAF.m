function [q,t]=witAF(node,qw)
% witness of the counterexample of AF (EG)
% f - a region, qw - a row vector of states

global GLOBAL_TRANSITION;

% an EG branch of the spec tree
EGfe = ~evaluate(node);
t =[];
count = 0;
q = qw;
while(1)
    qnext = [];
    oldcount = count;
    for w=1:length(qw)
        img = GLOBAL_TRANSITION{qw(w)};
        for j=1:length(img)
            if isinregion(EGfe,img(j));
               if ~ismember([qw(w),img(j)],t,'rows') || isempty(t)
                    t = vertcat(t, [qw(w),img(j)]);
                    count = count+1;
                end
                if ~ismember(img(j),qnext) || isempty(t)
                    qnext = horzcat(qnext,img(j));
                end
            end
        end
    end
    q = unique(horzcat(q,qnext));
    qw = qnext;
    if count - oldcount<1
        break;
    end
end
    [qnew, tnew] = witgraph(node.value{3},qw);
    q = unique(horzcat(q, qnew));
    t = unique(vertcat(t,tnew),'rows');


