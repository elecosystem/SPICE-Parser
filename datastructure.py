#Circuit class assumes that there is always a alternative branch when removing dummy branches

class Circuit:
	def __init__(self):
		self.nodeCnt=0 
		self.branches=list()

	def __repr__(self):
		st="Circuit with "+str(self.nodeCnt)+" nodes.\n"
		for b in self.branches:
			st+="	"+str(b).replace("\n","\n	")+"\n\n"
		return st

	def updNodeCnt(self):
		_mp=set()
		for _br in self.branches:
			_gn=_br.getNodes()
			_mp.add(_gn[0])
			_mp.add(_gn[1])
		self.nodeCnt=len(_mp)
		return self.nodeCnt

	def addBranch(self,br):
		#assert already in?
		self.branches.append(br)

	#get branches with component name cname
	def getBranchCompName(self,cname):
		l=list(filter(lambda x: x.getComponent().getName()==cname,self.branches))

		assert len(l)<2,"One component is in two branches!"

		return l[0] if len(l)==1 else None
	
	#get branches with nodes (start end) nds
	def getBranchesNodes(self,nds):
		return list(filter(lambda x: (x.node1==nds[0] and x.node2==nds[1]) or (x.node1==nds[1] and x.node2==nds[0]),self.branches)) #TODO correct private

	#get branches that connect to node nd
	def getBranchesNode(self,nd):
		return list(filter(lambda x: x.node1==nd or x.node2==nd,self.branches)) #TODO correct private

	def renameNode(self,nnew,nold):
		for _br in self.branches:
			_nds=list(_br.getNodes())
			if _nds[0]==nold:
				_nds[0]=nnew
			elif _nds[1]==nold:
				_nds[1]=nnew
			_br.setNodes(tuple(_nds))


#TODO Funcao de procura de fontes corrente,resistencias,fontes de tensao para ter disponivel para corrigir as dependencias 

	def renameNodesDep(self,nsnew,nsold):
		for _br in self.branches:
			if _br.getComponent().dependent!=None and _br.getComponent().dependent.getNodes()==nsold:
				_br.getComponent().dependent.setNodes(nsnew)

	def smartAltBranch(self,nds,winning_node):
		#TODO!!

		if len(self.getBranchesNode(nds[0]))==2:
			_tmp=self.getBranchesNode(nds[0])	
			if _tmp[0].getNodes()[1]==nds[0]:
				_id=_tmp[0].getNodes()[0]
			elif _tmp[1].getNodes()[1]==nds[0]:
				_id=_tmp[1].getNodes()[0]
			#FIXME!
			elif _tmp[0].getNodes()[0]==nds[0]:
				_id=_tmp[0].getNodes()[1]
			elif _tmp[1].getNodes()[0]==nds[0]:
				_id=_tmp[0].getNodes()[1]
			else:
				assert False, "Cant find correct branch!"
				
			return (_id,winning_node)	
		elif len(self.getBranchesNode(nds[1]))==2:
			_tmp=self.getBranchesNode(nds[1])	
			if _tmp[0].getNodes()[0]==nds[1]:
				_id=_tmp[0].getNodes()[1]
			elif _tmp[1].getNodes()[0]==nds[1]:
				_id=_tmp[1].getNodes()[1]
			elif _tmp[0].getNodes()[0]==nds[1]:
				_id=_tmp[0].getNodes()[1]
			elif _tmp[1].getNodes()[0]==nds[1]:
				_id=_tmp[0].getNodes()[1]
			else:
				assert False, "Cant find correct branch!"

			return (winning_node,_id)		
		else:
			assert False,"No alternative branch to hang a dependence!"
		

	#Removes all 0V Voltage sources, 0Ohm Resistors and 0H Inductors used for current measurement
	def removeBadBranches(circ):
		done=False
		while not done: #for every change, force the algorithm to traverse the circuit again
			done=True
			for _br in circ.branches:
				_comp=_br.getComponent()
				if _comp.value==0 and (_comp.ctype=='V' or _comp.ctype=='R' or _comp.ctype=='L'):
					if len(circ.getBranchesNodes(_br.getNodes()))>1: #another components in paralel
						circ.branches.remove(_br) #simply remove dummy branch
					else: 
						_nds=_br.getNodes()

						if _nds[1]==0: #rename nodes/branches
							circ.renameNodesDep(circ.smartAltBranch(_nds,_nds[1]),_nds)
							circ.renameNode(_nds[1],_nds[0])
						else:
							circ.renameNodesDep(circ.smartAltBranch(_nds,_nds[0]),_nds)
							circ.renameNode(_nds[0],_nds[1])	

						circ.branches.remove(_br) #remove branch/component

					done=False
					break
				
					
		
	#Makes nodes number sequencial
	def fixNodes(circ):
		_mp=set()
		#get all node numbers
		for _br in circ.branches:
			_gn=_br.getNodes()
			_mp.add(_gn[0])
			_mp.add(_gn[1])

		#remove node 0
		_mp.remove(0)

		#get list
		_nlst=list(_mp)
		
		#fix node numbers
		#FIXME might be bugged
		for _br in circ.branches+[a.getComponent().dependent for a in circ.branches if a.getComponent().dependent!=None]:
			_gn=_br.getNodes()	

			_nnn=[0,0]

			try:
				_nnn[0]=_nlst.index(_gn[0])+1
			except ValueError:
				pass
			
			try:
				_nnn[1]=_nlst.index(_gn[1])+1
			except ValueError:
				pass

			_br.setNodes(tuple(_nnn))

		return circ #redundant return
		

class Branch:
	def __init__(self,n1,n2,comp):
		self.node1=n1 #int
		self.node2=n2 #int
		self.comp=comp #Component()	

	def __repr__(self):
		st="Branch: Node1: "+str(self.node1)+" Node2: "+str(self.node2)+"\n"+str(self.comp).replace("\n","\n	")
		return st

	def getNodes(self):
		return (self.node1,self.node2)

	def getComponent(self):
		return self.comp

	def setNodes(self,ns):
		self.node1=ns[0]
		self.node2=ns[1]

class Component:
	def __init__(self,nm,ct,vl,sc,dep=None):
		self.name=nm  #str()
		self.ctype=ct #str()
		self.value=vl #float() # ?
		self.scale=sc #str()   # ?
		self.dependent=dep #Branch()

	def __repr__(self):
		_dep=str(self.dependent).replace("\n","\n   ")
		return "Component:\nName: "+self.name+"\nType: "+self.ctype+"\nValue: "+str(self.value)+"\nScale: "+self.scale + "\nDependency: "+("\n" if _dep!="None" else "")+ _dep

	def getName(self):
		return self.name
