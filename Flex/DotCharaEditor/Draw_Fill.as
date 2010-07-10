//author Show=O=Healer

/*
*/


package{
	//
	import flash.display.*;

	public class Draw_Fill{
		static public function draw(
			in_Color:uint,
			in_SrcX:int,
			in_SrcY:int,
			in_DstX:int,
			in_DstY:int,
			in_Bitmap_Main:BitmapData,
			in_Bitmap_Preview:BitmapData,
			in_IsStart:Boolean,
			in_IsEnd:Boolean,
			in_UseAlpha:Boolean = false//基本的にはIndexの描画なのでαまでは使わないと判断
		)
		:void
		{
			//押した瞬間だけ実行（押しながら移動させても他のところまでは塗りつぶさない）
			{
				if(! in_IsStart){
					return;
				}
			}

			//描画先
			var trg_bitmap:BitmapData;
			{
				//Drawの種類によってはin_IsEndで切り替える
				trg_bitmap = in_Bitmap_Main;
			}

			//描画
			{
				//できれば(old_x, old_y)から(in_DstX, in_DstY)への直線にしたい

				//x, y
				var x:int;
				var y:int;
				{
					x = in_DstX;
					y = in_DstY;
				}

				//SetPixel
				{
					trg_bitmap.floodFill(x, y, in_Color);
				}
			}
		}
	}
}

