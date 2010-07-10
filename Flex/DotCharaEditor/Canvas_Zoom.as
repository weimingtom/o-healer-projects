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

	public class Canvas_Zoom extends Canvas{
		//==Const==

		//#描けるドット数
		static public const DOT_NUM:int = 32;

		//#何倍に拡大して表示するか
		static public const SIZE_RATIO:int = 7;

		//＃サイズ
		static public const SIZE_W:int = DOT_NUM * SIZE_RATIO;
		static public const SIZE_H:int = DOT_NUM * SIZE_RATIO;

		//＃カーソルのタイプ（カーソルのIndex）
		static public var CursorTypeIter:int = 0;
		static public const CURSOR_TYPE_NORMAL:int		= CursorTypeIter++;
		static public const CURSOR_TYPE_MIRROR_X:int	= CursorTypeIter++;
		static public const CURSOR_TYPE_MIRROR_Y:int	= CursorTypeIter++;
		static public const CURSOR_TYPE_MIRROR_XY:int	= CursorTypeIter++;
		static public const CURSOR_TYPE_NUM:int			= CursorTypeIter;

		//＃カーソルのモード（カーソルをどう動かすか）
		static public var CursorModeIter:int = 0;
		static public const CURSOR_MODE_NORMAL:int				= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_X_16_16:int		= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_X_15_1_15:int	= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_Y_16_16:int		= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_Y_15_1_15:int	= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_XY_16_16:int		= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_XY_15_1_15:int	= CursorModeIter++;
		static public const CURSOR_MODE_NUM:int					= CursorModeIter;


		//==Var==

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//表示画像
		public var m_Bitmap:Bitmap;
		public var m_BitmapData:BitmapData;

		//トレース画像
		public var m_Bitmap_Trace:Bitmap = new Bitmap();

		//パレットIndexやNrmを保持する擬似画像（直接の表示には使わない）
		public var m_BitmapData_Index:BitmapData;

		//グリッド画像
		public var m_Grid:Shape;

		//カーソル画像
		public var m_Cursor:Array;//vec<Shape>：ミラーリングのため、複数のカーソルに対応

		//カーソルのモード（動かし方）
		public var m_CursorMode:int = CURSOR_MODE_NORMAL;

		//リスナのリスト
		public var m_ListenerList_MouseDown:Array = [];
		public var m_ListenerList_MouseMove:Array = [];
		public var m_ListenerList_MouseMove_WithDown:Array = [];
		public var m_ListenerList_MouseUp:Array = [];

		//
//		public var onDrawEnd:Function = function():void{};


		//==Function==

		//#Public

		//リスナを追加
		public function addEventListener_MouseDown(in_Func:Function):void{
			m_ListenerList_MouseDown.push(in_Func);
		}
		public function addEventListener_MouseMove(in_Func:Function):void{
			m_ListenerList_MouseMove.push(in_Func);
		}
		public function addEventListener_MouseMove_WithDown(in_Func:Function):void{
			m_ListenerList_MouseMove_WithDown.push(in_Func);
		}
		public function addEventListener_MouseUp(in_Func:Function):void{
			m_ListenerList_MouseUp.push(in_Func);
		}

		//カーソルの動かし方を外部から設定
		public function setCursorMode(in_Mode:int):void{
			m_CursorMode = in_Mode;
		}

		//Index Bitmapのクリア（主に初期化時に利用）
		public function clearIndex(in_Index:int = 0):void{
			m_BitmapData_Index.fillRect(m_BitmapData_Index.rect, in_Index);
		}

		//指定位置の色を取得
		public function getPixel32(in_X:int, in_Y:int):uint{
			return m_BitmapData.getPixel32(in_X, in_Y);
		}


		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function Canvas_Zoom(){
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function init(e:Event=null):void{
			//==Common Init==
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

			//BG
			{
				m_Root.addChild(new BackGroundAnim(SIZE_W, SIZE_H, SIZE_RATIO*2));
			}

			//Trace
			{
				var img_trace:Image = new Image();
				{
					img_trace.addChild(m_Bitmap_Trace);

					img_trace.alpha = 0.5;
					img_trace.scaleX = SIZE_RATIO;
					img_trace.scaleY = SIZE_RATIO;
				}
				m_Root.addChild(img_trace);
			}

			//Create Bitmap
			{
				m_BitmapData = new BitmapData(DOT_NUM, DOT_NUM, true, 0x00000000);

				m_Bitmap = new Bitmap(m_BitmapData);

				m_Bitmap.scaleX = SIZE_RATIO;
				m_Bitmap.scaleY = SIZE_RATIO;

				m_Root.addChild(m_Bitmap);
			}

			//Bitmap Index
			{
				//パレットのIndexを格納するためのBitmap。24bitで十分なはず
				m_BitmapData_Index = new BitmapData(DOT_NUM, DOT_NUM, false, 0x000000);
			}

			//Grid
			{
				m_Grid = new Shape();

				//Draw
				{
					var g:Graphics = m_Grid.graphics;

					//
					{
						g.clear();

						g.lineStyle(0, 0x888888, 0.5);
					}

					//縦線
					for(var x:int = 0; x <= SIZE_W; x += SIZE_RATIO){
						g.moveTo(x, 0);
						g.lineTo(x, SIZE_H);
					}

					//横線
					for(var y:int = 0; y <= SIZE_H; y += SIZE_RATIO){
						g.moveTo(0, y);
						g.lineTo(SIZE_W, y);
					}
				}

				m_Root.addChild(m_Grid);
			}

			//m_Cursor
			{
				m_Cursor = new Array(CURSOR_TYPE_NUM);

				m_Cursor.forEach(function(item:*, index:int, arr:Array):void{
					m_Cursor[index] = new Shape();

					m_Cursor[index].filters = [new BlurFilter(1,1)];

					m_Root.addChild(m_Cursor[index]);
				});

				//Init Cursor Graphic
				{
					redrawCursor();
				}
			}

			//mouse
			{
				var MouseDownFlag:Boolean = false;

				addEventListener(
					MouseEvent.MOUSE_DOWN,
					function(e:MouseEvent):void{
						MouseDownFlag = true;
						onMouseDown(m_Bitmap.mouseX, m_Bitmap.mouseY);
					}
				);

				root.addEventListener(
					MouseEvent.MOUSE_MOVE,
					function(e:MouseEvent):void{
						{
							onMouseMove(m_Bitmap.mouseX, m_Bitmap.mouseY);
						}

						if(! e.buttonDown){
							MouseDownFlag = false;
						}
						if(MouseDownFlag){
							onMouseMove_WithDown(m_Bitmap.mouseX, m_Bitmap.mouseY);
						}
					}
				);

				root.addEventListener(
					MouseEvent.MOUSE_UP,
					function(e:MouseEvent):void{
						if(MouseDownFlag){
							MouseDownFlag = false;

							onMouseUp(m_Bitmap.mouseX, m_Bitmap.mouseY);
						}
					}
				);
			}
		}


		//マウスが押された時の処理
		public function onMouseDown(in_X:int, in_Y:int):void{
			m_ListenerList_MouseDown.forEach(function(listener:*, index:int, arr:Array):void{
				listener(in_X, in_Y);
			});
		}

		//マウスが移動した時の処理
		public function onMouseMove(in_X:int, in_Y:int):void{
			m_ListenerList_MouseMove.forEach(function(listener:*, index:int, arr:Array):void{
				listener(in_X, in_Y);
			});
		}

		//マウスを押したまま移動した時の処理
		public function onMouseMove_WithDown(in_X:int, in_Y:int):void{
			m_ListenerList_MouseMove_WithDown.forEach(function(listener:*, index:int, arr:Array):void{
				listener(in_X, in_Y);
			});
		}

		//マウスが離された時の処理
		public function onMouseUp(in_X:int, in_Y:int):void{
			m_ListenerList_MouseUp.forEach(function(listener:*, index:int, arr:Array):void{
				listener(in_X, in_Y);
			});
		}


		//カーソルの位置セット
		public function setCursorPos(in_X:int, in_Y:int):void{
			m_Cursor.forEach(function(cursor_shape:*, index:int, arr:Array):void{
				var x:int = in_X;
				var y:int = in_Y;

				var visible_flag:Boolean = true;

				//カーソルの種類(index)によって位置や表示の有無を変更
				//表示の有無などは現在のカーソルモード(m_CursorMode)を見て判断
				switch(index){
				case CURSOR_TYPE_NORMAL:
					break;
				case CURSOR_TYPE_MIRROR_X:
					switch(m_CursorMode){
					case CURSOR_MODE_NORMAL:
					case CURSOR_MODE_MIRROR_Y_16_16:
					case CURSOR_MODE_MIRROR_Y_15_1_15:
						visible_flag = false;
						break;
					case CURSOR_MODE_MIRROR_X_16_16:
					case CURSOR_MODE_MIRROR_XY_16_16:
						x = DOT_NUM-1 - x;
						break;
					case CURSOR_MODE_MIRROR_X_15_1_15:
					case CURSOR_MODE_MIRROR_XY_15_1_15:
						x = DOT_NUM-2 - x;
						break;
					}
					break;
				case CURSOR_TYPE_MIRROR_Y:
					switch(m_CursorMode){
					case CURSOR_MODE_NORMAL:
					case CURSOR_MODE_MIRROR_X_16_16:
					case CURSOR_MODE_MIRROR_X_15_1_15:
						visible_flag = false;
						break;
					case CURSOR_MODE_MIRROR_Y_16_16:
					case CURSOR_MODE_MIRROR_XY_16_16:
						y = DOT_NUM-1 - y;
						break;
					case CURSOR_MODE_MIRROR_Y_15_1_15:
					case CURSOR_MODE_MIRROR_XY_15_1_15:
						y = DOT_NUM-2 - y;
						break;
					}
					break;
				case CURSOR_TYPE_MIRROR_XY:
					switch(m_CursorMode){
					case CURSOR_MODE_NORMAL:
					case CURSOR_MODE_MIRROR_X_16_16:
					case CURSOR_MODE_MIRROR_Y_16_16:
					case CURSOR_MODE_MIRROR_X_15_1_15:
					case CURSOR_MODE_MIRROR_Y_15_1_15:
						visible_flag = false;
						break;
					case CURSOR_MODE_MIRROR_XY_16_16:
						x = DOT_NUM-1 - x;
						y = DOT_NUM-1 - y;
						break;
					case CURSOR_MODE_MIRROR_XY_15_1_15:
						x = DOT_NUM-2 - x;
						y = DOT_NUM-2 - y;
						break;
					}
					break;
				}

				x *= SIZE_RATIO;
				y *= SIZE_RATIO;

				m_Cursor[index].visible = visible_flag;

				m_Cursor[index].x = x;
				m_Cursor[index].y = y;
			});
		}


		//カーソルを指定色で再描画
		public function redrawCursor(in_Color:uint = 0xFFFFFF):void{
			const colorLerp:Function = function(in_SrcColor:uint, in_DstColor:uint, in_Ratio:Number):uint{
				var a_src:uint = (in_SrcColor >> 24) & 0xFF;
				var r_src:uint = (in_SrcColor >> 16) & 0xFF;
				var g_src:uint = (in_SrcColor >>  8) & 0xFF;
				var b_src:uint = (in_SrcColor >>  0) & 0xFF;

				var a_dst:uint = (in_DstColor >> 24) & 0xFF;
				var r_dst:uint = (in_DstColor >> 16) & 0xFF;
				var g_dst:uint = (in_DstColor >>  8) & 0xFF;
				var b_dst:uint = (in_DstColor >>  0) & 0xFF;

				var a:uint = (a_src * (1 - in_Ratio)) + (a_dst * in_Ratio);
				var r:uint = (r_src * (1 - in_Ratio)) + (r_dst * in_Ratio);
				var g:uint = (g_src * (1 - in_Ratio)) + (g_dst * in_Ratio);
				var b:uint = (b_src * (1 - in_Ratio)) + (b_dst * in_Ratio);

				return (a << 24) | (r << 16) | (g << 8) | (b << 0);
			};

			m_Cursor.forEach(function(item:*, index:int, arr:Array):void{
				var g:Graphics = m_Cursor[index].graphics;

				const SCALE:Number = 2.0;
				const LEN:Number = SIZE_RATIO/SCALE;

				//Scale
				{
					m_Cursor[index].scaleX = m_Cursor[index].scaleY = SCALE;
				}

				//Reset
				{
					g.clear();
				}

				//Base : Black
				{
					var color_base:uint = colorLerp(in_Color, 0xDD000000, 0.5);
					g.lineStyle(0, color_base & 0xFFFFFF, ((color_base >> 24) & 0xFF)/255.0);

					g.drawRect(0, 0, LEN, LEN);
				}

				//Cross : White
				{
					var color_cross:uint = colorLerp(in_Color, 0xDDFFFFFF, 0.5);
					g.lineStyle(1, color_cross & 0xFFFFFF, ((color_base >> 24) & 0xFF)/255.0);

					g.moveTo(LEN*1/4,	0);
					g.lineTo(LEN*3/4,	0);
					g.moveTo(LEN*1/4,	LEN);
					g.lineTo(LEN*3/4,	LEN);
					g.moveTo(0,			LEN*1/4);
					g.lineTo(0,			LEN*3/4);
					g.moveTo(LEN,		LEN*1/4);
					g.lineTo(LEN,		LEN*3/4);
				}
			});
		}


		//表示をずらす
		public function scroll(in_MoveX:int, in_MoveY:int):void{
			var ori_bmp_data:BitmapData = m_BitmapData_Index.clone();

			var src_lx:int;
			var src_uy:int;
			var dst_rx:int;
			var dst_dy:int;
			{
				if(in_MoveX > 0){
					src_lx = (DOT_NUM - in_MoveX);
					dst_rx = in_MoveX;
				}else{
					src_lx = -in_MoveX;
					dst_rx = (DOT_NUM + in_MoveX);
				}
				if(in_MoveY > 0){
					src_uy = (DOT_NUM - in_MoveY);
					dst_dy = in_MoveY;
				}else{
					src_uy = -in_MoveY;
					dst_dy = (DOT_NUM + in_MoveY);
				}
			}

			//LU
			{
				src_rect.x = src_lx;
				src_rect.y = src_uy;
				src_rect.width  = dst_rx;//(in_MoveX > 0)? in_MoveX: (DOT_NUM + in_MoveX);
				src_rect.height = dst_dy;//(in_MoveY > 0)? in_MoveY: (DOT_NUM + in_MoveY);

				dst_pos.x = 0;
				dst_pos.y = 0;

				m_BitmapData_Index.copyPixels(
					ori_bmp_data,
					src_rect,
					dst_pos
				);
			}

			//RU
			if(in_MoveX != 0)
			{
				src_rect.x = 0;
				src_rect.y = src_uy;
				src_rect.width  = src_lx;//(in_MoveX > 0)? (DOT_NUM - in_MoveX): -in_MoveX;
				src_rect.height = dst_dy;//(in_MoveY > 0)? in_MoveY: (DOT_NUM + in_MoveY);

				dst_pos.x = dst_rx;
				dst_pos.y = 0;

				m_BitmapData_Index.copyPixels(
					ori_bmp_data,
					src_rect,
					dst_pos
				);
			}

			//LD
			if(in_MoveY != 0)
			{
				src_rect.x = src_lx;
				src_rect.y = 0;
				src_rect.width  = dst_rx;//(in_MoveX > 0)? in_MoveX: (DOT_NUM + in_MoveX);
				src_rect.height = src_uy;//(in_MoveY > 0)? (DOT_NUM - in_MoveY): -in_MoveY;

				dst_pos.x = 0;
				dst_pos.y = dst_dy;

				m_BitmapData_Index.copyPixels(
					ori_bmp_data,
					src_rect,
					dst_pos
				);
			}

			//RD
			if(in_MoveX != 0 && in_MoveY != 0)
			{
				src_rect.x = 0;
				src_rect.y = 0;
				src_rect.width  = src_lx;//(in_MoveX > 0)? (DOT_NUM - in_MoveX): -in_MoveX;
				src_rect.height = src_uy;//(in_MoveY > 0)? (DOT_NUM - in_MoveY): -in_MoveY;

				dst_pos.x = dst_rx;
				dst_pos.y = dst_dy;

				m_BitmapData_Index.copyPixels(
					ori_bmp_data,
					src_rect,
					dst_pos
				);
			}
		}
		public var src_rect:Rectangle = new Rectangle(0,0,0,0);
		public var dst_pos:Point = new Point(0,0);

		//表示反転
		public function reverse(in_IsX:Boolean = true):void{
			var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
			{
				if(in_IsX){
					mtx.a = -1;
					mtx.tx = DOT_NUM;
				}else{
					mtx.d = -1;
					mtx.ty = DOT_NUM;
				}
			}

			m_BitmapData_Index.draw(
				m_BitmapData_Index.clone(),
				mtx
			);
		}
	}
}

