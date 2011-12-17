package wlfr.util 
{
	public class wMath 
	{		
		public function wMath() 
		{
		}
		
		static public function mix(a:Number, b:Number, alpha:Number):Number {
			return a * (1.0 - alpha) + b * (alpha);
		}
	}
}