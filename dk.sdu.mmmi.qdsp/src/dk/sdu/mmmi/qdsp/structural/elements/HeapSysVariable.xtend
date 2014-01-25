package dk.sdu.mmmi.qdsp.structural.elements

import dk.sdu.mmmi.qdsp.structural.Heap

class HeapSysVariable extends HeapElement{
	private boolean inuse = true;
	new(Heap heap) {
		super(heap, "sys" + heap.sysVariableCount, 0);
	}
	def void release(){
		inuse = false;
	}
	def void take(){
		inuse = true;
	}
	def boolean isInUse(){
		return inuse;
	}
}