if (!_minisound) var _minisound = {};
if (!_minisound.loader) _minisound.loader = {};

_minisound.loader.load = function () {
    return new Promise(
        (resolve, reject) => {
            const minisound_web_js = document.createElement("script");
            minisound_web_js.src = "assets/packages/minisound_web/build/minisound_web.js";
            minisound_web_js.onerror = reject;
            minisound_web_js.onload = () => {
                if (runtimeInitialized) resolve();
                Module.onRuntimeInitialized = resolve;
            };
            document.head.append(minisound_web_js);
        }
    );
}
