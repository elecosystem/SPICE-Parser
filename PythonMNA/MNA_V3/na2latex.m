function latexEqs=na2latex(CF,I,Q,R)
%This function turns a system of NA equations to its latex representation

    V=sym('V',[1 size(I,1)-Q-R]);
    i=sym('ix',[1 Q]);
    v=sym('vx',[1 R]);
    
    x=[V i v].';
    
    latexEqs=latex(CF*x==I);
    
    latexEqs=['\begin{cases}' latexEqs(24:end-18) '\end{cases}'];
    
    
end

