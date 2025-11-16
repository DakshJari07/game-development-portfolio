package core;

import Assets;
import Math;
import entities.Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Raycaster extends FlxSprite {
    public var map:Array<String>;
    public var zbuf:Array<Float>;
    var bmd:BitmapData;
    public var flash:Float = 0;

    public function new(map:Array<String>) {
        super();
        this.map = map;
        makeGraphic(GameConfig.SCREEN_W, GameConfig.SCREEN_H, 0x00000000, true);
        bmd = pixels;
        zbuf = [for (_ in 0...GameConfig.SCREEN_W) 999.0];
        scrollFactor.set(0, 0);
    }

    inline function shade(col:Int, d:Float):Int {
        var f = 1.0 - Math.min(1.0, d / GameConfig.MAX_DIST);
        if (flash > 0) f = Math.min(1.0, f + 0.35);
        var r = Std.int(((col >> 16) & 0xff) * f);
        var g = Std.int(((col >> 8) & 0xff) * f);
        var b = Std.int((col & 0xff) * f);
        return (0xff << 24) | (r << 16) | (g << 8) | b;
    }

	inline function sampleTexture(texture:BitmapData, texX:Float, texY:Float):Int
	{
		var x = Std.int(texX * texture.width) % texture.width;
		var y = Std.int(texY * texture.height) % texture.height;
		if (x < 0)
			x += texture.width;
		if (y < 0)
			y += texture.height;
		return texture.getPixel32(x, y);
	}

	function getTextureForWallType(wallType:Int):BitmapData
	{
		if (Assets.brickTexture != null)
		{
			return Assets.brickTexture.bitmap;
		}
		return null;
	}
	
	function renderTexturedCeiling(W:Int, half:Int, px:Float, py:Float, pa:Float):Void
	{
		if (Assets.skyTexture == null)
		{
			bmd.fillRect(new Rectangle(0, 0, W, half), GameConfig.COL_CEIL);
			return;
		}
		
		var skyBitmap = Assets.skyTexture.bitmap;
		var skyWidth = skyBitmap.width;
		var skyHeight = skyBitmap.height;

		for (x in 0...W)
		{
			for (y in 0...half)
			{
				var skyX = Std.int((x + pa * 100) % skyWidth);
				if (skyX < 0) skyX += skyWidth;
				var skyY = Std.int((y / half) * skyHeight);
				
				var skyColor = skyBitmap.getPixel32(skyX, skyY);
				bmd.setPixel32(x, y, skyColor);
			}
		}
	}
	
	function renderTexturedFloor(W:Int, half:Int, H:Int, px:Float, py:Float, pa:Float):Void
	{
		if (Assets.grassTexture == null)
		{
			bmd.fillRect(new Rectangle(0, half, W, half), GameConfig.COL_FLOOR);
			return;
		}
		
		var grassBitmap = Assets.grassTexture.bitmap;

		for (x in 0...W)
		{
			for (y in half...H)
			{
				var grassX = x % grassBitmap.width;
				var grassY = (y - half) % grassBitmap.height;
				
				var grassColor = grassBitmap.getPixel32(grassX, grassY);
				bmd.setPixel32(x, y, grassColor);
			}
		}
	}


    public function renderScene(px:Float, py:Float, pa:Float, enemies:Array<Enemy>):Void {
        var W = GameConfig.SCREEN_W;
        var H = GameConfig.SCREEN_H;
        var half = H >> 1;

		bmd.lock();
        renderTexturedCeiling(W, half, px, py, pa);
        renderTexturedFloor(W, half, H, px, py, pa);

        var halfFov = GameConfig.FOV * 0.5;
        var planeX = Math.cos(pa + Math.PI / 2) * Math.tan(halfFov);
        var planeY = Math.sin(pa + Math.PI / 2) * Math.tan(halfFov);
        var dirX = Math.cos(pa);
        var dirY = Math.sin(pa);

        for (xpix in 0...W) {
            var camX = (2 * xpix / W) - 1;
            var rayDirX = dirX + planeX * camX;
            var rayDirY = dirY + planeY * camX;

            var mapX = Std.int(px);
            var mapY = Std.int(py);
            var deltaDistX = (rayDirX == 0) ? 1e30 : Math.abs(1 / rayDirX);
            var deltaDistY = (rayDirY == 0) ? 1e30 : Math.abs(1 / rayDirY);

            var stepX = 0, stepY = 0;
            var sideDistX = 0.0, sideDistY = 0.0;

            if (rayDirX < 0) { stepX = -1; sideDistX = (px - mapX) * deltaDistX; }
            else { stepX = 1; sideDistX = (mapX + 1.0 - px) * deltaDistX; }
            if (rayDirY < 0) { stepY = -1; sideDistY = (py - mapY) * deltaDistY; }
            else { stepY = 1; sideDistY = (mapY + 1.0 - py) * deltaDistY; }

            var hit = false;
            var side = 0;
            while (!hit) {
                if (sideDistX < sideDistY) { sideDistX += deltaDistX; mapX += stepX; side = 0; }
                else { sideDistY += deltaDistY; mapY += stepY; side = 1; }
                if (LevelData.isWall(mapX, mapY)) hit = true;
                if (mapX < 0 || mapY < 0 || mapY >= map.length || mapX >= map[0].length) hit = true;
            }

            var perpWallDist = (side == 0)
                ? (mapX - px + (1 - stepX) / 2) / (rayDirX == 0 ? 1e-6 : rayDirX)
                : (mapY - py + (1 - stepY) / 2) / (rayDirY == 0 ? 1e-6 : rayDirY);
            if (perpWallDist < 0.0001) perpWallDist = 0.0001;

            var lineH = Std.int(H / perpWallDist);
            if (lineH > H) lineH = H;
			var startY = Std.int(-lineH / 2 + half);
			var endY = Std.int(lineH / 2 + half);
            if (startY < 0) startY = 0;
            if (endY >= H) endY = H - 1;

			var wallType = LevelData.getWallType(mapX, mapY);
			var texture:BitmapData = getTextureForWallType(wallType);

			if (texture != null)
			{
				var wallX:Float;
				if (side == 0)
				{
					wallX = py + perpWallDist * rayDirY;
				}
				else
				{
					wallX = px + perpWallDist * rayDirX;
				}
				wallX -= Math.floor(wallX);

				var texX = Std.int(wallX * texture.width);
				if ((side == 0 && rayDirX > 0) || (side == 1 && rayDirY < 0))
				{
					texX = texture.width - texX - 1;
				}

				var y:Int = startY;
				while (y <= endY)
				{
					var texY = Std.int((y - startY) / (endY - startY + 1) * texture.height);
					var texColor = texture.getPixel32(texX, texY);
					var shadedColor = shade(texColor, perpWallDist);
					bmd.setPixel32(xpix, y, shadedColor);
					y++;
				}
			}
			else
			{
				var wallCol = shade(GameConfig.COL_WALL, perpWallDist);
				bmd.fillRect(new Rectangle(xpix, startY, 1, endY - startY + 1), wallCol);
			}

            zbuf[xpix] = perpWallDist;
        }

        bmd.unlock();
        dirty = true;
        flash -= 0.05;
        if (flash < 0) flash = 0;
    }
}

