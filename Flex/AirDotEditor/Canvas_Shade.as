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

	public class Canvas_Shade extends MyCanvas{
		//==Const==


		//==Var==

		//＃Bitmap：じっさいに表示する方
		public var m_Bitmap_Show:Bitmap;
		//マウスでの描画はまずこれに行い、それに基づくグラフィックをm_Bitmapの方に描く
		//具体的には「Draw～」系をoverrideすることで描画をのっとる
		//ついでにDrawの中身も独自のものにする（円の場合は球体のNrmを描くなど）



		//==Function==

		//!コンストラクタ
		public function Canvas_Shade(){
			//super
			{
				super();
			}

			//Init Param
			{
				m_ClearColor = Palette_Shade.NrmVector2NrmColor(Vector3D.Z_AXIS);//0xFF8080FF;
			}

			//==Bitmap==
			{
				var bmp_data:BitmapData = new BitmapData(DOT_NUM, DOT_NUM, true, 0xFF000000);
				m_Bitmap_Show = new Bitmap(bmp_data);
			}
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		override public function Init():void{
			super.Init();

			//表示するBitmapの差し替え
			{
				//add
				m_Bitmap.parent.addChild(m_Bitmap_Show);
//				m_Bitmap.parent.removeChild(m_Bitmap);//removeしてしまうとマウス位置を参照してる部分がおかしくなる
				m_Bitmap.visible = false;//ので、見えなくするだけ
			}

			Redraw();
		}

		//!法線の値から（灰色をベースにした）実際の色に描画
		public function Redraw():void{
			for(var y:int = 0; y < DOT_NUM; y += 1){
				for(var x:int = 0; x < DOT_NUM; x += 1){
					var nrm_color:uint = m_Bitmap.bitmapData.getPixel32(x, y);
					var color:uint = Canvas_Result.CalcColor(0xFFFFFFFF, nrm_color);
					m_Bitmap_Show.bitmapData.setPixel32(x, y, color);
				}
			}
		}

		//#Line (& Pen)
		override public function DrawLine(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			super.DrawLine(in_SrcX, in_SrcY, in_DstX, in_DstY);

			Redraw();
		}

		//#Rect
		override public function DrawRect(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			super.DrawRect(in_SrcX, in_SrcY, in_DstX, in_DstY);

			Redraw();
		}

		//#Circle
		override public function DrawCircle(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			//!!あとで球体のNrmを描くように変更

			super.DrawCircle(in_SrcX, in_SrcY, in_DstX, in_DstY);

			Redraw();
		}

		//#Paint
		override public function DrawPaint(in_SrcX:int, in_SrcY:int):void{
			super.DrawPaint(in_SrcX, in_SrcY);

			Redraw();
		}
	}
}
