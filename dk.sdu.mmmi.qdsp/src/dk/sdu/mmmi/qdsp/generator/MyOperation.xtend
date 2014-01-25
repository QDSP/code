package dk.sdu.mmmi.qdsp.generator

import dk.sdu.mmmi.qdsp.qDSP.impl.OperationImpl
import dk.sdu.mmmi.qdsp.structural.elements.HeapSysVariable

class MyOperation extends OperationImpl{
	
	@Property HeapSysVariable systemVariable
	
	new(){
	}
}