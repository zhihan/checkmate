function [T,v] = overall_system_reset(SCSBlocks,q,reset_indices)

% Get overall reset matrix for the given the FSM state vector.
%
% Syntax:
%   "[T,v] = overall_reset_matrix(SCSBlocks,q,reset_flag)"
%
% Description:
%   Return the composite state matrix "T" and vector "v" representing
%   the affine trasformation
%
%
%   "Tx + v"
%
%
%   for the given FSM state vector "q" and the SCSBs information are stored
%   in "SCSBlocks".
%
% Implementation:
%   For the "k"-th SCSB, compute the vector "uk", the outputs of FSMBs in
%   "q" in the order that they feed into the "k"-th SCSB in the Simulink
%   diagram. Use "uk" to call the `switching function` for the SCSB to
%   obtain the matrix-vector pair for that block.  Stack the matrices and
%   vectors from the SCSBs together to form the overall (composite)
%   matrix-vector pair.
%
% See Also:
%   overall_system_matrix,overall_system_clock,overall_system_ode

T=[];
v=[];

for k = 1:length(SCSBlocks)
    nxk = SCSBlocks{k}.nx;

    % Use identity reset as a default transformation.
    Tk = eye(nxk);
    vk = zeros(nxk,1);

    % Obtain the reset matrices if the current SCSB is to be reset.
    if ismember(k,reset_indices)
        swfunck = SCSBlocks{k}.swfunc;
        paradimk = SCSBlocks{k}.paradim;

        % Extract the FSM components from the overall FSM state vector for the
        % current SCSB.
        uk = q(SCSBlocks{k}.fsmbindices);

        % Make a dummy call to the switching function for the current SCSB
        % with the correct value of q.
        
        %if  nargin(swfunck) > 2
        %    [dum1,dum2,reset] = feval(swfunck,zeros(nxk,1),uk,zeros(paradimk,1));
        %else
            [dum1,dum2,reset] = feval(swfunck,zeros(nxk,1),uk);
        %end

        % Extract the transformation matrix-vector pair from the return
        % argument.
        Tk = reset.A;
        vk = reset.B;
    end

    % Stack the transformation matrices.
    T = [            T               zeros(size(T,1),size(Tk,2))
        zeros(size(Tk,1),size(T,2))            Tk              ];
    v = [v; vk];
end

return
