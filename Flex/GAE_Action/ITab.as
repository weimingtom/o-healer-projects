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

		//これは何番目のタブか（セットされていなければマイナス）
		public var m_TabIndex:int = -1;

		//タブに表示する文字列
		public var m_TabName:String = "TEST";

		public var m_TabLength:int = 4;


		//==Function==

		public function ITab(i_TabName:String){
			//Set Param
			{
				m_TabName = i_TabName;

				m_TabLength = i_TabName.length;
			}

			//Create Tab Image
			{
				CreateTab();
			}

			//Create Dummy Content
			{
				m_Content = new Image();
				m_Content.x = TabWindow.TAB_W;
				m_Content.visible = false;

				addChild(m_Content);
			}
		}

		//Create Tab Image
		public function CreateTab():void{
			//Create
			{
				m_TabImage = ImageManager.CreateTabImage(m_TabName);

				m_TabImage.addEventListener(
					MouseEvent.CLICK,//クリックされたら
					function(e:Event):void{Select();}//このタブを採用する
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
	//			MyMessageWindow.ShowMessage(i_MessageStr);
			}
		}

		//Update
		public function Update(i_DeltaTime:Number):void{
			//overrideして使う
		}
	}
}

