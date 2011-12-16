package 
{
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.system.ApplicationDomain;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.text.*;
	import com.adobe.utils.*;

	[SWF(width="640", height="480", frameRate="60", backgroundColor="#FFFFFF")]
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		private var titlescreenTf:TextField;
		private var fps_textfield:TextField;
		private var context3D:Context3D;
		private const swf_width:int = 640;
		private const swf_height:int = 480;
		private const step_size:int = 1000/60;
		private const time_step:Number = 1.0/60.0;
		private var vertex_buffer:VertexBuffer3D;
		private var index_buffer:IndexBuffer3D;
		private var program:Program3D;
		private var last_time:int;
		private var tri_rotation:Number = 0.0;
		private var framerate:Number = 0.0;
		private var last_draw_time:int = 0;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function initGUI():void {
			titlescreenTf = new TextField();
			titlescreenTf.width = 300;
			addChild(titlescreenTf);
			
			fps_textfield = new TextField();
			fps_textfield.width = 300;
			addChild(titlescreenTf);
		}
		
		// this error is fired if the swf is not using wmode=direct
		private function onStage3DError ( e:ErrorEvent ):void
		{
			trace("onStage3DError!");
			titlescreenTf.text = 'Embed Error Detected!'
			+'\nYour Flash 11 settings'
			+'\nhave hardware 3D turned OFF.'
			+'\nIs wmode=direct in the html?'
			+'\nExpect poor performance.';
		}
		
		public function mix(a:Number, b:Number, alpha:Number):Number {
			return a * (1.0 - alpha) + b * (alpha);
		}
		
		private function Draw():void {
			if (last_draw_time != 0) {
				var elapsed:int = getTimer() - last_draw_time;
				var temp_framerate:Number = 1000 / elapsed;
				framerate = mix(temp_framerate, framerate, 0.9);
				fps_textfield.text = framerate.toString();
			}
			last_draw_time = getTimer();
			
			if (!context3D) {
				return;
			}
			context3D.clear(Math.sin(getTimer()*0.001)*0.5+0.5, 0, 0, 1);
			
			// vertex position to attribute register 0
			context3D.setVertexBufferAt (0, vertex_buffer, 0, 	Context3DVertexBufferFormat.FLOAT_3);
			// color to attribute register 1
			context3D.setVertexBufferAt(1, vertex_buffer, 3, 	Context3DVertexBufferFormat.FLOAT_3);
			// assign shader program
			context3D.setProgram(program);

			var m:Matrix3D = new Matrix3D();
			m.appendRotation(tri_rotation, Vector3D.Z_AXIS);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			context3D.drawTriangles(index_buffer);
			
			context3D.present();
		}
		
		private function Update():void {
			tri_rotation += time_step * 90.0;
		}
		
		private function enterFrame(event:Event):void 
		{
			var cur_time:int = getTimer();
			var num_steps:int = 0;

			if (last_time == 0) {
				num_steps = 1;
				last_time = cur_time;
			} else while (last_time + step_size < cur_time) {
				++num_steps;
				last_time += step_size;
				break;
			}
			num_steps = Math.min(5, num_steps);
			
			for (var i:int = 0; i < num_steps; ++i) {
				Update();
			}
			
			Draw();
		}
		
		private function initData():void 
		{
			var vertices:Vector.<Number> = Vector.<Number>([
			-0.3,-0.3, 0, 	1, 0, 0, // x, y, z, r, g, b
			-0.3, 0.3, 0, 	0, 1, 0,
			 0.3, 0.3, 0, 	0, 0, 1]);
			
			// Create VertexBuffer3D. 3 vertices, of 6 Numbers each
			vertex_buffer = context3D.createVertexBuffer(3, 6);
			// Upload VertexBuffer3D to GPU. Offset 0, 3 vertices
			vertex_buffer.uploadFromVector(vertices, 0, 3);	
			
			var indices:Vector.<uint> = Vector.<uint>([0, 1, 2]);
			// Create IndexBuffer3D. Total of 3 indices. 1 triangle of 3 vertices
			index_buffer = context3D.createIndexBuffer(3);			
			// Upload IndexBuffer3D to GPU. Offset 0, count 3
			index_buffer.uploadFromVector (indices, 0, 3);	
		}
		
		private function initShaders():void 
		{
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + // pos to clipspace
				"mov v0, va1" // copy color
			);			

			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
			
				"mov oc, v0 "
			);

			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
	
		private function onContext3DCreate(event:Event):void
		{
			// Remove existing frame handler. Note that a context
			// loss can occur at any time which will force you
			// to recreate all objects we create here.
			// A context loss occurs for instance if you hit
			// CTRL-ALT-DELETE on Windows.
			// It takes a while before a new context is available
			// hence removing the enterFrame handler is important!
		 
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME,enterFrame);
		 
			// Obtain the current context
			var t:Stage3D = event.target as Stage3D;
			context3D = t.context3D;    
		 
			if (context3D == null)
			{
				// Currently no 3d context is available (error!)
				trace('ERROR: no context3D - video driver problem?');
				return;
			}
		 
			// detect software mode (html might not have wmode=direct)
			if ((context3D.driverInfo == Context3DRenderMode.SOFTWARE)
				|| (context3D.driverInfo.indexOf('oftware')>-1))
			{
				//Context3DRenderMode.AUTO
				trace("Software mode detected!");
				titlescreenTf.text = 'Software Rendering Detected!'
				+'\nYour Flash 11 settings'
				+'\nhave hardware 3D turned OFF.'
				+'\nIs wmode=direct in the html?'
				+'\nExpect poor performance.';
			}
			// if this is too big, it changes the stage size!
			titlescreenTf.text = 'Flash 11 Stage3D '
			+'(Molehill) is working perfectly!'
			+'\nFlash Version: '
			+ Capabilities.version
			+ '\n3D mode: ' + context3D.driverInfo;
		 
			// Disabling error checking will drastically improve performance.
			// If set to true, Flash sends helpful error messages regarding
			// AGAL compilation errors, uninitialized program constants, etc.
			context3D.enableErrorChecking = false;
			CONFIG::debug
			{
				context3D.enableErrorChecking = true; // v2
			}
		 
			var msaa:int = 4;
			
			// The 3d back buffer size is in pixels
			context3D.configureBackBuffer(swf_width, swf_height, msaa, true);
		 
			// Initialize our mesh data
			initData();
		 
			// assemble all the shaders we need
			initShaders();
		 
			// start animating
			addEventListener(Event.ENTER_FRAME,enterFrame);
		}

		private function init(e:Event = null):void 
		{
			last_time = 0;
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
		 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		 
			// add some text labels
			initGUI();
			
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
				titlescreenTf.text =
				'Flash 11 Required.\nYour version: '
				+ Capabilities.version
				+'\nThis game uses Stage3D.'
				+'\nPlease upgrade to Flash 11'
				+'\nso you can play 3d games!';
			}
		}

	}

}