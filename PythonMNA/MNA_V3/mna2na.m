%% Function that turns a MNA system of equations to a NA 

function [ CF2,I2,Q2,R2 ] = mna2na(circuit)

[ CF,x,I, N,M,P,Q,R] = mnaV3( circuit );

branches=circuit.Branch;

CF2=CF;
I2=I;
Q2=Q; %number of currents which will remain in CF2
R2=R; %number of voltages which will remain in CF2

%Dealing with branches containing voltage sources:
%if one branch contains a voltage source and neither of the nodes are
%groung, we build a super node;
%on the other hand, if one of the nodes of the branch in question is
%ground, we can exclude its equation and instantly replace it by the 
%definition of the nod's voltage


nVS=P;

if nVS>0
    
    B=sum(abs(CF(1:N,N+1:N+nVS)),1) %here we obtain a vector that tells us 
                                    %if the VS is connected to two nodes 
                                    %(B(n)==2) or connected to a node and 
                                    %to reference (B(n)==1)
    
    for i=linspace(nVS,1,nVS)
        if B(i)==1  %i-th VS is connected to the reference node, thus we 
                    %can remove this node's equation and replace it with 
                    %the definition of the node's voltage
                  
            idxVS=0;        
            for b=branches
                if strcmp(b.C.Type,'V')==1 || strcmp(b.C.Type,'VCVS')==1 || strcmp(b.C.Type,'CCVS')==1
                    idxVS=idxVS+1;
                
                    if idxVS==i
                        n=b.Begin+b.End; %one of them is zero, thus we are only obtaining the node that isnt zero
                        CF2(n,:)=zeros(size(CF2(n,:)));%reseting this line, because it is useless for NA
                        CF2(n,n)=1;

                        if strcmp(b.C.Type,'V')==1 %if the VS in question is independent all we have to do is set its value in the independent vector
                            I2(n)=b.C.Value;
                        elseif strcmp(b.C.Type,'VCVS')==1 %if the VS is VC, we have to define amongst which nodes is the dependence and multiply it by the coefficient
                            Begin=b.C.BranchDep.Begin;
                            End=b.C.BranchDep.End;
                            if Begin~=0
                                CF2(n,Begin)=-b.C.Value;
                            end
                            if End~=0
                                CF2(n,End)=b.C.Value;
                            end
                        elseif strcmp(b.C.Type,'CCVS')==1 %if the VS is CC, this is the hardest scenario, we have to find a branch that is percurred by the same current and its component is a resistor so that we can define the current (also we must check there aren't any current sources that directly define this current)
                            if strcmp(b.C.BranchDep.C.Type,'R') %if dependency is defined with a resistor
                                Begin=b.C.BranchDep.Begin;
                                End=b.C.BranchDep.End;
                                if Begin~=0
                                    CF2(n,Begin)=-b.C.Value/b.C.BranchDep.C.Value;
                                end
                                if End~=0
                                    CF2(n,End)=b.C.Value/b.C.BranchDep.C.Value;
                                end
                            else %else dependency is defined with a independent current source
                                I2(n)=b.C.BranchDep.C.Value;
                            end
                        end
                    end
                end
            end
        elseif B(i)>1   %if the VS is connected to two nodes that aren't ground, we need to make a super-node
                        %meaning we'll have an equation that represents the
                        %sum of currents coming in and out of the super-node
                        %and another one that represents the relation
                        %between both nodes
            idxVS=0;        
            for b=branches
                if strcmp(b.C.Type,'V')==1 || strcmp(b.C.Type,'VCVS')==1 || strcmp(b.C.Type,'CCVS')==1
                    idxVS=idxVS+1;
                    
                    if idxVS==i %this is True when we find the branch that contains the VS we're looking for
                        n=min(b.Begin,b.End);
                        n2=max(b.Begin,b.End);
                        CF2(n,:)=CF2(n,:)+CF2(n2,:); %adding the equations from both nodes of the VS branch, to make a supernode
                        I2(n)=I2(n)+I2(n2); 
                        CF2(n2,:)=zeros(size(CF2(n,:)));%resetting the second equation's info, because we've already inserted it on the above one, this equation will thus define the relation between both nodes, voltage wise
                        CF2(n2,b.Begin)=1;
                        CF2(n2,b.End)=-1;
                        if strcmp(b.C.Type,'V')==1
                            I2(n2)=b.C.Value;
                        elseif strcmp(b.C.Type,'VCVS')==1
                            CF2(n,b.C.BranchDep.Begin)=-b.C.Value;
                            CF2(n,b.C.BranchDep.End)=b.C.Value;
                        elseif strcmp(b.C.Type,'CCVS')==1
                            if strcmp(b.C.BranchDep.C.Type,'R') %if dependency is defined with a resistor
                                Begin=b.C.BranchDep.Begin;
                                End=b.C.BranchDep.End;
                                if Begin~=0
                                    CF2(n,Begin)=-b.C.Value/b.C.BranchDep.C.Value;
                                end
                                if End~=0
                                    CF2(n,End)=b.C.Value/b.C.BranchDep.C.Value;
                                end
                            else %else dependency is defined with a independent current source
                                I2(n)=b.C.BranchDep.C.Value;
                            end
                        end
                            
                    end
                
                end
                           
            end
        end
    end
    %in the NA matrix dependent voltage sources are directly defined on the
    %node's corresponding equation, thus we can delete from the CF2 matrix
    %the definition of the  voltage based on its current/voltage
    %dependency.
    %However, for ease of reading, dependencies concerning current sources
    %are still defined using auxiliary equations, thus we mustn't delete
    %the lines that correspond to current sources' dependencies
    mask=ones(size(I));
    mask(N+1:N+P)=0;
    if Q>0 
        idx=N+P+1;
        for b=branches
           if strcmp(b.C.Type,'CCVS')
               mask(idx)=0;
               idx=idx+1;
               Q2=Q2-1;
           elseif strcmp(b.C.Type,'CCCS')
               idx=idx+1;
           end 
        end 
    end
    
    if R>0
        idx=N+P+Q+1;
        for b=branches
            if strcmp(b.C.Type,'VCVS')
               mask(idx)=0;
               idx=idx+1;
               R2=R2-1;
           elseif strcmp(b.C.Type,'VCCS')
               idx=idx+1;
           end 
        end 
    end
    CF2=CF2(mask==1,mask==1)
    I2=I2(mask==1)
end

