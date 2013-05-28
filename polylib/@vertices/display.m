function display(v)
% DEFAULT display method
    fprintf(1,['\n' inputname(1) ': ']);
    if isempty(v.list)
        fprintf(1,' empty\n')
    else
        fprintf(1,'\n');
        for k = 1:size(v.list,2)
            fprintf(1,'v%d = [',k);
            fprintf(1,'%f ',v.list(:,k));
            fprintf(1,']^T\n');
        end
    end
    fprintf(1,'\n');
end
