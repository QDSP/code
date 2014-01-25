package dk.sdu.mmmi.qdsp.structural.elements.instruction

class CAIInstruction extends dk.sdu.mmmi.qdsp.structural.elements.MemoryWriteInstruction{
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
		return 0x07
	}

	
	new () {}
	new (int argument) { super(argument)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "CAI"
	}
	
	override getComment()'''
	Copy accumulator to IO memory address «argument»'''
}