function plot(p,color)

% Plot a polyhedron object 
%
% Syntax:
%   "plot(poly)"
%
%   "plot(poly,color)"
%
% Description:
%   "plot(poly)" plots the linear constraint object "poly" in blue.
%   "plot(poly,color)" plots "poly" in the color specified in the rgb row
%   vector "color=[r g b]".
%
% See Also:
%   polyhedron,linearcon,plot

if (nargin == 1)
  color = [0 0 1];
end

if isempty(p)
  return
end

n = dim(p.vtcs);
dimension = n-length(p.dE);

if (n == 2)
  
  if (dimension == 2)
    for k = 1:length(p.VI)
      vk = p.VI{k};
      PT = vk(1:length(vk));
      if ~isempty(PT)
          line(PT(1,:),PT(2,:),'color',color)
      end
    end
  end

  if (dimension == 1)
    v = p.VE{1};
    PT = v(1:length(v));
    line(PT(1,:),PT(2,:),'color',color)
  end

  if (dimension == 0)
    v = p.VE{1};
    PT = v(1:length(v));
    hold on
    plot(PT(1,:),PT(2,:),'x','color',color)
    hold off
  end

end

if (n == 3)

  if (dimension == 3)
    X = []; Y = []; Z = [];
    for k = 1:length(p.dI)
      N(k) = length(p.VI{k});
    end
    Nmax = max(N);

    V = p.vtcs(1:length(p.vtcs))';
    F = [];
    for k = 1:length(p.dI)
      vk = p.VI{k};
      normal = (p.CI(k,:))';
      Vk = order_vertices(vk,normal);
      Fk = zeros(1,Nmax)*NaN;
      for l = 1:size(Vk,1)
        Fk(1,l) = find_index(p.vtcs,Vk(l,:)');
      end
      F = [F; Fk];
    end % for k
% =========================================================================
% Corrected by Dong Jia from
%     patch('Vertices',V,'Faces',F,'FaceColor','flat', ...
%           'FaceVertexCData',color, ...
%           'FaceLighting','flat','BackFaceLighting','lit')
% to
    patch('Vertices',V,'Faces',F,'FaceColor',color, ...
          'FaceLighting','flat','BackFaceLighting','lit');
% =========================================================================
  end
  
  if (dimension == 2)
    normal = (p.CE)';
    V = order_vertices(p.vtcs,normal);
    X = V(:,1)';
    Y = V(:,2)';
    Z = V(:,3)';
    patch(X,Y,Z,color)
  end

  if (dimension == 1)
    v = p.VE{1};
    PT = v(1:length(v));
    line(PT(1,:),PT(2,:),PT(3,:),'color',color)
  end

  if (dimension == 0)
    v = p.VE{1};
    PT = v(1:length(v));
    hold on
    plot3(PT(1,:),PT(2,:),PT(3,:),'x','color',color)
    hold off
  end

end

if (n > 3)
  disp('POLYHEDRON/PLOT: No plotting support for higer dimensions.....\n')
end

return


% ----------------------------------------------------------------------------

function V = order_vertices(vtcs,normal)

% This routine assumes that all vertices lie on the same
% plane and that all verties are on the boundary (edge) of
% a polyhedron face (no point strictly inside).  
% Things can go wrong if bad vertices are given.

% Take the null space c'x = 0 as the basis for the points
% on this hyperplane
E = null(normal');
Er = E(1:2,:);

% Take the average of vertices as the origin, transform each point

N = length(vtcs);
v0 = average(vtcs);

theta = zeros(1,N);
for k = 1:N
  xk = E\(vtcs(k)-v0);
  theta(k) = atan2(xk(2),xk(1));
end

% Sort the angles to find the order of vertices
order = [1:N];
for k = 1:N
  for l = k+1:N
    if (theta(l) < theta(k))
      theta_temp = theta(k);
      theta(k) = theta(l);
      theta(l) = theta_temp;
      order_temp = order(k);
      order(k) = order(l);
      order(l) = order_temp;
    end
  end
end

X = zeros(N,1); Y = X; Z = X;
V = [];
for k = 1:N
  V(k,:) = vtcs(order(k))';
end
return


