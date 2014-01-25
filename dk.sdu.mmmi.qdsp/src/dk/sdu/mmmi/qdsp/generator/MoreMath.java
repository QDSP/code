package dk.sdu.mmmi.qdsp.generator;

public class MoreMath {

	public static int log2(int x)
	{
	    return (int) (Math.log(x) / Math.log(2));
	}
	
	public static boolean IsPowerOf2(int x)
	{
		int tmp = x;
		while(tmp%2 == 0 && tmp>1){
			tmp = tmp / 2;
		} 
		return tmp == 1;
	}
}
