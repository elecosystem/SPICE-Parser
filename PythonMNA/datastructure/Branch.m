classdef Branch < handle
%
%   *BRANCH class definition*
%
%   This class implements a circuit branch
% 
%   PROPERTIES:
%       * Begin:     The branch starting node
%       * End:       The branch ending node
%       * C: The branch component object
%
%   METHODS:
%       * Branch(Begin,Ends,Component): given the starting and ending node
%       and the component object node object, returns a branch object
%
    
    properties
        Begin
        End
        C
    end
        

     
    methods 
        function obj = Branch(Begin,Ends)
         obj.Begin = Begin;
         obj.End = Ends;
        end
        
        
        function obj = addComponent(obj,Name,Value,Type)
    
            c = Component(Name,Value,Type);
            obj.C = c;
            
        end
        
        function obj = addDependentSource(obj,Name,Value,Type,BranchDep)
            c = Component(Name,Value,Type);
            c.addDep(BranchDep)
            obj.C = c;
        end
        
    end  
end
       
