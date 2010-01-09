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

	public class Goal extends IGameObject{
		//==Const==

		//==Var==


		//==Common==

		override public function Reset(i_X:int, i_Y:int):void{
			//Pos
			{
				SetPos(i_X, i_Y);
			}

			//Graphic
			{//グラフィックは本体側でまとめて管理する
				if(numChildren <= 0){//まだ生成してなかったら
					addChild(ImageManager.LoadBlockImage(Game.G));
				}
			}
		}

		//Update:オーバライドして使う
		override public function Update(i_DeltaTime:Number):void{
			var player:Player;
			{
				player = Game.Instance().m_Player;
			}

			//Check
			{
				if(player == null){
					return;
				}
			}

			var Gap:Vector3D;
			{
				Gap = new Vector3D(
					player.x - this.x,
					player.y - this.y
				);
			}

			if(Gap.length < ImageManager.PANEL_LEN/2){
				Game.Instance().OnGoal();
			}
		}
	}
}

