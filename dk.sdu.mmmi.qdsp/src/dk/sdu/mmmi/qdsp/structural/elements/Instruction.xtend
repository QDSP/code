package dk.sdu.mmmi.qdsp.structural.elements;


public abstract class Instruction {
	protected Integer _argument = null
	
	def public abstract int getId() 

	def public Integer getArgument(){
		return _argument;
	}

	new() {}
	
	new(int argument) {
		this._argument = argument;
	}
	
	override toString(){
		return instructionName + " & A(" + (argument ?: 0) + ")";
	}

	
	def abstract String getInstructionName();
	def abstract String getComment();
	
}
