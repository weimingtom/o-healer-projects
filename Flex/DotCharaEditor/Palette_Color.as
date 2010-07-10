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

	public class Palette_Color extends IPalette{
		//==Const==

		//＃パレット数
		static public const PALETTE_NUM:int = 9;

		//＃サイズ
		static public const PALETTE_SIZE_W:int = 30;//パレットの基本幅
		static public const PALETTE_SIZE_H:int = 30;
		static public const SIZE_W:int = PALETTE_SIZE_W*2.5;//全体の大きさ
		static public const SIZE_H:int = PALETTE_SIZE_H*PALETTE_NUM;//100;

		//＃パレットの形状
		static public const PALETTE_SHAPE:Array = [
			[0, 0],
			[PALETTE_SIZE_W, 0],
			[PALETTE_SIZE_W*1.5, PALETTE_SIZE_W*0.5],
			[PALETTE_SIZE_W, PALETTE_SIZE_W],
			[0, PALETTE_SIZE_W],
		];
		static public var PALETTE_SHAPE_BEZIERED:Array;//最適化用

		//==Var==

		//パレット画像
		public var m_Palette:Array;//vec<Bitmap>


		//==Function==

		//初期化

		override public function init(e:Event=null):void{
			var i:int;

			//Check
			{
				if(m_Root){
					return;//すでに初期化されているようなので何もしない
				}
			}

			//Common Init
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//Init Once
			{
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			//Root
			{
				m_Root = new Image();
				addChild(m_Root);
			}

			//Create Bitmap
			{
				m_Palette = new Array(PALETTE_NUM);

				m_Palette.forEach(function(item:*, index:int, arr:Array):void{
					//Palette Root
					var pal_root:Image;
					{
						pal_root = new Image();
						m_Root.addChild(pal_root);
					}

					//Frame
					{
						var frame:Shape = new Shape();
						{
							var g:Graphics = frame.graphics;

							g.lineStyle(4, 0xFFFFFF, 0.3);

							//枠
							DrawPalette(g);

							if((index & 1) == 1){
								frame.x = PALETTE_SIZE_W*1.5;
								frame.scaleX = -1;
							}
						}

						pal_root.addChild(frame);
					}

					//Content
					var content:Image;
					{
						content = new Image();
						pal_root.addChild(content);
					}

					//BG
					var bg:Image;
					{
						bg = new BackGroundAnim(PALETTE_SIZE_W*1.5, PALETTE_SIZE_H, PALETTE_SIZE_W/2);
						content.addChild(bg);
					}

					//Bitmap
					{
						//create
						var bmp_data:BitmapData = new BitmapData(PALETTE_SIZE_W*1.5, PALETTE_SIZE_H, true, 0x00000000);
						var bmp:Bitmap = new Bitmap(bmp_data);
						m_Palette[index] = bmp;

						//regist
						content.addChild(bmp);
					}

					//Mask
					{
						var maskShape:Shape = new Shape();
						{
							//var g:Graphics = maskShape.graphics;
							g = maskShape.graphics;

							g.lineStyle(0, 0x000000, 0.0);
							g.beginFill(0xFFFFFF, 1.0);

							//枠
							DrawPalette(g);

							g.endFill();

							if((index & 1) == 1){
								maskShape.x = PALETTE_SIZE_W*1.5;
								maskShape.scaleX = -1;
							}
						}
						content.addChild(maskShape);

						content.mask = maskShape;
					}

					//Pos
					{
						pal_root.x = ((index & 1) == 0)? 0: PALETTE_SIZE_W;
						pal_root.y = index * PALETTE_SIZE_H;
					}

					//Listener
					{
						pal_root.addEventListener(
							MouseEvent.MOUSE_DOWN,
							function(e:MouseEvent):void{
								setCursorIndex(index);
							}
						);
					}
				});
			}

			//Create Cursor
			{
				m_Cursor = [new Sprite()];
				{
					var g:Graphics = m_Cursor[0].graphics;

					g.lineStyle(2, 0xFFFFFF, 0.7);

					//枠
					DrawPalette(g);

					//矢印
					g.moveTo(0, PALETTE_SIZE_W/2);
					g.lineTo(-PALETTE_SIZE_W/2, PALETTE_SIZE_W*1/4);
					g.lineTo(-PALETTE_SIZE_W/2, PALETTE_SIZE_W*3/4);
					g.lineTo(0, PALETTE_SIZE_W/2);
				}

				m_Cursor[0].x = m_Palette[m_CursorIndex].x;
				m_Cursor[0].y = m_Palette[m_CursorIndex].y;

				m_Root.addChild(m_Cursor[0]);
			}
		}

		//カーソル変更処理
		override public function setCursorIndex(in_Index:int, in_InputColor:uint = 0xFFFFFFFF):void{
			//Check
			{
				if(m_CursorIndex == in_Index){
					return;//変更の必要がなければ何もしない
				}
			}

			//Param
			{
				m_CursorIndex = in_Index;
			}

			//Change Cursor Pos
			{
				if((in_Index & 1) == 0){
					m_Cursor[0].x = m_Palette[in_Index].parent.parent.x;
					m_Cursor[0].y = m_Palette[in_Index].parent.parent.y;

					m_Cursor[0].scaleX =  1;
				}else{
					m_Cursor[0].x = m_Palette[in_Index].parent.parent.x + PALETTE_SIZE_W*1.5;
					m_Cursor[0].y = m_Palette[in_Index].parent.parent.y;

					m_Cursor[0].scaleX = -1;
				}
			}

			//Next
			{
				onCursorChange(in_Index, GetSelectedColor());
			}
		}

		override public function reset(in_Info:Array, in_InputColor:Array = null):void{
			//Param
			{
				//m_CursorIndex
				{
					if(m_CursorIndex >= in_Info.length){m_CursorIndex = in_Info.length-1;}
				}
			}

			//Graphic
			{
				//パレットの中身の色を更新
				var num:int = m_Palette.length;
				for(var i:int = 0; i < num; i++){
					m_Palette[i].bitmapData.fillRect(m_Palette[i].bitmapData.rect, in_InputColor[i]);
				}
			}

			//Next
			{
				onReset(in_Info, in_InputColor);
			}
		}

		override public function redraw():void{
			m_Palette[m_CursorIndex].bitmapData.fillRect(m_Palette[m_CursorIndex].bitmapData.rect, m_InputColor);
		}

		override public function redraw_cursor():void{
			//何もしない
		}


		//
		override public function GetSelectedColor():uint{
			return m_Palette[m_CursorIndex].bitmapData.getPixel32(0,0);
		}

		//
		public function GetColor(in_Index:int):uint{
			return m_Palette[in_Index].bitmapData.getPixel32(0,0);
		}

		//
		public function SetColor(in_Index:int, in_Color:uint):void{
			m_Palette[in_Index].bitmapData.fillRect(m_Palette[in_Index].bitmapData.rect, in_Color);
		}


		//#Utility

		//カーソル描画用関数
		public function DrawPalette(g:Graphics):void{
			const PointNum:int = PALETTE_SHAPE.length;

/*
			g.moveTo(PALETTE_SHAPE[0][0], PALETTE_SHAPE[0][1]);
			for(var i:int = 1; i < PointNum; i++){
				g.lineTo(PALETTE_SHAPE[i][0], PALETTE_SHAPE[i][1]);
			}
			g.lineTo(PALETTE_SHAPE[0][0], PALETTE_SHAPE[0][1]);
//*/
/*
			const Ratio:Number = 1/8.0;
			for(var i:int = 0; i < PointNum; i++){
				var pos_1:Array = [
					(PALETTE_SHAPE[(i+0)%PointNum][0] * (1 - Ratio)) + (PALETTE_SHAPE[(i+1)%PointNum][0] * Ratio),
					(PALETTE_SHAPE[(i+0)%PointNum][1] * (1 - Ratio)) + (PALETTE_SHAPE[(i+1)%PointNum][1] * Ratio)
				];

				var pos_2:Array = [
					(PALETTE_SHAPE[(i+0)%PointNum][0] * Ratio) + (PALETTE_SHAPE[(i+1)%PointNum][0] * (1 - Ratio)),
					(PALETTE_SHAPE[(i+0)%PointNum][1] * Ratio) + (PALETTE_SHAPE[(i+1)%PointNum][1] * (1 - Ratio))
				];

				var pos_3:Array = [
					(PALETTE_SHAPE[(i+1)%PointNum][0] * (1 - Ratio)) + (PALETTE_SHAPE[(i+2)%PointNum][0] * Ratio),
					(PALETTE_SHAPE[(i+1)%PointNum][1] * (1 - Ratio)) + (PALETTE_SHAPE[(i+2)%PointNum][1] * Ratio)
				];

				//Line
				{
					if(i == 0){
						g.moveTo(pos_1[0], pos_1[1]);//最初の一回以外は不要のはず
					}
					g.lineTo(pos_2[0], pos_2[1]);
				}

				//Curve
				{
					g.curveTo(PALETTE_SHAPE[(i+1)%PointNum][0], PALETTE_SHAPE[(i+1)%PointNum][1], pos_3[0], pos_3[1]);
				}
			}
//*/
//*
			//最適化
			const Ratio:Number = 1/8.0;

			if(PALETTE_SHAPE_BEZIERED == null){
				PALETTE_SHAPE_BEZIERED = new Array(PointNum*3);

				for(var j:int = 0; j < PointNum; j++){
					var Pos1:Array = PALETTE_SHAPE[(j+0)%PointNum];
					var Pos2:Array = PALETTE_SHAPE[(j+1)%PointNum];

					PALETTE_SHAPE_BEZIERED[3*j+0] = [
						(Pos1[0] * (1 - Ratio)) + (Pos2[0] * Ratio),
						(Pos1[1] * (1 - Ratio)) + (Pos2[1] * Ratio)
					];

					PALETTE_SHAPE_BEZIERED[3*j+1] = [
						(Pos1[0] * Ratio) + (Pos2[0] * (1 - Ratio)),
						(Pos1[1] * Ratio) + (Pos2[1] * (1 - Ratio))
					];

					PALETTE_SHAPE_BEZIERED[3*j+2] = [
						Pos2[0],
						Pos2[1]
					];
				}
			}

			var BezPointNum:int = PALETTE_SHAPE_BEZIERED.length;

			g.moveTo(PALETTE_SHAPE_BEZIERED[0][0], PALETTE_SHAPE_BEZIERED[0][1]);//最初の一回以外は不要のはず
			for(var i:int = 0; i < BezPointNum; i += 3){
//				var Pos_1:Array = PALETTE_SHAPE_BEZIERED[(i + 0) % BezPointNum];
				var Pos_2:Array = PALETTE_SHAPE_BEZIERED[(i + 1) % BezPointNum];
				var Pos_3:Array = PALETTE_SHAPE_BEZIERED[(i + 2) % BezPointNum];
				var Pos_4:Array = PALETTE_SHAPE_BEZIERED[(i + 3) % BezPointNum];

				//Line
				{
					g.lineTo(Pos_2[0], Pos_2[1]);
				}

				//Curve
				{
					g.curveTo(Pos_3[0], Pos_3[1], Pos_4[0], Pos_4[1]);
				}
			}
//*/
		}

		//Index => Color
		public function CreateBitmap_FromIndex(in_BitmapData_Index:BitmapData):BitmapData{
			var w:int = in_BitmapData_Index.width;
			var h:int = in_BitmapData_Index.height;

			var bmp_data:BitmapData = new BitmapData(w, h, true, 0x00000000);

			for(var x:int = 0; x < w; x++){
				for(var y:int = 0; y < h; y++){
					bmp_data.setPixel32(x, y, GetColor(in_BitmapData_Index.getPixel(x, y)));
				}
			}

			return bmp_data;
		}
	}
}

