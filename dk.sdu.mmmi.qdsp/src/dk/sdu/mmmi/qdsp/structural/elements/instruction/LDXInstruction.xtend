package dk.sdu.mmmi.qdsp.structural.elements.instruction

class LDXInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction{
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
		return 0x04
	}

	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "LDX"
	}
	
	override getComment() {
		return "Copy accumulator to loaders internal control register"
	}
	
}