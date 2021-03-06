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

	public class Enemy_Rolling extends IGameObject{
		//==Const==

		//==Var==

		public var m_GraphicList:Array;

		public var m_IsFindPlayer:Boolean = true;

		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Type
			{
				SetBlockType(Game.E);
			}

			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Flag
			{
				m_CheckPressFlag = true;
				m_SearchForceCenter = true;
			}

			//Graphic Anim
			{
				if(! m_GraphicList){//まだ生成してなかったら
					m_GraphicList = ImageManager.LoadEnemyImage("Enemy_Rolling");
					addChild(m_GraphicList[0]);
				}
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 30.0;
					ColParam.friction = 0.5;
					ColParam.allow_sleep = true;
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_ENEMY);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

					const rad:int = ImageManager.PANEL_LEN/2 - 1;
					CreateCollision_Circle(rad, ColParam);
				}

				//For Search
				{
					m_SearchW = ImageManager.PANEL_LEN/2 * 1.5;
					m_SearchH = ImageManager.PANEL_LEN/2 * 1.5;
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			var PlayerX:int = Game.Instance().m_Player.x;

			if(m_IsFindPlayer){
				var RadPerSecond:Number = 3.0 * 2.0*MyMath.PI;//回転速度（一秒あたりの回転量）

				//重力反転を考慮
				if(PhysManager.Instance.IsGravityReversed()){
					RadPerSecond = -RadPerSecond;
				}

				if(this.x < PlayerX){
					//右へ移動
					m_Body.SetAngularVelocity(RadPerSecond);
				}else{
					//左へ移動
					m_Body.SetAngularVelocity(-RadPerSecond);
				}
			}else{
			}
		}

		//圧死時の処理：オーバーライドして使う
		override public function OnPressDead(in_Nrm:Vector3D):void{
			//死亡エフェクト
			Effect_Bomb.Create(this.x, this.y);

			//死亡
			Kill();
		}

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			if(in_Obj is Player){
				in_Obj.AddDamage(1);
			}
		}


		//コリジョンに応じて回転する部分とそうでない部分をわけるためにoverride
		override public function Phys2Obj():void{
			//Ori
			{
				super.Phys2Obj();
			}
/*
			//物理的な回転量
			var rot:Number;
			{
				rot =  this.rotation;
				this.rotation = 0;
			}

			//回転させるグラフィックにのみ適用
			{
				m_RotImage.rotation = rot;
			}
//*/
		}
	}
}

