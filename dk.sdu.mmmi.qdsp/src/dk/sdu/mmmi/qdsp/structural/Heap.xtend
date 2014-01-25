package dk.sdu.mmmi.qdsp.structural

import java.util.List
import dk.sdu.mmmi.qdsp.structural.elements.HeapElement
import java.util.ArrayList
import dk.sdu.mmmi.qdsp.structural.elements.HeapVariable
import dk.sdu.mmmi.qdsp.structural.elements.HeapConstant
import dk.sdu.mmmi.qdsp.structural.elements.HeapSysVariable
import dk.sdu.mmmi.qdsp.qDSP.Constant
import dk.sdu.mmmi.qdsp.qDSP.Variable
import dk.sdu.mmmi.qdsp.qDSP.MyNumber

class Heap {
	private List<HeapElement> _heapElements = new ArrayList<HeapElement>();
	
	def void putVariable(String name, int value){
		_heapElements.add(new HeapVariable(this, name, value));
	}
	def void putConstant(String name, int value){
		_heapElements.add(new HeapConstant(this, name, value));
	}
	def HeapConstant putConstant(int cvalue){
		var element = _heapElements.filter(typeof (HeapConstant)).findFirst[cvalue == value];
		if (element == null) {
			element = new HeapConstant(this, cvalue);
			_heapElements.add(element);
		}
		return element;
	}
	def private HeapSysVariable putSysVariable(){
		var element = new HeapSysVariable(this);
		_heapElements.add(element);
		return element;
	}
	def dispatch HeapElement get(String name){
		for(e: _heapElements){
			if(e.name == name){
				return e;
			}
		}
	}
	def dispatch HeapElement get(Constant c){
		return get(c.name);
	}
	def dispatch HeapElement get(Variable v){
		return get(v.name);
	}
	def dispatch HeapElement get(MyNumber n){
		return putConstant(n.value);
	}
	def removeUnusedElements(){
		_heapElements = _heapElements.filter[!unused].toList
	}
	

//			Define:{
//				return data.get(type.name);
//			}
//			Address:{
//				var sysVar = getSysVar();
//				return data.get(sysVar.name);
//			}

	
	
	
	
	def HeapSysVariable getSysVar(){
		for(i: getSysVariables()){
			if(!i.isInUse()){
				i.take();
				return i;
			}
		}
		return putSysVariable();
	}
	def private List<HeapSysVariable> getSysVariables(){
		return _heapElements.filter(typeof(HeapSysVariable)).toList;
	}
	def List<HeapElement> getHeapElements(){
		return _heapElements
	}
	def int getSysVariableCount(){
		return getSysVariables().length;
	}
	def int getAddress(HeapElement e){
		return _heapElements.indexOf(e);
	}
	def int getSize(){
		return _heapElements.length;
	}
}