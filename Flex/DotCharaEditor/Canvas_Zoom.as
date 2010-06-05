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
		static public const CURSOR_TYPE_NORMAL:int	= CursorTypeIter++;
		static public const CURSOR_TYPE_MIRROR:int	= CursorTypeIter++;
		static public const CURSOR_TYPE_NUM:int		= CursorTypeIter;

		//＃カーソルのモード（カーソルをどう動かすか）
		static public var CursorModeIter:int = 0;
		static public const CURSOR_MODE_NORMAL:int			= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_16_16:int	= CursorModeIter++;
		static public const CURSOR_MODE_MIRROR_15_1_15:int	= CursorModeIter++;
		static public const CURSOR_MODE_NUM:int				= CursorModeIter;

		//＃描画方法
		static public var DrawModeIter:int = 0;
		static public const DRAW_MODE_DOT:int	= DrawModeIter++;
		static public const DRAW_MODE_FILL:int	= DrawModeIter++;
		static public const DRAW_MODE_NUM:int	= DrawModeIter;


		//==Var==

		//選択中のIndex
		public var m_CursorIndex:int = 0;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//表示画像
		public var m_Bitmap:Bitmap;
		public var m_BitmapData:BitmapData;

		//トレース画像
		public var m_Bitmap_Trace:Bitmap;

		//パレットIndexを保持する擬似画像（直接の表示には使わない）
		public var m_BitmapData_Index:BitmapData;

		//グリッド画像
		public var m_Grid:Shape;

		//カーソル画像
		public var m_Cursor:Array;//vec<Shape>：ミラーリングのため、複数のカーソルに対応

		//カーソル同期用に自分自身をstaticなリストに突っ込む
		static public var m_InstanceList:Array = [];//vec<Canvas_Zoom>

		//カーソルのモード（動かし方）
		public var m_CursorMode:int = CURSOR_MODE_MIRROR_15_1_15;

		//描画方法
		public var m_DrawMode:int = DRAW_MODE_DOT;

		//リスナのリスト
		public var m_ListenerList_Redraw:Array = [];

		//Index => Color
		public var m_Index2Color:Function = function(in_Index:int):uint{return 0x00000000};


		//==Function==

		//#Public

		//変更時のリスナを追加
		//変更時のリスナを追加
		public function SetListener_Redraw(in_Func:Function):void{
			m_ListenerList_Redraw.push(in_Func);
		}

		//Index=>Colorの変換処理を設定
		public function SetFunc_Index2Color(in_Func:Function):void{
			m_Index2Color = in_Func;
		}

		//選択されているIndexまわり
		public function GetCursorIndex():int{
			return m_CursorIndex;
		}
		public function SetCursorIndex(in_Index:int, in_CursorColor:uint = 0xFFFFFFFF):void{
			//Set Val
			{
				m_CursorIndex = in_Index;
			}

			//Redraw Cursor
			{
				RedrawCursor(in_CursorColor);
			}
		}

		//カーソルの動かし方を外部から設定
		public function SetCursorMode(in_Mode:int):void{
			m_CursorMode = in_Mode;
		}

		//描画方法の設定
		public function SetDrawMode(in_Mode:int):void{
			m_DrawMode = in_Mode;
		}

		//Index Bitmapのクリア（主に初期化時に利用）
		public function ClearIndex(in_Index:int = 0):void{
			m_BitmapData_Index.fillRect(m_BitmapData_Index.rect, in_Index);
		}

		//指定位置の色を取得
		public function GetPixel32(in_X:int, in_Y:int):uint{
			return m_BitmapData.getPixel32(in_X, in_Y);
		}


		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function Canvas_Zoom(){
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(e:Event):void{
			//==Common Init==
			{
				//自身の幅を設定しておく
				this.width  = SIZE_W;
				this.height = SIZE_H;

				//自身をstaticなリストに突っ込む
				m_InstanceList.push(this);
			}

			//Init Once
			{
				removeEventListener(Event.ADDED_TO_STAGE, Init);
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
				m_Bitmap_Trace = new Bitmap();

				m_Bitmap_Trace.scaleX = SIZE_RATIO;
				m_Bitmap_Trace.scaleY = SIZE_RATIO;

				m_Root.addChild(m_Bitmap_Trace);
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

					//Mouse
					{
						//Func
						var mouseMoveFunc:Function = function(e:MouseEvent = null):void{
							var x:int = m_Bitmap.mouseX;
							var y:int = m_Bitmap.mouseY;

							var visible_flag:Boolean = true;

							switch(index){
							case CURSOR_TYPE_NORMAL:
								break;
							case CURSOR_TYPE_MIRROR:
								switch(m_CursorMode){
								case CURSOR_MODE_NORMAL:
									visible_flag = false;
									break;
								case CURSOR_MODE_MIRROR_16_16:
									x = DOT_NUM-1 - x;
									break;
								case CURSOR_MODE_MIRROR_15_1_15:
									x = DOT_NUM-2 - x;
									break;
								}
								break;
							}

							x *= SIZE_RATIO;
							y *= SIZE_RATIO;

							m_InstanceList.forEach(function(instance:*, index_inner:int, arr_inner:Array):void{
								if(0 <= x && x < SIZE_W && 0 <= y && y < SIZE_H){
									instance.m_Cursor[index].visible = visible_flag;//true;
								}else{
									return;
//									instance.m_Cursor[index].visible = false;
								}

								instance.m_Cursor[index].x = x;
								instance.m_Cursor[index].y = y;
							});
						};

						//Init
						mouseMoveFunc();

						//Regist
						root.addEventListener(
							MouseEvent.MOUSE_MOVE,
							mouseMoveFunc
						);
					}

					m_Root.addChild(m_Cursor[index]);
				});

				//Draw
				{
					RedrawCursor();
				}
			}

			//mouse
			{
				var MouseDownFlag:Boolean = false;

				var mouseOldX:int = m_Bitmap.mouseX;
				var mouseOldY:int = m_Bitmap.mouseY;

				var onChange:Function = function():void{
					//Draw
					{
						//ラインだけじゃなく他のも？
						//!!

						switch(m_DrawMode){
						case DRAW_MODE_DOT:
							//フリー描画
							{
								const drawFunc_Dot:Function = function(in_Index:int):void{
									m_BitmapData_Index.setPixel(m_Cursor[in_Index].x / SIZE_RATIO, m_Cursor[in_Index].y / SIZE_RATIO, m_CursorIndex);
								};

								switch(m_CursorMode){
								case CURSOR_MODE_NORMAL:
									drawFunc_Dot(CURSOR_TYPE_NORMAL);
									break;
								case CURSOR_MODE_MIRROR_16_16:
								case CURSOR_MODE_MIRROR_15_1_15:
									drawFunc_Dot(CURSOR_TYPE_NORMAL);
									drawFunc_Dot(CURSOR_TYPE_MIRROR);
									break;
								}
							}
							break;
						case DRAW_MODE_FILL:
							//塗りつぶし
							{
								const drawFunc_Fill:Function = function(in_Index:int):void{
									m_BitmapData_Index.floodFill(m_Cursor[in_Index].x / SIZE_RATIO, m_Cursor[in_Index].y / SIZE_RATIO, m_CursorIndex);
								};

								switch(m_CursorMode){
								case CURSOR_MODE_NORMAL:
									drawFunc_Fill(CURSOR_TYPE_NORMAL);
									break;
								case CURSOR_MODE_MIRROR_16_16:
								case CURSOR_MODE_MIRROR_15_1_15:
									drawFunc_Fill(CURSOR_TYPE_NORMAL);
									drawFunc_Fill(CURSOR_TYPE_MIRROR);
									break;
								}
							}
							break;
						}

						Redraw();
					}

					//Old
					{
						mouseOldX = m_Bitmap.mouseX;
						mouseOldY = m_Bitmap.mouseY;
					}
				};

				addEventListener(
					MouseEvent.MOUSE_DOWN,
					function(e:MouseEvent):void{
						MouseDownFlag = true;
						mouseOldX = mouseX;
						mouseOldY = mouseY;
						onChange();
					}
				);

				root.addEventListener(
					MouseEvent.MOUSE_MOVE,
					function(e:MouseEvent):void{
						if(! e.buttonDown){
							MouseDownFlag = false;
						}
						if(MouseDownFlag){
							onChange();
						}
					}
				);
			}
		}

		public function Redraw():void{
			for(var y:int = 0; y < DOT_NUM; y++){
				for(var x:int = 0; x < DOT_NUM; x++){
					m_BitmapData.setPixel32(x, y, Index2Color(m_BitmapData_Index.getPixel(x, y)));
				}
			}

			//Call Listener
			{
				for(var i:int = 0; i < m_ListenerList_Redraw.length; i++){
					m_ListenerList_Redraw[i]();
				}
			}
		}

		public function RedrawCursor(in_Color:uint = 0xFFFFFF):void{
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
					g.lineStyle(1, color_base & 0xFFFFFF, ((color_base >> 24) & 0xFF)/255.0);

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

		public function Index2Color(in_Index:int):uint{
			return m_Index2Color(in_Index);
		}
	}
}

