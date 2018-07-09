function latexEqs=na2latex_butbetter(CF,I,Q,R)
%This function turns a system of NA equations to its latex representation

    V=sym('V',[1 size(I,1)-Q-R]);
    i=sym('ix',[1 Q]);
    v=sym('vx',[1 R]);
    
    %criando apenas uma matriz quadrada em que os membros s�o as diferen�as
    %simb�licas entre as tens�es em n�s consecutivos
    incognitas=repmat(V.',1,size(V,2))-repmat(V,size(V,2),1)+eye(size(V,2)).*repmat(V,size(V,2),1)
    %juntando as tens�es tentre n�s na parte abaixo, para as defini��es de
    %ix e vx
    incognitas=[incognitas; repmat(V,Q+R,1)];
    %juntoando as incognitas ix e vx
    incognitas=[incognitas repmat(i,size(I,1),1) repmat(v,size(I,1),1)]
    
    
    %fazendo as altera��es necess�rias em CF, devido � forma mais intuitiva
    %de representa��o de correntes nequa��es nodais
    CF(1:size(V,2),1:size(V,2))=CF(1:size(V,2),1:size(V,2)).*(-1+eye(size(V,2)))+repmat(sum(CF(1:size(V,2),1:size(V,2)),2),1,size(V,2)).*eye(size(V,2));
    
    cc=CF.*incognitas
    I
    latexEqs=latex(cc*eye(size(cc))==I);
    
    %latexEqs=['\begin{cases}' latexEqs(24:end-18) '\end{cases}'];
    
    
end

