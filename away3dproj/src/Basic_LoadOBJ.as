/*

OBJ file loading example in Away3d

Demonstrates:

How to use the AssetLibrary to load an internal OBJ model.
How to set custom material methods on a model.
How a natural skin texture can be achived with sub-surface diffuse shading and fresnel specular shading.

Code by Rob Bateman & David Lenaerts
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
david.lenaerts@gmail.com
http://www.derschmale.com

Model by Lee Perry-Smith, based on a work at triplegangers.com,  licensed under CC

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package
{
	import away3d.cameras.*;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.debug.*;
	import away3d.entities.Mesh;
	import away3d.events.*;
	import away3d.library.*;
	import away3d.library.assets.*;
	import away3d.loaders.*;
	import away3d.loaders.misc.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.methods.*;
	import away3d.primitives.WireframeAxesGrid;
	import away3d.primitives.WireframeGrid;
	import away3d.tools.Grid;
	import flash.geom.Matrix3D;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import mx.core.SoundAsset;
	import wlfr.Keyboard;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import net.flashpunk.Sfx;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	
	public class Basic_LoadOBJ extends Sprite
	{		
		//Infinite, 3D head model
		[Embed(source="/../embeds/turner.obj", mimeType="application/octet-stream")]
		private var HeadModel : Class;
		
		[Embed(source = "/../embeds/IGF_Turner_color.jpg")]
		private var Diffuse : Class;
		
		[Embed (source = "../embeds/shot.mp3")]
		private var shot_sound_file : Class;
				
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
				
		//material objects
		private var headMaterial:BitmapMaterial;
		private var subsurfaceMethod:SubsurfaceScatteringDiffuseMethod;
		private var fresnelMethod:FresnelSpecularMethod;
		private var diffuseMethod:BasicDiffuseMethod;
		private var specularMethod:BasicSpecularMethod;
		
		//scene objects
		private var direction:Vector3D;
		private var headModel:Mesh;
		
		//navigation variables
		private var move:Boolean = false;
		private var pan_angle:Number = 0.0;
		private var tilt_angle:Number = 0.0;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var mouse_x:Number;
		private var mouse_y:Number;
		private var tf:TextField;
		private var keyboard:Keyboard;
		private var grid:WireframeGrid;
		private var shoot_sfx:Sfx;
		
		/**
		 * Constructor
		 */
		public function Basic_LoadOBJ()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		private function OnSoundComplete(e:Event) {
		
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			scene = new Scene3D();
			grid = new WireframeGrid(10,10);
			scene.addChild(grid);
			
			camera = new Camera3D();
			camera.moveTo(2, 2, 2);
			camera.lens.near = 0.1;
			camera.lens.far = 100.0;
			
			view = new View3D();
			view.antiAlias = 4;
			view.scene = scene;
			view.camera = camera;
			view.backgroundColor = 0x333333;
			
			//view.addSourceURL("srcview/index.html");
			addChild(view);
			
			addChild(new AwayStats(view));
			
			tf = new TextField();
			tf.textColor = 0xFFFFFF;
			tf.y = 100;
			tf.width = 200;
			addChild(tf);
			
			shoot_sfx = new Sfx(shot_sound_file);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			headMaterial = new BitmapMaterial(new Diffuse().bitmapData);
			headMaterial.ambientColor = 0xFFFFFF;
			headMaterial.ambient = 1;
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//default available parsers to all
			Parsers.enableAllBundled()
			
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.loadData(new HeadModel());
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			keyboard = new Keyboard();
		 	stage.addEventListener(KeyboardEvent.KEY_DOWN, ReportKeyDown);
		 	stage.addEventListener(KeyboardEvent.KEY_UP, ReportKeyUp);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				pan_angle = 0.3 * (mouse_x - lastMouseX) + lastPanAngle;
				tilt_angle = 0.3 * (mouse_y - lastMouseY) + lastTiltAngle;
			}
			tf.text = "Mouse: " + mouse_x + "   " + mouse_y + 
				   "\nLast mouse: " + lastMouseX + "   " + lastMouseY + 
				   "\nMove: " + move;
			
			
			var vec:Vector3D = new Vector3D(0,0,2);
			var mat:Matrix3D = new Matrix3D();
			mat.appendRotation(tilt_angle, new Vector3D(-1, 0, 0));
			mat.appendRotation(pan_angle, new Vector3D(0, 1, 0));
			vec = mat.transformVector(vec);
			view.camera.moveTo(vec.x, vec.y+1.0, vec.z);
			view.camera.lookAt(new Vector3D(0, 1.0, 0));
			
			if (keyboard.WasKeyPressedThisStep(keyboard.GetKeyCode("d"))) {
				shoot_sfx.play();
			}
			
			view.render();
			
			keyboard.Update();
		}
		
		private function ReportKeyDown(e:KeyboardEvent):void 
		{
			keyboard.SetKeyDown(e.keyCode);
		}
		
		private function ReportKeyUp(e:KeyboardEvent):void 
		{
			keyboard.SetKeyUp(e.keyCode);
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH) {
				headModel = event.asset as Mesh;
				headModel.material = headMaterial;
				
				scene.addChild(headModel);
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			lastPanAngle = pan_angle;
			lastTiltAngle = tilt_angle;
			lastMouseX = mouse_x;
			lastMouseY = mouse_y;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		
		private function onMouseMove(event:MouseEvent):void
		{
			mouse_x = event.stageX;
			mouse_y = event.stageY;
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Key up listener for swapping between standard diffuse & specular shading, and sub-surface diffuse shading with fresnel specular shading
		 */
		private function onKeyUp(event : KeyboardEvent) : void
		{
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
		}
	}
}