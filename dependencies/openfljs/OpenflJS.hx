
import sys.io.File;

using StringTools;

class OpenflJS
{
	public static var exportFile:String = "Export/html5/bin/openfl.js";

	// Prevent default ApplicationMain and DefaultAssetLibrary to shadow the user's
	public static function excludeFromOpenflJS () {

		haxe.macro.Compiler.exclude("ApplicationMain");
		haxe.macro.Compiler.exclude("DefaultAssetLibrary");

	}

	// Post-fix the openfl.js file with proper exposing
	public static function main () {
		var prog = ~/\$hxClasses\["(.*?)"\]/g;

		var lib = File.getContent(exportFile);

		var paths = new Map<String, Bool>();
		var packages = new Array<String>();

		paths.set("lime", true);
		paths.set("openfl", true);

		packages.push("$hx_exports.lime = $hx_exports.lime || {};");

		lib = prog.map(lib, function (e:EReg) {

			var className = e.matched(1);

			if (className.startsWith("lime.") || className.startsWith("openfl.")) {

				var classPath = className.split(".");
				classPath.pop();

				var name;

				for (i in 0...classPath.length) {

					name = classPath.slice(0, i+1).join(".");

					if (!paths.exists(name)) {

						paths.set(name, true);
						packages.push('$$hx_exports.$name = $$hx_exports.$name || {};');

					}

				}

				return '$$hxClasses["$className"] = $$hx_exports.$className';

			} else {

				// ignore
				return '$$hxClasses["$className"]';

			}

		});

		var prog = ~/\$hx_exports\.lime = \$hx_exports\.lime \|\| {};/;

		lib = prog.replace(lib, packages.join("\n"));

		var appMain = ~/^ApplicationMain\.main\(\);/m;

		lib = appMain.replace(lib, "");

		File.saveContent(exportFile, lib);

	}
}