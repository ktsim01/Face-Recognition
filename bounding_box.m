function [xb, yb]=bounding_box(Ellipse)
    % Input: 
    % matrix of the following
    % 1 radius of ellipses at direction 1
    % 2 radius of ellipses at direction 2
    % 3 x-cooridante of centroid
    % 4 y-coordinate of centroid
    % 5 Inclination angle
    
    % Output
    % The boundary box defined by the following
    % xb: [xmin xmax] 
    % yb: [xmin xmax] 
    
    E1=E(Ellipse(1),Ellipse(2),Ellipse(3),Ellipse(4),Ellipse(5));
    
    Q=eye(3)/E1;
    S=sign(Q(3,3));
    x_min=(Q(1,3)-S*sqrt(Q(1,3)^2-Q(1,1)*Q(3,3)))/Q(3,3);
    x_max=(Q(1,3)+S*sqrt(Q(1,3)^2-Q(1,1)*Q(3,3)))/Q(3,3);
    
    y_min=(Q(2,3)-S*sqrt(Q(2,3)^2-Q(2,2)*Q(3,3)))/Q(3,3);
    y_max=(Q(2,3)+S*sqrt(Q(2,3)^2-Q(2,2)*Q(3,3)))/Q(3,3);
    
    xb=[x_min x_max];
    yb=[y_min y_max];
end