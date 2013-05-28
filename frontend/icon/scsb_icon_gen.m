% Script file for generating CheckMate switched continuous system block
% (SCSB) mask icon
%
% Syntax:
%   "scsb_icon_gen"
%
% Description:
%   "scsb_icon_gen" generates a figure displaying the SCSB mask icon, and
%   returns the two sets of coordinates used to generate the plot.
%
% Note:
%   "scsb_icon_gen" was used to obtain the sets of coordinates used in
%   "scsb_icon()" which is used to generate the actual mask icon in
%   CheckMate.

T = 0:0.2:10;
Y1 = impulse([0 0 1],[1 0.5 4],T);
Y2 = impulse([0 0 1],[1 -0.5 4],T);

mx1 = max(Y1);
mn1 = min(Y1);
Y1 = Y1'/(mx1-mn1)*0.3;

mx2 = max(Y2);
mn2 = min(Y2);
Y2 = Y2'/(mx2-mn2)*0.32;

Xcoord = [];
Ycoord = [];
figure(2); clf
hold on
axis([0 1 0 1])
plot(T/10*0.3+0.1,Y1+0.75)
Xcoord = T/10*0.3+0.1;
Ycoord = Y1+0.75;

plot(T/10*0.3+0.1,Y2+0.25)
Xcoord = [Xcoord NaN T/10*0.3+0.1];
Ycoord = [Ycoord NaN Y2+0.25];
plot([0.05 0.05 0.45 0.45 0.05],[0.05 0.45 0.45 0.05 0.05])
plot([0.05 0.05 0.45 0.45 0.05],[0.55 0.95 0.95 0.55 0.55])

Xcoord = [Xcoord NaN [0.05 0.05 0.45 0.45 0.05] ...
      NaN [0.05 0.05 0.45 0.45 0.05]];
Ycoord = [Ycoord NaN [0.05 0.45 0.45 0.05 0.05] ...
      NaN [0.55 0.95 0.95 0.55 0.55]];
   
R = 0.025;
theta = [0:1:10]*2*pi/10;
X = R*sin(theta); Y = R*cos(theta);
plot(X+0.475,Y+0.75)
Xcoord = [Xcoord NaN X+0.475];
Ycoord = [Ycoord NaN Y+0.75];
plot(X+0.475,Y+0.25)
Xcoord = [Xcoord NaN X+0.475];
Ycoord = [Ycoord NaN Y+0.25];
plot(X+0.725,Y+0.5)
Xcoord = [Xcoord NaN X+0.725];
Ycoord = [Ycoord NaN Y+0.5];
plot([0.5 0.7],[0.75 0.5])
plot([0.75 0.95],[0.5 0.5])
Xcoord = [Xcoord NaN 0.5 0.7 NaN 0.75 0.95];
Ycoord = [Ycoord NaN 0.75 0.5 NaN 0.5 0.5];

R = 0.45;
theta = [0:1:10]*pi/2/10+3*pi/4;
X = R*cos(theta); Y = R*sin(theta);
plot(X+1,Y+0.5)
Xcoord = [Xcoord NaN X+1];
Ycoord = [Ycoord NaN Y+0.5];
plot([X(1)+0.95 X(1)+1],[Y(1) Y(1)]+0.5) 
Xcoord = [Xcoord NaN X(1)+0.95 X(1)+1];
Ycoord = [Ycoord NaN Y(1)+0.5 Y(1)+0.5];
plot([X(1)+1 X(1)+1],[Y(1) Y(1)-0.06]+0.5) 
Xcoord = [Xcoord NaN X(1)+1 X(1)+1];
Ycoord = [Ycoord NaN Y(1)+0.5 Y(1)+0.44];
hold off

fprintf('\n\n\nX\n');
for k = 1:length(Xcoord)
   if (k > 1) & (rem(k-1,6) == 0)
      fprintf(1,'...\n');
   end
   fprintf(1,'%f ',Xcoord(k));
end
fprintf('\n\n\nY\n');
for k = 1:length(Ycoord)
   if (k > 1) & (rem(k-1,6) == 0)
      fprintf(1,'...\n');
   end
   fprintf(1,'%f ',Ycoord(k));
end






