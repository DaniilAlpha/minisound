function GROWABLE_HEAP_I8(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAP8}function GROWABLE_HEAP_U8(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAPU8}function GROWABLE_HEAP_I32(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAP32}function GROWABLE_HEAP_U32(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAPU32}function GROWABLE_HEAP_F32(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAPF32}function GROWABLE_HEAP_F64(){if(wasmMemory.buffer!=HEAP8.buffer){updateMemoryViews()}return HEAPF64}var Module=globalThis.Module||(typeof Module!="undefined"?Module:{});var ENVIRONMENT_IS_WEB=typeof window=="object";var ENVIRONMENT_IS_WORKER=typeof importScripts=="function";var ENVIRONMENT_IS_NODE=typeof process=="object"&&typeof process.versions=="object"&&typeof process.versions.node=="string";if(ENVIRONMENT_IS_NODE){var worker_threads=require("worker_threads");global.Worker=worker_threads.Worker;ENVIRONMENT_IS_WORKER=!worker_threads.isMainThread}var ENVIRONMENT_IS_WASM_WORKER=Module["$ww"];var moduleOverrides=Object.assign({},Module);var arguments_=[];var thisProgram="./this.program";var quit_=(status,toThrow)=>{throw toThrow};var _scriptName=typeof document!="undefined"?document.currentScript?.src:undefined;if(ENVIRONMENT_IS_NODE){_scriptName=__filename}else if(ENVIRONMENT_IS_WORKER){_scriptName=self.location.href}var scriptDirectory="";function locateFile(path){if(Module["locateFile"]){return Module["locateFile"](path,scriptDirectory)}return scriptDirectory+path}var read_,readAsync,readBinary;if(ENVIRONMENT_IS_NODE){var fs=require("fs");var nodePath=require("path");scriptDirectory=__dirname+"/";read_=(filename,binary)=>{filename=isFileURI(filename)?new URL(filename):nodePath.normalize(filename);return fs.readFileSync(filename,binary?undefined:"utf8")};readBinary=filename=>{var ret=read_(filename,true);if(!ret.buffer){ret=new Uint8Array(ret)}return ret};readAsync=(filename,onload,onerror,binary=true)=>{filename=isFileURI(filename)?new URL(filename):nodePath.normalize(filename);fs.readFile(filename,binary?undefined:"utf8",(err,data)=>{if(err)onerror(err);else onload(binary?data.buffer:data)})};if(!Module["thisProgram"]&&process.argv.length>1){thisProgram=process.argv[1].replace(/\\/g,"/")}arguments_=process.argv.slice(2);if(typeof module!="undefined"){module["exports"]=Module}process.on("uncaughtException",ex=>{if(ex!=="unwind"&&!(ex instanceof ExitStatus)&&!(ex.context instanceof ExitStatus)){throw ex}});quit_=(status,toThrow)=>{process.exitCode=status;throw toThrow}}else if(ENVIRONMENT_IS_WEB||ENVIRONMENT_IS_WORKER){if(ENVIRONMENT_IS_WORKER){scriptDirectory=self.location.href}else if(typeof document!="undefined"&&document.currentScript){scriptDirectory=document.currentScript.src}if(scriptDirectory.startsWith("blob:")){scriptDirectory=""}else{scriptDirectory=scriptDirectory.substr(0,scriptDirectory.replace(/[?#].*/,"").lastIndexOf("/")+1)}{read_=url=>{var xhr=new XMLHttpRequest;xhr.open("GET",url,false);xhr.send(null);return xhr.responseText};if(ENVIRONMENT_IS_WORKER){readBinary=url=>{var xhr=new XMLHttpRequest;xhr.open("GET",url,false);xhr.responseType="arraybuffer";xhr.send(null);return new Uint8Array(xhr.response)}}readAsync=(url,onload,onerror)=>{if(isFileURI(url)){var xhr=new XMLHttpRequest;xhr.open("GET",url,true);xhr.responseType="arraybuffer";xhr.onload=()=>{if(xhr.status==200||xhr.status==0&&xhr.response){onload(xhr.response);return}onerror()};xhr.onerror=onerror;xhr.send(null);return}fetch(url,{credentials:"same-origin"}).then(response=>{if(response.ok){return response.arrayBuffer()}return Promise.reject(new Error(response.status+" : "+response.url))}).then(onload,onerror)}}}else{}var out=Module["print"]||console.log.bind(console);var err=Module["printErr"]||console.error.bind(console);Object.assign(Module,moduleOverrides);moduleOverrides=null;if(Module["arguments"])arguments_=Module["arguments"];if(Module["thisProgram"])thisProgram=Module["thisProgram"];if(Module["quit"])quit_=Module["quit"];var wasmBinary;if(Module["wasmBinary"])wasmBinary=Module["wasmBinary"];var wasmMemory;var wasmModule;var ABORT=false;var EXITSTATUS;var HEAP8,HEAPU8,HEAP16,HEAPU16,HEAP32,HEAPU32,HEAPF32,HEAPF64;function updateMemoryViews(){var b=wasmMemory.buffer;Module["HEAP8"]=HEAP8=new Int8Array(b);Module["HEAP16"]=HEAP16=new Int16Array(b);Module["HEAPU8"]=HEAPU8=new Uint8Array(b);Module["HEAPU16"]=HEAPU16=new Uint16Array(b);Module["HEAP32"]=HEAP32=new Int32Array(b);Module["HEAPU32"]=HEAPU32=new Uint32Array(b);Module["HEAPF32"]=HEAPF32=new Float32Array(b);Module["HEAPF64"]=HEAPF64=new Float64Array(b)}if(Module["wasmMemory"]){wasmMemory=Module["wasmMemory"]}else{var INITIAL_MEMORY=Module["INITIAL_MEMORY"]||16777216;wasmMemory=new WebAssembly.Memory({initial:INITIAL_MEMORY/65536,maximum:1073741824/65536,shared:true});if(!(wasmMemory.buffer instanceof SharedArrayBuffer)){err("requested a shared WebAssembly.Memory but the returned buffer is not a SharedArrayBuffer, indicating that while the browser has SharedArrayBuffer it does not have WebAssembly threads support - you may need to set a flag");if(ENVIRONMENT_IS_NODE){err("(on node you may need: --experimental-wasm-threads --experimental-wasm-bulk-memory and/or recent version)")}throw Error("bad memory")}}updateMemoryViews();function writeStackCookie(){var max=_emscripten_stack_get_end();if(max==0){max+=4}GROWABLE_HEAP_U32()[max>>2]=34821223;GROWABLE_HEAP_U32()[max+4>>2]=2310721022;GROWABLE_HEAP_U32()[0>>2]=1668509029}function checkStackCookie(){if(ABORT)return;var max=_emscripten_stack_get_end();if(max==0){max+=4}var cookie1=GROWABLE_HEAP_U32()[max>>2];var cookie2=GROWABLE_HEAP_U32()[max+4>>2];if(cookie1!=34821223||cookie2!=2310721022){abort(`Stack overflow! Stack cookie has been overwritten at ${ptrToString(max)}, expected hex dwords 0x89BACDFE and 0x2135467, but received ${ptrToString(cookie2)} ${ptrToString(cookie1)}`)}if(GROWABLE_HEAP_U32()[0>>2]!=1668509029){abort("Runtime error: The application has corrupted its heap memory area (address zero)!")}}var __ATPRERUN__=[];var __ATINIT__=[];var __ATPOSTRUN__=[];var runtimeInitialized=false;function preRun(){if(Module["preRun"]){if(typeof Module["preRun"]=="function")Module["preRun"]=[Module["preRun"]];while(Module["preRun"].length){addOnPreRun(Module["preRun"].shift())}}callRuntimeCallbacks(__ATPRERUN__)}function initRuntime(){runtimeInitialized=true;if(ENVIRONMENT_IS_WASM_WORKER)return _wasmWorkerInitializeRuntime();checkStackCookie();callRuntimeCallbacks(__ATINIT__)}function postRun(){checkStackCookie();if(Module["postRun"]){if(typeof Module["postRun"]=="function")Module["postRun"]=[Module["postRun"]];while(Module["postRun"].length){addOnPostRun(Module["postRun"].shift())}}callRuntimeCallbacks(__ATPOSTRUN__)}function addOnPreRun(cb){__ATPRERUN__.unshift(cb)}function addOnInit(cb){__ATINIT__.unshift(cb)}function addOnPostRun(cb){__ATPOSTRUN__.unshift(cb)}var runDependencies=0;var runDependencyWatcher=null;var dependenciesFulfilled=null;function addRunDependency(id){runDependencies++;Module["monitorRunDependencies"]?.(runDependencies)}function removeRunDependency(id){runDependencies--;Module["monitorRunDependencies"]?.(runDependencies);if(runDependencies==0){if(runDependencyWatcher!==null){clearInterval(runDependencyWatcher);runDependencyWatcher=null}if(dependenciesFulfilled){var callback=dependenciesFulfilled;dependenciesFulfilled=null;callback()}}}function abort(what){Module["onAbort"]?.(what);what="Aborted("+what+")";err(what);ABORT=true;EXITSTATUS=1;what+=". Build with -sASSERTIONS for more info.";var e=new WebAssembly.RuntimeError(what);throw e}var dataURIPrefix="data:application/octet-stream;base64,";var isDataURI=filename=>filename.startsWith(dataURIPrefix);var isFileURI=filename=>filename.startsWith("file://");function findWasmBinary(){var f="minisound_web.wasm";if(!isDataURI(f)){return locateFile(f)}return f}var wasmBinaryFile;function getBinarySync(file){if(file==wasmBinaryFile&&wasmBinary){return new Uint8Array(wasmBinary)}if(readBinary){return readBinary(file)}throw"both async and sync fetching of the wasm failed"}function getBinaryPromise(binaryFile){if(!wasmBinary){return new Promise((resolve,reject)=>{readAsync(binaryFile,response=>resolve(new Uint8Array(response)),error=>{try{resolve(getBinarySync(binaryFile))}catch(e){reject(e)}})})}return Promise.resolve().then(()=>getBinarySync(binaryFile))}function instantiateArrayBuffer(binaryFile,imports,receiver){return getBinaryPromise(binaryFile).then(binary=>WebAssembly.instantiate(binary,imports)).then(receiver,reason=>{err(`failed to asynchronously prepare wasm: ${reason}`);abort(reason)})}function instantiateAsync(binary,binaryFile,imports,callback){if(!binary&&typeof WebAssembly.instantiateStreaming=="function"&&!isDataURI(binaryFile)&&!isFileURI(binaryFile)&&!ENVIRONMENT_IS_NODE&&typeof fetch=="function"){return fetch(binaryFile,{credentials:"same-origin"}).then(response=>{var result=WebAssembly.instantiateStreaming(response,imports);return result.then(callback,function(reason){err(`wasm streaming compile failed: ${reason}`);err("falling back to ArrayBuffer instantiation");return instantiateArrayBuffer(binaryFile,imports,callback)})})}return instantiateArrayBuffer(binaryFile,imports,callback)}function getWasmImports(){return{a:wasmImports}}function createWasm(){var info=getWasmImports();function receiveInstance(instance,module){wasmExports=instance.exports;wasmExports=Asyncify.instrumentWasmExports(wasmExports);wasmTable=wasmExports["R"];Module["wasmTable"]=wasmTable;addOnInit(wasmExports["u"]);wasmModule=module;removeRunDependency("wasm-instantiate");return wasmExports}addRunDependency("wasm-instantiate");function receiveInstantiationResult(result){receiveInstance(result["instance"],result["module"])}if(Module["instantiateWasm"]){try{return Module["instantiateWasm"](info,receiveInstance)}catch(e){err(`Module.instantiateWasm callback failed with error: ${e}`);return false}}if(!wasmBinaryFile)wasmBinaryFile=findWasmBinary();instantiateAsync(wasmBinary,wasmBinaryFile,info,receiveInstantiationResult);return{}}var ASM_CONSTS={40388:($0,$1,$2,$3,$4)=>{if(typeof window==="undefined"||(window.AudioContext||window.webkitAudioContext)===undefined){return 0}if(typeof window.miniaudio==="undefined"){window.miniaudio={referenceCount:0};window.miniaudio.device_type={};window.miniaudio.device_type.playback=$0;window.miniaudio.device_type.capture=$1;window.miniaudio.device_type.duplex=$2;window.miniaudio.device_state={};window.miniaudio.device_state.stopped=$3;window.miniaudio.device_state.started=$4;miniaudio.devices=[];miniaudio.track_device=function(device){for(var iDevice=0;iDevice<miniaudio.devices.length;++iDevice){if(miniaudio.devices[iDevice]==null){miniaudio.devices[iDevice]=device;return iDevice}}miniaudio.devices.push(device);return miniaudio.devices.length-1};miniaudio.untrack_device_by_index=function(deviceIndex){miniaudio.devices[deviceIndex]=null;while(miniaudio.devices.length>0){if(miniaudio.devices[miniaudio.devices.length-1]==null){miniaudio.devices.pop()}else{break}}};miniaudio.untrack_device=function(device){for(var iDevice=0;iDevice<miniaudio.devices.length;++iDevice){if(miniaudio.devices[iDevice]==device){return miniaudio.untrack_device_by_index(iDevice)}}};miniaudio.get_device_by_index=function(deviceIndex){return miniaudio.devices[deviceIndex]};miniaudio.unlock_event_types=function(){return["touchend","click"]}();miniaudio.unlock=function(){for(var i=0;i<miniaudio.devices.length;++i){var device=miniaudio.devices[i];if(device!=null&&device.webaudio!=null&&device.state===window.miniaudio.device_state.started){device.webaudio.resume().then(()=>{Module._ma_device__on_notification_unlocked(device.pDevice)},error=>{console.error("Failed to resume audiocontext",error)})}}miniaudio.unlock_event_types.map(function(event_type){document.removeEventListener(event_type,miniaudio.unlock,true)})};miniaudio.unlock_event_types.map(function(event_type){document.addEventListener(event_type,miniaudio.unlock,true)})}window.miniaudio.referenceCount+=1;return 1},42546:()=>{if(typeof window.miniaudio!=="undefined"){window.miniaudio.referenceCount-=1;if(window.miniaudio.referenceCount===0){delete window.miniaudio}}},42710:()=>navigator.mediaDevices!==undefined&&navigator.mediaDevices.getUserMedia!==undefined,42814:()=>{try{var temp=new(window.AudioContext||window.webkitAudioContext);var sampleRate=temp.sampleRate;temp.close();return sampleRate}catch(e){return 0}},42985:$0=>miniaudio.track_device({webaudio:emscriptenGetAudioObject($0),state:1}),43074:($0,$1)=>{var getUserMediaResult=0;var audioWorklet=emscriptenGetAudioObject($0);var audioContext=emscriptenGetAudioObject($1);navigator.mediaDevices.getUserMedia({audio:true,video:false}).then(function(stream){audioContext.streamNode=audioContext.createMediaStreamSource(stream);audioContext.streamNode.connect(audioWorklet);audioWorklet.connect(audioContext.destination);getUserMediaResult=0}).catch(function(error){console.log("navigator.mediaDevices.getUserMedia Failed: "+error);getUserMediaResult=-1});return getUserMediaResult},43636:($0,$1)=>{var audioWorklet=emscriptenGetAudioObject($0);var audioContext=emscriptenGetAudioObject($1);audioWorklet.connect(audioContext.destination);return 0},43796:$0=>emscriptenGetAudioObject($0).sampleRate,43848:$0=>{var device=miniaudio.get_device_by_index($0);if(device.streamNode!==undefined){device.streamNode.disconnect();device.streamNode=undefined}},44004:$0=>{miniaudio.untrack_device_by_index($0)},44047:$0=>{var device=miniaudio.get_device_by_index($0);device.webaudio.resume();device.state=miniaudio.device_state.started},44172:$0=>{var device=miniaudio.get_device_by_index($0);device.webaudio.suspend();device.state=miniaudio.device_state.stopped}};function ExitStatus(status){this.name="ExitStatus";this.message=`Program terminated with exit(${status})`;this.status=status}var _wasmWorkerDelayedMessageQueue=[];var wasmTableMirror=[];var wasmTable;var getWasmTableEntry=funcPtr=>{var func=wasmTableMirror[funcPtr];if(!func){if(funcPtr>=wasmTableMirror.length)wasmTableMirror.length=funcPtr+1;wasmTableMirror[funcPtr]=func=wasmTable.get(funcPtr)}return func};var _wasmWorkerRunPostMessage=e=>{let data=ENVIRONMENT_IS_NODE?e:e.data;let wasmCall=data["_wsc"];wasmCall&&getWasmTableEntry(wasmCall)(...data["x"])};var _wasmWorkerAppendToQueue=e=>{_wasmWorkerDelayedMessageQueue.push(e)};var _wasmWorkerInitializeRuntime=()=>{let m=Module;__emscripten_wasm_worker_initialize(m["sb"],m["sz"]);if(typeof AudioWorkletGlobalScope==="undefined"){removeEventListener("message",_wasmWorkerAppendToQueue);_wasmWorkerDelayedMessageQueue=_wasmWorkerDelayedMessageQueue.forEach(_wasmWorkerRunPostMessage);addEventListener("message",_wasmWorkerRunPostMessage)}};var callRuntimeCallbacks=callbacks=>{while(callbacks.length>0){callbacks.shift()(Module)}};var noExitRuntime=Module["noExitRuntime"]||true;var ptrToString=ptr=>{ptr>>>=0;return"0x"+ptr.toString(16).padStart(8,"0")};var stackRestore=val=>__emscripten_stack_restore(val);var stackSave=()=>_emscripten_stack_get_current();var UTF8ArrayToString=(heapOrArray,idx,maxBytesToRead)=>{var endIdx=idx+maxBytesToRead;var str="";while(!(idx>=endIdx)){var u0=heapOrArray[idx++];if(!u0)return str;if(!(u0&128)){str+=String.fromCharCode(u0);continue}var u1=heapOrArray[idx++]&63;if((u0&224)==192){str+=String.fromCharCode((u0&31)<<6|u1);continue}var u2=heapOrArray[idx++]&63;if((u0&240)==224){u0=(u0&15)<<12|u1<<6|u2}else{u0=(u0&7)<<18|u1<<12|u2<<6|heapOrArray[idx++]&63}if(u0<65536){str+=String.fromCharCode(u0)}else{var ch=u0-65536;str+=String.fromCharCode(55296|ch>>10,56320|ch&1023)}}return str};var UTF8ToString=(ptr,maxBytesToRead)=>ptr?UTF8ArrayToString(GROWABLE_HEAP_U8(),ptr,maxBytesToRead):"";var ___assert_fail=(condition,filename,line,func)=>{abort(`Assertion failed: ${UTF8ToString(condition)}, at: `+[filename?UTF8ToString(filename):"unknown filename",line,func?UTF8ToString(func):"unknown function"])};var SYSCALLS={varargs:undefined,getStr(ptr){var ret=UTF8ToString(ptr);return ret}};function ___syscall_fcntl64(fd,cmd,varargs){SYSCALLS.varargs=varargs;return 0}var ___syscall_fstat64=(fd,buf)=>{};function ___syscall_ioctl(fd,op,varargs){SYSCALLS.varargs=varargs;return 0}function ___syscall_openat(dirfd,path,flags,varargs){SYSCALLS.varargs=varargs}var readEmAsmArgsArray=[];var readEmAsmArgs=(sigPtr,buf)=>{readEmAsmArgsArray.length=0;var ch;while(ch=GROWABLE_HEAP_U8()[sigPtr++]){var wide=ch!=105;wide&=ch!=112;buf+=wide&&buf%8?4:0;readEmAsmArgsArray.push(ch==112?GROWABLE_HEAP_U32()[buf>>2]:ch==105?GROWABLE_HEAP_I32()[buf>>2]:GROWABLE_HEAP_F64()[buf>>3]);buf+=wide?8:4}return readEmAsmArgsArray};var runEmAsmFunction=(code,sigPtr,argbuf)=>{var args=readEmAsmArgs(sigPtr,argbuf);return ASM_CONSTS[code](...args)};var _emscripten_asm_const_int=(code,sigPtr,argbuf)=>runEmAsmFunction(code,sigPtr,argbuf);var EmAudio={};var EmAudioCounter=0;var emscriptenRegisterAudioObject=object=>{EmAudio[++EmAudioCounter]=object;return EmAudioCounter};var emscriptenGetAudioObject=objectHandle=>EmAudio[objectHandle];var _emscripten_create_audio_context=options=>{let ctx=window.AudioContext||window.webkitAudioContext;options>>=2;let opts=options?{latencyHint:GROWABLE_HEAP_U32()[options]?UTF8ToString(GROWABLE_HEAP_U32()[options]):void 0,sampleRate:GROWABLE_HEAP_I32()[options+1]||void 0}:void 0;return ctx&&emscriptenRegisterAudioObject(new ctx(opts))};var _emscripten_create_wasm_audio_worklet_node=(contextHandle,name,options,callback,userData)=>{options>>=2;function readChannelCountArray(heapIndex,numOutputs){let channelCounts=[];while(numOutputs--)channelCounts.push(GROWABLE_HEAP_U32()[heapIndex++]);return channelCounts}let opts=options?{numberOfInputs:GROWABLE_HEAP_I32()[options],numberOfOutputs:GROWABLE_HEAP_I32()[options+1],outputChannelCount:GROWABLE_HEAP_U32()[options+2]?readChannelCountArray(GROWABLE_HEAP_U32()[options+2]>>2,GROWABLE_HEAP_I32()[options+1]):void 0,processorOptions:{cb:callback,ud:userData}}:void 0;return emscriptenRegisterAudioObject(new AudioWorkletNode(EmAudio[contextHandle],UTF8ToString(name),opts))};var _emscripten_create_wasm_audio_worklet_processor_async=(contextHandle,options,callback,userData)=>{options>>=2;let audioParams=[],numAudioParams=GROWABLE_HEAP_U32()[options+1],audioParamDescriptors=GROWABLE_HEAP_U32()[options+2]>>2,i=0;while(numAudioParams--){audioParams.push({name:i++,defaultValue:GROWABLE_HEAP_F32()[audioParamDescriptors++],minValue:GROWABLE_HEAP_F32()[audioParamDescriptors++],maxValue:GROWABLE_HEAP_F32()[audioParamDescriptors++],automationRate:["a","k"][GROWABLE_HEAP_U32()[audioParamDescriptors++]]+"-rate"})}EmAudio[contextHandle].audioWorklet.bootstrapMessage.port.postMessage({_wpn:UTF8ToString(GROWABLE_HEAP_U32()[options]),audioParams:audioParams,contextHandle:contextHandle,callback:callback,userData:userData})};var _emscripten_destroy_audio_context=contextHandle=>{EmAudio[contextHandle].suspend();delete EmAudio[contextHandle]};var _emscripten_destroy_web_audio_node=objectHandle=>{EmAudio[objectHandle].disconnect();delete EmAudio[objectHandle]};var _emscripten_get_now;if(typeof performance!="undefined"&&performance.now){_emscripten_get_now=()=>performance.now()}else{_emscripten_get_now=Date.now}var getHeapMax=()=>1073741824;var growMemory=size=>{var b=wasmMemory.buffer;var pages=(size-b.byteLength+65535)/65536;try{wasmMemory.grow(pages);updateMemoryViews();return 1}catch(e){}};var _emscripten_resize_heap=requestedSize=>{var oldSize=GROWABLE_HEAP_U8().length;requestedSize>>>=0;if(requestedSize<=oldSize){return false}var maxHeapSize=getHeapMax();if(requestedSize>maxHeapSize){return false}var alignUp=(x,multiple)=>x+(multiple-x%multiple)%multiple;for(var cutDown=1;cutDown<=4;cutDown*=2){var overGrownHeapSize=oldSize*(1+.2/cutDown);overGrownHeapSize=Math.min(overGrownHeapSize,requestedSize+100663296);var newSize=Math.min(maxHeapSize,alignUp(Math.max(requestedSize,overGrownHeapSize),65536));var replacement=growMemory(newSize);if(replacement){return true}}return false};var handleException=e=>{if(e instanceof ExitStatus||e=="unwind"){return EXITSTATUS}checkStackCookie();if(e instanceof WebAssembly.RuntimeError){if(_emscripten_stack_get_current()<=0){err("Stack overflow detected.  You can try increasing -sSTACK_SIZE (currently set to 1048576)")}}quit_(1,e)};var runtimeKeepaliveCounter=0;var keepRuntimeAlive=()=>noExitRuntime||runtimeKeepaliveCounter>0;var _proc_exit=code=>{EXITSTATUS=code;if(!keepRuntimeAlive()){Module["onExit"]?.(code);ABORT=true}quit_(code,new ExitStatus(code))};var exitJS=(status,implicit)=>{EXITSTATUS=status;_proc_exit(status)};var _exit=exitJS;var maybeExit=()=>{if(!keepRuntimeAlive()){try{_exit(EXITSTATUS)}catch(e){handleException(e)}}};var callUserCallback=func=>{if(ABORT){return}try{func();maybeExit()}catch(e){handleException(e)}};var safeSetTimeout=(func,timeout)=>setTimeout(()=>{callUserCallback(func)},timeout);var _emscripten_sleep=ms=>Asyncify.handleSleep(wakeUp=>safeSetTimeout(wakeUp,ms));_emscripten_sleep.isAsync=true;var _wasmWorkersID=1;var _EmAudioDispatchProcessorCallback=e=>{let data=e.data;let wasmCall=data["_wsc"];wasmCall&&getWasmTableEntry(wasmCall)(...data["x"])};var _emscripten_start_wasm_audio_worklet_thread_async=(contextHandle,stackLowestAddress,stackSize,callback,userData)=>{let audioContext=EmAudio[contextHandle],audioWorklet=audioContext.audioWorklet;let audioWorkletCreationFailed=()=>{((a1,a2,a3)=>dynCall_viii(callback,a1,a2,a3))(contextHandle,0,userData)};if(!audioWorklet){return audioWorkletCreationFailed()}audioWorklet.addModule(locateFile("minisound_web.aw.js")).then(()=>{audioWorklet.bootstrapMessage=new AudioWorkletNode(audioContext,"message",{processorOptions:{$ww:_wasmWorkersID++,wasm:wasmModule,wasmMemory:wasmMemory,sb:stackLowestAddress,sz:stackSize}});audioWorklet.bootstrapMessage.port.onmessage=_EmAudioDispatchProcessorCallback;return audioWorklet.addModule(Module["mainScriptUrlOrBlob"]||_scriptName)}).then(()=>{((a1,a2,a3)=>dynCall_viii(callback,a1,a2,a3))(contextHandle,1,userData)}).catch(audioWorkletCreationFailed)};var _fd_close=fd=>52;var _fd_read=(fd,iov,iovcnt,pnum)=>52;var convertI32PairToI53Checked=(lo,hi)=>hi+2097152>>>0<4194305-!!lo?(lo>>>0)+hi*4294967296:NaN;function _fd_seek(fd,offset_low,offset_high,whence,newOffset){var offset=convertI32PairToI53Checked(offset_low,offset_high);return 70}var printCharBuffers=[null,[],[]];var printChar=(stream,curr)=>{var buffer=printCharBuffers[stream];if(curr===0||curr===10){(stream===1?out:err)(UTF8ArrayToString(buffer,0));buffer.length=0}else{buffer.push(curr)}};var _fd_write=(fd,iov,iovcnt,pnum)=>{var num=0;for(var i=0;i<iovcnt;i++){var ptr=GROWABLE_HEAP_U32()[iov>>2];var len=GROWABLE_HEAP_U32()[iov+4>>2];iov+=8;for(var j=0;j<len;j++){printChar(fd,GROWABLE_HEAP_U8()[ptr+j])}num+=len}GROWABLE_HEAP_U32()[pnum>>2]=num;return 0};var runAndAbortIfError=func=>{try{return func()}catch(e){abort(e)}};var runtimeKeepalivePush=()=>{runtimeKeepaliveCounter+=1};var runtimeKeepalivePop=()=>{runtimeKeepaliveCounter-=1};var Asyncify={instrumentWasmImports(imports){var importPattern=/^(invoke_.*|__asyncjs__.*)$/;for(let[x,original]of Object.entries(imports)){if(typeof original=="function"){let isAsyncifyImport=original.isAsync||importPattern.test(x)}}},instrumentWasmExports(exports){var ret={};for(let[x,original]of Object.entries(exports)){if(typeof original=="function"){ret[x]=(...args)=>{Asyncify.exportCallStack.push(x);try{return original(...args)}finally{if(!ABORT){var y=Asyncify.exportCallStack.pop();Asyncify.maybeStopUnwind()}}}}else{ret[x]=original}}return ret},State:{Normal:0,Unwinding:1,Rewinding:2,Disabled:3},state:0,StackSize:4096,currData:null,handleSleepReturnValue:0,exportCallStack:[],callStackNameToId:{},callStackIdToName:{},callStackId:0,asyncPromiseHandlers:null,sleepCallbacks:[],getCallStackId(funcName){var id=Asyncify.callStackNameToId[funcName];if(id===undefined){id=Asyncify.callStackId++;Asyncify.callStackNameToId[funcName]=id;Asyncify.callStackIdToName[id]=funcName}return id},maybeStopUnwind(){if(Asyncify.currData&&Asyncify.state===Asyncify.State.Unwinding&&Asyncify.exportCallStack.length===0){Asyncify.state=Asyncify.State.Normal;runAndAbortIfError(_asyncify_stop_unwind);if(typeof Fibers!="undefined"){Fibers.trampoline()}}},whenDone(){return new Promise((resolve,reject)=>{Asyncify.asyncPromiseHandlers={resolve:resolve,reject:reject}})},allocateData(){var ptr=_malloc(12+Asyncify.StackSize);Asyncify.setDataHeader(ptr,ptr+12,Asyncify.StackSize);Asyncify.setDataRewindFunc(ptr);return ptr},setDataHeader(ptr,stack,stackSize){GROWABLE_HEAP_U32()[ptr>>2]=stack;GROWABLE_HEAP_U32()[ptr+4>>2]=stack+stackSize},setDataRewindFunc(ptr){var bottomOfCallStack=Asyncify.exportCallStack[0];var rewindId=Asyncify.getCallStackId(bottomOfCallStack);GROWABLE_HEAP_I32()[ptr+8>>2]=rewindId},getDataRewindFuncName(ptr){var id=GROWABLE_HEAP_I32()[ptr+8>>2];var name=Asyncify.callStackIdToName[id];return name},getDataRewindFunc(name){var func=wasmExports[name];return func},doRewind(ptr){var name=Asyncify.getDataRewindFuncName(ptr);var func=Asyncify.getDataRewindFunc(name);return func()},handleSleep(startAsync){if(ABORT)return;if(Asyncify.state===Asyncify.State.Normal){var reachedCallback=false;var reachedAfterCallback=false;startAsync((handleSleepReturnValue=0)=>{if(ABORT)return;Asyncify.handleSleepReturnValue=handleSleepReturnValue;reachedCallback=true;if(!reachedAfterCallback){return}Asyncify.state=Asyncify.State.Rewinding;runAndAbortIfError(()=>_asyncify_start_rewind(Asyncify.currData));if(typeof Browser!="undefined"&&Browser.mainLoop.func){Browser.mainLoop.resume()}var asyncWasmReturnValue,isError=false;try{asyncWasmReturnValue=Asyncify.doRewind(Asyncify.currData)}catch(err){asyncWasmReturnValue=err;isError=true}var handled=false;if(!Asyncify.currData){var asyncPromiseHandlers=Asyncify.asyncPromiseHandlers;if(asyncPromiseHandlers){Asyncify.asyncPromiseHandlers=null;(isError?asyncPromiseHandlers.reject:asyncPromiseHandlers.resolve)(asyncWasmReturnValue);handled=true}}if(isError&&!handled){throw asyncWasmReturnValue}});reachedAfterCallback=true;if(!reachedCallback){Asyncify.state=Asyncify.State.Unwinding;Asyncify.currData=Asyncify.allocateData();if(typeof Browser!="undefined"&&Browser.mainLoop.func){Browser.mainLoop.pause()}runAndAbortIfError(()=>_asyncify_start_unwind(Asyncify.currData))}}else if(Asyncify.state===Asyncify.State.Rewinding){Asyncify.state=Asyncify.State.Normal;runAndAbortIfError(_asyncify_stop_rewind);_free(Asyncify.currData);Asyncify.currData=null;Asyncify.sleepCallbacks.forEach(callUserCallback)}else{abort(`invalid state: ${Asyncify.state}`)}return Asyncify.handleSleepReturnValue},handleAsync(startAsync){return Asyncify.handleSleep(wakeUp=>{startAsync().then(wakeUp)})}};var getCFunc=ident=>{var func=Module["_"+ident];return func};var writeArrayToMemory=(array,buffer)=>{GROWABLE_HEAP_I8().set(array,buffer)};var lengthBytesUTF8=str=>{var len=0;for(var i=0;i<str.length;++i){var c=str.charCodeAt(i);if(c<=127){len++}else if(c<=2047){len+=2}else if(c>=55296&&c<=57343){len+=4;++i}else{len+=3}}return len};var stringToUTF8Array=(str,heap,outIdx,maxBytesToWrite)=>{if(!(maxBytesToWrite>0))return 0;var startIdx=outIdx;var endIdx=outIdx+maxBytesToWrite-1;for(var i=0;i<str.length;++i){var u=str.charCodeAt(i);if(u>=55296&&u<=57343){var u1=str.charCodeAt(++i);u=65536+((u&1023)<<10)|u1&1023}if(u<=127){if(outIdx>=endIdx)break;heap[outIdx++]=u}else if(u<=2047){if(outIdx+1>=endIdx)break;heap[outIdx++]=192|u>>6;heap[outIdx++]=128|u&63}else if(u<=65535){if(outIdx+2>=endIdx)break;heap[outIdx++]=224|u>>12;heap[outIdx++]=128|u>>6&63;heap[outIdx++]=128|u&63}else{if(outIdx+3>=endIdx)break;heap[outIdx++]=240|u>>18;heap[outIdx++]=128|u>>12&63;heap[outIdx++]=128|u>>6&63;heap[outIdx++]=128|u&63}}heap[outIdx]=0;return outIdx-startIdx};var stringToUTF8=(str,outPtr,maxBytesToWrite)=>stringToUTF8Array(str,GROWABLE_HEAP_U8(),outPtr,maxBytesToWrite);var stackAlloc=sz=>__emscripten_stack_alloc(sz);var stringToUTF8OnStack=str=>{var size=lengthBytesUTF8(str)+1;var ret=stackAlloc(size);stringToUTF8(str,ret,size);return ret};var ccall=(ident,returnType,argTypes,args,opts)=>{var toC={string:str=>{var ret=0;if(str!==null&&str!==undefined&&str!==0){ret=stringToUTF8OnStack(str)}return ret},array:arr=>{var ret=stackAlloc(arr.length);writeArrayToMemory(arr,ret);return ret}};function convertReturnValue(ret){if(returnType==="string"){return UTF8ToString(ret)}if(returnType==="boolean")return Boolean(ret);return ret}var func=getCFunc(ident);var cArgs=[];var stack=0;if(args){for(var i=0;i<args.length;i++){var converter=toC[argTypes[i]];if(converter){if(stack===0)stack=stackSave();cArgs[i]=converter(args[i])}else{cArgs[i]=args[i]}}}var previousAsync=Asyncify.currData;var ret=func(...cArgs);function onDone(ret){runtimeKeepalivePop();if(stack!==0)stackRestore(stack);return convertReturnValue(ret)}var asyncMode=opts?.async;runtimeKeepalivePush();if(Asyncify.currData!=previousAsync){return Asyncify.whenDone().then(onDone)}ret=onDone(ret);if(asyncMode)return Promise.resolve(ret);return ret};var wasmImports={b:___assert_fail,h:___syscall_fcntl64,q:___syscall_fstat64,t:___syscall_ioctl,i:___syscall_openat,c:_emscripten_asm_const_int,n:_emscripten_create_audio_context,j:_emscripten_create_wasm_audio_worklet_node,k:_emscripten_create_wasm_audio_worklet_processor_async,e:_emscripten_destroy_audio_context,f:_emscripten_destroy_web_audio_node,d:_emscripten_get_now,p:_emscripten_resize_heap,l:_emscripten_sleep,m:_emscripten_start_wasm_audio_worklet_thread_async,g:_fd_close,s:_fd_read,o:_fd_seek,r:_fd_write,a:wasmMemory};var wasmExports=createWasm();var ___wasm_call_ctors=()=>(___wasm_call_ctors=wasmExports["u"])();var _ma_device__on_notification_unlocked=Module["_ma_device__on_notification_unlocked"]=a0=>(_ma_device__on_notification_unlocked=Module["_ma_device__on_notification_unlocked"]=wasmExports["v"])(a0);var _ma_malloc_emscripten=Module["_ma_malloc_emscripten"]=(a0,a1)=>(_ma_malloc_emscripten=Module["_ma_malloc_emscripten"]=wasmExports["w"])(a0,a1);var _ma_free_emscripten=Module["_ma_free_emscripten"]=(a0,a1)=>(_ma_free_emscripten=Module["_ma_free_emscripten"]=wasmExports["x"])(a0,a1);var _ma_device_process_pcm_frames_capture__webaudio=Module["_ma_device_process_pcm_frames_capture__webaudio"]=(a0,a1,a2)=>(_ma_device_process_pcm_frames_capture__webaudio=Module["_ma_device_process_pcm_frames_capture__webaudio"]=wasmExports["y"])(a0,a1,a2);var _ma_device_process_pcm_frames_playback__webaudio=Module["_ma_device_process_pcm_frames_playback__webaudio"]=(a0,a1,a2)=>(_ma_device_process_pcm_frames_playback__webaudio=Module["_ma_device_process_pcm_frames_playback__webaudio"]=wasmExports["z"])(a0,a1,a2);var _malloc=Module["_malloc"]=a0=>(_malloc=Module["_malloc"]=wasmExports["A"])(a0);var _free=Module["_free"]=a0=>(_free=Module["_free"]=wasmExports["B"])(a0);var _engine_alloc=Module["_engine_alloc"]=()=>(_engine_alloc=Module["_engine_alloc"]=wasmExports["C"])();var _engine_init=Module["_engine_init"]=(a0,a1)=>(_engine_init=Module["_engine_init"]=wasmExports["D"])(a0,a1);var _engine_uninit=Module["_engine_uninit"]=a0=>(_engine_uninit=Module["_engine_uninit"]=wasmExports["E"])(a0);var _engine_start=Module["_engine_start"]=a0=>(_engine_start=Module["_engine_start"]=wasmExports["F"])(a0);var _engine_load_sound=Module["_engine_load_sound"]=(a0,a1,a2,a3)=>(_engine_load_sound=Module["_engine_load_sound"]=wasmExports["G"])(a0,a1,a2,a3);var _sound_alloc=Module["_sound_alloc"]=()=>(_sound_alloc=Module["_sound_alloc"]=wasmExports["H"])();var _sound_unload=Module["_sound_unload"]=a0=>(_sound_unload=Module["_sound_unload"]=wasmExports["I"])(a0);var _sound_play=Module["_sound_play"]=a0=>(_sound_play=Module["_sound_play"]=wasmExports["J"])(a0);var _sound_replay=Module["_sound_replay"]=a0=>(_sound_replay=Module["_sound_replay"]=wasmExports["K"])(a0);var _sound_stop=Module["_sound_stop"]=a0=>(_sound_stop=Module["_sound_stop"]=wasmExports["L"])(a0);var _sound_pause=Module["_sound_pause"]=a0=>(_sound_pause=Module["_sound_pause"]=wasmExports["M"])(a0);var _sound_get_volume=Module["_sound_get_volume"]=a0=>(_sound_get_volume=Module["_sound_get_volume"]=wasmExports["N"])(a0);var _sound_set_volume=Module["_sound_set_volume"]=(a0,a1)=>(_sound_set_volume=Module["_sound_set_volume"]=wasmExports["O"])(a0,a1);var _sound_get_duration=Module["_sound_get_duration"]=a0=>(_sound_get_duration=Module["_sound_get_duration"]=wasmExports["P"])(a0);var _sound_set_looped=Module["_sound_set_looped"]=(a0,a1,a2)=>(_sound_set_looped=Module["_sound_set_looped"]=wasmExports["Q"])(a0,a1,a2);var _emscripten_stack_init=()=>(_emscripten_stack_init=wasmExports["S"])();var _emscripten_stack_get_end=()=>(_emscripten_stack_get_end=wasmExports["T"])();var __emscripten_wasm_worker_initialize=(a0,a1)=>(__emscripten_wasm_worker_initialize=wasmExports["U"])(a0,a1);var __emscripten_stack_restore=a0=>(__emscripten_stack_restore=wasmExports["V"])(a0);var __emscripten_stack_alloc=a0=>(__emscripten_stack_alloc=wasmExports["W"])(a0);var _emscripten_stack_get_current=()=>(_emscripten_stack_get_current=wasmExports["X"])();var dynCall_viii=Module["dynCall_viii"]=(a0,a1,a2,a3)=>(dynCall_viii=Module["dynCall_viii"]=wasmExports["Y"])(a0,a1,a2,a3);var _asyncify_start_unwind=a0=>(_asyncify_start_unwind=wasmExports["Z"])(a0);var _asyncify_stop_unwind=()=>(_asyncify_stop_unwind=wasmExports["_"])();var _asyncify_start_rewind=a0=>(_asyncify_start_rewind=wasmExports["$"])(a0);var _asyncify_stop_rewind=()=>(_asyncify_stop_rewind=wasmExports["aa"])();Module["stackSave"]=stackSave;Module["stackRestore"]=stackRestore;Module["stackAlloc"]=stackAlloc;Module["wasmTable"]=wasmTable;Module["ccall"]=ccall;var calledRun;dependenciesFulfilled=function runCaller(){if(!calledRun)run();if(!calledRun)dependenciesFulfilled=runCaller};function stackCheckInit(){_emscripten_stack_init();writeStackCookie()}function run(){if(runDependencies>0){return}stackCheckInit();if(ENVIRONMENT_IS_WASM_WORKER){return initRuntime()}preRun();if(runDependencies>0){return}function doRun(){if(calledRun)return;calledRun=true;Module["calledRun"]=true;if(ABORT)return;initRuntime();if(Module["onRuntimeInitialized"])Module["onRuntimeInitialized"]();postRun()}if(Module["setStatus"]){Module["setStatus"]("Running...");setTimeout(function(){setTimeout(function(){Module["setStatus"]("")},1);doRun()},1)}else{doRun()}checkStackCookie()}if(Module["preInit"]){if(typeof Module["preInit"]=="function")Module["preInit"]=[Module["preInit"]];while(Module["preInit"].length>0){Module["preInit"].pop()()}}run();
