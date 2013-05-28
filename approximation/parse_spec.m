function parse_spec()

global GLOBAL_SPEC_TREE GLOBAL_AP_BUILD_LIST GLOBAL_PIHA GLOBAL_SPEC
global GLOBAL_SPEC_ELEMENT 

GLOBAL_SPEC_TREE=cell(0);
GLOBAL_SPEC_ELEMENT = cell(0);
GLOBAL_AP_BUILD_LIST=cell(0);

spec_count=0;
for m=1:length(GLOBAL_PIHA.FSMBlocks)
    for n=1:length(GLOBAL_PIHA.FSMBlocks{m}.states)
        state_name=GLOBAL_PIHA.FSMBlocks{m}.states{n};
        if findstr('avoid',state_name)
            new=length(GLOBAL_SPEC)+1;
            fsmname = GLOBAL_PIHA.FSMBlocks{m}.name;
            GLOBAL_SPEC{new}=['(AG ~out_of_bound)&(AG ~' fsmname ' == ' state_name ')'];
            spec_count=spec_count+1;
        elseif findstr('reach',state_name)
            new=length(GLOBAL_SPEC)+1;
            fsmname = GLOBAL_PIHA.FSMBlocks{m}.name;
            GLOBAL_SPEC{new}=['(AG ~out_of_bound)&(AF ' fsmname ' == ' state_name ')'];
            spec_count=spec_count+1;
        end
    end
end
GLOBAL_SPEC{length(GLOBAL_SPEC)+1}=spec_count;

for i=1:length(GLOBAL_SPEC)-1
    GLOBAL_SPEC_ELEMENT{i} = GLOBAL_SPEC{i};
    fprintf(1,'\nParsing specification %d: %s\n',i,GLOBAL_SPEC_ELEMENT{i});
    % match parentheses
    match_paren(GLOBAL_SPEC_ELEMENT{i},0);
    % identify terminal symbols in the ACTL specification string and
    % parse the symbols to obtain parse tree for the specification
    GLOBAL_SPEC_TREE{i} = parse(identerm(GLOBAL_SPEC_ELEMENT{i}));
    % compile the list of all atomic propositions in the parse tree and
    % replace all the atomic proposition subtree by a single leaf
    fprintf('Compiling list of atomic propositions: %s\n',GLOBAL_SPEC_ELEMENT{i});
    [GLOBAL_SPEC_TREE{i},GLOBAL_AP_BUILD_LIST{i}] = ...
        compile_ap(GLOBAL_SPEC_TREE{i});
    for k = 1:length(GLOBAL_AP_BUILD_LIST{i})
        fprintf(1,' * %s\n',GLOBAL_AP_BUILD_LIST{i}{k}.name)
    end
end
