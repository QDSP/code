package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.JumpDestination
import dk.sdu.mmmi.qdsp.structural.elements.JumpMode

class JMPInstruction extends dk.sdu.mmmi.qdsp.structural.elements.JumpInstruction{
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
		return 0x13
	}

	
	new (JumpDestination destination, JumpMode mode) { super( destination, mode)}
	new (int argument, JumpDestination destination, JumpMode mode) { super(argument, destination, mode) }
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "JMP"
	}
	override getComment()'''
	Absolute jump «jumpDestination» «jumpMode». Codeline «argument»'''
}