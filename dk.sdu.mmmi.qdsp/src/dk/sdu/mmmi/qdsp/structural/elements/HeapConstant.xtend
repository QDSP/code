package dk.sdu.mmmi.qdsp.structural.elements

import dk.sdu.mmmi.qdsp.structural.Heap

class HeapConstant extends HeapElement{
	
	new(Heap heap, int value) {
		super(heap, value)
	}
	
	new(Heap heap, String name, int value) {
		super(heap, name, value)
	}
	
	override getName(){
		return super.name ?: "Constant" + " = " + value;
	}

	
}