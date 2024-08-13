# modify_js.cmake.in
file(READ "minisound_web.js" JS_CONTENT)
string(REPLACE 
    "audioWorklet.addModule(\"minisound_web.aw.js\")" 
    "audioWorklet.addModule(locateFile(\"minisound_web.aw.js\"))" 
    MODIFIED_JS_CONTENT "${JS_CONTENT}"
)
file(WRITE "minisound_web.js" "${MODIFIED_JS_CONTENT}")
