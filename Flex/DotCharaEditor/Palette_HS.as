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

	public class Palette_HS extends Canvas{
		//==Const==

		//＃サイズ
		static public const SIZE_W:int = 100;
		static public const SIZE_H:int = 200;


		//==Var==

		//基本情報
		public var m_Info:Array = [
			{H:1.0/6, S:1.0/6}
		];

		//選択中のIndex
		public var m_CursorIndex:int = 0;

		//Index
		public var m_HueIndex:Array;
		public var m_SaturationIndex:Array;

		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//パレット画像
		public var m_BitmapData:BitmapData;

		//カーソル画像
		public var m_Cursor:Array;//vec<Sprite>

		//リスナのリスト
		public var m_ListenerList_ChangeColor:Array = [];
		public var m_ListenerList_ChangeIndex:Array = [];

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
			var color:uint = m_BitmapData.getPixel(m_SaturationIndex[m_CursorIndex], m_HueIndex[m_CursorIndex]);
			return (0xFF000000 | color);
		}

		//値のリストの取得
		public function GetHueRatioList():Array{
			var result:Array = new Array(m_Cursor.length);

			for(var i:int = 0; i < m_Cursor.length; i++){
				result[i] = m_Cursor[i].y / (SIZE_H-1);
			}

			return result;
		}

		//値のリストの取得
		public function GetSaturationRatioList():Array{
			var result:Array = new Array(m_Cursor.length);

			for(var i:int = 0; i < m_Cursor.length; i++){
				result[i] = m_Cursor[i].x / (SIZE_W-1);
			}

			return result;
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
		public function Palette_HS(){
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
					const lerp:Function = function(in_Src:int, in_Dst:int, in_Ratio:Number):int{
						return in_Src * (1 - in_Ratio) + in_Dst * in_Ratio;
					};

					m_BitmapData = new BitmapData(SIZE_W, SIZE_H, false, 0x000000);
					{
						for(var y:int = 0; y < SIZE_H; y += 1){//色相：Hue
							//色
							var r_ori:uint;
							var g_ori:uint;
							var b_ori:uint;
							{
								//赤～黄、黄～緑、緑～青緑、青緑～青、青～紫、紫～赤の６フェイズ
								const calcVal:Function = function(in_Ratio:Number):uint{
									if(in_Ratio > 1.0){in_Ratio -= 1.0;}

									if(in_Ratio < 1.0/6.0){return 0xFF;}
									if(in_Ratio < 2.0/6.0){return 0xFF * (2.0 - in_Ratio*6.0);}
									if(in_Ratio < 3.0/6.0){return 0x00;}
									if(in_Ratio < 4.0/6.0){return 0x00;}
									if(in_Ratio < 5.0/6.0){return 0xFF * (in_Ratio*6.0 - 4.0);}
									if(in_Ratio < 6.0/6.0){return 0xFF;}

									return 0xFF;//err
								}

								r_ori = calcVal(1.0 * y / SIZE_H + 0.0/3.0);
								g_ori = calcVal(1.0 * y / SIZE_H + 2.0/3.0);
								b_ori = calcVal(1.0 * y / SIZE_H + 1.0/3.0);
							}

							for(var x:int = 0; x < SIZE_W; x += 1){//彩度：Saturation
								//彩度計算
								var ratio:Number = 1.0 * x / SIZE_W;

								var r:uint = lerp(r_ori, 0xFF, ratio);
								var g:uint = lerp(g_ori, 0xFF, ratio);
								var b:uint = lerp(b_ori, 0xFF, ratio);

//*
								//明るさを揃えてみる
								var vec:Vector3D = new Vector3D(r, g, b);
								vec.scaleBy(0xFF / vec.length);
								r = vec.x;
								g = vec.y;
								b = vec.z;
//*/

								var color:uint = (r << 16) | (g << 8) | (b << 0);

								//セット
								m_BitmapData.setPixel(x, y, color);
							}
						}
					}
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
						var gr:Graphics = m_Cursor[i].graphics;

						const w:int = 10;
						const v:int = 5;

						gr.lineStyle(3, 0x000000, 0.7);

						gr.moveTo( 0, w);
						gr.lineTo( 0, v);
						gr.moveTo( 0,-w);
						gr.lineTo( 0,-v);
						gr.moveTo( w, 0);
						gr.lineTo( v, 0);
						gr.moveTo(-w, 0);
						gr.lineTo(-v, 0);
					}

					//Pos
					{
						m_Cursor[i].x = (SIZE_W-1) * m_Info[i].S;
						m_Cursor[i].y = (SIZE_H-1) * m_Info[i].H;
					}

					m_Root.addChild(m_Cursor[i]);
				}

				RefreshCursor();
			}

			//m_HueIndex
			//m_SaturationIndex
			{
				m_HueIndex = new Array(Size);
				m_SaturationIndex = new Array(Size);

				for(i = 0; i < Size; i++){
					m_HueIndex[i]        = (SIZE_H-1) * m_Info[i].H;
					m_SaturationIndex[i] = (SIZE_W-1) * m_Info[i].S;
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
							m_HueIndex[m_CursorIndex]        = Math.min(Math.max(0, mouseY), SIZE_H-1);
							m_SaturationIndex[m_CursorIndex] = Math.min(Math.max(0, mouseX), SIZE_W-1);
						}
						//Cursor
						{
							m_Cursor[m_CursorIndex].x = m_SaturationIndex[m_CursorIndex];
							m_Cursor[m_CursorIndex].y = m_HueIndex[m_CursorIndex];
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

		public function RefreshCursor():void{
			var Size:int = m_Info.length;

			for(var i:int = 0; i < Size; i++){
				if(i == m_CursorIndex){
					m_Cursor[i].alpha = 1.0;
				}else{
					m_Cursor[i].alpha = 0.2;
				}
			}
		}
	}
}

