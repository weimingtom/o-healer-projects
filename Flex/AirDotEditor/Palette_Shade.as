//author Show=O=Healer

/*
法線のベクトルを求めるところから、法線マップの値を計算するところまではここでやる
法線マップの値（とライトやマテリアル）から実際の色を計算するのはよそに任せる
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

	public class Palette_Shade extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 200;
		static public const SIZE_H:int = 300;



		//==Var==

		//各値に対応したImage
		public var m_Layer:Array;//Layer[PRIORITY_NUM]
//*
		public var m_Image:Array;//Image[NUM_Y][NUM_X]
		public var m_Graphics:Array;//Graphics[NUM_Y][NUM_X]
/*/
		public var m_Image:Image;
		public var m_IndexBitmapData:BitmapData;
//*/
		public var m_Nrm:Array;//Nrm[NUM_Y][NUM_X]

		//対応するキャンバス
		public var m_Canvas:MyCanvas;

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
/*
				{
					var shape:Shape = new Shape();
					{
						var g:Graphics = shape.graphics;

						g.lineStyle(0, 0x000000, 0.0);
						g.beginFill(color, 1.0);

						g.drawRect(x*40, y*40, 32, 32);

						g.endFill();
					}
				}
/*/
				var x:int;
				var y:int;
				const PRIORITY_NUM:int = 5;
				const PRIORITY_MAP:Array = [
					[0, 2, 1, 2, 0, 2, 1, 2, 0],
					[2, 1, 4, 3, 1, 3, 4, 1, 2],
					[1, 4, 0, 2, 0, 2, 0, 4, 1],
					[2, 3, 2, 2, 1, 2, 2, 3, 2],
					[0, 1, 0, 1, 0, 1, 0, 1, 0],
					[2, 3, 2, 2, 1, 2, 2, 3, 2],
					[1, 4, 0, 2, 0, 2, 0, 4, 1],
					[2, 1, 4, 3, 1, 3, 4, 1, 2],
					[0, 2, 1, 2, 0, 2, 1, 2, 0],
				];
				var NumXY:int = PRIORITY_MAP.length;
				var CenterX:Number = (NumXY-1)/2.0;
				var CenterY:Number = (NumXY-1)/2.0;
				const PALETTE_W:int = 20;

				m_Layer = new Array(PRIORITY_NUM);
				{
					for(var i:int = PRIORITY_NUM-1; i >= 0; i -= 1){
						m_Layer[i] = new Image();
						addChild(m_Layer[i]);
					}
				}

				m_Image    = new Array(NumXY);
				m_Graphics = new Array(NumXY);
				m_Nrm      = new Array(NumXY);

				for(y = 0; y < NumXY; y += 1){
					m_Image[y]    = new Array(NumXY);
					m_Graphics[y] = new Array(NumXY);
					m_Nrm[y]      = new Array(NumXY);

					for(x = 0; x < NumXY; x += 1){
						//Calc Nrm
						var nrm:Vector3D;
						{
							//画像と同じく、右がX+、下がY+とする
							var RotZ:Number;
							{
								//X+:0/4, Y+:1/4, X-:2/4, Y-:3/4
								var GapX:Number = x - CenterX;
								var GapY:Number = y - CenterY;

								if(GapX == 0.0 && GapY == 0.0){
									RotZ = 0;//tekitou
								}else{
									RotZ = Math.atan2(GapY, GapX);
								}
							}

							var RotXY:Number;
							{
								var Phase:int;
								{//0:中心、Num/2:外側
									Phase = Math.max(Math.abs(GapX), Math.abs(GapY));
								}

								RotXY = 0.5*Math.PI * Phase/(Math.floor(NumXY/2)+1);
							}

							var DirXY:Vector3D = new Vector3D(Math.cos(RotZ), Math.sin(RotZ), 0.0);

							//LerpByTheta(AxisZ, DirXY, RotXY)
							var RatioZ:Number = Math.cos(RotXY);
							var RatioXY:Number = Math.sin(RotXY);
							nrm = new Vector3D(
								DirXY.x * RatioXY,
								DirXY.y * RatioXY,
								1.0 * RatioZ
							);

							//Normalize
							nrm.normalize();
						}

						//Graphic
						{
							var priority:int = PRIORITY_MAP[y][x];

							var shape:Shape = new Shape();
							m_Graphics[y][x] = shape.graphics;

							//あとで画像ロードで置き換えたい
							{
								var g:Graphics = m_Graphics[y][x];
								var color:uint = Canvas_Result.CalcColor(0xFFFFFFFF, NrmVector2NrmColor(nrm));
//								var color:uint = NrmVector2NrmColor(nrm);//法線マップをそのまま表示する場合はこちらで

								var val_ratio:Number = 1.0 * (PRIORITY_NUM - priority) / PRIORITY_NUM;
								var color_frame:uint = 0x000088;//(uint(0xFF * val_ratio) << 16) | (uint(0x80 * val_ratio) << 8) | (0 << 0);
								var alpha_frame:Number = 0.2 + 0.8*val_ratio;
								g.lineStyle(1, color_frame, alpha_frame);
								g.beginFill(color, 1.0);

//								g.drawRect(x*40, y*40, 32, 32);
								var RelPos:Vector3D = new Vector3D(x*PALETTE_W - CenterX*PALETTE_W, y*PALETTE_W - CenterY*PALETTE_W);
								var RelPosLen:Number = RelPos.length;
								if(RelPosLen > 0.01){
									RelPos.scaleBy(Math.max(Math.abs(x*PALETTE_W-CenterX*PALETTE_W), Math.abs(y*PALETTE_W-CenterY*PALETTE_W)) / RelPosLen);
								}
								g.drawRect(CenterX*PALETTE_W + RelPos.x, CenterY*PALETTE_W + RelPos.y, PALETTE_W, PALETTE_W);

								g.endFill();
							}

							m_Image[y][x] = new Image();
							m_Image[y][x].addChild(shape);

							m_Layer[priority].addChild(m_Image[y][x]);
						}

						//Nrm
						{
							m_Nrm[y][x] = nrm;
						}

						//Mouse
						{//Down
							var func:Function = function(in_Nrm:Vector3D):Function{
								return function(e:MouseEvent):void{
									SelectNrm(in_Nrm);
								};
							}

							m_Image[y][x].addEventListener(
								MouseEvent.MOUSE_DOWN,
								func(nrm)
							);
						}
					}
				}
//*/
			}

/*
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
//*/
		}

/*
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
						var g:Graphics = m_Graphics[p][i];

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
							m_Graphics[p][i].clear();
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
						var g:Graphics = m_Graphics[p][i];

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
						var g:Graphics = m_Graphics[p][i];

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
							m_Graphics[p][i].clear();
						}
					}
				}
				break;
			}
		}
//*/

		//NrmVector => NrmColor
		static public function NrmVector2NrmColor(in_Nrm:Vector3D):uint{
			var color:uint;
			{
				var a:uint = 0xFF;
				var r:uint = 0xFF * (0.5 + 0.5*in_Nrm.x);
				var g:uint = 0xFF * (0.5 + 0.5*in_Nrm.y);
				var b:uint = 0xFF * (0.5 + 0.5*in_Nrm.z);

				color = (a << 24) | (r << 16) | (g << 8) | (b << 0);
			}

			return color;
		}

		//指定した法線を採用する時の処理
		public function SelectNrm(in_Nrm:Vector3D):void{
//*
			m_Canvas.SetColor(NrmVector2NrmColor(in_Nrm));
/*/
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
//*/
		}

/*
		//カーソルの位置と形状を変更
		public function ResetCursor(in_Index:int):void{
			switch(m_PalettePhase){
			case 0://０段目だけ表示の時
				break;
			}
		}
//*/
	}
}
