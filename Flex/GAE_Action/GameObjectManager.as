//author Show=O=Healer
package{
	public class GameObjectManager{

		//リストの先頭
		static public var m_ObjectList:IGameObject;

		//Box2Dとほぼ同様にObjectを管理する
		//-Add
		static public function Register(i_Obj:IGameObject):void{
			if(m_ObjectList != null){
				m_ObjectList.m_PrevObj = i_Obj;
			}
			i_Obj.m_NextObj = m_ObjectList;

			m_ObjectList = i_Obj;
		}
		//-Del
		static public function Remove(i_Obj:IGameObject):void{
			if(i_Obj.m_PrevObj != null){
				i_Obj.m_PrevObj.m_NextObj = i_Obj.m_NextObj;
			}
			if(i_Obj.m_NextObj != null){
				i_Obj.m_NextObj.m_PrevObj = i_Obj.m_PrevObj;
			}
			if(i_Obj == m_ObjectList){
				m_ObjectList = i_Obj.m_NextObj;
			}
		}

		//#Reset
		static public function Reset():void{
			var obj:IGameObject = m_ObjectList;

			while(obj){
				var temp:IGameObject = obj.m_NextObj;

				{
					obj.m_NextObj = null;
					obj.m_PrevObj = null;
					obj.OnDestroy();
				}

				obj = temp;
			}

			m_ObjectList = null;
		}

		//#Update
		static public function Update(i_DeltaTime:Number):void{
			//各OBJの更新
			Update_EachObj(i_DeltaTime);

			//Killが呼ばれたものは削除する
			Update_KillCheck();
		}

		//Update : EachObj
		static public function Update_EachObj(i_DeltaTime:Number):void{
			var obj:IGameObject;

			//各GameObjectのUpdate
			obj = m_ObjectList;
			while(obj){
				obj.Update_Common(i_DeltaTime);

				obj.Update(i_DeltaTime);

				obj = obj.m_NextObj;
			}
		}

		//Update : KillCheck
		static public function Update_KillCheck():void{
			var obj:IGameObject;

			obj = m_ObjectList;
			while(obj){
				if(obj.m_KillFlag){
					obj.OnDestroy();
					var remove_obj:IGameObject = obj;
					obj = obj.m_NextObj;
					Remove(remove_obj);
				}else{
					obj = obj.m_NextObj;
				}
			}
		}

		//#Physics更新後のUpdate
		static public function Update_AfterPhys(i_DeltaTime:Number):void{
			//各OBJの更新
			Update_AfterPhys_EachObj(i_DeltaTime);

			//Killが呼ばれたものは削除する
			Update_KillCheck();
		}

		//Update_AfterPhys : EachObj
		static public function Update_AfterPhys_EachObj(i_DeltaTime:Number):void{
			var obj:IGameObject;

			//各GameObjectのUpdate
			obj = m_ObjectList;
			while(obj){
				obj.Update_AfterPhys_Common(i_DeltaTime);

				obj.Update_AfterPhys(i_DeltaTime);

				obj = obj.m_NextObj;
			}
		}

		//==ShareFlag==

		//#Member
		static public const FLAG_NUM:uint = 16;
		static public var m_Flags:Array = new Array(FLAG_NUM);

		//#Func
		static public function SetShareFlags(i_Flags:uint, i_IsOn:Boolean):void{
			for(var i:uint = 0; i < FLAG_NUM; i+=1){
				if((i_Flags & (1 << i)) != 0){
					m_Flags[i] = i_IsOn;
				}
			}
		}
		static public function IsShareFlagsOn(i_Flags:uint):Boolean{
			var Result:Boolean = false;
			{//ひとまず、一つでもtrueならtrueを返しておく
				for(var i:uint = 0; i < FLAG_NUM; i+=1){
					if((i_Flags & (1 << i)) != 0){
						if(m_Flags[i]){
							Result = true;
						}
					}
				}
			}
			return Result;
		}


		//==Search==

		//指定位置に居るOBJを探して返す
		static public function SearchObj(in_X:int, in_Y:int):Object{
			var obj:IGameObject;

			//各GameObjectのUpdate
			obj = m_ObjectList;
			while(obj){
				var info:Object = obj.SearchObj(in_X, in_Y);

				if(info != null){
					return info;
				}

				obj = obj.m_NextObj;
			}

			return null;
		}
	}
}

