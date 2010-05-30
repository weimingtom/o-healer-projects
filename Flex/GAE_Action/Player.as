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

		//#Type
		static public var TYPE_COUNTER:int = 0;//enum代わり
		static public const TYPE_NORMAL:int			= TYPE_COUNTER++;
		static public const TYPE_BLOCK_SUMMONER:int	= TYPE_COUNTER++;
		static public const TYPE_REVERSER:int		= TYPE_COUNTER++;
		static public const TYPE_NUM:int			= TYPE_COUNTER;

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

		//#Type
//		public var m_PlayerType:int = TYPE_NORMAL;//m_Valを使う

		//#Pos
		public var m_AX:Number = 0.0;
//		public var m_AY:Number = GRAVITY;
		public var m_BaseVX:Number = 0.0;

		//#Input
		public var m_Input:IInput;

		//#Mouse
		public var m_MouseSrcX:int=0;
		public var m_MouseSrcY:int=0;
		public var m_MouseDstX:int=0;
		public var m_MouseDstY:int=0;
		public var m_MouseDownFlag:Boolean = false;

		//#Draw
		public var m_DrawShape:Shape = new Shape();

		//=BlockSummoner
		//常に一つだけ生成するため、現在生成されているブロックを保持しておく
		public var m_SwitchBlock:Block_Movable;


		//==Common==

		//#Reset
		override public function Reset(i_X:int, i_Y:int):void{
			var InitFlag:Boolean = (m_Body != null);//すでに初期化はされているか

			//Type
			{
				SetBlockType(Game.P);
			}

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
			if(! InitFlag)//まだ生成していなければ
			{
				var ColParam:Object = GetDefaultCollisionParam();
				{//デフォルトのパラメータ
					ColParam.density = 9.0;//大きめにしてみるテスト
					ColParam.friction = 0.0;//1.0;//摩擦は独自計算
					ColParam.fix_rotation = true;//回転しないようにする（細い通路に落とすときにひっかからないように）
				}

				//Normal
				{//通常用コリジョン
					SetOwnCategory(ColParam, CATEGORY_PLAYER);
					SetHitCategory(ColParam, CATEGORY_BLOCK | CATEGORY_ENEMY);

					CreateCollision_Circle(ImageManager.CHARA_GRAPHIC_LEN_X/2-1, ColParam);
				}

				//Vs Terrain
				{//地形衝突用
					SetOwnCategory(ColParam, CATEGORY_PLAYER_VS_TERRAIN);
					SetHitCategory(ColParam, CATEGORY_TERRAIN_VS_PLAYER);

					CreateCollision_Circle(COL_RAD, ColParam);
				}
			}

			//マウスのイベント
			if(! InitFlag)
			{
				//Down
				Game.Instance().addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);//ステージ上のクリックのみ検出
				//Move
				Game.Instance().stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);//どこに移動しようとも
				//Up
				Game.Instance().stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);//どこでクリックを解除しようとも
			}

			//m_DrawShape
			if(! InitFlag)
			{
				Game.Instance().m_Root_Gimmick.addChild(m_DrawShape);
			}

			//m_SwitchBlock
			//生成したブロックもリセット
			if(m_SwitchBlock){
				m_SwitchBlock.visible = false;//ManagerのUpdateを回さないとKillでは消えないので、表示をオフにしておく
				m_SwitchBlock.Kill();
				m_SwitchBlock = null;
			}

			//画面のズームをいじっている可能性があるのでリセット
			{
				Game.Instance().m_Root_Zoom.scaleY = 1;

				scaleY = 1;

				PhysManager.Instance.SetGravity(PhysManager.GRAVITY);
			}

			//デストラクタ
			if(! InitFlag)
			{
				addEventListener(Event.REMOVED_FROM_STAGE, Destruct);
			}
		}

		//Destroy
		public function Destruct(e:Event):void{
			//Mouse
			{
				//Down
				Game.Instance().removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);//ステージ上のクリックのみ検出
				//Move
				Game.Instance().stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);//どこに移動しようとも
				//Up
				Game.Instance().stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);//どこでクリックを解除しようとも
			}
		}


		//#Input
		public function SetInput(i_Input:IInput):void{
			//Input
			{
				m_Input = i_Input;
			}
		}


		//#Mouse

		public function OnMouseDown(e:MouseEvent):void{
			//ステージでのマウス位置
			var MouseX:int = Game.Instance().m_Root_Gimmick.mouseX;
			var MouseY:int = Game.Instance().m_Root_Gimmick.mouseY;

			switch(m_Val){
			case TYPE_BLOCK_SUMMONER:
				if(! Game.Instance().IsWall(MouseX/ImageManager.PANEL_LEN, MouseY/ImageManager.PANEL_LEN)){//開始位置はブロックが無いとこじゃないとダメ
					//クリック位置を始点とする（ついでに現時点での終点ともする）
					m_MouseSrcX = MouseX;
					m_MouseSrcY = MouseY;
					m_MouseDstX = MouseX;
					m_MouseDstY = MouseY;

					//「マウスでの指定を開始したフラグ」をオン
					m_MouseDownFlag = true;

					//とりあえず現在のブロックサイズを描画してみる
					RedrawBlockGraphic();
				}
				break;
			}
		}

		public function OnMouseMove(e:MouseEvent):void{
			//ステージでのマウス位置
			var MouseX:int = Game.Instance().m_Root_Gimmick.mouseX;
			var MouseY:int = Game.Instance().m_Root_Gimmick.mouseY;

			switch(m_Val){
			case TYPE_BLOCK_SUMMONER:
				if(m_MouseDownFlag){
/*
					if(! IsWallContain(m_MouseSrcX, m_MouseSrcY, MouseX, MouseY)){
						//現在の終点を更新
						m_MouseDstX = MouseX;
						m_MouseDstY = MouseY;

						//現在のブロック候補表示の更新
						RedrawBlockGraphic();
					}
/*/
					for(var i:int = 0; i < 10; i++){
						if(! IsWallContain(m_MouseSrcX, m_MouseSrcY, MouseX, MouseY)){
							//現在の終点を更新
							m_MouseDstX = MouseX;
							m_MouseDstY = MouseY;

							//現在のブロック候補表示の更新
							RedrawBlockGraphic();

							break;
						}else{
							//目標位置を、最後の位置との中間にしてリトライしてみる
							MouseX = (m_MouseDstX + MouseX) / 2;
							MouseY = (m_MouseDstY + MouseY) / 2;
						}
					}
//*/
				}
				break;
			}
		}

		public function OnMouseUp(e:MouseEvent):void{
			//ステージでのマウス位置
			var MouseX:int = Game.Instance().m_Root_Gimmick.mouseX;
			var MouseY:int = Game.Instance().m_Root_Gimmick.mouseY;

			switch(m_Val){
			case TYPE_BLOCK_SUMMONER:
				if(m_MouseDownFlag){
					if(! IsWallContain(m_MouseSrcX, m_MouseSrcY, MouseX, MouseY)){
						//最終的な終点を更新
						m_MouseDstX = MouseX;
						m_MouseDstY = MouseY;
					}

					//前回のブロックはこの時点で削除
					if(m_SwitchBlock){
						m_SwitchBlock.Kill();
					}

					//今回のブロック生成
					{
						var BlockX:int = (m_MouseSrcX + m_MouseDstX) / 2;
						var BlockY:int = (m_MouseSrcY + m_MouseDstY) / 2;
						var BlockW:int = (m_MouseSrcX < m_MouseDstX)? m_MouseDstX-m_MouseSrcX: m_MouseSrcX-m_MouseDstX;
						var BlockH:int = (m_MouseSrcY < m_MouseDstY)? m_MouseDstY-m_MouseSrcY: m_MouseSrcY-m_MouseDstY;

						if(BlockW > 0 && BlockH > 0){
							m_SwitchBlock = new Block_Movable();

							m_SwitchBlock.SetVal(0);
							m_SwitchBlock.Reset_Inner(BlockX, BlockY, BlockW, BlockH);

							Game.Instance().m_Root_Gimmick.addChild(m_SwitchBlock);
							GameObjectManager.Register(m_SwitchBlock);
						}
					}

					//今までの候補表示をクリア
					ClearBlockGraphic();

					//マウス操作が終了したのでフラグオフ
					m_MouseDownFlag = false;
				}
				break;
			}
		}


		//#Utility
		public function IsWallContain(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int):Boolean
		{
			var SrcX:int = in_SrcX/ImageManager.PANEL_LEN;
			var SrcY:int = in_SrcY/ImageManager.PANEL_LEN;
			var DstX:int = in_DstX/ImageManager.PANEL_LEN;
			var DstY:int = in_DstY/ImageManager.PANEL_LEN;

			for(var iter_x:int = SrcX; ; ){
				for(var iter_y:int = SrcY; ; ){
					if(Game.Instance().IsWall(iter_x, iter_y)){
						return true;//範囲内のどこかにブロックがあった
					}
					if(iter_y < DstY){iter_y += 1; continue;}
					if(iter_y > DstY){iter_y -= 1; continue;}
					break;
				}

				if(iter_x < DstX){iter_x += 1; continue;}
				if(iter_x > DstX){iter_x -= 1; continue;}
				break;
			}

			return false;//範囲内のどこにもブロックがなかった
		}

		//#Draw
		public function RedrawBlockGraphic():void
		{
			var g:Graphics = m_DrawShape.graphics;

			//Clear
			{
				g.clear();
			}

			//Setting
			{
				const line_w:int = 3;
				const line_color:uint = 0xFF8800;
				const line_alpha:Number = 1.0;

				g.lineStyle(line_w, line_color, line_alpha);
			}

			//Draw
			{
				g.drawRect(m_MouseSrcX, m_MouseSrcY, m_MouseDstX - m_MouseSrcX, m_MouseDstY - m_MouseSrcY);
			}
		}

		public function ClearBlockGraphic():void
		{
			var g:Graphics = m_DrawShape.graphics;

			//Clear
			{
				g.clear();
			}
		}


		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			//Check Input
			{
				UpdateByInput();
			}

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

		//#Action
		public function UpdateByInput():void{
			//固有アクションの開始
			if(m_Input.IsPress_Edge(IInput.BUTTON_ACTION)){
				switch(m_Val){
				case TYPE_NORMAL:
					//こいつは何もしない
					break;
				case TYPE_BLOCK_SUMMONER:
					//こいつはマウスで行うので、ここは特に何もなし
					break;
				case TYPE_REVERSER:
					//ステージを反転させる
					Player_Reverser.Action();//下のローカルクラスで処理を実際に書く
					break;
				}
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
				m_VX = PhysVel.x * PhysManager.PHYS_SCALE - m_BaseVX;
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

					//重力の反転の考慮
					if(PhysManager.Instance.IsGravityReversed()){
						m_VY = -m_VY;//ここで一度反転して、処理を通常のものと一致させる
					}

					//下降速度に制限を設けてみる
					if(m_VY > JUMP_VEL){
						m_VY = JUMP_VEL;//ジャンプ速度と同じにしてみる
					}

					if(m_GroundFlag){//接地中はジャンプ可能
						if(m_Input.IsPress_Edge(IInput.BUTTON_U)){
							m_VY = -JUMP_VEL;
						}
					}

					//重力の反転の考慮
					if(PhysManager.Instance.IsGravityReversed()){
						m_VY = -m_VY;//もとに戻すための反転
					}
				}
			}

			//GameVel => PhysVel
			{
				PhysVel.x = (m_BaseVX + m_VX) / PhysManager.PHYS_SCALE;
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

		//Contact:接触したときに呼ばれる
		override public function OnContact(in_Obj:IGameObject, in_Nrm:Vector3D):void{
			//地面の速度の影響を受けてみる
			if(in_Nrm.y >  0.7){
				if(in_Obj.m_BlockType != Game.M){
					//通常
					m_BaseVX = in_Obj.GetVX();
				}else{
					//往復ブロック時は専用のものを参照
					m_BaseVX = in_Obj.m_VX;
				}
			}
		}

		//ダメージ死亡時の処理：オーバーライドして使う
		override public function OnDamageDead():void{
			Game.Instance().OnGameOver(Game.GAME_OVER_DAMAGE);
		}
	}
}


class Player_Reverser
{
	//==Const==
	//反転にかかる時間
	static public const REVERSE_TIME:Number = 1.0;

	//==Var==
	//反転状態か否か
	static public var m_ReversedFlag:Boolean = false;//完全に反転したときにフラグが変更される

	//==Func==
	//反転させる
	static public function Action():void{
		//Game本体のUpdateを、ステージ反転用Updateに差し替える

		//終了時に戻すため、現在のUpdate関数を記憶
		var oldUpdateFunc:Function = Game.Instance().m_UpdateFunc;

		//すぐさま重力反転
		if(m_ReversedFlag){
			//反転状態→元の重力
			PhysManager.Instance.SetGravity(PhysManager.GRAVITY);
		}else{
			//通常状態→逆重力
			PhysManager.Instance.SetGravity(-PhysManager.GRAVITY);
		}

		//ローカルタイマー
		var timer:Number = 0.0;

		//Updateを新しくセット
		Game.Instance().m_UpdateFunc = function():void{
			var deltaTime:Number = Game.Instance().GetDeltaTime();

			//timer
			{
				timer += deltaTime;
				if(timer > REVERSE_TIME){
					timer = REVERSE_TIME;
				}
			}

			//Scale
			{
				var ratio:Number = timer / REVERSE_TIME;

				//Y方向にスケーリング
				var stageScaleY:Number = 1 - 2*ratio;
				if(m_ReversedFlag){
					stageScaleY = -stageScaleY;
				}
				Game.Instance().m_Root_Zoom.scaleY = stageScaleY;

				//それに合わせて位置も修正
				var posY:Number = Game.CAMERA_H * ratio;
				if(m_ReversedFlag){
					posY = Game.CAMERA_H - posY;
				}
				Game.Instance().m_Root_Zoom.y = posY;
			}

			//プレイヤーだけは上下反転はしない
			{
				var playerScaleY:Number = 1;

				//初期状態が反転か否かで反転
				if(m_ReversedFlag){
					playerScaleY = -playerScaleY;
				}

				//反転処理が半分を過ぎたら相殺のため反転
				if(timer >= REVERSE_TIME/2){
					playerScaleY = -playerScaleY;
				}

				Game.Instance().m_Player.scaleY = playerScaleY;
			}

			//終了
			if(timer >= REVERSE_TIME){
				//フラグ反転
				m_ReversedFlag = !m_ReversedFlag;

				//Update関数を元に戻す
				Game.Instance().m_UpdateFunc = oldUpdateFunc;
			}
		}
	}
}

