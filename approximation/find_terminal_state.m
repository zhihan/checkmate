function idx = find_terminal_state(q,tm_start)
% FIND_TERMINAL_STATE finds the terminal state in the global transition
% mapping
%
% Example
% idx = find_terminal_state(q,tm_start)
%
%
global GLOBAL_XSYS2AUTO_MAP

idx = [];
for k = tm_start:length(GLOBAL_XSYS2AUTO_MAP)
    if all(GLOBAL_XSYS2AUTO_MAP{k}{2} == q)
        idx = k;
        break;
    end
end
return