//author Show=O=Healer

package{
	//数学用ライブラリ
	public class MyMath{

		public static const PI:Number = 3.1415926535;

		//==Common==

		//#Min
		static public function Min(i_LHS:Number, i_RHS:Number):Number{
			if(i_LHS < i_RHS){
				return i_LHS;
			}else{
				return i_RHS;
			}
		}

		//#Max
		static public function Max(i_LHS:Number, i_RHS:Number):Number{
			if(i_LHS > i_RHS){
				return i_LHS;
			}else{
				return i_RHS;
			}
		}

		//#Abs
		static public function Abs(i_Val:Number):Number{
			return (i_Val > 0)? i_Val: -i_Val;
		}

		//#Pos
		static public function Pow(i_Base:Number, i_Pow:Number):Number{
			return Math.pow(i_Base, i_Pow);
		}

		//#Square Root
		static public function Sqrt(i_Val:Number):Number{
			return Math.sqrt(i_Val);
		}

		//#Lerp
		static public function Lerp(i_Src:Number, i_Dst:Number, i_Ratio:Number):Number{
			return (i_Src * (1.0 - i_Ratio)) + (i_Dst * i_Ratio);
		}


		//==Random==

		//#Random 0.0～0.999999...
		static public function Random():Number{
			return Math.random();
		}

		//#Random 0～NUM-1
		static public function RandomRange(i_Num:int):int{
			var Result:int = i_Num * Random();

			return Result;
		}


		//==Sin,Cos==

		//#Sin
		static public function Sin(i_Theta:Number):Number{
			return Math.sin(i_Theta);
		}

		//#Cos
		static public function Cos(i_Theta:Number):Number{
			return Math.cos(i_Theta);
		}

		//#Atan
		static public function Atan(i_Y:Number, i_X:Number):Number{
			return Math.atan2(i_Y, i_X);
		}
	}
}


