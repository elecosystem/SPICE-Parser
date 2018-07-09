classdef Circuit < handle
%
%   *BRANCH class definition*
%
%   This class implements a group of circuit branch
% 
%   PROPERTIES:
%       * Branch: The branch starting node

%
%   METHODS:
%       * Branches(F): given a branch object returns a branches object
%
   
% Digo o mesmo que disse para a netlist

    properties
      Branch
      BranchCount
      NodesIdx
      NodeCount
    end

    methods 
        function obj = Circuit()
            obj.NodeCount=0;
            obj.BranchCount=0;
            obj.Branch=Branch(0,0);
        end
        
        function obj = addBranch(obj,B)
            for b=B
                obj.BranchCount=obj.BranchCount+1;
                obj.Branch(obj.BranchCount)=b;
                if sum(obj.NodesIdx==b.Begin)==0
                    obj.NodeCount=obj.NodeCount+1;
                    obj.NodesIdx(obj.NodeCount)=b.Begin;
                end
                if sum(obj.NodesIdx==b.End)==0
                    obj.NodeCount=obj.NodeCount+1;
                    obj.NodesIdx(obj.NodeCount)=b.End;
                end
            end
        end
   end
end
               
