// include: shell.js
// include: minimum_runtime_check.js
// end include: minimum_runtime_check.js
// The Module object: Our interface to the outside world. We import
// and export values on it. There are various ways Module can be used:
// 1. Not defined. We create it here
// 2. A function parameter, function(moduleArg) => Promise<Module>
// 3. pre-run appended it, var Module = {}; ..generated code..
// 4. External script tag defines var Module.
// We need to check if Module already exists (e.g. case 3 above).
// Substitution will be replaced with actual code on later stage of the build,
// this way Closure Compiler will not mangle it (e.g. case 4. above).
// Note that if you want to run closure, and also to use Module
// after the generated code, you will need to define   var Module = {};
// before the code. Then that object will be used in the code, and you
// can continue to use Module afterwards as well.
var Module = globalThis.Module || (typeof Module != "undefined" ? Module : {});

// The way we signal to a worker that it is hosting a pthread is to construct
// it with a specific name.
var ENVIRONMENT_IS_WASM_WORKER = globalThis.name == "em-ww";

var ENVIRONMENT_IS_AUDIO_WORKLET = !!globalThis.AudioWorkletGlobalScope;

// Audio worklets behave as wasm workers.
if (ENVIRONMENT_IS_AUDIO_WORKLET) ENVIRONMENT_IS_WASM_WORKER = true;

// Determine the runtime environment we are in. You can customize this by
// setting the ENVIRONMENT setting at compile time (see settings.js).
// Attempt to auto-detect the environment
var ENVIRONMENT_IS_WEB = !!globalThis.window;

var ENVIRONMENT_IS_WORKER = !!globalThis.WorkerGlobalScope;

// N.b. Electron.js environment is simultaneously a NODE-environment, but
// also a web environment.
var ENVIRONMENT_IS_NODE = globalThis.process?.versions?.node && globalThis.process?.type != "renderer";

var ENVIRONMENT_IS_SHELL = !ENVIRONMENT_IS_WEB && !ENVIRONMENT_IS_NODE && !ENVIRONMENT_IS_WORKER && !ENVIRONMENT_IS_AUDIO_WORKLET;

if (ENVIRONMENT_IS_NODE) {
  var worker_threads = require("worker_threads");
  global.Worker = worker_threads.Worker;
  ENVIRONMENT_IS_WORKER = !worker_threads.isMainThread;
  ENVIRONMENT_IS_WASM_WORKER = ENVIRONMENT_IS_WORKER && worker_threads["workerData"] == "em-ww";
}

// --pre-jses are emitted after the Module integration code, so that they can
// refer to Module (if they choose; they can also define Module)
var arguments_ = [];

var thisProgram = "./this.program";

var quit_ = (status, toThrow) => {
  throw toThrow;
};

// In MODULARIZE mode _scriptName needs to be captured already at the very top of the page immediately when the page is parsed, so it is generated there
// before the page load. In non-MODULARIZE modes generate it here.
var _scriptName = globalThis.document?.currentScript?.src;

if (typeof __filename != "undefined") {
  // Node
  _scriptName = __filename;
} else if (ENVIRONMENT_IS_WORKER) {
  _scriptName = self.location.href;
}

// `/` should be present at the end if `scriptDirectory` is not empty
var scriptDirectory = "";

function locateFile(path) {
  if (Module["locateFile"]) {
    return Module["locateFile"](path, scriptDirectory);
  }
  return scriptDirectory + path;
}

// Hooks that are implemented differently in different runtime environments.
var readAsync, readBinary;

if (ENVIRONMENT_IS_NODE) {
  // These modules will usually be used on Node.js. Load them eagerly to avoid
  // the complexity of lazy-loading.
  var fs = require("fs");
  scriptDirectory = __dirname + "/";
  // include: node_shell_read.js
  readBinary = filename => {
    // We need to re-wrap `file://` strings to URLs.
    filename = isFileURI(filename) ? new URL(filename) : filename;
    var ret = fs.readFileSync(filename);
    return ret;
  };
  readAsync = async (filename, binary = true) => {
    // See the comment in the `readBinary` function.
    filename = isFileURI(filename) ? new URL(filename) : filename;
    var ret = fs.readFileSync(filename, binary ? undefined : "utf8");
    return ret;
  };
  // end include: node_shell_read.js
  if (process.argv.length > 1) {
    thisProgram = process.argv[1].replace(/\\/g, "/");
  }
  arguments_ = process.argv.slice(2);
  // MODULARIZE will export the module in the proper place outside, we don't need to export here
  if (typeof module != "undefined") {
    module["exports"] = Module;
  }
  quit_ = (status, toThrow) => {
    process.exitCode = status;
    throw toThrow;
  };
} else // Note that this includes Node.js workers when relevant (pthreads is enabled).
// Node.js workers are detected as a combination of ENVIRONMENT_IS_WORKER and
// ENVIRONMENT_IS_NODE.
if (ENVIRONMENT_IS_WEB || ENVIRONMENT_IS_WORKER) {
  try {
    scriptDirectory = new URL(".", _scriptName).href;
  } catch {}
  {
    // include: web_or_worker_shell_read.js
    if (ENVIRONMENT_IS_WORKER) {
      readBinary = url => {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", url, false);
        xhr.responseType = "arraybuffer";
        xhr.send(null);
        return new Uint8Array(/** @type{!ArrayBuffer} */ (xhr.response));
      };
    }
    readAsync = async url => {
      // Fetch has some additional restrictions over XHR, like it can't be used on a file:// url.
      // See https://github.com/github/fetch/pull/92#issuecomment-140665932
      // Cordova or Electron apps are typically loaded from a file:// url.
      // So use XHR on webview if URL is a file URL.
      if (isFileURI(url)) {
        return new Promise((resolve, reject) => {
          var xhr = new XMLHttpRequest;
          xhr.open("GET", url, true);
          xhr.responseType = "arraybuffer";
          xhr.onload = () => {
            if (xhr.status == 200 || (xhr.status == 0 && xhr.response)) {
              // file URLs can return 0
              resolve(xhr.response);
              return;
            }
            reject(xhr.status);
          };
          xhr.onerror = reject;
          xhr.send(null);
        });
      }
      var response = await fetch(url, {
        credentials: "same-origin"
      });
      if (response.ok) {
        return response.arrayBuffer();
      }
      throw new Error(response.status + " : " + response.url);
    };
  }
} else {}

// Set up the out() and err() hooks, which are how we can print to stdout or
// stderr, respectively.
// Normally just binding console.log/console.error here works fine, but
// under node (with workers) we see missing/out-of-order messages so route
// directly to stdout and stderr.
// See https://github.com/emscripten-core/emscripten/issues/14804
var defaultPrint = console.log.bind(console);

var defaultPrintErr = console.error.bind(console);

if (ENVIRONMENT_IS_NODE) {
  var utils = require("util");
  var stringify = a => typeof a == "object" ? utils.inspect(a) : a;
  defaultPrint = (...args) => fs.writeSync(1, args.map(stringify).join(" ") + "\n");
  defaultPrintErr = (...args) => fs.writeSync(2, args.map(stringify).join(" ") + "\n");
}

var out = defaultPrint;

var err = defaultPrintErr;

// end include: shell.js
// include: preamble.js
// === Preamble library stuff ===
// Documentation for the public APIs defined in this file must be updated in:
//    site/source/docs/api_reference/preamble.js.rst
// A prebuilt local version of the documentation is available at:
//    site/build/text/docs/api_reference/preamble.js.txt
// You can also build docs locally as HTML or other formats in site/
// An online HTML version (which may be of a different version of Emscripten)
//    is up at http://kripken.github.io/emscripten-site/docs/api_reference/preamble.js.html
var wasmBinary;

// Wasm globals
// For sending to workers.
var wasmModule;

//========================================
// Runtime essentials
//========================================
// whether we are quitting the application. no code should run after this.
// set in exit() and abort()
var ABORT = false;

// set by exit() and abort().  Passed to 'onExit' handler.
// NOTE: This is also used as the process return code in shell environments
// but only when noExitRuntime is false.
var EXITSTATUS;

// In STRICT mode, we only define assert() when ASSERTIONS is set.  i.e. we
// don't define it at all in release modes.  This matches the behaviour of
// MINIMAL_RUNTIME.
// TODO(sbc): Make this the default even without STRICT enabled.
/** @type {function(*, string=)} */ function assert(condition, text) {
  if (!condition) {
    // This build was created without ASSERTIONS defined.  `assert()` should not
    // ever be called in this configuration but in case there are callers in
    // the wild leave this simple abort() implementation here for now.
    abort(text);
  }
}

/**
 * Indicates whether filename is delivered via file protocol (as opposed to http/https)
 * @noinline
 */ var isFileURI = filename => filename.startsWith("file://");

// include: runtime_common.js
// include: runtime_stack_check.js
// Initializes the stack cookie. Called at the startup of main and at the startup of each thread in pthreads mode.
function writeStackCookie() {
  var max = _emscripten_stack_get_end();
  // If the stack ends at address zero we write our cookies 4 bytes into the
  // stack.  This prevents interference with SAFE_HEAP and ASAN which also
  // monitor writes to address zero.
  if (max == 0) {
    max += 4;
  }
  // The stack grow downwards towards _emscripten_stack_get_end.
  // We write cookies to the final two words in the stack and detect if they are
  // ever overwritten.
  (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((max) >> 2), "storing")] = 34821223;
  (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((max) + (4)) >> 2), "storing")] = 2310721022;
}

function checkStackCookie() {
  if (ABORT) return;
  var max = _emscripten_stack_get_end();
  // See writeStackCookie().
  if (max == 0) {
    max += 4;
  }
  var cookie1 = (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((max) >> 2), "loading")];
  var cookie2 = (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((max) + (4)) >> 2), "loading")];
  if (cookie1 != 34821223 || cookie2 != 2310721022) {
    abort(`Stack overflow! Stack cookie has been overwritten at ${ptrToString(max)}, expected hex dwords 0x89BACDFE and 0x2135467, but received ${ptrToString(cookie2)} ${ptrToString(cookie1)}`);
  }
}

// end include: runtime_stack_check.js
// include: runtime_exceptions.js
// end include: runtime_exceptions.js
// include: runtime_debug.js
// end include: runtime_debug.js
// include: runtime_safe_heap.js
function SAFE_HEAP_INDEX(arr, idx, action) {
  const bytes = arr.BYTES_PER_ELEMENT;
  const dest = idx * bytes;
  if (idx <= 0) abort(`segmentation fault ${action} ${bytes} bytes at address ${dest}`);
  if (runtimeInitialized) {
    var brk = _sbrk(0);
    if (dest + bytes > brk) abort(`segmentation fault, exceeded the top of the available dynamic heap when ${action} ${bytes} bytes at address ${dest}. DYNAMICTOP=${brk}`);
    if (brk < _emscripten_stack_get_base()) abort(`brk >= _emscripten_stack_get_base() (brk=${brk}, _emscripten_stack_get_base()=${_emscripten_stack_get_base()})`);
    // sbrk-managed memory must be above the stack
    if (brk > wasmMemory.buffer.byteLength) abort(`brk <= wasmMemory.buffer.byteLength (brk=${brk}, wasmMemory.buffer.byteLength=${wasmMemory.buffer.byteLength})`);
  }
  return idx;
}

function segfault() {
  abort("segmentation fault");
}

function alignfault() {
  abort("alignment fault");
}

// end include: runtime_safe_heap.js
// Support for growable heap + pthreads, where the buffer may change, so JS views
// must be updated.
function growMemViews() {
  // `updateMemoryViews` updates all the views simultaneously, so it's enough to check any of them.
  if (wasmMemory.buffer != HEAP8.buffer) {
    updateMemoryViews();
  }
}

if (ENVIRONMENT_IS_NODE && (ENVIRONMENT_IS_WASM_WORKER)) {
  // Create as web-worker-like an environment as we can.
  var parentPort = worker_threads["parentPort"];
  parentPort.on("message", msg => global.onmessage?.({
    data: msg
  }));
  Object.assign(globalThis, {
    self: global,
    postMessage: msg => parentPort["postMessage"](msg)
  });
  // Node.js Workers do not pass postMessage()s and uncaught exception events to the parent
  // thread necessarily in the same order where they were generated in sequential program order.
  // See https://github.com/nodejs/node/issues/59617
  // To remedy this, capture all uncaughtExceptions in the Worker, and sequentialize those over
  // to the same postMessage pipe that other messages use.
  process.on("uncaughtException", err => {
    postMessage({
      cmd: "uncaughtException",
      error: err
    });
    // Also shut down the Worker to match the same semantics as if this uncaughtException
    // handler was not registered.
    // (n.b. this will not shut down the whole Node.js app process, but just the Worker)
    process.exit(1);
  });
}

// include: wasm_worker.js
var wwParams;

/**
 * Called once the initial message has been received from the creating thread.
 * The `props` object is property bag sent via postMessage to create the worker.
 *
 * This function is called both in normal wasm workers and in audio worklets.
 */ function startWasmWorker(props) {
  wwParams = props;
  wasmMemory = props.wasmMemory;
  updateMemoryViews();
  wasmModule = props.wasm;
  createWasm();
  run();
  // Drop now unneeded references to from the Module object in this Worker,
  // these are not needed anymore.
  props.wasm = props.wasmMemory = 0;
}

if (ENVIRONMENT_IS_WASM_WORKER && !ENVIRONMENT_IS_AUDIO_WORKLET) {
  // Node.js support
  if (ENVIRONMENT_IS_NODE) {
    // Weak map of handle functions to their wrapper. Used to implement
    // addEventListener/removeEventListener.
    var wrappedHandlers = new WeakMap;
    /** @suppress {checkTypes} */ globalThis.onmessage = null;
    function wrapMsgHandler(h) {
      var f = wrappedHandlers.get(h);
      if (!f) {
        f = msg => h({
          data: msg
        });
        wrappedHandlers.set(h, f);
      }
      return f;
    }
    Object.assign(globalThis, {
      addEventListener: (name, handler) => parentPort["on"](name, wrapMsgHandler(handler)),
      removeEventListener: (name, handler) => parentPort["off"](name, wrapMsgHandler(handler))
    });
  }
  onmessage = d => {
    // The first message sent to the Worker is always the bootstrap message.
    // Drop this message listener, it served its purpose of bootstrapping
    // the Wasm Module load, and is no longer needed. Let user code register
    // any desired message handlers from now on.
    /** @suppress {checkTypes} */ onmessage = null;
    startWasmWorker(d.data);
  };
}

// end include: wasm_worker.js
// include: audio_worklet.js
// This file is the main bootstrap script for Wasm Audio Worklets loaded in an
// Emscripten application.  Build with -sAUDIO_WORKLET linker flag to enable
// targeting Audio Worklets.
// AudioWorkletGlobalScope does not have a onmessage/postMessage() functionality
// at the global scope, which means that after creating an
// AudioWorkletGlobalScope and loading this script into it, we cannot
// postMessage() information into it like one would do with Web Workers.
// Instead, we must create an AudioWorkletProcessor class, then instantiate a
// Web Audio graph node from it on the main thread. Using its message port and
// the node constructor's "processorOptions" field, we can share the necessary
// bootstrap information from the main thread to the AudioWorkletGlobalScope.
if (ENVIRONMENT_IS_AUDIO_WORKLET) {
  function createWasmAudioWorkletProcessor(audioParams) {
    class WasmAudioWorkletProcessor extends AudioWorkletProcessor {
      constructor(args) {
        super();
        // Capture the Wasm function callback to invoke.
        let opts = args.processorOptions;
        this.callback = ((a1, a2, a3, a4, a5, a6, a7) => dynCall_iiiiiiii(opts.callback, a1, a2, a3, a4, a5, a6, a7));
        this.userData = opts.userData;
        // Then the samples per channel to process, fixed for the lifetime of the
        // context that created this processor. Even though this 'render quantum
        // size' is fixed at 128 samples in the 1.0 spec, it will be variable in
        // the 1.1 spec. It's passed in now, just to prove it's settable, but will
        // eventually be a property of the  AudioWorkletGlobalScope (globalThis).
        this.samplesPerChannel = opts.samplesPerChannel;
        this.bytesPerChannel = this.samplesPerChannel * 4;
        // Prepare the output views; see createOutputViews(). The 'STACK_ALIGN'
        // deduction stops the STACK_OVERFLOW_CHECK failing (since the stack will
        // be full if we allocate all the available space) leaving room for a
        // single AudioSampleFrame as a minimum. There's an arbitrary maximum of
        // 64 frames, for the case where a multi-MB stack is passed.
        this.outputViews = new Array(Math.min(((wwParams.stackSize - 16) / this.bytesPerChannel) | 0, /*sensible limit*/ 64));
        this.createOutputViews();
      }
      /**
     * Create up-front as many typed views for marshalling the output data as
     * may be required, allocated at the *top* of the worklet's stack (and whose
     * addresses are fixed). 
     */ createOutputViews() {
        // These are still alloc'd to take advantage of the overflow checks, etc.
        var oldStackPtr = stackSave();
        var viewDataIdx = ((stackAlloc(this.outputViews.length * this.bytesPerChannel)) >> 2);
        // Inserted in reverse so the lowest indices are closest to the stack top
        for (var n = this.outputViews.length - 1; n >= 0; n--) {
          this.outputViews[n] = (growMemViews(), HEAPF32).subarray(viewDataIdx, viewDataIdx += this.samplesPerChannel);
        }
        stackRestore(oldStackPtr);
      }
      static get parameterDescriptors() {
        return audioParams;
      }
      /**
     * Marshals all inputs and parameters to the Wasm memory on the thread's
     * stack, then performs the wasm audio worklet call, and finally marshals
     * audio output data back.
     *
     * @param {Object} parameters
     */ process(inputList, outputList, parameters) {
        // Recreate the output views if the heap has changed
        // TODO: add support for GROWABLE_ARRAYBUFFERS
        if ((growMemViews(), HEAPF32).buffer != this.outputViews[0].buffer) {
          this.createOutputViews();
        }
        var numInputs = inputList.length;
        var numOutputs = outputList.length;
        var entry;
        // reused list entry or index
        var subentry;
        // reused channel or other array in each list entry or index
        // Calculate the required stack and output buffer views (stack is further
        // split into aligned structs and the raw float data).
        var stackMemoryStruct = (numInputs + numOutputs) * 12;
        var stackMemoryData = 0;
        for (entry of inputList) {
          stackMemoryData += entry.length;
        }
        stackMemoryData *= this.bytesPerChannel;
        // Collect the total number of output channels (mapped to array views)
        var outputViewsNeeded = 0;
        for (entry of outputList) {
          outputViewsNeeded += entry.length;
        }
        stackMemoryData += outputViewsNeeded * this.bytesPerChannel;
        var numParams = 0;
        for (entry in parameters) {
          ++numParams;
          stackMemoryStruct += 8;
          stackMemoryData += parameters[entry].byteLength;
        }
        var oldStackPtr = stackSave();
        // Allocate the necessary stack space. All pointer variables are in bytes;
        // 'structPtr' starts at the first struct entry (all run sequentially)
        // and is the working start to each record; 'dataPtr' is the same for the
        // audio/params data, starting after *all* the structs.
        // 'structPtr' begins 16-byte aligned, allocated from the internal
        // _emscripten_stack_alloc(), as are the output views, and so to ensure
        // the views fall on the correct addresses (and we finish at stacktop) we
        // request additional bytes, taking this alignment into account, then
        // offset `dataPtr` by the difference.
        var stackMemoryAligned = (stackMemoryStruct + stackMemoryData + 15) & ~15;
        var structPtr = stackAlloc(stackMemoryAligned);
        var dataPtr = structPtr + (stackMemoryAligned - stackMemoryData);
        // Copy input audio descriptor structs and data to Wasm (recall, structs
        // first, audio data after). 'inputsPtr' is the start of the C callback's
        // input AudioSampleFrame.
        var /*const*/ inputsPtr = structPtr;
        for (entry of inputList) {
          // Write the AudioSampleFrame struct instance
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((structPtr) >> 2), "storing")] = entry.length;
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((structPtr) + (4)) >> 2), "storing")] = this.samplesPerChannel;
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((structPtr) + (8)) >> 2), "storing")] = dataPtr;
          structPtr += 12;
          // Marshal the input audio sample data for each audio channel of this input
          for (subentry of entry) {
            (growMemViews(), HEAPF32).set(subentry, ((dataPtr) >> 2));
            dataPtr += this.bytesPerChannel;
          }
        }
        // Copy parameters descriptor structs and data to Wasm. 'paramsPtr' is the
        // start of the C callback's input AudioParamFrame.
        var /*const*/ paramsPtr = structPtr;
        for (entry = 0; subentry = parameters[entry++]; ) {
          // Write the AudioParamFrame struct instance
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((structPtr) >> 2), "storing")] = subentry.length;
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((structPtr) + (4)) >> 2), "storing")] = dataPtr;
          structPtr += 8;
          // Marshal the audio parameters array
          (growMemViews(), HEAPF32).set(subentry, ((dataPtr) >> 2));
          dataPtr += subentry.length * 4;
        }
        // Copy output audio descriptor structs to Wasm. 'outputsPtr' is the start
        // of the C callback's output AudioSampleFrame. 'dataPtr' will now be
        // aligned with the output views, ending at stacktop (which is why this
        // needs to be last).
        var /*const*/ outputsPtr = structPtr;
        for (entry of outputList) {
          // Write the AudioSampleFrame struct instance
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((structPtr) >> 2), "storing")] = entry.length;
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((structPtr) + (4)) >> 2), "storing")] = this.samplesPerChannel;
          (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((structPtr) + (8)) >> 2), "storing")] = dataPtr;
          structPtr += 12;
          // Advance the output pointer to the next output (matching the pre-allocated views)
          dataPtr += this.bytesPerChannel * entry.length;
        }
        // Call out to Wasm callback to perform audio processing
        var didProduceAudio = this.callback(numInputs, inputsPtr, numOutputs, outputsPtr, numParams, paramsPtr, this.userData);
        if (didProduceAudio) {
          // Read back the produced audio data to all outputs and their channels.
          // The preallocated 'outputViews' already have the correct offsets and
          // sizes into the stack (recall from createOutputViews() that they run
          // backwards).
          for (entry of outputList) {
            for (subentry of entry) {
              subentry.set(this.outputViews[--outputViewsNeeded]);
            }
          }
        }
        stackRestore(oldStackPtr);
        // Return 'true' to tell the browser to continue running this processor.
        // (Returning 1 or any other truthy value won't work in Chrome)
        return !!didProduceAudio;
      }
    }
    return WasmAudioWorkletProcessor;
  }
  // If this browser does not support the up-to-date AudioWorklet standard
  // that has a MessagePort over to the AudioWorklet, then polyfill that by
  // a hacky AudioWorkletProcessor that provides the MessagePort.
  // Firefox added support in https://hg-edge.mozilla.org/integration/autoland/rev/ab38a1796126f2b3fc06475ffc5a625059af59c1
  // Chrome ticket: https://crbug.com/446920095
  // Safari ticket: https://webkit.org/b/299386
  /**
 * @suppress {duplicate, checkTypes}
 */ var port = globalThis.port || {};
  // Specify a worklet processor that will be used to receive messages to this
  // AudioWorkletGlobalScope.  We never connect this initial AudioWorkletProcessor
  // to the audio graph to do any audio processing.
  class BootstrapMessages extends AudioWorkletProcessor {
    constructor(arg) {
      super();
      startWasmWorker(arg.processorOptions);
      // Listen to messages from the main thread. These messages will ask this
      // scope to create the real AudioWorkletProcessors that call out to Wasm to
      // do audio processing.
      if (!(port instanceof MessagePort)) {
        this.port.onmessage = port.onmessage;
        /** @suppress {checkTypes} */ port = this.port;
      }
    }
    // No-op, not doing audio processing in this processor. It is just for
    // receiving bootstrap messages.  However browsers require it to still be
    // present. It should never be called because we never add a node to the graph
    // with this processor, although it does look like Chrome does still call this
    // function.
    process() {}
  }
  // Register the dummy processor that will just receive messages.
  registerProcessor("em-bootstrap", BootstrapMessages);
  port.onmessage = async msg => {
    let d = msg.data;
    if (d["_boot"]) {
      startWasmWorker(d);
    } else if (d["_wpn"]) {
      // '_wpn' is short for 'Worklet Processor Node', using an identifier
      // that will never conflict with user messages
      // Register a real AudioWorkletProcessor that will actually do audio processing.
      registerProcessor(d["_wpn"], createWasmAudioWorkletProcessor(d.audioParams));
      // Post a Wasm Call message back telling that we have now registered the
      // AudioWorkletProcessor, and should trigger the user onSuccess callback
      // of the emscripten_create_wasm_audio_worklet_processor_async() call.
      // '_wsc' is short for 'wasm call', using an identifier that will never
      // conflict with user messages.
      // Note: we convert the pointer arg manually here since the call site
      // ($_EmAudioDispatchProcessorCallback) is used with various signatures
      // and we do not know the types in advance.
      port.postMessage({
        "_wsc": d.callback,
        args: [ d.contextHandle, 1, d.userData ]
      });
    } else if (d["_wsc"]) {
      getWasmTableEntry(d["_wsc"])(...d.args);
    }
  };
}

// ENVIRONMENT_IS_AUDIO_WORKLET
// end include: audio_worklet.js
// Memory management
var /** @type {!Int8Array} */ HEAP8, /** @type {!Uint8Array} */ HEAPU8, /** @type {!Int16Array} */ HEAP16, /** @type {!Uint16Array} */ HEAPU16, /** @type {!Int32Array} */ HEAP32, /** @type {!Uint32Array} */ HEAPU32, /** @type {!Float32Array} */ HEAPF32, /** @type {!Float64Array} */ HEAPF64;

// BigInt64Array type is not correctly defined in closure
var /** not-@type {!BigInt64Array} */ HEAP64, /* BigUint64Array type is not correctly defined in closure
/** not-@type {!BigUint64Array} */ HEAPU64;

var runtimeInitialized = false;

function updateMemoryViews() {
  var b = wasmMemory.buffer;
  HEAP8 = new Int8Array(b);
  HEAP16 = new Int16Array(b);
  HEAPU8 = new Uint8Array(b);
  HEAPU16 = new Uint16Array(b);
  HEAP32 = new Int32Array(b);
  HEAPU32 = new Uint32Array(b);
  HEAPF32 = new Float32Array(b);
  HEAPF64 = new Float64Array(b);
  HEAP64 = new BigInt64Array(b);
  HEAPU64 = new BigUint64Array(b);
}

// In non-standalone/normal mode, we create the memory here.
// include: runtime_init_memory.js
// Create the wasm memory. (Note: this only applies if IMPORTED_MEMORY is defined)
// check for full engine support (use string 'subarray' to avoid closure compiler confusion)
function initMemory() {
  if ((ENVIRONMENT_IS_WASM_WORKER)) {
    return;
  }
  if (Module["wasmMemory"]) {
    wasmMemory = Module["wasmMemory"];
  } else {
    var INITIAL_MEMORY = Module["INITIAL_MEMORY"] || 16777216;
    /** @suppress {checkTypes} */ wasmMemory = new WebAssembly.Memory({
      "initial": INITIAL_MEMORY / 65536,
      // In theory we should not need to emit the maximum if we want "unlimited"
      // or 4GB of memory, but VMs error on that atm, see
      // https://github.com/emscripten-core/emscripten/issues/14130
      // And in the pthreads case we definitely need to emit a maximum. So
      // always emit one.
      "maximum": 16384,
      "shared": true
    });
  }
  updateMemoryViews();
}

// end include: runtime_init_memory.js
// include: memoryprofiler.js
// end include: memoryprofiler.js
// end include: runtime_common.js
function preRun() {
  if (Module["preRun"]) {
    if (typeof Module["preRun"] == "function") Module["preRun"] = [ Module["preRun"] ];
    while (Module["preRun"].length) {
      addOnPreRun(Module["preRun"].shift());
    }
  }
  // Begin ATPRERUNS hooks
  callRuntimeCallbacks(onPreRuns);
}

function initRuntime() {
  runtimeInitialized = true;
  if (ENVIRONMENT_IS_WASM_WORKER) return _wasmWorkerInitializeRuntime();
  checkStackCookie();
  // No ATINITS hooks
  wasmExports["__wasm_call_ctors"]();
}

function postRun() {
  checkStackCookie();
  if ((ENVIRONMENT_IS_WASM_WORKER)) {
    return;
  }
  // PThreads reuse the runtime from the main thread.
  if (Module["postRun"]) {
    if (typeof Module["postRun"] == "function") Module["postRun"] = [ Module["postRun"] ];
    while (Module["postRun"].length) {
      addOnPostRun(Module["postRun"].shift());
    }
  }
  // Begin ATPOSTRUNS hooks
  callRuntimeCallbacks(onPostRuns);
}

/** @param {string|number=} what */ function abort(what) {
  Module["onAbort"]?.(what);
  what = "Aborted(" + what + ")";
  // TODO(sbc): Should we remove printing and leave it up to whoever
  // catches the exception?
  err(what);
  ABORT = true;
  what += ". Build with -sASSERTIONS for more info.";
  // Use a wasm runtime error, because a JS error might be seen as a foreign
  // exception, which means we'd run destructors on it. We need the error to
  // simply make the program stop.
  // FIXME This approach does not work in Wasm EH because it currently does not assume
  // all RuntimeErrors are from traps; it decides whether a RuntimeError is from
  // a trap or not based on a hidden field within the object. So at the moment
  // we don't have a way of throwing a wasm trap from JS. TODO Make a JS API that
  // allows this in the wasm spec.
  // Suppress closure compiler warning here. Closure compiler's builtin extern
  // definition for WebAssembly.RuntimeError claims it takes no arguments even
  // though it can.
  // TODO(https://github.com/google/closure-compiler/pull/3913): Remove if/when upstream closure gets fixed.
  /** @suppress {checkTypes} */ var e = new WebAssembly.RuntimeError(what);
  // Throw the error whether or not MODULARIZE is set because abort is used
  // in code paths apart from instantiation where an exception is expected
  // to be thrown when abort is called.
  throw e;
}

var wasmBinaryFile;

function findWasmBinary() {
  return locateFile("minisound_web.wasm");
}

function getBinarySync(file) {
  if (file == wasmBinaryFile && wasmBinary) {
    return new Uint8Array(wasmBinary);
  }
  if (readBinary) {
    return readBinary(file);
  }
  // Throwing a plain string here, even though it not normally advisable since
  // this gets turning into an `abort` in instantiateArrayBuffer.
  throw "both async and sync fetching of the wasm failed";
}

async function getWasmBinary(binaryFile) {
  // If we don't have the binary yet, load it asynchronously using readAsync.
  if (!wasmBinary) {
    // Fetch the binary using readAsync
    try {
      var response = await readAsync(binaryFile);
      return new Uint8Array(response);
    } catch {}
  }
  // Otherwise, getBinarySync should be able to get it synchronously
  return getBinarySync(binaryFile);
}

async function instantiateArrayBuffer(binaryFile, imports) {
  try {
    var binary = await getWasmBinary(binaryFile);
    var instance = await WebAssembly.instantiate(binary, imports);
    return instance;
  } catch (reason) {
    err(`failed to asynchronously prepare wasm: ${reason}`);
    abort(reason);
  }
}

async function instantiateAsync(binary, binaryFile, imports) {
  if (!binary && !isFileURI(binaryFile) && !ENVIRONMENT_IS_NODE) {
    try {
      var response = fetch(binaryFile, {
        credentials: "same-origin"
      });
      var instantiationResult = await WebAssembly.instantiateStreaming(response, imports);
      return instantiationResult;
    } catch (reason) {
      // We expect the most common failure cause to be a bad MIME type for the binary,
      // in which case falling back to ArrayBuffer instantiation should work.
      err(`wasm streaming compile failed: ${reason}`);
      err("falling back to ArrayBuffer instantiation");
    }
  }
  return instantiateArrayBuffer(binaryFile, imports);
}

function getWasmImports() {
  assignWasmImports();
  // prepare imports
  var imports = {
    "env": wasmImports,
    "wasi_snapshot_preview1": wasmImports
  };
  return imports;
}

// Create the wasm instance.
// Receives the wasm imports, returns the exports.
async function createWasm() {
  // Load the wasm module and create an instance of using native support in the JS engine.
  // handle a generated wasm instance, receiving its exports and
  // performing other necessary setup
  /** @param {WebAssembly.Module=} module*/ function receiveInstance(instance, module) {
    wasmExports = instance.exports;
    wasmExports = Asyncify.instrumentWasmExports(wasmExports);
    assignWasmExports(wasmExports);
    // We now have the Wasm module loaded up, keep a reference to the compiled module so we can post it to the workers.
    wasmModule = module;
    removeRunDependency("wasm-instantiate");
    return wasmExports;
  }
  addRunDependency("wasm-instantiate");
  // Prefer streaming instantiation if available.
  function receiveInstantiationResult(result) {
    // 'result' is a ResultObject object which has both the module and instance.
    // receiveInstance() will swap in the exports (to Module.asm) so they can be called
    return receiveInstance(result["instance"], result["module"]);
  }
  var info = getWasmImports();
  // User shell pages can write their own Module.instantiateWasm = function(imports, successCallback) callback
  // to manually instantiate the Wasm module themselves. This allows pages to
  // run the instantiation parallel to any other async startup actions they are
  // performing.
  // Also pthreads and wasm workers initialize the wasm instance through this
  // path.
  if (Module["instantiateWasm"]) {
    return new Promise((resolve, reject) => {
      Module["instantiateWasm"](info, (inst, mod) => {
        resolve(receiveInstance(inst, mod));
      });
    });
  }
  if ((ENVIRONMENT_IS_WASM_WORKER)) {
    // Instantiate from the module that was received via postMessage from
    // the main thread. We can just use sync instantiation in the worker.
    var instance = new WebAssembly.Instance(wasmModule, getWasmImports());
    return receiveInstance(instance, wasmModule);
  }
  wasmBinaryFile ??= findWasmBinary();
  var result = await instantiateAsync(wasmBinary, wasmBinaryFile, info);
  var exports = receiveInstantiationResult(result);
  return exports;
}

// end include: preamble.js
// Begin JS library code
class ExitStatus {
  name="ExitStatus";
  constructor(status) {
    this.message = `Program terminated with exit(${status})`;
    this.status = status;
  }
}

var _wasmWorkerDelayedMessageQueue = [];

var handleException = e => {
  // Certain exception types we do not treat as errors since they are used for
  // internal control flow.
  // 1. ExitStatus, which is thrown by exit()
  // 2. "unwind", which is thrown by emscripten_unwind_to_js_event_loop() and others
  //    that wish to return to JS event loop.
  if (e instanceof ExitStatus || e == "unwind") {
    return EXITSTATUS;
  }
  checkStackCookie();
  if (e instanceof WebAssembly.RuntimeError) {
    if (_emscripten_stack_get_current() <= 0) {
      err("Stack overflow detected.  You can try increasing -sSTACK_SIZE (currently set to 1048576)");
    }
  }
  quit_(1, e);
};

var runtimeKeepaliveCounter = 0;

var keepRuntimeAlive = () => noExitRuntime || runtimeKeepaliveCounter > 0;

var _proc_exit = code => {
  EXITSTATUS = code;
  if (!keepRuntimeAlive()) {
    Module["onExit"]?.(code);
    ABORT = true;
  }
  quit_(code, new ExitStatus(code));
};

/** @param {boolean|number=} implicit */ var exitJS = (status, implicit) => {
  EXITSTATUS = status;
  _proc_exit(status);
};

var _exit = exitJS;

var maybeExit = () => {
  if (!keepRuntimeAlive()) {
    try {
      _exit(EXITSTATUS);
    } catch (e) {
      handleException(e);
    }
  }
};

var callUserCallback = func => {
  if (ABORT) {
    return;
  }
  try {
    func();
    maybeExit();
  } catch (e) {
    handleException(e);
  }
};

var wasmTableMirror = [];

var getWasmTableEntry = funcPtr => {
  var func = wasmTableMirror[funcPtr];
  if (!func) {
    /** @suppress {checkTypes} */ wasmTableMirror[funcPtr] = func = wasmTable.get(funcPtr);
  }
  return func;
};

var _wasmWorkerRunPostMessage = e => {
  // '_wsc' is short for 'wasm call', trying to use an identifier name that
  // will never conflict with user code
  let data = e.data;
  let wasmCall = data["_wsc"];
  wasmCall && callUserCallback(() => getWasmTableEntry(wasmCall)(...data["x"]));
};

var _wasmWorkerAppendToQueue = e => {
  _wasmWorkerDelayedMessageQueue.push(e);
};

var _wasmWorkerInitializeRuntime = () => {
  // Wasm workers basically never exit their runtime
  noExitRuntime = 1;
  // Run the C side Worker initialization for stack and TLS.
  __emscripten_wasm_worker_initialize(wwParams.stackLowestAddress, wwParams.stackSize);
  // Write the stack cookie last, after we have set up the proper bounds and
  // current position of the stack.
  writeStackCookie();
  // Audio Worklets do not have postMessage()ing capabilities.
  if (!ENVIRONMENT_IS_AUDIO_WORKLET) {
    // The Wasm Worker runtime is now up, so we can start processing
    // any postMessage function calls that have been received. Drop the temp
    // message handler that queued any pending incoming postMessage function calls ...
    removeEventListener("message", _wasmWorkerAppendToQueue);
    // ... then flush whatever messages we may have already gotten in the queue,
    //     and clear _wasmWorkerDelayedMessageQueue to undefined ...
    _wasmWorkerDelayedMessageQueue = _wasmWorkerDelayedMessageQueue.forEach(_wasmWorkerRunPostMessage);
    // ... and finally register the proper postMessage handler that immediately
    // dispatches incoming function calls without queueing them.
    addEventListener("message", _wasmWorkerRunPostMessage);
  }
};

var callRuntimeCallbacks = callbacks => {
  while (callbacks.length > 0) {
    // Pass the module as the first argument.
    callbacks.shift()(Module);
  }
};

var onPostRuns = [];

var addOnPostRun = cb => onPostRuns.push(cb);

var onPreRuns = [];

var addOnPreRun = cb => onPreRuns.push(cb);

var runDependencies = 0;

var dependenciesFulfilled = null;

var removeRunDependency = id => {
  runDependencies--;
  Module["monitorRunDependencies"]?.(runDependencies);
  if (runDependencies == 0) {
    if (dependenciesFulfilled) {
      var callback = dependenciesFulfilled;
      dependenciesFulfilled = null;
      callback();
    }
  }
};

var addRunDependency = id => {
  runDependencies++;
  Module["monitorRunDependencies"]?.(runDependencies);
};

var dynCalls = {};

var dynCallLegacy = (sig, ptr, args) => {
  sig = sig.replace(/p/g, "i");
  var f = dynCalls[sig];
  return f(ptr, ...args);
};

var dynCall = (sig, ptr, args = [], promising = false) => {
  var rtn = dynCallLegacy(sig, ptr, args);
  function convert(rtn) {
    return rtn;
  }
  return convert(rtn);
};

/**
     * @param {number} ptr
     * @param {string} type
     */ function getValue(ptr, type = "i8") {
  if (type.endsWith("*")) type = "*";
  switch (type) {
   case "i1":
    return (growMemViews(), HEAP8)[SAFE_HEAP_INDEX((growMemViews(), HEAP8), ptr, "loading")];

   case "i8":
    return (growMemViews(), HEAP8)[SAFE_HEAP_INDEX((growMemViews(), HEAP8), ptr, "loading")];

   case "i16":
    return (growMemViews(), HEAP16)[SAFE_HEAP_INDEX((growMemViews(), HEAP16), ((ptr) >> 1), "loading")];

   case "i32":
    return (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), ((ptr) >> 2), "loading")];

   case "i64":
    return (growMemViews(), HEAP64)[SAFE_HEAP_INDEX((growMemViews(), HEAP64), ((ptr) >> 3), "loading")];

   case "float":
    return (growMemViews(), HEAPF32)[SAFE_HEAP_INDEX((growMemViews(), HEAPF32), ((ptr) >> 2), "loading")];

   case "double":
    return (growMemViews(), HEAPF64)[SAFE_HEAP_INDEX((growMemViews(), HEAPF64), ((ptr) >> 3), "loading")];

   case "*":
    return (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((ptr) >> 2), "loading")];

   default:
    abort(`invalid type for getValue: ${type}`);
  }
}

var noExitRuntime = true;

var ptrToString = ptr => {
  // Convert to 32-bit unsigned value
  ptr >>>= 0;
  return "0x" + ptr.toString(16).padStart(8, "0");
};

/**
     * @param {number} ptr
     * @param {number} value
     * @param {string} type
     */ function setValue(ptr, value, type = "i8") {
  if (type.endsWith("*")) type = "*";
  switch (type) {
   case "i1":
    (growMemViews(), HEAP8)[SAFE_HEAP_INDEX((growMemViews(), HEAP8), ptr, "storing")] = value;
    break;

   case "i8":
    (growMemViews(), HEAP8)[SAFE_HEAP_INDEX((growMemViews(), HEAP8), ptr, "storing")] = value;
    break;

   case "i16":
    (growMemViews(), HEAP16)[SAFE_HEAP_INDEX((growMemViews(), HEAP16), ((ptr) >> 1), "storing")] = value;
    break;

   case "i32":
    (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), ((ptr) >> 2), "storing")] = value;
    break;

   case "i64":
    (growMemViews(), HEAP64)[SAFE_HEAP_INDEX((growMemViews(), HEAP64), ((ptr) >> 3), "storing")] = BigInt(value);
    break;

   case "float":
    (growMemViews(), HEAPF32)[SAFE_HEAP_INDEX((growMemViews(), HEAPF32), ((ptr) >> 2), "storing")] = value;
    break;

   case "double":
    (growMemViews(), HEAPF64)[SAFE_HEAP_INDEX((growMemViews(), HEAPF64), ((ptr) >> 3), "storing")] = value;
    break;

   case "*":
    (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((ptr) >> 2), "storing")] = value;
    break;

   default:
    abort(`invalid type for setValue: ${type}`);
  }
}

var stackRestore = val => __emscripten_stack_restore(val);

var stackSave = () => _emscripten_stack_get_current();

var wasmMemory;

var UTF8Decoder = globalThis.TextDecoder && new TextDecoder;

var findStringEnd = (heapOrArray, idx, maxBytesToRead, ignoreNul) => {
  var maxIdx = idx + maxBytesToRead;
  if (ignoreNul) return maxIdx;
  // TextDecoder needs to know the byte length in advance, it doesn't stop on
  // null terminator by itself.
  // As a tiny code save trick, compare idx against maxIdx using a negation,
  // so that maxBytesToRead=undefined/NaN means Infinity.
  while (heapOrArray[idx] && !(idx >= maxIdx)) ++idx;
  return idx;
};

/**
     * Given a pointer 'idx' to a null-terminated UTF8-encoded string in the given
     * array that contains uint8 values, returns a copy of that string as a
     * Javascript String object.
     * heapOrArray is either a regular array, or a JavaScript typed array view.
     * @param {number=} idx
     * @param {number=} maxBytesToRead
     * @param {boolean=} ignoreNul - If true, the function will not stop on a NUL character.
     * @return {string}
     */ var UTF8ArrayToString = (heapOrArray, idx = 0, maxBytesToRead, ignoreNul) => {
  var endPtr = findStringEnd(heapOrArray, idx, maxBytesToRead, ignoreNul);
  // When using conditional TextDecoder, skip it for short strings as the overhead of the native call is not worth it.
  if (endPtr - idx > 16 && heapOrArray.buffer && UTF8Decoder) {
    return UTF8Decoder.decode(heapOrArray.buffer instanceof ArrayBuffer ? heapOrArray.subarray(idx, endPtr) : heapOrArray.slice(idx, endPtr));
  }
  var str = "";
  while (idx < endPtr) {
    // For UTF8 byte structure, see:
    // http://en.wikipedia.org/wiki/UTF-8#Description
    // https://www.ietf.org/rfc/rfc2279.txt
    // https://tools.ietf.org/html/rfc3629
    var u0 = heapOrArray[idx++];
    if (!(u0 & 128)) {
      str += String.fromCharCode(u0);
      continue;
    }
    var u1 = heapOrArray[idx++] & 63;
    if ((u0 & 224) == 192) {
      str += String.fromCharCode(((u0 & 31) << 6) | u1);
      continue;
    }
    var u2 = heapOrArray[idx++] & 63;
    if ((u0 & 240) == 224) {
      u0 = ((u0 & 15) << 12) | (u1 << 6) | u2;
    } else {
      u0 = ((u0 & 7) << 18) | (u1 << 12) | (u2 << 6) | (heapOrArray[idx++] & 63);
    }
    if (u0 < 65536) {
      str += String.fromCharCode(u0);
    } else {
      var ch = u0 - 65536;
      str += String.fromCharCode(55296 | (ch >> 10), 56320 | (ch & 1023));
    }
  }
  return str;
};

/**
     * Given a pointer 'ptr' to a null-terminated UTF8-encoded string in the
     * emscripten HEAP, returns a copy of that string as a Javascript String object.
     *
     * @param {number} ptr
     * @param {number=} maxBytesToRead - An optional length that specifies the
     *   maximum number of bytes to read. You can omit this parameter to scan the
     *   string until the first 0 byte. If maxBytesToRead is passed, and the string
     *   at [ptr, ptr+maxBytesToReadr[ contains a null byte in the middle, then the
     *   string will cut short at that byte index.
     * @param {boolean=} ignoreNul - If true, the function will not stop on a NUL character.
     * @return {string}
     */ var UTF8ToString = (ptr, maxBytesToRead, ignoreNul) => ptr ? UTF8ArrayToString((growMemViews(), 
HEAPU8), ptr, maxBytesToRead, ignoreNul) : "";

var ___assert_fail = (condition, filename, line, func) => abort(`Assertion failed: ${UTF8ToString(condition)}, at: ` + [ filename ? UTF8ToString(filename) : "unknown filename", line, func ? UTF8ToString(func) : "unknown function" ]);

var SYSCALLS = {
  varargs: undefined,
  getStr(ptr) {
    var ret = UTF8ToString(ptr);
    return ret;
  }
};

function ___syscall_fcntl64(fd, cmd, varargs) {
  SYSCALLS.varargs = varargs;
  return 0;
}

function ___syscall_ioctl(fd, op, varargs) {
  SYSCALLS.varargs = varargs;
  return 0;
}

function ___syscall_openat(dirfd, path, flags, varargs) {
  SYSCALLS.varargs = varargs;
}

var readEmAsmArgsArray = [];

var readEmAsmArgs = (sigPtr, buf) => {
  readEmAsmArgsArray.length = 0;
  var ch;
  // Most arguments are i32s, so shift the buffer pointer so it is a plain
  // index into HEAP32.
  while (ch = (growMemViews(), HEAPU8)[SAFE_HEAP_INDEX((growMemViews(), HEAPU8), sigPtr++, "loading")]) {
    // Floats are always passed as doubles, so all types except for 'i'
    // are 8 bytes and require alignment.
    var wide = (ch != 105);
    wide &= (ch != 112);
    buf += wide && (buf % 8) ? 4 : 0;
    readEmAsmArgsArray.push(// Special case for pointers under wasm64 or CAN_ADDRESS_2GB mode.
    ch == 112 ? (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((buf) >> 2), "loading")] : ch == 106 ? (growMemViews(), 
    HEAP64)[SAFE_HEAP_INDEX((growMemViews(), HEAP64), ((buf) >> 3), "loading")] : ch == 105 ? (growMemViews(), 
    HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), ((buf) >> 2), "loading")] : (growMemViews(), 
    HEAPF64)[SAFE_HEAP_INDEX((growMemViews(), HEAPF64), ((buf) >> 3), "loading")]);
    buf += wide ? 8 : 4;
  }
  return readEmAsmArgsArray;
};

var runEmAsmFunction = (code, sigPtr, argbuf) => {
  var args = readEmAsmArgs(sigPtr, argbuf);
  return ASM_CONSTS[code](...args);
};

var _emscripten_asm_const_int = (code, sigPtr, argbuf) => runEmAsmFunction(code, sigPtr, argbuf);

var emscriptenGetContextQuantumSize = contextHandle => emAudio[contextHandle]["renderQuantumSize"] || 128;

var _emscripten_audio_context_quantum_size = contextHandle => emscriptenGetContextQuantumSize(contextHandle);

var emAudio = {};

var emAudioCounter = 0;

var emscriptenRegisterAudioObject = object => {
  emAudio[++emAudioCounter] = object;
  return emAudioCounter;
};

var emscriptenGetAudioObject = objectHandle => emAudio[objectHandle];

var _emscripten_create_audio_context = options => {
  // Safari added unprefixed AudioContext support in Safari 14.5 on iOS: https://caniuse.com/audio-api
  var ctx = window.AudioContext || window.webkitAudioContext;
  // Converts AUDIO_CONTEXT_RENDER_SIZE_* into AudioContextRenderSizeCategory
  // enums, otherwise returns a positive int value.
  function readRenderSizeHint(val) {
    return (val < 0) ? "hardware" : (val || "default");
  }
  var opts = options ? {
    latencyHint: UTF8ToString((growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAPU32), ((options) >> 2), "loading")]) || undefined,
    sampleRate: (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((options) + (4)) >> 2), "loading")] || undefined,
    renderSizeHint: readRenderSizeHint((growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAP32), (((options) + (8)) >> 2), "loading")])
  } : undefined;
  return ctx && emscriptenRegisterAudioObject(new ctx(opts));
};

var _emscripten_create_wasm_audio_worklet_node = (contextHandle, name, options, callback, userData) => {
  function readChannelCountArray(heapIndex, numOutputs) {
    if (!heapIndex) return undefined;
    heapIndex = ((heapIndex) >> 2);
    var channelCounts = [];
    while (numOutputs--) channelCounts.push((growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAPU32), heapIndex++, "loading")]);
    return channelCounts;
  }
  var optionsOutputs = options ? (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), 
  HEAP32), (((options) + (4)) >> 2), "loading")] : 0;
  var opts = options ? {
    numberOfInputs: (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), ((options) >> 2), "loading")],
    numberOfOutputs: optionsOutputs,
    outputChannelCount: readChannelCountArray((growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAPU32), (((options) + (8)) >> 2), "loading")], optionsOutputs),
    channelCount: (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((options) + (12)) >> 2), "loading")] || undefined,
    channelCountMode: [ , "clamped-max", "explicit" ][(growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAP32), (((options) + (16)) >> 2), "loading")]],
    channelInterpretation: [ , "discrete" ][(growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), 
    HEAP32), (((options) + (20)) >> 2), "loading")]],
    processorOptions: {
      callback,
      userData,
      samplesPerChannel: emscriptenGetContextQuantumSize(contextHandle)
    }
  } : undefined;
  return emscriptenRegisterAudioObject(new AudioWorkletNode(emAudio[contextHandle], UTF8ToString(name), opts));
};

var _emscripten_create_wasm_audio_worklet_processor_async = (contextHandle, options, callback, userData) => {
  var processorName = UTF8ToString((growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), 
  HEAPU32), ((options) >> 2), "loading")]);
  var numAudioParams = (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), (((options) + (4)) >> 2), "loading")];
  var audioParamDescriptors = (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), 
  HEAPU32), (((options) + (8)) >> 2), "loading")];
  var audioParams = [];
  var paramIndex = 0;
  while (numAudioParams--) {
    audioParams.push({
      name: paramIndex++,
      defaultValue: (growMemViews(), HEAPF32)[SAFE_HEAP_INDEX((growMemViews(), HEAPF32), ((audioParamDescriptors) >> 2), "loading")],
      minValue: (growMemViews(), HEAPF32)[SAFE_HEAP_INDEX((growMemViews(), HEAPF32), (((audioParamDescriptors) + (4)) >> 2), "loading")],
      maxValue: (growMemViews(), HEAPF32)[SAFE_HEAP_INDEX((growMemViews(), HEAPF32), (((audioParamDescriptors) + (8)) >> 2), "loading")],
      automationRate: ((growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), (((audioParamDescriptors) + (12)) >> 2), "loading")] ? "k" : "a") + "-rate"
    });
    audioParamDescriptors += 16;
  }
  emAudio[contextHandle].audioWorklet["port"].postMessage({
    // Deliberately mangled and short names used here ('_wpn', the 'Worklet
    // Processor Name' used as a 'key' to verify the message type so as to
    // not get accidentally mixed with user submitted messages, the remainder
    // for space saving reasons, abbreviated from their variable names).
    "_wpn": processorName,
    audioParams,
    contextHandle,
    callback,
    userData
  });
};

var _emscripten_destroy_audio_context = contextHandle => {
  emAudio[contextHandle].suspend();
  delete emAudio[contextHandle];
};

var _emscripten_destroy_web_audio_node = objectHandle => {
  // Explicitly disconnect the node from Web Audio graph before letting it GC,
  // to work around browser bugs such as https://webkit.org/b/222098#c23
  emAudio[objectHandle].disconnect();
  delete emAudio[objectHandle];
};

var _emscripten_get_now;

// AudioWorkletGlobalScope does not have performance.now()
// (https://github.com/WebAudio/web-audio-api/issues/2527), so if building
// with
// Audio Worklets enabled, do a dynamic check for its presence.
if (globalThis.performance && performance.now) {
  _emscripten_get_now = () => performance.now();
} else {
  _emscripten_get_now = Date.now;
}

var getHeapMax = () => // Stay one Wasm page short of 4GB: while e.g. Chrome is able to allocate
// full 4GB Wasm memories, the size will wrap back to 0 bytes in Wasm side
// for any code that deals with heap sizes, which would require special
// casing all heap size related code to treat 0 specially.
1073741824;

var alignMemory = (size, alignment) => Math.ceil(size / alignment) * alignment;

var growMemory = size => {
  var oldHeapSize = wasmMemory.buffer.byteLength;
  var pages = ((size - oldHeapSize + 65535) / 65536) | 0;
  try {
    // round size grow request up to wasm page size (fixed 64KB per spec)
    wasmMemory.grow(pages);
    // .grow() takes a delta compared to the previous size
    updateMemoryViews();
    return 1;
  } catch (e) {}
};

var _emscripten_resize_heap = requestedSize => {
  var oldSize = (growMemViews(), HEAPU8).length;
  // With CAN_ADDRESS_2GB or MEMORY64, pointers are already unsigned.
  requestedSize >>>= 0;
  // With multithreaded builds, races can happen (another thread might increase the size
  // in between), so return a failure, and let the caller retry.
  if (requestedSize <= oldSize) {
    return false;
  }
  // Memory resize rules:
  // 1.  Always increase heap size to at least the requested size, rounded up
  //     to next page multiple.
  // 2a. If MEMORY_GROWTH_LINEAR_STEP == -1, excessively resize the heap
  //     geometrically: increase the heap size according to
  //     MEMORY_GROWTH_GEOMETRIC_STEP factor (default +20%), At most
  //     overreserve by MEMORY_GROWTH_GEOMETRIC_CAP bytes (default 96MB).
  // 2b. If MEMORY_GROWTH_LINEAR_STEP != -1, excessively resize the heap
  //     linearly: increase the heap size by at least
  //     MEMORY_GROWTH_LINEAR_STEP bytes.
  // 3.  Max size for the heap is capped at 2048MB-WASM_PAGE_SIZE, or by
  //     MAXIMUM_MEMORY, or by ASAN limit, depending on which is smallest
  // 4.  If we were unable to allocate as much memory, it may be due to
  //     over-eager decision to excessively reserve due to (3) above.
  //     Hence if an allocation fails, cut down on the amount of excess
  //     growth, in an attempt to succeed to perform a smaller allocation.
  // A limit is set for how much we can grow. We should not exceed that
  // (the wasm binary specifies it, so if we tried, we'd fail anyhow).
  var maxHeapSize = getHeapMax();
  if (requestedSize > maxHeapSize) {
    return false;
  }
  // Loop through potential heap size increases. If we attempt a too eager
  // reservation that fails, cut down on the attempted size and reserve a
  // smaller bump instead. (max 3 times, chosen somewhat arbitrarily)
  for (var cutDown = 1; cutDown <= 4; cutDown *= 2) {
    var overGrownHeapSize = oldSize * (1 + .2 / cutDown);
    // ensure geometric growth
    // but limit overreserving (default to capping at +96MB overgrowth at most)
    overGrownHeapSize = Math.min(overGrownHeapSize, requestedSize + 100663296);
    var newSize = Math.min(maxHeapSize, alignMemory(Math.max(requestedSize, overGrownHeapSize), 65536));
    var replacement = growMemory(newSize);
    if (replacement) {
      return true;
    }
  }
  return false;
};

/** @param {number=} timeout */ var safeSetTimeout = (func, timeout) => setTimeout(() => {
  callUserCallback(func);
}, timeout);

var _emscripten_sleep = ms => Asyncify.handleSleep(wakeUp => safeSetTimeout(wakeUp, ms));

_emscripten_sleep.isAsync = true;

var _wasmWorkersID = 1;

var _emAudioDispatchProcessorCallback = e => {
  var data = e.data;
  // '_wsc' is short for 'wasm call', trying to use an identifier name that
  // will never conflict with user code. This is used to call both the 3-param
  // call (handle, true, userData) and the variable argument post functions.
  var wasmCall = data["_wsc"];
  wasmCall && getWasmTableEntry(wasmCall)(...data.args);
};

var stackAlloc = sz => __emscripten_stack_alloc(sz);

var _emscripten_start_wasm_audio_worklet_thread_async = (contextHandle, stackLowestAddress, stackSize, callback, userData) => {
  var audioContext = emAudio[contextHandle];
  var audioWorklet = audioContext.audioWorklet;
  var audioWorkletCreationFailed = () => {
    ((a1, a2, a3) => dynCall_viii(callback, a1, a2, a3))(contextHandle, 0, userData);
  };
  // Does browser not support AudioWorklets?
  if (!audioWorklet) {
    return audioWorkletCreationFailed();
  }
  audioWorklet.addModule(locateFile("minisound_web.js")).then(() => {
    // If this browser does not support the up-to-date AudioWorklet standard
    // that has a MessagePort over to the AudioWorklet, then polyfill that by
    // instantiating a dummy AudioWorkletNode to get a MessagePort over.
    // Firefox added support in https://hg-edge.mozilla.org/integration/autoland/rev/ab38a1796126f2b3fc06475ffc5a625059af59c1
    // Chrome ticket: https://crbug.com/446920095
    // Safari ticket: https://webkit.org/b/299386
    if (!audioWorklet["port"]) {
      audioWorklet["port"] = {
        postMessage: msg => {
          if (msg["_boot"]) {
            audioWorklet.bootstrapMessage = new AudioWorkletNode(audioContext, "em-bootstrap", {
              processorOptions: msg
            });
            audioWorklet.bootstrapMessage["port"].onmessage = msg => {
              audioWorklet["port"].onmessage(msg);
            };
          } else {
            audioWorklet.bootstrapMessage["port"].postMessage(msg);
          }
        }
      };
    }
    audioWorklet["port"].postMessage({
      // This is the bootstrap message to the Audio Worklet.
      "_boot": 1,
      // Assign the loaded AudioWorkletGlobalScope a Wasm Worker ID so that
      // it can utilized its own TLS slots, and it is recognized to not be
      // the main browser thread.
      wwID: _wasmWorkersID++,
      wasm: wasmModule,
      wasmMemory,
      stackLowestAddress,
      // sb = stack base
      stackSize
    });
    audioWorklet["port"].onmessage = _emAudioDispatchProcessorCallback;
    ((a1, a2, a3) => dynCall_viii(callback, a1, a2, a3))(contextHandle, 1, userData);
  }).catch(audioWorkletCreationFailed);
};

var _fd_close = fd => 52;

var _fd_read = (fd, iov, iovcnt, pnum) => 52;

var INT53_MAX = 9007199254740992;

var INT53_MIN = -9007199254740992;

var bigintToI53Checked = num => (num < INT53_MIN || num > INT53_MAX) ? NaN : Number(num);

function _fd_seek(fd, offset, whence, newOffset) {
  offset = bigintToI53Checked(offset);
  return 70;
}

var printCharBuffers = [ null, [], [] ];

var printChar = (stream, curr) => {
  var buffer = printCharBuffers[stream];
  if (curr === 0 || curr === 10) {
    (stream === 1 ? out : err)(UTF8ArrayToString(buffer));
    buffer.length = 0;
  } else {
    buffer.push(curr);
  }
};

var flush_NO_FILESYSTEM = () => {
  // flush anything remaining in the buffers during shutdown
  if (printCharBuffers[1].length) printChar(1, 10);
  if (printCharBuffers[2].length) printChar(2, 10);
};

var _fd_write = (fd, iov, iovcnt, pnum) => {
  // hack to support printf in SYSCALLS_REQUIRE_FILESYSTEM=0
  var num = 0;
  for (var i = 0; i < iovcnt; i++) {
    var ptr = (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((iov) >> 2), "loading")];
    var len = (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((iov) + (4)) >> 2), "loading")];
    iov += 8;
    for (var j = 0; j < len; j++) {
      printChar(fd, (growMemViews(), HEAPU8)[SAFE_HEAP_INDEX((growMemViews(), HEAPU8), ptr + j, "loading")]);
    }
    num += len;
  }
  (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((pnum) >> 2), "storing")] = num;
  return 0;
};

var runAndAbortIfError = func => {
  try {
    return func();
  } catch (e) {
    abort(e);
  }
};

var runtimeKeepalivePush = () => {
  runtimeKeepaliveCounter += 1;
};

var runtimeKeepalivePop = () => {
  runtimeKeepaliveCounter -= 1;
};

var Asyncify = {
  instrumentWasmImports(imports) {
    var importPattern = /^(invoke_.*|__asyncjs__.*)$/;
    for (let [x, original] of Object.entries(imports)) {
      if (typeof original == "function") {
        let isAsyncifyImport = original.isAsync || importPattern.test(x);
      }
    }
  },
  instrumentFunction(original) {
    var wrapper = (...args) => {
      Asyncify.exportCallStack.push(original);
      try {
        return original(...args);
      } finally {
        if (!ABORT) {
          var top = Asyncify.exportCallStack.pop();
          Asyncify.maybeStopUnwind();
        }
      }
    };
    Asyncify.funcWrappers.set(original, wrapper);
    return wrapper;
  },
  instrumentWasmExports(exports) {
    var ret = {};
    for (let [x, original] of Object.entries(exports)) {
      if (typeof original == "function") {
        var wrapper = Asyncify.instrumentFunction(original);
        ret[x] = wrapper;
      } else {
        ret[x] = original;
      }
    }
    return ret;
  },
  State: {
    Normal: 0,
    Unwinding: 1,
    Rewinding: 2,
    Disabled: 3
  },
  state: 0,
  StackSize: 131072,
  currData: null,
  handleSleepReturnValue: 0,
  exportCallStack: [],
  callstackFuncToId: new Map,
  callStackIdToFunc: new Map,
  funcWrappers: new Map,
  callStackId: 0,
  asyncPromiseHandlers: null,
  sleepCallbacks: [],
  getCallStackId(func) {
    if (!Asyncify.callstackFuncToId.has(func)) {
      var id = Asyncify.callStackId++;
      Asyncify.callstackFuncToId.set(func, id);
      Asyncify.callStackIdToFunc.set(id, func);
    }
    return Asyncify.callstackFuncToId.get(func);
  },
  maybeStopUnwind() {
    if (Asyncify.currData && Asyncify.state === Asyncify.State.Unwinding && Asyncify.exportCallStack.length === 0) {
      // We just finished unwinding.
      // Be sure to set the state before calling any other functions to avoid
      // possible infinite recursion here (For example in debug pthread builds
      // the dbg() function itself can call back into WebAssembly to get the
      // current pthread_self() pointer).
      Asyncify.state = Asyncify.State.Normal;
      // Keep the runtime alive so that a re-wind can be done later.
      runAndAbortIfError(_asyncify_stop_unwind);
      if (typeof Fibers != "undefined") {
        Fibers.trampoline();
      }
    }
  },
  whenDone() {
    return new Promise((resolve, reject) => {
      Asyncify.asyncPromiseHandlers = {
        resolve,
        reject
      };
    });
  },
  allocateData() {
    // An asyncify data structure has three fields:
    //  0  current stack pos
    //  4  max stack pos
    //  8  id of function at bottom of the call stack (callStackIdToFunc[id] == wasm func)
    // The Asyncify ABI only interprets the first two fields, the rest is for the runtime.
    // We also embed a stack in the same memory region here, right next to the structure.
    // This struct is also defined as asyncify_data_t in emscripten/fiber.h
    var ptr = _malloc(12 + Asyncify.StackSize);
    Asyncify.setDataHeader(ptr, ptr + 12, Asyncify.StackSize);
    Asyncify.setDataRewindFunc(ptr);
    return ptr;
  },
  setDataHeader(ptr, stack, stackSize) {
    (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), ((ptr) >> 2), "storing")] = stack;
    (growMemViews(), HEAPU32)[SAFE_HEAP_INDEX((growMemViews(), HEAPU32), (((ptr) + (4)) >> 2), "storing")] = stack + stackSize;
  },
  setDataRewindFunc(ptr) {
    var bottomOfCallStack = Asyncify.exportCallStack[0];
    var rewindId = Asyncify.getCallStackId(bottomOfCallStack);
    (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), (((ptr) + (8)) >> 2), "storing")] = rewindId;
  },
  getDataRewindFunc(ptr) {
    var id = (growMemViews(), HEAP32)[SAFE_HEAP_INDEX((growMemViews(), HEAP32), (((ptr) + (8)) >> 2), "loading")];
    var func = Asyncify.callStackIdToFunc.get(id);
    return func;
  },
  doRewind(ptr) {
    var original = Asyncify.getDataRewindFunc(ptr);
    var func = Asyncify.funcWrappers.get(original);
    // Once we have rewound and the stack we no longer need to artificially
    // keep the runtime alive.
    return func();
  },
  handleSleep(startAsync) {
    if (ABORT) return;
    if (Asyncify.state === Asyncify.State.Normal) {
      // Prepare to sleep. Call startAsync, and see what happens:
      // if the code decided to call our callback synchronously,
      // then no async operation was in fact begun, and we don't
      // need to do anything.
      var reachedCallback = false;
      var reachedAfterCallback = false;
      startAsync((handleSleepReturnValue = 0) => {
        if (ABORT) return;
        Asyncify.handleSleepReturnValue = handleSleepReturnValue;
        reachedCallback = true;
        if (!reachedAfterCallback) {
          // We are happening synchronously, so no need for async.
          return;
        }
        Asyncify.state = Asyncify.State.Rewinding;
        runAndAbortIfError(() => _asyncify_start_rewind(Asyncify.currData));
        if (typeof MainLoop != "undefined" && MainLoop.func) {
          MainLoop.resume();
        }
        var asyncWasmReturnValue, isError = false;
        try {
          asyncWasmReturnValue = Asyncify.doRewind(Asyncify.currData);
        } catch (err) {
          asyncWasmReturnValue = err;
          isError = true;
        }
        // Track whether the return value was handled by any promise handlers.
        var handled = false;
        if (!Asyncify.currData) {
          // All asynchronous execution has finished.
          // `asyncWasmReturnValue` now contains the final
          // return value of the exported async WASM function.
          // Note: `asyncWasmReturnValue` is distinct from
          // `Asyncify.handleSleepReturnValue`.
          // `Asyncify.handleSleepReturnValue` contains the return
          // value of the last C function to have executed
          // `Asyncify.handleSleep()`, whereas `asyncWasmReturnValue`
          // contains the return value of the exported WASM function
          // that may have called C functions that
          // call `Asyncify.handleSleep()`.
          var asyncPromiseHandlers = Asyncify.asyncPromiseHandlers;
          if (asyncPromiseHandlers) {
            Asyncify.asyncPromiseHandlers = null;
            (isError ? asyncPromiseHandlers.reject : asyncPromiseHandlers.resolve)(asyncWasmReturnValue);
            handled = true;
          }
        }
        if (isError && !handled) {
          // If there was an error and it was not handled by now, we have no choice but to
          // rethrow that error into the global scope where it can be caught only by
          // `onerror` or `onunhandledpromiserejection`.
          throw asyncWasmReturnValue;
        }
      });
      reachedAfterCallback = true;
      if (!reachedCallback) {
        // A true async operation was begun; start a sleep.
        Asyncify.state = Asyncify.State.Unwinding;
        // TODO: reuse, don't alloc/free every sleep
        Asyncify.currData = Asyncify.allocateData();
        if (typeof MainLoop != "undefined" && MainLoop.func) {
          MainLoop.pause();
        }
        runAndAbortIfError(() => _asyncify_start_unwind(Asyncify.currData));
      }
    } else if (Asyncify.state === Asyncify.State.Rewinding) {
      // Stop a resume.
      Asyncify.state = Asyncify.State.Normal;
      runAndAbortIfError(_asyncify_stop_rewind);
      _free(Asyncify.currData);
      Asyncify.currData = null;
      // Call all sleep callbacks now that the sleep-resume is all done.
      Asyncify.sleepCallbacks.forEach(callUserCallback);
    } else {
      abort(`invalid state: ${Asyncify.state}`);
    }
    return Asyncify.handleSleepReturnValue;
  },
  handleAsync: startAsync => Asyncify.handleSleep(wakeUp => {
    // TODO: add error handling as a second param when handleSleep implements it.
    startAsync().then(wakeUp);
  })
};

var getCFunc = ident => {
  var func = Module["_" + ident];
  // closure exported function
  return func;
};

var writeArrayToMemory = (array, buffer) => {
  (growMemViews(), HEAP8).set(array, buffer);
};

var lengthBytesUTF8 = str => {
  var len = 0;
  for (var i = 0; i < str.length; ++i) {
    // Gotcha: charCodeAt returns a 16-bit word that is a UTF-16 encoded code
    // unit, not a Unicode code point of the character! So decode
    // UTF16->UTF32->UTF8.
    // See http://unicode.org/faq/utf_bom.html#utf16-3
    var c = str.charCodeAt(i);
    // possibly a lead surrogate
    if (c <= 127) {
      len++;
    } else if (c <= 2047) {
      len += 2;
    } else if (c >= 55296 && c <= 57343) {
      len += 4;
      ++i;
    } else {
      len += 3;
    }
  }
  return len;
};

var stringToUTF8Array = (str, heap, outIdx, maxBytesToWrite) => {
  // Parameter maxBytesToWrite is not optional. Negative values, 0, null,
  // undefined and false each don't write out any bytes.
  if (!(maxBytesToWrite > 0)) return 0;
  var startIdx = outIdx;
  var endIdx = outIdx + maxBytesToWrite - 1;
  // -1 for string null terminator.
  for (var i = 0; i < str.length; ++i) {
    // For UTF8 byte structure, see http://en.wikipedia.org/wiki/UTF-8#Description
    // and https://www.ietf.org/rfc/rfc2279.txt
    // and https://tools.ietf.org/html/rfc3629
    var u = str.codePointAt(i);
    if (u <= 127) {
      if (outIdx >= endIdx) break;
      heap[outIdx++] = u;
    } else if (u <= 2047) {
      if (outIdx + 1 >= endIdx) break;
      heap[outIdx++] = 192 | (u >> 6);
      heap[outIdx++] = 128 | (u & 63);
    } else if (u <= 65535) {
      if (outIdx + 2 >= endIdx) break;
      heap[outIdx++] = 224 | (u >> 12);
      heap[outIdx++] = 128 | ((u >> 6) & 63);
      heap[outIdx++] = 128 | (u & 63);
    } else {
      if (outIdx + 3 >= endIdx) break;
      heap[outIdx++] = 240 | (u >> 18);
      heap[outIdx++] = 128 | ((u >> 12) & 63);
      heap[outIdx++] = 128 | ((u >> 6) & 63);
      heap[outIdx++] = 128 | (u & 63);
      // Gotcha: if codePoint is over 0xFFFF, it is represented as a surrogate pair in UTF-16.
      // We need to manually skip over the second code unit for correct iteration.
      i++;
    }
  }
  // Null-terminate the pointer to the buffer.
  heap[outIdx] = 0;
  return outIdx - startIdx;
};

var stringToUTF8 = (str, outPtr, maxBytesToWrite) => stringToUTF8Array(str, (growMemViews(), 
HEAPU8), outPtr, maxBytesToWrite);

var stringToUTF8OnStack = str => {
  var size = lengthBytesUTF8(str) + 1;
  var ret = stackAlloc(size);
  stringToUTF8(str, ret, size);
  return ret;
};

/**
     * @param {string|null=} returnType
     * @param {Array=} argTypes
     * @param {Array=} args
     * @param {Object=} opts
     */ var ccall = (ident, returnType, argTypes, args, opts) => {
  // For fast lookup of conversion functions
  var toC = {
    "string": str => {
      var ret = 0;
      if (str !== null && str !== undefined && str !== 0) {
        // null string
        ret = stringToUTF8OnStack(str);
      }
      return ret;
    },
    "array": arr => {
      var ret = stackAlloc(arr.length);
      writeArrayToMemory(arr, ret);
      return ret;
    }
  };
  function convertReturnValue(ret) {
    if (returnType === "string") {
      return UTF8ToString(ret);
    }
    if (returnType === "boolean") return Boolean(ret);
    return ret;
  }
  var func = getCFunc(ident);
  var cArgs = [];
  var stack = 0;
  if (args) {
    for (var i = 0; i < args.length; i++) {
      var converter = toC[argTypes[i]];
      if (converter) {
        if (stack === 0) stack = stackSave();
        cArgs[i] = converter(args[i]);
      } else {
        cArgs[i] = args[i];
      }
    }
  }
  // Data for a previous async operation that was in flight before us.
  var previousAsync = Asyncify.currData;
  var ret = func(...cArgs);
  function onDone(ret) {
    runtimeKeepalivePop();
    if (stack !== 0) stackRestore(stack);
    return convertReturnValue(ret);
  }
  var asyncMode = opts?.async;
  // Keep the runtime alive through all calls. Note that this call might not be
  // async, but for simplicity we push and pop in all calls.
  runtimeKeepalivePush();
  if (Asyncify.currData != previousAsync) {
    // This is a new async operation. The wasm is paused and has unwound its stack.
    // We need to return a Promise that resolves the return value
    // once the stack is rewound and execution finishes.
    return Asyncify.whenDone().then(onDone);
  }
  ret = onDone(ret);
  // If this is an async ccall, ensure we return a promise
  if (asyncMode) return Promise.resolve(ret);
  return ret;
};

// End JS library code
// include: postlibrary.js
// This file is included after the automatically-generated JS library code
// but before the wasm module is created.
{
  // With WASM_ESM_INTEGRATION this has to happen at the top level and not
  // delayed until processModuleArgs.
  initMemory();
  // Begin ATMODULES hooks
  if (Module["noExitRuntime"]) noExitRuntime = Module["noExitRuntime"];
  if (Module["print"]) out = Module["print"];
  if (Module["printErr"]) err = Module["printErr"];
  if (Module["wasmBinary"]) wasmBinary = Module["wasmBinary"];
  // End ATMODULES hooks
  if (Module["arguments"]) arguments_ = Module["arguments"];
  if (Module["thisProgram"]) thisProgram = Module["thisProgram"];
  if (Module["preInit"]) {
    if (typeof Module["preInit"] == "function") Module["preInit"] = [ Module["preInit"] ];
    while (Module["preInit"].length > 0) {
      Module["preInit"].shift()();
    }
  }
}

// Begin runtime exports
Module["ccall"] = ccall;

// End runtime exports
// Begin JS library exports
// End JS library exports
// end include: postlibrary.js
var ASM_CONSTS = {
  45176: ($0, $1, $2, $3, $4) => {
    if (typeof window === "undefined" || (window.AudioContext || window.webkitAudioContext) === undefined) {
      return 0;
    }
    if (typeof (window.miniaudio) === "undefined") {
      window.miniaudio = {
        referenceCount: 0
      };
      window.miniaudio.device_type = {};
      window.miniaudio.device_type.playback = $0;
      window.miniaudio.device_type.capture = $1;
      window.miniaudio.device_type.duplex = $2;
      window.miniaudio.device_state = {};
      window.miniaudio.device_state.stopped = $3;
      window.miniaudio.device_state.started = $4;
      let miniaudio = window.miniaudio;
      miniaudio.devices = [];
      miniaudio.track_device = function(device) {
        for (var iDevice = 0; iDevice < miniaudio.devices.length; ++iDevice) {
          if (miniaudio.devices[iDevice] == null) {
            miniaudio.devices[iDevice] = device;
            return iDevice;
          }
        }
        miniaudio.devices.push(device);
        return miniaudio.devices.length - 1;
      };
      miniaudio.untrack_device_by_index = function(deviceIndex) {
        miniaudio.devices[deviceIndex] = null;
        while (miniaudio.devices.length > 0) {
          if (miniaudio.devices[miniaudio.devices.length - 1] == null) {
            miniaudio.devices.pop();
          } else {
            break;
          }
        }
      };
      miniaudio.untrack_device = function(device) {
        for (var iDevice = 0; iDevice < miniaudio.devices.length; ++iDevice) {
          if (miniaudio.devices[iDevice] == device) {
            return miniaudio.untrack_device_by_index(iDevice);
          }
        }
      };
      miniaudio.get_device_by_index = function(deviceIndex) {
        return miniaudio.devices[deviceIndex];
      };
      miniaudio.unlock_event_types = (function() {
        return [ "touchend", "click" ];
      })();
      miniaudio.unlock = function() {
        for (var i = 0; i < miniaudio.devices.length; ++i) {
          var device = miniaudio.devices[i];
          if (device != null && device.webaudio != null && device.state === miniaudio.device_state.started) {
            device.webaudio.resume().then(() => {
              _ma_device__on_notification_unlocked(device.pDevice);
            }, error => {
              console.error("Failed to resume audiocontext", error);
            });
          }
        }
        miniaudio.unlock_event_types.map(function(event_type) {
          document.removeEventListener(event_type, miniaudio.unlock, true);
        });
      };
      miniaudio.unlock_event_types.map(function(event_type) {
        document.addEventListener(event_type, miniaudio.unlock, true);
      });
    }
    window.miniaudio.referenceCount += 1;
    return 1;
  },
  47354: () => {
    if (typeof (window.miniaudio) !== "undefined") {
      miniaudio.unlock_event_types.map(function(event_type) {
        document.removeEventListener(event_type, miniaudio.unlock, true);
      });
      window.miniaudio.referenceCount -= 1;
      if (window.miniaudio.referenceCount === 0) {
        delete window.miniaudio;
      }
    }
  },
  47644: () => (navigator.mediaDevices !== undefined && navigator.mediaDevices.getUserMedia !== undefined),
  47748: () => {
    try {
      var temp = new (window.AudioContext || window.webkitAudioContext);
      var sampleRate = temp.sampleRate;
      temp.close();
      return sampleRate;
    } catch (e) {
      return 0;
    }
  },
  47919: ($0, $1) => window.miniaudio.track_device({
    webaudio: emscriptenGetAudioObject($0),
    state: 1,
    pDevice: $1
  }),
  48028: ($0, $1) => {
    var getUserMediaResult = 0;
    var audioWorklet = emscriptenGetAudioObject($0);
    var audioContext = emscriptenGetAudioObject($1);
    navigator.mediaDevices.getUserMedia({
      audio: true,
      video: false
    }).then(function(stream) {
      audioContext.streamNode = audioContext.createMediaStreamSource(stream);
      audioContext.streamNode.connect(audioWorklet);
      audioWorklet.connect(audioContext.destination);
      getUserMediaResult = 0;
    }).catch(function(error) {
      console.log("navigator.mediaDevices.getUserMedia Failed: " + error);
      getUserMediaResult = -1;
    });
    return getUserMediaResult;
  },
  48590: ($0, $1) => {
    var audioWorklet = emscriptenGetAudioObject($0);
    var audioContext = emscriptenGetAudioObject($1);
    audioWorklet.connect(audioContext.destination);
    return 0;
  },
  48750: $0 => emscriptenGetAudioObject($0).sampleRate,
  48802: $0 => {
    var device = window.miniaudio.get_device_by_index($0);
    if (device.streamNode !== undefined) {
      device.streamNode.disconnect();
      device.streamNode = undefined;
    }
    device.pDevice = undefined;
  },
  48993: $0 => {
    window.miniaudio.untrack_device_by_index($0);
  },
  49043: $0 => {
    var device = window.miniaudio.get_device_by_index($0);
    device.webaudio.resume();
    device.state = window.miniaudio.device_state.started;
  },
  49182: $0 => {
    var device = window.miniaudio.get_device_by_index($0);
    device.webaudio.suspend();
    device.state = window.miniaudio.device_state.stopped;
  }
};

// Imports from the Wasm binary.
var _engine_alloc, _engine_init, _engine_uninit, _engine_start, _engine_load_sound, _free, _engine_generate_waveform, _engine_generate_noise, _engine_generate_pulse, _rec_alloc, _rec_uninit, _rec_end, _malloc, _recorder_alloc, _recorder_init, _recorder_uninit, _recorder_get_is_recording, _recorder_start, _recorder_save_rec, _recorder_resume_rec, _recorder_pause_rec, _sound_alloc, _sound_unload, _sound_play, _sound_pause, _sound_stop, _sound_get_volume, _sound_set_volume, _sound_get_duration, _sound_get_is_playing, _sound_get_cursor, _sound_set_cursor, _sound_get_pitch, _sound_set_pitch, _sound_get_encoded_data, _sound_get_waveform_data, _sound_get_noise_data, _sound_get_pulse_data, _encoded_sound_data_get_is_looped, _encoded_sound_data_set_looped, _pulse_sound_data_get_freq, _pulse_sound_data_set_freq, _pulse_sound_data_get_duty_cycle, _pulse_sound_data_set_duty_cycle, _waveform_sound_data_get_type, _waveform_sound_data_set_type, _waveform_sound_data_get_freq, _waveform_sound_data_set_freq, _ma_device__on_notification_unlocked, _ma_malloc_emscripten, _ma_free_emscripten, _ma_device_process_pcm_frames_capture__webaudio, _ma_device_process_pcm_frames_playback__webaudio, _emscripten_stack_get_end, _emscripten_stack_get_base, _sbrk, _emscripten_get_sbrk_ptr, _emscripten_stack_init, _emscripten_stack_get_free, __emscripten_stack_restore, __emscripten_stack_alloc, _emscripten_stack_get_current, __emscripten_wasm_worker_initialize, dynCall_iiiii, dynCall_iiji, dynCall_ii, dynCall_vi, dynCall_viiii, dynCall_vii, dynCall_iiiji, dynCall_iij, dynCall_iiiiiii, dynCall_iii, dynCall_iiii, dynCall_viii, dynCall_iiiiiiii, dynCall_jii, dynCall_iiiiiiiii, dynCall_iiiiii, dynCall_viiiii, dynCall_jiji, dynCall_iidiiii, _asyncify_start_unwind, _asyncify_stop_unwind, _asyncify_start_rewind, _asyncify_stop_rewind, __indirect_function_table, wasmTable;

function assignWasmExports(wasmExports) {
  _engine_alloc = Module["_engine_alloc"] = wasmExports["engine_alloc"];
  _engine_init = Module["_engine_init"] = wasmExports["engine_init"];
  _engine_uninit = Module["_engine_uninit"] = wasmExports["engine_uninit"];
  _engine_start = Module["_engine_start"] = wasmExports["engine_start"];
  _engine_load_sound = Module["_engine_load_sound"] = wasmExports["engine_load_sound"];
  _free = Module["_free"] = wasmExports["free"];
  _engine_generate_waveform = Module["_engine_generate_waveform"] = wasmExports["engine_generate_waveform"];
  _engine_generate_noise = Module["_engine_generate_noise"] = wasmExports["engine_generate_noise"];
  _engine_generate_pulse = Module["_engine_generate_pulse"] = wasmExports["engine_generate_pulse"];
  _rec_alloc = Module["_rec_alloc"] = wasmExports["rec_alloc"];
  _rec_uninit = Module["_rec_uninit"] = wasmExports["rec_uninit"];
  _rec_end = Module["_rec_end"] = wasmExports["rec_end"];
  _malloc = Module["_malloc"] = wasmExports["malloc"];
  _recorder_alloc = Module["_recorder_alloc"] = wasmExports["recorder_alloc"];
  _recorder_init = Module["_recorder_init"] = wasmExports["recorder_init"];
  _recorder_uninit = Module["_recorder_uninit"] = wasmExports["recorder_uninit"];
  _recorder_get_is_recording = Module["_recorder_get_is_recording"] = wasmExports["recorder_get_is_recording"];
  _recorder_start = Module["_recorder_start"] = wasmExports["recorder_start"];
  _recorder_save_rec = Module["_recorder_save_rec"] = wasmExports["recorder_save_rec"];
  _recorder_resume_rec = Module["_recorder_resume_rec"] = wasmExports["recorder_resume_rec"];
  _recorder_pause_rec = Module["_recorder_pause_rec"] = wasmExports["recorder_pause_rec"];
  _sound_alloc = Module["_sound_alloc"] = wasmExports["sound_alloc"];
  _sound_unload = Module["_sound_unload"] = wasmExports["sound_unload"];
  _sound_play = Module["_sound_play"] = wasmExports["sound_play"];
  _sound_pause = Module["_sound_pause"] = wasmExports["sound_pause"];
  _sound_stop = Module["_sound_stop"] = wasmExports["sound_stop"];
  _sound_get_volume = Module["_sound_get_volume"] = wasmExports["sound_get_volume"];
  _sound_set_volume = Module["_sound_set_volume"] = wasmExports["sound_set_volume"];
  _sound_get_duration = Module["_sound_get_duration"] = wasmExports["sound_get_duration"];
  _sound_get_is_playing = Module["_sound_get_is_playing"] = wasmExports["sound_get_is_playing"];
  _sound_get_cursor = Module["_sound_get_cursor"] = wasmExports["sound_get_cursor"];
  _sound_set_cursor = Module["_sound_set_cursor"] = wasmExports["sound_set_cursor"];
  _sound_get_pitch = Module["_sound_get_pitch"] = wasmExports["sound_get_pitch"];
  _sound_set_pitch = Module["_sound_set_pitch"] = wasmExports["sound_set_pitch"];
  _sound_get_encoded_data = Module["_sound_get_encoded_data"] = wasmExports["sound_get_encoded_data"];
  _sound_get_waveform_data = Module["_sound_get_waveform_data"] = wasmExports["sound_get_waveform_data"];
  _sound_get_noise_data = Module["_sound_get_noise_data"] = wasmExports["sound_get_noise_data"];
  _sound_get_pulse_data = Module["_sound_get_pulse_data"] = wasmExports["sound_get_pulse_data"];
  _encoded_sound_data_get_is_looped = Module["_encoded_sound_data_get_is_looped"] = wasmExports["encoded_sound_data_get_is_looped"];
  _encoded_sound_data_set_looped = Module["_encoded_sound_data_set_looped"] = wasmExports["encoded_sound_data_set_looped"];
  _pulse_sound_data_get_freq = Module["_pulse_sound_data_get_freq"] = wasmExports["pulse_sound_data_get_freq"];
  _pulse_sound_data_set_freq = Module["_pulse_sound_data_set_freq"] = wasmExports["pulse_sound_data_set_freq"];
  _pulse_sound_data_get_duty_cycle = Module["_pulse_sound_data_get_duty_cycle"] = wasmExports["pulse_sound_data_get_duty_cycle"];
  _pulse_sound_data_set_duty_cycle = Module["_pulse_sound_data_set_duty_cycle"] = wasmExports["pulse_sound_data_set_duty_cycle"];
  _waveform_sound_data_get_type = Module["_waveform_sound_data_get_type"] = wasmExports["waveform_sound_data_get_type"];
  _waveform_sound_data_set_type = Module["_waveform_sound_data_set_type"] = wasmExports["waveform_sound_data_set_type"];
  _waveform_sound_data_get_freq = Module["_waveform_sound_data_get_freq"] = wasmExports["waveform_sound_data_get_freq"];
  _waveform_sound_data_set_freq = Module["_waveform_sound_data_set_freq"] = wasmExports["waveform_sound_data_set_freq"];
  _ma_device__on_notification_unlocked = Module["_ma_device__on_notification_unlocked"] = wasmExports["ma_device__on_notification_unlocked"];
  _ma_malloc_emscripten = Module["_ma_malloc_emscripten"] = wasmExports["ma_malloc_emscripten"];
  _ma_free_emscripten = Module["_ma_free_emscripten"] = wasmExports["ma_free_emscripten"];
  _ma_device_process_pcm_frames_capture__webaudio = Module["_ma_device_process_pcm_frames_capture__webaudio"] = wasmExports["ma_device_process_pcm_frames_capture__webaudio"];
  _ma_device_process_pcm_frames_playback__webaudio = Module["_ma_device_process_pcm_frames_playback__webaudio"] = wasmExports["ma_device_process_pcm_frames_playback__webaudio"];
  _emscripten_stack_get_end = wasmExports["emscripten_stack_get_end"];
  _emscripten_stack_get_base = wasmExports["emscripten_stack_get_base"];
  _sbrk = wasmExports["sbrk"];
  _emscripten_get_sbrk_ptr = wasmExports["emscripten_get_sbrk_ptr"];
  _emscripten_stack_init = wasmExports["emscripten_stack_init"];
  _emscripten_stack_get_free = wasmExports["emscripten_stack_get_free"];
  __emscripten_stack_restore = wasmExports["_emscripten_stack_restore"];
  __emscripten_stack_alloc = wasmExports["_emscripten_stack_alloc"];
  _emscripten_stack_get_current = wasmExports["emscripten_stack_get_current"];
  __emscripten_wasm_worker_initialize = wasmExports["_emscripten_wasm_worker_initialize"];
  dynCall_iiiii = dynCalls["iiiii"] = wasmExports["dynCall_iiiii"];
  dynCall_iiji = dynCalls["iiji"] = wasmExports["dynCall_iiji"];
  dynCall_ii = dynCalls["ii"] = wasmExports["dynCall_ii"];
  dynCall_vi = dynCalls["vi"] = wasmExports["dynCall_vi"];
  dynCall_viiii = dynCalls["viiii"] = wasmExports["dynCall_viiii"];
  dynCall_vii = dynCalls["vii"] = wasmExports["dynCall_vii"];
  dynCall_iiiji = dynCalls["iiiji"] = wasmExports["dynCall_iiiji"];
  dynCall_iij = dynCalls["iij"] = wasmExports["dynCall_iij"];
  dynCall_iiiiiii = dynCalls["iiiiiii"] = wasmExports["dynCall_iiiiiii"];
  dynCall_iii = dynCalls["iii"] = wasmExports["dynCall_iii"];
  dynCall_iiii = dynCalls["iiii"] = wasmExports["dynCall_iiii"];
  dynCall_viii = dynCalls["viii"] = wasmExports["dynCall_viii"];
  dynCall_iiiiiiii = dynCalls["iiiiiiii"] = wasmExports["dynCall_iiiiiiii"];
  dynCall_jii = dynCalls["jii"] = wasmExports["dynCall_jii"];
  dynCall_iiiiiiiii = dynCalls["iiiiiiiii"] = wasmExports["dynCall_iiiiiiiii"];
  dynCall_iiiiii = dynCalls["iiiiii"] = wasmExports["dynCall_iiiiii"];
  dynCall_viiiii = dynCalls["viiiii"] = wasmExports["dynCall_viiiii"];
  dynCall_jiji = dynCalls["jiji"] = wasmExports["dynCall_jiji"];
  dynCall_iidiiii = dynCalls["iidiiii"] = wasmExports["dynCall_iidiiii"];
  _asyncify_start_unwind = wasmExports["asyncify_start_unwind"];
  _asyncify_stop_unwind = wasmExports["asyncify_stop_unwind"];
  _asyncify_start_rewind = wasmExports["asyncify_start_rewind"];
  _asyncify_stop_rewind = wasmExports["asyncify_stop_rewind"];
  __indirect_function_table = wasmTable = wasmExports["__indirect_function_table"];
}

var wasmImports;

function assignWasmImports() {
  wasmImports = {
    /** @export */ __assert_fail: ___assert_fail,
    /** @export */ __syscall_fcntl64: ___syscall_fcntl64,
    /** @export */ __syscall_ioctl: ___syscall_ioctl,
    /** @export */ __syscall_openat: ___syscall_openat,
    /** @export */ alignfault,
    /** @export */ emscripten_asm_const_int: _emscripten_asm_const_int,
    /** @export */ emscripten_audio_context_quantum_size: _emscripten_audio_context_quantum_size,
    /** @export */ emscripten_create_audio_context: _emscripten_create_audio_context,
    /** @export */ emscripten_create_wasm_audio_worklet_node: _emscripten_create_wasm_audio_worklet_node,
    /** @export */ emscripten_create_wasm_audio_worklet_processor_async: _emscripten_create_wasm_audio_worklet_processor_async,
    /** @export */ emscripten_destroy_audio_context: _emscripten_destroy_audio_context,
    /** @export */ emscripten_destroy_web_audio_node: _emscripten_destroy_web_audio_node,
    /** @export */ emscripten_get_now: _emscripten_get_now,
    /** @export */ emscripten_resize_heap: _emscripten_resize_heap,
    /** @export */ emscripten_sleep: _emscripten_sleep,
    /** @export */ emscripten_start_wasm_audio_worklet_thread_async: _emscripten_start_wasm_audio_worklet_thread_async,
    /** @export */ fd_close: _fd_close,
    /** @export */ fd_read: _fd_read,
    /** @export */ fd_seek: _fd_seek,
    /** @export */ fd_write: _fd_write,
    /** @export */ memory: wasmMemory,
    /** @export */ segfault
  };
}

// include: postamble.js
// === Auto-generated postamble setup entry stuff ===
function stackCheckInit() {
  // This is normally called automatically during __wasm_call_ctors but need to
  // get these values before even running any of the ctors so we call it redundantly
  // here.
  _emscripten_stack_init();
  // TODO(sbc): Move writeStackCookie to native to to avoid this.
  writeStackCookie();
}

function run() {
  if (runDependencies > 0) {
    dependenciesFulfilled = run;
    return;
  }
  if ((ENVIRONMENT_IS_WASM_WORKER)) {
    initRuntime();
    return;
  }
  stackCheckInit();
  preRun();
  // a preRun added a dependency, run will be called later
  if (runDependencies > 0) {
    dependenciesFulfilled = run;
    return;
  }
  function doRun() {
    // run may have just been called through dependencies being fulfilled just in this very frame,
    // or while the async setStatus time below was happening
    Module["calledRun"] = true;
    if (ABORT) return;
    initRuntime();
    Module["onRuntimeInitialized"]?.();
    postRun();
  }
  if (Module["setStatus"]) {
    Module["setStatus"]("Running...");
    setTimeout(() => {
      setTimeout(() => Module["setStatus"](""), 1);
      doRun();
    }, 1);
  } else {
    doRun();
  }
  checkStackCookie();
}

var wasmExports;

if ((!(ENVIRONMENT_IS_WASM_WORKER))) {
  // Call createWasm on startup if we are the main thread.
  // Worker threads call this once they receive the module via postMessage
  // With async instantation wasmExports is assigned asynchronously when the
  // instance is received.
  createWasm();
  run();
}
