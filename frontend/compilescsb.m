function compilescsb(cmd)
mexfilename = ['scsb_sfun.' mexext];
if isempty(which(mexfilename)) || ...
    strcmpi(cmd, 'recompile')
    disp('Compiling SCSB S-function');
    mex scsb_sfun.c
end