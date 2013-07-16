package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.TextArea;
	import flash.geom.Point;
	
	
	public class SeaBattle extends Sprite 
	{
		public const WIN_AI:String = "AI has won! Game Over!";
		public const WIN_HUMAN:String = "Human has won! Game Over!";
		
		public const SIZE_CELL:int = 15;
		
		public const INVALID:int = -1;
		public const EMPTY:int = 0;
		public const SHIP:int = 1;
		public const HIT:int = 2;
		public const MISS:int = 3;
		public const WIN:int = 4;
		public const LOSS:int = 5;
		public const RESERVED:int = 6;
		
		private var f1:Array = new Array(100);
		private var f2:Array = new Array(100);
		
		private var tf_debug:TextField = new TextField();
		private var b_reset:Sprite = new Sprite();
		
		private var ccell:Cell = null;
		
		private function i2x(index:int):int {
			return index%10;
		}
		
		private function i2y(index:int):int {
			return index/10;
		}
		
		private function xy2i(x:int, y:int):int {
			return x + 10*y;
		}
		
		public function get(f:Array, x:int, y:int):int {
			if(x>=0 && x<10 && y>=0 && y<10) {
				return f[xy2i(x,y)];
			} else {
				return INVALID;
			}
		}
		
		public function set(f:Array, x:int, y:int, value:int):void {
			if(x>=0 && x<10 && y>=0 && y<10) {
				f[xy2i(x,y)]=value;
			}
		}
		
		private function fit(f:Array, x:int, y:int, o:int, s:int):Boolean{
			//trace("fit: " + f + " | " + x + " | " + y + " | " + o + " | " + s);
			var i:int = -1;
			var j:int = -1;
			
			// check ship body
			for(i=0; i<s; i++) {
				if (o==0) {
					if (get(f, x+i, y) != EMPTY) {
						return false;
					}
				} else {
					if (get(f, x, y+i) != EMPTY) {
						return false;
					}
				}
			}
			
			// check surrounding
			for(i=-1; i<s+1; i++) {
				for (j=-1; j<=1; j++) {
					if (o==0) {
						if (get(f, x+i, y+j) != EMPTY && get(f, x+i, y+j) != RESERVED /*&& get(f, x+i, y+j) != INVALID*/) {
							return false;
						}
					} else {
						if (get(f, x+j, y+i) != EMPTY && get(f, x+j, y+i) != RESERVED /*&& get(f, x+j, y+i) != INVALID*/) {
							return false;
						}
					}
				}
			}
			
			return true;
		}
		
		private function place(f:Array, x:int, y:int, o:int, s:int):void{
			//trace("place: " + f + " | " + x + " | " + y + " | " + o + " | " + s);
			var i:int = -1;
			var j:int = -1;
			for(i=-1; i<s+1; i++) {
				for (j=-1; j<=1; j++) {
					(o==0) ? set(f, x+i, y+j, RESERVED) : set(f, x+j, y+i, RESERVED);
				}
			}
			
			for(i=0; i<s; i++) {
				(o==0) ? set(f, x+i, y, SHIP) : set(f, x, y+i, SHIP);
			}
		}
		
		private function unplace(f:Array, x:int, y:int, o:int, s:int):void{
			//trace("unplace: " + f + " | " + x + " | " + y + " | " + o + " | " + s);
			var i:int = -1;
			var j:int = -1;
			for(i=-1; i<s+1; i++) {
				for (j=-1; j<=1; j++) {
					(o==0) ? set(f, x+i, y+j, EMPTY) : set(f, x+j, y+i, EMPTY);
				}
			}
		}
		
		private function shuffle(array:Array): void {
			var i:int = array.length-1;
			for(i; i>0; i--) {
				var r:int = Math.floor(Math.random() * i);
				exchange(array, i, r);
			}
		}
		private function reset(array:Array): void {
			var i:int = array.length-1;
			for(i; i>=0; i--) {
				array[i] = 0;
			}
		}
		
		private function next_ship(f:Array, ships:Array):Boolean {
			//trace("next_ship: " + f + " | " + ships);
			if (ships.length == 0) {
				return true;
			} else {
				var mapEmpty:Function = function(item:int, index:int, array:Array):int{
					if (item == EMPTY) {
						return index;
					} else {
						return INVALID;
					}
				};
				var filterEmpty:Function = function(item:int, index:int, array:Array):Boolean{
					return item != INVALID;
				};
				var empty:Array = f.map(mapEmpty).filter(filterEmpty);
				shuffle(empty);
				
				var result:Boolean = false;
				var s:int = ships.pop();
				var i:int = 0;
				for (i; i<empty.length; i++) {
					var index:int = empty[i];
					var x:int = i2x(index);
					var y:int = i2y(index);
					var o:int = Math.floor(Math.random() * 2);	// random orientation
					if (fit(f, x, y, o, s)) {
						place(f, x, y, o, s);
						result = next_ship(f, ships);
						if (!result) {
							unplace(f, x, y, o, s);
							continue;
						} else {
							break;
						}
					} else {
						continue;
					}
				}
				
				ships.push(s);
				return result;
			}
		}
		
		private function pregen(f:Array): void {
			var ships:Array = new Array(1, 1, 1, 1, 2, 2, 2, 3, 3, 4);
			//var ships:Array = new Array(3, 4);
			//var ships:Array = new Array(1);
			//ships[0] = 4;
			var result:Boolean = next_ship(f, ships);
		}
		
		private function preseed(f:Array):void {
			f[0]=SHIP;
			f[1]=SHIP;
			f[2]=SHIP;
			f[3]=SHIP;
			
			f[5]=SHIP;
			f[6]=SHIP;
			f[7]=SHIP;
			
			f[9]=SHIP;
			
			f[20]=SHIP;
			f[21]=SHIP;
			f[22]=SHIP;
			
			f[24]=SHIP;
			f[25]=SHIP;
			
			f[27]=SHIP;
			f[28]=SHIP;
			
			f[40]=SHIP;
			f[41]=SHIP;
			
			f[43]=SHIP;
			
			f[45]=SHIP;
			
			f[47]=SHIP;
		}
		
		
		public function SeaBattle() {
			restart(null);
		}
		
		public function restart(event:MouseEvent): void {
			f1 = new Array(100);
			f2 = new Array(100);
			pregen(f1);
			pregen(f2);
			repaint();
		}
		
		private function has_lost(f:Array):Boolean {
			return f.indexOf(SHIP) == -1;
		}
		
		private function game_over(): Boolean {
			return ( has_lost(f1) || has_lost(f2) );
		}
		
		private function clean():void {
			removeChildren();
		}
		
		private function repaint():void {
			clean();
			drawFieldAt(f1, 0, 0, true);
			drawFieldAt(f2, SIZE_CELL * 11, 0, false);
			drawButtons();
			drawDebug();
		}
		
		private function trace(message: String):void {
			tf_debug.appendText("\n- "+message);
		}
		
		private function drawButtons():void {
			var textLabel:TextField = new TextField();
			textLabel.text = "Restart";
			textLabel.x = 22 * SIZE_CELL;
			textLabel.y = SIZE_CELL;
			textLabel.selectable = false;
			
			b_reset.graphics.clear();
			b_reset.graphics.beginFill(0xD4D4D4); // grey color
			b_reset.graphics.drawRoundRect(22 * SIZE_CELL, SIZE_CELL, 3 * SIZE_CELL, SIZE_CELL, 10, 10); // x, y, width, height, ellipseW, ellipseH
			b_reset.graphics.endFill();
			b_reset.addChild(textLabel);
			
			b_reset.addEventListener(MouseEvent.CLICK, restart);
			
			addChild(b_reset);
		}
		
		private function drawDebug():void {
			tf_debug.x = 0;
			tf_debug.y = 11 * SIZE_CELL;
			tf_debug.width = 21 * SIZE_CELL; 
			tf_debug.height = 100; 
			tf_debug.multiline = true; 
			tf_debug.wordWrap = true; 
			tf_debug.background = true; 
			tf_debug.border = true; 
			tf_debug.scrollV = tf_debug.numLines;
			
			var format:TextFormat = new TextFormat(); 
			format.font = "Console New"; 
			format.color = 0xFF0000; 
			format.size = 8; 
			
			tf_debug.defaultTextFormat = format; 
			addChild(tf_debug); 
			tf_debug.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownScroll);
			tf_debug.addEventListener(MouseEvent.MOUSE_UP, mouseUpScroll);
		} 
		
		public function mouseDownScroll(event:MouseEvent):void 
		{ 
			tf_debug.scrollV++; 
		}
		
		public function mouseUpScroll(event:MouseEvent):void 
		{
			tf_debug.scrollV--; 
		}
		
		
		private function drawFieldCellAtWithOffset(value:int, i:int, j:int, x:int, y:int, fog:Boolean):void {
			var color:uint = 0xffffff;
			switch(value) {
				case EMPTY: color = 0xffffff; break;
				case SHIP: color = fog? 0xffffff : 0x888888; break;
				case HIT: color = 0xff0000; break;
				case MISS: color = 0x00aa00; break;
				case RESERVED: color = fog? 0xffffff : 0xADD8E6; break;
				default: color = 0x000000;
			}
			
			var linecolor:uint = 0x000000;
			if(ccell != null && ccell.i == i && ccell.j ==j ) {
				linecolor = 0xff0000;
			}
			
			var rect:Cell = new Cell();
			rect.field = f1;
			rect.i = i;
			rect.j = j;
			rect.x = x + j*SIZE_CELL;
			rect.y = y + i*SIZE_CELL;
			
			var g:Graphics = rect.graphics;
			g.lineStyle(1, linecolor);
			g.beginFill(color);
			g.drawRect(0, 0, SIZE_CELL, SIZE_CELL);
			
			rect.addEventListener(MouseEvent.CLICK, fireHuman);
			
			addChild(rect);
		}
		
		private function fireHuman(event:MouseEvent):void {
			//trace("fireHuman: " + arguments);
			var children:Array = getObjectsUnderPoint(new Point(event.stageX, event.stageY));
			//trace("fireHuman: " + children);
			//trace("fireHuman: " + has_lost(f1) + "," + has_lost(f2));
			if(!game_over() && children != null && children.length > 0) {
				try {
					var cell:Cell = Cell(children[0]);
					var index:int = cell.i*10 + cell.j;
					var cvalue:int = cell.field[index];
					var result:int;
					
					//trace("fireHuman: cvalue = " + cvalue);
					
					switch(cvalue) {
						case EMPTY: cell.field[index] = MISS; result = MISS; break;
						case RESERVED: cell.field[index] = MISS; result = MISS; break;
						case SHIP: cell.field[index] = HIT; result = HIT; evaluateShot2(cell.field, index, HIT); break;
						default: break;
					}
					
					if(game_over()) {
						trace(WIN_HUMAN);
					}
					
					repaint();
					
					if (result == MISS) {
						turnAI();
					}
					
				} catch (e:Error) {
					//trace(children + " didn't contain a Cell");
				}
			}
		}
		
		private function updateCell1(field:Array, x:int, y:int, value:int): void {
			if(x>=0 && x<10 && y>=0 && y<10) {
				field[x*10 + y] = value;
			}
		}
		
		private function updateCell2(field:Array, index:int, value:int): void {
			var x:int = index / 10;
			var y:int = index % 10;
			updateCell1(field, x, y, value);
		}
		
		private function evaluateShot2(field:Array, index:int, value:int):void {
			updateCell2(field, index, value);
			if (value == HIT) {
				updateCell2(field, index-11, MISS);
				updateCell2(field, index+11, MISS);
				updateCell2(field, index-9, MISS);
				updateCell2(field, index+9, MISS);
			}
		}
		
		private function computeNearbyHits(field:Array, index:int):int {
			var result:int = 0;
			if(index-1 >= 0 && index-1 < 100 && field[index-1] == HIT) {result = result + 1;}
			if(index+1 >= 0 && index+1 < 100 && field[index+1] == HIT) {result = result + 1;}
			if(index-10 >= 0 && index-10 < 100 && field[index-10] == HIT) {result = result + 1;}
			if(index+10 >= 0 && index+10 < 100 && field[index+10] == HIT) {result = result + 1;}
			return result;
		}
		
		private function exchange(array:Array, i:int, j:int) :void {
			var t:int = array[j];
			array[j] = array[i];
			array[i] = t;
		}
		
		private function computeWeights(field:Array, unknown:Array): Array {
			var i:int = 0;
			var weights:Array = new Array(unknown.length);
			for (i=0; i<unknown.length; i++) {
				weights[i] = computeNearbyHits(field, unknown[i]);
			}
			return weights;
		}
		
		private function sortByNearbyHits(field:Array, unknown:Array, weights:Array):void {
			var i:int = 0;
			var j:int = 0;
			for (i=0; i<unknown.length; i++) {
				for(j=i; j<unknown.length; j++) {
					if(weights[i] < weights[j]) {
						exchange(unknown, i, j);
						exchange(unknown, i, j);
					}
				}
			}
		}
		
		private function fireAI():int {
			var mapUnknown:Function = function(item:int, index:int, array:Array):int{
				if (item != HIT && item != MISS) {
					return index;
				} else {
					return INVALID;
				}
			};
			var filterUnknown:Function = function(item:int, index:int, array:Array):Boolean{
				return item != INVALID;
			};
			var unknown:Array = f2.map(mapUnknown).filter(filterUnknown);
			var weights:Array = computeWeights(f2, unknown);
			var maxWeight:int = -1;
			var i:int = 0;
			for(i=0; i<weights.length; i++) {if (maxWeight < weights[i]) maxWeight = weights[i]; }
			
			var result:int = -1;
			
			if (unknown.length == 0) {
				trace(WIN_AI);
				result = LOSS;
			} else {
				
				var filterInefficient:Function = function(item:int, index:int, array:Array): Boolean{
					return (computeNearbyHits(f2, item) == maxWeight);
				}
				
				var unknown2:Array = unknown.filter(filterInefficient);
				var unknownIndex:int = Math.floor(Math.random() * unknown2.length);
				var f2Index:int = unknown2[unknownIndex];
				
				result = (f2[f2Index] == SHIP)? HIT : MISS;
				
				evaluateShot2(f2, f2Index, result);
			}
			
			repaint();
			
			return result;
		}
		
		private function turnAI():void {
			while(!game_over() && fireAI() == HIT) {
				continue;
			}
			
			if(game_over()) {
				trace(WIN_AI);
			}
		}
		
		private function drawFieldAt(field:Array, x:int, y:int, fog:Boolean):void {
			var i:int = 0;
			var j:int = 0;
			
			for(i=0; i<10; i++) {
				for(j=0; j<10; j++) {
					drawFieldCellAtWithOffset(field[i*10+j], i, j, x, y, fog);
				}
			}
		}
	}
}

import flash.display.Sprite;

class Cell extends Sprite {
	public var field:Array;
	public var i:int;
	public var j:int;
	
	public function Cell() {
		super();
	}
}


