
function partition = split_patch(patch,size_tol,W)

[split,con1,con2] = split_if_too_big(patch,size_tol,W);
if split
  partition1 = split_patch(con1,size_tol,W);
  partition2 = split_patch(con2,size_tol,W);
  partition = [partition1,partition2];
else
  partition = {patch};
end
return
