import sys
from antlr4 import *
from spiceLexer import spiceLexer
from spiceParser import spiceParser
from spiceExtractor import spiceExtractor
from datastructure import Circuit,Branch,Component
 
def main(argv):

	#Init lexer/parser

	input = FileStream(argv[1])
	lexer = spiceLexer(input)
	stream = CommonTokenStream(lexer)
	parser = spiceParser(stream)
	tree = parser.netlist()

	#FIXME GET SYNTAX ERRORS??

	#Init Walker+Listener and invocate walker

	walker=ParseTreeWalker()

	raw_circuit=Circuit()
	extractor=spiceExtractor(raw_circuit)
	walker.walk(extractor,tree)

	#Raw circuit structure populated

	#TODO: feed final structure to MNA

	#print(raw_circuit)

	Circuit.removeBadBranches(raw_circuit)
	Circuit.fixNodes(raw_circuit)
	raw_circuit.updNodeCnt()
	
	print(raw_circuit)
 
if __name__ == '__main__':
	main(sys.argv)
