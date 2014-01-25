package dk.sdu.mmmi.qdsp.generator

import dk.sdu.mmmi.qdsp.qDSP.impl.AddressImpl

class AddressItem extends AddressImpl{
		
	new(){
		super();
	}
	new(String chanel, int address){
		super()
		this.chanel = chanel;
		this.address = address;
	}
	
}