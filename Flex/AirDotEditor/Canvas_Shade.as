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
					var color:uint = Canvas_Result.CalcColor(0xFFFFFFFF, nrm_color, x, y);
					m_Bitmap_Show.bitmapData.setPixel32(x, y, color);
				}
			}
		}

		//==描画関数のoverride==

		//余裕があれば、変更部分だけRedrawするために、描画関数を渡したりしたい

		//#Line (& Pen)
		override public function DrawLine(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			super.DrawLine(in_SrcX, in_SrcY, in_DstX, in_DstY);

			Redraw();
		}

		//#Rect
		override public function DrawRect(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int, in_PaintFlag:Boolean = false):void{
			super.DrawRect(in_SrcX, in_SrcY, in_DstX, in_DstY, in_PaintFlag);

			Redraw();
		}

//*
		//#Circle
		override public function DrawCircle(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int, in_PaintFlag:Boolean = false):void{
			//法線をピクセルごとに計算したいので独自に描く

			var x:Number;

			var GridOffset:int = GRID_OFFSET[m_GridType];

			//Gridに合わせてドットを荒くする
			var SrcX:int;
			var SrcY:int;
			var DstX:int;
			var DstY:int;
			{
				SrcX = in_SrcX / GridOffset;
				SrcY = in_SrcY / GridOffset;
				DstX = in_DstX / GridOffset;
				DstY = in_DstY / GridOffset;
			}

			var CenterX:Number = (SrcX + DstX)/2.0;
			var CenterY:Number = (SrcY + DstY)/2.0;

			var RadX:Number = Math.abs(SrcX - DstX)/2.0;
			var RadY:Number = Math.abs(SrcY - DstY)/2.0;

			//ドットを打つローカル関数（グリッド座標が指定されるので、Bitmapに必要なだけ拡大して描画）
			var DrawPoint:Function;
			{
				DrawPoint = function(in_X:int, in_Y:int):void{
					var lx:int = in_X * GridOffset;
					var uy:int = in_Y * GridOffset;
					var rx:int = lx + GridOffset;
					var dy:int = uy + GridOffset;

					var ratio_x:Number = (in_X - CenterX) / (RadX + 1.0);
					var ratio_y:Number = (in_Y - CenterY) / (RadY + 1.0);
					var ratio_z:Number = Math.sqrt(1.0 - (ratio_x*ratio_x + ratio_y*ratio_y));

					var nrm:Vector3D = new Vector3D(ratio_x, ratio_y, ratio_z);
					nrm.y *= (RadX + 1.0) / (RadY + 1.0);
					nrm.normalize();

					var color:uint = Palette_Shade.NrmVector2NrmColor(nrm);

					for(var x:int = lx; x < rx; x += 1){
						for(var y:int = uy; y < dy; y += 1){
							m_Bitmap.bitmapData.setPixel32(x, y, color);
						}
					}
				}
			}

			//
			{
				var InvRadX:Number;
				var InvRadY:Number;
				{
					if(RadX > 0.0){
						InvRadX = 1.0 / (RadX * RadX);
					}else{
						InvRadX = 1.0;
					}

					if(RadY > 0.0){
						InvRadY = 1.0 / (RadY * RadY);
					}else{
						InvRadY = 1.0;
					}
				}

				//1/(RadX*RadX) * X*X + 1/(RadY*RadY) * Y*Y = 1

				//X+,Y+の範囲を考え、残りの「X+,Y-」「X-,Y+」「X-,Y-」はそれを反転したものを使う
				var OffsetX:Number = RadX;
				var OffsetY:Number = RadY - (int(RadY));

				//「X+,Y0」→「X0,Y+」の曲線を、「X移動」「Y移動」「XY移動」のどちらが適切かを判断しながら移動する
				{
					//始点を打つ
					{
						if(in_PaintFlag){
							//塗りつぶすバージョン

							for(x = OffsetX; x >= 0.0; x -= 1.0){//塗りつぶし用ループ
								//X+Y+
								DrawPoint(CenterX + x, CenterY + OffsetY);
								//X+Y-
								DrawPoint(CenterX + x, CenterY - OffsetY);
								//X-Y+
								DrawPoint(CenterX - x, CenterY + OffsetY);
								//X-Y-
								DrawPoint(CenterX - x, CenterY - OffsetY);
							}
						}else{
							//枠だけ描くバージョン

							//X+Y+
							DrawPoint(CenterX + OffsetX, CenterY + OffsetY);
							//X+Y-
							DrawPoint(CenterX + OffsetX, CenterY - OffsetY);
							//X-Y+
							DrawPoint(CenterX - OffsetX, CenterY + OffsetY);
							//X-Y-
							DrawPoint(CenterX - OffsetX, CenterY - OffsetY);
						}
					}

					while(OffsetX > 0){
						//点を動かす
						{
							//=基本的な考え方=
							//楕円の式は
							//(X*X)/(RadX*RadX) + (Y*Y)/(RadY*RadY) - 1 = 0
							//である。
							//なので、
							//(X*X)/(RadX*RadX) + (Y*Y)/(RadY*RadY) - 1
							//の値をX,Yから求めたものがそのまま誤差になる

							//現状のOffsetX、OffsetYでの誤差
							var Gap:Number = (OffsetX*OffsetX)*InvRadX + (OffsetY*OffsetY)*InvRadY - 1;

							//X-移動した場合の楕円との誤差
							//楕円の式に「X=OffsetX-1、Y=OffsetY」を代入して、「Gap：X=OffsetX,Y=OffsetY」に相当する部分はGapで置き換える
							var GapX:Number = Gap - 2*OffsetX*InvRadX + 1/(RadX*RadX);

							//Y+移動した場合の楕円との誤差
							//Xと同じように求める
							var GapY:Number = Gap + 2*OffsetY*InvRadY + 1*InvRadY;

							//X+Y-も同様
							var GapXY:Number = Gap - 2*OffsetX*InvRadX + 1*InvRadX + 2*OffsetY*InvRadY + 1*InvRadY;

							GapX  = Math.abs(GapX);
							GapY  = Math.abs(GapY);
							GapXY = Math.abs(GapXY);

							//一番誤差が少ない方に進む
							if(GapX < GapY){//X < Y
								if(GapXY < GapX){//XY < X
									OffsetX -= 1.0;
									OffsetY += 1.0;
								}else{//X <= GY
									OffsetX -= 1.0;
								}
							}else{//Y <= X
								if(GapXY < GapY){//XY < Y
									OffsetX -= 1.0;
									OffsetY += 1.0;
								}else{//Y <= XY
									OffsetY += 1.0;
								}
							}
						}

						//点を打つ
						{
							if(in_PaintFlag){
								//塗りつぶすバージョン

								for(x = OffsetX; x >= 0.0; x -= 1.0){//塗りつぶし用ループ
									//X+Y+
									DrawPoint(CenterX + x, CenterY + OffsetY);
									//X+Y-
									DrawPoint(CenterX + x, CenterY - OffsetY);
									//X-Y+
									DrawPoint(CenterX - x, CenterY + OffsetY);
									//X-Y-
									DrawPoint(CenterX - x, CenterY - OffsetY);
								}
							}else{
								//枠だけ描くバージョン

								//X+Y+
								DrawPoint(CenterX + OffsetX, CenterY + OffsetY);
								//X+Y-
								DrawPoint(CenterX + OffsetX, CenterY - OffsetY);
								//X-Y+
								DrawPoint(CenterX - OffsetX, CenterY + OffsetY);
								//X-Y-
								DrawPoint(CenterX - OffsetX, CenterY - OffsetY);
							}
						}

						//もっと最適化できるはずなんだけど、実用上問題ないのでこのままで
					}
				}
			}

			Redraw();
		}
/*/
		//#Circle
		override public function DrawCircle(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			//!!あとで球体のNrmを描くように変更

			super.DrawCircle(in_SrcX, in_SrcY, in_DstX, in_DstY);

			Redraw();
		}
//*/

		//#Paint
		override public function DrawPaint(in_SrcX:int, in_SrcY:int):void{
			super.DrawPaint(in_SrcX, in_SrcY);

			Redraw();
		}
	}
}
