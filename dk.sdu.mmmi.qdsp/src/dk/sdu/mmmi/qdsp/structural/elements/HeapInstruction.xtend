package dk.sdu.mmmi.qdsp.structural.elements;

public abstract class HeapInstruction extends Instruction{
	protected HeapElement heapelement;
	
	//new () {}
	new (HeapElement heapelement) { 
		if (heapelement == null) throw new NullPointerException()
		this.setHeapElement = heapelement;
	}
	
	override getArgument() {
		return heapelement.heapAddress;
	}
	def public void setHeapElement(HeapElement element){
		if (element == null) throw new NullPointerException()
		if(heapelement != null){
			heapelement.removeInstruction(this);
		}
		element.addInstruction(this);
		heapelement = element;
	}
	def public HeapElement getHeapElement(){
		return heapelement;
	}
}
