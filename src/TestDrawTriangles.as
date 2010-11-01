package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;

	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="500", height="500")]
	public class TestDrawTriangles extends Sprite {
		[Embed(source="test_img_3.jpg", mimeType="image/jpeg")]
		private var TestImg : Class;

		public function TestDrawTriangles() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;

			var rows : int = 30;
			var cols : int = 30;

			var j : Number = 100;

			var perlinNoise : BitmapData = new BitmapData(rows + 1, cols + 1);
			var offsetP1 : Point = new Point();
			var offsets : Array = [offsetP1];

			var testImg : BitmapData = (new TestImg as Bitmap).bitmapData;
			var verticeGrid : VerticeGrid;

			var vertices : Vector.<Number> = new Vector.<Number>((rows + 1) * (cols + 1) * 2);
			var vector : Point = new Point();

			var sin120 : Number = Math.sin(120 * Math.PI / 180);
			var cos120 : Number = Math.cos(120 * Math.PI / 180);
			var sin240 : Number = Math.sin(240 * Math.PI / 180);
			var cos240 : Number = Math.cos(240 * Math.PI / 180);

			addEventListener(Event.ENTER_FRAME, function() : void {
				offsetP1.y += 1;
				perlinNoise.lock();
				perlinNoise.perlinNoise(15, 15, 1, 1977, true, true, 7, false, offsets);

				var colors : Vector.<uint> = perlinNoise.getVector(perlinNoise.rect);

				perlinNoise.unlock();
				var k : int = 0;
				for each (var color : uint in colors) {
					var r : uint = color >> 16 & 0xFF;
					var g : uint = color >> 8 & 0xFF;
					var b : uint = color & 0xFF;

					var x1 : Number = 0;
					var y1 : Number = r;
					var x2 : Number = sin120 * g;
					var y2 : Number = cos120 * g;
					var x3 : Number = sin240 * b;
					var y3 : Number = cos240 * b;

					var mr : Number = (y2 - y1) / (x2 - x1);
					var mt : Number = (y3 - y2) / (x3 - x2);

					var px : Number = (mr * mt * (y3 - y1) + mr * (x2 + x3) - mt * (x1 + x2)) / (2 * (mr - mt));
					var py : Number = (-1 / mr) * (px - (x1 + x2) / 2) + (y1 + y2) / 2;

					vector.x = px ;
					vector.y = py;
					vertices[k] = verticeGrid.vertices[k] + vector.x - j;
					k++;
					vertices[k] = verticeGrid.vertices[k] + vector.y - j;
					k++;
				}

				graphics.clear();
				graphics.beginBitmapFill(testImg);
				graphics.drawTriangles(vertices, verticeGrid.indices, verticeGrid.uvtData);
				graphics.endFill();
			});

			stage.addEventListener(Event.RESIZE, stageResize);

			function stageResize() : void {
				verticeGrid = new VerticeGrid(stage.stageWidth + j * 2, stage.stageHeight + j * 2, rows, cols);
			}
			stageResize();
		}
	}
}
class VerticeGrid {
	public var vertices : Vector.<Number>;
	public var indices : Vector.<int>;
	public var uvtData : Vector.<Number>;

	public function VerticeGrid(width : Number, height : Number, columns : int = 1, rows : int = 1) {
		var dx : Number = width / columns;
		var dy : Number = height / rows;
		vertices = new Vector.<Number>();
		uvtData = new Vector.<Number>();
		var px : Number = 0;
		var py : Number = 0;
		for (var y : Number = 0; y <= rows; y++) {
			px = 0;
			for (var x : Number = 0; x <= columns; x++) {
				vertices.push(px, py);
				uvtData.push(px / width, py / height);
				px += dx;
			}
			py += dy;
		}
		indices = new Vector.<int>();
		var k : int = 0;
		
		for (var i : int = 0; i < rows; i++) {
			for (var j : int = 0; j < columns; j++) {
				var z0 : Number = k++;
				var z1 : Number = z0 + 1;
				var z2 : Number = z1 + columns;
				var z3 : Number = z2 + 1;
				indices.push(z0, z1, z2, z2, z3, z1);
			}
			k++;
		}
		
	}
}
