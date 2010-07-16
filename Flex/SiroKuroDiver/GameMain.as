/*
　ToDo
　・ブロック移動時の再描画がまだうまくいかない
　　・周辺の地形によるコリジョンを消してしまう
　・ブロック移動時に重くなりすぎる
　　・もっと高速化を
　　　・黒いブロックを動かしたときは、「メイン」「白用」だけ更新して、「黒用」は更新しない
　　　・Drawで共有できる部分は共有
　　　・Glow意外で幅を広くする方法はない？
　・プレイヤーが黒いエリアに入ったら黒いブロックのコリジョンとはぶつからないようにしたい
　・ゲートの可視化
　・ブロックが壁にぶつかったらBox2Dもそういう風に判定させる
　・プレイヤーのコリジョンを半分くらいにする
　・ブロックのコリジョンを縦長に
　・リスタート対応
　・ちゃんとしたゴール処理
*/



package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.ui.Keyboard;

	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;

	public class GameMain extends Sprite{
		//==Const==

		static public const PANEL_LEN:int = 32;//16;

		//マップ
		static public const O:int = 0;
		static public const X:int = 1;
		static public const Q:int = 2;
		static public const V:int = 3;
		static public const P:int = 99;
		static public const G:int = 100;
		static public const B:int = 200;
		static public const MAP:Array = [
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, O, O, O, O, O, O, O, O, X, X, X, X, X, X, X],
			[X, O, O, O, O, O, X, V, X, X, X, X, X, X, X, X],
			[X, P, O, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, O, O, O, O, X, X, X],
			[X, X, X, O, O, O, B, O, O, O, O, G, O, X, X, X],
			[X, X, X, O, O, X, X, X, X, X, O, X, X, X, X, X],
			[X, X, X, X, O, X, X, X, V, X, O, X, X, X, X, X],
			[X, X, X, X, O, O, O, O, O, X, O, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		];


		//==Var==

		//マップの幅
		static public var H:int = 100;//あとでちゃんと更新
		static public var W:int = 100;//あとでちゃんと更新

		//レイヤー：ルート
		public var m_Layer_Root:Sprite = new Sprite();
		//- レイヤー：ゲートエフェクト（エフェクトの部分）
		public var  m_Layer_Gate:Sprite = new Sprite();
		//- レイヤー：地形
		public var  m_Layer_Terrain:Sprite = new Sprite();
		//- レイヤー：ゲート地形（地形の黒い部分）
		public var  m_Layer_GateAsBlock:Sprite = new Sprite();
		//- レイヤー：ブロック：黒
		public var  m_Layer_Block_Black:Sprite = new Sprite();
		//- レイヤー：ブロック：白
		public var  m_Layer_Block_White:Sprite = new Sprite();
		//- レイヤー：プレイヤー
		public var  m_Layer_Player:Sprite = new Sprite();

		//グラフィック
		//- グラフィック：ブロック
		public var  m_BitmapData_Terrain:BitmapData;
		//- グラフィック：ゲート
		public var  m_BitmapData_Gate:BitmapData;
		//- グラフィック：ゲート地形
		public var  m_BitmapData_GateAsBlock:BitmapData;

		//地形判定に使うBitmapData
		public var m_BitmapData_Collision:BitmapData;
		public var m_BitmapData_Collision_ForBlackBlock:BitmapData;
		public var m_BitmapData_Collision_ForWhiteBlock:BitmapData;

		//汎用ビットマップ（地形の計算に利用する）
		public var m_BitmapData_Util_0:BitmapData;
		public var m_BitmapData_Util_1:BitmapData;

		//コリジョン描画用Dirtyフラグまわり
		public var m_DirtyFlag:Boolean = false;
		public var m_DirtyFlag_ForBlackBlock:Boolean = false;
		public var m_DirtyFlag_ForWhiteBlock:Boolean = false;
		public var m_RedrawRect:Rectangle = new Rectangle();
		public var m_RedrawPoint:Point = new Point();

		//#Physics
	   	public var m_PhysWorld:b2World;

		//プレイヤー
		public var m_Player:Player;

		//プレイヤー表示切り替え用マスク
		public var m_ShapeMask_ForPlayer:Sprite = new Sprite();

		//==Function==

		//Static Global Access
		static private var m_Instance:GameMain;
		static public function Instance():GameMain{return m_Instance;}

		//#Init
		public function GameMain(){
			//Init Later (for Using "stage" etc.)
			addEventListener(Event.ADDED_TO_STAGE, Init);

			m_Instance = this;
		}
		
		public function Init(e:Event = null):void{
			var x:int, y:int;

			//Init Once Only
			{
				removeEventListener(Event.ADDED_TO_STAGE, Init);
			}

			//Common Param
			{
				W = MAP[0].length * PANEL_LEN;
				H = MAP.length * PANEL_LEN;
			}

	    	//Setup Box2D
	    	//m_PhysWorld
	    	{//座標系はスケーリングせず、物理エンジン中の位置とドットの位置は同じ値になるようにする
	    		//Create World
	    		{
		    		var worldAABB:b2AABB;
		    		{
		    			worldAABB = new b2AABB();
			    		worldAABB.lowerBound.Set(-W, -H);
		    			worldAABB.upperBound.Set(2*W, 2*H);
		    		}

		    		var gravity:b2Vec2;
		    		{
		    			gravity = new b2Vec2(0, 600 / IGameObject.PHYS_SCALE);
		    		}

		    		m_PhysWorld = new b2World(worldAABB, gravity, true);
	    		}
	    	}

			//BG
			{
				addChild(new Bitmap(new BitmapData(W, H, false, 0xFFFFFF)));
				//addChild(new Bitmap(new BitmapData(W, H, false, 0x000000)));//確認用
			}

			//Layer
			{
				addChild(m_Layer_Root);
				{
					m_Layer_Root.addChild(m_Layer_Gate);
					m_Layer_Root.addChild(m_Layer_Terrain);
					m_Layer_Root.addChild(m_Layer_GateAsBlock);
					m_Layer_Root.addChild(m_Layer_Block_Black);
					m_Layer_Root.addChild(m_Layer_Block_White);
					m_Layer_Root.addChild(m_Layer_Player);

					m_Layer_Player.addChild(m_ShapeMask_ForPlayer);
				}
			}

			//グラフィック：下準備
			{
				//m_BitmapData_Terrain
				{
					m_BitmapData_Terrain = new BitmapData(W,H, true, 0x00000000);
					m_Layer_Terrain.addChild(new Bitmap(m_BitmapData_Terrain));
				}

				//m_BitmapData_Gate
				{
					m_BitmapData_Gate = new BitmapData(W,H, true, 0x00000000);
					m_Layer_Gate.addChild(new Bitmap(m_BitmapData_Gate));
				}

				//m_BitmapData_GateAsBlock
				{
					m_BitmapData_GateAsBlock = new BitmapData(W,H, true, 0x00000000);
					m_Layer_GateAsBlock.addChild(new Bitmap(m_BitmapData_GateAsBlock));
				}
			}

			//コリジョン：下準備
			{
				//m_BitmapData_Collision
				{
					m_BitmapData_Collision = new BitmapData(W,H, true, 0x00000000);
					m_BitmapData_Collision_ForBlackBlock = new BitmapData(W,H, true, 0x00000000);
					m_BitmapData_Collision_ForWhiteBlock = new BitmapData(W,H, true, 0x00000000);
				}
			}

			//MAPに基づく処理
			var PlayerX:int = 0;
			var PlayerY:int = 0;
			var GoalX:int = 0;
			var GoalY:int = 0;
			{
				var NumX:int = MAP[0].length;
				var NumY:int = MAP.length;

				var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);
				var mtx:Matrix = new Matrix();

				//ゲートエフェクト用
				var GateEffect:Sprite = new Sprite();
				{
					var s:Shape;
					var g:Graphics;

					//X
					{
						s = new Shape();
						GateEffect.addChild(s);

						//Draw Rect
						g = s.graphics;
						g.lineStyle(0, 0x0000000, 0.0);
						g.beginFill(0x000000, 1.0);
						g.drawRect(0,0, PANEL_LEN,PANEL_LEN);
						g.endFill();

						//Draw Effect
						s.filters = [new GlowFilter(0x0088FF, 1.0, PANEL_LEN,1)];
					}

					//Y
					{
						s = new Shape();
						GateEffect.addChild(s);

						//Draw Rect
						g = s.graphics;
						g.lineStyle(0, 0x0000000, 0.0);
						g.beginFill(0x000000, 1.0);
						g.drawRect(0,0, PANEL_LEN,PANEL_LEN);
						g.endFill();

						//Draw Effect
						s.filters = [new GlowFilter(0x0088FF, 1.0, 1,PANEL_LEN)];
					}
				}

				//プレイヤー表示のマスク用
				var mask_for_player:Graphics;
				{
					var mask_shape:Shape = new Shape();
					m_ShapeMask_ForPlayer.addChild(mask_shape);

					mask_for_player = mask_shape.graphics;
					mask_for_player.lineStyle(0, 0x000000, 0.0);
					mask_for_player.beginFill(0x000000, 1.0);
				}

				//MAPの要素に応じた処理
				for(y = 0; y < NumY; y++){
					rect.y = y * PANEL_LEN;
					mtx.ty = rect.y;
					for(x = 0; x < NumX; x++){
						rect.x = x * PANEL_LEN;
						mtx.tx = rect.x;

						switch(MAP[y][x]){
						case O://空間
							break;
						case X://ブロック
							m_BitmapData_Terrain.fillRect(rect, 0xFF000000);
							mask_for_player.drawRect(rect.x, rect.y, rect.width, rect.height);
							break;
						case V://隣接する空間と移動可能なブロック
							m_BitmapData_GateAsBlock.fillRect(rect, 0xFF000000);
							m_BitmapData_Gate.draw(GateEffect, mtx);
							mask_for_player.drawRect(rect.x, rect.y, rect.width, rect.height);
							break;

						case P://プレイヤー位置（それ以外は空間扱い）
							PlayerX = rect.x + PANEL_LEN/2;
							PlayerY = rect.y + PANEL_LEN/2;
							break
						case G://ゴール位置（それ以外は空間扱い）
							GoalX = rect.x + PANEL_LEN/2;
							GoalY = rect.y + PANEL_LEN/2;
							break
//*
						case B://黒ブロック位置
							{
								m_Layer_Block_Black.addChild(
									new MovableBlock(m_PhysWorld, rect.x + PANEL_LEN/2, rect.y + PANEL_LEN/2)
								);
							}
							break;
//*/
						}
					}
				}

				//後処理
				{
					mask_for_player.endFill();
				}
			}

			//Player
			{
				m_Player = new Player(m_PhysWorld, PlayerX, PlayerY);
				m_Layer_Player.addChild(m_Player);
			}

			//Goal
			{
				m_Layer_Root.addChild(new Goal(GoalX, GoalY));
			}

			//Bitmap : Util
			{
				m_BitmapData_Util_0 = new BitmapData(W, H, true, 0x00000000);
				m_BitmapData_Util_1 = new BitmapData(W, H, true, 0x00000000);
			}

			//Dirty
			{
				ResetDirty();
			}

			//コリジョンを実際に描画
			{
				m_DirtyFlag_ForBlackBlock = true;
				m_DirtyFlag_ForWhiteBlock = true;
				RedrawCollision(new Rectangle(0,0,W,H), new Point());
//				RedrawCollision(new Rectangle(2*PANEL_LEN,0,W-2*PANEL_LEN,H), new Point(2*PANEL_LEN));//test
			}

			//Call "Update"
			{
				addEventListener(Event.ENTER_FRAME, Update);
			}

			//Debug
//			m_Layer_Root.addChild(new Bitmap(m_BitmapData_Collision));//コリジョンの可視化
//			m_Layer_Root.addChild(new Bitmap(m_BitmapData_Collision_ForBlackBlock));//コリジョンの可視化
//			m_Layer_Root.addChild(new Bitmap(m_BitmapData_Collision_ForWhiteBlock));//コリジョンの可視化
		}

		//#Update
		public function Update(e:Event=null):void{
			const DeltaTime:Number = 1/24.0;

			//Redraw Collision
			if(m_DirtyFlag){
				//
				RedrawCollision(m_RedrawRect, m_RedrawPoint);

				//
				ResetDirty();
			}

			//Update Phys
			{
		    	const iteration:int = 2;

		    	m_PhysWorld.Step(DeltaTime, iteration);
			}

			//Camera
			{//プレイヤーが画面に収まるようにRootの位置を調整
				var CAMERA_W:int = stage.stageWidth;
				var CAMERA_H:int = stage.stageHeight;

				var trgX:Number = m_Player.x - CAMERA_W/2.0;
				var trgY:Number = m_Player.y - CAMERA_H/2.0;

				var MinX:Number = 0.0;
				var MaxX:Number = W - CAMERA_W;
				var MinY:Number = 0.0;
				var MaxY:Number = H - CAMERA_H;

				if(trgX > MaxX){
					trgX = MaxX;
				}
				if(trgY > MaxY){
					trgY = MaxY;
				}
				if(trgX < MinX){
					trgX = MinX;
				}
				if(trgY < MinY){
					trgY = MinY;
				}

				m_Layer_Root.x = -trgX;
				m_Layer_Root.y = -trgY;
			}
		}

		//地形コリジョン生成
		public function RedrawCollision(in_Rect:Rectangle, in_Pos:Point):void
		{
			//Dirtyな部分（今は全体描画になってる）
			var rect:Rectangle = in_Rect;//m_Bitmap_Terrain.rect;
			var pos:Point = in_Pos;//new Point(0,0);

			const mtx_identity:Matrix = new Matrix();

			//m_BitmapData_Collision
			{
				//Reset
				{//rectより一回り大きい範囲をクリアするだけでよいが、一応全てリセット
					m_BitmapData_Util_0.fillRect(m_BitmapData_Util_0.rect, 0x00000000);
					m_BitmapData_Util_1.fillRect(m_BitmapData_Util_1.rect, 0x00000000);
				}

				//まずは白と黒の境界線が描画されたものを用意する
				{
					//強制的に黒く描画
					const ct_black:ColorTransform = new ColorTransform(0,0,0,1);
					m_BitmapData_Util_0.draw(m_Layer_Terrain, mtx_identity, ct_black, BlendMode.NORMAL, rect);
					m_BitmapData_Util_0.draw(m_Layer_Block_Black, mtx_identity, ct_black, BlendMode.NORMAL, rect);

					//白でブラー
					const blur_white:GlowFilter = new GlowFilter(0xFFFFFF,1.0, 2,2, 255);//幅が１でOKなら１で。
					m_BitmapData_Util_1.applyFilter(m_BitmapData_Util_0, rect, pos, blur_white);
					//ここでブラーの影響がrectの内部に出ないようにしたい
					//影響が出るようなら、「切り出し部分」よりも小さく「貼りつけ部分」を設定すること（このスコープと下のスコープのrectを別にする）

					//ゲート部分を描き足す
					m_BitmapData_Util_1.draw(m_Layer_GateAsBlock, mtx_identity, ct_black, BlendMode.NORMAL, rect);

					//Rの値をAにセット：白は白のまま、黒かった部分は透明に。
					m_BitmapData_Util_0.copyChannel(m_BitmapData_Util_1, rect, pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				}

				//そしてその境界線を膨らませて、実際のコリジョン描画にする
				{
					//横に伸ばす
					const blur_x:GlowFilter = new GlowFilter(0xFFFFFF,1.0, PANEL_LEN*3/5,1, 255);
					m_BitmapData_Util_1.applyFilter(m_BitmapData_Util_0, rect, pos, blur_x);

					//縦に伸ばす
					const blur_y:GlowFilter = new GlowFilter(0xFFFFFF,1.0, 1,PANEL_LEN*3/5, 255);
					m_BitmapData_Util_0.applyFilter(m_BitmapData_Util_1, rect, pos, blur_y);
				}

				//それを実際のコリジョンに移す
				{
					m_BitmapData_Collision.copyPixels(m_BitmapData_Util_0, rect, pos);
				}
			}

			//m_BitmapData_Collision_ForBlackBlock
			if(m_DirtyFlag_ForBlackBlock)
			{
				//Reset
				{//rectより一回り大きい範囲をクリアするだけでよいが、一応全てリセット
					m_BitmapData_Util_0.fillRect(m_BitmapData_Util_0.rect, 0x00000000);
					m_BitmapData_Util_1.fillRect(m_BitmapData_Util_1.rect, 0x00000000);
				}

				//まずは白と黒の境界線が描画されたものを用意する
				{
					//強制的に黒く描画
//					const ct_black:ColorTransform = new ColorTransform(0,0,0,1);
					m_BitmapData_Util_0.draw(m_Layer_Terrain, mtx_identity, ct_black, BlendMode.NORMAL, rect);
					m_BitmapData_Util_0.draw(m_Layer_GateAsBlock, mtx_identity, ct_black, BlendMode.NORMAL, rect);

					//白でブラー
//					const blur_white:GlowFilter = new GlowFilter(0xFFFFFF,1.0, 2,2, 255);//幅が１でOKなら１で。
					m_BitmapData_Util_1.applyFilter(m_BitmapData_Util_0, rect, pos, blur_white);
					//ここでブラーの影響がrectの内部に出ないようにしたい
					//影響が出るようなら、「切り出し部分」よりも小さく「貼りつけ部分」を設定すること（このスコープと下のスコープのrectを別にする）

					//Rの値をAにセット：白は白のまま、黒かった部分は透明に。
					m_BitmapData_Util_0.copyChannel(m_BitmapData_Util_1, rect, pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				}

				//そしてその境界線を膨らませて、実際のコリジョン描画にする
				{
					//横に伸ばす
//					const blur_x:GlowFilter = new GlowFilter(0xFFFFFF,1.0, PANEL_LEN/2-1,1, 255);
					m_BitmapData_Util_1.applyFilter(m_BitmapData_Util_0, rect, pos, blur_x);

					//縦に伸ばす
//					const blur_y:GlowFilter = new GlowFilter(0xFFFFFF,1.0, 1,PANEL_LEN/2-1, 255);
					m_BitmapData_Util_0.applyFilter(m_BitmapData_Util_1, rect, pos, blur_y);
				}

				//それを実際のコリジョンに移す
				{
					m_BitmapData_Collision_ForBlackBlock.copyPixels(m_BitmapData_Util_0, rect, pos);
				}
			}
		}


		//Dirty部分のリセット
		public function ResetDirty():void{
			m_DirtyFlag = false;
			m_DirtyFlag_ForBlackBlock = false;
			m_DirtyFlag_ForWhiteBlock = false;

			m_RedrawRect.x = W;
			m_RedrawRect.width = 0;
			m_RedrawRect.y = H;
			m_RedrawRect.height = 0;

			m_RedrawPoint.x = m_RedrawRect.x;
			m_RedrawPoint.y = m_RedrawRect.y;
		}

		//Dirty部分の追加
		public function AddDirty(in_LX:int, in_RX:int, in_UY:int, in_DY:int, in_IsBlackBlock:Boolean):void{
			//m_DirtyFlag
			{
				m_DirtyFlag = true;

				if(in_IsBlackBlock){
					m_DirtyFlag_ForWhiteBlock;//黒いブロックが動いたら、白いブロック用の地形を再描画
				}else{
					m_DirtyFlag_ForBlackBlock;//上の逆
				}
			}

			//m_RedrawRect
			{
				if(in_LX < m_RedrawRect.left){
					m_RedrawRect.left = in_LX;
				}
				if(m_RedrawRect.right < in_RX){
					m_RedrawRect.right = in_RX;
				}
				if(in_UY < m_RedrawRect.top){
					m_RedrawRect.top = in_UY;
				}
				if(m_RedrawRect.bottom < in_DY){
					m_RedrawRect.bottom = in_DY;
				}
			}

			//m_RedrawPoint
			{
				m_RedrawPoint.x = m_RedrawRect.x;
				m_RedrawPoint.y = m_RedrawRect.y;
			}
		}


		//Collision
		public function IsCollision(i_X:int, i_Y:int):Boolean{
			//範囲外は空間とみなす
			{
				if(i_X < 0){return false;}
				if(i_X >= W){return false;}
				if(i_Y < 0){return false;}
				if(i_Y >= H){return false;}
			}

			//一定以上白ければ壁とみなす
			var color:uint = m_BitmapData_Collision.getPixel32(i_X, i_Y);
			var r:uint = (color >> 16) & 0xFF;
			return r > 0x02;//
		}

		public function IsCollision_ForBlackBlock(i_X:int, i_Y:int):Boolean{
			//範囲外は空間とみなす
			{
				if(i_X < 0){return false;}
				if(i_X >= W){return false;}
				if(i_Y < 0){return false;}
				if(i_Y >= H){return false;}
			}

			//一定以上白ければ壁とみなす
			var color:uint = m_BitmapData_Collision_ForBlackBlock.getPixel32(i_X, i_Y);
			var r:uint = (color >> 16) & 0xFF;
			return r > 0x02;//
		}

		public function IsCollision_ForWhiteBlock(i_X:int, i_Y:int):Boolean{
			//範囲外は空間とみなす
			{
				if(i_X < 0){return false;}
				if(i_X >= W){return false;}
				if(i_Y < 0){return false;}
				if(i_Y >= H){return false;}
			}

			//一定以上白ければ壁とみなす
			var color:uint = m_BitmapData_Collision_ForWhiteBlock.getPixel32(i_X, i_Y);
			var r:uint = (color >> 16) & 0xFF;
			return r > 0x02;//
		}
	}
}


import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.filters.*;
import flash.ui.Keyboard;

import Box2D.Dynamics.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Common.Math.*;


//*
internal class IGameObject extends Sprite{
	//コリジョンを利用しつつ、Bitmapを見た動きをするOBJ

	//==Const==

	//Box2Dに大きい値を入れると上手く機能しないので、小さくするためのスケーリング
	static public const PHYS_SCALE:Number = 10.0;

	static public const DRAG_RATIO_O:Number = 0.7;
	static public const DRAG_RATIO_W:Number = 0.5;


	//==Var==

	public var m_Body:b2Body;

	public var m_AX:Number = 0.0;
	public var m_VY:Number = 0.0;

	public var m_GroundFlag:Boolean = false;

	//Collision
	static public var m_ShapeDef_Black:b2PolygonDef;
	static public var m_ShapeDef_White:b2PolygonDef;

	//#Debug
	public var m_TrgShape:Shape = new Shape();


	//==Function==

	//Init
    public function IGameObject(in_PhysWorld:b2World, in_X:int, in_Y:int, in_IsBlack:Boolean){
    	//Pos
    	{
    		this.x = in_X;
    		this.y = in_Y;
    	}

    	//Phys
    	{
			//m_Body
			{
    			var bodyDef:b2BodyDef;
    			{
    				bodyDef = new b2BodyDef();
					bodyDef.position.Set(in_X / PHYS_SCALE, in_Y / PHYS_SCALE);
    			}

				m_Body = in_PhysWorld.CreateBody(bodyDef);
			}

			//Add Shape
			{
    			//Shape
//				const COL_W:Number = GameMain.PANEL_LEN/2 / PHYS_SCALE;
				const COL_W:Number = GameMain.PANEL_LEN*6/10 / PHYS_SCALE;
				if(m_ShapeDef_Black == null){
					m_ShapeDef_Black = new b2PolygonDef();
					m_ShapeDef_Black.SetAsBox(COL_W, COL_W);
					m_ShapeDef_Black.density = 1.0;
					m_ShapeDef_Black.friction = 0.0;
					//m_ShapeDef_Black.restitution = i_Param.restitution;
					m_ShapeDef_Black.filter.categoryBits = (1 << 0);
					m_ShapeDef_Black.filter.maskBits = (1 << 0);
				}
				if(m_ShapeDef_White == null){
					m_ShapeDef_White = new b2PolygonDef();
					m_ShapeDef_White.SetAsBox(COL_W, COL_W);
					m_ShapeDef_White.density = 1.0;
					m_ShapeDef_White.friction = 0.0;
					//m_ShapeDef_White.restitution = i_Param.restitution;
					m_ShapeDef_White.filter.categoryBits = (1 << 1);
					m_ShapeDef_White.filter.maskBits = (1 << 1);
				}

				if(in_IsBlack){
					m_Body.CreateShape(m_ShapeDef_Black);
				}else{
					m_Body.CreateShape(m_ShapeDef_White);
				}

				m_Body.SetMassFromShapes();
			}
    	}

		//Debug
		{
			var g:Graphics = m_TrgShape.graphics;
			g.lineStyle(5, 0xFFFF00, 1.0);
			g.drawCircle(0, 0, 32);
			//addChild(m_TrgShape);//ここのコメントを外すと、移動方向の可視化
		}

		//Call Update
		{
			addEventListener(Event.ENTER_FRAME, Update);
		}
    }

	//Update
	public function Update(e:Event=null):void{//in_DeltaTime:Number
		var in_DeltaTime:Number = 1.0 / 24.0;

		//範囲外なら移動を諦める
		{
			const Range:int = GameMain.PANEL_LEN*2;
			if(this.x < -Range){return;}
			if(this.x >= GameMain.W + Range){return;}
			if(this.y < -Range){return;}
			if(this.y >= GameMain.H + Range){return;}
		}

		//Phys => Game
		var PhysX:Number;
		var PhysY:Number;
		var PhysVX:Number;
		var PhysVY:Number;
		{
			PhysX = m_Body.GetPosition().x * PHYS_SCALE;
			PhysY = m_Body.GetPosition().y * PHYS_SCALE;

			PhysVX = m_Body.GetLinearVelocity().x * PHYS_SCALE;
			PhysVY = m_Body.GetLinearVelocity().y * PHYS_SCALE;
		}

		//加速＆擬似摩擦補正
		{
			//VX
			{
				//
				PhysVX += m_AX * in_DeltaTime;

				//
				var Rat:Number;
				{
					if(! m_GroundFlag){
						Rat = DRAG_RATIO_O;
					}else{
						Rat = DRAG_RATIO_W;
					}
				}

				//
				PhysVX *= Math.pow(Rat, 10.0*in_DeltaTime);
			}
		}

		//Bitmapを見た移動
		{
			var MoveX:int = PhysX - this.x;
			var MoveY:int = PhysY - this.y;

			//Debug
			{
				m_TrgShape.x = MoveX*5;
				m_TrgShape.y = MoveY*5;
			}

			//移動アルゴリズム実行

			const BaseOffset:int = 1;//浮く量
			var Offset:int;

			var TrgX:int;
			var TrgY:int;

			var i:int;

			//Move : Up
			{
				TrgX = this.x;
				Offset = (MoveY < 0)? BaseOffset-MoveY: BaseOffset;

				for(i = 0; i < Offset; i++){
					TrgY = this.y - 1;
					if(IsCollision(TrgX, TrgY)){
						//天井にぶつかったので速度は０にする
						PhysVY = 0;
						break;
					}
					this.y = TrgY;
				}

				//途中で止まったなら、その分をPhys側にフィードバック
				PhysY += Offset - i;
			}

			//Move : Horz
			{
				TrgX = this.x;
				TrgY = this.y;

				for(i = 0; i != MoveX; ){
					if(i < MoveX){
						i++;
						TrgX++;
					}else{
						i--;
						TrgX--;
					}

					if(IsCollision(TrgX, TrgY)){
						PhysVX = 0;
						//途中で止まったなら、その分をPhys側にフィードバック
						PhysX = this.x;//位置を一致させてしまう
						break;
					}

					this.x = TrgX;
				}
			}

			//Move : Down
			{
				TrgX = this.x;
				Offset = (MoveY > 0)? BaseOffset+MoveY: BaseOffset;

				m_GroundFlag = false;
				for(i = 0; i < Offset; i++){
					TrgY = this.y + 1;
					if(IsCollision(TrgX, TrgY)){
						//接地したとみなす
						m_GroundFlag = true;//ジャンプできるようにフラグオン
						PhysVY = 0;//速度リセット
						break;
					}
					this.y = TrgY;
				}

				//途中で止まったなら、その分をPhys側にフィードバック
				PhysY -= Offset - i;
			}
		}

		//Game => Phys
		{
			//VY
			{
				if(m_VY < 0.0){
					PhysVY = m_VY;

					m_VY = 0.0;
				}
			}

			m_Body.SetXForm(new b2Vec2(PhysX / PHYS_SCALE, PhysY / PHYS_SCALE), m_Body.GetAngle());
			m_Body.GetLinearVelocity().x = PhysVX / PHYS_SCALE;
			m_Body.GetLinearVelocity().y = PhysVY / PHYS_SCALE;
		}
	}

	public function IsCollision(in_X:int, in_Y:int):Boolean{
		return GameMain.Instance().IsCollision(in_X, in_Y);
	}
}
//*/


//*
internal class Player extends IGameObject{

	//==Cost==

	//#Input
	static public var button_enum:int = 0;
	static public const BUTTON_L:int = button_enum++;
	static public const BUTTON_R:int = button_enum++;
	static public const BUTTON_U:int = button_enum++;
	static public const BUTTON_NUM:int = button_enum;

	//#Move
	static public const MOVE_POW_AIR:Number    = 470.0;
	static public const MOVE_POW_GROUND:Number = 1100.0;
	static public const JUMP_VEL:Number = 300.0;

	//==Var==

	//#StartPos
	public var m_StartPosX:int = 0;
	public var m_StartPosY:int = 0;

	//#Graphic
	public var m_Root:Sprite = new Sprite();

	//#Input
	public var m_Input:Array = new Array(BUTTON_NUM);

	//
	public var m_IsInBlack_Old:Boolean = false;

	//==Function==

	//#Init
	public function Player(in_PhysWorld:b2World, in_X:int, in_Y:int){
		//Super
		{
			var IsBlack:Boolean = true;
			super(in_PhysWorld, in_X, in_Y, IsBlack);
		}

		//Pos
		{
			this.x = m_StartPosX = in_X;
			this.y = m_StartPosY = in_Y;
		}

		//Init Later (for Using "stage" etc.)
		addEventListener(Event.ADDED_TO_STAGE, Init);
	}

	public function Init(e:Event = null):void{
		var i:int;

		//Init Once Only
		{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
		}

		//Layer
		{
			addChild(m_Root);
		}

		//Create Graphic
		{
			const Rad:int = GameMain.PANEL_LEN/4;

			var shape:Shape;
			var g:Graphics;

			//黒
			{
				shape = new Shape();
				g = shape.graphics;

				g.lineStyle(0, 0x000000, 0.0);
				g.beginFill(0x222222, 1.0);
				g.drawCircle(0, 0, Rad);
				g.endFill();

				m_Root.addChild(shape);
			}

			//白
			{
				shape = new Shape();
				g = shape.graphics;

				g.lineStyle(0, 0x000000, 0.0);
				g.beginFill(0xDDDDDD, 1.0);
				g.drawCircle(0, 0, Rad);
				g.endFill();

				m_Root.addChild(shape);

				shape.mask = GameMain.Instance().m_ShapeMask_ForPlayer;//地形が黒いところでしか白プレイヤーは表示されない
			}
		}

		//Input
		{
			//Init
			for(i = 0; i < BUTTON_NUM; i++){
				m_Input[i] = false;
			}

			//Listener
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp);
		}
	}

	//#Input
	static public const KEY_R:int = 82;
	public function KeyDown(e:KeyboardEvent):void{
		switch(e.keyCode){
		case Keyboard.LEFT:		m_Input[BUTTON_L] = true;		break;
		case Keyboard.RIGHT:	m_Input[BUTTON_R] = true;		break;
		case Keyboard.UP:		m_Input[BUTTON_U] = true;		break;

		case KEY_R://位置のリセット
			this.x = m_StartPosX;
			this.y = m_StartPosY;
			break;
		}
	}

	public function KeyUp(e:KeyboardEvent):void{
		switch(e.keyCode){
		case Keyboard.LEFT:		m_Input[BUTTON_L] = false;		break;
		case Keyboard.RIGHT:	m_Input[BUTTON_R] = false;		break;
		case Keyboard.UP:		m_Input[BUTTON_U] = false;		break;
		}
	}

	//#Update
	override public function Update(e:Event=null):void{
		//入力
		{
			//m_AX
			{
				var PowX:Number;
				{
					if(! m_GroundFlag){
						PowX = MOVE_POW_AIR;
					}else{
						PowX = MOVE_POW_GROUND;
					}
				}

				m_AX = 0.0;
				if(m_Input[BUTTON_R]){
					m_AX =  PowX;
				}
				if(m_Input[BUTTON_L]){
					m_AX = -PowX;
				}
			}

			//m_VY
			{
				if(m_GroundFlag && m_Input[BUTTON_U]){
					m_VY = -JUMP_VEL;
				}
			}
		}

		//移動
		{
			super.Update();
		}

		//白黒が反転したら、コリジョンも反転する
		{
			var IsInBlack:Boolean = IsInBlack();
//*
			if(m_IsInBlack_Old != IsInBlack){//bool同士の比較は気が引けるが
				if(IsInBlack){
					//Delete Old
					m_Body.DestroyShape(m_Body.m_shapeList);
					//Create New
					m_Body.CreateShape(m_ShapeDef_White);
				}else{
					//Delete Old
					m_Body.DestroyShape(m_Body.m_shapeList);
					//Create New
					m_Body.CreateShape(m_ShapeDef_Black);
				}

				m_IsInBlack_Old = IsInBlack;
			}
//*/
/*
			//Debug
			if(IsInBlack){
				scaleX = 3;
			}else{
				scaleX = 1;
			}
//*/
		}
	}

	//Utility
	static public var BitmapData_ForHitTest:BitmapData;
	static public var mtx:Matrix = new Matrix();
	public function IsInBlack():Boolean{
		//今の自分の中心位置が、白く描画されていれば黒エリアの中にいると判断する

		if(BitmapData_ForHitTest == null){
//*
			BitmapData_ForHitTest = new BitmapData(1,1,true,0x00000000);
/*/
			//Debug
			BitmapData_ForHitTest = new BitmapData(32,32,true,0x88888888);
			GameMain.Instance().addChild(new Bitmap(BitmapData_ForHitTest));//test
//*/
		}

		//自分を描画して
		mtx.tx = -this.x;
		mtx.ty = -this.y;
		BitmapData_ForHitTest.draw(GameMain.Instance().m_Layer_Player, mtx);

		//白ならTrue
		return ((BitmapData_ForHitTest.getPixel32(0,0) & 0xFF) > 0xFF/2);
	}
}
//*/

//*
internal class MovableBlock extends IGameObject{
	//==Var==

	public var m_IsBlack:Boolean = true;

	//Mask For Player
	public var m_MaskForPlayer:Shape = new Shape();


	//==Function==

	public function MovableBlock(in_PhysWorld:b2World, in_X:int, in_Y:int){
		//Super
		{
			super(in_PhysWorld, in_X, in_Y, m_IsBlack);
		}

		const BlockW:int = GameMain.PANEL_LEN;//*3/2;//+2;
		const BlockH:int = GameMain.PANEL_LEN*3/2;//*3/2;//+2;
		const OffsetY:int = -GameMain.PANEL_LEN/8;

		//Graphic
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			{
				g.lineStyle(2, 0x444444, 1.0);
//				g.lineStyle(0, 0x000000, 0.0);
				g.beginFill(0x000000, 1.0);
				g.drawRect(-BlockW/2, -BlockH/2+OffsetY, BlockW, BlockH);
				g.endFill();
			}

			addChild(shape);
		}

		//Mask For Player
		{
			g = m_MaskForPlayer.graphics;
			if(m_IsBlack)
			{
				g.lineStyle(2, 0x444444, 1.0);
				g.beginFill(0x000000, 1.0);
				g.drawRect(-BlockW/2, -BlockH/2+OffsetY, BlockW, BlockH);
				g.endFill();
			}

			GameMain.Instance().m_ShapeMask_ForPlayer.addChild(m_MaskForPlayer);
		}
	}

	//#Update
	override public function Update(e:Event=null):void{
		var OldX:int = this.x;
		var OldY:int = this.y;

		//移動
		{
			super.Update();
		}

		//Dirty
		{
			var NewX:int = this.x;
			var NewY:int = this.y;

			if(OldX != NewX || OldY != NewY){//移動していたら
				//自分の周辺のコリジョンを再描画
				var lx:int, rx:int, uy:int, dy:int;
				{
					const Range:int = GameMain.PANEL_LEN;
					if(OldX < NewX){
						lx = OldX - Range;
						rx = NewX + Range;
					}else{
						lx = NewX - Range;
						rx = OldX + Range;
					}

					if(OldY < NewY){
						uy = OldY - Range;
						dy = NewY + Range;
					}else{
						uy = NewY - Range;
						dy = OldY + Range;
					}
				}

				GameMain.Instance().AddDirty(lx, rx, uy, dy, m_IsBlack);
			}
		}

		//Mask For Player
		{
			m_MaskForPlayer.x = this.x;
			m_MaskForPlayer.y = this.y;
		}
	}

	override public function IsCollision(in_X:int, in_Y:int):Boolean{
		if(m_IsBlack){
			return GameMain.Instance().IsCollision_ForBlackBlock(in_X, in_Y);
		}else{
			return GameMain.Instance().IsCollision_ForWhiteBlock(in_X, in_Y);
		}
	}
}
//*/

//*
internal class Goal extends Sprite{
	public function Goal(in_X:int, in_Y:int){
		//Pos
		{
			this.x = in_X;
			this.y = in_Y;
		}

		//Graphic
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.lineStyle(2, 0xFFFF00, 1.0);
			g.drawCircle(0, 0, GameMain.PANEL_LEN/2);

			shape.filters = [new GlowFilter(0xFF0000, 1.0)];

			addChild(shape);
		}

		//Call "Update"
		{
			addEventListener(Event.ENTER_FRAME, Update);
		}
	}


	//#Update
	public function Update(e:Event=null):void{
		var GapX:int = GameMain.Instance().m_Player.x - this.x;
		var GapY:int = GameMain.Instance().m_Player.y - this.y;
		if(Math.sqrt(GapX*GapX+GapY*GapY) < GameMain.PANEL_LEN){
			//プレイヤーがゴールに接触した
			//じゃあ、なんかゴールを表示しとこう
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.lineStyle(8, 0xFFFF00, 1.0);
			g.drawCircle(0,0, 100);
			shape.filters = [new GlowFilter(0xFF0000, 1.0)];
			addChild(shape);

			//こいつの処理も外す
			removeEventListener(Event.ENTER_FRAME, Update);
			//本体も外しとこう
			GameMain.Instance().removeEventListener(Event.ENTER_FRAME, GameMain.Instance().Update);
			//プレイヤーも（ｒｙ
			GameMain.Instance().m_Player.removeEventListener(Event.ENTER_FRAME, GameMain.Instance().m_Player.Update);
		}
	}
}
//*/




