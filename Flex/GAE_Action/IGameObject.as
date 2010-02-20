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

	public class IGameObject extends Image{

		//==GameObject==

		//GameObjectListを形成するためのポインタ
		public var m_NextObj:IGameObject;
		public var m_PrevObj:IGameObject;

		//リストから外れるためのフラグ
		public var m_KillFlag:Boolean = false;


		//Init
		public function IGameObject(){
		}

		//Reset:オーバライドして使う
		public function Reset(i_X:int, i_Y:int):void{
		}

		//Update:共通処理
		public function Update_Common(i_DeltaTime:Number):void{
			CheckPressDead(i_DeltaTime);
		}

		//Update:オーバライドして使う
		public function Update(i_DeltaTime:Number):void{
		}

		//削除される時に呼ばれる処理:オーバライドして使う
		public function OnDestroy():void{
			//remove Graphic
			if(this.parent){
				this.parent.removeChild(this);
			}
			//remove collision
			if(m_Body != null){
				PhysManager.DestroyBody(m_Body);
			}
		}

		//削除するトリガーとして呼ぶ
		public function Kill():void{
			m_KillFlag = true;//実際の削除はあとで
		}


		//==Set==

		//セットに対応するIndex
		public var m_BlockType:int = -1;

		public function SetBlockType(in_BlockType:int):void{//Game.Oとかを指定する
			m_BlockType = in_BlockType;
		}

		//セット時に指定される値
		public var m_Val:int = 0;

		public function SetVal(in_Val:int):void{
			m_Val = in_Val;
		}

		//セット時に指定される方向
		static public const DIR_U:int = 0;//default
		static public const DIR_D:int = 1;
		static public const DIR_L:int = 2;
		static public const DIR_R:int = 3;

		public var m_Dir:int = DIR_U;

		public function SetDir(in_Dir:int):void{
			m_Dir = in_Dir;
		}


		//==Graphic==

		static public const GRAPHIC_DIR_U:int = 0;
		static public const GRAPHIC_DIR_R:int = 1;
		static public const GRAPHIC_DIR_D:int = 2;
		static public const GRAPHIC_DIR_L:int = 3;

		static  public const ANIM_PATTERN:Array = [0, 1, 2, 1];

		protected var m_AnimGraphicImage:Image
		protected var m_AnimGraphicList:Array;
		protected var m_AnimGraphicDir:int = GRAPHIC_DIR_R;
		protected var m_AnimGraphicIter:int = 0;
		protected var m_AnimGraphicTimer:Number = 0.0;
		protected var m_AnimGraphicInterval:Number = 0.1;

		//RPGツクール系の画像の登録
		public function ResetGraphic(i_AnimGraphicList:Array):void{
			m_AnimGraphicList = i_AnimGraphicList;

			RefreshAnimation();
		}

		//
		public function SetGraphicDir(i_Dir:int):void{
			m_AnimGraphicDir = i_Dir;

			RefreshAnimation();
		}

		//画像のアニメーション
		public function UpdateAnimation(i_DeltaTime:Number):void{
			m_AnimGraphicTimer += i_DeltaTime;

			if(m_AnimGraphicTimer >= m_AnimGraphicInterval){
				//m_AnimGraphicTimer
				{
					m_AnimGraphicTimer -= m_AnimGraphicInterval;
				}

				//m_AnimGraphicIter
				{
					m_AnimGraphicIter += 1;
					if(m_AnimGraphicIter >= 4){
						m_AnimGraphicIter = 0;
					}
				}

				RefreshAnimation();
			}
		}

		//
		public function RefreshAnimation():void{
			//Remove
			if(m_AnimGraphicImage){removeChild(m_AnimGraphicImage);}

			//Create
			m_AnimGraphicImage = m_AnimGraphicList[m_AnimGraphicDir][ANIM_PATTERN[m_AnimGraphicIter]];

			//Entry
			addChild(m_AnimGraphicImage);
		}


		//==Coordinate==

		public var m_VX:Number = 0;
		public var m_VY:Number = 0;

		//Flag
		public var m_GroundFlag:Boolean = false;


		//Pos
		protected function SetPos(i_X:Number, i_Y:Number):void{
			this.x = i_X;
			this.y = i_Y;

			if(m_Body){
				m_Body.SetXForm(
					new b2Vec2(this.x / PhysManager.PHYS_SCALE, this.y / PhysManager.PHYS_SCALE),
					0//m_Body.GetAngle()
				);
			}
		}


		//Vel
		//VX
		public function SetVX(i_VX:Number):void{
			if(m_Body){
				var PhysVel:b2Vec2 = m_Body.GetLinearVelocity();
				PhysVel.x = i_VX / PhysManager.PHYS_SCALE;
				m_Body.SetLinearVelocity(PhysVel);
			}
		}
		public function GetVX():Number{
			if(m_Body){
				return m_Body.GetLinearVelocity().x * PhysManager.PHYS_SCALE;
			}else{
				return m_VX;
			}
		}
		//VY
		public function SetVY(i_VY:Number):void{
			if(m_Body){
				var PhysVel:b2Vec2 = m_Body.GetLinearVelocity();
				PhysVel.y = i_VY / PhysManager.PHYS_SCALE;
				m_Body.SetLinearVelocity(PhysVel);
			}
		}
		public function GetVY():Number{
			if(m_Body){
				return m_Body.GetLinearVelocity().y * PhysManager.PHYS_SCALE;
			}else{
				return m_VY;
			}
		}


		//==Collision==

		//Collision Category
		public static const CATEGORY_PLAYER:uint 			= 0x0001;//通常のプレイヤーコリジョン
		public static const CATEGORY_PLAYER_VS_TERRAIN:uint	= 0x0002;//地形衝突専用のプレイヤーコリジョン
		public static const CATEGORY_TERRAIN:uint 			= 0x0004;//通常の地形コリジョン
		public static const CATEGORY_TERRAIN_VS_PLAYER:uint	= 0x0008;//プレイヤー衝突専用の地形コリジョン
		public static const CATEGORY_BLOCK:uint				= 0x0010;//ブロックコリジョン
		public static const CATEGORY_ENEMY:uint				= 0x0020;//エネミーコリジョン

		//Collision Body
		public var m_BodyDef:b2BodyDef;
		public var m_Body:b2Body;

		//Create : Base
		public function CreateBody(i_Param:Object):void{
			//コリジョン（の形状）をくっつけるためのBodyの生成
			//自分で呼んでも良いけど、基本的には以下のCreateCollision～で自動的に呼ばれるので気にしなくて良い

			//Check
			{
				//すでに作ってあるなら何もしない
				if(m_Body){return;}
			}

			//Body
			m_BodyDef = new b2BodyDef();
			{
				m_BodyDef.userData = this;//m_Graphic;//物理エンジンに合わせて座標などを更新するために登録
				m_BodyDef.position.Set(this.x / PhysManager.PHYS_SCALE, this.y / PhysManager.PHYS_SCALE);

				m_BodyDef.fixedRotation = i_Param.fix_rotation;

				if(i_Param.start_sleep){
					m_BodyDef.isSleeping = true;
				}else{
					m_BodyDef.allowSleep = i_Param.allow_sleep;
				}
			}

			//Create:Base
			{
				m_Body = PhysManager.CreateBody(m_BodyDef);//コリジョンの実際の生成
			}
		}

		//Create:Circle
		public function CreateCollision_Circle(i_Rad:int, i_Param:Object):void{
			//Create : Base
			{
				CreateBody(i_Param);
			}

			//Add Shape
			{
				var shapeDef:b2CircleDef = new b2CircleDef();
				shapeDef.radius = i_Rad / PhysManager.PHYS_SCALE;
				shapeDef.density = i_Param.density;
				shapeDef.friction = i_Param.friction;
//				shapeDef.restitution = i_Param.restitution;
				shapeDef.filter.categoryBits = i_Param.category_bits;
				shapeDef.filter.maskBits = i_Param.mask_bits;

				m_Body.CreateShape(shapeDef);
				if(i_Param.density > 0){
					m_Body.SetMassFromShapes();
				}
			}
		}

		//Create:Box
		public function CreateCollision_Box(i_W:int, i_H:int, i_Param:Object):void{
			//Create : Base
			{
				CreateBody(i_Param);
			}

			//Add Shape
			{
				var shapeDef:b2PolygonDef = new b2PolygonDef();
				shapeDef.SetAsBox(i_W/2 / PhysManager.PHYS_SCALE, i_H/2 / PhysManager.PHYS_SCALE);
				shapeDef.density = i_Param.density;
				shapeDef.friction = i_Param.friction;
//				shapeDef.restitution = i_Param.restitution;
				shapeDef.filter.categoryBits = i_Param.category_bits;
				shapeDef.filter.maskBits = i_Param.mask_bits;

				m_Body.CreateShape(shapeDef);
				if(i_Param.density > 0){
					m_Body.SetMassFromShapes();
				}
			}
		}

		//Param : Get Default
		public function GetDefaultCollisionParam():Object{
			var param:Object = {};
			{
				param.density = 1.0;
				param.friction = 1.0;
				param.category_bits = 0x01;
				param.mask_bits = 0xFFFF;
				param.start_sleep = false;
				param.allow_sleep = false;
				param.fix_rotation = false;
			}

			return param;
		}

		//Param : Category
		public function SetOwnCategory(o_Param:Object, i_Category:uint):void{
			//セットするパラメータと、自分のカテゴリーを引数にする
			o_Param.category_bits = i_Category;
		}
		public function SetHitCategory(o_Param:Object, i_CategoryOr:uint):void{
			//セットするパラメータと、ヒットする相手のカテゴリーを引数にする
			//カテゴリーは「|」でつなぐことが可能
			o_Param.mask_bits = i_CategoryOr;
		}

		//Contact:Common
		public function OnContact_Common(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			//コリジョンに接触したら必ず呼ばれる

			var Vel:b2Vec2 = m_Body.GetLinearVelocity();

			//コリジョンの接地判定
			{//将来的に「横方向にぶつかってる」などの判定が必要になるかもしれないので、Ground以外にも用意しておく
				//L
				{
					if(in_Nrm.x < -0.7){
						if(Vel.x <= 0){
						}
					}
				}

				//R
				{
					if(in_Nrm.x >  0.7){
						if(Vel.x >= 0){
						}
					}
				}

				//U
				{
					if(in_Nrm.y < -0.7){
						if(Vel.y <= 0){
						}
					}
				}

				//D
				{
					if(in_Nrm.y >  0.7){
//						if(Vel.y >= 0)//これだけだと、「一緒に落下しているとき」や「めりこんで上昇してるとき」が入らないので、もっと良い判定が望まれる
						{
							//接地フラグを立てる
							m_GroundFlag = true;
						}
					}
				}
			}

			//圧死判定
			{
				var PressFlag:Boolean = true;
				{
					//!!in_Objがドア（逆ドア）で、非表示の場合は考慮しないようにしたい（αチェックで擬似的にオンオフの判断はできるが）
					switch(in_Obj.m_BlockType){
					case Game.P:
					case Game.E:
						//キャラクターによる圧力では圧死しない
						PressFlag = false;
						break;
					case Game.D:
					case Game.R:
						//オンオフする壁なら、オンの時しか圧死しない
						{
							var block_door:Block_Door = in_Obj as Block_Door;
							if(! block_door.m_IsOn){
								PressFlag = false;
							}
						}
						break;
					}
				}

				if(PressFlag){
					//
					var Vel3D:Vector3D = new Vector3D(Vel.x, Vel.y);

					if(Vel3D.dotProduct(in_Nrm) <= 0.01){//自ら隙間にはまったときは圧死しないよう、速度チェックをする
						AddPressPowList(in_Nrm);
					}
				}
			}
		}

		//Contact:
		public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			//こっちはオーバーライドして各自で使う
		}


		//==圧死判定==

		//圧死判定を行うか
		public var m_CheckPressFlag:Boolean = false;

		//接触方向のリスト
		public var m_PressPowList:Array = [];

		//圧力方向を一つ加える
		public function AddPressPowList(in_Nrm:Vector3D):void{
			//新しく加えられた力と、今までに加えられた力が反対方向であれば、挟み込まれていると判断する

			//Check
			{
				if(! m_CheckPressFlag){//圧死判定は行わない
					return;
				}
			}

			//圧死チェック
			{
				var size:int = m_PressPowList.length;
				for(var i:int = 0; i < size; i += 1){
					if(m_PressPowList[i].dotProduct(in_Nrm) < -0.99){//ほぼ反対側の力なら（どちらも長さは１と仮定）
						OnPressDead(in_Nrm);
						return;
					}
				}
			}

			//次回判定用に追加
			m_PressPowList.push(in_Nrm);
		}


		//圧死判定
		public function CheckPressDead(in_DeltaTime:Number):void{
			//Check
			{
				if(! m_CheckPressFlag){//圧死判定は行わない
					return;
				}
			}

			//Reset
			{
				m_PressPowList = [];//clear

//				m_PressedFlag = false;
			}
		}

		//圧死時の処理：オーバーライドして使う
		public function OnPressDead(in_Nrm:Vector3D):void{
		}

/*
		//Sync:Obj=>Physics
		//こっちは使わないので封印
		public function Obj2Phys():void{
			//コリジョンの位置を実際の位置として採用する

			//Check
			{
				if(m_Body == null){
					return;
				}
			}

			//Pos
			{
				m_Body.SetXForm(
					new b2Vec2(this.x / PhysManager.PHYS_SCALE, this.y / PhysManager.PHYS_SCALE),
					m_Body.GetAngle()
				);
			}
		}
//*/
		//Sync:Physics=>Obj
		public function Phys2Obj():void{
			//コリジョンの位置を実際の位置として採用する

			//Check
			{
				if(m_Body == null){
					return;
				}
			}

			//Pos
			{
				this.x = m_Body.GetPosition().x * PhysManager.PHYS_SCALE;
				this.y = m_Body.GetPosition().y * PhysManager.PHYS_SCALE;
			}

			//Rot
			{
				this.rotation = m_Body.GetAngle() * 360/(2*MyMath.PI);
			}
		}


		//==Damage==

		public var m_HP:int = 1;

		public function AddDamage(in_Damage:int):void{
			//Check
			{
				if(m_HP <= 0){//すでに死んでるorアンデッドなら処理を行わない
					return;
				}
			}

			//Exec
			{
				m_HP -= in_Damage;
			}

			//Check
			{
				if(m_HP <= 0){
					OnDamageDead();
				}
			}
		}

		//ダメージ死亡時の処理：オーバーライドして使う
		public function OnDamageDead():void{
		}


		//==ShareFlag==
		//オブジェクト同士で共有するフラグ（スイッチ（フラグ１オン）→ゲート（フラグ１がオンならオープン）みたいな）

		public function SetShareFlags(i_Flags:uint, i_IsOn:Boolean):void{
			GameObjectManager.SetShareFlags(i_Flags, i_IsOn);
		}

		public function IsShareFlagsOn(i_Flags:uint):Boolean{
			return GameObjectManager.IsShareFlagsOn(i_Flags);
		}

	}
}

