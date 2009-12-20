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
//		static public const MOVE_VEL:Number = 100.0;
		static public const MOVE_POW_AIR:Number    = 470.0;//空中での制御はやややりにくくする
		static public const MOVE_POW_GROUND:Number = 1100.0;
		static public const JUMP_VEL:Number = 300.0;
		static public const GRAVITY:Number = 600.0;

		//#空気抵抗、地面との摩擦
		static public const DRAG_RATIO_O:Number = 0.7;//空中での摩擦は少なくする（あまり減らさないようにする）
		static public const DRAG_RATIO_W:Number = 0.5;


		//==Var==

		//#Pos
		public var m_VX:Number = 0.0;
		public var m_VY:Number = 0.0;
		public var m_AX:Number = 0.0;
		public var m_AY:Number = GRAVITY;

		//#Input
		public var m_Input:IInput;

		//#Flag
		public var m_GroundFlag:Boolean = false;

		//==Common==

		public function Init(i_X:int, i_Y:int, i_Input:IInput):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Input
			{
				m_Input = i_Input;
			}

			//Graphic Anim
			{
				ResetGraphic(ImageManager.LoadCharaImage("Player", 1));
				SetGraphicDir(GRAPHIC_DIR_R);
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
		}

		//#Pos
		public function UpdatePosition(i_DeltaTime:Number):void{
			var i:int;

			//Param
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
						m_AX =  PowX
					}
					if(m_Input.IsPress(IInput.BUTTON_L)){
						m_AX = -PowX
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
					m_VY += m_AY * i_DeltaTime;

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


			//Move
			{
				var move:int;

				//U
				{
					//Val
					{
						move = 1;
						if(m_VY < 0){move -= m_VY * i_DeltaTime;}
					}

					//Move
					{
						for(i = 0; i < move; i += 1){
							if(Game.Instance().IsCollision(this.x, this.y-1)){
								//天井にぶつかった

								//縦の速度をリセットする
								m_VY = 0;

								break;
							}

							this.y -= 1;
						}
					}
				}

				//R
				{
					//Val
					{
						move = 1;
						if(m_VX > 0){move += m_VX * i_DeltaTime;}
					}

					//Move
					{
						for(i = 0; i < move; i += 1){
							if(Game.Instance().IsCollision(this.x+1, this.y)){
								//壁にぶつかった

								//横の速度をリセットする
								if(m_VX > 0){
									m_VX = 0;
								}

								break;
							}

							this.x += 1;
						}
					}
				}

				//L
				{
					//Val
					{
						move = 2;
						if(m_VX < 0){move -= m_VX * i_DeltaTime;}
					}

					//Move
					{
						for(i = 0; i < move; i += 1){
							if(Game.Instance().IsCollision(this.x-1, this.y)){
								//壁にぶつかった

								//横の速度をリセットする
								if(m_VX < 0){
									m_VX = 0;
								}

								break;
							}

							this.x -= 1;
						}
					}
				}

				//R
				{
					//Val
					{
						move = 1;
					}

					//Move
					{
						for(i = 0; i < move; i += 1){
							if(Game.Instance().IsCollision(this.x+1, this.y)){break;}

							this.x += 1;
						}
					}
				}

				//D
				{
					m_GroundFlag = false;

					//Val
					{
						move = 2;
						if(m_VY > 0){move += m_VY * i_DeltaTime;}
					}

					//Move
					{
						for(i = 0; i < move; i += 1){
							if(Game.Instance().IsCollision(this.x, this.y+1)){
								//接地した

								//壁づたいにジャンプすると、アルゴリズムの関係上、上昇中でも接地するので、下降中のみに制限
								if(m_VY >= 0){
									//接地フラグを立てる
									m_GroundFlag = true;

									//縦の速度をリセットする
									m_VY = 0;
								}

								break;
							}

							this.y += 1;
						}
					}
				}
			}
		}
	}
}

