package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	[SWF(backgroundColor="#FFFFFF", frameRate="62", width="500", height="500")]
	public class TestDrawTriangles2 extends Sprite {
		public function TestDrawTriangles2() {
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadingComplete);
			function loadingComplete() : void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadingComplete);
				start(Bitmap(loader.content).bitmapData);
			}
			loader.load(new URLRequest("http://farm4.static.flickr.com/3205/2336407752_002f5d0fc8_b.jpg"), new LoaderContext(true));
		}

		private function start(testImg : BitmapData) : void {
			var drawCam : Function = function() : void {
				graphics.clear();
				videoBitmapData.draw(video);
				graphics.beginBitmapFill(videoBitmapData);
				graphics.drawTriangles(vertices, verticeGrid.indices, verticeGrid.uvtData);
				graphics.endFill();
			};
			var drawTestImg : Function = function() : void {
				graphics.clear();
				graphics.beginBitmapFill(testImg);
				graphics.drawTriangles(vertices, verticeGrid.indices, verticeGrid.uvtData);
				graphics.endFill();
			};
			var draw : Function;

			var cam : Camera = Camera.getCamera();
			if (cam) {
				cam.setQuality(16384, 100);
				cam.addEventListener(StatusEvent.STATUS, camStatus);
				cam.setMode(stage.stageWidth, stage.stageHeight, 30);
				var video : Video = new Video(stage.stageWidth, stage.stageHeight);
			}
			draw = drawTestImg;

			function camStatus(e : StatusEvent) : void {			
				if (e.code == "Camera.Muted") {
					draw = drawTestImg;
				} else {
					draw = drawCam;
				}				
			}

			video.attachCamera(cam);
			var videoBitmapData : BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight);

			var delta : Number = 100;

			var cols : int = 30;
			var rows : int = 30;
			var perlinNoiseBaseY : Number = 20;
			var perlinNoiseBaseX : Number = 20;

			var perlinNoiseRandomSeed : int = 1977;
			var perlinNoiseNumOctaves : uint = 1;

			var perlinNoiseOffsetP1 : Point = new Point();
			var perlinNoiseOffsets : Array = [perlinNoiseOffsetP1];

			var sin120 : Number = Math.sin(120 * Math.PI / 180);
			var cos120 : Number = Math.cos(120 * Math.PI / 180);
			var sin240 : Number = Math.sin(240 * Math.PI / 180);
			var cos240 : Number = Math.cos(240 * Math.PI / 180);

			var r : uint;
			var g : uint;
			var b : uint;

			var x1 : Number;
			var y1 : Number;
			var x2 : Number;
			var y2 : Number;
			var x3 : Number;
			var y3 : Number;

			var mr : Number;
			var mt : Number;

			var vector : Point = new Point();

			var k : int;
			var i : int;

			var firstRow : Rectangle = new Rectangle(0, 0, cols + 1, 1);

			var verticeGrid : VerticeGrid = new VerticeGrid(stage.stageWidth + delta * 2, stage.stageHeight + delta * 2, cols, rows);
			trace(verticeGrid.vertices);
			var vertices : Vector.<Number> = new Vector.<Number>(cols * rows * 2);

			var perlinNoise : BitmapData = new BitmapData(cols + 1, rows + 1);
			updatePerlinNoise();

			var colors : Vector.<uint> = perlinNoise.getVector(perlinNoise.rect);
			var distortion : Vector.<Number> = new Vector.<Number>((cols + 1) * (rows + 1) * 2);
			var length : int = colors.length;

			k = 0;
			for (i = 0; i < length; i++) {
				colorToVector(colors[i]);
				distortion[k++] = vector.x;
				distortion[k++] = vector.y;
			}

			var render : Function = function() : void {
				updatePerlinNoise();

				k = (cols + 1) * 2;

				for (i = distortion.length - 1; i >= k; i--) {
					distortion[i] = distortion[i - k];
				}

				colors = perlinNoise.getVector(firstRow);
				length = colors.length;
				k--;
				for (i = length - 1; i >= 0; i--) {
					colorToVector(colors[i]);
					distortion[k--] = vector.y;
					distortion[k--] = vector.x;
				}
				length = distortion.length;

				for (i = 0; i < length; i++) {
					vertices[i] = verticeGrid.vertices[i] + distortion[i] - delta;
				}
				draw();
			};

			addEventListener(Event.ENTER_FRAME, render);

			function updatePerlinNoise() : void {
				perlinNoiseOffsetP1.y--;
				perlinNoise.lock();
				perlinNoise.perlinNoise(perlinNoiseBaseX, perlinNoiseBaseY, perlinNoiseNumOctaves, perlinNoiseRandomSeed, true, true, 7, false, perlinNoiseOffsets);
				perlinNoise.unlock();
			}

			function colorToVector(color : uint) : void {
				r = color >> 16 & 0xFF;
				g = color >> 8 & 0xFF;
				b = color & 0xFF;
				x1 = 0;
				y1 = r;
				x2 = sin120 * g;
				y2 = cos120 * g;
				x3 = sin240 * b;
				y3 = cos240 * b;
				mr = (y2 - y1) / (x2 - x1);
				mt = (y3 - y2) / (x3 - x2);
				vector.x = (mr * mt * (y3 - y1) + mr * (x2 + x3) - mt * (x1 + x2)) / (2 * (mr - mt));
				vector.y = (-1 / mr) * (vector.x - (x1 + x2) * 0.5) + (y1 + y2) * 0.5;
			}
		}
	}
}
class VerticeGrid {
	public var vertices : Vector.<Number>;
	public var indices : Vector.<int>;
	public var uvtData : Vector.<Number>;

	public function VerticeGrid(width : Number, height : Number, columns : uint = 1, rows : uint = 1) {
		trace(columns, rows);
		var dx : Number = width / columns;
		var dy : Number = height / rows;
		vertices = new Vector.<Number>();
		uvtData = new Vector.<Number>();
		var px : Number = 0;
		var py : Number = 0;
		for (var y : int = 0; y <= rows; y++) {
			px = 0;
			for (var x : int = 0; x <= columns; x++) {
				vertices.push(px, py);
				uvtData.push(px / width, py / height);
				px += dx;
			}
			py += dy;
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
