package dk.sdu.mmmi.qdsp.structural.elements.instruction

class TRNInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction{
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
		return 0x0E
	}

	
	override getInstructionName() {
		return staticInstructionName
	}
	
	def static getStaticInstructionName() {
		return "TRN"
	}
	
	override getComment() {
		return "Truncate accumulator to 16 bit";
	}
	
}