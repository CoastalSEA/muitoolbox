function ison = ispointonline(line,point,isbound,limitfactor)
%
%-------function help------------------------------------------------------
% NAME
%   ispointonline.m
% PURPOSE
%   determine whether a point lies on a line 
% USAGE
%   ison = ispointonline(line,point,limitfactor)
% INPUTS
%   line - matrix of two points with x in row 1 and y in row 2, or
%          xy struct containing the two points
%   point - vector of x and y or x,y struct
%   isbound - logical true to check whether point is within end points of line
%   limitfactor - factor to scale eps limit (depends on magnitude of points)
%                 (optional - default = 100)
% OUTPUTS
%   ison - logical true if point lies on line
% NOTES
%  Line equation: y = m*x + b;  by Jan on Matlab Forum
%  https://uk.mathworks.com/matlabcentral/answers/351581-points-lying-within-line
%
% Author: Ian Townend
% CoastalSEA (c) Feb 2025
%--------------------------------------------------------------------------
%
    if nargin<4, limitfactor = 100; end

    if isstruct(line)
        P1 = [line.x(1),line.y(1)];
        P2 = [line.x(2),line.y(2)];
    else
        P1 = line(:,1)';
        P2 = line(:,2)';
    end
    %
    if isstruct(point)
        point = [point.x,point.y];
    else
        if iscolumn(point), point = point'; end
    end

    %input defines a point=[x3,y3] on line through P1=[x1,y1] and P2=[x2,y2]
    % Normal along the line:
    P12 = P2 - P1;
    L12 = sqrt(P12 * P12');
    N   = P12 / L12;
    
    % Line from P1 to point:
    PQ = point - P1;
    
    % Norm of distance vector: LPQ = N x PQ
    Dist = abs(N(1) * PQ(2) - N(2) * PQ(1));
    
    % Consider rounding errors:
    limit = limitfactor * eps(max(abs(cat(1, P1(:), P2(:), point(:)))));
    ison = (Dist < limit);
    % Consider end points 
    if ison && isbound
      % Projection of the vector from P1 to Q on the line:
      L = PQ * N.';  % DOT product
      ison = (L > 0.0 && L < L12);
    end

    % figure; 
    % plot([P1(1),P2(1)],[P1(2),P2(2)])
    % hold on 
    % plot(point(1),point(2),'xr')
    % hold off
end
%%-------------------------------------------------------------------------
    %the same solution in a more compact version (does not check whether
    %within end points)
    % limit = limitfactor * eps(max(abs(cat(1, P1(:), P2(:), point(:)))));
    % if P1(1) ~= P2(1)
    %     m = (P2(2)-P1(2))/(P2(1)-P1(1));
    %     yy3 = m*point(1)+P1(2)-m*P1(1);
    %     ison = (abs(point(2)-yy3) < limitfactor*limit);
    % else
    %     ison = abs(point(1)) < limit;
    % end

