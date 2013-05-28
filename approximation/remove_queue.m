function [queue_new,head] = remove_queue(queue)

head = queue(1);
queue_new = queue(2:length(queue));

