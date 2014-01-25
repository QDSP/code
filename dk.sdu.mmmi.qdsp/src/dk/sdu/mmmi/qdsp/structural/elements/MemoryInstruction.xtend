package dk.sdu.mmmi.qdsp.structural.elements

public abstract class MemoryInstruction extends Instruction{
	
	def public void setArgument(int argument){
		super._argument = argument;
	}
	
	new () {}
	new (int argument) { super(argument) }
	
}