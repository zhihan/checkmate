function result = test_lin_reach(point)

global GLOBAL_APPROX_PARAM;
GLOBAL_APPROX_PARAM = parameters(1);
GLOBAL_APPROX_PARAM.T = 0.01;
GLOBAL_APPROX_PARAM.hull_flag = 'convexhull';

theta = 0.3;

A = [0 0 0; 0 sin(theta) -cos(theta); 0 cos(theta) sin(theta)];
b = [1; 0; 0];

I = linearcon([],[],[1 0 0], 1);
X0 = linearcon([],[],[eye(3); -eye(3)], [0.5; 1+1e-2; 1e-2; 0.5; -1+1e-2; 1e-2]);
tic;
mapping = fs_lin_map(A,b,X0,I);
toc;
% for i=1:length(mapping{1})
%     c = transform(mapping{1}{i}, [0 1 0; 0 0 1], [0;0]);
%     plot(c);
% end
% axis square; axis equal;