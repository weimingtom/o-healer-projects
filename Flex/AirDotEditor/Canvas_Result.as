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

		//光源のタイプ
		static public const LIGHT_POINT:int = 0;
		static public const LIGHT_DIR:int   = 1;

		//==Var==

		//#合成するキャンバス
		public var m_Canvas_Color:Canvas_Color;
		public var m_Canvas_Shade:Canvas_Shade;

		//＃Bitmap
		public var m_Bitmap:Bitmap;


		//光源のタイプ
		static public var m_LightType:int = LIGHT_POINT;


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
		//マテリアル名
		static public var m_MaterialName:String = "N";//デフォルト：ノーマル
		//
		static public function SetMaterialName(in_MaterialName:String):void{
			m_MaterialName = in_MaterialName;
		}
		//
		static public function CalcColor(in_Color:uint, in_NrmColor:uint, in_X:int = 0, in_Y:int = 0):uint{
			const calcMap:Object = {
				//ノーマル
				N:CalcColor_Normal,
				//金属
				M:CalcColor_Metal,

				//デバッグ
				D:function(in_Color:uint, in_NrmColor:uint, in_X:int, in_Y:int):uint{return in_NrmColor;}
			};

			return calcMap[m_MaterialName](in_Color, in_NrmColor, in_X, in_Y);
		}
		//#Normal
		static public function CalcColor_Normal(in_Color:uint, in_NrmColor:uint, in_X:int = 0, in_Y:int = 0):uint{
//*
//			var LightColor:uint = Palette_Light.m_LightColor;
			var AmbientColor:uint = Palette_Light.m_AmbientColor;

			//NrmColor => NrmVector
			var Nrm:Vector3D;
			{
				Nrm = NrmColor2NrmVector(in_NrmColor);
				Nrm.normalize();
			}

			//原点から見たライト方向
			var RelLightDir:Vector3D;
			{
				switch(m_LightType){
				case LIGHT_POINT:
					//点光源
					RelLightDir = new Vector3D(
						Palette_Light.m_LightPosition.x - in_X,
						Palette_Light.m_LightPosition.y - in_Y,
						Palette_Light.m_LightPosition.z
					);
					break;
				case LIGHT_DIR:
					//平行光源
					RelLightDir = new Vector3D(
						Palette_Light.m_LightPosition.x,
						Palette_Light.m_LightPosition.y,
						Palette_Light.m_LightPosition.z
					);
					break;
				}

				RelLightDir.normalize();
			}

			//
			var ratio:Number;
			{
				var dot:Number = Nrm.dotProduct(RelLightDir);

				ratio = dot;
//				//-0.8～1.0→0.0～1.0：独自処理
//				ratio = (ratio + 0.8) * (1.0 / 1.8);
				//-0.2～1.0→0.0～1.0：独自処理
				ratio = (ratio + 0.2) * (1.0 / 1.2);
				if(ratio < 0.0){ratio = 0.0;}//clamp
				if(ratio > 1.0){ratio = 1.0;}//clamp
			}

			//Lerp
			var result_color:uint;
			{
				var a:uint = (in_Color >> 24) & 0xFF;
				var r:uint = (in_Color >> 16) & 0xFF;
				var g:uint = (in_Color >>  8) & 0xFF;
				var b:uint = (in_Color >>  0) & 0xFF;

				var r_dst:uint = (AmbientColor >> 16) & 0xFF;
				var g_dst:uint = (AmbientColor >>  8) & 0xFF;
				var b_dst:uint = (AmbientColor >>  0) & 0xFF;

				r = (r * ratio) + (r_dst * (1 - ratio));
				g = (g * ratio) + (g_dst * (1 - ratio));
				b = (b * ratio) + (b_dst * (1 - ratio));

				result_color = (a << 24) | (r << 16) | (g << 8) | (b << 0);
			}

			return result_color;
/*/
			//法線マップの表示っぽくしてみる
			return in_NrmColor;
//*/
		}


//*
		static public function CalcColor_Metal(in_Color:uint, in_NrmColor:uint, in_X:int = 0, in_Y:int = 0):uint{
			//金属マテリアル（クック・トランス）

			var LightColor:uint = Palette_Light.m_LightColor;
//			var AmbientColor:uint = Palette_Light.m_AmbientColor;


			//#ベクトル

			//ライトベクトル
			var L:Vector3D;
			switch(m_LightType){
			case LIGHT_POINT:
				//点光源
				L = new Vector3D(Palette_Light.m_LightPosition.x - in_X, Palette_Light.m_LightPosition.y - in_Y, Palette_Light.m_LightPosition.z); L.normalize();
				break;
			case LIGHT_DIR:
				//平行光源
				L = new Vector3D(Palette_Light.m_LightPosition.x, Palette_Light.m_LightPosition.y, Palette_Light.m_LightPosition.z); L.normalize();
				break;
			}

			//法線ベクトル
			var N:Vector3D = NrmColor2NrmVector(in_NrmColor);

			//視線ベクトル
			var V:Vector3D = Vector3D.Z_AXIS;

			//ハーフベクトル
			var H:Vector3D = L.add(V); H.normalize();


			//#内積

			var NV:Number = N.dotProduct(V);
			var NH:Number = N.dotProduct(H);
			var VH:Number = V.dotProduct(H);
			var NL:Number = N.dotProduct(L);
			var LH:Number = L.dotProduct(H);


			//#計算

			//Beckmann分布関数
			var D:Number;
			{
				const m:Number = 0.5;//0.35;//定数：荒さ
				var NH2:Number = NH*NH;
				D = Math.exp(-(1-NH2)/(NH2*m*m)) / (4*m*m*NH2*NH2);
			}

			//幾何減衰率
			var G:Number;
			{
				G = Math.min(Math.min(2*NH*NV/VH, 2*NH*NL/VH), 1);
			}

			//フレネル
			var F:Number;
			var F0:Number;
			{
//				const n:Number = 20.0;//複素屈折率の実部
				const n:Number = 3.0;//複素屈折率の実部
				var g_:Number = Math.sqrt(n*n + LH*LH -1);
				var gpc:Number = g_+LH;
				var gnc:Number = g_-LH;
				var cgpc:Number = LH*gpc-1;
				var cgnc:Number = LH*gnc+1;
				F = 0.5*gnc*gnc*(1+cgpc*cgpc/(cgnc*cgnc))/(gpc*gpc);
				F0 = ((n-1)*(n-1))/((n+1)*(n+1));
			}

			//結果：色にかける係数
			var Ratio:Number;
			{
				Ratio = Math.max(F*D*G/NV, 0);
			}


			//#適用
			var result_color:uint;
			{
				var a:uint = (in_Color >> 24) & 0xFF;

				var ori_color:uint = CalcColor_Normal(in_Color, in_NrmColor, in_X, in_Y);

				var Color_Ori:Vector3D = new Vector3D((in_Color>>16)&0xFF, (in_Color>>8)&0xFF, (in_Color>>0)&0xFF);
				var Color_Light:Vector3D = new Vector3D((LightColor>>16)&0xFF, (LightColor>>8)&0xFF, (LightColor>>0)&0xFF);
				var Color_Ambient:Vector3D = new Vector3D((ori_color>>16)&0xFF, (ori_color>>8)&0xFF, (ori_color>>0)&0xFF);

				//Color Shift
				Color_Ambient = Color_Ambient.add(new Vector3D((Color_Light.x - Color_Ambient.x) * Math.max(F-F0, 0) / (1 - F0), (Color_Light.y - Color_Ambient.y) * Math.max(F-F0, 0) / (1 - F0), (Color_Light.z - Color_Ambient.z) * Math.max(F-F0, 0) / (1 - F0)));

				//独自処理：どんな色でも白とびが可能なように、少しだけ色を底上げする
				var Offset:int = 0x02;
				Color_Ori = Color_Ori.add(new Vector3D(Offset, Offset, Offset));

				var Color_Result:Vector3D = new Vector3D(
					Color_Ambient.x + 0xFF * (Color_Ori.x/0xFF * Color_Light.x/0xFF * Ratio),
					Color_Ambient.y + 0xFF * (Color_Ori.y/0xFF * Color_Light.y/0xFF * Ratio),
					Color_Ambient.z + 0xFF * (Color_Ori.z/0xFF * Color_Light.z/0xFF * Ratio)
				);

				var r:uint = Math.min(Math.max(Color_Result.x, 0x00), 0xFF);
				var g:uint = Math.min(Math.max(Color_Result.y, 0x00), 0xFF);
				var b:uint = Math.min(Math.max(Color_Result.z, 0x00), 0xFF);

				result_color = (a << 24) | (r << 16) | (g << 8) | (b << 0);
			}

			return result_color;
		}
//*/

		//==Update==

		//ColorとShadeを合成したグラフィックに更新する
		public function Update():void{
			for(var y:int = 0; y < MyCanvas.DOT_NUM; y += 1){
				for(var x:int = 0; x < MyCanvas.DOT_NUM; x += 1){
					var color:uint     = m_Canvas_Color.m_Bitmap.bitmapData.getPixel32(x, y);
					var nrm_color:uint = m_Canvas_Shade.m_Bitmap.bitmapData.getPixel32(x, y);

					var result_color:uint;
//*
					result_color = CalcColor(color, nrm_color, x, y);
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
