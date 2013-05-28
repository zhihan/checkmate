function sfdata = process_sf_data(sys, fsmbHandle)

machine_id = get_machine_id(sys);
if isempty(machine_id)
    fprintf(1,['\007Error: Cannot find machine id for ''' sys '''!!!\n'])
    return
end

sfdata = {};
for k = 1:length(fsmbHandle)

    block_name = get_param(fsmbHandle(k),'Name');
    chart_id = find_chart_id(machine_id,block_name);

    if isempty(chart_id)
        fprintf(1,['\007Error: Cannot find chart id for "' block_name '"!!!\n'])
        return
    else

        data_id = sf('find',sf('DataOf',chart_id),'.scope','INPUT_DATA');
        input_data = {};
        clock=[];
        in_num=0;

        for l = 1:length(data_id)

            [expression,clock_handle]=sf_input_expression(fsmbHandle(k),'data',l);
            if ~isempty(clock_handle)
                error('CheckMate:PIHA','Clocks must be event inputs.');
            else
                in_num=in_num+1;
                input_data{in_num}.Name = sf('get',data_id(l),'.name');
                if input_data{in_num}.Name(1)==' '|| input_data{in_num}.Name(length(input_data{in_num}.Name))==' '
                    error('CheckMate:PIHA',...
                        'The names of Stateflow input data variables cannot have leading or trailing spaces.')
                end

                input_data{in_num}.Expression = expression;
            end%if

        end%for

        event_id = sf('find',sf('EventsOf',chart_id),'.scope','INPUT_EVENT');
        input_event = {};

        for l = 1:length(event_id)

            event_name = sf('get',event_id(l),'.name');
            if event_name(1)==' '|| event_name(length(event_name))==' '
                error('CheckMate:PIHA', ...
                'The names of Stateflow input events cannot have leading or trailing spaces.')
            end
            if ~strcmp(event_name,'start')

                [expression,clock_handle]=sf_input_expression(fsmbHandle(k),'event',l);

                if ~isempty(clock_handle)
                    clock_num=length(clock)+1;
                    clock{clock_num}.Name=sf('get',event_id(l),'.name');
                    clock{clock_num}.ClockBlock=get_param(clock_handle,'name');
                    clock{clock_num}.ClockHandle=clock_handle;
                else


                    % ignore the start event, which is used only for simulation purpose
                    new = length(input_event)+1;
                    input_event{new}.Name = event_name;

                    if ~isempty(sf('find',event_id(l),'.trigger','RISING_EDGE_EVENT'))
                        input_event{new}.Trigger = 'RISING_EDGE_EVENT';
                    end

                    if ~isempty(sf('find',event_id(l),'.trigger','FALLING_EDGE_EVENT'))
                        input_event{new}.Trigger = 'FALLING_EDGE_EVENT';
                    end

                    if ~isempty(sf('find',event_id(l),'.trigger','EITHER_EDGE_EVENT'))
                        input_event{new}.Trigger = 'EITHER_EDGE_EVENT';
                    end

                    if strcmp('RISING_EDGE_EVENT',input_event{new}.Trigger)
                        input_event{new}.Expression = ...
                            sf_input_expression(fsmbHandle(k),'event',l);
                    elseif strcmp('FALLING_EDGE_EVENT',input_event{new}.Trigger)
                        input_event{new}.Expression = ...
                            ['~(' sf_input_expression(fsmbHandle(k),'event',l) ')'];
                    else
                        error('CheckMate:PIHA', ...
                            'This version only supports  rising and falling event edges!')
                    end%if

                end%if
            end%if
        end%for

        sfdata{k}.BlockName = block_name;
        sfdata{k}.SimulinkHandle = fsmbHandle(k);
        sfdata{k}.StateflowChartID = chart_id;
        sfdata{k}.InputData = input_data;
        sfdata{k}.InputEvent = input_event;
        sfdata{k}.Clock = clock;

    end%if

end%for