//author Show=O=Healer
package{
	public class SwitchCounter{
		//==Get==

		static public function Get(in_Index:int):SwitchCounter{
			//作られていない分を補充
			while(m_SwitchCounterList.length <= in_Index){m_SwitchCounterList.push(new SwitchCounter());}

			//Indexに相当するものを返す
			return m_SwitchCounterList[in_Index];
		}

		static public function Reset():void{
			var Size:int = m_SwitchCounterList.length;

			for(var i:int = 0; i < Size; i += 1){
				m_SwitchCounterList[i].m_Count = 0;
			}
		}

		//==Common==

		//Check
		public function IsOn():Boolean{return m_Count > 0;}

		//++,-=
		public function Inc():void{m_Count++;}
		public function Dec():void{m_Count--;}


		//==Var==

		static private var m_SwitchCounterList:Array = [];

		private var m_Count:int = 0;
	}
}

