function ap = build_fsm_ap(fsmname,statename)


global GLOBAL_PIHA GLOBAL_TRANSITION GLOBAL_XSYS2AUTO_MAP


found = 0;
for k = 1:length(GLOBAL_PIHA.FSMBlocks)
  if strcmp(fsmname,GLOBAL_PIHA.FSMBlocks{k}.name)
    fsmidx = k;
    found = 1;
    break;
  end
end
if ~found
  error('CheckMate:InvalidFSM', ['Invalid FSM block name ''' fsmname '''.'])
end


found = 0;
for k = 1:length(GLOBAL_PIHA.FSMBlocks{fsmidx}.states)
  if strcmp(statename,GLOBAL_PIHA.FSMBlocks{fsmidx}.states{k})
    stateidx = k;
    found = 1;
    break;
  end
end
if ~found
  error('CheckMate:InvalidFSM',['Invalid state name ''' statename ''' for FSM block ''' fsmname '''.'])
end


N = length(GLOBAL_TRANSITION);
ap = region(N,'false');
for k = 1:N
    if isa(GLOBAL_XSYS2AUTO_MAP{k},'double')
        loc = GLOBAL_XSYS2AUTO_MAP{k}(1);
        q = GLOBAL_PIHA.Locations{loc}.q;
    else
        % must be special states

        if strcmp(GLOBAL_XSYS2AUTO_MAP{k}{1},'terminal')
            q = GLOBAL_XSYS2AUTO_MAP{k}{2};
            if (q(fsmidx) == stateidx)
            ap = set_state(ap,k,1);
            end
        else
            loc = GLOBAL_XSYS2AUTO_MAP{k}{2};
            q = GLOBAL_PIHA.Locations{loc}.q;
        end                                      
    end
      

    if (q(fsmidx) == stateidx)
        ap = set_state(ap,k,1);
    end
end
return




