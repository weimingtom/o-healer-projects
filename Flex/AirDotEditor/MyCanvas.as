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
	import flash.ui.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class MyCanvas extends Canvas{
		//==Const==

		//#描けるドット数
		static public const DOT_NUM:int = 32;

		//#何倍に拡大して表示するか
		static public const SIZE_RATIO:int = 5;

		//＃サイズ
		static public const SIZE_W:int = DOT_NUM * SIZE_RATIO;
		static public const SIZE_H:int = DOT_NUM * SIZE_RATIO;


		//＃グリッドごとのドットの幅
		public const GRID_OFFSET:Array = [
			DOT_NUM/8,//GRID_TYPE_8x8
			DOT_NUM/16,//GRID_TYPE_16x16
			DOT_NUM/32,//GRID_TYPE_32x32
		];


		//==Var==

		//＃Bitmap
		public var m_Bitmap:Bitmap;

		//＃Cursor
		public var m_Cursor:Image;
		//static変数を使って、他のカーソルと同期させる
		public var m_GlobalCursorIndex:int;//カーソル全体での連番
		static public var m_CursorFlag:Array = [];//vector<Boolean> カーソルが範囲内にあるやつはtrue
		static public var m_CursorGraphics:Array = [];//vector<Graphics>
		public var m_CursorColorAnimTimer:Number = 0.0;
		public var m_CursorAlphaAnimTimer:Number = 0.0;

		//＃Grid
		public var m_Grid:Array;
		public var m_GridType:int = GridButton.GRID_TYPE_8x8;//GRID_TYPE_32x32;//

		//＃選択中のツール
		//全キャンバスで共通にしてしまうため、staticにする
		static public var m_ToolIndex:int = ToolButton.TOOL_PEN;


		//=継承先で変更するもの=

		//描画色
		public var m_Color:uint = 0xFF000000;

		//Bitmapをクリアするときの色
		public var m_ClearColor:uint = 0x00000000;


		//==Function==

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init():void{
			var i:int;
			var j:int;

			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;
			}

			//==Bitmap==
			{
				//Ori : Bitmap
				{
					var bmp_data:BitmapData = new BitmapData(DOT_NUM, DOT_NUM, true, m_ClearColor);
					m_Bitmap  = new Bitmap(bmp_data);
				}

				//Zoom : Image
				{
					var img:Image = new Image();
					img.addChild(m_Bitmap);

					img.scaleX = SIZE_RATIO;
					img.scaleY = SIZE_RATIO;

					addChild(img);
				}
			}

			//==Grid==
			{
				m_Grid = new Array(GridButton.GRID_TYPE_NUM);
				for(i = 0; i < GridButton.GRID_TYPE_NUM; i += 1){
					var shape:Shape = new Shape();
					{
						var g:Graphics = shape.graphics;
						{
							g.lineStyle(1, 0x000000, 0.1);

							var GridOffset:int = GRID_OFFSET[i] * SIZE_RATIO;
							var Size:int = DOT_NUM * SIZE_RATIO;

							for(j = GridOffset; j < Size; j += GridOffset){
								//縦線
								g.moveTo(j, 0);
								g.lineTo(j, Size);
								//横線
								g.moveTo(0,    j);
								g.lineTo(Size, j);
							}
						}
					}

					m_Grid[i] = new Image();
					m_Grid[i].addChild(shape);
				}

				addChild(m_Grid[m_GridType]);
			}

			//==Cursor==
			{
				//Index
				{//全体で何番目か
					//Index
					m_GlobalCursorIndex = m_CursorFlag.length;

					//インクリメントを兼ねて、自分のところに適当に値を詰めておく
					m_CursorFlag.push(false);//このIndexによるカーソルの表示はなしとする
				}
				//Image
				{
					m_Cursor = new Image();

					{
						var sprite:Sprite = new Sprite();

						m_Cursor.addChild(sprite);

						m_CursorGraphics.push(sprite.graphics);

						//最初は何も描かないことで非表示にしておく
					}

					addChild(m_Cursor);
				}
			}

			//==Mouse==
			{
				//Down
				addEventListener(//Down位置はこれの上を検出する必要があるので普通にaddEventListener
					MouseEvent.MOUSE_DOWN,
					OnMouseDown
				);

				//Up
				root.addEventListener(//これの範囲外でマウスが動いたり離されたりするので、以降はRootにつける
					MouseEvent.MOUSE_UP,
					OnMouseUp
				);

				//Move
				root.addEventListener(
					MouseEvent.MOUSE_MOVE,
					OnMouseMove
				);

				//RangeIn
				addEventListener(
					MouseEvent.ROLL_OVER,
					OnMouseIn
				);

				//RangeOut
				addEventListener(
					MouseEvent.ROLL_OUT,
					OnMouseOut
				);
			}

			//==Update==
			{
				addEventListener(
					"enterFrame",
					function(event:Event):void {Update();}
				);
			}
		}

		//==Mouse==

		//クリックしているか（Updateで参照したりレンジアウトに対応するため）
		public var m_IsMouseDown:Boolean = false;

		//開始位置
		public var m_SrcPosX:int = 0;
		public var m_SrcPosY:int = 0;

		//開始直前のBitmap
		public var m_BitmapData_Ori:BitmapData;

		public function OnMouseDown(e:MouseEvent):void{
			//開始位置を記憶
			{
				m_SrcPosX = m_Bitmap.mouseX;
				m_SrcPosY = m_Bitmap.mouseY;
			}

			//Flag
			{
				if(! m_IsMouseDown){
					m_IsMouseDown = true;
				}else{
					return;
				}
			}

			//ツールごとの処理
			switch(m_ToolIndex){
			//
			case ToolButton.TOOL_PEN:
				DrawLine(m_SrcPosX, m_SrcPosY, m_SrcPosX, m_SrcPosY);
				break;
			//
			case ToolButton.TOOL_SPRAY:
				break;
			//
			case ToolButton.TOOL_PAINT:
				DrawPaint(m_SrcPosX, m_SrcPosY);
				break;
			//
			case ToolButton.TOOL_LINE:
			case ToolButton.TOOL_RECT:
			case ToolButton.TOOL_CIRCLE:
				//開始直前のBitmapを覚えておき、これに上書きしたものを毎フレーム見せて確認させる
				m_BitmapData_Ori = m_Bitmap.bitmapData.clone();
				break;
			//
			case ToolButton.TOOL_SPOIT:
				SetColor(m_Bitmap.bitmapData.getPixel32(m_Bitmap.mouseX, m_Bitmap.mouseY));
				break;
			}
		}

		public function OnMouseUp(e:MouseEvent):void{
			//Flag
			{
				if(m_IsMouseDown){
					m_IsMouseDown = false;
				}else{
					return;
				}
			}

			//ツールごとの処理
			switch(m_ToolIndex){
			//
			case ToolButton.TOOL_PEN:
				break;
			//
			case ToolButton.TOOL_SPRAY:
				break;
			//
			case ToolButton.TOOL_PAINT:
				break;
			//
			case ToolButton.TOOL_LINE:
				DrawLine(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
				break;
			case ToolButton.TOOL_RECT:
				DrawRect(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
				break;
			case ToolButton.TOOL_CIRCLE:
				DrawCircle(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
				break;
			//
			case ToolButton.TOOL_SPOIT:
				SetColor(m_Bitmap.bitmapData.getPixel32(m_Bitmap.mouseX, m_Bitmap.mouseY));
				break;
			}
		}

		public function OnMouseMove(e:MouseEvent):void{
			if(m_IsMouseDown){
				//ツールごとの処理
				switch(m_ToolIndex){
				//
				case ToolButton.TOOL_PEN:
					//
					DrawLine(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
					//
					m_SrcPosX = m_Bitmap.mouseX;
					m_SrcPosY = m_Bitmap.mouseY;
					//
					break;
				//
				case ToolButton.TOOL_SPRAY:
					break;
				//
				case ToolButton.TOOL_PAINT:
					break;
				//
				case ToolButton.TOOL_LINE:
				case ToolButton.TOOL_RECT:
				case ToolButton.TOOL_CIRCLE:
					break;
				//
				case ToolButton.TOOL_SPOIT:
					SetColor(m_Bitmap.bitmapData.getPixel32(m_Bitmap.mouseX, m_Bitmap.mouseY));
					break;
				}
			}
		}

		public function OnMouseIn(e:MouseEvent):void{
		}

		public function OnMouseOut(e:MouseEvent):void{
		}

		public function Update():void{
			var DeltaTime:Number = 1.0 / 20.0;

			//Tool
			{
				if(m_IsMouseDown){
					switch(m_ToolIndex){
					//
					case ToolButton.TOOL_PEN:
						break;
					//
					case ToolButton.TOOL_SPRAY:
						//!!
						break;
					//
					case ToolButton.TOOL_PAINT:
						break;
					//
					case ToolButton.TOOL_LINE:
						//Oriでリセット
						{
							m_Bitmap.bitmapData = m_BitmapData_Ori.clone();
						}
						//Draw
						{
							DrawLine(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
						}
						break;
					case ToolButton.TOOL_RECT:
						//Oriでリセット
						{
							m_Bitmap.bitmapData = m_BitmapData_Ori.clone();
						}
						//Draw
						{
							DrawRect(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
						}
						break;
					case ToolButton.TOOL_CIRCLE:
						//Oriでリセット
						{
							m_Bitmap.bitmapData = m_BitmapData_Ori.clone();
						}
						//Draw
						{
							DrawCircle(m_SrcPosX, m_SrcPosY, m_Bitmap.mouseX, m_Bitmap.mouseY);
						}
						break;
					//
					case ToolButton.TOOL_SPOIT:
						break;
					}
				}
			}

			//Cursor
			{
				var i:int;
				var CursorNum:int = m_CursorFlag.length;

				var IsRangeIn:Boolean = true;
				{
					if(mouseX < 0){IsRangeIn = false;}
					if(SIZE_W <= mouseX){IsRangeIn = false;}
					if(mouseY < 0){IsRangeIn = false;}
					if(SIZE_H <= mouseY){IsRangeIn = false;}
				}

				if(IsRangeIn){
					m_CursorFlag[m_GlobalCursorIndex] = true;

					const CURSOR_COLOR_ANIM_TIME:Number = 5.6789;
					const CURSOR_ALPHA_ANIM_TIME:Number = 1.0;

					//Timer
					{
						//Color
						{
							m_CursorColorAnimTimer += DeltaTime;

							if(m_CursorColorAnimTimer >= CURSOR_COLOR_ANIM_TIME){
								m_CursorColorAnimTimer -= CURSOR_COLOR_ANIM_TIME;
							}
						}

						//Alpha
						{
							m_CursorAlphaAnimTimer += DeltaTime;

							if(m_CursorAlphaAnimTimer >= CURSOR_ALPHA_ANIM_TIME){
								m_CursorAlphaAnimTimer -= CURSOR_ALPHA_ANIM_TIME;
							}
						}
					}

					//全てのカーソルの形状をここで決定＆描画
					for(i = 0; i < CursorNum; i += 1){
						var graphics:Graphics = m_CursorGraphics[i];

						//Init
						{
							graphics.clear();

//*
							var clamp:Function = function(i_Val:int, i_Min:int, i_Max:int):int{
								//clamp関数は用意されていないようなので自作
								if(i_Val < i_Min){return i_Min;}
								if(i_Val > i_Max){return i_Max;}
								return i_Val;
							}

							var color_ratio:Number = m_CursorColorAnimTimer / CURSOR_COLOR_ANIM_TIME;
							var theta:Number = 2.0*Math.PI * color_ratio;

							var theta_r:Number = theta + 2.0*Math.PI * 0.0/3.0;
							var theta_g:Number = theta + 2.0*Math.PI * 1.0/3.0;
							var theta_b:Number = theta + 2.0*Math.PI * 2.0/3.0;

							var r:uint = clamp(0xFF * (0.5 + 1.5*Math.cos(theta_r)), 0x00, 0xFF);
							var g:uint = clamp(0xFF * (0.5 + 1.5*Math.cos(theta_g)), 0x00, 0xFF);
							var b:uint = clamp(0xFF * (0.5 + 1.5*Math.cos(theta_b)), 0x00, 0xFF);

							var color:uint = (r << 16) | (g << 8) | (b << 0);
/*/
							var val:uint = 0xFF * (0.5 + 0.5*Math.cos(2.0*Math.PI * m_CursorColorAnimTimer / CURSOR_COLOR_ANIM_TIME));
							var color:uint = (val << 16) | (val << 8) | (val << 0);
//*/
							var alpha:Number = 0.9;//0.5 + 0.5*Math.cos(2.0*Math.PI * m_CursorAlphaAnimTimer/CURSOR_ALPHA_ANIM_TIME);

							graphics.lineStyle(1, color, alpha);
						}

						var GridOffset:int = GRID_OFFSET[m_GridType] * SIZE_RATIO;
						var Size:int = DOT_NUM * SIZE_RATIO;

						//Draw Rect
						{
							var lx:int = mouseX;
							var uy:int = mouseY;
							{//グリッドに合わせる
								lx /= GridOffset; lx *= GridOffset;
								uy /= GridOffset; uy *= GridOffset;
							}

							{
								graphics.moveTo(lx, uy);
								graphics.lineTo(lx, uy+GridOffset);
								graphics.lineTo(lx+GridOffset, uy+GridOffset);
								graphics.lineTo(lx+GridOffset, uy);
								graphics.lineTo(lx, uy);
							}
						}

//						//通常のマウスは非表示にしてしまう
//						Mouse.hide();
					}
				}else{
					m_CursorFlag[m_GlobalCursorIndex] = false;

					//他のも全部オフならカーソルの描画を消す
					var CursorVisible:Boolean = false;
					{
						for(i = 0; i < CursorNum; i += 1){
							if(m_CursorFlag[i]){
								CursorVisible = true;
								break;
							}
						}
					}

					if(! CursorVisible){
						for(i = 0; i < CursorNum; i += 1){
							m_CursorGraphics[i].clear();
						}

//						//普通のマウスの表示もオンにする
//						Mouse.show();
					}
				}
			}
		}


		//==Tool==

		//BitmapにShapeを書きこむためのダミーShape（毎回生成しないようにする）
		protected var m_DrawShape:Shape = new Shape();
		public function GetDrawGraphics():Graphics{
			var g:Graphics = m_DrawShape.graphics;
			g.clear();
			return g;
		}

		//同様にBitmapDataも用意
		public var m_DrawBitmapData:BitmapData = new BitmapData(DOT_NUM, DOT_NUM, true, 0x00000000);

		//
		public const m_Mtx_8x8:Matrix   = new Matrix(4,0,0,4, 0,0);
		public const m_Mtx_16x16:Matrix = new Matrix(2,0,0,2, 0,0);
		public const m_Mtx_32x32:Matrix = new Matrix(1,0,0,1, 0,0);

		//#Line (& Pen)
		public function DrawLine(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			//アンチェリをかけたくないので、自前でブレゼンハムのアルゴリズムで描く

			//Gridに合わせてドットを荒くする
			var SrcX:int;
			var SrcY:int;
			var DstX:int;
			var DstY:int;
			{
				switch(m_GridType){
				case GridButton.GRID_TYPE_8x8:
					SrcX = in_SrcX / 4;
					SrcY = in_SrcY / 4;
					DstX = in_DstX / 4;
					DstY = in_DstY / 4;
					break;
				case GridButton.GRID_TYPE_16x16:
					SrcX = in_SrcX / 2;
					SrcY = in_SrcY / 2;
					DstX = in_DstX / 2;
					DstY = in_DstY / 2;
					break;
				case GridButton.GRID_TYPE_32x32:
					SrcX = in_SrcX / 1;
					SrcY = in_SrcY / 1;
					DstX = in_DstX / 1;
					DstY = in_DstY / 1;
					break;
				}
			}

			//ドットを打つローカル関数（グリッド座標が指定されるので、Bitmapに必要なだけ拡大して描画）
			var DrawPoint:Function;
			{
				var GridOffset:int = GRID_OFFSET[m_GridType];

				DrawPoint = function(in_X:int, in_Y:int):void{
					var lx:int = in_X * GridOffset;
					var uy:int = in_Y * GridOffset;
					var rx:int = lx + GridOffset;
					var dy:int = uy + GridOffset;

					for(var x:int = lx; x < rx; x += 1){
						for(var y:int = uy; y < dy; y += 1){
							m_Bitmap.bitmapData.setPixel32(x, y, m_Color);
						}
					}
				}
			}

			//プレゼンハム
			{
				//
				var NextX:int = SrcX;
				var NextY:int = SrcY;

				//移動量
				var DeltaX:int = DstX - SrcX;
				var DeltaY:int = DstY - SrcY;

				//どちら側に移動するか
				var StepX:int = (DeltaX >= 0)? 1: -1;
				var StepY:int = (DeltaY >= 0)? 1: -1;

				//移動量→移動の幅（の２倍）
				DeltaX = 2 * Math.abs(DeltaX);
				DeltaY = 2 * Math.abs(DeltaY);

				//始点に点を打つ
				DrawPoint(NextX, NextY);

				var fraction:int = 0;
				//X++で進むかY++で進むか分岐
				if(DeltaX > DeltaY){
					//X++で進む
					fraction = DeltaY - DeltaX/2;
					while(NextX != DstX){
						//Y++
						{
							if(fraction >= 0){
								NextY += StepY;
								fraction -= DeltaX;
							}
						}

						//X++
						{
							NextX += StepX;
							fraction += DeltaY;
						}

						//Draw
						{
							DrawPoint(NextX, NextY);
						}
					}
				}else{
					//Y++で進む
					fraction = DeltaX - DeltaY/2;
					while(NextY != DstY){
						//X++
						{
							if(fraction >= 0){
								NextX += StepX;
								fraction -= DeltaY;
							}
						}

						//Y++
						{
							NextY += StepY;
							fraction += DeltaX;
						}

						//Draw
						{
							DrawPoint(NextX, NextY);
						}
					}
				}
			}
		}

		//#Rect
		public function DrawRect(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			
			//Gridに合わせてドットを荒くする
			var SrcX:int;
			var SrcY:int;
			var DstX:int;
			var DstY:int;
			{
				switch(m_GridType){
				case GridButton.GRID_TYPE_8x8:
					SrcX = in_SrcX / 4;
					SrcY = in_SrcY / 4;
					DstX = in_DstX / 4;
					DstY = in_DstY / 4;
					break;
				case GridButton.GRID_TYPE_16x16:
					SrcX = in_SrcX / 2;
					SrcY = in_SrcY / 2;
					DstX = in_DstX / 2;
					DstY = in_DstY / 2;
					break;
				case GridButton.GRID_TYPE_32x32:
					SrcX = in_SrcX / 1;
					SrcY = in_SrcY / 1;
					DstX = in_DstX / 1;
					DstY = in_DstY / 1;
					break;
				}

				//Src <= Dstにする
				var temp:int;
				if(SrcX > DstX){temp = SrcX; SrcX = DstX; DstX = temp;}
				if(SrcY > DstY){temp = SrcY; SrcY = DstY; DstY = temp;}
			}

			//ドットを打つローカル関数（グリッド座標が指定されるので、Bitmapに必要なだけ拡大して描画）
			var DrawPoint:Function;
			{
				var GridOffset:int = GRID_OFFSET[m_GridType];

				DrawPoint = function(in_X:int, in_Y:int):void{
					var lx:int = in_X * GridOffset;
					var uy:int = in_Y * GridOffset;
					var rx:int = lx + GridOffset;
					var dy:int = uy + GridOffset;

					for(var x:int = lx; x < rx; x += 1){
						for(var y:int = uy; y < dy; y += 1){
							m_Bitmap.bitmapData.setPixel32(x, y, m_Color);
						}
					}
				}
			}

			//Draw
			{
				//横線
				for(var x:int = SrcX; x <= DstX; x += 1){
					//上の線
					DrawPoint(x, SrcY);
					//下の線
					DrawPoint(x, DstY);
				}
				
				//縦線
				for(var y:int = SrcY; y <= DstY; y += 1){
					//左の線
					DrawPoint(SrcX, y);
					//右の線
					DrawPoint(DstX, y);
				}
			}
		}

		//#Circle
		public function DrawCircle(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):void{
			//アンチェリをかけたくないので、自前で描く

			//Gridに合わせてドットを荒くする
			var SrcX:int;
			var SrcY:int;
			var DstX:int;
			var DstY:int;
			{
				switch(m_GridType){
				case GridButton.GRID_TYPE_8x8:
					SrcX = in_SrcX / 4;
					SrcY = in_SrcY / 4;
					DstX = in_DstX / 4;
					DstY = in_DstY / 4;
					break;
				case GridButton.GRID_TYPE_16x16:
					SrcX = in_SrcX / 2;
					SrcY = in_SrcY / 2;
					DstX = in_DstX / 2;
					DstY = in_DstY / 2;
					break;
				case GridButton.GRID_TYPE_32x32:
					SrcX = in_SrcX / 1;
					SrcY = in_SrcY / 1;
					DstX = in_DstX / 1;
					DstY = in_DstY / 1;
					break;
				}
			}

			//ドットを打つローカル関数（グリッド座標が指定されるので、Bitmapに必要なだけ拡大して描画）
			var DrawPoint:Function;
			{
				var GridOffset:int = GRID_OFFSET[m_GridType];

				DrawPoint = function(in_X:int, in_Y:int):void{
					var lx:int = in_X * GridOffset;
					var uy:int = in_Y * GridOffset;
					var rx:int = lx + GridOffset;
					var dy:int = uy + GridOffset;

					for(var x:int = lx; x < rx; x += 1){
						for(var y:int = uy; y < dy; y += 1){
							m_Bitmap.bitmapData.setPixel32(x, y, m_Color);
						}
					}
				}
			}

			//
			{
				var CenterX:Number = (SrcX + DstX)/2.0;
				var CenterY:Number = (SrcY + DstY)/2.0;

				var RadX:Number = Math.abs(SrcX - DstX)/2.0;
				var RadY:Number = Math.abs(SrcY - DstY)/2.0;

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
						//X+Y+
						DrawPoint(CenterX + OffsetX, CenterY + OffsetY);
						//X+Y-
						DrawPoint(CenterX + OffsetX, CenterY - OffsetY);
						//X-Y+
						DrawPoint(CenterX - OffsetX, CenterY + OffsetY);
						//X-Y-
						DrawPoint(CenterX - OffsetX, CenterY - OffsetY);
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
							//X+Y+
							DrawPoint(CenterX + OffsetX, CenterY + OffsetY);
							//X+Y-
							DrawPoint(CenterX + OffsetX, CenterY - OffsetY);
							//X-Y+
							DrawPoint(CenterX - OffsetX, CenterY + OffsetY);
							//X-Y-
							DrawPoint(CenterX - OffsetX, CenterY - OffsetY);
						}

						//もっと最適化できるはずなんだけど、実用上問題ないのでこのままで
					}
				}
			}
		}

		//#Paint
		public function DrawPaint(in_SrcX:int, in_SrcY:int):void{
			//塗りつぶしはデフォでサポートされてるのでそれを使う
			m_Bitmap.bitmapData.floodFill(in_SrcX, in_SrcY, m_Color);
		}


		//==Grid==

		public function SetGridType(in_GridType:int):void{
			//Check
			{
				//今セットされているのと同じなら何もしない
				if(in_GridType == m_GridType){
					return;
				}
			}

			//Image
			{
				//Remove
				{
					removeChild(m_Grid[m_GridType]);
				}

				//Add
				{
					addChild(m_Grid[in_GridType]);
				}
			}

			//Index
			{
				m_GridType = in_GridType;
			}
		}


		//===Color==

		public function SetColor(in_Color:uint):void{
			m_Color = in_Color;
		}
	}
}
