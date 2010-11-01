package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class TestColorCircle2 extends Sprite {
		public function TestColorCircle2() {
			stage.frameRate = 255;

			var bitmapData : BitmapData = new BitmapData(600, 600, false);
			var bitmap : Bitmap = new Bitmap(bitmapData);
			addChild(bitmap);

			var dx : int = 300;
			var dy : int = 300;			

			var c : Number = Math.sin(120 * Math.PI / 180);
			var d : Number = Math.cos(120 * Math.PI / 180);
			var e : Number = Math.sin(240 * Math.PI / 180);
			var f : Number = Math.cos(240 * Math.PI / 180);

			var k : int = 254;
			var q : int = 2;
			bitmapData.lock();
			for (var r : int = 0; r < k; r += q) {
				for (var g : int = 0; g < k; g += q) {
					for (var b : int = 0; b < k; b += q) {
						var x1 : Number = 0;
						var y1 : Number = r;
						var x2 : Number = c * g;
						var y2 : Number = d * g;
						var x3 : Number = e * b;
						var y3 : Number = f * b;

						var mr : Number = (y2 - y1) / (x2 - x1);
						var mt : Number = (y3 - y2) / (x3 - x2);

						var px : Number = (mr * mt * (y3 - y1) + mr * (x2 + x3) - mt * (x1 + x2)) / (2 * (mr - mt));

						var py : Number = (-1 / mr) * (px - (x1 + x2) / 2) + (y1 + y2) / 2;

						bitmapData.setPixel(px + dx, py + dy, r << 16 | g << 8 | b);
					}
				}
			}
			bitmapData.unlock();
		}
	}
}
