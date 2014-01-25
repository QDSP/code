package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.HeapElement

class SUBInstruction extends dk.sdu.mmmi.qdsp.structural.elements.HeapReadInstruction{
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
		return 0x0A
	}

	
	//new () {}
	new (HeapElement heapelement) { super(heapelement)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "SUB"
	}
	
	override getComment() {
		return "Subtracting " + heapelement.name + " (Heap" + heapelement.heapAddress + ") from accumulator";
	}
	
}