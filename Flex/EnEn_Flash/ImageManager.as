//author Show=O=Healer

package{
/*
	import flash.text.TextField;
	import flash.utils.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
//*/
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class ImageManager{
		//==Font==
		[Embed(
			source='ume-tgc4.ttf',
			fontName='ume',
			unicodeRange = 'U+0021-U+007E'
		)]
		 private var GameFont:Class;


		//==Const==

		static public const GRAPHIC_INDEX_EMPTY:Number = -1;
		static public const GRAPHIC_INDEX_BLACK:Number =  0;
		static public const GRAPHIC_INDEX_WHITE:Number =  1;

		static public const COLOR_WHITE:uint			= 0xFFFAE0;//0xFAF5C0;//0xFFFFFF;
		static public const COLOR_BLACK:uint			= 0x000000;
		static public const COLOR_EMPTY:uint			= 0xFF888888;//0x00000000;


		//==BG==

		static public function DrawBG(i_BG:BitmapData, i_GraphicMap:Array):void
		{
			//背景色で塗りつぶす
			{
				i_BG.fillRect(i_BG.rect, COLOR_EMPTY);
			}

			//i_GraphicMapのブロックのある部分を描く
			var shape:Shape = new Shape();
			{//まずはShape（のGraphics）に描いて、それをBMPに描く
				var graphic:Graphics = shape.graphics;

				var NumX:int = i_GraphicMap[0].length;
				var NumY:int = i_GraphicMap.length;

				for(var x:int = 0; x < NumX; x += 1){
					var max_move:int = 0;//落下した分の上のスキマの大きさを覚えておく

					var lx:int = x * Game.PANEL_LEN;

					for(var y:int = 0; y < NumY; y += 1){
						var uy:int = y * Game.PANEL_LEN;

						{
							graphic.lineStyle(0, 0x000000, 0.0);

							if(i_GraphicMap[y][x] < GRAPHIC_INDEX_BLACK){
								//Empty～Black
								var alpha:Number = 1.0 + i_GraphicMap[y][x];
								graphic.beginFill(0x000000, alpha);
							}else{
								//Black～White
								var r:int = (((COLOR_WHITE >> 16) & 0xFF)  * i_GraphicMap[y][x]);
								var g:int = (((COLOR_WHITE >>  8) & 0xFF)  * i_GraphicMap[y][x]);
								var b:int = (((COLOR_WHITE >>  0) & 0xFF)  * i_GraphicMap[y][x]);
//								var val:int = 0xFF * i_GraphicMap[y][x];
								graphic.beginFill((r << 16) + (g << 8) + (b << 0));
							}

							graphic.drawRect(lx, uy, Game.PANEL_LEN, Game.PANEL_LEN);
						}
					}
				}
			}

			//Refresh
			{
				i_BG.draw(shape);
			}
		}


		//=Block=

		//全て、左上が原点となるように作る（位置制御はブロックの方でやる）
		static public function LoadImage_Block(i_Color:int, i_Blocks:Array):Image
		{
			var shape:Shape = new Shape();
			var graphic:Graphics = shape.graphics;

			//Init
			{
				switch(i_Color){
				case GRAPHIC_INDEX_BLACK:
					graphic.lineStyle(1, COLOR_BLACK, 1.0);
					graphic.beginFill(COLOR_BLACK);
					break;
				case GRAPHIC_INDEX_WHITE:
					graphic.lineStyle(1, COLOR_WHITE, 1.0);
					graphic.beginFill(COLOR_WHITE);
					break;
				}
			}

			//Draw
			var len:int = Game.PANEL_LEN;
			for(var y:int = 0; y < i_Blocks.length; y += 1){
				for(var x:int = 0; x < i_Blocks[y].length; x += 1){
					if(i_Blocks[y][x] != 0){
						graphic.drawRect(x*len, y*len, len, len);
					}
				}
			}

			//BitmapData
			var bmp_data:BitmapData;
			{
				//枠が見切れるので、できれば６つ分作って、１つ分ずらしておきたい
				bmp_data = new BitmapData(len*4, len*4, true, 0x000000);//４マスを越えることはないはず
				bmp_data.draw(shape);
			}

			//BMP_DATA => BMP
			var bmp:Bitmap = new Bitmap( bmp_data , PixelSnapping.AUTO , true);

			//Result
			var Result:Image = new Image();
			Result.addChild(bmp);
			return Result;
		}

		//=Fire=

/*
		[Embed(source='Fire.png')]
		 private static var Bitmap_Fire: Class;

		static public function CreateFire():Image{
			var result:Image;
			{
				result = new Image();
				result.addChild(new Bitmap_Fire);
			}
			return result;
		}
/*/
		static public function CreateFire():TeraFire{
			return new TeraFire(0, 0, Game.PANEL_LEN*2, Game.PANEL_LEN*3);
		}
//*/
	}
}


