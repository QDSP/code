package dk.sdu.mmmi.qdsp.optimizer

import dk.sdu.mmmi.qdsp.structural.elements.HeapReadInstruction
import dk.sdu.mmmi.qdsp.structural.elements.HeapSysVariable
import dk.sdu.mmmi.qdsp.structural.elements.Instruction
import dk.sdu.mmmi.qdsp.structural.elements.JumpInstruction
import dk.sdu.mmmi.qdsp.structural.elements.MemoryReadInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAHInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAIInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CASInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CHAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CIAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CSAInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.JMPInstruction
import dk.sdu.mmmi.qdsp.structural.elements.instruction.NOPInstruction
import java.util.ArrayList
import java.util.List

class InstructionOptimizer {
	
	private List<JumpData> jumps = new ArrayList<JumpData>();
	private List<Instruction> instructions
	private List<Area> areas = new ArrayList<Area>();
	
    def public void Optimize( List<Instruction> instructions) {
		this.instructions = instructions;
		var List<JumpData> jumps = new ArrayList<JumpData>();
		areas.clear();
		var int i = 0;

		for(Instruction instruction : this.instructions) {
			if (instruction instanceof JumpInstruction) {
				jumps.add(new JumpData(instruction as JumpInstruction, i));
				if (!this.jumps.exists[it.equals(instruction)]){
					this.jumps.add(new JumpData(instruction as JumpInstruction, i));
				}
			}
			i = i + 1;
		}
		

		areas = generateAreas(jumps, instructions)
		updateAreaAncestry(areas);

		print(printAreas());
		runOptimization();
		print(printAreas());


	}
		

	
	def printAreas() '''
	«FOR Area it : this.areas»
		«it»
	«ENDFOR»
	
	''' 
	
	
	def List<Area> generateAreas(List<JumpData> jumps, List<Instruction> instructions) {
		var List<Area> areas = new ArrayList<Area>()
		var int lastStart = 0;
		for ( i : 0 ..< instructions.size) {
			if(lastStart >= i) {
				if (instructions.get(i) instanceof JMPInstruction) {
					areas.add(new Area(lastStart, i))
					lastStart = i + 1;
				}	
			} else if (jumps.exists[to == i]) {	
				areas.add(new Area(lastStart, i - 1))
				lastStart = i; 
			} else if(jumps.exists[from == i]) {
				areas.add(new Area(lastStart, i))			
				lastStart = i + 1;
			} 
		}
		
		areas.add(new Area(lastStart, instructions.size-1))
		
		return areas;
	}

	def updateAreaAncestry(List<Area> areas) {
		for ( i : 1 ..< areas.size) {
			var Area area = areas.get(i);
			
			if (!(instructions.get(areas.get(i-1).end) instanceof JMPInstruction)) {
				var Area parea = areas.get(i-1);
				parea.children.add(area);
				area.parrents.add(parea);
			}
			
			for ( j : 0 ..< areas.size) {
				var Area parea = areas.get(j)
				var Instruction instruction = instructions.get(parea.end);
				if (instruction instanceof JumpInstruction && parea != area) {
					if (instruction.argument == area.start) {
						parea.children.add(area);
						area.parrents.add(parea);
					}
				}
			}
		}
	}	
	def runOptimization() {
		//Optimize areacode
		optimizeAreas()
		print(printAreas());
		//Optimize Instructions
		var int i = 1;
		while (i < instructions.size()) {
			if ((instructions.get(i) instanceof CSAInstruction && instructions.get(i+1) instanceof NOPInstruction) || (instructions.get(i) instanceof CIAInstruction && instructions.get(i+1) instanceof NOPInstruction) ) {
				val MemoryReadInstruction instruction = instructions.get(i) as MemoryReadInstruction
				if (instruction.argument != null)
					i = optimizeDataToAcc(i, instruction);	
			} else if (instructions.get(i) instanceof MemoryReadInstruction) {
				i = optimizeAcumulator(i, instructions.get(i)); 
			} else if (instructions.get(i) instanceof CHAInstruction) {
				if (instructions.get(i+1) instanceof CAHInstruction && (instructions.get(i+1) as CAHInstruction).heapElement instanceof HeapSysVariable) {
					i = optimizeHeapLoads(i, instructions.get(i) as CHAInstruction);
				} else {
					i = optimizeAcumulator(i, instructions.get(i)); 
				}
			}
				
			i = i + 1
		}
		//Optimize Heap Puts
		optimizeHeapPuts();
	}
	
	def optimizeHeapPuts() {
		var int index = 1 
		while (index < instructions.size) {
			val Instruction instruction = instructions.get(index);
			if (instruction instanceof CAHInstruction) {
				var boolean found = false;
				var int i = 0 
				while (i < instructions.size && !found) {
					var Instruction tmp = instructions.get(i);
					if (tmp instanceof HeapReadInstruction && tmp.argument == instruction.argument) {
						found = true;
					}
					i = i + 1	
				}
				if (!found) {
					removeInstruction(index);
					index = index - 1;
				}
			}
			index = index + 1	
		}
		
	}

	def private int optimizeAcumulator(int oldindex, Instruction instruction) {
		var int index = oldindex
		var boolean blocked = false;
		val List<AreaAnalysis> analyzedAreas = new ArrayList<AreaAnalysis>();
		val List<AreaAnalysis> requredAreas = new ArrayList<AreaAnalysis>();
		new AreaAnalysis(getArea(index)) => [
			alternativeEnd = oldindex - 1 
			requredAreas.add(it)
			analyzedAreas.add(it)
		]
		var int finds = 0;
		while(requredAreas.size() > finds && !blocked) {
			val AreaAnalysis areaanalysis = requredAreas.get(finds);
			var boolean break = false;
			var int i = areaanalysis.end 
			while (i >= areaanalysis.start && !break) {
				var Instruction tmpInstruction = instructions.get(i)
				if(tmpInstruction instanceof CAHInstruction && instruction instanceof CHAInstruction) {
					if (tmpInstruction.argument == instruction.argument) {
						System.err.println("Removed accumulator element: " + index);
						areaanalysis.foundLine = i;
					}  else {
						blocked = true;
					}
					break = true;
				} else if(tmpInstruction instanceof CAIInstruction && instruction instanceof CIAInstruction) {
					if (tmpInstruction.argument == instruction.argument) {
						System.err.println("Removed accumulator element: " + index);
						areaanalysis.foundLine = i;
					}  else {
						blocked = true;
					}
					break = true;
				} else if(tmpInstruction instanceof CASInstruction && instruction instanceof CSAInstruction) {
					if (tmpInstruction.argument == instruction.argument) {
						System.err.println("Removed accumulator element: " + index);
						areaanalysis.foundLine = i;
					}  else {
						blocked = true;
					}
					break = true;
				} else if (tmpInstruction instanceof HeapReadInstruction || tmpInstruction instanceof MemoryReadInstruction) {
					blocked = true;
					break = true;
				} 
				i = i - 1
			}
			
			
			if (areaanalysis.foundLine < 0 && !blocked) {
				if (areaanalysis.area.parrents.size > 0) {
					requredAreas.remove(areaanalysis)
					for (parea : areaanalysis.area.parrents) {
						if (!analyzedAreas.exists[parea == area]) {
							new AreaAnalysis(parea) => [
								requredAreas.add(it)
								analyzedAreas.add(it)
							]
						}
					}
				} else {
					blocked = true
				}
			} else if ( !blocked) {
				finds = finds + 1
			}
		}
		
		if(!blocked){
			if (finds == requredAreas.size) {
				removeInstruction(index);
				index = index - 1;
			}
		}
		
		return index
	}
	
	def private Area getArea(int instuctionIndex) {
		var Area area = areas.findFirst[start <= instuctionIndex && end >= instuctionIndex]
		if (area == null) {
			System.err.println('''Failed to find area with at index: «instuctionIndex»''');
			throw new NullPointerException()
		}
		return area
	}
	
	def int optimizeDataToAcc(int index, MemoryReadInstruction instruction) {
		var int newindex = index; 
		if (index < 1) return index
		val List<AreaAnalysis> requredAreas = new ArrayList<AreaAnalysis>();
		val List<AreaAnalysis> analyzedAreas = new ArrayList<AreaAnalysis>();
		requredAreas.add(new AreaAnalysis(getArea(index)) => [alternativeEnd = index - 1]);
		var boolean blocked = false;
		var int finds = 0;
		
		while(requredAreas.size() > finds && !blocked) {
			val AreaAnalysis areaanalysis = requredAreas.get(finds);
			var int i = areaanalysis.end
			while (i >= areaanalysis.start && !blocked && areaanalysis.instruction == null) {
				var Instruction tempInstruction = instructions.get(i)
				if ((instruction instanceof CSAInstruction && tempInstruction instanceof CASInstruction) || (instruction instanceof CIAInstruction && tempInstruction instanceof CAIInstruction)) {
					blocked = true;
				} else if(instruction.class.isInstance(tempInstruction)) {
					if (tempInstruction.argument == null || tempInstruction.argument == instruction.argument) {
						areaanalysis.foundLine = i
						areaanalysis.instruction = tempInstruction
					} else {
						blocked = true;
					}
				} 
				i = i - 1
			}
			
			if (areaanalysis.instruction == null && !blocked) {
				if (areaanalysis.area.parrents.size > 0) {
				requredAreas.remove(areaanalysis)
				for (parea : areaanalysis.area.parrents) {
					var AreaAnalysis tmpArea = analyzedAreas.findFirst[parea == area]
					if (tmpArea == null) {
						var aArea = new AreaAnalysis(parea)
						requredAreas.add(aArea)
						analyzedAreas.add(aArea)
					} else {
						if (tmpArea.instruction != null) {
							finds = finds + 1
						}
					}
				}
				} else {
					blocked = true
				}
			} else if ( !blocked) {
				finds = finds + 1
			}
		}
		
		if (!blocked ) {
			if (finds == requredAreas.size()) {
			//	if not blocked and enough replacements found, update instruction set				
				System.err.println("Size match ok, size:" + finds);
				instruction.addressSetInstructions.forEach[removeAddressSetIn(index)]
				for (AreaAnalysis areaAnalysis : requredAreas) { // Update each of the affected instructions
					var MemoryReadInstruction tmp = areaAnalysis.instruction as MemoryReadInstruction
					if (!instruction.addressSetInstructions.contains(tmp)) {
						instruction.removeSetInstruction(tmp)
					}
					tmp.addSetInstruction(instruction);
					instruction.addressSetInstructions.forEach[addAddressSetIn(areaAnalysis.foundLine)]
					tmp.setArgument = instruction.argument
				}
				
				removeInstruction(index);
				if (instructions.get(index) instanceof NOPInstruction) {
					removeInstruction(index);
					newindex = newindex - 1;
				}
				newindex = newindex - 1;
				
			} else {
				System.err.println("Size match with parrents bad, size:" + finds);
			}
		}
		
		
		return newindex
	}
	
	def private int optimizeHeapLoads(int oldindex, CHAInstruction instruction) {
		var int index = oldindex; 
		System.err.println("Optimize Heap Use");
		var int to = instruction.argument;
		var int from = instructions.get(index+1).argument;
			
		val List<AreaAnalysis> processareas = new ArrayList<AreaAnalysis>();
		val List<AreaAnalysis> analyzedAreas = new ArrayList<AreaAnalysis>();
		new AreaAnalysis(getArea(index)) => [
			alternativeStart = oldindex
			analyzedAreas.add(it)
			processareas.add(it)
		]
		
		removeInstruction(index);
		removeInstruction(index);
		
		while(processareas.size() > 0) {
			var AreaAnalysis areaanalysis = processareas.get(0);
			processareas.remove(areaanalysis);
			var boolean blocked = false;
			var int i = areaanalysis.start
			while (i < areaanalysis.end  && !blocked) {
				var Instruction tmp = instructions.get(i);
				
				if(tmp instanceof HeapReadInstruction) {
					if (tmp.argument == from)
						(tmp as HeapReadInstruction).heapElement = instruction.heapElement
				}
				else if (tmp instanceof CAHInstruction) {
					if (tmp.argument == to || tmp.argument == from)
						blocked = true
					
				}
				i = i + 1
			}
			
			if (!blocked) {
				for (Area cArea : areaanalysis.area.children) {
					if (!analyzedAreas.exists[cArea == area])
						new AreaAnalysis(cArea) => [
							analyzedAreas.add(it)
							processareas.add(it)
						]
				}
			}
		}
		
		index = index - 2
		return index
	}

	def private int getInstructionIndexFromAreaEnd(Area area, boolean skipJumps) {
		var int index = area.end;
		while (instructions.get(index) instanceof JMPInstruction && area.start <= index && skipJumps && area.start < area.end)
			index = index - 1;

		return index;
	}
	
	def optimizeAreas() {
		for ( i : 0 ..< areas.size) {
			var Area area = areas.get(i);
			if (area.parrents.size() > 1) {
				var boolean same = true;
				while (same) {
					var Area testparea = area.parrents.get(0);
					var testinstuction = instructions.get(getInstructionIndexFromAreaEnd(testparea,true));
					
					for ( j : 1 ..< area.parrents.size) {
						var Area parea = area.parrents.get(j);
						var instuction = instructions.get(getInstructionIndexFromAreaEnd(parea,true));
						if (instuction.argument == testinstuction.argument && instuction.id == testinstuction.id) {
							same = same
						} else {
							same = false;
						}
					}
					
					if (same) {
						area.parrents.forEach[removeInstruction(getInstructionIndexFromAreaEnd(it,true))]
						addInstruction(area.start, testinstuction)
					}
				}
			}
		}
		
		var List<Area> areasToRemove = new ArrayList<Area>()
		for ( area : areas) {
			if (area.start > area.end) {
				area.parrents.forEach[children.remove(area)]
				area.children.forEach[parrents.remove(area)]
				areasToRemove.add(area);
			}
		}
		areas.removeAll(areasToRemove)
	}
		
	def removeInstruction(int index) {
		instructions.remove(index)
		
		jumps.filter[to > index].forEach[to = to - 1];
		jumps.filter[from >= index].forEach[from = from - 1];
		
		areas.filter[start > index].forEach[start = start - 1];
		//areas.filter[start == index].forEach[start = start - 1];
		areas.filter[end >= index].forEach[end = end - 1];
		
		for (MemoryReadInstruction it : instructions.filter(typeof(MemoryReadInstruction))) {
			var int i = 0;
			while (i < addressSetIn.size()) {
				if (addressSetIn.get(i) >= index) 
				{
					addressSetIn.set(i, addressSetIn.get(i) - 1)
				}
				i = i + 1;
			}
		}
	}
	
	def addInstruction(int index,Instruction instruction) {
		instructions.add(index, instruction)
		
		jumps.filter[to > index].forEach[to = to + 1];
		jumps.filter[from >= index].forEach[from = from + 1];
		
		areas.filter[start > index].forEach[start = start + 1];
		//areas.filter[start == index].forEach[start = start - 1];
		areas.filter[end >= index].forEach[end = end + 1];
		
		for (MemoryReadInstruction it : instructions.filter(typeof(MemoryReadInstruction))) {
			var int i = 0;
			while (i < addressSetIn.size()) {
				if (addressSetIn.get(i) >= index) {
					addressSetIn.set(i, addressSetIn.get(i) + 1)
				}
				i = i + 1
			}
		}
	}	
}


	class AreaAnalysis {
		@Property private Area area
		@Property private int foundLine = -1
		@Property private Instruction instruction
		@Property public int alternativeEnd = -1
		@Property public int alternativeStart = -1

		def int getEnd() {
			if (alternativeEnd != -1) return alternativeEnd;
			return area.end;
		}

		def int getStart() {
			if (alternativeStart != -1) return alternativeStart;
			return area.start;
		}

		new(Area area) {
			if (area == null) throw new NullPointerException();
			this.area = area;
		}
	}

	class Area {
		@Property public List<Area> parrents = new ArrayList<Area>();
		@Property public List<Area> children = new ArrayList<Area>();
		@Property public int start;
		@Property public int end;

		new(int start, int end) {
			this.start = start;
			this.end = end;
		}
		
		override public String toString() '''
			Area start: «start» end: «end» «IF parrents.size > 0»Parrents: «FOR Area it : parrents»«start» «ENDFOR»«ENDIF»«IF children.size > 0»Children: «FOR Area it : children SEPARATOR ' '»«start»«ENDFOR»«ENDIF»
		'''
	}

	class JumpData {
		@Property int from;
		@Property JumpInstruction instruction;

		new(JumpInstruction instruction, int from) {
			this.from = from;
			this.instruction = instruction;
		}

		def public int getTo() {
			return instruction.argument;
		}

		def public void setTo(int address) {
			instruction.argument = address;
		}

		
		override public boolean equals(Object obj) {
			if (obj == null) return false;
			if (obj == this) return true;
			if (obj instanceof JumpData) {
				if ((obj as JumpData).instruction == instruction) 
					return true;
			} else if (obj instanceof JumpInstruction) {
				if (this.instruction == obj) 
					return true;
			}


			return false;
		}
		

	
	}

