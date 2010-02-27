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

	public class ITab extends Image
	{
		//==Var==

		//parent
		public var m_TabWindow:TabWindow;

		//タブ画像
		public var m_TabImage:Image;
		//中身の画像
		public var m_Content:Image;

		//このタブの基本イメージとなる色（これを変換して枠の色や背景色に使う）
		public var m_BaseColor:uint;

		//これは何番目のタブか（セットされていなければマイナス）
		public var m_TabIndex:int = -1;

		//タブに表示する文字列
		public var m_TabName:String = "テスト";

		public var m_TabLength:int = 3;

		//タブにマウスを合わせた時のメッセージ
		public var m_TabMessage:String = "";


		//==Function==

		public function ITab(i_TabName:String, i_BaseColor:uint = 0x000000){
			//Set Param
			{
				m_TabName = i_TabName;

				m_TabLength = 3;//i_TabName.length;

				m_BaseColor = i_BaseColor;
			}

			//Create Dummy Content
			{
				m_Content = ImageManager.CreateTabContentImage(i_BaseColor);
				m_Content.x = ImageManager.TAB_W;
				m_Content.visible = false;

				addChild(m_Content);
			}

			//Create Tab Image
			{
				CreateTab();
			}
		}

		//このタブの登録が終わったときに呼ばれる：overrideして使う
		public function OnRegister():void{
		}

		//Create Tab Image
		public function CreateTab():void{
			//Create
			{
				m_TabImage = ImageManager.CreateTabImage(m_TabName, m_BaseColor);

				m_TabImage.addEventListener(
					MouseEvent.CLICK,//クリックされたら
					function(e:Event):void{Select();}//このタブを採用する
				);

				m_TabImage.addEventListener(
					MouseEvent.MOUSE_OVER,
					function(e:Event):void{HintMessage.Instance().PushMessage(m_TabMessage);}
				);
				m_TabImage.addEventListener(
					MouseEvent.MOUSE_OUT,
					function(e:Event):void{HintMessage.Instance().PopMessage(m_TabMessage);}
				);

				addChild(m_TabImage);
			}
		}

		//Set Param
		public function SetTabIndex(i_Index:int):void{
			m_TabIndex = i_Index;
		}
		public function SetTabWindow(i_TabWindow:TabWindow):void{
			m_TabWindow = i_TabWindow;
		}

		//Select
		public function Select():void{
			//これが選ばれたことを上に通知
			if(m_TabWindow){//一応チェック
				m_TabWindow.Select(m_TabIndex);
			}
		}

		//Show Message
		public function CreateShowMessagehandler(i_MessageStr:String):Function{
			//メッセージウィンドウのstatic関数で生成した方が良いかも
			return function(e:Event):void{
				HintMessage.Instance().PushMessage(i_MessageStr);
			}
		}
		//Hide Message
		public function CreateHideMessagehandler(i_MessageStr:String):Function{
			//メッセージウィンドウのstatic関数で生成した方が良いかも
			return function(e:Event):void{
				HintMessage.Instance().PopMessage(i_MessageStr);
			}
		}

		//Update
		public function Update(i_DeltaTime:Number):void{
			//overrideして使う
		}
	}
}

