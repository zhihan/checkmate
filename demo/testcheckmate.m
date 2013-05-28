function status = testcheckmate(point)
% TCHECKMATE Test checkmate basis functionalities.

% Note: This M-file is compatible with R14 and later.
status = 'unknown';

if nargin ==0
    point = 'all';
end

status = check_install;
if strcmpi(status, 'failed')
    return;
end

if strcmpi(point, 'all') || strcmpi(point, 'tboing_verify')
    status = tboing_verify();
    if strcmpi(status, 'failed')
        return;
    end
end

if strcmpi(point, 'all') || strcmpi(point, 'tboing_explore')
    status = tboing_explore();
    if strcmpi(status, 'failed')
        return;
    end
end

if strcmpi(point, 'all') || strcmpi(point, 'tetc5d_explore')
    status = tetc5d_explore();
    if strcmpi(status, 'failed')
        return;
    end
end

if strcmpi(point, 'all') || strcmpi(point, 'tetc2d_verify')
    status = tetc2d_verify();
    if strcmpi(status, 'failed')
        return;
    end
end
if strcmpi(point, 'all') || strcmpi(point, 'tph_verify')
    status = tph_verify();
    if strcmpi(status, 'failed')
        return;
    end
end

if strcmpi(point, 'all') || strcmpi(point, 'tph_explore')
    status = tph_explore();
    if strcmpi(status, 'failed')
        return;
    end
end

if strcmpi(point, 'all') || strcmpi(point, 'tacc_explore')
    status = tacc_explore();
    if strcmpi(status, 'failed')
        return;
    end
end

end

function status = check_install()
a = which('verify.m');
if ~isempty(a)
    status = 'success';
else
    status = 'failed';
end
end

function status = tboing_verify()
oldDir = pwd;
dir = 'boing';
global GLOBAL_APPROX_PARAM
cd(dir);
mdl = 'boing';
setup_boing;
load_system(mdl);
try
    fprintf('\n\n->Using default (CH or ORH) approximations\n');
    verify;
    
    setup_boing;
    fprintf('\n\n->Using convex hull approximations\n');

    GLOBAL_APPROX_PARAM.hull_flag = 'convexhull';
    
    verify;
    status = 'success';
catch 
    disp(lasterror);
    status = 'failed';
    bdclose(mdl);
end
bdclose(mdl);

cd(oldDir);

end

function status = tboing_explore()
oldDir = pwd;
dir = 'boing';

cd(dir);
mdl = 'boing';
setup_boing;
load_system(mdl);
try
    explore;
    status = 'success';
catch
    disp(lasterr);
    status = 'failed';
end
bdclose('all');
cd(oldDir);
end

function status = tetc5d_explore()
oldDir = pwd;
dir = 'etc5d';

cd(dir);
mdl = 'etc5d';
setup5d;
load_system(mdl);
try
    explore;
    status = 'success';
catch
    disp(lasterr);
    status = 'failed';
end
bdclose('all');
cd(oldDir);
end

function status = tetc2d_verify()
oldDir = pwd;
dir = 'etc_reg';
    global GLOBAL_APPROX_PARAM
cd(dir);
mdl = 'etc_reg';
setup_reg;
load_system(mdl);
try
    fprintf('\n\n->Using default (CH or ORH) approximations\n');
    verify;

    setup_reg;
    fprintf('\n\n->Using convex hull approximations\n');

    GLOBAL_APPROX_PARAM.hull_flag = 'convexhull';
    verify;
    
    status = 'success';
catch 
    disp(lasterror);
    status = 'failed';
end
bdclose('all');
cd(oldDir);
end

function status = tph_verify()
oldDir = pwd;
dir = 'ph_plant';
    global GLOBAL_APPROX_PARAM
cd(dir);
mdl = 'ph_plant';
setup_ph;
load_system(mdl);
try
    fprintf('\n\n->Using default (CH or ORH) approximations\n');
    verify;
    
    setup_ph;
    fprintf('\n\n->Using convex hull approximations\n');
    

    GLOBAL_APPROX_PARAM.hull_flag = 'convexhull';
    verify;
    
    status = 'success';
catch
    disp(lasterr);
    status = 'failed';
end
bdclose('all');
cd(oldDir);
end

function status = tph_explore()
oldDir = pwd;
dir = 'ph_plant';

cd(dir);
mdl = 'ph_plant';
setup_ph;
load_system(mdl);
try
    explore;
   
    status = 'success';
catch
    disp(lasterr);
    status = 'failed';
end
 bdclose('all');
cd(oldDir);
end

function status = tacc_explore()
oldDir = pwd;
dir = 'V2V';

cd(dir);
mdl = 'acc';

load_system(mdl);
try
    acc_setup;
    explore;
    
    status = 'success';
catch
    disp(lasterr);
    status = 'failed';
end
bdclose('all');
cd(oldDir);
end
