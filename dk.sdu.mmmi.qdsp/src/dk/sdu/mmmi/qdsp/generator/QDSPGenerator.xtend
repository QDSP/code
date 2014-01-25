package dk.sdu.mmmi.qdsp.generator

import dk.sdu.mmmi.qdsp.optimizer.InstructionOptimizer
import dk.sdu.mmmi.qdsp.qDSP.Address
import dk.sdu.mmmi.qdsp.qDSP.Constant
import dk.sdu.mmmi.qdsp.qDSP.Define
import dk.sdu.mmmi.qdsp.qDSP.FuncFor
import dk.sdu.mmmi.qdsp.qDSP.FuncIf
import dk.sdu.mmmi.qdsp.qDSP.FuncLoader
import dk.sdu.mmmi.qdsp.qDSP.FuncLoop
import dk.sdu.mmmi.qdsp.qDSP.FuncMax
import dk.sdu.mmmi.qdsp.qDSP.FuncMin
import dk.sdu.mmmi.qdsp.qDSP.FuncPare
import dk.sdu.mmmi.qdsp.qDSP.FuncSleep
import dk.sdu.mmmi.qdsp.qDSP.FuncSwitch
import dk.sdu.mmmi.qdsp.qDSP.FuncTrunctate16
import dk.sdu.mmmi.qdsp.qDSP.FuncWhile
import dk.sdu.mmmi.qdsp.qDSP.Function
import dk.sdu.mmmi.qdsp.qDSP.MathType
import dk.sdu.mmmi.qdsp.qDSP.Model
import dk.sdu.mmmi.qdsp.qDSP.MyMath
import dk.sdu.mmmi.qdsp.qDSP.Operation
import dk.sdu.mmmi.qdsp.qDSP.Variable
import dk.sdu.mmmi.qdsp.qDSP.qInstruction
import dk.sdu.mmmi.qdsp.structural.Heap
import dk.sdu.mmmi.qdsp.structural.elements.HeapElement
import dk.sdu.mmmi.qdsp.structural.elements.HeapSysVariable
import dk.sdu.mmmi.qdsp.structural.elements.Instruction
import dk.sdu.mmmi.qdsp.structural.elements.JumpDestination
import dk.sdu.mmmi.qdsp.structural.elements.JumpInstruction
import dk.sdu.mmmi.qdsp.structural.elements.JumpMode
import dk.sdu.mmmi.qdsp.structural.elements.instruction.ADDInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BDIVInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BMULInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BREInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRGInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRLInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAIInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CASInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CHAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CIAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CMPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CSAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.JMPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.LDXInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.LSHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MAXInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MINInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MULInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.NOPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSTInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.SUBInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.TRNInstruction
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IFileSystemAccessExtension3
import org.eclipse.xtext.generator.IGenerator
import dk.sdu.mmmi.qdsp.qDSP.qdInstruction
import dk.sdu.mmmi.qdsp.qDSP.MyNumber
import dk.sdu.mmmi.qdsp.qDSP.impl.MyNumberImpl
import dk.sdu.mmmi.qdsp.qDSP.Element import dk.sdu.mmmi.qdsp.qDSP.ResType
import dk.sdu.mmmi.qdsp.qDSP.Datatype

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class QDSPGenerator implements IGenerator {
	
	MySettings					settings;
//	Instructions				instructions;
	ResourcesValidator			resourcesValidator;
	Heap					 	heap; 
//	List<Variable> 				vars;
//	List<Define> 				defs;
//	List<Constant> 				consts;
//	List<qInstruction> 			insts;
	List<Instruction>			muInsts;
	List<AddressItem>			currentAccumulator;
	
	var int _instructionLength
	
    def	int getInstructionLength(){
		if(settings.RuntimeProgrammable) {
			return (Math.ceil(MoreMath.log2(_instructionLength)) as int)+1
		} else {
			return (Math.ceil(MoreMath.log2(_instructionLength)) as int)+1
		}
	}
	
	def getProgramMemorySize() {
		var tmpSize = Math.max(settings.ProgramMemorySize, muInsts.size)
		return tmpSize
	}
	
	def getHeapSize() {
		var tmpSize = Math.max(settings.HeapSize,heap.size)
		return tmpSize
	}
	
	def int isUsed(Class<?> type) {
		if (settings.RuntimeProgrammable) return 1
		if (muInsts.filter(type).size > 0)
			return 1
		else		
			return 0;
	}
	
	def optimizeInstructions() {
		var int i = 1;
 		if (muInsts.filter(typeof(NOPInstruction)).size > 0 || settings.RuntimeProgrammable)  { 
 			NOPInstruction.setId(i)
 			i = i + 1
 		}
		if (muInsts.filter(typeof(CAHInstruction)).size > 0 || settings.RuntimeProgrammable)  { CAHInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(CHAInstruction)).size > 0 || settings.RuntimeProgrammable)  { CHAInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(RSTInstruction)).size > 0 || settings.RuntimeProgrammable)  { RSTInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(LDXInstruction)).size > 0 || settings.RuntimeProgrammable)  { LDXInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(CASInstruction)).size > 0 || settings.RuntimeProgrammable)  { CASInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(CSAInstruction)).size > 0 || settings.RuntimeProgrammable)  { CSAInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(CAIInstruction)).size > 0 || settings.RuntimeProgrammable)  { CAIInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(CIAInstruction)).size > 0 || settings.RuntimeProgrammable)  { CIAInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(ADDInstruction)).size > 0 || settings.RuntimeProgrammable)  { ADDInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(SUBInstruction)).size > 0 || settings.RuntimeProgrammable)  { SUBInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(BDIVInstruction)).size > 0 || settings.RuntimeProgrammable) { BDIVInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(BMULInstruction)).size > 0 || settings.RuntimeProgrammable) { BMULInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(MULInstruction)).size > 0 || settings.RuntimeProgrammable)  { MULInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(TRNInstruction)).size > 0 || settings.RuntimeProgrammable)  { TRNInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(MAXInstruction)).size > 0 || settings.RuntimeProgrammable)  { MAXInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(MINInstruction)).size > 0 || settings.RuntimeProgrammable)  { MINInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(LSHInstruction)).size > 0 || settings.RuntimeProgrammable)  { LSHInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(RSHInstruction)).size > 0 || settings.RuntimeProgrammable)  { RSHInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(JMPInstruction)).size > 0 || settings.RuntimeProgrammable)  { JMPInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(BREInstruction)).size > 0 || settings.RuntimeProgrammable)  { BREInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(BRGInstruction)).size > 0 || settings.RuntimeProgrammable)  { BRGInstruction.setId(i); i = i + 1; }
		if (muInsts.filter(typeof(BRLInstruction)).size > 0 || settings.RuntimeProgrammable)  { BRLInstruction.setId(i); i = i + 1; }
 		if (muInsts.filter(typeof(CMPInstruction)).size > 0 || settings.RuntimeProgrammable)  { CMPInstruction.setId(i); i = i + 1; }
 		_instructionLength = i;
	}
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		if(resource.allContents.size < 1){
			return;
		}

			
		muInsts = new ArrayList<Instruction>();
		currentAccumulator = new ArrayList<AddressItem>();
		settings = new MySettings();
//		instructions = new Instructions(settings);
		heap = new Heap();
		resourcesValidator = new ResourcesValidator(this);
		
		
		// getting resources
		println("Getting resources");
		var model = resource.allContents.filter(typeof(Model)).toList().get(0);
		
		if(model.settings != null){
			settings.loadSettings(model.settings.settings);		
		}

		generateProgramCode(model.elements);
		
		if (settings.EnableOptimization) {
			var InstructionOptimizer qo = new InstructionOptimizer 
			qo.Optimize(muInsts);
		}
		heap.removeUnusedElements();
		optimizeInstructions();
		generateQdspPro(resource, fsa);
	}
	
//	def private void loadElements(Model model){
//		insts = new ArrayList();
//		consts = new ArrayList();
//		vars = new ArrayList();
//		defs = new ArrayList();
//		//var elements = resource.allContents.filter(typeof(Elements)).toList();
//		println(model.elements.length + " Element(s) was loaded.");
//		for(e: model.elements){
//			switch e{
//				qInstruction:{
//					insts.add(e);
//				}
//				Constant:{
//					consts.add(e);
//				}
//				Variable:{
//					vars.add(e);
//				}
//				Define:{
//					defs.add(e);
//				}
//			}
//		}
//		
//		println(vars.length + " Variable(s), " + defs.length + " Define(s), " + consts.length + " Constant(s) and " + insts.length + " Instruction(s)");
//	}
	
	def private void generateQdspPro(Resource resource, IFileSystemAccess fsa){
		var qdspPro = "";
		
		for(i: muInsts){
			qdspPro = qdspPro + i.toString() + ","
			if(i.comment != ""){
				qdspPro = qdspPro + " \t\t-- " + i.comment
			}
			qdspPro = qdspPro + '\n'; 
		}
		
		fsa.generateFile(settings.projectName + ".qdspPro", qdspPro);
		
		var vhdl = new VHDLGenerator(this,settings, resourcesValidator, heap, muInsts);
		fsa.generateFile(settings.projectName + ".vhdl", vhdl.getVHDL);
		
		if(settings.RuntimeProgrammable) {
			var python = new ProgrammerGenerator(settings);
			fsa.generateFile("qdspProgrammer.py", python.getPython());
			var bin = new BitfileGenerator(settings, muInsts, heap, resourcesValidator);
	
			if (fsa instanceof IFileSystemAccessExtension3) {
				var realfsa = fsa as IFileSystemAccessExtension3;
				realfsa.generateFile(settings.projectName + ".bin",IFileSystemAccess.DEFAULT_OUTPUT ,bin.getBitfile());
			}
		}
	}

	
	def private void generateProgramCode(List<Element> elemets){
		
		elemets.decodeElements

		addToMuInsts(new RSTInstruction());

		var Integer argumentSize;

		var tmp = Math.max(heap.size, muInsts.length);
		argumentSize = Math.ceil(MoreMath.log2(tmp)).intValue;

		if(argumentSize > 6){
			settings.MicroInstArgumentSize = argumentSize;
		} else {
			settings.MicroInstArgumentSize = 6;
		}
		if(!settings.RuntimeProgrammable){
			settings.HeapSize = heap.size;
			settings.ProgramMemorySize = muInsts.length;
		}
	}
	
	
	def private void decodeElements(List<Element> elements) {
		for( element : elements) {
			element.decodeElement
		}
	}
	
	def private void decodeElement(Element it) {
		switch it {
			qInstruction: decodeElement
			Constant: decodeElement
			Variable: decodeElement
			Define: decodeElement
		}
	}
	
	def private void decodeElement(Define it){
//		decodeInstruction
	}
	
	def private void decodeElement(Constant it){
		heap.putConstant(name, value)
	}
	
	def private void decodeElement(Variable it){
		if (math == null) {
			heap.putVariable(name, 0);
		}else if (math.valn != null && math.operations.size == 0) {
			heap.putVariable(name, math.valn.value);	
		} else {
			heap.putVariable(name, 0);
			math.decodeMath
			it.fromAccumulator
		}
		
	}
	
	def private void decodeInstructions(List<qInstruction> insts){
		for(i: insts){
			decodeElement(i)
		}
	}
	
	def private void decodeElement(qdInstruction inst){ 
		if (inst.inc != null) {												//If instuction = incriment decriment
			toAccumulator(inst.inc.variable);
			var MyOperation myop = new MyOperation();
			myop.valn = new MyMyNumberImpl() => [value = 1]
			if (inst.inc.type == "++")
				myop.operator = "+"
			else
				myop.operator = "-"	
			doMath(myop)
			
			fromAccumulator(inst.inc.variable);
		} else {
			if(inst.add != null){											// argumented assgnment operatin
				var MyOperation myop = new MyOperation();
				myop.^val = inst.value.^val
				myop.valf = inst.value.valf
				myop.valn = inst.value.valn
				myop.operator = inst.add
				
				inst.value.^val = inst.res as Variable
				inst.value.valf = null
				inst.value.valn = null
				
				inst.value.operations.add(0,myop)
			}
			
			
			decodeMath(inst.value);
			
			if(inst.res != null){
				fromAccumulator(inst.res);
			} else {
				fromAccumulator(inst.res2);
			}
		}
	}
	
	def private void decodeElement(qInstruction inst){ 
		if(inst.func != null) {
			inst.func.decodeFunction;
		} else {
			inst.inst.decodeElement
		}
	}
	
	def private dispatch void decodeFunction(FuncSleep f){
		for(i: 0 ..< f.value){
			addToMuInsts(new NOPInstruction());
		}
	}
	
	def private dispatch void decodeFunction(FuncTrunctate16 f){
		decodeMath(f.value);
		addToMuInsts(new TRNInstruction());
	}
	
	def private dispatch void decodeFunction(FuncMin f){
		var HeapElement heapElement;
		decodeMath(f.val1);
		if(f.^val2 != null){
			heapElement = heap.get(f.^val2);
		} else {
			heapElement = heap.get(f.^val2n);
		}
		var ins = new MINInstruction(heapElement);
		//ins.comment = "Gets the smallest value of the accumulator or Heap " + variable.address + " (" + variable.name + ")" 
		addToMuInsts(ins);
	}
	
	def private dispatch void decodeFunction(FuncMax f){
		var HeapElement heapElement;
		decodeMath(f.val1);
		if(f.^val2 != null){
			heapElement = heap.get(f.^val2);
		} else {
			heapElement = heap.get(f.^val2n);
		}
		var ins = new MAXInstruction(heapElement);
//		ins.comment = "Gets the largest value of the accumulator or Heap " + variable.address + " (" + variable.name + ")" 		
		addToMuInsts(ins);
	}
	
	def private dispatch void decodeFunction(FuncLoader f){
		if(settings.RuntimeProgrammable){
			toAccumulator(new AddressItem("sh",settings.ProgramingControlAddress));
			addToMuInsts(new LDXInstruction());
		}
	}
	
	def private dispatch void decodeFunction(FuncPare f){
		decodeMath(f.value);
	}
	
	
	def private dispatch void decodeFunction(Address f){
		toAccumulator(f);
	}
	
	def private dispatch void decodeFunction(FuncIf it){
		if(bool.val1 == true){
			decodeInstructions(insts1);
		} else {
			var JMPInstruction jumpToEnd = new JMPInstruction(JumpDestination.ToEnd, JumpMode.If);
			var JumpInstruction jumpInst
			//if statement != false
			if(bool.val2 != null){
				decodeCompare(bool.val2, bool.val3);
				if (elseifs.size > 0) 	jumpInst = decodeComporatorInvers(bool.comp, JumpMode.ElseIf)
				else					jumpInst = decodeComporatorInvers(bool.comp, JumpMode.Else)
				decodeInstructions(insts1);
				jumpInst.argument = muInsts.length();
			}
			var int i = 0
			var boolean break = false
			//Process else ifs
			while (i < elseifs.size && !break) {
				//complete the previous statement
				if (jumpInst != null) { 
					jumpInst.argument = (jumpInst.argument + 1)
					addToMuInsts(jumpToEnd)
				}
				//handle next statement
				jumpInst = null
				var its = elseifs.get(i)
				if(its.bool.val1 == true){
					decodeInstructions(its.insts2)
					break = true;
				} else {
					if(its.bool.val2 != null){
						decodeCompare(its.bool.val2, its.bool.val3);
						if (i < elseifs.size - 1) 	jumpInst = decodeComporatorInvers(its.bool.comp, JumpMode.ElseIf)
						else				 		jumpInst = decodeComporatorInvers(its.bool.comp, JumpMode.Else)
						decodeInstructions(its.insts2)
						jumpInst.argument = (muInsts.length())
					}
				}
				i = i + 1
			}
			//Process else
			if(^else != null && !break){
				if (jumpInst != null) {
					jumpInst.argument = jumpInst.argument + 1
					addToMuInsts(jumpToEnd)
				}
				decodeInstructions(insts3)
			}
			jumpToEnd.argument = muInsts.length();
			
		}
	}
	
	
	def private dispatch void decodeFunction(FuncSwitch f){
		var JMPInstruction jumpToEnd = new JMPInstruction(JumpDestination.ToEnd, JumpMode.Switch);
		var JumpInstruction jumpInst;
		var JMPInstruction jumpOverBranch
		var HeapSysVariable sysVar = heap.getSysVar();
		decodeMath(f.val2);
		fromAccumulator(sysVar);
		for(i: 0 ..< f.cases.length()){
			
			jumpOverBranch = new JMPInstruction(JumpDestination.Over, JumpMode.Branch);
			if(i != 0){
				jumpInst.argument = (jumpInst.argument + 1);
				if(f.cases.get(i-1).break != null){
					addToMuInsts(jumpToEnd);
				} else {
					addToMuInsts(jumpOverBranch);
				}
			}
			
			if(f.cases.get(i).^val != null){
				toAccumulator(f.cases.get(i).^val);
			} else {
				toAccumulator(f.cases.get(i).^valn);
			}


			addToMuInsts(new CMPInstruction(sysVar));
			jumpInst = decodeComporatorInvers("==", JumpMode.Switch);
			decodeInstructions(f.cases.get(i).insts1);
			jumpOverBranch.argument = (muInsts.length());
			jumpInst.argument = (muInsts.length());
		}
		if(f.def != null){	
			jumpInst.argument = (jumpInst.argument + 1);
			if(f.cases.get(f.cases.length()-1).break != null){
				addToMuInsts(#[jumpToEnd]);
			}
			decodeInstructions(f.insts2);
		}
		jumpToEnd.argument = muInsts.length();
		sysVar.release();
	}
	
	def private dispatch void decodeFunction(FuncLoop f){
		if(f instanceof FuncFor){
			var FuncFor ff = f as FuncFor;
			//ff.insts1?.decodeInstructions
			//if ( != null) {
				decodeElement(ff.insts1);
			//}
		}
		if(f.bool.val2 == null){
			if(f.bool.val1){
				var startAddress = muInsts.length();
				decodeInstructions(f.instructions);
				if(f instanceof FuncFor){
					var FuncFor ff = f as FuncFor;
					ff.insts2?.decodeElement
				}
				addToMuInsts(new JMPInstruction(startAddress,JumpDestination.ToStart, JumpMode.Loop));
			}
		} else {
			var String caller = "loop";
			var ins = new JMPInstruction(JumpDestination.ToEnd,JumpMode.LoopCompare)
			if(f instanceof FuncWhile || f instanceof FuncFor) {
				addToMuInsts(ins);
			}
			var startAddress = muInsts.length();
			decodeInstructions(f.instructions);
			if(f instanceof FuncFor){
				caller = "for";
				var FuncFor ff = f as FuncFor;
				ff.insts2?.decodeElement
			}
			var endAddress = muInsts.length();
			ins.argument = endAddress;
			
			decodeCompare(f.bool.val2, f.bool.val3);
			decodeComporator( f.bool.comp, startAddress, JumpMode.Loop)
		}
	}
	
	
	def private void decodeCompare(MyMath val1, MyMath val2){
		var HeapSysVariable sysVar = heap.getSysVar();
		decodeMath(val2);
		fromAccumulator(sysVar);
		decodeMath(val1);
//		addToMuInsts(#[new MicroInstruction(Instructions.CMP, heap.getAddress(sysVar), "Compares the accumulator with heap address " + heap.getAddress(sysVar) + " (" + (sysVar as Variable).name +")")]);
		//TODO: Change this maybe?
		addToMuInsts(new CMPInstruction(sysVar));
		sysVar.release();
	}
	
	def private void decodeComporator(String comporator, int JumpAddress, JumpMode mode){
		switch comporator{
			case "==":{
				addToMuInsts(new BREInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
			case "<":{
				addToMuInsts(new BRLInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
			case ">":{
				addToMuInsts(new BRGInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
			case "<=":{
				addToMuInsts(new BRGInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
				addToMuInsts(new JMPInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
			case ">=":{
				addToMuInsts(new BRLInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
				addToMuInsts(new JMPInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
			case "!=":{
				addToMuInsts(new BREInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
				addToMuInsts(new JMPInstruction(JumpAddress, JumpDestination.ToStart, mode))
			}
		}
	}
	
	def private JumpInstruction decodeComporatorInvers(String comporator, JumpMode mode){
		var JumpInstruction jumpInst = new JMPInstruction(JumpDestination.ToStartOfNext, mode);
		switch comporator{
			case "==": { 
				addToMuInsts(new BREInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
			}
			case "<": {
				addToMuInsts(new BRLInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
			}
			case ">": {
				addToMuInsts(new BRGInstruction(muInsts.length() + 2, JumpDestination.Over, JumpMode.Line))
			}
			case "<=": {
				jumpInst = new BRGInstruction(JumpDestination.ToStartOfNext, mode)
			}
			case ">=": {
				jumpInst = new BRLInstruction(JumpDestination.ToStartOfNext, mode)
			}
			case "!=": {
				jumpInst = new BREInstruction(JumpDestination.ToStartOfNext, mode)
			}
		}
		addToMuInsts(jumpInst);
		return jumpInst;	
	}

	
	def private void decodeMath(MyMath m){
		var instsructions = new ArrayList<Instruction>();
		var lastResults = new ArrayList<Operation>();
		
		
		for(i: m.operations.length >.. 0){
			var operation = m.operations.get(i);
			var HeapSysVariable sysVar;
			var MyOperation result = new MyOperation();
			result.setOperator(operation.operator);
			if(operation.valf != null){
				
				decodeFunction(operation.valf);
				executeLastResults(lastResults);
				
				sysVar = heap.getSysVar();
				fromAccumulator(sysVar);
				result.systemVariable = sysVar;

			} else if(operation.^val != null) {
				if(operation.^val instanceof Define){		// addresses are handled as a functions
					toAccumulator(operation.^val);
					executeLastResults(lastResults);
					sysVar = heap.getSysVar();
					fromAccumulator(sysVar);
					result.systemVariable = sysVar;
				} else {
					result.setVal(operation.^val)
				}
			} else if(operation.valn != null) {
				result.setValn(operation.^valn)
			}
			lastResults.add(result);	
		}
		
		
		if(m.valf != null){
			decodeFunction(m.valf);
		} else if(m.^val != null) {
			toAccumulator(m.^val);
		} else if(m.valn != null) {
			toAccumulator(m.valn);
		}
		executeLastResults(lastResults);
		addToMuInsts(instsructions as Instruction[]);
		return;	
	}
	
	def private executeLastResults(List<Operation> lastResults){
		if(lastResults.size != 0){
			for(k: lastResults.length >.. 0){
				var r = lastResults.get(k);
				doMath(r);
				if(r instanceof MyOperation){	
					(r as MyOperation).systemVariable?.release();
				}
				lastResults.remove(r);
			}
		}
	}
	
	def private void addToMuInsts(Instruction instruction){
		muInsts.add(instruction);
	}
	
	def private void addToMuInsts(Instruction[] instructions){
		for(instruction: instructions){
			addToMuInsts(instruction);
		}
	}
	
	def private dispatch void toAccumulator(Define v){
		toAccumulator(v.value, v.name)
	}
	
	def private dispatch void toAccumulator(Address v){
		toAccumulator(v, "")
	}
	
	def private void toAccumulator(Address item, String name){
		if(item.chanel.equalsIgnoreCase("sh")){
			val CSAInstruction inst =  new CSAInstruction(item.address, muInsts.size)
			addToMuInsts(#[new CSAInstruction(item.address)=> [addSetInstruction(inst)], new NOPInstruction(),  inst])
		}else{
			val CIAInstruction inst =  new CIAInstruction(item.address, muInsts.size)
			addToMuInsts(#[new CIAInstruction(item.address)=> [addSetInstruction(inst)], new NOPInstruction(), inst])
			
		}
	}
	def private dispatch void toAccumulator(ResType item){
		switch item{
			Address: toAccumulator(item)
			Define: toAccumulator(item)
			MathType: toAccumulator(item)
		}
	}
	
	def private dispatch void toAccumulator(MathType item){
		var instruction = new CHAInstruction(heap.get(item))
		addToMuInsts(instruction);
	}

	def private dispatch void fromAccumulator(Address item){
		fromAccumulator(item,"");
	}
	
	def private dispatch void fromAccumulator(Define it){
		fromAccumulator(value,name);
	}
	
	def private void fromAccumulator(Address it, String name){
		if(chanel.equalsIgnoreCase("sh")) {
			addToMuInsts(new CASInstruction(address));
		} else {
			addToMuInsts(new CAIInstruction(address));
		}
	}
	
	def private dispatch void fromAccumulator(Variable item){
		addToMuInsts(new CAHInstruction(heap.get(item)));
	}
	
	//TODO: DETTE GÅR IKKE BARE AT GØRE !!!!!!
	def private dispatch void fromAccumulator(HeapElement item){
		addToMuInsts(new CAHInstruction(item));
	}


	def private void doMath(Operation o){
		var insts = new ArrayList<Instruction>();
		var HeapElement heapelement;
		if(o.^val != null){
			heapelement = heap.get(o.^val); 
		} else if(o.^valn != null){
			heapelement = heap.get(o.^valn); 
		} else if (o.^valf != null) {
			decodeFunction(o.valf);
		} else if (o instanceof MyOperation) {
			var myop = o as MyOperation
			heapelement = myop.systemVariable;			 
		}
		
		if (heapelement != null) {
			switch o.operator{
				case "+":{
					insts.add(new ADDInstruction(heapelement))
				}
				case "-":{
					insts.add(new SUBInstruction(heapelement))

				}
				case "*":{ 
					if(o.^valn != null){
						var multiplyer = o.valn.value;
						if(MoreMath.IsPowerOf2(multiplyer)){
							var shifts = 0;
							while(multiplyer%2 == 0 && multiplyer>1){
								multiplyer = multiplyer / 2;
								shifts = shifts + 1;
							} 
							insts.add(new BMULInstruction(shifts))
						} else {
							insts.add(new MULInstruction(heapelement));
						}
					} else if (o instanceof MyOperation || o.^val != null) {
						insts.add(new MULInstruction(heapelement))
					}
				}
				case "/":{
					var devider = o.valn.value;
					if(MoreMath.IsPowerOf2(devider)){
						var shifts = 0;
						while(devider%2 == 0 && devider>1){
							devider = devider / 2;
							shifts = shifts + 1;
						} 
						insts.add(new BDIVInstruction(shifts))
					} else {
						throw new Exception("Unable to devide with numbers not power of 2");
						// throw compiler error
						// TODO: 4AK -> Make validation Check
					}
				}
				case "<<":{
					insts.add(new LSHInstruction(o.valn.value));
				}
				case ">>":{
					insts.add(new RSHInstruction(o.valn.value));
				}
			}
		
		}
		currentAccumulator.clear();
		addToMuInsts(insts as Instruction[]);
	}
}

