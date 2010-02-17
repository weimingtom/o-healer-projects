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

	public class Block_Door extends IGameObject{
		//==Const==

		//==Var==

		public var m_IsReverse:Boolean = false;

		public var m_IsOn:Boolean = false;

		public var m_filter_ori:b2FilterData;
		public var m_filter_none:b2FilterData;

		//==Common==

		//Init
		public function Block_Door(in_IsReverse:Boolean):void{
			m_IsReverse = in_IsReverse;
		}

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Type
			{
				if(! m_IsReverse){
					SetBlockType(Game.D);
				}else{
					SetBlockType(Game.R);
				}
			}

			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Flag
			{
				m_IsOn = !m_IsReverse;
			}

			//Graphic Anim
			{
				while(numChildren > 0){//以前の画象は削除
					removeChildAt(0);
				}

				if(! m_IsReverse){
					addChild(ImageManager.LoadBlockImage(Game.D, m_Val));
				}else{
					addChild(ImageManager.LoadBlockImage(Game.R, m_Val));
				}
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;
					ColParam.friction = 0.1;
					ColParam.allow_sleep = false;

//					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_BLOCK);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

					const w:int = ImageManager.PANEL_LEN;//-2;
					CreateCollision_Box(w, w, ColParam);

					m_filter_ori = m_Body.m_shapeList.m_filter;

					m_filter_none = new b2FilterData();
					m_filter_none.categoryBits = 0;
					m_filter_none.maskBits     = 0;
				}

				if(m_IsOn){
					//リセットに備えて、一応オンにしておく
					Change_On();
				}else{
					//オフの状態でスタート
					Change_Off();
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//自分のオンオフとスイッチのオンオフが違えば、スイッチに合わせて挙動変更
			{
				var IsOn:Boolean = (SwitchCounter.Get(m_Val).IsOn() == m_IsReverse);

				if(m_IsOn != IsOn){
					if(IsOn){
						Change_On();
					}else{
						Change_Off();
					}

					m_IsOn = IsOn;
				}
			}
		}

		//On
		public function Change_On():void{
			//コリジョンオン
			m_Body.m_shapeList.m_filter = m_filter_ori;
			//表示オン
			this.alpha = 1.0;

			//接触判定の再計算のため、「今接触しているものは何か」をリセット
//			RemoveSelfFromContactList();
		}

		//Off
		public function Change_Off():void{
			//コリジョンオフ
			m_Body.m_shapeList.m_filter = m_filter_none;
			//表示オフ
			this.alpha = 0.3;

			//接触判定の再計算のため、「今接触しているものは何か」をリセット
			RemoveSelfFromContactList();
		}

		//接触判定の再計算のための処理
		public function RemoveSelfFromContactList():void{
			//自分とぶつかってるやつ全員のContactListから自分を除去し、自分のContactListもリセットする
			var iter_self:b2ContactEdge;
			var iter_other:b2ContactEdge;
			for(iter_self = m_Body.m_contactList; iter_self; iter_self = iter_self.next){
				for(iter_other = iter_self.other.m_contactList; iter_other; iter_other = iter_other.next){
					if(iter_other.other == m_Body){
						if(iter_other.prev){
							iter_other.prev.next = iter_other.next;
						}else{
							iter_self.other.m_contactList = iter_other.next;
						}
						if(iter_other.next){
							iter_other.next.prev = iter_other.prev;
						}
					}
				}

				iter_self.other.WakeUp();//Sleepしてる場合があるので起こす
			}
			m_Body.m_contactList = null;
		}
	}
}

