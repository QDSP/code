package dk.sdu.mmmi.qdsp.structural.elements.instruction

class RSTInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction {
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
		return 0x03
	}

	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "RST"
	}
	
	override getComment() {
		return "Resets program counter to 0"
	}
	
}