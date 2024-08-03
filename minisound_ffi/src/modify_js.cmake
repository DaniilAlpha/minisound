# modify_js.cmake
file(READ "${MAIN_LIB}.js" JS_CONTENT)
string(REPLACE 
    "audioWorklet.addModule(\"${MAIN_LIB}.aw.js\")" 
    "audioWorklet.addModule(locateFile(\"${MAIN_LIB}.aw.js\"))" 
    MODIFIED_JS_CONTENT "${JS_CONTENT}"
)
file(WRITE "${MAIN_LIB}.js" "${MODIFIED_JS_CONTENT}")
