//author Show=O=Healer
package{
	import flash.display.Stage;
	//Input
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	public class CInput_Keyboard extends IInput{
		//キーボードのキー
		static public const KEY_0:int = 48;
		static public const KEY_1:int = 49;
		static public const KEY_2:int = 50;
		static public const KEY_3:int = 51;
		static public const KEY_4:int = 52;
		static public const KEY_5:int = 53;
		static public const KEY_6:int = 54;
		static public const KEY_7:int = 55;
		static public const KEY_8:int = 56;
		static public const KEY_9:int = 57;
		static public const KEY_A:int = 65;
		static public const KEY_B:int = 66;
		static public const KEY_C:int = 67;
		static public const KEY_D:int = 68;
		static public const KEY_E:int = 69;
		static public const KEY_F:int = 70;
		static public const KEY_G:int = 71;
		static public const KEY_H:int = 72;
		static public const KEY_I:int = 73;
		static public const KEY_J:int = 74;
		static public const KEY_K:int = 75;
		static public const KEY_L:int = 76;
		static public const KEY_M:int = 77;
		static public const KEY_N:int = 78;
		static public const KEY_O:int = 79;
		static public const KEY_P:int = 80;
		static public const KEY_Q:int = 81;
		static public const KEY_R:int = 82;
		static public const KEY_S:int = 83;
		static public const KEY_T:int = 84;
		static public const KEY_U:int = 85;
		static public const KEY_V:int = 86;
		static public const KEY_W:int = 87;
		static public const KEY_X:int = 88;
		static public const KEY_Y:int = 89;
		static public const KEY_Z:int = 90;

		//キーボードの入力を記憶しておく
		private var m_Input:Array;//Boolean[BUTTON_NUM]
		private var m_Input_Old:Array;//エッジ検出用
		private var m_Input_Old_Old:Array;//エッジ検出用

		//初期化
		public function CInput_Keyboard(i_Stage:Stage):void{
			//キーボードの入力をOnKeyDownなどで受け取る
			{
				i_Stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
				i_Stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			}

			//記憶を初期化
			{
				m_Input = new Array(BUTTON_NUM);
				m_Input_Old     = new Array(BUTTON_NUM);
				m_Input_Old_Old = new Array(BUTTON_NUM);
				for(var i:int = 0; i < m_Input.length; i+=1){
					m_Input_Old_Old[i] = m_Input_Old[i] = m_Input[i] = false;
				}
			}
		}

		//キーが押されたら、対応する部分をtrueにする
		private function OnKeyDown(event:KeyboardEvent):void{
			switch(event.keyCode){
			case Keyboard.LEFT:		m_Input[BUTTON_L] = true;		break;
			case Keyboard.RIGHT:	m_Input[BUTTON_R] = true;		break;
			case Keyboard.UP:		m_Input[BUTTON_U] = true;		break;
			case Keyboard.DOWN:		m_Input[BUTTON_D] = true;		break;

			case KEY_R:				m_Input[BUTTON_RESET] = true;	break;
			}
		}
		private function OnKeyUp(event:KeyboardEvent):void{
			switch(event.keyCode){
			case Keyboard.LEFT:		m_Input[BUTTON_L] = false;		break;
			case Keyboard.RIGHT:	m_Input[BUTTON_R] = false;		break;
			case Keyboard.UP:		m_Input[BUTTON_U] = false;		break;
			case Keyboard.DOWN:		m_Input[BUTTON_D] = false;		break;

			case KEY_R:				m_Input[BUTTON_RESET] = false;	break;
			}
		}

		//i_Buttonが現在押されているか
		override public function IsPress(i_Button:int):Boolean{
			return m_Input[i_Button];
		}

		//i_Buttonが押されたか（エッジ）
		override public function IsPress_Edge(i_Button:int):Boolean{
			return m_Input[i_Button] && (m_Input_Old_Old[i_Button] != m_Input[i_Button]);
		}

		//毎フレーム呼んで、必要なら情報の更新を行う
		override public function Update():void{
			var i:int;
			//Update_Postという処理を追加すれば、わざわざOldOldみたいなのは用意しなくてもいいけど、今回はこれで
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old_Old[i] = m_Input_Old[i];
			}
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old[i] = m_Input[i];
			}
		}
	}
}

