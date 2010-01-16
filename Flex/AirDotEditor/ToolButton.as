//author Show=O=Healer

/*
*/


package{
	//
	import flash.display.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class ToolButton extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 32;
		static public const SIZE_H:int = 32;

		//＃ツールの種類
		//
		static public const TOOL_PEN:int	= 0;
		//
		static public const TOOL_SPRAY:int	= 1;
		//
		static public const TOOL_PAINT:int	= 2;
		//
		static public const TOOL_LINE:int	= 3;
		static public const TOOL_RECT:int	= 4;
		static public const TOOL_CIRCLE:int	= 5;
		//
		static public const TOOL_SPOIT:int	= 6;
		//
		static public const TOOL_UNDO:int	= 7;
		static public const TOOL_REDO:int	= 8;

		//==Embed==
		[Embed(source='Tool_Pen.png')]
		 private static var Bitmap_Pen: Class;
		[Embed(source='Tool_Spray.png')]
		 private static var Bitmap_Spray: Class;
		[Embed(source='Tool_Paint.png')]
		 private static var Bitmap_Paint: Class;
		[Embed(source='Tool_Line.png')]
		 private static var Bitmap_Line: Class;
		[Embed(source='Tool_Rect.png')]
		 private static var Bitmap_Rect: Class;
		[Embed(source='Tool_Circle.png')]
		 private static var Bitmap_Circle: Class;
		[Embed(source='Tool_Spoit.png')]
		 private static var Bitmap_Spoit: Class;
		[Embed(source='Tool_Undo.png')]
		 private static var Bitmap_Undo: Class;
		[Embed(source='Tool_Redo.png')]
		 private static var Bitmap_Redo: Class;

		static public var m_BitmapList:Array = [
			new Bitmap_Pen(),
			new Bitmap_Spray(),
			new Bitmap_Paint(),
			new Bitmap_Line(),
			new Bitmap_Rect(),
			new Bitmap_Circle(),
			new Bitmap_Spoit(),
			new Bitmap_Undo(),
			new Bitmap_Redo(),
		];

		//==Var==

		//＃Cursor
		static public var m_Cursor:Image;//ツールで一つを共有

		//＃こいつのIndex
		public var m_ToolIndex:int;


		//==Function==

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_ToolIndex:int):void{
			var i:int;
			var j:int;

			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//==Param==
			{
				m_ToolIndex = in_ToolIndex;
			}

			//==Image==
			{
				var img:Image = new Image();
				img.addChild(m_BitmapList[in_ToolIndex]);

				addChild(img);
			}

			//==Cursor==
			{
				//初めて作るのがこいつなら、こいつにカーソルを合わせた状態で生成
				if(m_Cursor == null){
					//Draw
					{
						m_Cursor = new Image();

						var shape:Shape = new Shape();
						m_Cursor.addChild(shape);

						var g:Graphics = shape.graphics;
						{
							const w:int = 4;

							g.lineStyle(w, 0xFF8800, 0.7);

							g.drawRect(-w/2, -w/2, 32+w, 32+w);
						}
					}

					//UseThis
					{
						ChangeToolIndex();
					}
				}
			}

			//==Mouse==
			{
				//Down
				addEventListener(
					MouseEvent.MOUSE_DOWN,
					function(e:MouseEvent):void{ChangeToolIndex();}
				);
			}
		}

		//====

		public function ChangeToolIndex():void{
			//SetToolIndex
			{
				MyCanvas.m_ToolIndex = m_ToolIndex;
			}

			//CursorImage
			{
				//カーソルを自分につける
				addChild(m_Cursor);
			}
		}
	}
}
