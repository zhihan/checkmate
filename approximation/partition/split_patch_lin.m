function partition = split_patch_lin(patch,A,var_tol,size_tol,W)

split = 0;
[too_big,con1,con2] = split_if_too_big(patch,size_tol,W);
if too_big
  split = 1;
else
  % If not too big, check if too varied
  [fmin,fmax] = compute_vfield_variation(patch,A);
  too_varied = (fmax - fmin > var_tol);
  if too_varied
    CE = linearcon_data(patch);
    n = (CE*A)';
    k = (fmax+fmin)/2;
    M = sqrt(n'*n);
    n = n/M;
    k = k/M;
    con1 = patch & linearcon([],[],n',k);
    con2 = patch & linearcon([],[],-n',-k);
    split = 1;
  end
end

if split
  partition1 = split_patch(con1,A,var_tol,size_tol,W);
  partition2 = split_patch(con2,A,var_tol,size_tol,W);
  partition = append_array(partition1,partition2);
else
  partition = {patch};
end

return
