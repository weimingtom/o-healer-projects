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

	public class Palette_Color extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 200;
		static public const SIZE_H:int = 300;

		//色＆彩度のサイズ
		static public const COLOR_PICKER_W:int = 100;
		static public const COLOR_PICKER_H:int = 200;

		//明度のサイズ
		static public const BRIGHTNESS_W:int = 100;
		static public const BRIGHTNESS_H:int = 32;

		//＃スペース
		static public const SPACE_L:int = 3;
		static public const SPACE_R:int = 3;
		static public const SPACE_U:int = 3;
		static public const SPACE_D:int = 3;
		static public const SPACE_Y:int = 6;



		//==Var==

		//対応するキャンバス
		public var m_Canvas:MyCanvas;

		//各パーツで共有する値
		public var m_Param:Param;


		//==Function==

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_Canvas:MyCanvas):void{
			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//==Param==
			{
				//Create
				{
					m_Param = new Param();
				}

				//Set
				{
					//このパレットに対応するキャンバス
					m_Param.m_Canvas = in_Canvas;

					//GUIのパーツ
					m_Param.m_Picker_HS = new Picker_HS();//色相と彩度のピッカー
					m_Param.m_Picker_B = new Picker_B();//明度のピッカー

					//パラメータ
					m_Param.m_HueIndex		= 0;//色相
					m_Param.m_SaturationIndex	= 0;//彩度
					m_Param.m_BrightnessIndex	= 0;//明度
					m_Param.m_AlphaIndex		= 0;//アルファ
				}

				//Init : Picker_HS
				{
					addChild(m_Param.m_Picker_HS);

					m_Param.m_Picker_HS.Init(m_Param);

					m_Param.m_Picker_HS.x = 10;
					m_Param.m_Picker_HS.y = 10;
				}

				//Init : Picker_B
				{
					addChild(m_Param.m_Picker_B);

					m_Param.m_Picker_B.Init(m_Param);

					m_Param.m_Picker_B.x = 10;
					m_Param.m_Picker_B.y = 10 + COLOR_PICKER_H + 10;
				}

				//Init : Palette
				{
					var i:int;
					var Size:int;
					var palette:Palette_Base;

					//L
					{
						const PaletteParam:Array = [
							{H:int(m_Param.m_Picker_HS.BMP_H * 0/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 1/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 2/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 4/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 8/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H *10/12), S:0, B:0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 0/12), S:m_Param.m_Picker_HS.BMP_W-1, B:m_Param.m_Picker_B.BMP_W * 0, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 0/12), S:m_Param.m_Picker_HS.BMP_W-1, B:m_Param.m_Picker_B.BMP_W / 2, A:1},
							{H:int(m_Param.m_Picker_HS.BMP_H * 0/12), S:m_Param.m_Picker_HS.BMP_W-1, B:m_Param.m_Picker_B.BMP_W - 1, A:1},
						];

						Size = PaletteParam.length;
						for(i = 0; i < Size; i += 1){
							palette = new Palette_L();

							if(i == 0){
								m_Param.m_SelectedPalette = palette;
							}

							addChild(palette);

							palette.Init(
								m_Param,
								PaletteParam[i].H,
								PaletteParam[i].S,
								PaletteParam[i].B,
								PaletteParam[i].A
							);

							palette.x = 10 + COLOR_PICKER_W + 32;
							palette.y = 10 + i * 25;
						}
					}

					//R
					{
						Size -= 1;//前回より一段少ないかずにする
						for(i = 0; i < Size; i += 1){
							palette = new Palette_R();

							addChild(palette);

							palette.Init(
								m_Param,
								0,//H
								m_Param.m_Picker_HS.BMP_W-1,//S
								0,//B
								1//A
							);

							palette.x = 10 + COLOR_PICKER_W + 32 + 32;
							palette.y = 10 + (i + 0.5) * 25;
						}
					}
				}

				//Refresh by Default
//				{
//					//上でデフォルトに設定した奴のボタンを擬似的に押す
//					m_Param.m_SelectedPalette.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
//				}
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

//パレットの変更（OnDown）
//→自分を「選ばれたパレット」にする
//→H, S, Bをセット
//→HSピッカーをHSに基づき変更（H,S => カーソル位置, ColorHS）：Refresh
//　→BピッカーをBに基づき変更（B,ColorHS => カーソル位置, 表示色, Color）：Refresh
//　　→キャンバスで使う色の変更（Color => ペン色）
//
//HSピッカーの変更（OnDown）
//→H, Sをセット
//→ColorHSをセット、カーソル位置更新：Refresh
//→BピッカーのHS色を変更（B,ColorHS => 表示色, Color）：Refresh
//　→パレットをHSBに基づき変更（H, S, B、Color => パレット色、保持値）：Refresh
//　→キャンバスで使う色の変更（Color => ペン色）
//
//Bピッカーの変更（OnDown）
//→Bをセット
//→Colorをセット、カーソル位置更新：Refresh
//→パレットをHSBに基づき変更（H, S, B, Color => パレット色、保持値）：Refresh
//→キャンバスで使う色の変更（Color => ペン色）
//
//
//パレットの初期化時
//・H,S,Bが与えられる
//

/*
//Picker_B
{
	//Bをセット
	m_Param.m_BrightnessIndex = m_BrightnessIndex;

	//Colorを求める（ついでにカーソル位置も更新）
	m_Param.m_Picker_B.Refresh();

	//キャンバスで使う色の変更
	m_Param.m_Canvas.SetColor(m_Param.m_Color);

	//パレットの色や値の変更
	m_Param.m_SelectedPalette.Refresh();
}

//Picker_HS
{
	//H, Sをセット
	m_Param.m_HueIndex        = m_HueIndex;
	m_Param.m_SaturationIndex = m_SaturationIndex;

	//ColorHSを求める（ついでにカーソル位置も更新）
	m_Param.m_Picker_HS.Refresh();

	//Bピッカーの更新（Colorを求めてもらう）
	m_Param.m_Picker_B.Refresh();

	//キャンバスで使う色の変更
	m_Param.m_Canvas.SetColor(m_Param.m_Color);

	//パレットの色や値の変更
	m_Param.m_SelectedPalette.Refresh();
}

//Pallete
{
	//自分を「選ばれたパレット」にする
	m_Param.m_SelectedPalette = this;

	//H, S, B, Aをセット
	m_Param.m_HueIndex        = m_HueIndex;
	m_Param.m_SaturationIndex = m_SaturationIndex;
	m_Param.m_BrightnessIndex = m_BrightnessIndex;
	m_Param.m_AlphaIndex      = m_AlphaIndex;

	//HSピッカーの更新（ColorHSも求めてもらう）
	m_Param.m_Picker_HS.Refresh();

	//Bピッカーの更新（Colorを求めてもらう）
	m_Param.m_Picker_B.Refresh();

	//キャンバスで使う色の変更
	m_Param.m_Canvas.SetColor(m_Param.m_Color);
}
//*/

class Param
{
	//このパレットに対応するキャンバス
	public var m_Canvas:MyCanvas;

	//GUIのパーツ
	public var m_SelectedPalette:Palette_Base;//選択中のパレット
	public var m_Picker_HS:Picker_HS;//色相と彩度のピッカー
	public var m_Picker_B:Picker_B;//明度のピッカー

	//パラメータ
	public var m_HueIndex:int;//色相
	public var m_SaturationIndex:int;//彩度
	public var m_BrightnessIndex:int;//明度
	public var m_AlphaIndex:int;//アルファ

	//計算した色
	public var m_ColorHS:uint;
	public var m_Color:uint;//最終的なカラー
}
/*
var param:Param;
{
	//このパレットに対応するキャンバス
	param.m_Canvas = HGE;

	//GUIのパーツ
	param.m_Picker_HS = new Picker_HS();//色相と彩度のピッカー
	param.m_Picker_B = new Picker_B();//明度のピッカー

	//パラメータ
	param.m_HueIndex		= 0;//色相
	param.m_SaturationIndex	= 0;//彩度
	param.m_BrightnessIndex	= 0;//明度
	param.m_AlphaIndex		= 0;//アルファ
}
{
	//Init GUI
	param.m_Picker_HS.Init(param);
	param.m_Picker_B.Init(param);
}
//!!各パレットにparamを渡す
//*/

class Palette_Base extends Image
{
	//==Const==

	//サイズ
	static public const W:int = 20;
	static public const H:int = 20;

	//==Var==

	//値共有用のパラメータ
	public var m_Param:Param;

	//色計算用のパラメータ
	public var m_HueIndex:int;
	public var m_SaturationIndex:int;
	public var m_BrightnessIndex:int;
	public var m_AlphaIndex:int;

	//パレット画像
	public var m_Shape:Shape;


	//==Function==

	//初期化
	public function Init(
		in_Param:Param,
		in_HueIndex:int,
		in_SaturationIndex:int,
		in_BrightnessIndex:int,
		in_AlphaIndex:int
	):void
	{
		//Param
		{
			m_Param = in_Param;

			m_HueIndex			= in_HueIndex;
			m_SaturationIndex	= in_SaturationIndex;
			m_BrightnessIndex	= in_BrightnessIndex;
			m_AlphaIndex		= in_AlphaIndex;
		}

		//Image
		{
			m_Shape = new Shape();
			addChild(m_Shape);
		}

		//mouse
		{
			//関数内でのthisがこのパレットを指さないようなので、一度別の変数に入れて参照する
			var palette:Palette_Base = this;

			addEventListener(
				MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void{
					//自分を「選ばれたパレット」にする
					m_Param.m_SelectedPalette = palette;

					//H, S, B, Aをセット
					m_Param.m_HueIndex        = m_HueIndex;
					m_Param.m_SaturationIndex = m_SaturationIndex;
					m_Param.m_BrightnessIndex = m_BrightnessIndex;
					m_Param.m_AlphaIndex      = m_AlphaIndex;

					//HSピッカーの更新（ColorHSも求めてもらう）
					m_Param.m_Picker_HS.Refresh();

					//Bピッカーの更新（Colorを求めてもらう）
					m_Param.m_Picker_B.Refresh();

					//キャンバスで使う色の変更
					m_Param.m_Canvas.SetColor(m_Param.m_Color);
				}
			);
		}

		//Draw
		{
			//値を一度仮でセットした後、求められた色を自分に適用し、値を元に戻す

			//まずは現在の設定を記憶（後で元に戻すため）
			var HueIndex:int        = m_Param.m_HueIndex;
			var SaturationIndex:int = m_Param.m_SaturationIndex;
			var BrightnessIndex:int = m_Param.m_BrightnessIndex;
			var AlphaIndex:int      = m_Param.m_AlphaIndex;
			{//自分の設定に基づく色計算＆適用
				//自分の設定を押し付ける
				m_Param.m_HueIndex        = m_HueIndex;
				m_Param.m_SaturationIndex = m_SaturationIndex;
				m_Param.m_BrightnessIndex = m_BrightnessIndex;
				m_Param.m_AlphaIndex      = m_AlphaIndex;

				//HSに基づく色を求める
				m_Param.m_Picker_HS.Refresh();

				//Bに基づく色を求める
				m_Param.m_Picker_B.Refresh();

				//求めた色で自分のパレット更新
				Refresh();
			}
			{//以前の設定に戻す
				//以前の設定に戻す
				m_Param.m_HueIndex        = HueIndex;
				m_Param.m_SaturationIndex = SaturationIndex;
				m_Param.m_BrightnessIndex = BrightnessIndex;
				m_Param.m_AlphaIndex      = AlphaIndex;

				//カーソル位置なども元に戻す
				m_Param.m_Picker_HS.Refresh();
				m_Param.m_Picker_B.Refresh();
			}
		}
/*
		//最初に作られたパレットを最初に採用する
		{
			if(m_SelectedPalette == null){
				m_SelectedPalette = this;
			}
		}
//*/
	}

	//m_Param.m_Colorに基づく色の更新
	public function Refresh():void{
		//オーバライドして、色と枠を描くようにする
	}
}

class Palette_L extends Palette_Base
{
	//m_Param.m_Colorに基づく色の更新
	override public function Refresh():void{
		var g:Graphics = m_Shape.graphics;

		{//Color
			var color:uint = m_Param.m_Color;

			g.lineStyle(0, 0x000000, 0.0);
			g.beginFill(color & 0xFFFFFF, ((color >>> 24) & 0xFF) / 255.0);

			g.moveTo(0, 0);

			g.lineTo(W, 0);

			g.lineTo(W+W/2, H/2);

			g.lineTo(W, H);

			g.lineTo(0, H);

			g.lineTo(0, 0);

			g.endFill();
		}

		{//Frame
			g.moveTo(0, 0);

			g.lineStyle(1, 0x000000, 0.8);
			g.lineTo(W, 0);

			g.lineStyle(1, 0x303030, 0.8);
			g.lineTo(W+W/2, H/2);

			g.lineStyle(1, 0xB0B0B0, 0.8);
			g.lineTo(W, H);

			g.lineStyle(1, 0xFFFFFF, 0.8);
			g.lineTo(0, H);

			g.lineStyle(1, 0xA0A0A0, 0.8);
			g.lineTo(0, 0);
		}
	}
}

class Palette_R extends Palette_Base
{
	//m_Param.m_Colorに基づく色の更新
	override public function Refresh():void{
		var g:Graphics = m_Shape.graphics;

		{//Color
			var color:uint = m_Param.m_Color;

			g.lineStyle(0, 0x000000, 0.0);
			g.beginFill(color & 0xFFFFFF, ((color >>> 24) & 0xFF) / 255.0);

			g.moveTo(0, 0);

			g.lineTo(W, 0);

			g.lineTo(W, H);

			g.lineTo(0, H);

			g.lineTo(-W/2, H/2);

			g.lineTo(0, 0);

			g.endFill();
		}

		{//Frame
			g.moveTo(0, 0);

			g.lineStyle(1, 0x000000, 0.8);
			g.lineTo(W, 0);

			g.lineStyle(1, 0x606060, 0.8);
			g.lineTo(W, H);

			g.lineStyle(1, 0xFFFFFF, 0.8);
			g.lineTo(0, H);

			g.lineStyle(1, 0xD0D0D0, 0.8);
			g.lineTo(-W/2, H/2);

			g.lineStyle(1, 0x505050, 0.8);
			g.lineTo(0, 0);
		}
	}
}


class Picker_HS extends Image
{
	//==Var==

	//値共有用のパラメータ
	public var m_Param:Param;

	//色計算用のパラメータ
	public var m_HueIndex:int;
	public var m_SaturationIndex:int;

	//カーソル画像
	public var m_Cursor:Sprite;

	//
	public var m_BitmapData:BitmapData;

	//
	public var BMP_W:int;
	public var BMP_H:int;


	//==Function==

	public function Init(in_Param:Param):void{
		//Param
		{
			m_Param = in_Param;
		}

		//Create Bitmap
		{
			BMP_W = Palette_Color.COLOR_PICKER_W;
			BMP_H = Palette_Color.COLOR_PICKER_H;

			m_BitmapData = new BitmapData(BMP_W, BMP_H, false, 0x000000);
			{
				for(var y:int = 0; y < BMP_H; y += 1){//色相：Hue
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

						r_ori = calcVal(1.0 * y / BMP_H + 0.0/3.0);
						g_ori = calcVal(1.0 * y / BMP_H + 2.0/3.0);
						b_ori = calcVal(1.0 * y / BMP_H + 1.0/3.0);
					}

					for(var x:int = 0; x < BMP_W; x += 1){//彩度：Saturation
						//彩度計算
						var ratio:Number = 1.0 * x / BMP_W;

						var r:uint = (r_ori * (1 - ratio)) + (0xFF * ratio);
						var g:uint = (g_ori * (1 - ratio)) + (0xFF * ratio);
						var b:uint = (b_ori * (1 - ratio)) + (0xFF * ratio);

						var color:uint = (r << 16) | (g << 8) | (b << 0);

						//セット
						m_BitmapData.setPixel(x, y, color);
					}
				}
			}

			addChild(new Bitmap(m_BitmapData));
		}

		//Create Cursor
		{
			m_Cursor = new Sprite();
			{
				var gr:Graphics = m_Cursor.graphics;

				const w:int = 10;
				const v:int = 5;

				gr.lineStyle(3, 0x000000, 0.7);

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
		}

		//mouse
		{
			var onChange:Function = function():void{
				//H, Sをセット
				m_Param.m_HueIndex        = Math.min(Math.max(0, mouseY), BMP_H);
				m_Param.m_SaturationIndex = Math.min(Math.max(0, mouseX), BMP_W);

				//ColorHSを求める（ついでにカーソル位置も更新）
				m_Param.m_Picker_HS.Refresh();

				//Bピッカーの更新（Colorを求めてもらう）
				m_Param.m_Picker_B.Refresh();

				//キャンバスで使う色の変更
				m_Param.m_Canvas.SetColor(m_Param.m_Color);

				//パレットの色や値の変更
				m_Param.m_SelectedPalette.Refresh();
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


	//m_ParamのH,Sに基づく更新
	public function Refresh():void{
		//Param
		{
			m_HueIndex        = m_Param.m_HueIndex;
			m_SaturationIndex = m_Param.m_SaturationIndex;
		}
		//Cursor
		{
			m_Cursor.x = m_SaturationIndex;
			m_Cursor.y = m_HueIndex;
		}
		//Calc ColorHS
		{
			var color:uint = m_BitmapData.getPixel(m_SaturationIndex, m_HueIndex);
			m_Param.m_ColorHS = 0xFF000000 | color;
		}
	}
}


class Picker_B extends Image
{
	//==Var==

	//値共有用のパラメータ
	public var m_Param:Param;

	//色計算用のパラメータ
	public var m_BrightnessIndex:int;

	//Bitmap
	public var m_BitmapData:BitmapData;

	//カーソル画像
	public var m_Cursor:Sprite;

	//
	public var BMP_W:int;
	public var BMP_H:int;


	//==Function==

	public function Init(in_Param:Param):void
	{
		//Param
		{
			m_Param = in_Param;
		}

		//Create Bitmap
		{
			BMP_W = Palette_Color.BRIGHTNESS_W;
			BMP_H = Palette_Color.BRIGHTNESS_H;

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
				//Bをセット
				m_Param.m_BrightnessIndex = Math.min(Math.max(0, mouseX), BMP_W);

				//Colorを求める（ついでにカーソル位置も更新）
				m_Param.m_Picker_B.Refresh();

				//キャンバスで使う色の変更
				m_Param.m_Canvas.SetColor(m_Param.m_Color);

				//パレットの色や値の変更
				m_Param.m_SelectedPalette.Refresh();
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

	//描画
	public function Refresh():void{
		//Param
		{
			m_BrightnessIndex = m_Param.m_BrightnessIndex;
		}

		//Redraw
		{
			const BMP_W:int = m_BitmapData.width;
			const BMP_H:int = m_BitmapData.height;

			var r_ori:uint = (m_Param.m_ColorHS >> 16) & 0xFF;
			var g_ori:uint = (m_Param.m_ColorHS >>  8) & 0xFF;
			var b_ori:uint = (m_Param.m_ColorHS >>  0) & 0xFF;

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

		//カーソル位置
		{
			m_Cursor.x = m_BrightnessIndex;
		}

		//Calc ColorHSB
		{
			m_Param.m_Color = 0xFF000000 | m_BitmapData.getPixel(m_BrightnessIndex, 0);
		}
	}
}




