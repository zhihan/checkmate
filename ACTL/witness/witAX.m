function [q,t]=witAX(node,qw)
% witness of the counterexample of AX
% f - a region, qw - a row vector of states

global GLOBAL_TRANSITION;

% an AX branch of the spec tree
fe = ~evaluate(node.value{3});
qnext = [];
t =[];
q = qw;
for w=1:length(qw)
    img = GLOBAL_TRANSITION{qw(w)};
    for j=1:length(img)
        if isinregion(fe,img(j));
            qnext = horzcat(qnext,img(j));
            t = vertcat(t, [qw(w),img(j)]);
        end
    end
end

q = horzcat(q,qnext);
[qnew, tnew] = witgraph(node.value{3},qnext);
q = unique(horzcat(q, qnew));
t = unique(vertcat(t,tnew), 'rows');


