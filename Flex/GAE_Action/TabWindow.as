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
					offset = -ImageManager.TAB_W/2;//半マス上から始める

					for(var i:int = 0; i < index; i += 1){
						offset += (m_TabList[i].m_TabLength + 1) * ImageManager.TAB_W;
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

			//タブの表示順序を整える
			{
				Show(m_SelectedIndex);//面倒なのでこれで
			}

			//タブの登録が終わったので、事後処理があれば呼ぶ
			{
				i_Tab.OnRegister();
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
			//コンテナの表示を差し替える
			{
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

			//タブの手前描画の順序を変更
			{
				var i:int;
				var num:int = m_TabList.length;

				//まずは全てのタブを表示から外す
				for(i = 0; i < num; i += 1){
					removeChild(m_TabList[i]);
				}

				//選択したやつの手前までは順番に再登録
				for(i = 0; i < i_Index; i += 1){
					addChild(m_TabList[i]);
				}

				//選択したやつ以降のものは逆順に登録
				for(i = num-1; i >= i_Index; i -= 1){
					addChild(m_TabList[i]);
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
