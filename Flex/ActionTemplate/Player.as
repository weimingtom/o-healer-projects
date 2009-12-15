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

		//#Pos
		static public const MOVE_VEL:Number = 100.0;
		static public const JUMP_VEL:Number = 300.0;

		//==Var==

		//#Pos
		public var m_VX:Number = 0.0;
		public var m_VY:Number = 0.0;
		public var m_G:Number = 600.0;

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
				//m_VX
				{
					var vx:Number = 0.0;
					if(m_Input.IsPress(IInput.BUTTON_R)){
						vx += MOVE_VEL;
					}
					if(m_Input.IsPress(IInput.BUTTON_L)){
						vx -= MOVE_VEL;
					}

					m_VX = vx;
				}

				//m_VY
				{
					m_VY += m_G * i_DeltaTime;

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
							if(Game.Instance().IsCollision(this.x+1, this.y)){break;}

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
							if(Game.Instance().IsCollision(this.x-1, this.y)){break;}

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

