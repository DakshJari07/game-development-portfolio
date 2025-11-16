package ui;

import Math;
import core.GameConfig;
import core.LevelData;
import entities.Enemy;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class MiniMap extends FlxSprite {
    var map:Array<String>;
    var zoom:Int;
    var size:Int;
    var radius:Int;
    var bmd:BitmapData;

    public function new(map:Array<String>, size:Int = 140, zoom:Int = 4) {
        super();
        this.map = map;
        this.size = size;
        this.zoom = zoom;
        this.radius = Std.int(size / 2);
        makeGraphic(size, size, 0x00000000, true);
        bmd = pixels;
        scrollFactor.set(0, 0);
        x = 16;
        y = GameConfig.SCREEN_H - size - 20;
    }

    public function render(px:Float, py:Float, pa:Float, enemies:Array<Enemy>):Void {
        bmd.lock();
        bmd.fillRect(new Rectangle(0, 0, size, size), 0x00000000);

        var half = radius;

        inline function insideCircle(sx:Int, sy:Int):Bool {
            var dx = sx - half;
            var dy = sy - half;
            return (dx * dx + dy * dy) <= radius * radius;
        }

        inline function rotate270Left(x:Float, y:Float):{x:Int, y:Int} {
            var dx = x - half;
            var dy = y - half;
			var angle = 3 * Math.PI / 2;
            var rotatedX = dx * Math.cos(angle) - dy * Math.sin(angle);
            var rotatedY = dx * Math.sin(angle) + dy * Math.cos(angle);
            return {x: Std.int(half + rotatedX), y: Std.int(half + rotatedY)};
        }

        for (j in 0...map.length)
            for (i in 0...map[j].length)
                if (LevelData.isWall(i, j)) {
                    var sx = half + (i - px) * zoom;
                    var sy = half + (j - py) * zoom;
                    var rotated = rotate270Left(sx, sy);
                    if (insideCircle(rotated.x, rotated.y))
						bmd.fillRect(new Rectangle(rotated.x, rotated.y, 3, 3), 0xffCCCCCC);
                }

        for (e in enemies)
            if (e.alive) {
				var sx = half + (e.worldX - px) * zoom;
				var sy = half + (e.worldY - py) * zoom;
                var rotated = rotate270Left(sx, sy);
                if (insideCircle(rotated.x, rotated.y))
                    bmd.fillRect(new Rectangle(rotated.x, rotated.y, 3, 3), 0xffff3333);
            }

        drawArrow(half, half, pa + 3 * Math.PI / 2, 0xff00aaff);

        for (y in 0...size)
            for (x in 0...size) {
                var dx = x - half;
                var dy = y - half;
                var distSq = dx * dx + dy * dy;
                var radiusSq = radius * radius;
                
				if (distSq <= radiusSq)
				{
                    var currentPixel = bmd.getPixel32(x, y);
					if (currentPixel == 0x00000000)
					{
						bmd.setPixel32(x, y, 0xAA000000);
                    }

                    if (distSq > (radius - 2) * (radius - 2)) {
						bmd.setPixel32(x, y, 0xFFFFFFFF);
                    }
				}
				else
				{
                    bmd.setPixel32(x, y, 0x00000000);
                }
            }

        bmd.unlock();
        dirty = true;
    }

    function drawArrow(cx:Int, cy:Int, ang:Float, col:Int):Void {
        var len = 8.0;
        var tipX = Std.int(cx + Math.cos(ang) * len);
        var tipY = Std.int(cy + Math.sin(ang) * len);
        var leftX = Std.int(cx + Math.cos(ang + Math.PI * 0.75) * 5);
        var leftY = Std.int(cy + Math.sin(ang + Math.PI * 0.75) * 5);
        var rightX = Std.int(cx + Math.cos(ang - Math.PI * 0.75) * 5);
        var rightY = Std.int(cy + Math.sin(ang - Math.PI * 0.75) * 5);

        drawSafeLine(cx, cy, tipX, tipY, col);
        drawSafeLine(tipX, tipY, leftX, leftY, col);
        drawSafeLine(tipX, tipY, rightX, rightY, col);
    }

    function drawSafeLine(x0:Float, y0:Float, x1:Float, y1:Float, col:Int):Void {
        var dx = Math.abs(x1 - x0);
        var dy = Math.abs(y1 - y0);
        var sx = if (x0 < x1) 1 else -1;
        var sy = if (y0 < y1) 1 else -1;
        var err = dx - dy;
        var x = Std.int(x0);
        var y = Std.int(y0);
        var steps = 0;
        while (steps < 200) {
            steps++;
            if (x >= 0 && y >= 0 && x < size && y < size)
                bmd.setPixel32(x, y, col);
            if (x == Std.int(x1) && y == Std.int(y1)) break;
            var e2 = 2 * err;
            if (e2 > -dy) { err -= dy; x += sx; }
            if (e2 < dx) { err += dx; y += sy; }
        }
    }
}

