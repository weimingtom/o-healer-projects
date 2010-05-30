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

	public class Block_Switch extends IGameObject{
		//==Const==

		//==Var==

		public var m_IsOn:Boolean = false;
		public var m_IsOn_Old:Boolean = false;

		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Type
			{
				SetBlockType(Game.S);
			}

			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic Anim
			{
				while(numChildren > 0){//以前の画象は削除
					removeChildAt(0);
				}

				addChild(ImageManager.LoadBlockImage(Game.S, m_Val));
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
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//オンオフのエッジ部分での処理
			{
				if(m_IsOn != m_IsOn_Old){
					if(m_IsOn){
						//新しくオンになった
						SwitchCounter.Get(m_Val).Inc();//スイッチ＋＋（複数のスイッチが想定されるので、自分の分を＋＋）
					}else{
						//新しくオフになった
						SwitchCounter.Get(m_Val).Dec();//スイッチ－－
					}

					m_IsOn_Old = m_IsOn;
				}

				m_IsOn = false;
			}
		}

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			//重力の反転の考慮
			if(PhysManager.Instance.IsGravityReversed()){
				in_Nrm.y = -in_Nrm.y;
			}

			//対応ブロックが上に乗ったらスイッチオン
			{
				if(in_Obj.m_Val == m_Val){//自分と同じ値が指定された
					if(in_Obj.m_BlockType == Game.Q){//動かせるブロックに
						if(in_Nrm.y < -0.9){//上に乗られたら
							m_IsOn = true;//オンにする
						}
					}
				}
			}
		}
	}
}

