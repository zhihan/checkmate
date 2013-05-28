function [q,t]=witAR(node,qw)
% witness of the counterexample of AR (EU)
% f - a region, qw - a row vector of states

global GLOBAL_TRANSITION;

% an EU branch of the spec tree
EUfege = ~evaluate(node);
fe = ~evaluate(node.value{2});
ge = ~evaluate(node.value{4});
t =[];
count = 0;
q = qw;
while(1)
    qnext = [];
    oldcount = count;
    for w=1:length(qw)
        img = GLOBAL_TRANSITION{qw(w)};
        for j=1:length(img)
            if isinregion(EUfege,img(j));
               if ~ismember([qw(w),img(j)],t,'rows') || isempty(t)
                    t = vertcat(t, [qw(w),img(j)]);
                    count = count+1;
                end
                if ~ismember(img(j),qnext) || isempty(t)
                    qnext = horzcat(qnext,img(j));
                    if isinregion(fe, img(j))
                        [qnew, tnew] = witgraph(node.value{2},img(j));
                        q = unique(horzcat(q, qnew));
                        t = unique(vertcat(t,tnew),'rows');
                    end
                    if isinregion(ge, img(j))
                        [qnew, tnew] = witgraph(node.value{4},img(j));
                        q = unique(horzcat(q, qnew));
                        t = unique(vertcat(t,tnew),'rows');
                    end
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



