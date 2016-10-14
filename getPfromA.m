function p = getPfromA(A)
e0 = sqrt((trace(A)+1)/4);

e1 = (A(3,2) - A(2,3))/(4*e0);
e2 = (A(1,3) - A(3,1))/(4*e0);
e3 = (A(2,1) - A(1,2))/(4*e0);

p = [e0;e1;e2;e3];