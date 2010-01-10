//author Show=O=Healer
package{
	//
	import flash.display.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.net.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	/*
		・値の上下ボタンは、MaxやMinの時は無効とわかるように灰色っぽくしたい
		　・あるいは描画しなくても良いのかも
		　　・それだとなんかのエラーっぽく見えて、「限界値」というのが伝わらないので、やはり灰色で
	*/

	public class Tab_Setting extends ITab
	{
		//==Const==

		//項目
		static public const ITEM_NUMX:int = 0;
		static public const ITEM_NUMY:int = 1;

		static public const ITEM_NUM:int = 2;

		//ヒントメッセージ
		static public const HINT_MESSAGE_BUTTON_UP:Array = [
			"横のブロック数を増やします",//NumX
			"縦のブロック数を増やします",//NumY
		];
		static public const HINT_MESSAGE_BUTTON_DOWN:Array = [
			"横のブロック数を減らします",//NumX
			"縦のブロック数を減らします",//NumY
		];


		//==Var==

		//実際の値に応じて書きなおすために保持
//		private var m_Bitmap_4NumX:Bitmap;
//		private var m_Bitmap_4NumY:Bitmap;
		private var m_Bitmap_4Val:Array =  new Array(ITEM_NUM);

		//値の変動を知るために、以前の値を覚えておく
		private var m_NumX_Old:int = 0;
		private var m_NumY_Old:int = 0;


		//==Function==

		//Init
		public function Tab_Setting(){
			var i:int;

			//Tab
			{
				super("設定", 0x000000);
			}

			//Content
			{
				var Num:int = ITEM_NUM;

				//Callback : Up
				var FuncUp:Array = [
					//NumX
					function(e:Event):void{
						var NewW:int = MyMath.Clamp(Game.Instance().m_Map[0].length + 1, 1, 100);
						var NewH:int = Game.Instance().m_Map.length;

						//Check
						{
							if(NewW == Game.Instance().m_Map[0].length){
								return;//no change
							}
						}

						//Change
						{
							Game.Instance().ResizeMap(NewW, NewH);
						}
					},
					//NumY
					function(e:Event):void{
						var NewW:int = Game.Instance().m_Map[0].length;
						var NewH:int = MyMath.Clamp(Game.Instance().m_Map.length + 1, 1, 100);

						//Check
						{
							if(NewH == Game.Instance().m_Map.length){
								return;//no change
							}
						}

						//Change
						{
							Game.Instance().ResizeMap(NewW, NewH);
						}
					},
				];

				//Callback : Down
				var FuncDown:Array = [
					//NumX
					function(e:Event):void{
						var NewW:int = MyMath.Clamp(Game.Instance().m_Map[0].length - 1, 1, 100);
						var NewH:int = Game.Instance().m_Map.length;

						//Check
						{
							if(NewW == Game.Instance().m_Map[0].length){
								return;//no change
							}
						}

						//Change
						{
							Game.Instance().ResizeMap(NewW, NewH);
						}
					},
					//NumY
					function(e:Event):void{
						var NewW:int = Game.Instance().m_Map[0].length;
						var NewH:int = MyMath.Clamp(Game.Instance().m_Map.length - 1, 1, 100);

						//Check
						{
							if(NewH == Game.Instance().m_Map.length){
								return;//no change
							}
						}

						//Change
						{
							Game.Instance().ResizeMap(NewW, NewH);
						}
					},
				];

				//Create Pael Image
				for(i = 0; i < Num; i += 1)
				{
					//Base
					var img_base:Image;
					{
						img_base = ImageManager.CreateSettingImage_Base();
						img_base.x = 0;
						img_base.y = i * (32 * 3);
					}

					//Base : Child
					{
						//数字部分
						{
							var img_val:Image = new Image();
							m_Bitmap_4Val[i] = ImageManager.CreateSettingBitmap_Val();
							img_val.addChild(m_Bitmap_4Val[i]);
							img_val.x = 32;
							img_val.y = 32;

							img_base.addChild(img_val);
						}

						//Upボタン
						{
							var img_button_up:Image;
							img_button_up = ImageManager.CreateSettingImage_Button_Up();
							img_button_up.x = 32;
							img_button_up.y = 0;

							//Click
							img_button_up.addEventListener(//クリック時の挙動を追加
								MouseEvent.CLICK,//クリックされたら
								FuncUp[i]
							);

							//MouseOver
							img_button_up.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_UP[i]));

							img_base.addChild(img_button_up);
						}

						//Downボタン
						{
							var img_button_down:Image;
							img_button_down = ImageManager.CreateSettingImage_Button_Down();
							img_button_down.x = 32;
							img_button_down.y = 32 * 2;

							//Click
							img_button_down.addEventListener(//クリック時の挙動を追加
								MouseEvent.CLICK,//クリックされたら
								FuncDown[i]
							);

							//MouseOver
							img_button_down.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_DOWN[i]));

							img_base.addChild(img_button_down);
						}
					}

					//Regist
					m_Content.addChild(img_base);
				}
			}
		}

		//Update
		override public function Update(i_DeltaTime:Number):void{
			var NumX:int = Game.Instance().m_Map[0].length;
			var NumY:int = Game.Instance().m_Map.length;

			if(m_NumX_Old != NumX){
				m_NumX_Old = NumX;

				ImageManager.RedrawSettingBitmap_Val(m_Bitmap_4Val[ITEM_NUMX], NumX);
			}

			if(m_NumY_Old != NumY){
				m_NumY_Old = NumY;

				ImageManager.RedrawSettingBitmap_Val(m_Bitmap_4Val[ITEM_NUMY], NumY);
			}
		}
	}
}

