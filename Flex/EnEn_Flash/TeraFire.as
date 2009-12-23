package {
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TeraFire extends Sprite{
		//横方向ゆらぎ速度
		public var phaseRateX:Number;
		//縦方向ゆらぎ速度
		public var phaseRateY:Number;
		private var offsets:Array= [new Point(),new Point()];
		private var seed:Number = Math.random();
		private var fireW:Number;
		private var fireH:Number;
		//火の色
		private var fireColerIn:uint = 0xFFCC00;
		private var fireColerOut:uint = 0xE22D09;

		private var ball:Sprite;
		private var gradientImage:BitmapData;
		private var displaceImage:BitmapData;
		//火の玉の中心の上下位置偏差（-1で上端、1で下端）
		private var focalPointRatio:Number = 0.6;
		//炎の揺らぎのせいで描画エリアをはみ出してしまうのを防ぐための余白幅
		private const margin:int = 10;
		private var rdm:Number;
		
		//コンストラクタ
		public function TeraFire(xPos:Number=0, yPos:Number=0, fireWidth:Number=30, fireHeight:Number=90){
			fireW = fireWidth;
			fireH = fireHeight;
			phaseRateX = 0;
			phaseRateY = 5;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(fireW,fireH,Math.PI/2,-fireW/2,-fireH*(focalPointRatio+1)/2);
			var colors:Array = [fireColerIn, fireColerOut, fireColerOut];
			var alphas:Array = [1,1,0];
			var ratios:Array = [30, 100, 220];
			
			var home:Sprite = new Sprite();
			ball = new Sprite();
			//炎本体
			ball.graphics.beginGradientFill(GradientType.RADIAL,colors, alphas, ratios, matrix,"pad","rgb",focalPointRatio);
			ball.graphics.drawEllipse(-fireW/2,-fireH*(focalPointRatio+1)/2,fireW,fireH);
			ball.graphics.endFill();
			//余白確保用透明矩形
			ball.graphics.beginFill(0x000000,0);
			ball.graphics.drawRect(-fireW/2,0,fireW+margin,1);
			ball.graphics.endFill();
			addChild(home);
			home.addChild(ball);
			this.x = xPos;
			this.y = yPos;
//			addEventListener(Event.ENTER_FRAME,loop);
			
			//ゆらぎ用のBitmap（ステージに貼付ける必要はないのでBitmapに貼る必要はない）
			displaceImage = new BitmapData(fireW+margin,fireH,false,0xFFFFFFFF);
			//火の芯付近の揺らぎを抑える用のグラデーション
			var matrix2:Matrix = new Matrix();
			matrix2.createGradientBox(fireW+margin,fireH,Math.PI/2,0,0);
			var gradient_mc:Sprite = new Sprite;
			gradient_mc.graphics.beginGradientFill(GradientType.LINEAR,[0x666666,0x666666], [0,1], [120,220], matrix2);
			gradient_mc.graphics.drawRect(0,0,fireW+margin,fireH);//drawのターゲットなので生成位置にこだわる必要はない。
			gradient_mc.graphics.endFill();
			gradientImage = new BitmapData(fireW+margin,fireH,true,0x00FFFFFF);
			gradientImage.draw(gradient_mc);//gradient_mcを消す必要は？
			//同サイズの炎の揺らぎをランダム化
			rdm = Math.floor(Math.random()*10);
			
			//確認検証用コード
			/*this.startDrag(true);//検証用マウス吸着
			import flash.display.Bitmap; 
			var bmp:Bitmap = new flash.display.Bitmap(displaceImage);
			bmp.x = -fireW/2;
			bmp.y = -fireH*(focalPointRatio+1)/2;
			home.addChild(bmp);
			bmp.alpha = 0.4;//揺らぎマップのコピーを半透明表示（擬似コピーなので揺らぎマップ本体ではない！）
			home.addChild(gradient_mc);//根元の揺らぎ抑えるグラデーションを表示。場所は適当
			*/
		}
		public function loop():void{//e:Event
			//もやもや画像を上スクロール移動させる
			for(var i:int = 0; i < 2; ++i){
				offsets[i].x += phaseRateX;
				offsets[i].y += phaseRateY;
			}
			//もやもやした白黒画像を生成
			displaceImage.perlinNoise(30+rdm, 60+rdm, 2, seed, false, false, 7, true, offsets);
			//芯付近の揺らぎを抑える
			displaceImage.copyPixels(gradientImage,gradientImage.rect,new Point(),null, null, true);
			var dMap:DisplacementMapFilter = new DisplacementMapFilter(displaceImage, new Point(), 1, 1, 20, 10, DisplacementMapFilterMode.CLAMP);
			ball.filters = [dMap];
		}
	}
}
/*
課題点：
・DisplacementMapFilterの元マップが原寸な必要ないかも。半分のサイズを拡大して使って負荷下げれたらいいかも。
・やや右寄りに揺らぐ分だけ余計にサイズ確保してる部分（margin）の処理が不細工。
*/