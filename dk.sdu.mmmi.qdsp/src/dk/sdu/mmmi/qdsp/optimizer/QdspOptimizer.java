///*
// * Use Jump data to generate areas, by finding all jumps, and splitting code whenever a jump start or end is hit, might work
// * 
// * Limit search for instruction to max be size of areas, to avoid endledss loop
// * 
// * */
//
//
//package dk.sdu.mmmi.qdsp.optimizer;
//
//import java.io.Console;
//import java.util.ArrayList;
//import java.util.List;
//
//import javax.crypto.AEADBadTagException;
//
//import org.eclipse.xtext.xtext.CurrentTypeFinder;
//
//import dk.sdu.mmmi.qdsp.generator.Instructions;
//import dk.sdu.mmmi.qdsp.generator.MicroInstruction;
//import dk.sdu.mmmi.qdsp.structural.elements.Instruction;
//import dk.sdu.mmmi.qdsp.structural.elements.JumpInstruction;
//
//public class QdspOptimizer {
//	private List<JumpData> jumps = new ArrayList<JumpData>();
//	private List<Instruction> instructions;
//	private List<Area> areas = new ArrayList<Area>();
//
//
//	public void Optimize( List<Instruction> instructions) {
//		this.instructions = instructions;
//
//		jumps.clear();
//		areas.clear();
//		int i = 0;
//		for(Instruction instruction : this.instructions) {
//			if (instruction instanceof JumpInstruction) {
//				jumps.add(new JumpData((JumpInstruction)instruction, i));
//			}
//			i++;
//		}
//
//		areas = generateAreas(0,instructions.size()-1);
//		updateAreaAncestry(areas);
//
//		printAreas();
//		runOptimization();
//		printAreas();
//
//
//		//return this.instructions;
//	}
//
//	private void printAreas() {
//		for(Area area : areas) {
//			System.out.print("Area start: " + area.start + " end: " + area.end + " ancestors: ");
//
//			for(Area parea : area.parrents) {
//				System.out.print(parea.start + " " );
//			}
//			System.out.print("children: ");
//			for(Area parea : area.children) {
//				System.out.print(parea.start + " " );
//			}
//
//			System.out.println();
//		}
//	}
//
////	private void updateAreaAncestry(List<Area> areas) {
////
////
////		for (int i = 1; i < areas.size();i++) {
////			Area area = areas.get(i);
////
////			if (instructions.get(areas.get(i-1).end).instruction != Instructions.JMP) { 
////				Area parea = areas.get(i-1);
////				parea.children.add(area);
////				area.parrents.add(parea); 
////			}
////
////			for (int j = i-2; j >= 0; j--) {
////				Area parea = areas.get(j);
////				Instruction instruction = instructions.get(parea.end);
////				switch (instruction.instruction) {
////				case Instructions.BRE:
////				case Instructions.BRG: 
////				case Instructions.BRL:
////				case Instructions.JMP:
////					if (instruction.address == area.start) {
////						area.parrents.add(parea);
////						parea.children.add(area);
////					}
////
////					break;
////				default: break;
////				}
////
////
////			}
////		}
////
////
////	}
////
////	private List<Area> generateAreas(int begin, int end) {
////		List<Area> areas = new ArrayList<Area>();
////		int curAreaStart = begin;
////		int curAreaJmp = -1;
////		for(int i = begin; i < end; i++) {
////			System.out.println("Arealyzing line" + i);
////			Instruction instruction = instructions.get(i);
////			if (i == curAreaJmp) {
////				areas.add(new Area(curAreaStart, curAreaJmp - 1));
////				curAreaStart = i;
////			}
////
////			if (isJump(instruction)) {
////				
////				if (instruction.instruction == Instructions.JMP && instruction.address < i) {
////					areas.add(new Area(curAreaStart, instruction.address - 1));
////					areas.add(new Area(instruction.address, i));
////					curAreaStart = i;
////				} else {
////					areas.add(new Area(curAreaStart, i));
////					//areas.addAll(generateAreas(i+1, instruction.address - 1));
////					//i = instruction.address;
////					if (instructions.get(i - 1).instruction == Instructions.JMP) {
////						curAreaJmp = instructions.get(i - 1).address;
////					}
////					curAreaStart = i;
////				}
////			}
////		}
////		if (curAreaStart <= end) {
////			areas.add(new Area(curAreaStart, end));
////		}
////		return areas;
////	}
////
////	private void runOptimization() {
////		//Optimize areacode
////		optimizeAreas();
////
////		//Optimize instructions
////		for(int i = 1; i < instructions.size() ; i++) {
////			Instruction instruction = instructions.get(i);
////			if (instruction.instruction == Instructions.CSA && instructions.get(i+1).instruction == Instructions.NOP) 
////				i = optimizeDataToAcc(i, instruction);
////			else if (instruction.instruction == Instructions.CIA && instructions.get(i+1).instruction == Instructions.CIA) 
////				i = optimizeDataToAcc(i, instruction);
////			else if (instruction.instruction == Instructions.CHA && instructions.get(i+1).instruction == Instructions.CAH && instructions.get(i+1).systemvariable)
////				i = optimizeHeapLoads(i, instruction);
////			else if (instruction.instruction == Instructions.CHA)
////				i = optimizeAcumulator(i, instruction);
////			else if (instruction.instruction == Instructions.CIA)
////				i = optimizeAcumulator(i, instruction); 
////			else if (instruction.instruction == Instructions.CSA)
////				i = optimizeAcumulator(i, instruction);
////		}
////
////
////		//Optimize Heap Puts
////		optimizeHeapPuts();
////	}
////
////	private boolean isHeapUser(Instruction instruction) {
////		switch (instruction.instruction) {
////		case Instructions.CHA:
////		case Instructions.CMP:
////		case Instructions.ADD:
////		case Instructions.SUB:
////		case Instructions.MUL:
////		case Instructions.MAX:
////		case Instructions.MIN: return true;
////		default: return false;
////		}
////	}
////
////	private void optimizeHeapPuts() {
////
////
////		for(int index = 1; index < instructions.size() ; index++) {
////			MicroInstruction instruction = instructions.get(index);
////
////			if (instruction.instruction == Instructions.CAH) {
////				boolean found = false;
////				for(int i = 0; i < instructions.size() ; i++) {
////					MicroInstruction tmp = instructions.get(i);
////					if (isHeapUser(tmp) && tmp.address == instruction.address) {
////						found = true;
////						break;
////					}
////				}
////
////				if (!found) {
////					removeInstruction(index);
////					index--;
////				}
////			}
////		}
////	}
////
////	private int getInstructionIndexFromAreaEnd(Area area, boolean skipJumps) {
////		int index = area.end;
////		while (instructions.get(index).instruction == Instructions.JMP && area.start <= index && skipJumps)
////			index--;
////
////		return index;
////	}
////
////	private void optimizeAreas() {
////		for (int i = 0; i < areas.size(); i++) {
////			Area area = areas.get(i);
////			if (area.parrents.size() > 1) {
////				boolean same = true;
////				while (same) {
////					Area testparea = area.parrents.get(0);
////					MicroInstruction testinstuction = instructions.get(getInstructionIndexFromAreaEnd(testparea,true));
////
////					for (int j = 1; j < area.parrents.size(); j++) {
////						Area parea = area.parrents.get(j);
////						MicroInstruction instuction = instructions.get(getInstructionIndexFromAreaEnd(parea,true));
////
////						if (instuction.address == testinstuction.address && instuction.instruction == testinstuction.instruction) {
////
////						} else {
////							same = false;
////							break;
////						}
////					}
////
////					if (same) {
////						for (int j = 0; j < area.parrents.size(); j++) {
////							Area parea = area.parrents.get(j);
////							removeInstruction(getInstructionIndexFromAreaEnd(parea,true));
////						}
////
////						addInstruction(area.start, testinstuction);
////
////					}
////				}
////
////
////			} else if (area.parrents.size() > 1) {
////
////			}
////		}
////	}
////
////	private Area getArea(int instuctionIndex) {
////		for(Area area : areas) {
////			if (area.start <= instuctionIndex && area.end >= instuctionIndex)
////				return area;
////		}
////		return null;
////	}
////
////	private int optimizeAcumulator(int index, MicroInstruction instruction) {
////		List<AreaAnalysis> requredAreas = new ArrayList<AreaAnalysis>();
////		AreaAnalysis aa = new AreaAnalysis(getArea(index)); 
////		aa.AlternativeEnd =  index-1;
////		requredAreas.add(aa);
////
////		boolean blocked = false;
////		int finds = 0;
////		while(requredAreas.size() > finds) {
////			AreaAnalysis areaanalysis = requredAreas.get(finds);
////
////			for(int i = areaanalysis.getEnd(); i >= areaanalysis.area.start;i--) {
////				MicroInstruction tmp = instructions.get(i);
////
////				if(tmp.instruction == Instructions.CAH && instruction.instruction == Instructions.CHA) {
////					if (tmp.address == instruction.address) {
////						System.err.println("Removed accumulator elemet: " + index);
////						areaanalysis.found = i;
////					}  else {
////						blocked = true;
////					}
////					break;
////				} else if(tmp.instruction == Instructions.CAI && instruction.instruction == Instructions.CIA) {
////					if (tmp.address == instruction.address) {
////						System.err.println("Removed accumulator elemet: " + index);
////						areaanalysis.found = i;
////					}  else {
////						blocked = true;
////					}
////					break;
////				} else if(tmp.instruction == Instructions.CAS && instruction.instruction == Instructions.CSA) {
////					if (tmp.address == instruction.address) {
////						System.err.println("Removed accumulator elemet: " + index);
////						areaanalysis.found = i;
////					}  else {
////						blocked = true;
////					}
////					break;
////				} else if (tmp.instruction == Instructions.CAH || tmp.instruction == Instructions.CAI || tmp.instruction == Instructions.CAS || tmp.instruction == Instructions.NOP || tmp.instruction == Instructions.CMP || isJump(tmp)) {
////
////				} else {
////					blocked = true;
////					break;
////				}
////			}
////
////			if (areaanalysis.found < 0 && !blocked) {
////				requredAreas.remove(areaanalysis);
////				for (Area area : areaanalysis.area.parrents) {
////					requredAreas.add(new AreaAnalysis(area));
////				}
////			} else {
////				finds++;
////			}
////		}
////		if(!blocked){
////			if (finds == requredAreas.size()) {
////				removeInstruction(index);
////				index--;
////			}
////		}
////
////		return index;
////	}
////
////	private int optimizeHeapLoads(int index, MicroInstruction instruction) {
////		System.err.println("Optimize Headder Use");
////		int to = instruction.address;
////		int from = instructions.get(index+1).address;
////
////		removeInstruction(index);
////		removeInstruction(index);
////
////
////
////		List<AreaAnalysis> processareas = new ArrayList<AreaAnalysis>();
////		AreaAnalysis aa = new AreaAnalysis(getArea(index)); 
////		aa.AlternativeStart =  index;
////		processareas.add(aa);
////
////		while(processareas.size() > 0) {
////			AreaAnalysis areaanalysis = processareas.get(0);
////			processareas.remove(areaanalysis);
////			boolean blocked = false;
////			for (int i = areaanalysis.getStart(); i < areaanalysis.getEnd(); i++) {
////				MicroInstruction tmp = instructions.get(i);
////				switch (tmp.instruction) {
////				case Instructions.CHA:
////				case Instructions.CMP:
////				case Instructions.ADD:
////				case Instructions.SUB:
////				case Instructions.MUL:
////				case Instructions.MAX:
////				case Instructions.MIN:
////					if (tmp.address == from)
////						tmp.address = to;
////					break;
////
////				case Instructions.CAH:
////					if (tmp.address == to || tmp.address == from)
////						blocked = true;
////
////				default:
////					break;
////				}
////
////				if (blocked) break;
////			}
////
////			if (!blocked) {
////				for (Area area : areaanalysis.area.children) {
////					processareas.add(new AreaAnalysis(area));
////				}
////			}
////
////		}
////		index -= 2; 
////		return index;
////	}
////
////
////	private int optimizeDataToAcc(int index, MicroInstruction instruction) {
////		int blocker = 0;
////
////		if (instruction.instruction == Instructions.CSA) blocker = Instructions.CAS;
////		if (instruction.instruction == Instructions.CIA) blocker = Instructions.CAI;
////
////		List<AreaAnalysis> requredAreas = new ArrayList<AreaAnalysis>();
////		AreaAnalysis aa = new AreaAnalysis(getArea(index)); 
////		aa.AlternativeEnd =  index-1;
////		requredAreas.add(aa);
////
////		boolean blocked = false;
////		int finds = 0;
////		while(requredAreas.size() > finds) {
////			AreaAnalysis areaanalysis = requredAreas.get(finds);
////
////			for(int i = areaanalysis.getEnd(); i >= areaanalysis.area.start;i--) {
////				MicroInstruction tmp = instructions.get(i);
////				if (tmp.instruction == blocker) { blocked = true;	break;}
////				if (tmp.instruction == instruction.instruction) {
////					if (!tmp.changed || tmp.address == instruction.address) {
////						areaanalysis.found = i;
////					} else {
////						blocked = true;
////					}
////					break;
////				}
////			}
////
////			if (areaanalysis.found < 0 && !blocked) {
////				requredAreas.remove(areaanalysis);
////				for (Area area : areaanalysis.area.parrents) {
////					requredAreas.add(new AreaAnalysis(area));
////				}
////			} else {
////				finds++;
////			}
////		}
////		if(!blocked){
////			if (finds == requredAreas.size()) {
////				System.err.println("Size match with parrents ok, size:" + finds);
////				for (AreaAnalysis areaAnalysis : requredAreas) {
////					MicroInstruction tmp = instructions.get(areaAnalysis.found);
////					tmp.address = instruction.address;
////					tmp.changed = true;
////				}
////				removeInstruction(index);
////				if (instruction.instruction == Instructions.CSA) {
////					removeInstruction(index); //TODO: This might cause issues
////					index--;
////				}
////				index--;
////
////			} else {
////				System.err.println("Size match with parrents bad, size:" + finds);
////			}
////		}
////		return index;
////	}
////
////
////	private void removeInstruction(int index) {
////		instructions.remove(index);
////
////		for(JumpData jump : jumps) {
////			if (jump.getTo() > index) {
////				jump.instruction.address--;		
////			}
////			if (jump.getFrom() > index) {
////				jump.from--;		
////			}
////		}
////
////		for(Area area : areas) {
////			if (area.start > index) {
////				area.start--;		
////			}
////			if (area.end >= index) {
////				area.end--;		
////			}
////		}
////
////	}
////
////
////	private void addInstruction(int index, MicroInstruction instruction) {
////		instructions.add(index, instruction);
////
////		for(JumpData jump : jumps) {
////			if (jump.getTo() > index) {
////				jump.instruction.address++;		
////			}
////			if (jump.getFrom() > index) {
////				jump.from++;		
////			}
////		}
////
////		for(Area area : areas) {
////			if (area.start > index) {
////				area.start++;		
////			}
////			if (area.end > index) {
////				area.end++;		
////			}
////		}
////
////	}
////
////	private boolean isJump(MicroInstruction instruction) {
////		switch (instruction.instruction) {
////		case Instructions.BRE: return true;
////		case Instructions.BRG: return true;
////		case Instructions.BRL: return true;
////		case Instructions.JMP: return true;
////		default: return false;
////		}
////
////	}
////
////	private class AreaAnalysis {
////		public Area area;
////		public int found = -1;
////		public int AlternativeEnd = -1;
////		public int AlternativeStart = -1;
////
////		public int getEnd() {
////			if (AlternativeEnd != -1) return AlternativeEnd;
////			return area.end;
////		}
////
////		public int getStart() {
////			if (AlternativeStart != -1) return AlternativeStart;
////			return area.start;
////		}
////
////		public AreaAnalysis(Area area) {
////			this.area = area;
////		}
////	}
////
////
//	private class Area {
//		public List<Area> parrents = new ArrayList<Area>();
//		public List<Area> children = new ArrayList<Area>();
//		public int start;
//		public int end;
//
//
//		public Area(int start, int end) {
//			this.start = start;
//			this.end = end;
//		}
//
//
//	}
//
//	private class JumpData {
//		private int from;
//		public JumpInstruction instruction;
//
//		public JumpData(JumpInstruction instruction, int from) {
//			this.from = from;
//			this.instruction = instruction;
//		}
//
//		public int getFrom() {
//			return from;
//		}
//
//		public int getTo() {
//			return instruction.getArgument();
//		}
//
//		public void setTo(int address) {
//			instruction.setArgument(address);
//		}
//
//		@Override
//		public boolean equals(Object obj) {
//			if (obj == null) return false;
//			if (obj == this) return true;
//			if (obj instanceof JumpData) {
//				JumpData jump = (JumpData)obj;
//				if (jump.instruction == instruction) 
//					return true;
//			} else if (obj instanceof JumpInstruction) {
//				JumpInstruction instruction = (JumpInstruction)obj;
//				if (this.instruction == instruction) 
//					return true;
//			}
//
//
//			return false;
//		}
//	}
//
//}
