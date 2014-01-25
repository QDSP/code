package dk.sdu.mmmi.qdsp.generator
import dk.sdu.mmmi.qdsp.qDSP.impl.VariableImpl

class MySysVar extends VariableImpl{
	boolean free;
	new(String name){
		this.setName(name);
		free = false;
	}
	def void take(){
		free = false;
	}
	def void release(){
		free = true
	}
	def boolean isFree(){
		return free;
	}
}