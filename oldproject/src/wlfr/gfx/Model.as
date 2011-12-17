package wlfr.gfx 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	public class Model 
	{	
		private var vertex_buffer:VertexBuffer3D;
		private var index_buffer:IndexBuffer3D;
		private var program:Program3D;
		
		public function Model() 
		{			
		}
		
		public function Init(context3D:Context3D):void {
			var vertices:Vector.<Number> = Vector.<Number>([
			-0.3,-0.3, 0, 	1, 0, 0, // x, y, z, r, g, b
			-0.3, 0.3, 0, 	0, 1, 0,
			 0.3, 0.3, 0, 	0, 0, 1]);
			
			vertex_buffer = context3D.createVertexBuffer(3, 6);
			vertex_buffer.uploadFromVector(vertices, 0, 3);	
			
			var indices:Vector.<uint> = Vector.<uint>([0, 1, 2]);
			index_buffer = context3D.createIndexBuffer(3);			
			index_buffer.uploadFromVector (indices, 0, 3);	
						
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
		
		public function Draw(context3D:Context3D, m:Matrix3D):void {
			context3D.setVertexBufferAt (0, vertex_buffer, 0, 	Context3DVertexBufferFormat.FLOAT_3);
			context3D.setVertexBufferAt(1, vertex_buffer, 3, 	Context3DVertexBufferFormat.FLOAT_3);
			context3D.setProgram(program);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			context3D.drawTriangles(index_buffer);
		}
	}

}