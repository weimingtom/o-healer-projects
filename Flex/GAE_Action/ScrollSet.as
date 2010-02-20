//author Show=O=Healer
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
	//Box2D
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;

	//スクロールバー、上下ボタンなどの一通りのセット
	public class ScrollSet extends Image{
		//==Const==

		//==Var==

		//#外側から書き換える

		//上ボタンが押された時の挙動
		public var OnUp:Function = function():void{};

		//下ボタンが押された時の挙動
		public var OnDown:Function = function():void{};

		//スクロールバーを操作された時の挙動
		public var ByRatio:Function = function(i_Ratio:Number):void{};


		//==Common==

		//Init
		public function Init(i_H:int):void{
/*
			//m_Button_Up
			var m_Button_Up:Image;
			{
				//Create
				m_Button_Up = ImageManager.CreateScrollImage_Up();

				//Pos
				m_Button_Up.x = 0;
				m_Button_Up.y = 0;

				//Mouse
				m_Button_Up.addEventListener(//クリック時の挙動を追加
					MouseEvent.CLICK,//クリックされたら
					function(e:Event):void{OnUp();}//OnUpを実行
				);

				//Register
				addChild(m_Button_Up);
			}

			//m_Button_Down
			var m_Button_Down:Image;
			{
				//Create
				m_Button_Down = ImageManager.CreateScrollImage_Down();

				//Pos
				m_Button_Down.x = 0;
				m_Button_Down.y = i_H - m_Button_Down.height;

				//Mouse
				m_Button_Down.addEventListener(//クリック時の挙動を追加
					MouseEvent.CLICK,//クリックされたら
					function(e:Event):void{OnDown();}//OnDownを実行
				);

				//Register
				addChild(m_Button_Down);
			}
//*/
			//ScrollHeight
//			var ScrollHeight:int = i_H - m_Button_Up.height - m_Button_Down.height;
			var ScrollHeight:int = i_H;

			//m_ScrollUnderBar
			var m_ScrollUnderBar:Image;
			{
				//Create
				m_ScrollUnderBar = ImageManager.CreateScrollImage_UnderBar(ScrollHeight);

				//Pos
				m_ScrollUnderBar.x = 0;
				m_ScrollUnderBar.y = 0;//m_Button_Up.height;

				//Register
				addChild(m_ScrollUnderBar);
			}
			//m_ScrollBar
			var m_ScrollBar:Image;
			{
				//Create
				m_ScrollBar = ImageManager.CreateScrollImage_Bar(ScrollHeight);

				//Pos
				m_ScrollBar.x = 0;
				m_ScrollBar.y = 0;

				//Mouse
				var IsScroll:Boolean = false;
				var SrcY:int = 0;
				var SrcMouseY:int = 0;
				//-Down
				m_ScrollBar.addEventListener(//これの上でボタンが押されたらスクロールモードへ移行
					MouseEvent.MOUSE_DOWN,
					function(e:Event):void{
						IsScroll = true;
						SrcY = m_ScrollBar.y;
						SrcMouseY = m_ScrollUnderBar.mouseY;
					}
				);
				//-Move
				root.addEventListener(//スクロールモードならByRatioを呼ぶ
					MouseEvent.MOUSE_MOVE,
					function(e:Event):void{
						if(IsScroll){
							//Pos
							{
								m_ScrollBar.y = SrcY + (m_ScrollUnderBar.mouseY - SrcMouseY);
								if(m_ScrollBar.y < 0){m_ScrollBar.y = 0;}
								if(m_ScrollBar.y > ScrollHeight - m_ScrollBar.height){m_ScrollBar.y = ScrollHeight - m_ScrollBar.height;}
							}

							//Ratio
							{
								var ratio:Number = m_ScrollBar.y / (ScrollHeight - m_ScrollBar.height);
								ByRatio(ratio);
							}
						}
					}
				);
				//-Up
				root.addEventListener(//これの範囲外に行っても、ボタンが離されたならスクロールモード終了
					MouseEvent.MOUSE_UP,
					function(e:Event):void{IsScroll = false;}
				);
				//Register
				m_ScrollUnderBar.addChild(m_ScrollBar);
			}

			//w,h
			this.width = 32;
			this.height = i_H;
		}

	}
}

