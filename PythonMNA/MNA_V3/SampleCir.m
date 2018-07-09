clear all;

addpath('../datastructure');

%display('Generating Circuit')
b1 = Branch(0,1);
b2 = Branch(0,1);
b3 = Branch(1,2);
b4 = Branch(2,0);
b5 = Branch(1,3);
b6 = Branch(0,3);
b7 = Branch(1,4);
b8 = Branch(4,0);

b1.addComponent('I1',10,'I');
b2.addComponent('R1',50,'R');
b3.addComponent('R2',100,'R');
b4.addDependentSource('V3',2,'VCVS',b2);
b5.addComponent('R3',150,'R');
b6.addDependentSource('I2',-3,'CCCS',b2);
b7.addComponent('R4',200,'R');
b8.addComponent('V5',5,'V');

branches=[b1 b2 b3 b4 b5 b6 b7 b8];
c=Circuit();
c.addBranch(branches);
clear b1 b2 b3  b4 b5 b6 b7 b8 branches 

x=mnaV3 (c)

%[ CF2,I2,Q2,R2 ]=mna2na(c)
%
%latexEqs=na2latex(CF2,I2,Q2,R2)
%
%latexEqs2=na2latex_butbetter(CF2,I2,Q2,R2)
