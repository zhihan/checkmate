global GLOBAL_APPROX_PARAM
GLOBAL_APPROX_PARAM = parameters(1);

INV = linearcon([],[],[1 0],[1]); 
X0 = linearcon([],[],[eye(2); -eye(2)],1e-1*[1;1;1;1]);
mapping = fs_nonlin_map(@dblclk,[],X0,INV,linearcon,0.05,2)


% plot
t = 1.15;
vtcs = vertices(X0);
figure;
hold on;
plot(X0);
box on
for i=1:length(mapping{1})
    plot(mapping{1}{i});
end
for i=1:length(vtcs)
    x = vtcs(i);
    y = x + v*t;
    plot([x(1) y(1)], [x(2), y(2)], 'r--');
end