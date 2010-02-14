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

	public class Block_Fix extends IGameObject{
		//==Const==

		//==Var==


		//==Common==

		public function Init(i_LX:int, i_RX:int, i_UY:int, i_DY:int):void{
			//Type
			{
				SetBlockType(Game.W);
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

			//Graphic Anim
//			{//グラフィックは本体側でまとめて管理する
//				addChild(ImageManager.LoadBlockImage(Game.W));
//			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;//Fix
					ColParam.friction = 0.1;//1.0;
				}

				//Normal
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_TERRAIN);
					SetHitCategory(ColParam, CATEGORY_BLOCK | CATEGORY_ENEMY);

					CreateCollision_Box(w, h, ColParam);
				}

				//Vs Player
				{//プレイヤー衝突用
					SetOwnCategory(ColParam, CATEGORY_TERRAIN_VS_PLAYER);
					SetHitCategory(ColParam, CATEGORY_PLAYER_VS_TERRAIN);
					ColParam.friction = 0.0;//プレイヤー側で独自計算

					var Offset4PlayerX:int;
					var Offset4PlayerY:int;
					{
						Offset4PlayerX = ImageManager.CHARA_GRAPHIC_LEN_X - 2 * Player.COL_RAD - 1;
						Offset4PlayerY = ImageManager.CHARA_GRAPHIC_LEN_X - 2 * Player.COL_RAD - 1;//ImageManager.CHARA_GRAPHIC_LEN_Y - 2 * Player.COL_RAD - 1;
					}

					CreateCollision_Box(w+Offset4PlayerX, h+Offset4PlayerY, ColParam);
				}
			}
		}

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}
	}
}

