package wlfr 
{
	import flash.utils.getTimer;
	
	public class Time 
	{
		public const time_step:Number = 1.0 / 60.0;
		public var time:Number = 0.0;
		
		private const step_size:int = 1000/60;
		private var last_time:int = 0;
		
		public function Time() 
		{}
		
		public function GetNumSteps():int {
			var cur_time:int = getTimer();
			var num_steps:int = 0;
			
			if (last_time == 0) {
				num_steps = 1;
				last_time = cur_time;
			} else while (last_time + step_size < cur_time) {
				++num_steps;
				last_time += step_size;
			}
			num_steps = Math.min(5, num_steps);
			
			return num_steps;
		}
		
	}

}