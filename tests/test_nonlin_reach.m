function result = test_nonlin_reach(point)

global GLOBAL_APPROX_PARAM;
GLOBAL_APPROX_PARAM = parameters(1);
GLOBAL_APPROX_PARAM.T = 0.01;
GLOBAL_APPROX_PARAM.hull_flag = 'convexhull';

theta = 0.3;

A = [0 0 0; 0 sin(theta) -cos(theta); 0 cos(theta) sin(theta)];
b = [1; 0; 0];

I = linearcon([],[],[1 0 0], 1);
X0 = linearcon([],[],[eye(3); -eye(3)], [0.5; 1+1e-2; 1e-2; 0.5; -1+1e-2; 1e-2]);

mapping = fs_nonlin_map(@linode,{A,b},X0,I,linearcon,GLOBAL_APPROX_PARAM.T,1.6);

for i=1:length(mapping{1})
    c = transform(mapping{1}{i}, [0 1 0; 0 0 1], [0;0]);
    plot(c, 'r');
end
axis square; axis equal;