package game 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import wlfr.gfx.Model;
	import wlfr.Time;
	
	public class Game 
	{
		private var model:Model;
		private var tri_rotation:Number = 0.0;

		public function Game() 
		{
			model = new Model();
		}
		
		public function Init(context3D:Context3D):void
		{
			model.Init(context3D);
		}
		
		public function Update(time:Time):void
		{			
			tri_rotation += time.time_step * 90.0;
		}
		
		public function Draw(context3D:Context3D, time:Time ):void
		{			
			context3D.clear(Math.sin(time.time)*0.5+0.5, 0, 0, 1);
			
			var m:Matrix3D = new Matrix3D();
			m.appendRotation(tri_rotation, Vector3D.Z_AXIS);
			
			model.Draw(context3D, m);
		}
	}

}