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

		//選択中のIndex
		public var m_CursorIndex:int = 0;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//パレット画像
		public var m_Palette:Array;//vec<Bitmap>

		//カーソル画像
		public var m_Cursor:Sprite;

		//リスナのリスト
		public var m_ListenerList_ChangeColor:Array = [];
		public var m_ListenerList_ChangeIndex:Array = [];//選択しているものが変わったら呼ばれる関数のリスト


		//==Function==

		//#Public

		//色の取得
		public function GetColor(in_Index:int = -1):uint{
			if(in_Index < 0){
				return m_Palette[m_CursorIndex].bitmapData.getPixel32(PALETTE_SIZE_W/2, 0);
			}else{
				return m_Palette[in_Index].bitmapData.getPixel32(PALETTE_SIZE_W/2, 0);
			}
		}

		//選択されているIndexまわり
		public function GetCursorIndex():int{
			return m_CursorIndex;
		}
		public function SetCursorIndex(in_Index:int):void{
			//Set Val
			{
				m_CursorIndex = in_Index;
			}

			//Change Cursor Pos
			{
				if((in_Index & 1) == 0){
					m_Cursor.x = m_Palette[m_CursorIndex].parent.parent.x;
					m_Cursor.y = m_Palette[m_CursorIndex].parent.parent.y;

					m_Cursor.scaleX =  1;
				}else{
					m_Cursor.x = m_Palette[m_CursorIndex].parent.parent.x + PALETTE_SIZE_W*1.5;
					m_Cursor.y = m_Palette[m_CursorIndex].parent.parent.y;

					m_Cursor.scaleX = -1;
				}
			}

			//Call Listener
			{
				for(var i:int = 0; i < m_ListenerList_ChangeIndex.length; i++){
					m_ListenerList_ChangeIndex[i]();
				}
			}
		}

		//変更時のリスナを追加
		public function SetListener_ChangeColor(in_Func:Function):void{
			m_ListenerList_ChangeColor.push(in_Func);
		}
		public function SetListener_ChangeIndex(in_Func:Function):void{
			m_ListenerList_ChangeIndex.push(in_Func);
		}


		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function Palette_Color(){
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}

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

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(e:Event):void{
			var i:int;

			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//Init Once
			{
				removeEventListener(Event.ADDED_TO_STAGE, Init);
			}

			//ResetGraphic
			{
				while(this.numChildren > 0){
					removeChildAt(0);
				}
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
								SetCursorIndex(index);
							}
						);
					}
				});
			}

			//Create Cursor
			{
				m_Cursor = new Sprite();
				{
					var g:Graphics = m_Cursor.graphics;

					g.lineStyle(2, 0xFFFFFF, 0.7);

					//枠
					DrawPalette(g);

					//矢印
					g.moveTo(0, PALETTE_SIZE_W/2);
					g.lineTo(-PALETTE_SIZE_W/2, PALETTE_SIZE_W*1/4);
					g.lineTo(-PALETTE_SIZE_W/2, PALETTE_SIZE_W*3/4);
					g.lineTo(0, PALETTE_SIZE_W/2);
				}

				m_Cursor.x = m_Palette[m_CursorIndex].x;
				m_Cursor.y = m_Palette[m_CursorIndex].y;

				m_Root.addChild(m_Cursor);
			}
		}

		//描画
		public function Redraw(in_Color:uint, in_Index:int = -1):void{//!!Use
			//in_Index
			if(in_Index < 0){
				in_Index = m_CursorIndex;
			}

			//Draw
			m_Palette[in_Index].bitmapData.fillRect(m_Palette[in_Index].bitmapData.rect, in_Color);

			//Call Listener
			{
				for(var i:int = 0; i < m_ListenerList_ChangeColor.length; i++){
					m_ListenerList_ChangeColor[i]();
				}
			}
		}
	}
}

