package dk.sdu.mmmi.qdsp.generator;

import java.nio.ByteBuffer;

import dk.sdu.mmmi.qdsp.structural.elements.instruction.ADDInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BDIVInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BMULInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BREInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRGInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.BRLInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAHInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CAIInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CASInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CHAInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CIAInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CMPInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.CSAInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.JMPInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.LSHInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MAXInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MINInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.MULInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSHInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.RSTInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.SUBInstruction;
import dk.sdu.mmmi.qdsp.structural.elements.instruction.TRNInstruction;

public class ResourcesValidator {

	QDSPGenerator generator;
	
	public ResourcesValidator(QDSPGenerator generator) {
		this.generator = generator;
	}
	
	private int generateFeaturekey(){
		int validation = 0;
		
		
		validation = (validation | generator.isUsed(CAHInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CHAInstruction.class)) << 1;
		validation = (validation | generator.isUsed(RSTInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CASInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CSAInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CAIInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CIAInstruction.class)) << 1;
		validation = (validation | generator.isUsed(ADDInstruction.class)) << 1;
		validation = (validation | generator.isUsed(SUBInstruction.class)) << 1;
		validation = (validation | generator.isUsed(BDIVInstruction.class)) << 1;
		validation = (validation | generator.isUsed(BMULInstruction.class)) << 1;
		validation = (validation | generator.isUsed(MULInstruction.class)) << 1;
		validation = (validation | generator.isUsed(TRNInstruction.class)) << 1;
		validation = (validation | generator.isUsed(MAXInstruction.class)) << 1;
		validation = (validation | generator.isUsed(MINInstruction.class)) << 1;
		validation = (validation | generator.isUsed(LSHInstruction.class)) << 1;
		validation = (validation | generator.isUsed(RSHInstruction.class)) << 1;
		validation = (validation | generator.isUsed(JMPInstruction.class)) << 1;
		validation = (validation | generator.isUsed(BREInstruction.class)) << 1;
		validation = (validation | generator.isUsed(BRGInstruction.class)) << 1;
		validation = (validation | generator.isUsed(BRLInstruction.class)) << 1;
		validation = (validation | generator.isUsed(CMPInstruction.class));
		return validation;
	}
	private int generateValidationkey(){
		int validation = 0;
		validation |= generator.getHeapSize() << 16;
		validation |= generator.getProgramMemorySize() & ((1 << 16) - 1);
		return validation;
	}
	
	public byte[] getValidationKeyAsByteArray(){
		return intToBytes(generateValidationkey(), 4);
	}
	public byte[] getFeaturekeyAsByteArray(){
		return intToBytes(generateFeaturekey(), 4);
	}
	public String getValidationkeyAsString(){
		String binarized = Integer.toBinaryString(generateValidationkey());
		int len = binarized.length();
		String zeroes = "00000000000000000000000000000000";
		if (len < 32)
		  binarized = zeroes.substring(0, 32-len).concat(binarized);
		else
		  binarized = binarized.substring(len - 32);
		return binarized;
	}
	public String getFeaturekeyAsString(){
		String binarized = Integer.toBinaryString(generateFeaturekey());
		int len = binarized.length();
		String zeroes = "0000000000000000000000";
		if (len < 22)
		  binarized = zeroes.substring(0, 22-len).concat(binarized);
		else
		  binarized = binarized.substring(len - 22);
		return binarized;
	}
	
	public byte[] intToBytes(int number, int bytes){
		if(bytes == 1){
			return ByteBuffer.allocate(bytes).put((byte)number).array();
		} else if(bytes == 2){
			return ByteBuffer.allocate(bytes).putShort((short)number).array();
		} else if(bytes == 4){
			return ByteBuffer.allocate(bytes).putInt(number).array();
		}
		return null;
		
	}
}
