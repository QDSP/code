package dk.sdu.mmmi.qdsp.structural.elements

import java.util.Set
import java.util.HashSet
import java.util.ArrayList
import java.util.List

public abstract class MemoryReadInstruction extends MemoryInstruction{
	private  List<Integer> _addressSetIn  = new ArrayList<Integer>()
	@Property public Integer memoryAddress;
	private Set<MemoryReadInstruction> _addressSetInstructions = new HashSet<MemoryReadInstruction>();
	
	new (int argument) { 
		super(argument)
	}
	new (int memoryAddress, int addressSetIn) {
		this.memoryAddress = memoryAddress
		this._addressSetIn.add(addressSetIn) 
	}
	
	def public List<Integer> getAddressSetIn() {
		return _addressSetIn;
	}
	
	def public boolean addAddressSetIn(Integer addressSetIn) {
		return _addressSetIn.add(addressSetIn)
	}
	def public boolean removeAddressSetIn(Integer addressSetIn) {
		var boolean result = _addressSetIn.remove(addressSetIn)
		return result
	}
	
	def public Set<MemoryReadInstruction> getAddressSetInstructions() {
		return _addressSetInstructions.unmodifiableView;
	}
	
	def public boolean addSetInstruction(MemoryReadInstruction instruction) {
		//print(this.class.toString)
		return _addressSetInstructions.add(instruction);
	}
	
	def public boolean removeSetInstruction(MemoryReadInstruction instruction) {
		//print(this.class.toString)
		return _addressSetInstructions.remove(instruction);
	}
}