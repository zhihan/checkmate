function [newC, newd] = remove_repeat_hyp(con, C, d)
news = true(size(d));
for i=1:length(news)
    news(i) = is_new_ineq(con, C(i,:), d(i,:));
end
newC = C(news, :);
newd = d(news, :);
end

function new = is_new_ineq(CONfeas,c,d)

% Check if the given constraint cTx <= d
% is already in the feasible constraint CONfeas

global GLOBAL_APPROX_PARAM

hyperplane_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;

% First search the equality constraints
CE = CONfeas.CE; dE = CONfeas.dE;
new = 1;
for k = 1:length(dE)
    MATRIX = [CE(k,:) dE(k); c d];
    if (rank(MATRIX,hyperplane_tol) < 2)
        new = 0;
        break;
    end
end

if new
    % Now search the inequality constraints
    CI = CONfeas.CI; dI = CONfeas.dI;
    for k = 1:length(dI)
        MATRIX = [CI(k,:) dI(k); c d];
        if (rank(MATRIX,hyperplane_tol) < 2) && (CI(k,:)*c' > 0)
            new = 0;
            break;
        end
    end
end
end
