package ui;

import core.GameConfig;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HUD extends FlxText {
    public function new() {
        super(8, 8, GameConfig.SCREEN_W - 16, "");
        setFormat(null, 16, FlxColor.WHITE, "left");
        scrollFactor.set(0, 0);
    }

    public function updateHUD(health:Int, enemies:Int, timeLeft:Float, ammo:String = ""):Void {
        var t = Std.string(Math.fround(timeLeft * 10) / 10);
        var ammoDisplay = ammo != "" ? "    Ammo: " + ammo : "";
		text = "HP: " + health + "    Time: " + t + ammoDisplay;
    }
}

