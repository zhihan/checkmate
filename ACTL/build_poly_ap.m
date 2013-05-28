function ap = build_poly_ap(apname)


global GLOBAL_PIHA GLOBAL_TRANSITION GLOBAL_AUTO2XSYS_MAP


% build region for apname if it is a new atomic proposition

N = length(GLOBAL_TRANSITION);
NL = length(GLOBAL_PIHA.Locations);
switch apname
  case 'null_event',
    ap = region(N,(0:NL-1) + GLOBAL_AUTO2XSYS_MAP.ne_start);
  case 'time_limit',
    ap = region(N,(0:NL-1) + GLOBAL_AUTO2XSYS_MAP.tl_start);
  case 'out_of_bound',
    ap = region(N,(0:NL-1) + GLOBAL_AUTO2XSYS_MAP.oob_start);
  case 'indeterminate',
    ap = region(N,(0:NL-1) + GLOBAL_AUTO2XSYS_MAP.ind_start);
  otherwise,
    error(['Invalid atomic proposition name ''' apname '''.'])
end


% -----------------------------------------------------------------------------

