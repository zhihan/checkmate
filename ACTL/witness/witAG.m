function [q,t] =witAG(node, qw)
% WITAG - witness graph for counterexample of AG f
% [q,t] =witAG(node, qw)
%    
global GLOBAL_TRANSITION;

EFfe = ~evaluate(node);
fe = ~evaluate(node.value{3});
t =[];
count = 0;
q = qw;
while(1)
    qnext = [];
    oldcount = count;
    for w=1:length(qw)
        img = GLOBAL_TRANSITION{qw(w)};
        for j=1:length(img)
            if isinregion(EFfe,img(j));
               if ~ismember([qw(w),img(j)],t,'rows') || isempty(t)
                    t = vertcat(t, [qw(w),img(j)]); % add transition
                    count = count+1;
                end
                if ~ismember(img(j),qnext) || isempty(t)
                    qnext = horzcat(qnext,img(j)); % explore state
                    if isinregion(fe, img(j))
                        [qnew, tnew] = witgraph(node.value{3},img(j)); %recursion
                        q = unique(horzcat(q, qnew)); %add subgraph
                        t = unique(vertcat(t,tnew),'rows');
                    end
                end
            end
        end
    end
    q = unique(horzcat(q,qnext)); 
    qw = qnext;
    if count - oldcount<1 %fixed-point
        break;
    end
end

