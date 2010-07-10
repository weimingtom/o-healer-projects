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

	public class IPalette extends Canvas{
		//==Const==

		//定数もどき：overrideして変更

		public function GetBitmapW():int{return 100;}
		public function GetBitmapH():int{return 32;}

		public function GetInfoKeyName_X():String{return "X";}
		public function GetInfoKeyName_Y():String{return "Y";}

		public function Is2D():Boolean{return false;}
		public function IsUseBackgroundAnim():Boolean{return false;}


		//==Func==

		//#Common

		public function IPalette(){
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(e:Event=null):void{
			//Check
			{
				if(m_Root){
					return;//すでに初期化されているようなので何もしない
				}
			}

			//Common Init
			{
				//自身の幅を設定しておく
				this.width  = GetBitmapW();
				this.height = GetBitmapH();
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

			//BackGround
			{
				if(IsUseBackgroundAnim()){
					m_Root.addChild(new BackGroundAnim(GetBitmapW(), GetBitmapH(), 10));
				}
			}

			//m_BitmapData
			{
				m_BitmapData = new BitmapData(GetBitmapW(), GetBitmapH(), true, 0x00000000);
				m_Root.addChild(new Bitmap(m_BitmapData));
			}

			//Mouse
			{
				var MouseDownFlag:Boolean = false;

				var onChange:Function = function():void{
					//Check
					{
						if(m_CursorIndex < 0){return;}
						if(m_CursorIndex >= m_Cursor.length){return;}
					}

					//Cursor
					{
						m_Cursor[m_CursorIndex].x = Math.min(Math.max(0, m_Root.mouseX), GetBitmapW()-1);

						if(Is2D()){
							m_Cursor[m_CursorIndex].y = Math.min(Math.max(0, m_Root.mouseY), GetBitmapH()-1);
						}
					}

					//Next
					{
						onOutputChange(GetSelectedColor());
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

		//#カーソル変更

		//カーソル変更後のコールバック
		public var onCursorChange:Function = function(in_Index:int, in_InputColor:uint):void{};

		//カーソル変更処理
		public function setCursorIndex(in_Index:int, in_InputColor:uint = 0xFFFFFFFF):void{
			//Check
			{
				if(m_CursorIndex == in_Index){
					return;//変更の必要がなければ何もしない
				}
			}

			//Param
			{
				m_CursorIndex = in_Index;
				m_InputColor = in_InputColor;
			}

			//Graphic
			{
				redraw();

				redraw_cursor();
			}

			//Next
			{
				onCursorChange(in_Index, GetSelectedColor());
			}
		}


		//#色変更

		//色変更後のコールバック
		public var onOutputChange:Function = function(in_InputColor:uint):void{};

		//色変更処理
		public function onInputChange(in_InputColor:uint):void{
			//Param
			{
				m_InputColor = in_InputColor;
			}

			//Graphic
			{
				redraw();
			}

			//Next
			{
				onOutputChange(GetSelectedColor());
			}
		}


		//#初期化

		//初期化後のコールバック
		public var onReset:Function = function(in_Info:Array, in_InputColor:Array):void{};

		//初期化
		public function reset(in_Info:Array, in_InputColor:Array = null):void{
			//Param
			{
				//m_CursorIndex
				{
					if(m_CursorIndex >= in_Info.length){m_CursorIndex = in_Info.length-1;}
				}

				//m_InputColor
				{
					m_InputColor = in_InputColor[m_CursorIndex];
				}

				//m_Cursor
				{
					refreshCursor(in_Info);
				}
			}

			//Graphic
			{
				redraw();
			}

			//
			var outputColor:Array;
			{
				var num:int = in_Info.length;

				outputColor = new Array(num);

				for(var i:int = 0; i < num; i++){
					outputColor[i] = calc_color(in_InputColor[i], in_Info[i][GetInfoKeyName_X()]);
				}
			}

			//Next
			{
				onReset(in_Info, outputColor);
			}
		}

		public function refreshCursor(in_Info:Array):void{
			var i:int;

			var size_old:int	= m_Cursor.length;
			var size_info:int	= in_Info.length;

			//まずは数を合わせる
			{
				//Remove
				if(size_info < size_old){
					var newCursorArray:Array		= new Array(size_info);

					//Copy
					for(i = 0; i < size_info; i++){
						newCursorArray[i]		= m_Cursor[i];
					}
					//Remove
					for(i = size_info; i < size_old; i++){
						m_Cursor[i].parent.removeChild(m_Cursor[i]);
					}

					//Restore
					{
						m_Cursor = newCursorArray;
					}
				}

				//Add
				if(size_info > size_old){
					//Add
					for(i = size_old; i < size_info; i++){
						//Add
						{
							m_Cursor.push(new Sprite());
						}

						//Init Cursor
						{
							//Draw
							{
								var g:Graphics = m_Cursor[i].graphics;

								const w:int = 6;

								g.lineStyle(1, 0x000000, 0.7);
								g.beginFill(0xFFFFFF, 0.7);

								g.moveTo(   0,   0);
								g.lineTo( w/2, w/2);
								g.lineTo(   0,   w);
								g.lineTo(-w/2, w/2);
								g.lineTo(   0,   0);

								g.endFill();
							}

							m_Root.addChild(m_Cursor[i]);
						}
					}
				}
			}

			//そして位置や値をInfoから計算
			{
				for(i = 0; i < size_info; i++){
					m_Cursor[i].x = (GetBitmapW()-1) * (1 - in_Info[i][GetInfoKeyName_X()]);
					m_Cursor[i].y = (GetBitmapH()-1) * (i+1) / (size_info+1);
				}
			}

			//初期化時などのため、CursorIndexまわりの再計算
			{
				//Indexがオーバーしていたら範囲内の戻す
				if(size_info <= m_CursorIndex){
					m_CursorIndex = size_info - 1;
				}

				redraw_cursor();
			}
		}

		public function redraw_cursor():void{
			var num:int = m_Cursor.length;

			//Alpha
			{
				for(var i:int = 0; i < num; i++){
					if(i == m_CursorIndex){
						m_Cursor[i].alpha = 1.0;
					}else{
						m_Cursor[i].alpha = 0.5;
					}
				}
			}
		}


		//#Redraw
		//ものによってはoverrideして使う
		public function redraw():void{
			var color_src:uint = calc_color(m_InputColor, 1);
			var color_dst:uint = calc_color(m_InputColor, 0);

			var BMP_W:int = m_BitmapData.width;
			var BMP_H:int = m_BitmapData.height;

			for(var x:int = 0; x < BMP_W; x += 1){//アルファ：Alpha
				var ratio:Number = 1.0 * x / (BMP_W-1);

				var color:uint = lerp_color(color_src, color_dst, ratio);

				for(var y:int = 0; y < BMP_H; y += 1){
					//セット
					m_BitmapData.setPixel32(x, y, color);
				}
			}
		}


		//#Save & Load
		public function GetVal(in_Index:int, in_IsX:Boolean = true):Number{
			if(in_IsX){
				return 1 - m_Cursor[in_Index].x / (GetBitmapW()-1);
			}else{
				return m_Cursor[in_Index].y / (GetBitmapH()-1);
			}
		}


		//#Utility

		//lerp : color
		static public function lerp_color(in_SrcColor:uint, in_DstColor:uint, in_Ratio:Number):uint{
			var a:uint = lerp((in_SrcColor >> 24) & 0xFF, (in_DstColor >> 24) & 0xFF, in_Ratio);
			var r:uint = lerp((in_SrcColor >> 16) & 0xFF, (in_DstColor >> 16) & 0xFF, in_Ratio);
			var g:uint = lerp((in_SrcColor >>  8) & 0xFF, (in_DstColor >>  8) & 0xFF, in_Ratio);
			var b:uint = lerp((in_SrcColor >>  0) & 0xFF, (in_DstColor >>  0) & 0xFF, in_Ratio);
			
			return (a << 24) | (r << 16) | (g << 8) | (b << 0);
		}

		//lerp
		static public function lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
			return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
		}


		//====
		//要override

		//
		public function calc_color(in_BaseColor:uint, in_Ratio:Number):uint{
			return in_BaseColor;//in_BaseColorに、in_Ratioの要素を加味したものを返すようにする
		}

		//
		public function GetSelectedColor():uint{
			return calc_color(m_InputColor, 1 - m_Cursor[m_CursorIndex].x / (GetBitmapW()-1));
		}


		//==Var==

		//上流から渡された色
		public var m_InputColor:uint = 0xFFFFFFFF;

		//現在のカーソル
		public var m_CursorIndex:int = 0;


		//画像のRoot（直接BitmapやSpriteをCanvasに登録することはできないため）
		public var m_Root:Image;

		//パレット画像
		public var m_BitmapData:BitmapData;

		//カーソル画像
		public var m_Cursor:Array = [];//vec<Sprite>
	}
}

