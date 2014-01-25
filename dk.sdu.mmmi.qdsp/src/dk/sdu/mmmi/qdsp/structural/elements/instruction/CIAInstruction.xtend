package dk.sdu.mmmi.qdsp.structural.elements.instruction

class CIAInstruction extends dk.sdu.mmmi.qdsp.structural.elements.MemoryReadInstruction{
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
		return 0x08
	}

	
	new (int argument) { super(argument)}
	new (int memoryAddress, int addressSetIn) { super(memoryAddress, addressSetIn)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "CIA"
	}
	override getComment()'''
	«IF addressSetIn.size > 0»Copy IO memory address «memoryAddress» to accumulator, address set in line «addressSetIn»«IF argument != null». «ENDIF»«ENDIF»«IF argument != null»Setting address to «argument»«ENDIF»'''
}