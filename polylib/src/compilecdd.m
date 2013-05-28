% script to compile CDDMEX
function compilecdd(cmd)

mexfilename = ['cddmex.' mexext];
dstfilename = ['..' filesep '@linearcon' filesep 'private' filesep mexfilename];
if isempty(dir(dstfilename)) || strcmpi(cmd, 'recompile')
    disp('Compiling CDDMEX');
    mex cddmex.c cddcore.c cddio.c cddlib.c cddlp.c cddmp.c cddproj.c setoper.c
    copyfile(mexfilename, dstfilename, 'f');
end