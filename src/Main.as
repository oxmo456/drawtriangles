package {
	import flash.display.Bitmap;
	import flash.display.Sprite;

	public class Main extends Sprite {
		[Embed(source="test_img.jpg", mimeType="image/jpeg")]
		private var TestImg : Class;

		public function Main() {
			var testImg : Bitmap = new TestImg as Bitmap;
			addChild(testImg);
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
