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

	public class Palette_B extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 100;
		static public const SIZE_H:int = 32;


		//==Var==

		//基本情報
		public var m_Info:Array = [
			{B:1/6.0}
		];

		//選択中のIndex
		public var m_CursorIndex:int = 0;

		//Index
		public var m_BrightnessIndex:Array;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//パレット画像
		public var m_BitmapData:BitmapData;

		//カーソル画像
		public var m_Cursor:Array;//vec<Sprite>

		//リスナのリスト
		public var m_ListenerList_ChangeColor:Array = [];
		public var m_ListenerList_ChangeIndex:Array = [];//こっちは不要かもしれないが、一応将来のために用意

		//初期化記憶フラグ
		public var m_InitListenerFlag:Boolean = false;


		//==Function==

		//#Public

		//データの初期化
		public function SetData(in_Info:Array):void{
			m_Info = in_Info;

			Init();
		}

		//色の取得
		public function GetColor():uint{
			if(m_CursorIndex < 0 || m_Info.length <= m_CursorIndex){return 0x00000000;}
			var color:uint = m_BitmapData.getPixel(m_BrightnessIndex[m_CursorIndex], 0);
			return (0xFF000000 | color);
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

			//Refresh Cursor
			{
				RefreshCursor();
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
		public function Palette_B(){
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(e:Event = null):void{
			//Resetも兼ねるので、２回以上呼んでも大丈夫なようにしておく

			var i:int;

			var Size:int = m_Info.length;

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
				if(! m_BitmapData){
					m_BitmapData = new BitmapData(SIZE_W, SIZE_H, false, 0x000000);
				}

				m_Root.addChild(new Bitmap(m_BitmapData));
			}

			//Create Cursor
			{
				m_Cursor = new Array(Size);

				for(i = 0; i < Size; i++){
					m_Cursor[i] = new Sprite();

					//Draw
					{
						var g:Graphics = m_Cursor[i].graphics;

						const w:int = 6;

						g.lineStyle(1, 0x000000, 0.7);
						g.beginFill(0xFFFFFF, 0.7);

						g.moveTo( w/2, 0);
						g.lineTo(   0, w);
						g.lineTo(-w/2, 0);
						g.lineTo( w/2, 0);

						g.endFill();
					}

					//Pos
					{
						m_Cursor[i].x = (SIZE_W-1) * m_Info[i].B;
					}

					m_Root.addChild(m_Cursor[i]);
				}

				RefreshCursor();
			}

			//m_HueIndex
			//m_SaturationIndex
			{
				m_BrightnessIndex = new Array(Size);

				for(i = 0; i < Size; i++){
					m_BrightnessIndex[i] = (SIZE_W-1) * m_Info[i].B;
				}
			}

			//mouse
			{
				if(! m_InitListenerFlag){
					m_InitListenerFlag = true;

					var MouseDownFlag:Boolean = false;

					var onChange:Function = function():void{
						//Check
						{
							if(m_CursorIndex < 0){return;}
							if(m_CursorIndex >= m_Info.length){return;}
						}

						//Param
						{
							m_BrightnessIndex[m_CursorIndex] = Math.min(Math.max(0, mouseX), SIZE_W-1);
						}
						//Cursor
						{
							m_Cursor[m_CursorIndex].x = m_BrightnessIndex[m_CursorIndex];
						}
						//Call Listener
						{
							for(var i:int = 0; i < m_ListenerList_ChangeColor.length; i++){
								m_ListenerList_ChangeColor[i]();
							}
						}
					};

					addEventListener(
						MouseEvent.MOUSE_DOWN,
						function(e:MouseEvent):void{
							MouseDownFlag = true;
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
		}

		//描画
		public function Redraw(in_ColorHS:uint):void{
			const BMP_W:int = m_BitmapData.width;
			const BMP_H:int = m_BitmapData.height;

			var r_ori:uint = (in_ColorHS >> 16) & 0xFF;
			var g_ori:uint = (in_ColorHS >>  8) & 0xFF;
			var b_ori:uint = (in_ColorHS >>  0) & 0xFF;

			for(var x:int = 0; x < BMP_W; x += 1){//明度：Brightness
				var ratio:Number = 1.0 * x / BMP_W;

				var r:uint = (r_ori * (1 - ratio)) + (0x00 * ratio);
				var g:uint = (g_ori * (1 - ratio)) + (0x00 * ratio);
				var b:uint = (b_ori * (1 - ratio)) + (0x00 * ratio);

				var color:uint = (r << 16) | (g << 8) | (b << 0);

				for(var y:int = 0; y < BMP_H; y += 1){
					//セット
					m_BitmapData.setPixel(x, y, color);
				}
			}

			//Call Listener
			{
				for(var i:int = 0; i < m_ListenerList_ChangeColor.length; i++){
					m_ListenerList_ChangeColor[i]();
				}
			}
		}

		public function RefreshCursor():void{
			var Size:int = m_Info.length;

			for(var i:int = 0; i < Size; i++){
				if(i == m_CursorIndex){
					m_Cursor[i].alpha = 1.0;
				}else{
					m_Cursor[i].alpha = 0.5;
				}
			}
		}
	}
}
