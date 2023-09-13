function E=E(r1,r2,Cx,Cy,theta)

E_hat=diag([1/r1^2 1/r2^2 -1]);

Dt=[1 0 -Cx ; 0 1 -Cy ; 0 0 1];

Dr=[cos(theta)  -sin(theta) 0 ...
 ;  sin(theta)   cos(theta) 0 ...
 ;  0            0          1];

 E=Dt'*Dr'*E_hat*Dr*Dt;
end