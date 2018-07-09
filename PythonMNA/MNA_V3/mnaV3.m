%% Third Version of Modified Nodal Analysis Algorithm Implementation
%%
%Major changes: now current dependencies are no longer made from currents in
%voltage sources

%------------------------------------
%IMPORTANT ASSUMPTIONS ON THIS VERSION:
%-each branch only has one component
%-the nodes are consecutive starting on 0
%-current dependencies are made on branches containing a resistor or a
%independent current source
%------------------------------------ 

% Args in:
%   circuit - it's an object of the Circuit class, which has all necessary 
% information about the circuit on which we will operate 
%
% Returns:
%   x - vector containing the voltages in each given node followed by the 
% currents in each of the voltage sources in their order of appearance in
% the branches vector, current dependencies and voltage dependencies

 
function [ CF,x,I, N,M,P,Q,R] = mnaV3( circuit )

%% Definition of the system's dimensions
% In this part we define the system dimensions, based on the number of
% nodes, voltage sources, currents and voltages that control dependent
% sources.

%Obtaining the list of  branches of the circuit:
branches=circuit.Branch;

%Obtaining the number of nodes (except GND), N:
N=circuit.NodeCount-1;


%Obtaining the number of currents in voltage sources (independent or 
%dependent ones), P: 
P=0;
for b=branches
    if strcmp(b.C.Type,'V') || strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'CCVS') 
        P=P+1;
    end
end

%Obtaining the number of currents that control dependent sources, Q:
Q=0;
for b=branches
    if strcmp(b.C.Type,'CCVS') || strcmp(b.C.Type,'CCCS') 
        Q=Q+1;
    end
end

%Obtaining the number of voltages that control dependent sources, R:
R=0;
for b=branches
    if strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'VCCS') 
        R=R+1;
    end
end

%Finally, obtaining the number of variables of the system disconsidering 
%the nodal voltages, M:
M=P+Q+R; 


%% Construction of the GR matrix
% GR(N,N) is the conductance matrix: 
GR=zeros(N,N);

%Filling GR positions in the diagonal: 
for i=1:N
    for b=branches
        if (b.Begin==i || b.End==i) && strcmp(b.C.Type,'R')
            GR(i,i)=GR(i,i)+1/b.C.Value;
        end
    end
end

%Filling GR positions amongst nodes:
for b=branches
    Begin=b.Begin;
    End=b.End;
    if Begin~=0 && End~=0 && strcmp(b.C.Type,'R') 
        GR(Begin,End)=GR(Begin,End)-1/b.C.Value;
        GR(End,Begin)=GR(End,Begin)-1/b.C.Value;
    end
end

%% Construction of the B matrix
% B is a matrix that defines the currents through voltage sources and in
% (voltage or current) dependent current sources 

B=zeros(N,M);


%First we fill matrix B with the currents on the independent voltage
%sources
idx=1;  %this index represents the column of matrix B in which we are working, 
        %that corresponds to the line idx+N of the variables column
for b= branches
    if strcmp(b.C.Type,'V') || strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'CCVS')
        Begin=b.Begin;
        End=b.End;
        if Begin~=0
            B(Begin,idx)=1;
        end
        if End~=0
            B(End,idx)=-1;
        end
        idx=idx+1;
    end
end

%Now we add to the matrix B more parameters related to current dependent 
%current sources
for b= branches
    if strcmp(b.C.Type,'CCCS') 
        Begin=b.Begin;
        End=b.End;
        if Begin~=0
            B(Begin,idx)=b.C.Value;
        end
        if End~=0
            B(End,idx)=-b.C.Value;
        end
        idx=idx+1;
    end
    
    if strcmp(b.C.Type,'CCVS')
        idx=idx+1;
    end
end

%Now we add to the matrix B more parameters related to voltage dependent
%current sources
for b=branches
    if strcmp(b.C.Type,'VCCS') 
        Begin=b.Begin;
        End=b.End;
        if Begin~=0
            B(Begin,idx)=b.C.Value;
        end
        if End~=0
            B(End,idx)=-b.C.Value;
        end
        idx=idx+1;
    end
    
    if strcmp(b.C.Type,'VCVS')
        idx=idx+1;
    end
end


%% Construction of the C matrix
% C is a matrix that defines amongst which nodes are the currents and
% voltages related to dependent sources

C=zeros(M,N);

%first we fill matrix C with the currents on the voltage sources, this will
%serve to define the voltage on the branches with VSs

idx=1;  %this index represents the line of matrix C in which we are working, 
        %that corresponds to the line idx+N of the variables column

        
for b= branches
    if strcmp(b.C.Type,'V') || strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'CCVS')
        Begin=b.Begin;
        End=b.End;
        if Begin~=0
            C(idx,Begin)=1;
        end
        if End~=0
            C(idx,End)=-1;
        end
        idx=idx+1;
    end
end

%Now we indicate amongst which nodes are the currents in the dependencies
%we skip the idxs corresponding to the current dependencies that are not
%dependencies based on currents in resistors.
for b= branches
    if strcmp(b.C.Type,'CCVS') || strcmp(b.C.Type,'CCCS') 
        if strcmp(b.C.BranchDep.C.Type,'R')
            Begin=b.C.BranchDep.Begin;
            End=b.C.BranchDep.End;
            if Begin~=0
                C(idx,Begin)=1;
            end
            if End~=0
                C(idx,End)=-1;
            end
        end
        idx=idx+1;
    end
end

%Finally we complete the B matrix with the information that says in which
%nodes is the voltage sampled for the voltage dependencies
for b= branches
    if strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'VCCS') 
        Begin=b.C.BranchDep.Begin;
        End=b.C.BranchDep.End;
        if Begin~=0
            C(idx,Begin)=1;
        end
        if End~=0
            C(idx,End)=-1;
        end
        idx=idx+1;
    end
end



%% Construction of the D matrix
% D is a matrix relative to voltage sources and to the dependencies of 
% the various sources:
D=zeros(M,M);

idx=1;  %this index represents the line of matrix D in which we are working, 
        %that corresponds to the line idx+N of the variables column

%Firstly we set a line of zeros (skip the idx) for the lines that correspond 
%currents on independent voltage sources:

for b= branches
    if strcmp(b.C.Type,'V')
        idx=idx+1;
    elseif strcmp(b.C.Type,'VCVS')
        idx2=P+Q+1;
        
        for bb=branches
            if strcmp(bb.C.Type,'VCVS') || strcmp(bb.C.Type,'VCCS') 
                if strcmp(bb.C.Name,b.C.Name)
                    break
                end
                idx2=idx2+1;
            end
        end
        
        D(idx,idx2)=-b.C.Value;
        idx=idx+1;
    elseif strcmp(b.C.Type,'CCVS')
        idx2=P+1;
        
        for bb=branches
            if strcmp(bb.C.Type,'CCVS') || strcmp(bb.C.Type,'CCCS') 
                if strcmp(bb.C.Name,b.C.Name)
                    break
                end
                idx2=idx2+1;
            end
        end
        
        
        D(idx,idx2)=-b.C.Value;
        idx=idx+1;
    end
end

%Fill on matrix D the current dependencies, if it is due to a R, we add in
%the line of the order of that current the value -R, if it is dua to a
%independent current source, we add the value 1:
for b= branches
    if strcmp(b.C.Type,'CCVS') || strcmp(b.C.Type,'CCCS') 
        if strcmp(b.C.BranchDep.C.Type,'R')
            D(idx,idx)=-b.C.BranchDep.C.Value;
        else
            D(idx,idx)=1;
        end
        idx=idx+1;    
    end
end


for b= branches
    if strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'VCCS')
        D(idx,idx)=-1;
        idx=idx+1;
    end
end

%% Assembly of all matrices into the coefficients matrix - CF
% CF is the final coefficient matrix, formed by GR,B,C,D in the following
% way:
CF=[GR B;C D]

%% Construction of the I matrix
% I is the matrix of the independent terms
I=zeros(M+N,1);

idx=N+1;
for b=branches
    if strcmp(b.C.Type,'V')
        I(idx)=b.C.Value;
        idx=idx+1;
    end
    if strcmp(b.C.Type,'VCVS') || strcmp(b.C.Type,'CCVS')
        idx=idx+1;
    end
    if strcmp(b.C.Type,'I')
       if b.Begin>0
           I(b.Begin)=-b.C.Value;
       end
       if b.End>0
           I(b.End)=b.C.Value;
       end
    end
end

idx=N+P+1;
for b=branches
    if strcmp(b.C.Type,'CCVS') || strcmp(b.C.Type,'CCCS') 
        if strcmp(b.C.BranchDep.C.Type,'I')
            I(idx)=b.C.BranchDep.C.Value;
        end
        idx=idx+1; 
    end
end

%% Obtaining the result

%CF*x=I <=> x=CF^-1 * I
x=CF\I;
       