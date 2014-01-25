package dk.sdu.mmmi.qdsp.structural.elements.instruction

class BMULInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction{
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
		return 0x0C
	}
	
	def public void setArgument(int argument){
		super._argument = argument;
	}
	new () {}
	new (int argument) { super(argument)}
	
	
	def static getStaticInstructionName() {
		return "BMUL"
	}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	override getComment() {
		return "Multiplies by " + Math.pow(2, _argument) + ", by left shifting accumulator " + _argument + " times, keeps signed bit";
	}
	
}