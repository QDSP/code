package dk.sdu.mmmi.qdsp.structural.elements

public abstract class JumpInstruction extends Instruction{
	private JumpDestination jumpDestination;
	private JumpMode jumpMode;
	
	def public void setArgument(int argument){
		super._argument = argument;
	}
	new (JumpDestination destination, JumpMode mode) {
		this.jumpDestination = destination;
		this.jumpMode = mode;
	}
	new (int argument, JumpDestination destination, JumpMode mode) { 
		super(argument);
		this.jumpDestination = destination;
		this.jumpMode = mode;
	}
	
	def protected String getJumpDestination(){
		switch jumpDestination{
			case JumpDestination.ToEnd: 		return "to end of"
			case JumpDestination.Over: 			return "over"
			case JumpDestination.ToStart: 		return "to start of"
			case JumpDestination.ToStartOfNext: return "to start of next"
			default: return ""
		}
	}
	def protected String getJumpMode(){
		switch jumpMode{
			case JumpMode.If: 					return "If statement"
			case JumpMode.Else: 				return "Else statement"
			case JumpMode.ElseIf: 				return "ElseIf statement"
			case JumpMode.Switch: 				return "Switch statement"
			case JumpMode.Loop: 				return "Loop statement"
			case JumpMode.LoopCompare: 			return "Loop statement, for compare"
			case JumpMode.Branch: 				return "branch"
			case JumpMode.Line: 				return "next line"
			default: return ""
		}
	}
}
enum JumpDestination {
	ToEnd,Over,ToStart,ToStartOfNext
}
enum JumpMode {
	If,Else,ElseIf,Switch,Loop,LoopCompare,Branch,Line
}