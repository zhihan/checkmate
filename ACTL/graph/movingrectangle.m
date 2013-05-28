function movingrectangle(f,mode)

if nargin <2 %user mode
    ax = gca;
    set(ax,'buttondownfcn',['movingrectangle(gca,1)'],'tag','movingrectangle');
    set(ax,'units','pixels');
else %callback mode
    if strcmp(get(gcf,'selectiontype'),'open')
       %
    else
        switch mode
            case 1 % axis's buttondownfcn invoked
                cp=get(gca,'currentpoint');
                x = cp(1,1);
                y = cp(2,2);
                % find the corresponding rectangle
                rects = findobj(gca, 'type', 'rectangle');
                pos=cell2mat(get(rects,'position'));
                xdist = pos(:,1) -x + pos(:,3)/2;
                ydist = pos(:,2) -y + pos(:,4)/2;
                d=sqrt(ydist.^2+xdist.^2);
                index=find(d==min(d));
                index = index(1);
                r = get(f,'userdata');
                r.handle = rects(index);
                r.offset = [pos(index,1) - x, pos(index,2) - y];
                r.size = [pos(index,3), pos(index,4)];
                set(gcf, 'userdata', r);
                set(gcf,'windowbuttonmotionfcn','movingrectangle(gcf,2)','doublebuffer','on');
                set(gcf,'windowbuttonupfcn','movingrectangle(gcf,3)');
                
            case 2 % windowbuttonmotion function for the figure
                cp=get(gca,'currentpoint');
                x = cp(1,1);
                y = cp(2,2);
                h = get(f,'userdata');
                set(h.handle, 'position', [x+h.offset(1),y+h.offset(2),h.size(1),h.size(2)]);
                r = get(h.handle,'userdata');
                set(r.label, 'position',[x+h.offset(1),y+h.offset(2)]);
                for i=1:length(r.in)
                    linex = get(r.in(i),'xdata');
                    liney = get(r.in(i),'ydata');
                    linex(2) = x+h.offset(1)+h.size(1)/2;
                    liney(2) = y+h.offset(2)+ h.size(2)/2; 
                    direction = [linex(2), liney(2)] -[linex(1), liney(1)];
                    direction = direction/norm(direction);
                    linex(2) = linex(2) - h.size(1)* direction(1);
                    liney(2) = liney(2) - h.size(2)* direction(2);
                    set(r.in(i), 'xdata', linex, 'ydata', liney);
                    update_arrow(r.in(i), [linex(1),liney(1)],[linex(2),liney(2)]);
                end
                for i=1:length(r.out)
                    linex = get(r.out(i),'xdata');
                    liney = get(r.out(i),'ydata');
                    direction = [linex(2), liney(2)] -[linex(1), liney(1)];
                    direction = direction/norm(direction);
                    linex(2) = linex(2) + h.size(1)* direction(1);
                    liney(2) = liney(2) + h.size(2)* direction(2);
                    linex(1) = x+h.offset(1) + h.size(1)/2;
                    liney(1) = y+h.offset(2) + h.size(2)/2; 
                    direction = [linex(2), liney(2)] -[linex(1), liney(1)];
                    direction = direction/norm(direction);
                    linex(2) = linex(2) - h.size(1)* direction(1);
                    liney(2) = liney(2) - h.size(2)* direction(2);
                    set(r.out(i), 'xdata', linex, 'ydata', liney);
                    update_arrow(r.out(i), [linex(1),liney(1)],[linex(2),liney(2)]);
                end
            case 3 % windowbutton up function 
                set(gcf,'windowbuttonmotionfcn',[],'windowbuttonupfcn',[]);
        end
    end
end
  
%-------------------------------------------
function update_arrow(handle,src,dst)
arrow = get(handle, 'userdata');
direction = (dst - src)/norm(dst-src);
pert = null(direction)';
startc = pert*0.02 + dst - direction*0.05;
termc = -pert*0.02 + dst - direction*0.05;
xdata = [startc(1), dst(1), termc(1)];
ydata = [startc(2), dst(2), termc(2)];
set(arrow, 'xdata', xdata, 'ydata', ydata);
return


