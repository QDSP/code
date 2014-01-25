package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.HeapElement

class CHAInstruction extends dk.sdu.mmmi.qdsp.structural.elements.HeapReadInstruction{
	protected static Integer myid = null;
	def public static void setId(int id){
		myid = id
	}
	override getId() {
		return getStaticID 
	}

	def static getStaticID() {
		return myid ?: getStaticDefaultID 
	}

	def static getStaticDefaultID() {
		return 0x02
	}

	
	//new () {}
	new (HeapElement heapelement) { super(heapelement)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	def static getStaticInstructionName() {
		return "CHA"
	}
	
	override getComment() {
		return "Copy " + heapelement.name + " (Heap" + heapelement.heapAddress + ") to accumulator";
	}
	
}