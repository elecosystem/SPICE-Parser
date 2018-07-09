classdef Component < handle
%
%   *COMPONENT class definition*
%
%   This class implements a circuit branch
% 
%   PROPERTIES:
%       * Name:  The component name
%       * Value: The component value
%       * Type:  The component type
%
%   METHODS:
%       * Component(Name,Value,Type): given the component name, numeric
%       value and type (see below for the currently avalilable types)
%       object returns a component object  
%       * Complex(obj,omega): given a componenent object and its operating
%       angular frequency, returns the impedance
%
%
%
%   Avaliable Component Types:
%       * C: Capacitor
%       * L: Inductance
%       * R: Resistor
%       * VCVS : Voltage Controled Voltage Source
%      *  VCCS : Voltage Controlled Current Source
%      *  CCCS : Current Controlled Current Source
%      *  CCVS : Current Controlled Voltage Source
   
 
    
    properties(SetAccess = private, GetAccess = public)
        Name
        Value
        Type
        BranchDep
    end
    
    methods 
         function obj = Component(Name,Value,Type)
             obj.Name = Name;
             obj.Value = Value;
             obj.Type = Type;
         end
         
         function obj = addDep(obj,BranchDep)
              obj.BranchDep = BranchDep; 
         end
                       
    end
end
       
