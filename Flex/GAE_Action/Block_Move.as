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

	public class Block_Move extends IGameObject{
		//==Const==

		//==Var==

		//移動開始地点
		public var m_SrcX:int = 0;
		public var m_SrcY:int = 0;

		//タイマ
		public var m_Timer:Number = 0.0;

		//==Common==

		//Reset
		override public function Reset(i_X:int, i_Y:int):void{
			//Type
			{
				SetBlockType(Game.M);
			}

			//Pos
			{
				SetPos(i_X, i_Y);
				m_SrcX = i_X;
				m_SrcY = i_Y;
			}

			//Timer
			{
				m_Timer = 0.0;
			}

			//Graphic Anim
			{
				if(numChildren <= 0){//まだ生成してなかったら
					addChild(ImageManager.LoadBlockImage(Game.M));
				}
			}

			//Collision
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 0.0;
					ColParam.friction = 0.2;//0.1;
					ColParam.allow_sleep = false;

					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				if(! m_Body)//まだ生成してなかったら（位置とかは上のSetPosでセットされるはず）
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_BLOCK);
					SetHitCategory(ColParam, CATEGORY_PLAYER | CATEGORY_TERRAIN | CATEGORY_BLOCK | CATEGORY_ENEMY);

					const w:int = ImageManager.PANEL_LEN;//-2;
					CreateCollision_Box(w, w, ColParam);
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//!!
			m_Dir = DIR_R;

			//移動周期
			var CYCLE:Number;
			{
				if(m_Val > 0){
					CYCLE = 1.0 + 0.5 * m_Val;
				}else{
					CYCLE = 99.9;//tekitou
				}
			}

			//Timer
			{
				m_Timer += i_DeltaTime;
				if(m_Timer >= CYCLE){
					m_Timer -= CYCLE;
				}
			}

			//Pos
			{
				var Ratio:Number = 0.5 - 0.5 * MyMath.Cos(m_Timer/CYCLE * 2*MyMath.PI);

				var TrgX:int;
				var TrgY:int;
				{
					TrgX = m_SrcX;
					TrgY = m_SrcY;

					switch(m_Dir){
					case DIR_L:
						TrgX -= m_Val * ImageManager.PANEL_LEN * Ratio;
						break;
					case DIR_R:
						TrgX += m_Val * ImageManager.PANEL_LEN * Ratio;
						break;
					case DIR_U:
						TrgY -= m_Val * ImageManager.PANEL_LEN * Ratio;
						break;
					case DIR_D:
						TrgY += m_Val * ImageManager.PANEL_LEN * Ratio;
						break;
					}
				}

				SetPos(TrgX, TrgY);
			}

			//Vel
			{
				//自分には反映されないが、接触してる奴の動作に影響するので速度も計算＆設定しておく
//				var Vel:Number = m_Val * ImageManager.PANEL_LEN * 0.9*MyMath.Sin(m_Timer/CYCLE * 2*MyMath.PI);
//				var Vel:Number = m_Val * ImageManager.PANEL_LEN * 0.9*MyMath.Sin(m_Timer/CYCLE * 2*MyMath.PI + 0.03 * 2*MyMath.PI);
				var VX:Number = m_Val * ImageManager.PANEL_LEN * 2.0*MyMath.Sin(m_Timer/CYCLE * 2*MyMath.PI + 0.14 * 2*MyMath.PI);//左右移動はこれでOK
				var VY:Number = m_Val * ImageManager.PANEL_LEN * 0.7*MyMath.Sin(m_Timer/CYCLE * 2*MyMath.PI + 0.01 * 2*MyMath.PI);//上下移動はこれでOK
				var VX_Player:Number = m_Val * ImageManager.PANEL_LEN * 0.95*MyMath.Sin(m_Timer/CYCLE * 2*MyMath.PI + 0.04 * 2*MyMath.PI);//プレイヤーの左右移動はこれでOK（５マス指定の場合のみ）

				switch(m_Dir){
				case DIR_L:
					SetVX(-VX);
					m_VX = -VX_Player;//プレイヤーにはこちらを参照してもらう
					break;
				case DIR_R:
					SetVX( VX);
					m_VX =  VX_Player;//プレイヤーにはこちらを参照してもらう
					break;
				case DIR_U:
					SetVY(-VY);
					break;
				case DIR_D:
					SetVY( VY);
					break;
				}
			}
		}

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			//こいつ自身はStaticなコリジョンなので、接触したままだとSleepして良いと勘違いされるため、毎回起こす
			if(in_Obj.m_Body){
				in_Obj.m_Body.WakeUp();
			}
		}
	}
}

