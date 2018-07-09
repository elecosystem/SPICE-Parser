function latexEqs=na2latex_butbetter(CF,I,Q,R)
%This function turns a system of NA equations to its latex representation

    V=sym('V',[1 size(I,1)-Q-R]);
    i=sym('ix',[1 Q]);
    v=sym('vx',[1 R]);
    
    %criando apenas uma matriz quadrada em que os membros são as diferenças
    %simbólicas entre as tensões em nós consecutivos
    incognitas=repmat(V.',1,size(V,2))-repmat(V,size(V,2),1)+eye(size(V,2)).*repmat(V,size(V,2),1)
    %juntando as tensões tentre nós na parte abaixo, para as definições de
    %ix e vx
    incognitas=[incognitas; repmat(V,Q+R,1)];
    %juntoando as incognitas ix e vx
    incognitas=[incognitas repmat(i,size(I,1),1) repmat(v,size(I,1),1)]
    
    
    %fazendo as alterações necessárias em CF, devido à forma mais intuitiva
    %de representação de correntes nequações nodais
    CF(1:size(V,2),1:size(V,2))=CF(1:size(V,2),1:size(V,2)).*(-1+eye(size(V,2)))+repmat(sum(CF(1:size(V,2),1:size(V,2)),2),1,size(V,2)).*eye(size(V,2));
    
    cc=CF.*incognitas
    I
    latexEqs=latex(cc*eye(size(cc))==I);
    
    %latexEqs=['\begin{cases}' latexEqs(24:end-18) '\end{cases}'];
    
    
end

