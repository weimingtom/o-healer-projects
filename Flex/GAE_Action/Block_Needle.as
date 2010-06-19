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

	public class Block_Needle extends IGameObject{
		//==Const==

		//==Var==

		public var m_Image_Block:Image;

		//==Common==

		//Reset
		//override public function Reset(i_X:int, i_Y:int):void
		public function Init(i_LX:int, i_RX:int, i_UY:int, i_DY:int):void
		{
			//Type
			{
				SetBlockType(Game.N);
			}

			var center_x:int;
			var center_y:int;
			var w:int;
			var h:int;
			{
				center_x = (i_LX+i_RX+1)/2 * ImageManager.PANEL_LEN;
				center_y = (i_UY+i_DY+1)/2 * ImageManager.PANEL_LEN;

				w = (i_RX - i_LX + 1) * ImageManager.PANEL_LEN;
				h = (i_DY - i_UY + 1) * ImageManager.PANEL_LEN;
			}

			//Pos
			{
				SetPos(center_x, center_y);
			}
/*
			//Graphic Anim
			{
				if(! m_Image_Block){//まだ生成してなかったら
					m_Image_Block = ImageManager.LoadBlockImage(Game.N);
					addChild(m_Image_Block);
				}
			}
//*/
			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;
					ColParam.friction = 0.01;//0.5;//0.05;
					ColParam.allow_sleep = true;

//					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_BLOCK);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

					CreateCollision_Box(w, h, ColParam);
				}
			}
		}

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			if(in_Obj is Player){
				in_Obj.AddDamage(1);
			}
		}
	}
}

