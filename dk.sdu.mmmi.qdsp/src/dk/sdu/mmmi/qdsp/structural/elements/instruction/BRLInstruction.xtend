package dk.sdu.mmmi.qdsp.structural.elements.instruction

import dk.sdu.mmmi.qdsp.structural.elements.JumpDestination
import dk.sdu.mmmi.qdsp.structural.elements.JumpMode

class BRLInstruction extends dk.sdu.mmmi.qdsp.structural.elements.JumpInstruction{
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
		return 0x16
	}

	
	new (JumpDestination destination, JumpMode mode) { super( destination, mode)}
	new (int argument, JumpDestination destination, JumpMode mode) { super(argument, destination, mode) }
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	def static getStaticInstructionName() {
		return "BRL"
	}
	override getComment()'''
	Absolute jump «jumpDestination» «jumpMode», if less than flag is set. Codeline «argument»'''
}