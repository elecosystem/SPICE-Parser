# Data Structure 

The given data structure is a set of three classes that, altogether, store a basic electric circuit.
The purpose of the construction of this data structure in MATLAB(R) is solely for the purpose of implementing a version of de MNA algorithm on the stored circuit. 

This file contains a brief description of the classes and an example of the creation of a circuit in the end.

## Classes

The available Classes are the following:

- **Component** : Class that stores information about a component;

- **Branch**: Class that ideintifies the branch, beginning and ending nodes, and contains an instance of a Component, the component in the given branch;

- **Circuit**: Class that contains a list of branches (Branch) and has a list of the used nodes (merely as integers);


	


## Classes Description

### Component

This class's constructor expects the following arguments

- Name (string)
- Value (double)
- Type (String) 

There are nine types available for components, and these must be strictly used:
-- ' R ' : Resistor
-- ' L ' : Inductor
-- ' C ' : Capacitor
-- ' VS ' : Independent Voltage Source
-- ' VCVS ' : Voltage Cotrolled Voltage Source
-- ' CCVS ' : Current Controlled Voltage Source
-- ' IS ' : Current Source
-- ' VCIS ' : Voltage Controlled Current Source
-- ' CCIS ' : Current Controlled Current Source

**Note:** Eventhough this class has a constructor it is not to be used directly, once it is called by methods in class Branch, which is going to be described below.



Besides the constructor, this class presents other method:

###### addDep(BranchDep) :

This method serves simply to, in the case of a component with dependencies, link the Branch where the voltage/current is fetched.



### Branch

The constructor of this class has two input arguments:
- Begin(int)
- End(int)

After having created a branch, we only have information about the positioning of it, we now have two different methods to add what's important, its component, they are presented right below:

###### addComponent(Name,Value,Type) :
This method takes as input the **Name**, the **Value** and the **Type** of the component and calls the constructor of the Component class.

###### addDependentSource(Name,Value,Type,BranchDep) :
This method is very similar to the one mentioned above but it is specific to dependent power sources, thus it has an extra argument, **BranchDep**, to define the respective dependency.


## Sample Circuit

First of all create the branches:
```Matlab
		b01=Branch(0,1);
		b12=Branch(1,2);
		b23=Branch(2,3);
		b20=Branch(2,0);
		b30=Branch(3,0);
```
At this point we only have several branches that constitute a grid as follows:

**1** ____ **2** _____ **3**
 | &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |
  _____ **0**______
  
  Now we need to add the desired components to each branch:
  ```Matlab
		b01.addComponent('V1',5,'V');
		b12.addComponent('R1',1e3,'R');
		b23.addComponent('R2',1e3,'R');
		b20.addDependentSource('CCVS1',3,'CCVS',b12)
		b30.addComponent('I1',5e-2,'I');
```
Finally, we add them all to a new circuit:
```Matlab
		circuit=Circuit();
		circuit.addBranch([b01 b12 b23 b20 b30]);
```