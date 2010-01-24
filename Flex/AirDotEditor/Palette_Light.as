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

	public class Palette_Light extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 190;
		static public const SIZE_H:int = 300;

		//＃ライト位置パレットのサイズ
		static public const LP_SIZE_W:int = 180;
		static public const LP_SIZE_H:int = 200;

		//＃ライトの強さパレットのサイズ
		static public const LV_SIZE_W:int = 180;
		static public const LV_SIZE_H:int = 20;


		//==Var==

		//ライト位置
		static public var m_LightPosition:Vector3D = new Vector3D(MyCanvas.DOT_NUM/16, MyCanvas.DOT_NUM/32, 50.0);

		//ライト色
		static public var m_LightColor:uint = 0xFFFFFF;
		static public var m_AmbientColor:uint = 0x000000;


		//==Function==

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_PaletteShade:Palette_Shade, in_CanvasShade:Canvas_Shade):void{
			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//==Image==
			{
				//LightPosition
				{
					var picker_LP:Picker_LightPosition = new Picker_LightPosition();
					addChild(picker_LP);
					picker_LP.Init(in_PaletteShade, in_CanvasShade);

					picker_LP.x = 10;
					picker_LP.y = 10;
				}

				//LightVal
				{
					var picker_LV:Picker_LightVal = new Picker_LightVal();
					addChild(picker_LV);
					picker_LV.Init(in_PaletteShade, in_CanvasShade);

					picker_LV.x = 10;
					picker_LV.y = 220;
				}

				//AmbientVal
				{
					var picker_AV:Picker_AmbientVal = new Picker_AmbientVal();
					addChild(picker_AV);
					picker_AV.Init(in_PaletteShade, in_CanvasShade);

					picker_AV.x = 10;
					picker_AV.y = 250;
				}
			}
		}
	}
}


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


class Picker_LightPosition extends Image
{
	//==Var==

	//カーソル画像
	public var m_Cursor:Sprite;


	//==Function==

	public function Init(in_PaletteShade:Palette_Shade, in_CanvasShade:Canvas_Shade):void{
		const BMP_W:int = Palette_Light.LP_SIZE_W;
		const BMP_H:int = Palette_Light.LP_SIZE_H;

		//Create Bitmap
		{
			var bmp_data:BitmapData = new BitmapData(BMP_W, BMP_H, false, 0x000000);

			addChild(new Bitmap(bmp_data));
		}

		//Create Cursor
		{
			m_Cursor = new Sprite();
			{
				var gr:Graphics = m_Cursor.graphics;

				const w:int = 10;
				const v:int = 5;

				gr.lineStyle(3, 0xFFFFFF, 0.7);

				gr.moveTo( 0, w);
				gr.lineTo( 0, v);
				gr.moveTo( 0,-w);
				gr.lineTo( 0,-v);
				gr.moveTo( w, 0);
				gr.lineTo( v, 0);
				gr.moveTo(-w, 0);
				gr.lineTo(-v, 0);
			}

			addChild(m_Cursor);

			m_Cursor.x = Palette_Light.m_LightPosition.x * BMP_W / MyCanvas.DOT_NUM;
			m_Cursor.y = Palette_Light.m_LightPosition.y * BMP_H / MyCanvas.DOT_NUM;
		}

		//mouse
		{
			var onChange:Function = function():void{
				Palette_Light.m_LightPosition.x = mouseX * MyCanvas.DOT_NUM / BMP_W;
				Palette_Light.m_LightPosition.y = mouseY * MyCanvas.DOT_NUM / BMP_H;

				m_Cursor.x = mouseX;
				m_Cursor.y = mouseY;

				in_PaletteShade.Redraw();
				in_CanvasShade.Redraw();
			};

			var IsButtonDown:Boolean = false;

			addEventListener(
				MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void{
					IsButtonDown = true;
					onChange();
				}
			);

			root.addEventListener(
				MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent):void{
					if(! e.buttonDown){
						IsButtonDown = false;
					}
					if(IsButtonDown){
						onChange();
					}
				}
			);
		}
	}
}


class Picker_LightVal extends Image
{
	//==Var==

	//Bitmap
	public var m_BitmapData:BitmapData;

	//カーソル画像
	public var m_Cursor:Sprite;

	//
	public var BMP_W:int;
	public var BMP_H:int;


	//==Function==

	public function Init(in_PaletteShade:Palette_Shade, in_CanvasShade:Canvas_Shade):void
	{
		//Create Bitmap
		{
			BMP_W = Palette_Light.LV_SIZE_W;
			BMP_H = Palette_Light.LV_SIZE_H;

			m_BitmapData = new BitmapData(BMP_W, BMP_H, false, 0x000000);

			addChild(new Bitmap(m_BitmapData));
		}

		//Create Cursor
		{
			m_Cursor = new Sprite();
			{
				var g:Graphics = m_Cursor.graphics;

				const w:int = 6;

				g.lineStyle(1, 0x000000, 0.7);
				g.beginFill(0xFFFFFF, 0.7);

				g.moveTo( w/2, 0);
				g.lineTo(   0, w);
				g.lineTo(-w/2, 0);
				g.lineTo( w/2, 0);

				g.endFill();
			}

			addChild(m_Cursor);
		}

		//mouse
		{
			var onChange:Function = function():void{
				var x:int = Math.min(Math.max(0, mouseX), BMP_W);

				//Cursor
				{
					m_Cursor.x = x;
				}

				//Calc LightColor
				{
					var ratio:Number = x / BMP_W;

					var val:uint = 0xFF * (1 - ratio);

					Palette_Light.m_LightColor = (val << 16) | (val << 8) | (val << 0);
				}

				//Redraw
				{
					in_PaletteShade.Redraw();
					in_CanvasShade.Redraw();
				}
			};

			var IsButtonDown:Boolean = false;

			addEventListener(
				MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void{
					IsButtonDown = true;
					onChange();
				}
			);

			root.addEventListener(
				MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent):void{
					if(! e.buttonDown){
						IsButtonDown = false;
					}
					if(IsButtonDown){
						onChange();
					}
				}
			);
		}

		//描画
		{
			Refresh();
		}
	}

	//描画
	public function Refresh():void{
		//Redraw
		{
			const BMP_W:int = m_BitmapData.width;
			const BMP_H:int = m_BitmapData.height;

			var r_ori:uint = 0xFF;//(m_Param.m_ColorHS >> 16) & 0xFF;
			var g_ori:uint = 0xFF;//(m_Param.m_ColorHS >>  8) & 0xFF;
			var b_ori:uint = 0xFF;//(m_Param.m_ColorHS >>  0) & 0xFF;

			for(var x:int = 0; x < BMP_W; x += 1){//明度：Brightness
				var ratio:Number = 1.0 * x / BMP_W;

				var r:uint = (r_ori * (1 - ratio)) + (0x00 * ratio);
				var g:uint = (g_ori * (1 - ratio)) + (0x00 * ratio);
				var b:uint = (b_ori * (1 - ratio)) + (0x00 * ratio);

				var color:uint = (r << 16) | (g << 8) | (b << 0);

				for(var y:int = 0; y < BMP_H; y += 1){
					//セット
					m_BitmapData.setPixel(x, y, color);
				}
			}
		}

//		//カーソル位置
//		{
//			m_Cursor.x = m_BrightnessIndex;
//		}
	}
}


class Picker_AmbientVal extends Image
{
	//==Var==

	//Bitmap
	public var m_BitmapData:BitmapData;

	//カーソル画像
	public var m_Cursor:Sprite;

	//
	public var BMP_W:int;
	public var BMP_H:int;


	//==Function==

	public function Init(in_PaletteShade:Palette_Shade, in_CanvasShade:Canvas_Shade):void
	{
		//Create Bitmap
		{
			BMP_W = Palette_Light.LV_SIZE_W;
			BMP_H = Palette_Light.LV_SIZE_H;

			m_BitmapData = new BitmapData(BMP_W, BMP_H, false, 0x000000);

			addChild(new Bitmap(m_BitmapData));
		}

		//Create Cursor
		{
			m_Cursor = new Sprite();
			{
				var g:Graphics = m_Cursor.graphics;

				const w:int = 6;

				g.lineStyle(1, 0x000000, 0.7);
				g.beginFill(0xFFFFFF, 0.7);

				g.moveTo( w/2, 0);
				g.lineTo(   0, w);
				g.lineTo(-w/2, 0);
				g.lineTo( w/2, 0);

				g.endFill();
			}

			addChild(m_Cursor);

			m_Cursor.x = BMP_W-1;
		}

		//mouse
		{
			var onChange:Function = function():void{
				var x:int = Math.min(Math.max(0, mouseX), BMP_W);

				//Cursor
				{
					m_Cursor.x = x;
				}

				//Calc LightColor
				{
					var ratio:Number = x / BMP_W;

					var val:uint = 0xFF * (1 - ratio);

					Palette_Light.m_AmbientColor = (val << 16) | (val << 8) | (val << 0);
				}

				//Redraw
				{
					in_PaletteShade.Redraw();
					in_CanvasShade.Redraw();
				}
			};

			var IsButtonDown:Boolean = false;

			addEventListener(
				MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void{
					IsButtonDown = true;
					onChange();
				}
			);

			root.addEventListener(
				MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent):void{
					if(! e.buttonDown){
						IsButtonDown = false;
					}
					if(IsButtonDown){
						onChange();
					}
				}
			);
		}

		//描画
		{
			Refresh();
		}
	}

	//描画
	public function Refresh():void{
		//Redraw
		{
			const BMP_W:int = m_BitmapData.width;
			const BMP_H:int = m_BitmapData.height;

			var r_ori:uint = 0xFF;//(m_Param.m_ColorHS >> 16) & 0xFF;
			var g_ori:uint = 0xFF;//(m_Param.m_ColorHS >>  8) & 0xFF;
			var b_ori:uint = 0xFF;//(m_Param.m_ColorHS >>  0) & 0xFF;

			for(var x:int = 0; x < BMP_W; x += 1){//明度：Brightness
				var ratio:Number = 1.0 * x / BMP_W;

				var r:uint = (r_ori * (1 - ratio)) + (0x00 * ratio);
				var g:uint = (g_ori * (1 - ratio)) + (0x00 * ratio);
				var b:uint = (b_ori * (1 - ratio)) + (0x00 * ratio);

				var color:uint = (r << 16) | (g << 8) | (b << 0);

				for(var y:int = 0; y < BMP_H; y += 1){
					//セット
					m_BitmapData.setPixel(x, y, color);
				}
			}
		}

//		//カーソル位置
//		{
//			m_Cursor.x = m_BrightnessIndex;
//		}
	}
}




