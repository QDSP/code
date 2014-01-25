package dk.sdu.mmmi.qdsp.generator

import java.util.List
import dk.sdu.mmmi.qdsp.qDSP.Setting
import dk.sdu.mmmi.qdsp.qDSP.ProjectTitle
import dk.sdu.mmmi.qdsp.qDSP.HeapSize
import dk.sdu.mmmi.qdsp.qDSP.ProgramMemorySize
import dk.sdu.mmmi.qdsp.qDSP.RuntimeProgrammable
import dk.sdu.mmmi.qdsp.qDSP.AutoCommentQDSPCode
import dk.sdu.mmmi.qdsp.qDSP.ProgramingControlAddress
import dk.sdu.mmmi.qdsp.qDSP.ProgramingStatusAddress
import dk.sdu.mmmi.qdsp.qDSP.ProgramingDataInAddress
import dk.sdu.mmmi.qdsp.qDSP.ProgramingDataOutAddress
import dk.sdu.mmmi.qdsp.qDSP.EnableOptimization
import dk.sdu.mmmi.qdsp.qDSP.SHInterfaceType

class MySettings {
	public String 	projectName 				= "NewQdsp";
	public Integer 	HeapSize					= 32;
	public Integer	ProgramMemorySize			= 128;
	public boolean	RuntimeProgrammable 		= false;
	public boolean	CommentCode					= true;
	public Integer	ProgramingControlAddress	= 7;
	public Integer	ProgramingStatusAddress		= 0;
	public Integer	ProgramingDataInAddress		= 1;
	public Integer	ProgramingDataOutAddress	= 6;
	public Integer	MicroInstSize				= 5;
	public Integer	MicroInstArgumentSize		= 6;
	public boolean 	EnableOptimization			= true;
	public SHInterfaceTypes	shInterfaceType		= SHInterfaceTypes.Unity;
	
	
	public def loadSettings(List<Setting> settings){
		for(setting: settings){
			switch setting{
				ProjectTitle:{
					projectName = setting.^val;
				}
				HeapSize:{
					HeapSize = setting.^val;
				}
				ProgramMemorySize:{
					ProgramMemorySize = setting.^val;
				}
				RuntimeProgrammable:{
					RuntimeProgrammable = setting.^val;
				}
				AutoCommentQDSPCode:{
					CommentCode = setting.^val;
				}
				ProgramingControlAddress:{
					ProgramingControlAddress = setting.^val;
				}
				ProgramingStatusAddress:{
					ProgramingStatusAddress =  setting.^val;
				}
				ProgramingDataInAddress:{
					ProgramingDataInAddress = setting.^val;
				}
				ProgramingDataOutAddress:{
					ProgramingDataOutAddress = setting.^val;
				}
				EnableOptimization:{
					EnableOptimization = setting.^val;
				}
				SHInterfaceType:{
					if(setting.^val == "Unity-Link"){
						shInterfaceType = SHInterfaceTypes.Unity;
					} else if(setting.^val == "uTosNet") {
						shInterfaceType = SHInterfaceTypes.uTosNet;
					}
				}
			}
		}
	}
}