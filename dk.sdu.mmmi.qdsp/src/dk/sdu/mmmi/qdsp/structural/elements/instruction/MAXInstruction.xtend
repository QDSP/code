package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.HeapElement

class MAXInstruction extends dk.sdu.mmmi.qdsp.structural.elements.HeapReadInstruction{
	protected static Integer myid = null;
	def public static void setId(int id){
		myid = id
	}
	new(HeapElement heapelement) {
		super(heapelement)
	}
	
	override getId() {
		return getStaticID 
	}

	def static getStaticID() {
		return myid ?: getStaticDefaultID 
	}

	def static getStaticDefaultID() {
		return 0x0F
	}

	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "MAX"
	}
	
	override getComment()'''
	Leaves the maximum value of accumulator or «heapelement.name» (Heap«heapelement.heapAddress») on the accumulator'''
	
}