package entities;

import Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class WeaponLightBlaster extends FlxSprite
{
	public var damage:Int = 25;
	public var fireRate:Float = 0.2;
	public var ammo:Int = 6;
	public var maxAmmo:Int = 24;
	public var reloadTime:Float = 1.0;
	public var spread:Float = 2.0;
	public var isAutomatic:Bool = false;
	
	private var lastFireTime:Float = 0;
	private var isReloading:Bool = false;
	private var reloadStartTime:Float = 0;
	private var baseX:Float;
	private var baseY:Float;
	
	public function new(x:Float, y:Float)
	{
		super(x, y);
		
		baseX = x;
		baseY = y;
		
		loadGraphic(Assets.weaponGraphics[0]);

		scale.set(6.0, 6.0);
		updateHitbox();

		antialiasing = false;
		pixelPerfectRender = true;

		flipX = true;

		scrollFactor.set(0, 0);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (isReloading)
		{
			if (FlxG.game.ticks - reloadStartTime > reloadTime * 1000)
			{
				finishReload();
			}
		}

		var targetX = baseX + (FlxG.mouse.x - FlxG.width/2) * 0.01;
		var targetY = baseY + (FlxG.mouse.y - FlxG.height/2) * 0.008;
		
		x += (targetX - x) * elapsed * 6;
		y += (targetY - y) * elapsed * 6;
		angle += (0 - angle) * elapsed * 12;
	}
	
	public function canFire():Bool
	{
		if (isReloading) return false;
		if (ammo <= 0) return false;
		
		var timeSinceLastFire = (FlxG.game.ticks - lastFireTime) / 1000;
		return timeSinceLastFire >= fireRate;
	}
	
	public function fire():Array<BulletLightBlaster>
	{
		if (!canFire())
		{
			if (ammo <= 0 && !isReloading)
			{
				try
				{
					var sound = FlxG.sound.play("assets/sounds/empty_click.mp3");
					if (sound != null)
						sound.volume = 0.4;
				}
				catch (e:Dynamic) {}
			}
			return [];
		}
		
		ammo--;
		lastFireTime = FlxG.game.ticks;
		
		x += 15;
		y += 7.5;
		angle = -5;

		var bullets:Array<BulletLightBlaster> = [];
		var spreadAngle = FlxG.random.float(-spread/2, spread/2);
		var bullet = new BulletLightBlaster(
			FlxG.width/2, 
			FlxG.height/2, 
			spreadAngle,
			damage
		);
		bullets.push(bullet);

		createMuzzleFlash();
		
		return bullets;
	}
	
	private function createMuzzleFlash():Void
	{
		var muzzleFlash = new FlxSprite(x + width * 0.8, y + height * 0.3);
		muzzleFlash.loadGraphic(Assets.muzzleFlashGraphic);
		muzzleFlash.scale.set(2.0, 2.0);
		muzzleFlash.updateHitbox();
		FlxG.state.add(muzzleFlash);

		FlxTween.tween(muzzleFlash, {alpha: 0}, 0.1, {
			onComplete: function(_) {
				muzzleFlash.kill();
			}
		});
	}
	
	public function reload():Bool
	{
		if (isReloading || ammo == 6)
			return false;
		
		var ammoNeeded = 6 - ammo;
		if (maxAmmo <= 0) return false;
		
		isReloading = true;
		reloadStartTime = FlxG.game.ticks;

		FlxTween.tween(this, {y: baseY - 50}, reloadTime * 0.3, {
			onComplete: function(_) {
				FlxTween.tween(this, {y: baseY}, reloadTime * 0.7);
			}
		});
		
		return true;
	}
	
	private function finishReload():Void
	{
		var ammoNeeded = 6 - ammo;
		var ammoToAdd = Std.int(Math.min(ammoNeeded, maxAmmo));
		
		ammo += ammoToAdd;
		maxAmmo -= ammoToAdd;
		isReloading = false;
	}
	
	public function getAmmoString():String
	{
		return ammo + "/" + maxAmmo;
	}
	
	public function getWeaponName():String
	{
		return "LIGHT BLASTER";
	}
}

