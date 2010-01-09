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

	public class TabWindow extends Image{
		//==Const==

		//タブの（一文字あたりの）高さ
		static public const TAB_H:int = 16;
		//タブの幅
		static public const TAB_W:int = 32;


		//==Var==

		//登録されたタブをリストに入れて管理する
		public var m_TabList:Array = [];

		//現在表示中のタブ（の中身）
		public var m_SelectedContent:Image;

		//現在表示中のタブのIndex
		public var m_SelectedIndex:int = -1;

		//ベースの画像
		public var m_BaseImage:Image;


		//==Function==

		//Init
		public function TabWindow(i_X:int, i_Y:int, i_W:int, i_H:int){
			//Pos
			{
				this.x = i_X;
				this.y = i_Y;
			}

			//Image
			{
				m_BaseImage = ImageManager.CreateTabWindow(i_W, i_H);

				addChild(m_BaseImage);
			}
		}

		//Regist
		public function AddTab(i_Tab:ITab):void{
			var index:int = m_TabList.length;

			//Add
			{
				m_TabList.push(i_Tab);
			}

			//Register
			{
				addChild(i_Tab);
			}

			//Set Param
			{
				i_Tab.SetTabIndex(index);

				i_Tab.SetTabWindow(this);
			}

			//タブの表示位置調整
			{
				var offset:int;
				{
					if(index <= 0){
						offset = 0;
					}else{
						offset = TAB_H;
					}

					for(var i:int = 0; i < index; i += 1){
						offset += (m_TabList[i].m_TabLength + 1) * TAB_H;
					}
				}

				i_Tab.m_TabImage.y = offset;
			}

			//初めての追加なら、それを表示する
			{
				if(index == 0){
					Select(index);
				}
			}
		}

		//Select
		public function Select(i_Index:int):void{
			//Check
			{
				if(m_SelectedIndex == i_Index){
					return;
				}
			}

			//Set
			{
				m_SelectedIndex = i_Index;
			}

			//Show
			{
				Show(i_Index);
			}
		}

		//Show
		public function Show(i_Index:int):void{
			//Off
			{
				if(m_SelectedContent){
					m_SelectedContent.visible = false;
				}
			}

			//Set
			{
				m_SelectedContent = m_TabList[i_Index].m_Content;
			}

			//On
			{
				if(m_SelectedContent){//一応チェック
					m_SelectedContent.visible = true;
				}
			}
		}

		//Update
		public function Update(i_DeltaTime:Number):void{
			//現在選択されているタブのUpdateを呼ぶだけ
			if(0 < m_SelectedIndex && m_SelectedIndex < m_TabList.length){
				if(m_TabList[m_SelectedIndex]){
					m_TabList[m_SelectedIndex].Update(i_DeltaTime);
				}
			}
		}
	}
}
