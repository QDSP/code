package dk.sdu.mmmi.qdsp.generator;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import dk.sdu.mmmi.qdsp.structural.Heap;
import dk.sdu.mmmi.qdsp.structural.elements.HeapElement;
import dk.sdu.mmmi.qdsp.structural.elements.Instruction;

public class BitfileGenerator {

	final Integer 	headerSize 			= 18;	//Bytes
	final Integer 	heapElementSize 	= 5;	//Bytes
	final Integer 	programElementSize 	= 2;	//Bytes
	
	MySettings settings;
	Heap heap;
	List<Instruction> muInsts;
	int numberOfHeapElements;
	int numberOfInstructions;
	ResourcesValidator resourcesValidator;

	
	public BitfileGenerator(MySettings settings,List<Instruction> muInsts, Heap heap, ResourcesValidator resourcesValidator){
		this.settings = settings;
		this.heap = heap;
		this.muInsts = muInsts;
		this.resourcesValidator = resourcesValidator;
	}
	public InputStream getBitfile(){
		
		List<Byte> 	genProgram = createProgram();
		List<Byte> 	genHeap = createHeap();
		byte[]		genHeader = createHeader();
		
		byte[] returnVal = new byte[genHeader.length + genHeap.size() + genProgram.size()];
		for(int i = 0; i < genHeader.length; i++){
			returnVal[i] = genHeader[i];
		}
		for(int i = 0; i < genHeap.size(); i++){
			returnVal[i + genHeader.length] = genHeap.get(i);
		}
		for(int i = 0; i < genProgram.size(); i++){
			returnVal[i + genHeader.length + genHeap.size()] = genProgram.get(i);
		}
		
		return new ByteArrayInputStream(returnVal);
	}
	private byte[] createHeader(){
		byte[] tmp;
		byte[] header = new byte[headerSize];
		header[0] =  resourcesValidator.intToBytes(headerSize,1)[0];
		header[1] =  resourcesValidator.intToBytes(settings.ProgramingControlAddress,1)[0];
		header[2] =  resourcesValidator.intToBytes(settings.ProgramingDataOutAddress,1)[0];
		header[3] =  resourcesValidator.intToBytes(settings.ProgramingDataInAddress,1)[0];
		header[4] =  resourcesValidator.intToBytes(settings.ProgramingStatusAddress,1)[0];
		header[5] =  resourcesValidator.intToBytes(programElementSize,1)[0];
		tmp = resourcesValidator.intToBytes(numberOfHeapElements * heapElementSize,2);
		header[6] = tmp[0];
		header[7] = tmp[1];
		tmp = resourcesValidator.intToBytes(numberOfInstructions * programElementSize,2);
		header[8] = tmp[0];
		header[9] = tmp[1];
		tmp = resourcesValidator.getFeaturekeyAsByteArray();
		header[10] = tmp[0];
		header[11] = tmp[1];
		header[12] = tmp[2];
		header[13] = tmp[3];
		tmp = resourcesValidator.getValidationKeyAsByteArray();
		header[14] = tmp[0];
		header[15] = tmp[1];
		header[16] = tmp[2];
		header[17] = tmp[3];
		return header;
	}
	private List<Byte> createHeap(){
		List<Byte> bytes = new ArrayList<Byte>();
		for(HeapElement v: heap.getHeapElements()){
			if(v.getValue() != 0){
				numberOfHeapElements ++;
				bytes.add(resourcesValidator.intToBytes(v.getHeapAddress(), 1)[0]);
				for(Byte b: resourcesValidator.intToBytes(v.getValue(), 4)){
					bytes.add(b);
				}
			}
		}
		return bytes;
	} 
	
	private List<Byte> createProgram(){
		List<Byte> bytes = new ArrayList<Byte>();
		for(Instruction i: muInsts){
			int inst = (short) ((i.getId() << settings.MicroInstArgumentSize) | ((i.getArgument() != null ? i.getArgument() : 0) & ((1 << settings.MicroInstArgumentSize)-1 )));
			
			numberOfInstructions ++;
			for(Byte b: resourcesValidator.intToBytes(inst, 2)){
				bytes.add(b);
			}
		}
		return bytes;
	}
	
	
}
