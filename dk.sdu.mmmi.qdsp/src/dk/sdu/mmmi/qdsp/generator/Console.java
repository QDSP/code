package dk.sdu.mmmi.qdsp.generator;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;


public class Console {
	private static MessageConsoleStream out;

	private static Color red = new Color(Display.getCurrent(),255, 0, 0 );
	private static Color yellow = new Color(Display.getCurrent(),255, 153, 0 );
	private static Color blue = new Color(Display.getCurrent(),0, 0, 255 );
	
	private static MessageConsole findConsole(String name) {
	      ConsolePlugin plugin = ConsolePlugin.getDefault();
	      IConsoleManager conMan = plugin.getConsoleManager();
	      IConsole[] existing = conMan.getConsoles();
	      for (int i = 0; i < existing.length; i++)
	         if (name.equals(existing[i].getName()))
	            return (MessageConsole) existing[i];
	      //no console found, so create a new one
	      MessageConsole myConsole = new MessageConsole(name, null);
	      conMan.addConsoles(new IConsole[]{myConsole});
	      return myConsole;
	   }

	private static MessageConsoleStream getMessageStream() {
		  MessageConsole myConsole = findConsole("QDSP Generator");
		  return myConsole.newMessageStream();
		}
	
	public static void println(String msg){
		out = getMessageStream();
		out.println(msg);
	}
	

	public static void printError(String msg){
		out = getMessageStream();
		out.setColor(red);
		out.print("ERROR:\t\t");
		out.println(msg);

	}
	public static void printWarning(String msg){
		out = getMessageStream();
		out.setColor(yellow);
		out.print("WARNING:\t");
		out.println(msg);
	}
	public static void printInfo(String msg){
		out = getMessageStream();
		out.setColor(blue);
		out.print("Info:\t\t");
		out.println(msg);
	}
}
