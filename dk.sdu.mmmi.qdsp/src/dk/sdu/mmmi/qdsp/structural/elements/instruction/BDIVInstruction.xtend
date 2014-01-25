package dk.sdu.mmmi.qdsp.structural.elements.instruction

class BDIVInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction{
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
		return 0x0B;
	}
	def public void setArgument(int argument){
		super._argument = argument;
	}
	new () {}
	new (int argument) { super(argument)}
	
	
	def static getStaticInstructionName() {
		return "BDIV"
	}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	override getComment() {
		return "Divides by " + Math.pow(2, _argument) + ", by right shifting accumulator " + _argument + " times, keeps signed bit";
	}
	
}