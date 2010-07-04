//author Show=O=Healer
package{
/*
	ToDO

	・コリジョンの連結
	　・上は水平方向に連結、左右は縦方向に連結
	　・具体的な繋げ方から考える
*/



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

	public class Block_Cluster extends IGameObject{
		//==Const==

		//==Var==

		public var m_Root:Image;

		public var m_Map:Array;


		//==Common==

		public function Init(i_PointList:Array, in_LX:int, in_RX:int, in_UY:int, in_DY:int):void{
			var Num:int = i_PointList.length;
			var NumX:int = in_RX - in_LX + 1;
			var NumY:int = in_DY - in_UY + 1;
			var i:int;

			//var map:Array;
			{
				//Init
				{
					m_Map = new Array(NumY);
					for(var y:int = 0; y < NumY; y++){
						m_Map[y] = new Array(NumX);
						for(var x:int = 0; x < NumX; x++){
							m_Map[y][x] = Game.O;
						}
					}
				}

				//Set
				{
					for(i = 0; i < Num; i++){
						var point:Point = i_PointList[i];

						x = point.x - in_LX;
						y = point.y - in_UY;

						m_Map[y][x] = Game.L;
					}
				}
			}

			//コリジョンを作る範囲のリスト
			var col_rect_list:Array = [];
			{//横方向に並んでるものはまとめて、さらに縦も同じ位置・同じ幅であればまとめる

				//まとめるための関数
				const clustering:Function = function(in_LX:int, in_RX:int, in_Y:int):void{
					//今回の分の範囲
					var rect:Rectangle = new Rectangle(in_LX, in_Y, in_RX-in_LX+1, 1);

					//すでに求めた範囲のやつと一体化できるなら一体化する
					var col_num:int = col_rect_list.length;
					for(i = 0; i < col_num; i++){
						//検証対象
						var trg_rect:Rectangle = col_rect_list[i];

						//一体化できるか
						var union_flag:Boolean = true;
						{
							//幅が違えば一体化しない
							if(trg_rect.x != rect.x || trg_rect.width != rect.width){
								union_flag = false;
							}

							//自分の一つ上でなければ一体化しない
							{
								var trg_next_y:int = trg_rect.y + trg_rect.height;
								if(trg_next_y != in_Y){
									union_flag = false;
								}
							}
						}

						//一体化
						if(union_flag){
							trg_rect.height += 1;//下にくっつけたことにすればOKのはず

							return;//一体化したので新規登録はせずに終了
						}
					}

					//一体化できるものがなければ、新規登録
					col_rect_list.push(rect);
				}

				//まとめ中かそうでないかのフラグ
				var NowClustering:Boolean = false;

				//イテレーション開始
				var lx:int, rx:int;
				for(y = 0; y < NumY; y++){
					for(x = 0; x < NumX; x++){
						var IsBlock:Boolean = (m_Map[y][x] == Game.L);

						if(! NowClustering){//Lをまだ見つけていない
							if(! IsBlock){//今回のもLじゃない
								//何もせず次へ進む
							}else{//Lを見つけた
								//クラスタリング開始
								NowClustering = true;
								//左端はここ
								lx = x;
								//右端もここ
								rx = x;
							}
						}else{//Lをすでに見つけていて、それを連結中
							if(IsBlock){//今回のもLだった
								//右端を伸ばす
								rx = x;
							}else{//Lが途切れた
								//前回位置までをクラスタリング
								clustering(lx, rx, y);
								//クラスタリング終了
								NowClustering = false;
							}
						}
					}

					if(NowClustering){//右端までLだった
						//まとめる
						rx = x-1;
						clustering(lx, rx, y);
						//クラスタリング終了
						NowClustering = false;
					}
				}
			}

			//Type
			{
				SetBlockType(Game.L);
			}


			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 10.0;
					ColParam.friction = 0.05;//0.5;
					ColParam.allow_sleep = true;

					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					//Create : Base
					{
						CreateBody(ColParam);
					}

					//Add Shape
					{
						SetOwnCategory(ColParam, CATEGORY_BLOCK);
						SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

						var shapeDef:b2PolygonDef = new b2PolygonDef();
						shapeDef.density = ColParam.density;
						shapeDef.friction = ColParam.friction;
		//				shapeDef.restitution = ColParam.restitution;
						shapeDef.filter.categoryBits = ColParam.category_bits;
						shapeDef.filter.maskBits = ColParam.mask_bits;

						var col_w:Number = (ImageManager.PANEL_LEN/2.0) / PhysManager.PHYS_SCALE;
						var center:b2Vec2 = new b2Vec2();
/*
						for(i = 0; i < Num; i++){
							center.x = ImageManager.PANEL_LEN * (i_PointList[i].x + 0.5) / PhysManager.PHYS_SCALE;
							center.y = ImageManager.PANEL_LEN * (i_PointList[i].y + 0.5) / PhysManager.PHYS_SCALE;

							shapeDef.SetAsOrientedBox(col_w, col_w, center);

							m_Body.CreateShape(shapeDef);
						}
/*/
						var col_num:int = col_rect_list.length;
						for(i = 0; i < col_num; i++){
							var rect:Rectangle = col_rect_list[i];

							//W
							var w:Number = (rect.width/2 * ImageManager.PANEL_LEN - 0.01) / PhysManager.PHYS_SCALE;
							var h:Number = (rect.height/2 * ImageManager.PANEL_LEN - 0.01) / PhysManager.PHYS_SCALE;

							//center
							center.x = ImageManager.PANEL_LEN * (in_LX + (rect.left + rect.right)/2) / PhysManager.PHYS_SCALE;
							center.y = ImageManager.PANEL_LEN * (in_UY + (rect.top + rect.bottom)/2) / PhysManager.PHYS_SCALE;

							shapeDef.SetAsOrientedBox(w, h, center);

							m_Body.CreateShape(shapeDef);
						}
//*/

						if(ColParam.density > 0){
							m_Body.SetMassFromShapes();
						}
					}
				}
			}

//			var pos:b2Vec2;

			//Pos
//			{
//				pos = m_Body.GetLocalCenter();
//				SetPos(pos.x * PhysManager.PHYS_SCALE, pos.y * PhysManager.PHYS_SCALE);
//				SetPos(ImageManager.PANEL_LEN/2, ImageManager.PANEL_LEN/2);
//			}

			//Graphic Anim
			{//グラフィックは本体側でまとめて管理する
/*
				//m_Root
				{
					m_Root = new Image();

//					pos = m_Body.GetLocalCenter();
//					m_Root.x = -pos.x * PhysManager.PHYS_SCALE;
//					m_Root.y = -pos.y * PhysManager.PHYS_SCALE;

					addChild(m_Root);
				}

				//Block
				{
					for(i = 0; i < Num; i++){
						var img:Image = ImageManager.LoadBlockImage(Game.L);
						img.x = ImageManager.PANEL_LEN * (i_PointList[i].x + 0.5);
						img.y = ImageManager.PANEL_LEN * (i_PointList[i].y + 0.5);
						m_Root.addChild(img);
					}
				}
/*/
				//m_Root
				{
					m_Root = new Image();

					m_Root.x = in_LX * ImageManager.PANEL_LEN;
					m_Root.y = in_UY * ImageManager.PANEL_LEN;

					addChild(m_Root);
				}

				//Block
				{
					var bmp_data:BitmapData = new BitmapData(NumX * ImageManager.PANEL_LEN, NumY * ImageManager.PANEL_LEN, true, 0x00000000);

					ImageManager.DrawBlockCluster(bmp_data, m_Map);

					m_Root.addChild(new Bitmap(bmp_data));
				}
//*/
			}
		}

		//Reset:オーバライドして使う
		override public function Reset(i_X:int, i_Y:int):void{
			//基本的には(0,0)にリセットされればOKなはず
			SetPos(i_X, i_Y);
		}

//		//Update:オーバライドして使う
//		override public function Update(i_DeltaTime:Number):void{
//		}

		//指定位置に居るOBJを探して返す（特殊な形状をしているので独自実装）
		override public function SearchObj(in_X:int, in_Y:int):Object{
			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			//ブロックの左上の座標
			var lx:int = this.x + m_Root.x;
			var uy:int = this.y + m_Root.y;

			//ブロックのIndexとして表現した場合の指定座標
			var IndexX:int = (in_X - lx) / ImageManager.PANEL_LEN;
			var IndexY:int = (in_Y - uy) / ImageManager.PANEL_LEN;

			//範囲チェック
			{
				if(IndexX < 0){return null;}
				if(NumX <= IndexX){return null;}
				if(IndexY < 0){return null;}
				if(NumY <= IndexY){return null;}
			}

			//ヒットチェック
			{
				if(m_Map[IndexY][IndexX] != Game.L){
					return null;
				}
			}

			//ヒットするようなので情報を返す
			return {
				target:this,
				anchor:(new Vector3D(in_X - this.x, in_Y - this.y))
			};
		}
	}
}

