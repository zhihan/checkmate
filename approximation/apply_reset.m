function new_mapping=apply_reset(polytope,q_temp,transitions)

%This function applies the reset mapping (if applicable) to the given polytope
%(given the discrete state q). Changed to handle general resets. 
%Modified 02/12/02 Ansgar
%Modified 03/15/02 HWT


global GLOBAL_PIHA


%The 'next' q must be inferred.
%Find destination location number
%This code was changed by JPK 8/02.  New code uses Zhi's new
%idx field in transition to infer what the new location is.
q_temp(transitions.idx) = transitions.destination;
q_global = q_temp;
        
 
         
if (transitions.reset_flag) 
    % Apply the identity, except otherwise stated
    T_reset=eye(dim(polytope));
    v_reset=zeros(dim(polytope),1);

    % for each scsb that will be reset do the folowing
    for k1=1:length(transitions.reset_scs_index)
       paradim=GLOBAL_PIHA.SCSBlocks{transitions.reset_scs_index(k1)}.paradim;
       swfunc=GLOBAL_PIHA.SCSBlocks{transitions.reset_scs_index(k1)}.swfunc;
       dimension=GLOBAL_PIHA.SCSBlocks{transitions.reset_scs_index(k1)}.nx;
       % extract the correct components for the location for this SCSB
       q=q_global(GLOBAL_PIHA.SCSBlocks{transitions.reset_scs_index(k1)}.fsmbindices);
       % reset the transformation matrix
    
       % Ignore the reset if the function swfunc doesn't provide it.
       if (nargout(swfunc)<3)
          error('ChekcMate:NoReset', ...
              '%s does not provide a reset-value, and can therefore not be reset.', ...
              swfunc);
       else
        
          %Infer affine transformation (parameters T and v for 'transform.m'
          if  nargin(swfunc)>2
             [dum1,dum2,reset]=feval(swfunc,zeros(dimension,1),q,zeros(paradim,1));
          else
             [dum1,dum2,reset]=feval(swfunc,zeros(dimension,1),q);
          end; %if
        
          % This code was added by JPK (8/2002) to catch the old style of 
          % reset specification (i.e. where the user passes a reset point
          % instead of A and B.
          
          if isfield(reset,'A')&& isfield(reset','B')  
            T = reset.A;
            v = reset.B;
          else
            disp('Error in the user defined dynamics m-file.'); 
            disp('The reset function (the third output of the user-defined dynamics file), should contain')
            disp('a .A field and a .B field where there reset is given by x_r=Ax+B.  See the Boing demo for')
            disp('an example of a system with resets.  If you are using a CheckMate model from a version')
            disp('previous to 3.01m, the reset function will need to be changed in order to accomodate this')
            disp('convention.')
            error('Error in the user defined dynamics m-file.')
          end
          
      
          % determine the index of the state vector that is goverened by swfunc.
          start_index=1;
          for k2=1:(transitions.reset_scs_index(k1)-1)
             start_index=start_index+GLOBAL_PIHA.SCSBlocks{k2}.nx;
          end;
          end_index=start_index+dimension-1;        
        
          T_reset(start_index:end_index,start_index:end_index)=T;
          v_reset(start_index:end_index,1)=v;
       end; % else,  i.e., nargout(swfunc)>=3, so reset occurs
    end; % for each reset SCSB
    
    % Finally, transform it
    new_mapping=transform(polytope,T_reset,v_reset);
    
    % Grow lower dimensional new_mappings to full dimensions
    if rank(T_reset)<dim(polytope)
        [CE,dE,CI,dI] = linearcon_data(new_mapping);
        new_mapping = grow_polytope_for_iauto_build(CE,dE,CI,dI,linearcon);
    end;
        
else % no reset
   new_mapping=polytope;
end % if any reset

return
