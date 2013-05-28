function inputblks = trace_mux_network(dstblk,dstport)

% Find handles and order of muxed input blocks
%
% Syntax:
%   "inputblks = trace_mux_network(dstblk,dstport)"
%
% Description:
%   "trace_mux_network(dstblk,dstport)" returns, in order, the input
%   blocks that are muxed together before feeding into the destination
%   port "dstport" of the destination block "dstblk".
%
% See Also:
%   trace_pthb_input,trace_scsb_input

src = find_src_port(dstblk,dstport);
if isempty(src)
  error('CheckMate:PIHA:UnconnectedBlock', ...
      sprintf('Input port "%s" of block "%s" is not connected.', ...
        dstport,get(dstblk,'Name')));
end
inputblks = find_mux_input_blocks(src.block);

%
function inputblks = find_mux_input_blocks(block)

BlockType = get_param(block,'BlockType');
if strcmp(BlockType,'Mux')
  inputblks = [];
  n = eval(get_param(block,'Inputs'));
  for k = 1:n
      src = find_src_port(block,num2str(k));
      if isempty(src)
          error( 'Checkmate:PIHA:UnconnectedLine', ...
              sprintf('Input port "%d" of block "%s" is not connected.', ...
              k,get_param(block,'Name')));
      end
    inputblks = [inputblks; find_mux_input_blocks(src.block)];
  end
else
  inputblks = block;
end
