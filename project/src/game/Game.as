package game 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import wlfr.gfx.Model;
	import wlfr.Time;
	import wlfr.Keyboard;
	
	public class Game 
	{
		public var keys:Keyboard;
		public var context3D:Context3D;
		public var time:Time;
		
		private var model:Model;
		private var tri_rotation:Number = 0.0;

		public function Game(_keys:Keyboard, _time:Time, _context3D:Context3D) 
		{
			keys = _keys;
			time = _time;
			context3D = _context3D;
			
			model = new Model();
		}
		
		public function Init():void
		{
			model.Init(context3D);
		}
		
		public function Update():void
		{			
			if(keys.IsKeyDown(keys.GetKeyCode("a"))){
				tri_rotation += time.time_step * 90.0;
			}		
			if(keys.IsKeyDown(keys.GetKeyCode("d"))){
				tri_rotation -= time.time_step * 90.0;
			}
		}
		
		public function Draw():void
		{			
			context3D.clear(Math.sin(time.time)*0.5+0.5, 0, 0, 1);
			
			var m:Matrix3D = new Matrix3D();
			m.appendRotation(tri_rotation, Vector3D.Z_AXIS);
			
			model.Draw(context3D, m);
		}
	}

}