function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';

blkStruct.OpenFcn = 'template';
blkStruct.Name = 'Checkmate';

 Browser(1).Library = 'template';
  Browser(1).Name    = 'CheckMate';
  Browser(1).IsFlat  = 1;
 blkStruct.Browser = Browser;

% End of slblocks



