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

	public class Palette_HL extends IPalette{
		//==Const==

		//＃サイズ
		override public function GetBitmapW():int{return 100;}
		override public function GetBitmapH():int{return 200;}

		override public function GetInfoKeyName_X():String{return "L";}//横方向
		override public function GetInfoKeyName_Y():String{return "H";}//縦方向

		override public function Is2D():Boolean{return true;}


		//==Function==

		//初期化
		override public function reset(in_Info:Array, in_InputColor:Array = null):void{
			//Param
			{
				//m_CursorIndex
				{
					if(m_CursorIndex >= in_Info.length){m_CursorIndex = in_Info.length-1;}
				}

				//m_Cursor
				{
					refreshCursor(in_Info);
				}
			}

			//Graphic
			{
				redraw();
			}

			//
			var outputColor:Array;
			{
				var num:int = in_Info.length;

				outputColor = new Array(num);

				for(var i:int = 0; i < num; i++){
					outputColor[i] = GetColor(i);
				}
			}

			//Next
			{
				onReset(in_Info, outputColor);
			}
		}

		override public function refreshCursor(in_Info:Array):void{
			var i:int;

			var size_old:int	= m_Cursor.length;
			var size_info:int	= in_Info.length;

			//まずは数を合わせる
			{
				//Remove
				if(size_info < size_old){
					var newCursorArray:Array		= new Array(size_info);

					//Copy
					for(i = 0; i < size_info; i++){
						newCursorArray[i]		= m_Cursor[i];
					}
					//Remove
					for(i = size_info; i < size_old; i++){
						m_Cursor[i].parent.removeChild(m_Cursor[i]);
					}

					//Restore
					{
						m_Cursor = newCursorArray;
					}
				}

				//Add
				if(size_info > size_old){
					//Add
					for(i = size_old; i < size_info; i++){
						//Add
						{
							m_Cursor.push(new Sprite());
						}

						//Init Cursor
						{
							//Draw
							{
								var g:Graphics = m_Cursor[i].graphics;

								const w:int = 10;
								const v:int = 5;

								const line_w:Array = [
									3,
									1
								];

								const line_color:Array = [
									0x444444,
									0xBBBBBB
								];

								for(var j:int = 0; j < 2; j++){
									g.lineStyle(line_w[j], line_color[j], 0.7);

									g.moveTo( 0, w);
									g.lineTo( 0, v);
									g.moveTo( 0,-w);
									g.lineTo( 0,-v);
									g.moveTo( w, 0);
									g.lineTo( v, 0);
									g.moveTo(-w, 0);
									g.lineTo(-v, 0);
								}
							}

							m_Root.addChild(m_Cursor[i]);
						}
					}
				}
			}

			//そして位置や値をInfoから計算
			{
				for(i = 0; i < size_info; i++){
					m_Cursor[i].x = (GetBitmapW()-1) * in_Info[i][GetInfoKeyName_X()];
					m_Cursor[i].y = (GetBitmapH()-1) * in_Info[i][GetInfoKeyName_Y()];
				}
			}

			//初期化時などのため、CursorIndexまわりの再計算
			{
				//Indexがオーバーしていたら範囲内の戻す
				if(size_info <= m_CursorIndex){
					m_CursorIndex = size_info - 1;
				}

				redraw_cursor();
			}
		}


		override public function redraw_cursor():void{
			var num:int = m_Cursor.length;

			//Alpha
			{
				for(var i:int = 0; i < num; i++){
					if(i == m_CursorIndex){
						m_Cursor[i].alpha = 1.0;
					}else{
						m_Cursor[i].alpha = 0.5;
					}
				}
			}
		}


		public function GetColor(in_Index:int):uint{
			return m_BitmapData.getPixel32(m_Cursor[in_Index].x, m_Cursor[in_Index].y);
		}
		//
		override public function GetSelectedColor():uint{
			return GetColor(m_CursorIndex);
		}
//*
		//#Save & Load
		override public function GetVal(in_Index:int, in_IsX:Boolean = true):Number{
			if(in_IsX){
				return m_Cursor[in_Index].x / (GetBitmapW()-1);
			}else{
				return m_Cursor[in_Index].y / (GetBitmapH()-1);
			}
		}
//*/

		public var m_DrawInitFlag:Boolean = false;
		override public function redraw():void{
			//こいつは初期化時に一度描画したらもういじらない
			{
				if(m_DrawInitFlag){
					return;
				}

				m_DrawInitFlag = true;
			}

			var SIZE_W:int = GetBitmapW();
			var SIZE_H:int = GetBitmapH();

			//HL
			for(var y:int = 0; y < SIZE_H; y += 1){//色相：Hue
				//色
				var r_ori:uint;
				var g_ori:uint;
				var b_ori:uint;
				{
					//赤～黄、黄～緑、緑～青緑、青緑～青、青～紫、紫～赤の６フェイズ
					const calcVal:Function = function(in_Ratio:Number):uint{
						if(in_Ratio > 1.0){in_Ratio -= 1.0;}

						if(in_Ratio < 1.0/6.0){return 0xFF;}
						if(in_Ratio < 2.0/6.0){return 0xFF * (2.0 - in_Ratio*6.0);}
						if(in_Ratio < 3.0/6.0){return 0x00;}
						if(in_Ratio < 4.0/6.0){return 0x00;}
						if(in_Ratio < 5.0/6.0){return 0xFF * (in_Ratio*6.0 - 4.0);}
						if(in_Ratio < 6.0/6.0){return 0xFF;}

						return 0xFF;//err
					}

					r_ori = calcVal(1.0 * y / SIZE_H + 0.0/3.0);
					g_ori = calcVal(1.0 * y / SIZE_H + 2.0/3.0);
					b_ori = calcVal(1.0 * y / SIZE_H + 1.0/3.0);
				}

				for(var x:int = 0; x < SIZE_W; x += 1){//輝度：Lightness
					//輝度計算
					var ratio:Number = 1.0 * x / SIZE_W;

					//元の色の長さ / 白の長さ
					var ratio_ori:Number = (new Vector3D(r_ori, g_ori, b_ori)).length / (new Vector3D(0xFF, 0xFF, 0xFF)).length;

					//色の計算
					var color:uint;
					{
						var r:uint, g:uint, b:uint;
						if(ratio < ratio_ori){
							//黒～原色

							//Lerp用Ratioに変換
							ratio = ratio / ratio_ori;

							//黒→原色のLerp
							r = lerp(0x00, r_ori, ratio);
							g = lerp(0x00, g_ori, ratio);
							b = lerp(0x00, b_ori, ratio);
						}else{
							//原色～白

							//Lerp用Ratioに変換
							ratio = (ratio - ratio_ori) / (1 - ratio_ori);

							//原色→白のLerp
							r = lerp(r_ori, 0xFF, ratio);
							g = lerp(g_ori, 0xFF, ratio);
							b = lerp(b_ori, 0xFF, ratio);
						}

						color = 0xFF000000 | (r << 16) | (g << 8) | (b << 0);
					}

					//セット
					m_BitmapData.setPixel32(x, y, color);
				}
			}
		}
	}
}

