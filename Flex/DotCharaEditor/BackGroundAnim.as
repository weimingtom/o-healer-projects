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

	public class BackGroundAnim extends Image{
		//==Const==

		static public const COLOR_WHITE:uint = 0xAAAAAA;//0xEEEEEE;
		static public const COLOR_BLACK:uint = 0x999999;//0xEEEEEE;

		//==Var==

		//#サイズ
		public var SIZE_W:int = 100;
		public var SIZE_H:int = 100;

		//#マスのサイズ
		public var BLOCK_SIZE:int = 16;

		//背景画像
		public var m_Shape:Shape;

		//スクロール用オフセット
		public var m_Offset:Number = 0;


		//==Function==

		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function BackGroundAnim(in_W:int, in_H:int, in_Size:int = 16){
			//Size
			{
				SIZE_W = in_W;
				SIZE_H = in_H;

				BLOCK_SIZE = in_Size;
			}

			//Image
			{
				m_Shape = new Shape();

				//Draw
				{
					var g:Graphics = m_Shape.graphics;

					//Reset
					{
						g.clear();

						g.lineStyle(1, 0x000000, 0.0);
					}

					//White
					{
						g.beginFill(COLOR_WHITE, 1.0);

						g.drawRect(-BLOCK_SIZE, -BLOCK_SIZE, in_W+BLOCK_SIZE, in_H+BLOCK_SIZE);

						g.endFill();
					}

					//Black
					{
						g.beginFill(COLOR_BLACK, 1.0);

						//格子状になるように描画と非描画を繰り返す
						var DrawFlag_Start:Boolean = true;
						var DrawFlag:Boolean = true;

						for(var x:int = -BLOCK_SIZE; x < SIZE_W; x += BLOCK_SIZE){
							DrawFlag = DrawFlag_Start;

							for(var y:int = -BLOCK_SIZE; y < SIZE_H; y += BLOCK_SIZE){
								if(DrawFlag){
									g.drawRect(x, y, BLOCK_SIZE, BLOCK_SIZE);
								}

								DrawFlag = !DrawFlag;
							}

							DrawFlag_Start = !DrawFlag_Start;
						}

						g.endFill();
					}
				}

				//Regist
				{
					addChild(m_Shape);
				}
			}

			//Mask
			{
				var MaskImage:Shape = new Shape();

				{
//					var g:Graphics = MaskImage.graphics;
					g = MaskImage.graphics;

					//Reset
					{
						g.clear();

						g.lineStyle(1, 0x000000, 0.0);
					}

					//White
					{
						g.beginFill(0xFFFFFF, 1.0);

						g.drawRect(0, 0, in_W, in_H);

						g.endFill();
					}
				}

				this.addChild(MaskImage);
				this.mask = MaskImage;
			}

			//Call Update
			{
				addEventListener(Event.ENTER_FRAME, Update);
			}
		}

		//!スクロールさせる
		public function Update(e:Event = null):void{
			//スクロール量(m_Offset)の計算
			{//0～BLOCK_SIZEの間に収まるように
				m_Offset += 0.5;//* DeltaTime*60

				while(m_Offset >= BLOCK_SIZE){
					m_Offset -= BLOCK_SIZE;
				}
			}

			//適用
			{
				m_Shape.x = m_Offset;
				m_Shape.y = m_Offset;
			}
		}
	}
}

