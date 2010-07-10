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

	public class Canvas_Gather extends Canvas{
		//==Const==

		//==Var==

		//#サイズ
		public var SIZE_W:int = 24 * 3;
		public var SIZE_H:int = 32 * 4;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//表示画像
		public var m_Bitmap:Bitmap;
		public var m_BitmapData:BitmapData;

		//「色」と「陰」の取得関数（外部から指定する）
		public var m_FuncGetColor_Color:Function = function(in_X:int, in_Y:int):uint{return 0x00000000;}
		public var m_FuncGetColor_Shade:Function = function(in_X:int, in_Y:int):uint{return 0x00000000;}

		//==Function==

		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function Canvas_Gather(in_W:int = 72, in_H:int = 128){
			//Size
			{
				SIZE_W = in_W;
				SIZE_H = in_H;

				this.width  = in_W;
				this.height = in_H;
			}

			//Root
			{
				m_Root = new Image();
				addChild(m_Root);
			}

			//BG
			{
				m_Root.addChild(new BackGroundAnim(SIZE_W, SIZE_H, SIZE_H/16));
			}

			//Create Bitmap
			{
				m_BitmapData = new BitmapData(SIZE_W, SIZE_H, true, 0x00000000);

				m_Bitmap = new Bitmap(m_BitmapData);

				m_Root.addChild(m_Bitmap);
			}
		}

		//#Interface

		//「色」取得関数と、「陰」取得関数を外部からセット
		public function SetFunc_GetColor_Color(in_Func:Function):void{
			m_FuncGetColor_Color = in_Func;
		}
		public function SetFunc_GetColor_Shade(in_Func:Function):void{
			m_FuncGetColor_Shade = in_Func;
		}

		//「色」と「陰」の合成画像を作成
		public function Redraw():void{
			for(var y:int = 0; y < SIZE_W; y++){
				for(var x:int = 0; x < SIZE_W; x++){
					m_BitmapData.setPixel32(x, y, GetColor(x, y));
				}
			}
		}

		//「色」と「陰」のピクセル単位での合成結果を返す
		public function GetColor(in_X:int, in_Y:int):uint{
			const lerp:Function = function(in_Src:uint, in_Dst:uint, in_Ratio:Number):uint{
				return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
			};

			var col_color:uint = m_FuncGetColor_Color(in_X, in_Y);
			var col_shade:uint = m_FuncGetColor_Shade(in_X, in_Y);

			var ratio:Number = ((col_shade >> 24) & 0xFF) / 255.0;

			var a:uint = (col_color >> 24) & 0xFF;
			var r:uint = lerp((col_color >> 16) & 0xFF, (col_shade >> 16) & 0xFF, ratio);
			var g:uint = lerp((col_color >>  8) & 0xFF, (col_shade >>  8) & 0xFF, ratio);
			var b:uint = lerp((col_color >>  0) & 0xFF, (col_shade >>  0) & 0xFF, ratio);

			return (a << 24) | (r << 16) | (g << 8) | (b << 0);
		}
	}
}

