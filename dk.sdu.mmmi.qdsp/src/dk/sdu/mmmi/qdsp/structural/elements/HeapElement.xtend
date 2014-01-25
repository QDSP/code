package dk.sdu.mmmi.qdsp.structural.elements;

import java.util.List
import java.util.ArrayList
import dk.sdu.mmmi.qdsp.structural.Heap

public abstract class HeapElement {
	protected Heap heap;
	@Property public String name;
	@Property public int value = 0;
	protected List<HeapInstruction> instructions = new ArrayList<HeapInstruction>()
	
	new(Heap heap, int value){
		this.heap = heap;
		this.value = value;
	}
	new(Heap heap, String name, int value){
		this(heap, value)
		this.name = name;
	}
	def int getHeapAddress(){
		heap.getAddress(this);
	}
	def boolean isUnused(){
		return instructions.size() == 0;
	}
	def boolean addInstruction(HeapInstruction instruction){
		return instructions.add(instruction);
	}
	def boolean removeInstruction(HeapInstruction instruction){
		return instructions.remove(instruction);
	}
}
