function scsb_mask_handler(blk)

% Check if parameter constraints should be shown.
use_param = get_param(blk,'use_param');
MaskVisibilities = get_param(blk,'MaskVisibilities');
MaskVisibilities{12} = use_param;
MaskVisibilities{13} = use_param;

% Check if sampled-data analysis should be used.
use_sd = get_param(blk,'use_sd');
MaskVisibilities{3} = use_sd;
MaskVisibilities{4} = use_sd;
set_param(blk,'MaskVisibilities',MaskVisibilities);
if strcmpi(use_param,'off')
  set_param(blk,'p0','[]');
  set_param(blk,'PaCs','[]');
end
if strcmpi(use_sd,'off')
  set_param(blk,'nup','[]');
  set_param(blk,'nz','[]');
end



return