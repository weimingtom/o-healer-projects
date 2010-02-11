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

	public class Block_Trampoline extends IGameObject{
		//==Const==

		//==Var==


		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic Anim
			{
				if(numChildren <= 0){//まだ生成してなかったら
					addChild(ImageManager.LoadBlockImage(Game.T));
				}
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;
					ColParam.friction = 0.5;//0.05;
					ColParam.allow_sleep = true;

//					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_BLOCK);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK);

					const w:int = ImageManager.PANEL_LEN;//-2;
					CreateCollision_Box(w, w, ColParam);
				}
			}
		}

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}

		public var m_Val:int = 5;

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			const W:int = ImageManager.PANEL_LEN;

			//#Y

			var VY:Number = MyMath.Sqrt(2 * PhysManager.GRAVITY * (m_Val * W*PhysManager.PHYS_SCALE + W/4*PhysManager.PHYS_SCALE))

			//上に乗られた
			{
				if(in_Nrm.y < -0.7){
					//m_Valの数のブロック分、上に移動させる
					//H = 0.5*VY^2/G
					//VY = Sqrt(2 * G * Height)
					in_Obj.SetVY(-VY);
					return;
				}
			}

			//下に接触した
			{
				if(in_Nrm.y >  0.7){
					//必要性が特にないので、適当に上とは逆のベクトルを設定するのみ
					in_Obj.SetVY(VY);
					return;
				}
			}


			//#X

/*
			//地上のプレイヤーをm_Valマス移動させる
			var VX:Number = 60 + m_Val*200;
/*/
			//空中で当たったときにやはりおかしいので、VYと共通の値にする
			var VX:Number = VY;
//*/

			//右側と接触
			{
				if(in_Nrm.x >  0.7){
					in_Obj.SetVX(VX);
					return;
				}
			}
			//左側と接触
			{
				if(in_Nrm.x < -0.7){
					in_Obj.SetVX(-VX);
					return;
				}
			}
		}
	}
}

