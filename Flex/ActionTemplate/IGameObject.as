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

	public class IGameObject extends Image{

		//------------------
		//Var
		//------------------

		//==GameObject==

		//GameObjectListを形成するためのポインタ
		public var m_NextObj:IGameObject;
		public var m_PrevObj:IGameObject;

		//リストから外れるためのフラグ
		public var m_KillFlag:Boolean = false;



		//------------------
		//Function
		//------------------


		//==GameObject==

		public function IGameObject(){
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
		}

		//削除するトリガーとして呼ぶ
		public function Kill():void{
			m_KillFlag = true;//実際の削除はあとで
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

		//Pos
		protected function SetPos(i_X:Number, i_Y:Number):void{
			this.x = i_X;
			this.y = i_Y;
		}


		public function OnContact_Common(i_Trg:IGameObject, i_X:Number, i_Y:Number):void{
		}
		public function OnContact(i_Trg:IGameObject, i_X:Number, i_Y:Number):void{
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

