package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.HeapElement

class CAHInstruction extends dk.sdu.mmmi.qdsp.structural.elements.HeapInstruction{
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
		return 0x01
	}

	
	//new () {}
	new (HeapElement heapelement) { super(heapelement)}


	override getInstructionName() {
		return staticInstructionName
	}
	

	def static getStaticInstructionName() {
		return "CAH"
	}
	
	override getComment() {
		return "Copy accumulator to " + heapelement.name + " (Heap" + heapelement.heapAddress + ")";
	}
	
}