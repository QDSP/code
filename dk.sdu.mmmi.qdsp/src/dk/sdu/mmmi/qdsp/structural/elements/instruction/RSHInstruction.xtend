package dk.sdu.mmmi.qdsp.structural.elements.instruction

class RSHInstruction extends dk.sdu.mmmi.qdsp.structural.elements.Instruction{
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
		return 0x12
	}

	def public void setArgument(int argument){
		super._argument = argument;
	}
	new () {}
	new (int argument) { super(argument)}
	
	override getInstructionName() {
		return staticInstructionName
	}
	
	
	def static getStaticInstructionName() {
		return "RSH"
	}
	
	override getComment() {
		return "Right shifting accumulator " + _argument + " times";
	}
	
}