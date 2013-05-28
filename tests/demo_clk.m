global GLOBAL_APPROX_PARAM
GLOBAL_APPROX_PARAM = parameters(1);

INV = linearcon([],[],[1 0],[1]); 
X0 = linearcon([],[],[eye(2); -eye(2)],1e-1*[1;1;1;1]);
v = [1;2];
mapping = clk_map(X0,v,INV);


% plot
t = 1.15;
vtcs = vertices(X0);
figure;
hold on;
plot(X0);
box on
plot(mapping{1}{1});
for i=1:length(vtcs)
    x = vtcs(i);
    y = x + v*t;
    plot([x(1) y(1)], [x(2), y(2)], 'r--');
end