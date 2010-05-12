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


		//==Var==

		//選択中のIndex
		public var m_CursorIndex:int = 0;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//表示画像
		public var m_Bitmap:Bitmap;
		public var m_BitmapData:BitmapData;

		//パレットIndexを保持する擬似画像（直接の表示には使わない）
		public var m_BitmapData_Index:BitmapData;

		//リスナのリスト
		public var m_ListenerList:Array = [];

		//Index => Color
		public var m_Index2Color:Function = function(in_Index:int):uint{return 0x00000000};

		//描画色
		public var m_Color:uint = 0xFF000000;


		//==Function==

		//#Public

		//描画色の変更
		public function SetColor(in_Color:uint):void{
			m_Color = in_Color;
		}

		//変更時のリスナを追加
		public function SetListener(in_Func:Function):void{
			m_ListenerList.push(in_Func);
		}

		//Index=>Colorの変換処理を設定
		public function SetFunc_Index2Color(in_Func:Function):void{
			m_Index2Color = in_Func;
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
		}

		//Index Bitmapのクリア（主に初期化時に利用）
		public function ClearIndex(in_Index:int = 0):void{
			m_BitmapData_Index.fillRect(m_BitmapData_Index.rect, in_Index);
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

			//Create Bitmap
			{
				m_BitmapData = new BitmapData(DOT_NUM, DOT_NUM, true, 0x00000000);

				m_Bitmap = new Bitmap(m_BitmapData);

				m_Bitmap.scaleX = SIZE_RATIO;
				m_Bitmap.scaleY = SIZE_RATIO;

				m_Root.addChild(m_Bitmap);
			}

			//
			{
				//パレットのIndexを格納するためのBitmap。24bitで十分なはず
				m_BitmapData_Index = new BitmapData(DOT_NUM, DOT_NUM, false, 0x000000);
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
//						m_BitmapData.setPixel32(m_Bitmap.mouseX, m_Bitmap.mouseY, m_Color);
						m_BitmapData_Index.setPixel(m_Bitmap.mouseX, m_Bitmap.mouseY, m_CursorIndex);
						Redraw();
					}

					//Call Listener
					{
						for(var i:int = 0; i < m_ListenerList.length; i++){
							m_ListenerList[i]();
						}
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
		}

		public function Index2Color(in_Index:int):uint{
			return m_Index2Color(in_Index);
		}
	}
}

