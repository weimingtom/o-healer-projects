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

	public class Effect_Bomb extends IGameObject{
//*
		//==Const==

		//爆発の大きさ
		static public const RAD_MIN:int = 32;
		static public const RAD_MAX:int = 48;

		static public const SMOKE_RAD:int = 48;

		//線の数（円を何等分するか）
		static public const LINE_NUM:int = 12;

		//爆発の時間
		static public const TIME_FIRE:Number = 0.2;
		static public const TIME_SMOKE:Number = 0.2;

		//==Var==

		//Effect
		public var m_Shape_Fire:Shape = new Shape();
		public var m_Shape_Smoke:Shape = new Shape();

		//Timer
		public var m_Timer:Number = 0.0;

		//==Common==

		//Create
		static public function Create(i_X:int, i_Y:int):void{
			var effect:Effect_Bomb = new Effect_Bomb();
			effect.Reset(i_X, i_Y);
			Game.Instance().m_Root_Gimmick.addChild(effect);
			GameObjectManager.Register(effect);
		}

		//Init
		override public function Reset(i_X:int, i_Y:int):void{
			var g:Graphics;

			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Effect : Smoke
			{
				//Register
				{
					addChild(m_Shape_Smoke);
				}

				{//Draw
					g = m_Shape_Smoke.graphics;

					g.clear();
					g.lineStyle(1, 0x000000, 1.0);

					//Center
					{
						g.beginFill(0x000000, 1.0);
						g.drawCircle(0, 0, SMOKE_RAD);
						g.endFill();
					}
				}

				{//Filter
					const blur:Number = 10.0;
					m_Shape_Smoke.filters = [new BlurFilter(blur, blur)];
				}

				{//Alpha
					m_Shape_Smoke.alpha = 0;
				}

//				{//Scale
//					m_Shape_Smoke.scaleX = 0;
//					m_Shape_Smoke.scaleY = 0;
//				}
			}

			//Effect : Fire
			{
				//Register
				{
					addChild(m_Shape_Fire);
				}

				{//Draw
					g = m_Shape_Fire.graphics;

					g.clear();
					g.lineStyle(3, 0xFFDDAA, 1.0);

					//Center
					{
						g.beginFill(0xFFEECC, 1.0);
						g.drawCircle(0, 0, 0.8*RAD_MIN);
						g.endFill();
					}

					//Line
					for(var i:int = 0; i < LINE_NUM; i++){
						var ang:Number;
						{
							var ang_base:Number = 2*MyMath.PI * i/LINE_NUM;
							var ang_offset:Number = 2*MyMath.PI/LINE_NUM * (MyMath.Random()-0.5);

							ang = ang_base + ang_offset;
						}

						var len:Number;
						{
							len = MyMath.Lerp(RAD_MIN, RAD_MAX, MyMath.Random());
						}

						//g.moveTo(0, 0);
						//g.lineTo(len*MyMath.Cos(ang), len*MyMath.Sin(ang));
						const c_rad:Number = 3.0;
						g.moveTo(c_rad*MyMath.Cos(ang-MyMath.PI/2), c_rad*MyMath.Sin(ang-MyMath.PI/2));
						g.lineTo(len*MyMath.Cos(ang), len*MyMath.Sin(ang));
						g.lineTo(c_rad*MyMath.Cos(ang+MyMath.PI/2), c_rad*MyMath.Sin(ang+MyMath.PI/2));
					}
				}

				{//Filter
					m_Shape_Fire.filters = [new BlurFilter(), new GlowFilter(0xFF2200)];
				}

				{//Add Draw
					m_Shape_Fire.blendMode = BlendMode.ADD;
				}

				{//Scale
					m_Shape_Fire.scaleX = 0;
					m_Shape_Fire.scaleY = 0;
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			var ratio:Number;

			//m_Timer
			{
				m_Timer += i_DeltaTime;
			}

			//Check
			{
				if(m_Timer >= TIME_FIRE+TIME_SMOKE){
					Kill();
					return;
				}
			}

			//Anim : Fire
			{
				ratio = MyMath.Clamp(m_Timer / TIME_FIRE, 0.0, 1.0);

				//alpha
				m_Shape_Fire.alpha = MyMath.Sin(0.5*MyMath.PI * (1 - ratio));

				//scale
				m_Shape_Fire.scaleX = m_Shape_Fire.scaleY = ratio;
			}

			//Anim : Smoke
			{
				if(m_Timer < TIME_FIRE){
					ratio = MyMath.Clamp(m_Timer / TIME_FIRE, 0.0, 1.0);
				}else{
					ratio = MyMath.Clamp(1 - (m_Timer-TIME_FIRE) / TIME_SMOKE, 0.0, 1.0);
				}

				//alpha
//				m_Shape_Smoke.alpha = 0.5 - 0.5*MyMath.Cos(MyMath.PI * ratio);

				//scale
//				m_Shape_Smoke.scaleX = m_Shape_Smoke.scaleY = MyMath.Sin(0.5*MyMath.PI * m_Timer / (TIME_FIRE + TIME_SMOKE));
			}
		}
//*/

/*
		//==Const==

		//爆発の大きさ
		static public const RAD:int = 24;

		//爆発の時間
		static public const TIME:Number = 0.15;

		//==Var==

		//Effect
		public var m_Shape_Fire:Shape = new Shape();

		//Timer
		public var m_Timer:Number = 0.0;

		//==Common==

		//Create
		static public function Create(i_X:int, i_Y:int):void{
			var effect:Effect_Bomb = new Effect_Bomb();
			effect.Reset(i_X, i_Y);
			Game.Instance().m_Root_Gimmick.addChild(effect);
			GameObjectManager.Register(effect);
		}

		//Init
		override public function Reset(i_X:int, i_Y:int):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic
			{//グラフィックは本体側でまとめて管理する
				//Register
				{
					addChild(m_Shape_Fire);
				}

				{//Draw
					var g:Graphics = m_Shape_Fire.graphics;

					g.clear();
					g.lineStyle(8, 0xFFBB00, 1.0);
					g.drawCircle(0, 0, RAD);
				}

				{//Filter
					m_Shape_Fire.filters = [new BlurFilter(), new GlowFilter(0xFF2200)];
				}

				{//Scale
					m_Shape_Fire.scaleX = 0;
					m_Shape_Fire.scaleY = 0;
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//m_Timer
			{
				m_Timer += i_DeltaTime;
			}

			//Check
			{
				if(m_Timer >= TIME){
					Kill();
					return;
				}
			}

			//Scale Anim
			{
				var ratio:Number = m_Timer / TIME;

				//alpha
				m_Shape_Fire.alpha = MyMath.Sin(0.5*MyMath.PI * (1 - ratio));

				//scale
				m_Shape_Fire.scaleX = m_Shape_Fire.scaleY = MyMath.Sin(0.5*MyMath.PI * ratio);
			}
		}
//*/
	}
}

