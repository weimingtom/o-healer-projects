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

	public class Player extends IGameObject{
		//==Const==

		/*
			＃X方向の慣性制御

			VX = 110に収束するように、POWとRATIOを決定する
			・地上は完全に110、空中はそれより少し小さい値に収束

			例えばDeltaTime=0.1(秒)とすると、
			VX += POW * 0.1
			VX *= RATIO
			という式になり、POW=100、RATIO=0.5ならVX=5に収束する、という感じ
		*/

		//#Pos
		static public const MOVE_POW_AIR:Number    = 470.0;//空中での制御はやややりにくくする
		static public const MOVE_POW_GROUND:Number = 1100.0;
		static public const JUMP_VEL:Number = 300.0;
//		static public const GRAVITY:Number = 600.0;

		//#空気抵抗、地面との摩擦
		static public const DRAG_RATIO_O:Number = 0.7;//空中での摩擦は少なくする（あまり減らさないようにする）
		static public const DRAG_RATIO_W:Number = 0.5;//地面の摩擦も物理エンジンには任せない（壁に触れたままジャンプして摩擦が起こっても困るため）

		//#Collision
		static public const COL_RAD:int = 4;


		//==Var==

		//#Pos
		public var m_AX:Number = 0.0;
//		public var m_AY:Number = GRAVITY;

		//#Input
		public var m_Input:IInput;


		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Flag
			{
				m_CheckPressFlag = true;
			}

			//Scale
			{
				scaleX = 1.0;
				scaleY = 1.0;
			}

			//Graphic Anim
			{
				if(! m_AnimGraphicList){//まだ生成していなければ
					ResetGraphic(ImageManager.LoadCharaImage("Player"));
				}
				SetGraphicDir(GRAPHIC_DIR_R);
			}

			//Collision
			if(! m_Body)//まだ生成していなければ
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 9.0;//大きめにしてみるテスト
					ColParam.friction = 0.0;//1.0;//摩擦は独自計算
				}

				//Normal
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_PLAYER);
					SetHitCategory(ColParam, CATEGORY_BLOCK);

					CreateCollision_Circle(ImageManager.CHARA_GRAPHIC_LEN_X/2-1, ColParam);
				}

				//Vs Terrain
				{//地形衝突用
					SetOwnCategory(ColParam, CATEGORY_PLAYER_VS_TERRAIN);
					SetHitCategory(ColParam, CATEGORY_TERRAIN_VS_PLAYER);

					CreateCollision_Circle(COL_RAD, ColParam);
				}
			}
		}

		public function SetInput(i_Input:IInput):void{
			//Input
			{
				m_Input = i_Input;
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//Graphic Anim
			{
				if(m_Input.IsPress(IInput.BUTTON_R)){
					SetGraphicDir(GRAPHIC_DIR_R);
				}
				if(m_Input.IsPress(IInput.BUTTON_L)){
					SetGraphicDir(GRAPHIC_DIR_L);
				}

				UpdateAnimation(i_DeltaTime);
			}

			//Pos
			{
				UpdatePosition(i_DeltaTime);
			}

			//Check : Dead
			{
				CheckDead();
			}
		}

		//#Pos
		public function UpdatePosition(i_DeltaTime:Number):void{
			//Check
			{
				if(m_Body == null){
					return;
				}
			}

			//PhysVel => GameVel
			var PhysVel:b2Vec2 = m_Body.GetLinearVelocity();
			{
				m_VX = PhysVel.x * PhysManager.PHYS_SCALE;
				m_VY = PhysVel.y * PhysManager.PHYS_SCALE;
			}

			//Paramの計算
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
					if(m_Input.IsPress(IInput.BUTTON_R)){
						m_AX =  PowX;
					}
					if(m_Input.IsPress(IInput.BUTTON_L)){
						m_AX = -PowX;
					}
				}

				//m_VX
				{
					//Powによる加算
					m_VX += m_AX * i_DeltaTime;

					//空気抵抗率
					var Rat:Number;
					{
						if(! m_GroundFlag){
							Rat = DRAG_RATIO_O;
						}else{
							Rat = DRAG_RATIO_W;
						}
					}

					//空気抵抗などによる減速(擬似抵抗)
					m_VX *= MyMath.Pow(Rat, 10.0*i_DeltaTime);
				}

				//m_VY
				{
//					m_VY += m_AY * i_DeltaTime;//重力計算は物理エンジン任せ

					//下降速度に制限を設けてみる
					if(m_VY > JUMP_VEL){
						m_VY = JUMP_VEL;//ジャンプ速度と同じにしてみる
					}

					if(m_GroundFlag){//接地中はジャンプ可能
						if(m_Input.IsPress_Edge(IInput.BUTTON_U)){
							m_VY = -JUMP_VEL;
						}
					}
				}
			}

			//GameVel => PhysVel
			{
				PhysVel.x = m_VX / PhysManager.PHYS_SCALE;
				PhysVel.y = m_VY / PhysManager.PHYS_SCALE;

				m_Body.SetLinearVelocity(PhysVel);
			}

			//Param Reset
			{
				m_GroundFlag = false;
			}
		}

		//#Check : Dead
		public function CheckDead():void{
			//落下死
			if(this.y > Game.Instance().GetStageH() + ImageManager.PANEL_LEN/2){
				Game.Instance().OnGameOver(Game.GAME_OVER_FALL);
			}
		}

		//圧死時の処理：オーバーライドして使う
		override public function OnPressDead(in_Nrm:Vector3D):void{
			//画象を圧縮してみる
			{
				scaleX = 0.5 + 0.5 * MyMath.Abs(in_Nrm.y);
				scaleY = 0.5 + 0.5 * MyMath.Abs(in_Nrm.x);

				//圧縮した分下に移動させてみる（Reset時に座標もリセットされると仮定）
				m_AnimGraphicImage.y += 0.5*ImageManager.PANEL_LEN * (1 - scaleY);
			}

			Game.Instance().OnGameOver(Game.GAME_OVER_PRESS);
		}
	}
}

