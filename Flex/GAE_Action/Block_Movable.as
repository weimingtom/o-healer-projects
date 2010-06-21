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

	public class Block_Movable extends IGameObject{
		//==Const==

		//==Var==


		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			Reset_Inner(i_X, i_Y, ImageManager.PANEL_LEN, ImageManager.PANEL_LEN);
		}

		//Reset
		public function Reset_Inner(i_X:int, i_Y:int, i_W:int, i_H:int):void{
			//Type
			{
				SetBlockType(Game.Q);
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

				addChild(ImageManager.LoadBlockImage(Game.Q, m_Val));

				this.scaleX = i_W / ImageManager.PANEL_LEN;
				this.scaleY = i_H / ImageManager.PANEL_LEN;
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
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
/*
					SetOwnCategory(ColParam, CATEGORY_BLOCK);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

					const w:int = ImageManager.PANEL_LEN;//-2;
					CreateCollision_Box(w, w, ColParam);
/*/
					//八角形の独自形状にするので、自分で操作する
					//Create : Base
					{
						CreateBody(ColParam);
					}

					//Add Shape
					{
						SetOwnCategory(ColParam, CATEGORY_BLOCK);
						SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

						var shapeDef:b2PolygonDef = new b2PolygonDef();
						{//八角形
							var d:Number = 4.0 / PhysManager.PHYS_SCALE;//削り取る角の辺の長さ
							const w:Number = i_W/2 / PhysManager.PHYS_SCALE;//基本となる四角形の長さ（の半分）
							const h:Number = i_H/2 / PhysManager.PHYS_SCALE;//外部からWとは別にHを指定できるようにしたので対応

							if(w < d){d = w/2;}
							if(h < d){d = h/2;}

							shapeDef.vertexCount = 8;
/*
							//反時計回りに頂点を設定
							shapeDef.vertices[0].Set(-w+d, -h  );//北北西
							shapeDef.vertices[1].Set(-w,   -h+d);//西北西
							shapeDef.vertices[2].Set(-w,    h-d);//西南西
							shapeDef.vertices[3].Set(-w+d,  h);//南南西
							shapeDef.vertices[4].Set( w-d,  h);//南南東
							shapeDef.vertices[5].Set( w,    h-d);//東南東
							shapeDef.vertices[6].Set( w,   -h+d);//東北東
							shapeDef.vertices[7].Set( w-d, -h);//北北東
/*/
							//時計回りに頂点を設定
							shapeDef.vertices[0].Set( w-d, -h);//北北東
							shapeDef.vertices[1].Set( w,   -h+d);//東北東
							shapeDef.vertices[2].Set( w,    h-d);//東南東
							shapeDef.vertices[3].Set( w-d,  h);//南南東
							shapeDef.vertices[4].Set(-w+d,  h);//南南西
							shapeDef.vertices[5].Set(-w,    h-d);//西南西
							shapeDef.vertices[6].Set(-w,   -h+d);//西北西
							shapeDef.vertices[7].Set(-w+d, -h  );//北北西
//*/
						}
						shapeDef.density = ColParam.density;
						shapeDef.friction = ColParam.friction;
		//				shapeDef.restitution = ColParam.restitution;
						shapeDef.filter.categoryBits = ColParam.category_bits;
						shapeDef.filter.maskBits = ColParam.mask_bits;

						m_Body.CreateShape(shapeDef);
						if(ColParam.density > 0){
							m_Body.SetMassFromShapes();
						}
					}
//*/
				}

				//For Search
				{
					m_SearchType = SEARCH_TYPE_BOX;
					m_SearchW = ImageManager.PANEL_LEN/2;
					m_SearchH = ImageManager.PANEL_LEN/2;
				}
			}
		}

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}
	}
}

