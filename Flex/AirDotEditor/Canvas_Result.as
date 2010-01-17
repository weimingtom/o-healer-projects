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

	public class Canvas_Result extends Canvas{
		//==Const==


		//==Var==

		//#合成するキャンバス
		public var m_Canvas_Color:Canvas_Color;
		public var m_Canvas_Shade:Canvas_Shade;

		//＃Bitmap
		public var m_Bitmap:Bitmap;


		//==Function==

		//!コンストラクタ
		public function Canvas_Result(){
			//==Size==
			{
				//自身の幅を設定しておく
				this.width  = MyCanvas.DOT_NUM;
				this.height = MyCanvas.DOT_NUM;
			}

			//==Bitmap==
			{
				//Ori : Bitmap
				{
					var bmp_data:BitmapData = new BitmapData(MyCanvas.DOT_NUM, MyCanvas.DOT_NUM, true, 0x00000000);
					m_Bitmap  = new Bitmap(bmp_data);
				}

				//Zoom : Image
				{
					var img:Image = new Image();
					img.addChild(m_Bitmap);

					addChild(img);
				}
			}
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_Canvas_Color:Canvas_Color, in_Canvas_Shade:Canvas_Shade):void{
			//==Param==
			{
				m_Canvas_Color = in_Canvas_Color;
				m_Canvas_Shade = in_Canvas_Shade;
			}

			//==Update==
			{
				addEventListener(
					"enterFrame",
					function(event:Event):void {Update();}
				);
			}
		}

		//Bitmapの中央を原点、単位はドットと考える
		//ライト位置
		static public var m_LightPosition:Vector3D = new Vector3D(-MyCanvas.DOT_NUM/8, -MyCanvas.DOT_NUM/16, 10.0);
		//
		static public function CalcColor(in_Color:uint, in_NrmColor:uint):uint{
//*
			//NrmColor => NrmVector
			var Nrm:Vector3D;
			{
				Nrm = NrmColor2NrmVector(in_NrmColor);
				Nrm.normalize();
			}

			//原点から見たライト方向
			var RelLightDir:Vector3D;
			{
				RelLightDir = new Vector3D(
					m_LightPosition.x,
					m_LightPosition.y,
					m_LightPosition.z
				);

				RelLightDir.normalize();
			}

			//
			var ratio:Number;
			{
				var dot:Number = Nrm.dotProduct(RelLightDir);

				ratio = dot;
				if(ratio < 0.0){ratio = 0.0;}//clamp
				if(ratio > 1.0){ratio = 1.0;}//clamp
			}

			//Lerp
			var result_color;
			{
				var a:int = (in_Color >> 24) & 0xFF;
				var r:int = (in_Color >> 16) & 0xFF;
				var g:int = (in_Color >>  8) & 0xFF;
				var b:int = (in_Color >>  0) & 0xFF;

				r = r * ratio;
				g = g * ratio;
				b = b * ratio;

				result_color = (a << 24) | (r << 16) | (g << 8) | (b << 0);
			}

			return result_color;
/*/
			//法線マップの表示っぽくしてみる
			return in_NrmColor;
//*/
		}


		//==Update==

		//ColorとShadeを合成したグラフィックに更新する
		public function Update():void{
			for(var y:int = 0; y < MyCanvas.DOT_NUM; y += 1){
				for(var x:int = 0; x < MyCanvas.DOT_NUM; x += 1){
					var color:uint     = m_Canvas_Color.m_Bitmap.bitmapData.getPixel32(x, y);
					var nrm_color:uint = m_Canvas_Shade.m_Bitmap.bitmapData.getPixel32(x, y);

					var result_color:uint;
//*
					result_color = CalcColor(color, nrm_color);
/*/
					result_color = color;
//*/

					m_Bitmap.bitmapData.setPixel32(x, y, result_color);
				}
			}
		}


		//==Convert==

		//NrmColor => NrmVector
		static public function NrmColor2NrmVector(in_NrmColor:uint):Vector3D{
			var nrm:Vector3D;
			{
				var r:Number = (in_NrmColor >> 16) & 0xFF;
				var g:Number = (in_NrmColor >>  8) & 0xFF;
				var b:Number = (in_NrmColor >>  0) & 0xFF;

				nrm = new Vector3D(
					2.0*(r / 255.0) - 1.0,
					2.0*(g / 255.0) - 1.0,
					2.0*(b / 255.0) - 1.0
				);
			}

			return nrm;
		}
	}
}
