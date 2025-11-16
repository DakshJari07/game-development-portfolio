package core;

#if html5
import js.Syntax;
#end

class MouseLock {
    public static function enable():Void {
        #if html5
        Syntax.code("
            document.addEventListener('click', function() {
                const el = document.querySelector('canvas') || document.body;
                if (el && el.requestPointerLock) el.requestPointerLock();
            });
        ");
        #end
    }

    public static function installMouseMove():Void {
        #if html5
        Syntax.code("
            window._mouseDX = 0;
            window.addEventListener('mousemove', function(e) {
                if (document.pointerLockElement) {
                    window._mouseDX += e.movementX || 0;
                }
            });
        ");
        #end
    }

    public static function getDX():Float {
        #if html5
        var d = Syntax.code('window._mouseDX || 0');
        Syntax.code('window._mouseDX = 0');
        return d;
        #else
        return 0;
        #end
    }
	public static function disable():Void
	{
		#if html5
		Syntax.code("
            if (document.exitPointerLock) {
                document.exitPointerLock();
            }
        ");
		#end
	}
}

