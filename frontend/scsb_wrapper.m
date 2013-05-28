function [x_dot,x_reset] = scsb_wrapper(swfunc,x,u,p,...
    use_reset,use_param,use_sd,controller_output)

% Description:
%   SCSB wrapper function. This function calls the user-defined switching
%   function to return the derivative and reset vector.

% Call the switching function based on whether or not the reset is used
% and whether or not the parameter is used.

%If the controller output exists, it constitutes part of the state of the system for
%simulation.
if use_sd
    x = [ x ; controller_output];
end

%Note that 'time' is passed to this wrapper function, but it is not currently being used.  If it is
%decided to change CheckMate such that the SCSB s-function passes time to the user-defined m-file
%(thus potentially creating a time-varying system), the 'feval' lines commented out in what follows should be used
%instead of the 'feval' lines that are currently being used.

if use_reset
    if use_param
        [sys,type,x_reset] = feval(swfunc,x,u,p);
    else
        [sys,type,x_reset] = feval(swfunc,x,u);
    end
else
    if use_param
        [sys,type] = feval(swfunc,x,u,p);
    else
        [sys,type] = feval(swfunc,x,u);
    end
end

if ~use_sd
    % Compute state derivative vector according to continuous dynamics type.
    switch type,
        case 'linear',
            % If the differential equation type is linear dx/dt = Ax + b, the returned
            % sys from swfunc is a structure containing the matrix A and the vector b.
            A = sys.A; b = sys.b;
            x_dot = A*x + b;
        case {'clock','nonlinear'}
            x_dot = sys;
        otherwise,
            error('CheckMate:SFun',['Unknown type of differential equation ''' type ...
                ''' returned from switching function ' sprintf('\n') ...
                '   ''' swfunc '''.'])
    end
else
    %If sampled-data analysis is used, make use of the plant and controller
    %description of the system.

    % Compute state derivative vector according to continuous dynamics type.
    switch type,
        case 'linear',
            % If the differential equation type is linear dx/dt = Ax + b, the returned
            % sys from swfunc is a structure containing:
            %     sys.A  = plant A matrix
            %     sys.b  = plant b matrix
            %     sys.r  = plant r vector
            %     sys.C  = plant C matrix
            %     sys.Ap = controller state A matrix
            %     sys.bp = controller state b matrix
            %     sys.rp = controller state r vector
            %     sys.Cp = controller C matrix
            %     sys.Dp = controller D matrix
            %     sys.rpp= controller output r vector
            A = sys.A; b = sys.b;
            r = sys.r; C = sys.C;
            Ap = sys.Ap; bp = sys.bp;
            rp = sys.rp; Cp = sys.Cp;
            Dp = sys.Dp; rpp = sys.rpp;
            xdim = size(A,1);
            zdim = size(Ap,1);
            if (~(xdim+zdim+size(controller_output,1)==size(x,1)))
                error('CheckMate:SFunError', ...
                    'Dimensions of system equations are incorrect.')
            end
            %continuous portion of system
            x_dot(1:xdim,1) = A*x(1:xdim) + b*controller_output+r;
            %discrete time state update
            x_dot(xdim+1:xdim+zdim) = Ap*x(xdim+1:xdim+zdim)+bp*(C*x(1:xdim))+rp;
            %Controller output update.  Note that x_dot is of higher dimension than x.  This is because
            %x is composed of the plant state and the controller state, while the x_dot also contains the
            %controller output update.
            x_dot(xdim+zdim+1:xdim+zdim+size(controller_output,1)) = Cp*x(xdim+1:xdim+zdim)+Dp*x(1:xdim)+rpp;
        case {'clock','nonlinear'}
            x_dot = sys;
        otherwise,
            error('CheckMate:SFun:UnknownType', ...
                ['Unknown type of differential equation ''' type ...
                ''' returned from switching function ' sprintf('\n') ...
                '   ''' swfunc '''.'])
    end

end

% Make sure x_dot is a column vector.
x_dot = x_dot(:);

if use_reset
    if isfield(x_reset,'A') && isfield(x_reset','B')
        x_reset = x_reset.A*x + x_reset.B;
        % Make sure x_reset is a column vector.
        x_reset = x_reset(:);
    else

        % This code was added by JPK (8/2002) to catch the old style of
        % reset specification (i.e. where the user passes a reset point
        % instead of A and B.

        disp('Error in the user defined dynamics m-file.');
        disp('The reset function (the third output of the user-defined dynamics file), should contain')
        disp('a .A field and a .B field where there reset is given by x_r=Ax+B.  See the Boing demo for')
        disp('an example of a system with resets.  If you are using a CheckMate model from a version')
        disp('previous to 3.01m, the reset function will need to be changed in order to accomodate this')
        disp('convention.')
        error('CheckMate:SfunError','Error in the user defined dynamics m-file.')
    end
else
    x_reset = x(:);
end

return
