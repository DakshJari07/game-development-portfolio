package core;

class GameConfig {
    public static inline var SCREEN_W:Int = 960;
    public static inline var SCREEN_H:Int = 600;

	public static var FOV:Float = Math.PI / 3;
    public static inline var MAX_DIST:Float = 30;
	public static inline var MOVE_SPEED:Float = 3.2;
	public static inline var SPRINT_MULTIPLIER:Float = 1.8;
	public static inline var ROT_SPEED:Float = 2.6;
	public static inline var ENEMY_SPEED:Float = 1.6;
	public static inline var TIMER_START:Float = 20.0;
    public static inline var MIN_ENEMIES:Int = 5;

    public static inline var COL_WALL:Int  = 0xff4f83ff;
    public static inline var COL_FLOOR:Int = 0xff0e1626;
    public static inline var COL_CEIL:Int  = 0xff0a0f1d;
    public static inline var COL_ENEMY:Int = 0xffef5350;
    public static inline var COL_BG:Int    = 0xff000000;
}

