package {
	import flash.geom.Point;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class Main extends Sprite {
		[Embed(source="test_img.jpg", mimeType="image/jpeg")]
		private var TestImg : Class;

		public function Main() {
			var d : uint = 0xf0e2ff;

			trace(d.toString(2));

			d = d & 0x1FF;

			trace(d.toString(2));

			// var testImg : BitmapData = (new TestImg as Bitmap).bitmapData;
			//			//
			// var plane : Plane = new Plane(stage.stageWidth, stage.stageHeight, 10, 10);
			//
			// graphics.lineStyle(0, 0, 0.5);
			// graphics.beginBitmapFill(testImg);
			// graphics.drawTriangles(plane.vertices, plane.indices, plane.uvtData);
			// graphics.endFill();
			//			//
			//
			var perlinNoise : BitmapData = new BitmapData(1, 1, true, 0);
			var b : Bitmap = new Bitmap(perlinNoise);
			b.width = stage.stageWidth;
			b.height = stage.stageHeight;
			addChild(b);

			var offsets : Array = [];
			var v : Array = [];
			var k : int = 3;
			for (var i : int = 0; i < k; i++) {
				offsets.push(new Point());
				v.push(Math.random() * 2 - 1);
			}
			var a : Number = 0;
			var h : Number = 0;
			addEventListener(Event.ENTER_FRAME, function() : void {
				perlinNoise.perlinNoise(100, 100, k, 1977, false, false, 7, false, offsets);
				for (var i : int = 0; i < k; i++) {
					offsets[i]["x"] += v[i];
				}

				a = perlinNoise.getVector(perlinNoise.rect)[0];
				trace(a - h);
				h = a;
				
			});
		}
	}
}
class Plane {
	public var vertices : Vector.<Number>;
	public var indices : Vector.<int>;
	public var uvtData : Vector.<Number>;

	public function Plane(width : Number, height : Number, columns : int = 1, rows : int = 1) {
		var dx : Number = width / columns;
		var dy : Number = height / rows;
		vertices = new Vector.<Number>();
		uvtData = new Vector.<Number>();
		for (var y : Number = 0; y <= height; y += dy) {
			for (var x : Number = 0; x <= width; x += dx) {
				vertices.push(x, y);
				uvtData.push(x / width, y / height);
			}
		}
		indices = new Vector.<int>();
		var k : int = 0;
		var a : Vector.<uint> = new Vector.<uint>();
		for (var i : int = 0; i < rows; i++) {
			for (var j : int = 0; j < columns; j++) {
				a.push(k++);
			}
			k++;
		}
		k = a.length;
		for (var w : int = 0; w < k; w++) {
			var z0 : Number = a[w];
			var z1 : Number = z0 + 1;
			var z2 : Number = z1 + columns;
			var z3 : Number = z2 + 1;
			indices.push(z0, z1, z2, z2, z3, z1);
		}
	}
}
