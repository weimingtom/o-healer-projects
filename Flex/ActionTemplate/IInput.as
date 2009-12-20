//author Show=O=Healer
package{
	public class IInput{

		//i_Buttonとして指定するもの(enum欲しい)
		//Player
		static public const BUTTON_L:int = 0;
		static public const BUTTON_R:int = 1;
		static public const BUTTON_U:int = 2;
		static public const BUTTON_D:int = 3;
		//System
		static public const BUTTON_RESET:int = 4;
		//Num
		static public const BUTTON_NUM:int  = 5;


		//i_Buttonが現在押されているか
		public function IsPress(i_Button:int):Boolean{
			//継承されてなければ、常にfalseを返す
			return false;
		}

		//i_Buttonが押されたか（エッジ）
		public function IsPress_Edge(i_Button:int):Boolean{
			//継承されてなければ、常にfalseを返す
			return false;
		}

		//毎フレーム呼んで、必要なら情報の更新を行う
		public function Update():void{
		}
	}
}

