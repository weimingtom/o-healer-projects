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

	public class Block_Accel extends IGameObject{
		//==Const==

		//==Var==

		public var m_Image_Block:Image;

		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Type
			{
				SetBlockType(Game.A);
			}

			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic Anim
			{
				if(! m_Image_Block){//まだ生成してなかったら
					m_Image_Block = ImageManager.LoadBlockImage(Game.A);
					addChild(m_Image_Block);
				}

				switch(m_Dir){
				case DIR_L:
					m_Image_Block.rotation = 270;
					break;
				case DIR_R:
					m_Image_Block.rotation = 90;
					break;
				case DIR_U:
					m_Image_Block.rotation = 0;
					break;
				case DIR_D:
					m_Image_Block.rotation = 180;
					break;
				}
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;
					ColParam.friction = 0.00001;//0.5;//0.05;
					ColParam.allow_sleep = true;

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

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			const W:int = ImageManager.PANEL_LEN;

			var Val:int;
			{
				if(m_Val > 0){
					Val = m_Val;
				}else{
					Val = 5;
				}
			}


/*
			//トランポリンと同じ計算
			var V:Number = MyMath.Sqrt(2 * PhysManager.GRAVITY * (Val * W*PhysManager.PHYS_SCALE + W/4*PhysManager.PHYS_SCALE))
			//より弱めてみる
			V *= 0.3;
/*/
			var V:Number = m_Val * 40.0;
//*/

			//速度の強制セット
			switch(m_Dir){
			case DIR_L:
				if(in_Obj.GetVX() > -V){
					in_Obj.SetVX(-V);
				}
				break;
			case DIR_R:
				if(in_Obj.GetVX() <  V){
					in_Obj.SetVX( V);
				}
				break;
			case DIR_U:
				if(in_Obj.GetVY() > -V){
					in_Obj.SetVY(-V);
				}
				break;
			case DIR_D:
				if(in_Obj.GetVY() <  V){
					in_Obj.SetVY( V);
				}
				break;
			}
		}
	}
}

