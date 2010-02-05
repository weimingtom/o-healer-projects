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
			//Tab
			{
				super("設定", 0x000000);
			}
		}

		//位置の計算が特殊なので、登録後にContentの中身を作る
		override public function OnRegister():void{
			var i:int;

			//Content
			{
				var Num:int = ITEM_NUM;

				//Callback : Up
				var FuncUp:Array = [
					//NumX
					function(e:Event):void{
						var NewW:int = MyMath.Clamp(Game.Instance().m_Map[0].length + 1, Game.MAP_W_MIN, Game.MAP_W_MAX);
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
						var NewH:int = MyMath.Clamp(Game.Instance().m_Map.length + 1, Game.MAP_H_MIN, Game.MAP_H_MAX);

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
						var NewW:int = MyMath.Clamp(Game.Instance().m_Map[0].length - 1, Game.MAP_W_MIN, Game.MAP_W_MAX);
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
						var NewH:int = MyMath.Clamp(Game.Instance().m_Map.length - 1, Game.MAP_H_MIN, Game.MAP_H_MAX);

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


				var frame:Image = Game.Instance().m_GameFrameImage;
				var FrameW:int = frame.width;
				var FrameH:int = frame.height;
				var RelPointX:Point = new Point(FrameW-ImageManager.GAME_FRAME_W/2, FrameH/2);
				var RelPointY:Point = new Point(FrameW/2, FrameH-ImageManager.GAME_FRAME_H/2);
/*
				var POS_BASE:Array = [//拡大してからボタンを押して開始すると、サイズボタンの位置がずれる
					m_Content.globalToLocal(frame.localToGlobal(RelPointX)),//ゲームの枠の右中央にセットするための相対位置
					m_Content.globalToLocal(frame.localToGlobal(RelPointY)),//ゲームの枠の下中央にセットするための相対位置
				];
/*/
				//オフセットを自前で求める。「Global=Game.Instance()」と捉える
				var offsetX:int;
				var offsetY:int;
				var p:DisplayObject;
				{//相対座標→絶対座標
					p = m_Content;
					while(p){
						offsetX -= p.x;
						offsetY -= p.y;
						p = p.parent;
						if(p == Game.Instance()){break;}
					}
				}
				{//絶対座標→相対座標
					p = frame;
					while(p){
						offsetX += p.x;
						offsetY += p.y;
						p = p.parent;
						if(p == Game.Instance()){break;}
					}
				}
				var POS_BASE:Array = [
					RelPointX.add(new Point(offsetX, offsetY)),
					RelPointY.add(new Point(offsetX, offsetY)),
				];
//*/

				const POS_PLUS:Array = [
					new Point(48/2, 0),
					new Point(0, 48/2),
				];
				const POS_MINUS:Array = [
					new Point(-48/2, 0),
					new Point(0, -48/2),
				];


				//Create Pael Image
				for(i = 0; i < Num; i += 1)
				{
					//Base
					var img_base:Image;
					{
						img_base = ImageManager.CreateSettingImage_Base(i);
						img_base.x = POS_BASE[i].x;
						img_base.y = POS_BASE[i].y;
					}

					//Base : Child
					{
						//数字部分
						{
							var img_val:Image = new Image();
							m_Bitmap_4Val[i] = ImageManager.CreateSettingBitmap_Val();
							img_val.addChild(m_Bitmap_4Val[i]);
							m_Bitmap_4Val[i].x = -m_Bitmap_4Val[i].width/2;
							m_Bitmap_4Val[i].y = -m_Bitmap_4Val[i].height/2;

							img_base.addChild(img_val);
						}

						//Upボタン
						{
							var img_button_up:Image;
							img_button_up = ImageManager.CreateSettingImage_Button_Up(i);
							img_button_up.x = POS_PLUS[i].x;
							img_button_up.y = POS_PLUS[i].y;

							//Click
							img_button_up.addEventListener(//クリック時の挙動を追加
								MouseEvent.MOUSE_DOWN,//押した瞬間にしてみる
								FuncUp[i]
							);

							//MouseOver
							img_button_up.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_UP[i]));

							img_base.addChild(img_button_up);
						}

						//Downボタン
						{
							var img_button_down:Image;
							img_button_down = ImageManager.CreateSettingImage_Button_Down(i);
							img_button_down.x = POS_MINUS[i].x;
							img_button_down.y = POS_MINUS[i].y;

							//Click
							img_button_down.addEventListener(//クリック時の挙動を追加
								MouseEvent.MOUSE_DOWN,//押した瞬間にしてみる
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

