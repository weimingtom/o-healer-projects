//author Show=O=Healer
package{
	import flash.display.Stage;
	//Input
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	public class CInput_Keyboard extends IInput{
		//�L�[�{�[�h�̃L�[
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

		//�L�[�{�[�h�̓��͂��L�����Ă���
		private var m_Input:Array;//Boolean[BUTTON_NUM]
		private var m_Input_Old:Array;//�G�b�W���o�p
		private var m_Input_Old_Old:Array;//�G�b�W���o�p

		//������
		public function CInput_Keyboard(i_Stage:Stage):void{
			//�L�[�{�[�h�̓��͂�OnKeyDown�ȂǂŎ󂯎��
			{
				i_Stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
				i_Stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			}

			//�L����������
			{
				m_Input = new Array(BUTTON_NUM);
				m_Input_Old     = new Array(BUTTON_NUM);
				m_Input_Old_Old = new Array(BUTTON_NUM);
				for(var i:int = 0; i < m_Input.length; i+=1){
					m_Input_Old_Old[i] = m_Input_Old[i] = m_Input[i] = false;
				}
			}
		}

		//�L�[�������ꂽ��A�Ή����镔����true�ɂ���
		private function OnKeyDown(event:KeyboardEvent):void{
			switch(event.keyCode){
			//�J�[�\���̎����A�ł����e����
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

			case Keyboard.ENTER:	m_Input[BUTTON_GO_TO_PLAY] = true;	break;
			case Keyboard.ESCAPE:	m_Input[BUTTON_GO_TO_EDIT] = true;	break;

			case Keyboard.SPACE:	m_Input[BUTTON_BLOCK_O] = true;	break;
			case KEY_W:				m_Input[BUTTON_BLOCK_W] = true;	break;
			}
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

			case Keyboard.ENTER:	m_Input[BUTTON_GO_TO_PLAY] = false;	break;
			case Keyboard.ESCAPE:	m_Input[BUTTON_GO_TO_EDIT] = false;	break;

			case Keyboard.SPACE:	m_Input[BUTTON_BLOCK_O] = false;	break;
			case KEY_W:				m_Input[BUTTON_BLOCK_W] = false;	break;
			}
		}

		//i_Button�����݉�����Ă��邩
		override public function IsPress(i_Button:int):Boolean{
			return m_Input[i_Button];
		}

		//i_Button�������ꂽ���i�G�b�W�j
		override public function IsPress_Edge(i_Button:int):Boolean{
			return m_Input[i_Button] && (m_Input_Old_Old[i_Button] != m_Input[i_Button]);
		}

		//���t���[���Ă�ŁA�K�v�Ȃ���̍X�V���s��
		override public function Update():void{
			var i:int;
			//Update_Post�Ƃ���������ǉ�����΁A�킴�킴OldOld�݂����Ȃ̂͗p�ӂ��Ȃ��Ă��������ǁA����͂����
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old_Old[i] = m_Input_Old[i];
			}
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old[i] = m_Input[i];
			}
		}
	}
}

