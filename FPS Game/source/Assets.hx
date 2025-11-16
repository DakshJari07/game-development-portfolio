package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;

class Assets
{
	public static var weaponGraphics:Array<FlxGraphic>;

	public static var muzzleFlashGraphic:FlxGraphic;

	public static var bulletGraphic:FlxGraphic;

	public static var crosshairGraphic:FlxGraphic;

	public static var brickTexture:FlxGraphic;

	public static var skyTexture:FlxGraphic;
	public static var grassTexture:FlxGraphic;

	public static var gruntSound:String = "assets/sounds/grunt1-68324.mp3";

	public static var fireSound:String = "assets/sounds/lmg_fire01.mp3";

	public static var ouchSound:String = "assets/sounds/ouch.mp3";

	public static var gunShotCloseSound:String = "assets/sounds/gun-shot-close.mp3";

	public static var sadSound:String = "assets/sounds/sad.mp3";
	public static var congSound:String = "assets/sounds/cong.mp3";

	public static function loadLightBlasterAssets(
		weaponPath:String = "assets/images/blaster-a.png",
		smokePath:String = "assets/images/smoke.png",
		bulletPath:String = "assets/images/bullet-foam.png",
		crosshairPath:String = "assets/images/crosshair006.png",
			brickPath:String = "assets/images/BRICKS.png",
		skyPath:String = "assets/images/sky.jpg", grassPath:String = "assets/images/grass.jpg"
	):Void
	{
		if (weaponGraphics == null)
			weaponGraphics = [];

		weaponGraphics[0] = FlxG.bitmap.add(weaponPath);

		muzzleFlashGraphic = FlxG.bitmap.add(smokePath);

		bulletGraphic = FlxG.bitmap.add(bulletPath);

		crosshairGraphic = FlxG.bitmap.add(crosshairPath);

		brickTexture = FlxG.bitmap.add(brickPath);

		skyTexture = FlxG.bitmap.add(skyPath);
		grassTexture = FlxG.bitmap.add(grassPath);
		
	}
}

