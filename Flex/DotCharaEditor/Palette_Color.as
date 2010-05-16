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
		static public const SIZE_W:int = 25;//50;
		static public const SIZE_H:int = 100;
		static public const PALETTE_SIZE_W:int = 20;
		static public const PALETTE_SIZE_H:int = 20;

		//＃パレット数
		static public const PALETTE_NUM:int = 9;


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
				return m_Palette[m_CursorIndex].bitmapData.getPixel32(0, 0);
			}else{
				return m_Palette[in_Index].bitmapData.getPixel32(0, 0);
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
				m_Cursor.x = m_Palette[m_CursorIndex].x;
				m_Cursor.y = m_Palette[m_CursorIndex].y;
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
					//BG
					var bg:Image;
					{
						bg = new BackGroundAnim(PALETTE_SIZE_W, PALETTE_SIZE_H, PALETTE_SIZE_W/2);
						m_Root.addChild(bg);
					}

					//Bitmap
					var img:Image;
					{
						var bmp_data:BitmapData = new BitmapData(PALETTE_SIZE_W, PALETTE_SIZE_H, true, 0xFFFFFFFF);//0x00000000

						var bmp:Bitmap = new Bitmap(bmp_data);

						m_Palette[index] = bmp;

						img = new Image();
						img.addChild(bmp);
						m_Root.addChild(img);
					}

					//Frame
					//!!

					//BG:透明色をわからせるため
					//!!

					//Pos
					{
						m_Palette[index].y = index * PALETTE_SIZE_H*1.5;
						bg.y = m_Palette[index].y;
					}

					//Listener
					{
						img.addEventListener(
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
					g.moveTo(0, 0);
					g.lineTo(PALETTE_SIZE_W, 0);
					g.lineTo(PALETTE_SIZE_W, PALETTE_SIZE_W);
					g.lineTo(0, PALETTE_SIZE_W);
					g.lineTo(0, 0);

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

