package {
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TestColorCircle extends Sprite {
		public function TestColorCircle() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var perlinNoise : BitmapData = new BitmapData(1, 1, true, 0xFFFFFFFF);
			var perlinNoiseBitmap : Bitmap = new Bitmap(perlinNoise);
			addChild(perlinNoiseBitmap);

			var echo : BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			var echoBitmap : Bitmap = new Bitmap(echo);
			addChild(echoBitmap);

			var cx : int = 0;
			var cy : int = 0;

			var s : Shape = new Shape();
			s.blendMode = BlendMode.LAYER;
			addChild(s);
			var grp : Graphics = s.graphics;

			stage.addEventListener(Event.RESIZE, stageResize);

			function stageResize() : void {
				cx = stage.stageWidth * 0.5;
				cy = stage.stageHeight * 0.5;
				s.x = cx;
				s.y = cy;
				echo = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
				echoBitmap.bitmapData = echo;
				perlinNoiseBitmap.width = stage.stageWidth;
				perlinNoiseBitmap.height = stage.stageHeight;
			}

			var offsets : Array = [];
			var v : Array = [];
			var k : int = 3;
			for (var i : int = 0; i < k; i++) {
				offsets.push(new Point());
				v.push(Math.random() * 2 - 1);
			}

			var rInfo : TextField = createInfoTextField();
			addChild(rInfo);
			var gInfo : TextField = createInfoTextField();
			addChild(gInfo);
			var bInfo : TextField = createInfoTextField();
			addChild(bInfo);

			function createInfoTextField() : TextField {
				var t : TextField = new TextField();
				var f : TextFormat = new TextFormat();
				f.font = "Verdana";
				f.size = 9;
				f.color = 0xffffff;
				t.defaultTextFormat = f;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.selectable = false;
				return t;
			}
			var zR : Number = 2;
			var zG : Number = 2;
			var zB : Number = 2;
			addEventListener(Event.ENTER_FRAME, function() : void {
				perlinNoise.perlinNoise(100, 100, k, 1977, false, false, 7, false, offsets);
				for (var i : int = 0; i < k; i++) {
					offsets[i]["x"] += v[i];
				}
				var color : uint = perlinNoise.getPixel(0, 0);
				var r : uint = color >> 16 & 0xFF;
				var g : uint = color >> 8 & 0xFF;
				var b : uint = color & 0xFF;

				grp.clear();

				grp.lineStyle(0, 0xffffff, 0.4);

				grp.moveTo(0, 0);
				var pR : Point = getPointFromAngle(0, r * zR);
				grp.lineTo(pR.x, pR.y);
				rInfo.x = pR.x + cx;
				rInfo.y = pR.y + cy;
				rInfo.text = "R:" + r.toString(16);

				grp.moveTo(0, 0);
				var pG : Point = getPointFromAngle(120, g * zG);
				grp.lineTo(pG.x, pG.y);
				gInfo.text = "G:" + g.toString(16);
				gInfo.x = pG.x + cx;
				gInfo.y = pG.y + cy - gInfo.height;

				grp.moveTo(0, 0);
				var pB : Point = getPointFromAngle(240, b * zB);
				grp.lineTo(pB.x, pB.y);
				bInfo.text = "B:" + b.toString(16);
				bInfo.x = pB.x + cx - bInfo.width;
				bInfo.y = pB.y + cy - bInfo.height;

				var x1 : Number = pR.x;
				var y1 : Number = pR.y;
				var x2 : Number = pG.x;
				var y2 : Number = pG.y;
				var x3 : Number = pB.x;
				var y3 : Number = pB.y;

				var mr : Number = (y2 - y1) / (x2 - x1);
				var mt : Number = (y3 - y2) / (x3 - x2);

				var px : Number = (mr * mt * (y3 - y1) + mr * (x2 + x3) - mt * (x1 + x2)) / (2 * (mr - mt));

				var py : Number = (-1 / mr) * (px - (x1 + x2) / 2) + (y1 + y2) / 2;

				var radius : Number = Math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));

				if (px && py && radius) {
					grp.lineStyle(0, 0xffffff, 0.6);
					grp.drawCircle(px, py, radius);
					grp.moveTo(px - 3, py);
					grp.lineTo(px + 3, py);
					grp.moveTo(px, py - 3);
					grp.lineTo(px, py + 3);
					grp.moveTo(px, py);
					grp.lineTo(0, 0);
					var rect : Rectangle = new Rectangle();
					rect.x = px + cx;
					rect.y = py + cy;
					rect.x -= 2;
					rect.y -= 2;
					rect.width = 4;
					rect.height = 4;
					echo.fillRect(rect, 0xff000000 | color);
				}
			});

			function getPointFromAngle(angle : Number, dist : Number) : Point {
				var p : Point = new Point();

				p.x = Math.sin(angle * Math.PI / 180) * dist;
				p.y = Math.cos(angle * Math.PI / 180) * dist;

				return p;
			}

			stageResize();
		}
	}
}
