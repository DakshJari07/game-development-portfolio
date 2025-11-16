package ui;

import Math;
import core.GameConfig;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class GunOverlay extends FlxSprite {
    var recoil:Float = 0;
    var muzzleFlash:Float = 0;

    public function new() {
        super();
        makeGraphic(GameConfig.SCREEN_W, GameConfig.SCREEN_H, 0x00000000, true);
        scrollFactor.set(0, 0);
    }

	public function updateGun(elapsed:Float):Void
	{
        recoil = Math.max(0, recoil - elapsed * 4);
        muzzleFlash = Math.max(0, muzzleFlash - elapsed * 8);

        var bmd = pixels;
        bmd.lock();
        bmd.fillRect(new Rectangle(0, 0, width, height), 0x00000000);

        var cx:Int = Std.int(GameConfig.SCREEN_W / 2);
        var cy:Int = Std.int(GameConfig.SCREEN_H - 70 + recoil * 6);

        drawBox(bmd, cx - 40, cy + 20, 80, 45, 0xffffffff);
        drawOutline(bmd, cx - 40, cy + 20, 80, 45, 0xff000000);

        drawBox(bmd, cx - 15, cy - 10, 30, 30, 0xff222222);
        drawOutline(bmd, cx - 15, cy - 10, 30, 30, 0xff000000);

        drawBox(bmd, cx - 25, cy - 35, 50, 25, 0xff444444);
        drawOutline(bmd, cx - 25, cy - 35, 50, 25, 0xff000000);

        drawBox(bmd, cx - 6, cy - 45, 12, 10, 0xffcc0000);
        drawOutline(bmd, cx - 6, cy - 45, 12, 10, 0xff000000);

        if (muzzleFlash > 0.1) {
            var flash:Int = Std.int(10 + muzzleFlash * 15);
            var fx:Int = Std.int(cx - flash / 2);
            var fy:Int = Std.int(cy - 55 - flash);
            drawBox(bmd, fx, fy, flash, flash, 0xffffff00);
        }

        bmd.unlock();
        dirty = true;
    }

    inline function drawBox(bmd:BitmapData, x:Int, y:Int, w:Int, h:Int, color:Int):Void {
        bmd.fillRect(new Rectangle(x, y, w, h), color);
    }

    inline function drawOutline(bmd:BitmapData, x:Int, y:Int, w:Int, h:Int, color:Int):Void {
        for (i in 0...w) {
            bmd.setPixel32(x + i, y, color);
            bmd.setPixel32(x + i, y + h - 1, color);
        }
        for (j in 0...h) {
            bmd.setPixel32(x, y + j, color);
            bmd.setPixel32(x + w - 1, y + j, color);
        }
    }

    public function shootRecoil():Void {
        recoil = 1.0;
        muzzleFlash = 1.0;
    }
}

