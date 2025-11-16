package entities;

import Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class BulletLightBlaster extends FlxSprite
{
	public var damage:Int;
	public var speed:Float = 700;
	
	public function new(x:Float, y:Float, spreadAngle:Float = 0, bulletDamage:Int = 25)
	{
		super(x, y);
		
		damage = bulletDamage;
		
		loadGraphic(Assets.bulletGraphic);
		scale.set(1.0, 1.0);
		updateHitbox();

		x -= width / 2;
		y -= height / 2;
		
		var angleRad = (spreadAngle + 90) * Math.PI / 180;
		velocity.x = Math.cos(angleRad) * speed;
		velocity.y = Math.sin(angleRad) * speed;
		
		angularVelocity = 360;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (y < -height || y > FlxG.height + height || x < -width || x > FlxG.width + width)
		{
			kill();
		}
	}
	
	public function hit():Void
	{
		createHitEffect();
		kill();
	}
	
	private function createHitEffect():Void
	{
		var effect = new FlxSprite(x - 5, y - 5);
		effect.makeGraphic(14, 14, FlxColor.RED);
		FlxG.state.add(effect);

		FlxTween.tween(effect, {alpha: 0}, 0.2, {
			onComplete: function(_) {
				effect.kill();
			}
		});
	}
}

