package dk.sdu.mmmi.qdsp.generator

import org.eclipse.xtext.diagnostics.Diagnostic

class MyDiagnostic implements Diagnostic{
	
	override getLength() {
		10;
	}
	
	override getOffset() {
		20
	}
	
	override getColumn() {
		30
	}
	
	override getLine() {
		40
	}
	
	override getLocation() {
		"Location"
	}
	
	override getMessage() {
		"Message"
	}
	
}