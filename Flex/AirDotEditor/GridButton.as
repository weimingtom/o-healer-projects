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

	public class GridButton extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 50;
		static public const SIZE_H:int = 20;

		//＃グリッドのタイプ
		static public const GRID_TYPE_8x8:int   = 0;
		static public const GRID_TYPE_16x16:int = 1;
		static public const GRID_TYPE_32x32:int = 2;
//		static public const GRID_TYPE_64x64:int = 3;
//		static public const GRID_TYPE_NUM:int	= 4;
		static public const GRID_TYPE_NUM:int	= 3;


		//==Embed==
		[Embed(source='Button_8x8.png')]
		 private static var Bitmap_8x8: Class;
		[Embed(source='Button_16x16.png')]
		 private static var Bitmap_16x16: Class;
		[Embed(source='Button_32x32.png')]
		 private static var Bitmap_32x32: Class;
//		[Embed(source='Button_64x64.png')]
//		 private static var Bitmap_64x64: Class;

		static public var m_BitmapList:Array = [
			new Bitmap_8x8(),
			new Bitmap_16x16(),
			new Bitmap_32x32(),
//			new Bitmap_64x64(),
		];

		//==Var==


		//==Function==

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_GridType:int, in_Canvas:MyCanvas):void{
			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//==Image==
			{
				var bmp:Bitmap = new Bitmap(m_BitmapList[in_GridType].bitmapData.clone());
				var img:Image = new Image();
				img.addChild(bmp);

				addChild(img);
			}

			//==Mouse==
			{
				//Down
				addEventListener(
					MouseEvent.MOUSE_DOWN,
					function(e:MouseEvent):void{
						in_Canvas.SetGridType(in_GridType);
					}
				);
			}
		}
	}
}
