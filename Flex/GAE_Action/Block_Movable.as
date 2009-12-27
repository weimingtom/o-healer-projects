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

	public class Block_Movable extends IGameObject{
		//==Const==

		//==Var==


		//==Common==

		public function Init(i_X:int, i_Y:int):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic Anim
			{
				addChild(ImageManager.LoadBlockImage(ImageManager.BLOCK_INDEX_MOVE));
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 10.0;
					ColParam.friction = 0.5;//0.05;
					ColParam.allow_sleep = true;

					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
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
	}
}

