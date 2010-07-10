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

	public class Canvas_Result extends Canvas{
		//==Const==

		//#サイズ
		static public const SIZE_ANIM_W:int = 24 * 3;
		static public const SIZE_ANIM_H:int = 32 * 4;

		static public const PADDING:int = 5;


		//==Var==

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;
		public var  m_Root_Anim:Image;

		//表示画像：24x32[3][4]
		public var m_Bitmap_Anim:Bitmap;
		public var m_BitmapData_Anim:BitmapData;

		//選択されたときに返すための内部データ
		public var m_BitmapData_Index_Anim_Color:Array;
		public var m_BitmapData_Index_Anim_Shade:Array;

		//トレース画像
		public var m_Bitmap_Trace:Bitmap = new Bitmap();

		//グリッド
		public var m_Grid:Shape = new Shape();

		//カーソル
		public var m_Cursor:Shape = new Shape();
		public var m_CursorIndex:int = 4;


		//こいつをクリックしてマスを選んだ時に呼ばれる関数
		public var onSelected:Function = function():void{};

		//==Function==

		//#Init

		//rootなどに触るので、初期化のタイミングを遅らせる
		public function Canvas_Result(){
			//Size
			{
				this.width  = PADDING + SIZE_ANIM_W + PADDING;
				this.height = PADDING + SIZE_ANIM_H + PADDING;
			}

			//Root
			{
				m_Root = new Image();
				addChild(m_Root);
			}

			//Anim
			{
				//Node
				{
					m_Root_Anim = new Image();
					m_Root.addChild(m_Root_Anim);

					m_Root_Anim.x = PADDING;
					m_Root_Anim.y = PADDING;
				}

				//BG
				{
					m_Root_Anim.addChild(new BackGroundAnim(SIZE_ANIM_W, SIZE_ANIM_H, 8));
				}

				//Trace
				{
					var img_trace:Image = new Image();
					{
						img_trace.addChild(m_Bitmap_Trace);
						img_trace.alpha = 0.5;
					}
					m_Root_Anim.addChild(img_trace);
				}

				//Create Bitmap
				{
					m_BitmapData_Anim = new BitmapData(SIZE_ANIM_W, SIZE_ANIM_H, true, 0x00000000);

					m_Bitmap_Anim = new Bitmap(m_BitmapData_Anim);

					m_Root_Anim.addChild(m_Bitmap_Anim);
				}

				//Grid
				{
					m_Root_Anim.addChild(m_Grid);

					var g:Graphics = m_Grid.graphics;

					//Init
					{
						g.lineStyle(0, 0x000000, 0.3);
					}

					//Draw X
					for(var x:int = 0; x <= SIZE_ANIM_W; x += 24){
						g.moveTo(x, 0);
						g.lineTo(x, SIZE_ANIM_H);
					}

					//Draw Y
					for(var y:int = 0; y <= SIZE_ANIM_H; y += 32){
						g.moveTo(0, y);
						g.lineTo(SIZE_ANIM_W, y);
					}
				}

				//Mouse
				{
					m_Root_Anim.addEventListener(
						MouseEvent.MOUSE_DOWN,
						function(e:MouseEvent):void{
 							m_CursorIndex = int(m_Root_Anim.mouseX / 24) + int(m_Root_Anim.mouseY / 32) * 3;
							RefreshCursor();

							onSelected();
						}
					);
				}
			}

			//Cursor
			{
				//Draw
				{
					//サイズを1X1にして、枠の大きさに合わせてスケーリングする

					//Draw Rect
					{
						g = m_Cursor.graphics;

						g.lineStyle(1, 0xFFFFFF, 1.0);

						g.drawRect(0, 0, 24, 32);
					}

					//Filter
					{
						m_Cursor.filters = [new GlowFilter(0xFFFFFF, 1.0, 2,2)];
					}

					//Register
					{
						m_Root.addChild(m_Cursor);
					}
				}

				//Pos
				{
					RefreshCursor();
				}
			}

			//内部記憶データ
			{
				//
				m_BitmapData_Index_Anim_Color = new Array(12);
				m_BitmapData_Index_Anim_Shade = new Array(12);
				for(var i:int = 0; i < 12; i++){
					m_BitmapData_Index_Anim_Color[i] = new BitmapData(32, 32, false, 0x0);
					m_BitmapData_Index_Anim_Shade[i] = new BitmapData(32, 32, false, 0x0);
				}
			}
		}

		//m_CursorIndexに基づき、カーソルの位置や大きさを更新
		public function RefreshCursor():void{
			//Anim

			//Pos
			{
				m_Cursor.x = m_Root_Anim.x + (24 * int(m_CursorIndex % 3));
				m_Cursor.y = m_Root_Anim.y + (32 * int(m_CursorIndex / 3));
			}
		}

		//#Interface

		//選択中の場所に画像を描く
		public static const ctr:ColorTransform = new ColorTransform();
		public static const bm:String = BlendMode.NORMAL;
		public static const p:Point = new Point();
		public function Redraw(in_BitmapData_Color:BitmapData, in_BitmapData_Shade:BitmapData, in_BitmapData_Index_Color:BitmapData, in_BitmapData_Index_Shade:BitmapData):void{
			var in_BitmapData:BitmapData;
			{
				in_BitmapData = new BitmapData(32, 32, true, 0x00000000);
				in_BitmapData.draw(in_BitmapData_Color);
				in_BitmapData.draw(in_BitmapData_Shade);
				//αだけは「色」のものをそのまま使う
				in_BitmapData.copyChannel(in_BitmapData_Color, in_BitmapData_Color.rect, p, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}


			{
				//Anim

				//Calc Pos
				var rect:Rectangle;
				var mtx:Matrix;
				{
					rect = new Rectangle(
						(24 * int(m_CursorIndex % 3)),
						(32 * int(m_CursorIndex / 3)),
						24,
						32
					);
					mtx = new Matrix(
						1,0,0,1,
						(24 * int(m_CursorIndex % 3)) - (32-24)/2,
						(32 * int(m_CursorIndex / 3))
					);
				}

				//Clear
				m_BitmapData_Anim.fillRect(rect, 0x00000000);

				//Draw
				m_BitmapData_Anim.draw(in_BitmapData, mtx, ctr, bm, rect);

				//Save
				m_BitmapData_Index_Anim_Color[m_CursorIndex].draw(in_BitmapData_Index_Color);
				m_BitmapData_Index_Anim_Shade[m_CursorIndex].draw(in_BitmapData_Index_Shade);
			}
		}


		public function Refresh(in_Palette_Color:Palette_Color, in_Palette_Shade:Palette_Color):void{
			m_BitmapData_Anim.fillRect(m_BitmapData_Anim.rect, 0x00000000);

			var rect:Rectangle = new Rectangle(0, 0, 24,32);
			var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
			var dst_p:Point = new Point();

			for(var i:int = 0; i < 12; i++){
				//ここの処理はRedrawと統合したいところだが
				rect.x = (24 * int(i % 3));
				rect.y = (32 * int(i / 3));
				mtx.tx = (24 * int(i % 3)) - (32-24)/2;
				mtx.ty = (32 * int(i / 3));
				dst_p.x = (24 * int(i % 3));
				dst_p.y = (32 * int(i / 3));

				var bmp_data_color:BitmapData = in_Palette_Color.CreateBitmap_FromIndex(m_BitmapData_Index_Anim_Color[i]);
				var bmp_data_shade:BitmapData = in_Palette_Shade.CreateBitmap_FromIndex(m_BitmapData_Index_Anim_Shade[i]);
				m_BitmapData_Anim.draw(bmp_data_color, mtx, ctr, bm, rect);
				m_BitmapData_Anim.draw(bmp_data_shade, mtx, ctr, bm, rect);
				//αだけは「色」のものをそのまま使う
				rect.x = (32-24)/2;
				rect.y = 0;
				m_BitmapData_Anim.copyChannel(bmp_data_color, rect, dst_p, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}
		}


		public function Get_BitmapData_Index_Color():BitmapData{
			return m_BitmapData_Index_Anim_Color[m_CursorIndex];
		}

		public function Get_BitmapData_Index_Shade():BitmapData{
			return m_BitmapData_Index_Anim_Shade[m_CursorIndex];
		}

		public function ClearIndex_Color(in_Index:int):void{
			for(var i:int = 0; i < 12; i++){
				m_BitmapData_Index_Anim_Color[i].fillRect(m_BitmapData_Index_Anim_Color[i].rect, in_Index);
			}
		}

		public function ClearIndex_Shade(in_Index:int):void{
			for(var i:int = 0; i < 12; i++){
				m_BitmapData_Index_Anim_Shade[i].fillRect(m_BitmapData_Index_Anim_Shade[i].rect, in_Index);
			}
		}


		//#Save & Load

		//合成結果の画像を返す（結果保存用）
		public function Get_BitmapData_Anim():BitmapData{
			return m_BitmapData_Anim;
		}

		//「色」のIndex画像を返す（「色」画像保存用）
		public function Get_BitmapData_Index_Anim_Color():BitmapData{
			var bmp_data:BitmapData = new BitmapData(SIZE_ANIM_W, SIZE_ANIM_H, false, 0x0);

			{
				var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
				var rect:Rectangle = new Rectangle(0, 0, 24,32);

				for(var i:int = 0; i < 12; i++){
					mtx.tx = (24 * int(i % 3)) - (32-24)/2;
					mtx.ty = (32 * int(i / 3));
					rect.x = (24 * int(i % 3));
					rect.y = (32 * int(i / 3));

					bmp_data.draw(m_BitmapData_Index_Anim_Color[i], mtx, ctr, bm, rect);
				}
			}

			return bmp_data;
		}

		//「陰」のIndex画像を返す（「陰」画像保存用）
		public function Get_BitmapData_Index_Anim_Shade():BitmapData{
			var bmp_data:BitmapData = new BitmapData(SIZE_ANIM_W, SIZE_ANIM_H, false, 0x0);

			{
				var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
				var rect:Rectangle = new Rectangle(0, 0, 24,32);

				for(var i:int = 0; i < 12; i++){
					mtx.tx = (24 * int(i % 3)) - (32-24)/2;
					mtx.ty = (32 * int(i / 3));
					rect.x = (24 * int(i % 3));
					rect.y = (32 * int(i / 3));

					bmp_data.draw(m_BitmapData_Index_Anim_Shade[i], mtx, ctr, bm, rect);
				}
			}

			return bmp_data;
		}

		//「色」のIndex画像をセット（「色」画像ロード用）
		public function Set_BitmapData_Index_Anim_Color(in_Obj:DisplayObject):void{
			var rect:Rectangle = new Rectangle((32-24)/2, 0, 24, 32);

			var mtx:Matrix = new Matrix(1,0,0,1, 0,0);

			for(var i:int = 0; i < 12; i++){
				//Calc Pos
				{
					mtx.tx = -(24 * int(i % 3)) + (32-24)/2;
					mtx.ty = -(32 * int(i / 3));
				}

				m_BitmapData_Index_Anim_Color[i].draw(in_Obj, mtx, ctr, bm, rect);
			}
		}

		//「陰」のIndex画像をセット（「陰」画像ロード用）
		public function Set_BitmapData_Index_Anim_Shade(in_Obj:DisplayObject):void{
			var rect:Rectangle = new Rectangle((32-24)/2, 0, 24, 32);

			var mtx:Matrix = new Matrix(1,0,0,1, 0,0);

			for(var i:int = 0; i < 12; i++){
				//Calc Pos
				{
					mtx.tx = -(24 * int(i % 3)) + (32-24)/2;
					mtx.ty = -(32 * int(i / 3));
				}

				m_BitmapData_Index_Anim_Shade[i].draw(in_Obj, mtx, ctr, bm, rect);
			}
		}


		//#Trace

		public function GetTraceBitmapData():BitmapData{
			//Check
			{
				if(m_Bitmap_Trace.bitmapData == null){
					return null;
				}
			}

			//Create
			{
				var bmp_data:BitmapData = new BitmapData(32, 32, true, 0x00000000);

				var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
				mtx.tx = int(m_CursorIndex % 3) * -24 + (32-24)/2;
				mtx.ty = int(m_CursorIndex / 3) * -32;

				var rect:Rectangle = new Rectangle((32-24)/2, 0, 24, 32);

				bmp_data.draw(m_Bitmap_Trace.bitmapData, mtx, ctr, bm, rect);

				return bmp_data;
			}
		}
	}
}

