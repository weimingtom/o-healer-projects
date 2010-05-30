//author Show=O=Healer

package{
	import flash.events.Event;
	import flash.display.*;
	import flash.text.TextField;
	import flash.utils.*;
	import flash.net.SharedObject;
	import flash.geom.*;
	//mxml
	import mx.core.*;
	import mx.controls.*;
	import mx.containers.*;
	//Box2D
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import General.*;


	public class PhysManager{
		//=Phys=
		public var m_World:b2World;

		//=Param=
		static public const PHYS_SCALE:Number = 10;
		static public const GRAVITY:Number = 60.0;

		static public const RANGE_LX:Number = -99999.0;//Main.RANGE_LX - 30.0;
		static public const RANGE_RX:Number =  99999.0;//Main.RANGE_RX + 30.0;
		static public const RANGE_UY:Number = -99999.0;//Main.RANGE_UY - 30.0;
		static public const RANGE_DY:Number =  99999.0;//Main.RANGE_DY + 30.0;


		//=Singleton=
		private static var __Instance:PhysManager;

		public static function get Instance():PhysManager
		{
			if(__Instance == null){
				__Instance = new PhysManager();
			}

			return __Instance;
		}


		//=Init Physics=
		public function PhysManager(){
			{//Common
				//AABB
				var worldAABB:b2AABB = new b2AABB();
				worldAABB.lowerBound.Set(RANGE_LX/PHYS_SCALE, RANGE_UY/PHYS_SCALE);
				worldAABB.upperBound.Set(RANGE_RX/PHYS_SCALE, RANGE_DY/PHYS_SCALE);
				//Gravity
				var g:b2Vec2 = new b2Vec2(0.0, GRAVITY);
				//Sleep
				var useSleep:Boolean = true;
				//World
				m_World = new b2World(worldAABB, g, useSleep);
			}
		}


		//=Static Function=

		//コリジョンを実際に作成する
		static public function CreateBody(in_BodyDef:b2BodyDef):b2Body{
			return Instance.m_World.CreateBody(in_BodyDef);
		}

		//コリジョンを削除する
		static public function DestroyBody(in_Body:b2Body):void{
			Instance.m_World.DestroyBody(in_Body);
		}

		//毎フレーム呼んでもらう
		static public function Update(in_DeltaTime:Number):void{
			var bb:b2Body;
/*
			//GameObject→Physsicsへの位置の反映
			{
				for (bb = Instance.m_World.m_bodyList; bb; bb = bb.m_next) {
					if(bb.m_userData != null){
						bb.m_userData.Obj2Phys();
					}
				}
			}
//*/
			//物理計算
			{
				const iteration:int = 50;//あまり「動くコリジョン」は使わないので、贅沢にたくさん処理して良いことにする（ちゃんとしたコリジョン排斥のため）
				Instance.m_World.Step(in_DeltaTime, iteration);
			}

			//ぶつかっているものを見つけて、対応関数を呼ぶ
			for(var iter:b2Contact = Instance.m_World.m_contactList; iter != null; iter = iter.GetNext()){
				if(iter.GetManifoldCount() == 0){
					continue;
				}

				var Obj1:IGameObject = iter.GetShape1().m_body.m_userData as IGameObject;
				var Obj2:IGameObject = iter.GetShape2().m_body.m_userData as IGameObject;

				var Nrm_Phys:b2Vec2 = iter.GetManifolds()[0].normal;
				var Nrm:Vector3D = new Vector3D(Nrm_Phys.x, Nrm_Phys.y);
				var Nrm_Neg:Vector3D = new Vector3D(-Nrm_Phys.x, -Nrm_Phys.y);
				Nrm.normalize();
				Nrm_Neg.normalize();

				Obj1.OnContact_Common(Obj2, Nrm);
				Obj2.OnContact_Common(Obj1, Nrm_Neg);

				Obj1.OnContact(Obj2, Nrm);
				Obj2.OnContact(Obj1, Nrm_Neg);
			}

			//Physics→GameObjectへの位置の反映
			{
				for (bb = Instance.m_World.m_bodyList; bb; bb = bb.m_next) {
					if(bb.m_userData != null){
						bb.m_userData.Phys2Obj();
					}
				}
			}
		}


		//全てのオブジェクトを消す
		static public function Reset():void{
//			Instance.m_World.CleanBodyList();
			//!!リセットして大丈夫かを確認

/*
			//デバッグ表示を使うときは、ここのコメントアウトを元に戻す
			{
				// デバッグオブジェクト
				var debug:b2DebugDraw = new b2DebugDraw();
				
				debug.m_sprite			= Game.Instance().m_Root_Gimmick;//this;
				debug.m_drawScale		= PHYS_SCALE;
				debug.m_fillAlpha		= 0.3;
				debug.m_lineThickness	= 1.0;
				debug.m_drawFlags		= b2DebugDraw.e_shapeBit;
				
				// デバッグ描画
				Instance.m_World.SetDebugDraw(debug);
			}
//*/
		}


		//重力
		public function IsGravityReversed():Boolean{
			return (m_World.m_gravity.y < 0);
		}
		public function SetGravity(in_Gravity:Number):void{
			m_World.m_gravity.y = in_Gravity;

			//反転してもSleepしてるやつが落下しないので、全員叩き起こす
			for (var bb:b2Body = m_World.m_bodyList; bb; bb = bb.m_next) {
				bb.WakeUp();
			}
		}
	}
}
