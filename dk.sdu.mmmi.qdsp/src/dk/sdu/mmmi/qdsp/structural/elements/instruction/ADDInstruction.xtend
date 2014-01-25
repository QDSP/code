package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.HeapElement

class ADDInstruction extends dk.sdu.mmmi.qdsp.structural.elements.HeapReadInstruction{
	
	protected static Integer myid = null;
	def public static void setId(int id){
		myid = id
	}
	//new () {}
	new (HeapElement heapelement) { super(heapelement)}

	def static getStaticDefaultID() {
		return 0x09
	}
	
	def static getStaticInstructionName() {
		return "ADD"
	}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	override getComment() {
		return "Adding " + heapelement.name + " (Heap" + heapelement.heapAddress + ") to accumulator";
	}
	
	override getId() {
		return getStaticID 
	}

	def static getStaticID() {
		return myid ?: getStaticDefaultID 
	}
	
}