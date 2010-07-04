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
			//カーソルの自動連打を許容する
			case Keyboard.LEFT:
				m_Input[BUTTON_L] = true;
				m_Input[BUTTON_CURSOR_L] = true;
				m_Input_Old[BUTTON_CURSOR_L] = m_Input_Old_Old[BUTTON_CURSOR_L] = false;
				break;
			case Keyboard.RIGHT:
				m_Input[BUTTON_R] = true;
				m_Input[BUTTON_CURSOR_R] = true;
				m_Input_Old[BUTTON_CURSOR_R] = m_Input_Old_Old[BUTTON_CURSOR_R] = false;
				break;
			case Keyboard.UP:
				m_Input[BUTTON_U] = true;
				m_Input[BUTTON_CURSOR_U] = true;
				m_Input_Old[BUTTON_CURSOR_U] = m_Input_Old_Old[BUTTON_CURSOR_U] = false;
				break;
			case Keyboard.DOWN:
				m_Input[BUTTON_D] = true;
				m_Input[BUTTON_CURSOR_D] = true;
				m_Input_Old[BUTTON_CURSOR_D] = m_Input_Old_Old[BUTTON_CURSOR_D] = false;
				break;

			case KEY_R:				m_Input[BUTTON_RESET] = true;	break;
			}

			//Player
			switch(event.keyCode){
			case Keyboard.SPACE:	m_Input[BUTTON_ACTION] = true; break;
			}

			//Editor
			switch(event.keyCode){
			case Keyboard.ENTER:
				m_Input[BUTTON_GO_TO_PLAY] = true;
				m_Input[BUTTON_GO_TO_EDIT] = true;
				break;

			case Keyboard.SPACE:	m_Input[BUTTON_BLOCK_O] = true;	break;
			case KEY_W:				m_Input[BUTTON_BLOCK_W] = true;	break;
			case KEY_Q:				m_Input[BUTTON_BLOCK_Q] = true;	break;
			case KEY_S:				m_Input[BUTTON_BLOCK_S] = true;	break;
			case KEY_D:				m_Input[BUTTON_BLOCK_D] = true;	break;
			case KEY_R:				m_Input[BUTTON_BLOCK_R] = true;	break;
			case KEY_M:				m_Input[BUTTON_BLOCK_M] = true;	break;
			case KEY_T:				m_Input[BUTTON_BLOCK_T] = true;	break;
			case KEY_A:				m_Input[BUTTON_BLOCK_A] = true;	break;
			case KEY_N:				m_Input[BUTTON_BLOCK_N] = true;	break;
			case KEY_L:				m_Input[BUTTON_BLOCK_L] = true;	break;
			case KEY_E:				m_Input[BUTTON_BLOCK_E] = true;	break;

			case KEY_P:				m_Input[BUTTON_PLAYER_POS] = true;	break;
			case KEY_G:				m_Input[BUTTON_GOAL_POS] = true;	break;

			case KEY_0:	m_Input[BUTTON_0] = true; break;
			case KEY_1:	m_Input[BUTTON_1] = true; break;
			case KEY_2:	m_Input[BUTTON_2] = true; break;
			case KEY_3:	m_Input[BUTTON_3] = true; break;
			case KEY_4:	m_Input[BUTTON_4] = true; break;
			case KEY_5:	m_Input[BUTTON_5] = true; break;
			case KEY_6:	m_Input[BUTTON_6] = true; break;
			case KEY_7:	m_Input[BUTTON_7] = true; break;
			case KEY_8:	m_Input[BUTTON_8] = true; break;
			case KEY_9:	m_Input[BUTTON_9] = true; break;
			}

			if(event.shiftKey){		m_Input[BUTTON_RANGE] = true;}
			if(event.ctrlKey){		m_Input[BUTTON_DIR] = true;}
		}
		private function OnKeyUp(event:KeyboardEvent):void{
			switch(event.keyCode){
			case Keyboard.LEFT:
				m_Input[BUTTON_L] = false;
				m_Input[BUTTON_CURSOR_L] = false;
				break;
			case Keyboard.RIGHT:
				m_Input[BUTTON_R] = false;
				m_Input[BUTTON_CURSOR_R] = false;
				break;
			case Keyboard.UP:
				m_Input[BUTTON_U] = false;
				m_Input[BUTTON_CURSOR_U] = false;
				break;
			case Keyboard.DOWN:
				m_Input[BUTTON_D] = false;
				m_Input[BUTTON_CURSOR_D] = false;
				break;

			case KEY_R:				m_Input[BUTTON_RESET] = false;	break;
			}

			//Player
			switch(event.keyCode){
			case Keyboard.SPACE:	m_Input[BUTTON_ACTION] = false; break;
			}

			//Editor
			switch(event.keyCode){
			case Keyboard.ENTER:
				m_Input[BUTTON_GO_TO_PLAY] = false;
				m_Input[BUTTON_GO_TO_EDIT] = false;
				break;

			case Keyboard.SPACE:	m_Input[BUTTON_BLOCK_O] = false;	break;
			case KEY_W:				m_Input[BUTTON_BLOCK_W] = false;	break;
			case KEY_Q:				m_Input[BUTTON_BLOCK_Q] = false;	break;
			case KEY_S:				m_Input[BUTTON_BLOCK_S] = false;	break;
			case KEY_D:				m_Input[BUTTON_BLOCK_D] = false;	break;
			case KEY_R:				m_Input[BUTTON_BLOCK_R] = false;	break;
			case KEY_M:				m_Input[BUTTON_BLOCK_M] = false;	break;
			case KEY_T:				m_Input[BUTTON_BLOCK_T] = false;	break;
			case KEY_A:				m_Input[BUTTON_BLOCK_A] = false;	break;
			case KEY_N:				m_Input[BUTTON_BLOCK_N] = false;	break;
			case KEY_L:				m_Input[BUTTON_BLOCK_L] = false;	break;
			case KEY_E:				m_Input[BUTTON_BLOCK_E] = false;	break;

			case KEY_P:				m_Input[BUTTON_PLAYER_POS] = false;	break;
			case KEY_G:				m_Input[BUTTON_GOAL_POS] = false;	break;

			case KEY_0:	m_Input[BUTTON_0] = false; break;
			case KEY_1:	m_Input[BUTTON_1] = false; break;
			case KEY_2:	m_Input[BUTTON_2] = false; break;
			case KEY_3:	m_Input[BUTTON_3] = false; break;
			case KEY_4:	m_Input[BUTTON_4] = false; break;
			case KEY_5:	m_Input[BUTTON_5] = false; break;
			case KEY_6:	m_Input[BUTTON_6] = false; break;
			case KEY_7:	m_Input[BUTTON_7] = false; break;
			case KEY_8:	m_Input[BUTTON_8] = false; break;
			case KEY_9:	m_Input[BUTTON_9] = false; break;
			}

			if(! event.shiftKey){		m_Input[BUTTON_RANGE] = false;}
			if(! event.ctrlKey){		m_Input[BUTTON_DIR] = false;}
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

