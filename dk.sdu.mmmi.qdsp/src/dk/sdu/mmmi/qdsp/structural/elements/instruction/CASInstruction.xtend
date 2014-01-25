package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.MemoryWriteInstruction

class CASInstruction extends MemoryWriteInstruction {
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
		return 0x05
	}

	
	new () {}
	new (int argument) { super(argument)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "CAS"
	}
	override getComment()'''
	Copy accumulator to SH memory address «argument»'''
}