package wlfr
{
	public class Keyboard 
	{
		private var keys:Array;
		private var key_pressed:Array;
		internal var _lookup:Object;
		internal var _map:Array;
		internal const _total:uint = 256;
		
		public function Keyboard() 
		{
			_lookup = new Object();
			_map = new Array(_total);
			keys = new Array();
			key_pressed = new Array();
			SetKeyShortcuts();
		}	
		
		public function IsKeyDown(key:uint):Boolean {
			if (keys[key]) {
				return true;
			} else {
				return false;
			}
		}
		
		public function WasKeyPressedThisStep(key:uint):Boolean {
			if (key_pressed[key]) {
				return true;
			} else {
				return false;
			}
		}
		
		public function Update():void {
			for (var i:uint = 0; i < key_pressed.length; ++i) {
				key_pressed[i] = false;
			}
		}
		
		public function SetKeyDown(key:uint):void {
			if(!keys[key]){
				key_pressed[key] = true;
			}
			keys[key] = true;
		}
		
		public function SetKeyUp(key:uint):void {
			keys[key] = false;
		}	
		
		public function GetKeyCode(key:String):uint
		{
			var lcase:String = key.toLowerCase();
			return _lookup[lcase];
		}
		
		protected function addKey(KeyName:String,KeyCode:uint):void
		{
			var lcase:String = KeyName.toLowerCase();
			_lookup[lcase] = KeyCode;
			_map[KeyCode] = { name: lcase, current: 0, last: 0 };
		}
		
		protected function SetKeyShortcuts():void {
			// Stolen from Flixel
			
			var i:uint;
			
			//LETTERS
			i = 65;
			while(i <= 90)
				addKey(String.fromCharCode(i),i++);
			
			//NUMBERS
			i = 48;
			addKey("ZERO",i++);
			addKey("ONE",i++);
			addKey("TWO",i++);
			addKey("THREE",i++);
			addKey("FOUR",i++);
			addKey("FIVE",i++);
			addKey("SIX",i++);
			addKey("SEVEN",i++);
			addKey("EIGHT",i++);
			addKey("NINE",i++);
			i = 96;
			addKey("NUMPADZERO",i++);
			addKey("NUMPADONE",i++);
			addKey("NUMPADTWO",i++);
			addKey("NUMPADTHREE",i++);
			addKey("NUMPADFOUR",i++);
			addKey("NUMPADFIVE",i++);
			addKey("NUMPADSIX",i++);
			addKey("NUMPADSEVEN",i++);
			addKey("NUMPADEIGHT",i++);
			addKey("NUMPADNINE",i++);
			addKey("PAGEUP", 33);
			addKey("PAGEDOWN", 34);
			addKey("HOME", 36);
			addKey("END", 35);
			addKey("INSERT", 45);
			
			//FUNCTION KEYS
			i = 1;
			while(i <= 12)
				addKey("F"+i,111+(i++));
			
			//SPECIAL KEYS + PUNCTUATION
			addKey("ESCAPE",27);
			addKey("MINUS",189);
			addKey("NUMPADMINUS",109);
			addKey("PLUS",187);
			addKey("NUMPADPLUS",107);
			addKey("DELETE",46);
			addKey("BACKSPACE",8);
			addKey("LBRACKET",219);
			addKey("RBRACKET",221);
			addKey("BACKSLASH",220);
			addKey("CAPSLOCK",20);
			addKey("SEMICOLON",186);
			addKey("QUOTE",222);
			addKey("ENTER",13);
			addKey("SHIFT",16);
			addKey("COMMA",188);
			addKey("PERIOD",190);
			addKey("NUMPADPERIOD",110);
			addKey("SLASH",191);
			addKey("NUMPADSLASH",191);
			addKey("CONTROL",17);
			addKey("ALT",18);
			addKey("SPACE",32);
			addKey("UP",38);
			addKey("DOWN",40);
			addKey("LEFT",37);
			addKey("RIGHT",39);
			addKey("TAB",9);
		}
	}
}