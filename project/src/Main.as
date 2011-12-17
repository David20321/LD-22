package 
{
	import flash.system.System;
	import flash.system.ApplicationDomain;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.system.Capabilities;
	import wlfr.gfx.Model;
	import wlfr.Time;
	import wlfr.util.StringContainer;
	import wlfr.util.wMath;
	import game.Game;
	
	import com.adobe.utils.*;
	

	[SWF(width="640", height="480", frameRate="60", backgroundColor="#FFFFFF")]
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		private static const swf_width:int = 640;
		private static const swf_height:int = 480;

		private var graphics_info_str:String;
		private var titlescreenTf:TextField;
		private var context3D:Context3D;
		private var framerate:Number = 0.0;
		private var last_draw_time:int = 0;
		
		private var time:Time;
		private var the_game:Game;
		
		public function Main():void 
		{
			the_game = new Game();
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function initGUI():void {
			titlescreenTf = new TextField();
			titlescreenTf.width = 300;
			addChild(titlescreenTf);
		}
		
		// this error is fired if the swf is not using wmode=direct
		private function onStage3DError ( e:ErrorEvent ):void
		{
			trace("onStage3DError!");
			graphics_info_str = 'Embed Error Detected!'
			+'\nYour Flash 11 settings'
			+'\nhave hardware 3D turned OFF.'
			+'\nIs wmode=direct in the html?'
			+'\nExpect poor performance.';
		}
		
		private function Draw():void {
			if (last_draw_time != 0) {
				var elapsed:int = getTimer() - last_draw_time;
				if(elapsed != 0){
					var temp_framerate:Number = 1000 / elapsed;
					framerate = wMath.mix(temp_framerate, framerate, 0.9);
					titlescreenTf.text = graphics_info_str +"\nFPS: "+int(framerate).toString();
				}
			}
			last_draw_time = getTimer();
			
			if (!context3D) {
				return;
			}
			
			the_game.Draw(context3D, time);
			
			context3D.present();
		}
		
		private function Update():void {
			the_game.Update(time);
		}
		
		private function enterFrame(event:Event):void 
		{
			var num_steps:int = time.GetNumSteps();
			
			trace(num_steps);
			for (var i:int = 0; i < num_steps; ++i) {
				time.time += time.time_step; 
				Update();
			}
			
			Draw();
		}
		
		private function onContext3DCreate(event:Event):void
		{	
			// Based on example from Breakdance McFunkyPants blog
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME,enterFrame);
		 
			var cfg:GraphicsConfig = new GraphicsConfig(swf_width, swf_height, 4 /*msaa*/);
			var sc:StringContainer = new StringContainer();
			context3D = GraphicsSetup.SetUpContext(event.target as Stage3D, cfg, sc);
			graphics_info_str = sc.string;
			
		 	addEventListener(Event.ENTER_FRAME, enterFrame);
			
			time = new Time();
			the_game.Init(context3D);
		}

		private function init(e:Event = null):void 
		{
			graphics_info_str = new String("Test");
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
		 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// are we running Flash 11 with Stage3D available?
			var stage3DAvailable:Boolean =
			ApplicationDomain.currentDomain.hasDefinition
				("flash.display.Stage3D");
			if (stage3DAvailable)
			{
				stage.stage3Ds[0].addEventListener(
					Event.CONTEXT3D_CREATE, onContext3DCreate);
				// detect when the swf is not using wmode=direct
				stage.stage3Ds[0].addEventListener(
					ErrorEvent.ERROR, onStage3DError);
				// request hardware 3d mode now
				stage.stage3Ds[0].requestContext3D();
			}
			else
			{
				trace("stage3DAvailable is false!");
				graphics_info_str =
				'Flash 11 Required.\nYour version: '
				+ Capabilities.version
				+'\nThis game uses Stage3D.'
				+'\nPlease upgrade to Flash 11'
				+'\nso you can play 3d games!';
			}
			
			initGUI();
		}
	}
}

internal class GraphicsSetup 
{
	import flash.display.*;
	import flash.display3D.*;
	import flash.system.Capabilities;
	import wlfr.util.StringContainer;
	static function SetUpContext(t:Stage3D, cfg:GraphicsConfig, sc:StringContainer):Context3D {
		var context3D:Context3D = t.context3D;    
	 
		if (context3D == null)
		{
			trace('No context3D');
			return null;
		}
	 
		if ((context3D.driverInfo == Context3DRenderMode.SOFTWARE)
			|| (context3D.driverInfo.indexOf('oftware')>-1))
		{
			trace("Software mode detected!");
			sc.string = 'Software Rendering Detected!'
			+'\nYour Flash 11 settings'
			+'\nhave hardware 3D turned OFF.'
			+'\nIs wmode=direct in the html?'
			+'\nExpect poor performance.';
		}
		
		sc.string = 'Flash 11 Stage3D '
		+'(Molehill) is working perfectly!'
		+'\nFlash Version: '
		+ Capabilities.version
		+ '\n3D mode: ' + context3D.driverInfo;
	 
		context3D.enableErrorChecking = false;
		CONFIG::debug
		{
			context3D.enableErrorChecking = true;
		}
	 
		context3D.configureBackBuffer(cfg.width, cfg.height, cfg.msaa, true);
		return context3D;
	}
}

internal class GraphicsConfig
{
	public var width:int;
	public var height:int;
	public var msaa:int;
	
	public function GraphicsConfig(_width:int, _height:int, _msaa:int) {
		width = _width;
		height = _height;
		msaa = _msaa;
	}
}