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

		//＃スペース
		static public const SPACE_L:int = 3;
		static public const SPACE_R:int = 3;
		static public const SPACE_U:int = 3;
		static public const SPACE_D:int = 3;
		static public const SPACE_Y:int = 6;


		//＃色のリスト

		static public const COLOR_LIST:Array = [
			[//1st
				0xFFFF0000,//Red
				0xFFFFA500,//Orange
				0xFFFFFF00,//Yellow
				0xFF008000,//Green
				0xFF0000FF,//Blue
				0xFF4B0082,//Blue Pirple
				0xFF800080,//Red Pirple

				0xFFFFFFFF,//White
				0xFF808080,//Gray
				0xFF000000,//Black
			],
			[//2nd //1stの隣接色を合成した色
				0xFFFF5200,
				0xFFFFD200,
				0xFF80C000,
				0xFF004080,
				0xFF2500C8,
				0xFF650081,
				0xFFC02940,

				0xFFC0C0C0,
				0xFF404040,
//				0xFF000000,
			],

			//透明色は別にする
		];


		//==Var==

		//各色に対応したImage
		public var m_ColorImage:Array;//Image[COLOR_LIST_SIZE][]
		public var m_ColorGraphics:Array;//Graphics[COLOR_LIST_SIZE][]

		//対応するキャンバス
		public var m_Canvas:MyCanvas;

		//現在のパレットの表示形式（COLOR_LISTの何段目までを表示するか）
		public var m_PalettePhase:int = 1;

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
				m_Canvas = in_Canvas;
			}

			//==Image==
			{
				var i:int;
				var Size:int;
				var shape:Shape;

				var IndexOffset:int = 0;

				var PhaseNum:int = COLOR_LIST.length;

				//
				{
					m_ColorImage    = new Array(PhaseNum);
					m_ColorGraphics = new Array(PhaseNum);
				}

				//まだ実際には色をつけず、Imageとそれをクリックした時の処理を設定するのみ
				for(var p:int = 0; p < PhaseNum; p += 1){
					Size = COLOR_LIST[p].length;

					m_ColorImage[p] = new Array(Size);
					m_ColorGraphics[p] = new Array(Size);

					for(i = 0; i < Size; i += 1){
						//Graphic
						{
							shape = new Shape();
							m_ColorGraphics[p][i] = shape.graphics;

							m_ColorImage[p][i] = new Image();
							m_ColorImage[p][i].addChild(shape);
							addChild(m_ColorImage[p][i]);
						}

						//Mouse
						{//Down
							var func:Function = function(in_Index:int):Function{
								return function(e:MouseEvent):void{
									SelectColor(in_Index);
								};
							}

							m_ColorImage[p][i].addEventListener(
								MouseEvent.MOUSE_DOWN,
/*
								function(e:MouseEvent):void{
									SelectColor(i + IndexOffset);//この書き方だとiの変動の影響を受ける1
								}
/*/
								func(i + IndexOffset)
								//一度引数として別物にしてやれば大丈夫
//*/
							);
						}
					}

					IndexOffset += Size;
				}
			}

			//色を塗ったりレイアウト構築したり
			{
				//m_PalettePhaseのデフォルトの値に応じて構築
				CreatePalette(m_PalettePhase);
			}

			//カーソルは1stの一番最初の奴に合わせておく
			{
				//m_PalettePhaseのデフォルトの値に応じて構築
				SelectColor(m_PalettePhase);
			}
		}

		//
		public function CreatePalette(in_Phase:int):void{
			//Param
			{
				m_PalettePhase = in_Phase;
			}

			var i:int;
			var p:int;
			var Size:int;
			var lx:int;
			var uy:int;
			var w:int;
			var h:int;

			var PhaseNum:int = COLOR_LIST.length;

			//Draw
			switch(in_Phase){
			case 0://０段目だけ表示
				{//[0]
					//Draw Palette
					p = 0;
					Size = COLOR_LIST[p].length;

					{//Param
//						w = SIZE_W - SPACE_L - SPACE_R;
						h = (SIZE_H - SPACE_U - SPACE_D - SPACE_Y*(Size-1)) / Size;//高さからスペースを除いたものをSizeで分割
						w = h;

						lx = SPACE_L;
						uy = SPACE_U;
					}

					for(i = 0; i < Size; i += 1){
						var g:Graphics = m_ColorGraphics[p][i];

						var color:uint = COLOR_LIST[p][i];

						//gにパレットの絵を描く
						{//Color
							g.lineStyle(0, 0x000000, 0.0);
							g.beginFill(COLOR_LIST[p][i] & 0xFFFFFF, 1.0);//透明色はないと仮定

							g.drawRect(lx, uy, w, h);

							g.endFill();
						}
						{//Frame
							g.moveTo(lx, uy);

							g.lineStyle(1, 0x000000, 0.8);
							g.lineTo(lx+w, uy);

							g.lineStyle(1, 0x606060, 0.8);
							g.lineTo(lx+w, uy+h);

							g.lineStyle(1, 0xFFFFFF, 0.8);
							g.lineTo(lx, uy+h);

							g.lineStyle(1, 0xA0A0A0, 0.8);
							g.lineTo(lx, uy);
						}

						//Offset
						uy += h + SPACE_Y;
					}
				}

				{//[1]～
					//No Draw => Clear
					for(p = 1; p < PhaseNum; p += 1){
						Size = COLOR_LIST[p].length;

						for(i = 0; i < Size; i += 1){
							m_ColorGraphics[p][i].clear();
						}
					}
				}
				break;
			case 1://０段と１段を表示
				{//[0]
					//Draw Palette
					p = 0;
					Size = COLOR_LIST[p].length;

					{//Param
//						w = SIZE_W - SPACE_L - SPACE_R;
						h = (SIZE_H - SPACE_U - SPACE_D - SPACE_Y*(Size-1)) / Size;//高さからスペースを除いたものをSizeで分割
						w = h;

						lx = SPACE_L;
						uy = SPACE_U;
					}

					for(i = 0; i < Size; i += 1){
						var g:Graphics = m_ColorGraphics[p][i];

						var color:uint = COLOR_LIST[p][i];

						//gにパレットの絵を描く
						{//Color
							g.lineStyle(0, 0x000000, 0.0);
							g.beginFill(COLOR_LIST[p][i] & 0xFFFFFF, 1.0);//透明色はないと仮定

							g.moveTo(lx, uy);

							g.lineTo(lx+w, uy);

							g.lineTo(lx+w+w/2, uy+h/2);

							g.lineTo(lx+w, uy+h);

							g.lineTo(lx, uy+h);

							g.lineTo(lx, uy);

							g.endFill();
						}
						{//Frame
							g.moveTo(lx, uy);

							g.lineStyle(1, 0x000000, 0.8);
							g.lineTo(lx+w, uy);

							g.lineStyle(1, 0x303030, 0.8);
							g.lineTo(lx+w+w/2, uy+h/2);

							g.lineStyle(1, 0xB0B0B0, 0.8);
							g.lineTo(lx+w, uy+h);

							g.lineStyle(1, 0xFFFFFF, 0.8);
							g.lineTo(lx, uy+h);

							g.lineStyle(1, 0xA0A0A0, 0.8);
							g.lineTo(lx, uy);
						}

						//Offset
						uy += h + SPACE_Y;
					}
				}

				{//[1]
					//Draw Palette
					p = 1;
					Size = COLOR_LIST[p].length;

					{//Param
//						w = SIZE_W - SPACE_L - SPACE_R;
//						h = (SIZE_H - SPACE_U - SPACE_D - SPACE_Y*(Size-1)) / Size;//高さからスペースを除いたものをSizeで分割
//						w = h;
						//wとhの値は[0]のものを流用す

						lx = SPACE_L + w*1.7;
						uy = SPACE_U + h/2 + SPACE_Y/2;
					}

					for(i = 0; i < Size; i += 1){
						var g:Graphics = m_ColorGraphics[p][i];

						var color:uint = COLOR_LIST[p][i];

						//gにパレットの絵を描く
						{//Color
							g.lineStyle(0, 0x000000, 0.0);
							g.beginFill(COLOR_LIST[p][i] & 0xFFFFFF, 1.0);//透明色はないと仮定

							g.moveTo(lx, uy);

							g.lineTo(lx+w, uy);

							g.lineTo(lx+w, uy+h);

							g.lineTo(lx, uy+h);

							g.lineTo(lx-w/2, uy+h/2);

							g.lineTo(lx, uy);

							g.endFill();
						}
						{//Frame
							g.moveTo(lx, uy);

							g.lineStyle(1, 0x000000, 0.8);
							g.lineTo(lx+w, uy);

							g.lineStyle(1, 0x606060, 0.8);
							g.lineTo(lx+w, uy+h);

							g.lineStyle(1, 0xFFFFFF, 0.8);
							g.lineTo(lx, uy+h);

							g.lineStyle(1, 0xD0D0D0, 0.8);
							g.lineTo(lx-w/2, uy+h/2);

							g.lineStyle(1, 0x505050, 0.8);
							g.lineTo(lx, uy);
						}

						//Offset
						uy += h + SPACE_Y;
					}
				}

				{//[2]～
					//No Draw => Clear
					for(p = 2; p < PhaseNum; p += 1){
						Size = COLOR_LIST[p].length;

						for(i = 0; i < Size; i += 1){
							m_ColorGraphics[p][i].clear();
						}
					}
				}
				break;
			}
		}

		//指定したIndexの色を採用する時の処理
		public function SelectColor(in_Index:int):void{
			var Size:int;

			var PhaseNum:int = COLOR_LIST.length;

			var index:int = in_Index;
			for(var p:int = 0; p < PhaseNum; p += 1){
				Size = COLOR_LIST[p].length;

				if(index < Size){//この段のパレットに含まれていれば対応する処理を行う
					//キャンバスで使う色を変更
					m_Canvas.SetColor(COLOR_LIST[p][index]);

					//カーソル位置を変更
					ResetCursor(in_Index);

					return;
				}

				index -= Size;
			}
		}

		//カーソルの位置と形状を変更
		public function ResetCursor(in_Index:int):void{
			switch(m_PalettePhase){
			case 0://０段目だけ表示の時
				break;
			}
		}
	}
}
