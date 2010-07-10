//author Show=O=Healer

/*
*/


package{
	//
	import flash.display.*;

	public class Draw_Dot{
		static public var old_x:int = 0;
		static public var old_y:int = 0;

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
			//描画先
			var trg_bitmap:BitmapData;
			{
				//Drawの種類によってはin_IsEndで切り替える
				trg_bitmap = in_Bitmap_Main;
			}

			//Param
			{
				if(in_IsStart){
					old_x = in_DstX;
					old_y = in_DstY;
				}
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
					if(in_UseAlpha){
						trg_bitmap.setPixel32(x, y, in_Color);
					}else{
						trg_bitmap.setPixel(x, y, in_Color);
					}
				}
			}

			//Param
			{
				old_x = in_DstX;
				old_y = in_DstY;
			}
		}
	}
}

