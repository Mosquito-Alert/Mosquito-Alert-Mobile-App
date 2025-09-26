// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _3: (o, t) => typeof o === t,
      _4: (o, c) => o instanceof c,
      _7: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._7(f,arguments.length,x0) }),
      _8: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._8(f,arguments.length,x0) }),
      _36: () => new Array(),
      _37: x0 => new Array(x0),
      _39: x0 => x0.length,
      _41: (x0,x1) => x0[x1],
      _42: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _87: x0 => x0.click(),
      _88: x0 => x0.buffer,
      _89: x0 => x0.wasmMemory,
      _90: () => globalThis.window._flutter_skwasmInstance,
      _91: x0 => x0.rasterStartMilliseconds,
      _92: x0 => x0.rasterEndMilliseconds,
      _93: x0 => x0.imageBitmaps,
      _120: x0 => x0.remove(),
      _121: (x0,x1) => x0.append(x1),
      _122: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _123: (x0,x1) => x0.querySelector(x1),
      _125: (x0,x1) => x0.removeChild(x1),
      _203: x0 => x0.stopPropagation(),
      _204: x0 => x0.preventDefault(),
      _206: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _250: x0 => x0.select(),
      _251: (x0,x1) => x0.execCommand(x1),
      _253: x0 => x0.unlock(),
      _254: x0 => x0.getReader(),
      _255: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _256: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _257: (x0,x1) => x0.item(x1),
      _258: x0 => x0.next(),
      _259: x0 => x0.now(),
      _260: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._260(f,arguments.length,x0) }),
      _261: (x0,x1) => x0.addListener(x1),
      _262: (x0,x1) => x0.removeListener(x1),
      _263: (x0,x1) => x0.matchMedia(x1),
      _264: (x0,x1) => x0.revokeObjectURL(x1),
      _265: x0 => x0.close(),
      _266: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _267: x0 => new window.ImageDecoder(x0),
      _268: x0 => ({frameIndex: x0}),
      _269: (x0,x1) => x0.decode(x1),
      _270: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._270(f,arguments.length,x0) }),
      _271: (x0,x1) => x0.getModifierState(x1),
      _272: (x0,x1) => x0.removeProperty(x1),
      _273: (x0,x1) => x0.prepend(x1),
      _274: x0 => x0.disconnect(),
      _275: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._275(f,arguments.length,x0) }),
      _276: (x0,x1) => x0.getAttribute(x1),
      _277: (x0,x1) => x0.contains(x1),
      _278: x0 => x0.blur(),
      _279: x0 => x0.hasFocus(),
      _280: (x0,x1) => x0.hasAttribute(x1),
      _281: (x0,x1) => x0.getModifierState(x1),
      _285: (x0,x1) => x0.appendChild(x1),
      _286: (x0,x1) => x0.createTextNode(x1),
      _287: (x0,x1) => x0.removeAttribute(x1),
      _288: x0 => x0.getBoundingClientRect(),
      _289: (x0,x1) => x0.observe(x1),
      _290: x0 => x0.disconnect(),
      _291: (x0,x1) => x0.closest(x1),
      _701: () => globalThis.window.flutterConfiguration,
      _702: x0 => x0.assetBase,
      _708: x0 => x0.debugShowSemanticsNodes,
      _709: x0 => x0.hostElement,
      _710: x0 => x0.multiViewEnabled,
      _711: x0 => x0.nonce,
      _713: x0 => x0.fontFallbackBaseUrl,
      _717: x0 => x0.console,
      _718: x0 => x0.devicePixelRatio,
      _719: x0 => x0.document,
      _720: x0 => x0.history,
      _721: x0 => x0.innerHeight,
      _722: x0 => x0.innerWidth,
      _723: x0 => x0.location,
      _724: x0 => x0.navigator,
      _725: x0 => x0.visualViewport,
      _726: x0 => x0.performance,
      _728: x0 => x0.URL,
      _730: (x0,x1) => x0.getComputedStyle(x1),
      _731: x0 => x0.screen,
      _732: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._732(f,arguments.length,x0) }),
      _733: (x0,x1) => x0.requestAnimationFrame(x1),
      _738: (x0,x1) => x0.warn(x1),
      _740: (x0,x1) => x0.debug(x1),
      _741: x0 => globalThis.parseFloat(x0),
      _742: () => globalThis.window,
      _743: () => globalThis.Intl,
      _744: () => globalThis.Symbol,
      _745: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _747: x0 => x0.clipboard,
      _748: x0 => x0.maxTouchPoints,
      _749: x0 => x0.vendor,
      _750: x0 => x0.language,
      _751: x0 => x0.platform,
      _752: x0 => x0.userAgent,
      _753: (x0,x1) => x0.vibrate(x1),
      _754: x0 => x0.languages,
      _755: x0 => x0.documentElement,
      _756: (x0,x1) => x0.querySelector(x1),
      _759: (x0,x1) => x0.createElement(x1),
      _762: (x0,x1) => x0.createEvent(x1),
      _763: x0 => x0.activeElement,
      _766: x0 => x0.head,
      _767: x0 => x0.body,
      _769: (x0,x1) => { x0.title = x1 },
      _772: x0 => x0.visibilityState,
      _773: () => globalThis.document,
      _774: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._774(f,arguments.length,x0) }),
      _775: (x0,x1) => x0.dispatchEvent(x1),
      _783: x0 => x0.target,
      _785: x0 => x0.timeStamp,
      _786: x0 => x0.type,
      _788: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _794: x0 => x0.baseURI,
      _795: x0 => x0.firstChild,
      _799: x0 => x0.parentElement,
      _800: (x0,x1) => { x0.textContent = x1 },
      _802: x0 => x0.parentNode,
      _804: x0 => x0.isConnected,
      _808: x0 => x0.firstElementChild,
      _810: x0 => x0.nextElementSibling,
      _811: x0 => x0.clientHeight,
      _812: x0 => x0.clientWidth,
      _813: x0 => x0.offsetHeight,
      _814: x0 => x0.offsetWidth,
      _815: x0 => x0.id,
      _816: (x0,x1) => { x0.id = x1 },
      _819: (x0,x1) => { x0.spellcheck = x1 },
      _820: x0 => x0.tagName,
      _821: x0 => x0.style,
      _823: (x0,x1) => x0.querySelectorAll(x1),
      _824: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _825: (x0,x1) => { x0.tabIndex = x1 },
      _826: x0 => x0.tabIndex,
      _827: (x0,x1) => x0.focus(x1),
      _828: x0 => x0.scrollTop,
      _829: (x0,x1) => { x0.scrollTop = x1 },
      _830: x0 => x0.scrollLeft,
      _831: (x0,x1) => { x0.scrollLeft = x1 },
      _832: x0 => x0.classList,
      _834: (x0,x1) => { x0.className = x1 },
      _836: (x0,x1) => x0.getElementsByClassName(x1),
      _837: (x0,x1) => x0.attachShadow(x1),
      _840: x0 => x0.computedStyleMap(),
      _841: (x0,x1) => x0.get(x1),
      _847: (x0,x1) => x0.getPropertyValue(x1),
      _848: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _849: x0 => x0.offsetLeft,
      _850: x0 => x0.offsetTop,
      _851: x0 => x0.offsetParent,
      _853: (x0,x1) => { x0.name = x1 },
      _854: x0 => x0.content,
      _855: (x0,x1) => { x0.content = x1 },
      _859: (x0,x1) => { x0.src = x1 },
      _860: x0 => x0.naturalWidth,
      _861: x0 => x0.naturalHeight,
      _865: (x0,x1) => { x0.crossOrigin = x1 },
      _867: (x0,x1) => { x0.decoding = x1 },
      _868: x0 => x0.decode(),
      _873: (x0,x1) => { x0.nonce = x1 },
      _878: (x0,x1) => { x0.width = x1 },
      _880: (x0,x1) => { x0.height = x1 },
      _883: (x0,x1) => x0.getContext(x1),
      _942: (x0,x1) => x0.fetch(x1),
      _943: x0 => x0.status,
      _945: x0 => x0.body,
      _946: x0 => x0.arrayBuffer(),
      _949: x0 => x0.read(),
      _950: x0 => x0.value,
      _951: x0 => x0.done,
      _953: x0 => x0.name,
      _954: x0 => x0.x,
      _955: x0 => x0.y,
      _958: x0 => x0.top,
      _959: x0 => x0.right,
      _960: x0 => x0.bottom,
      _961: x0 => x0.left,
      _973: x0 => x0.height,
      _974: x0 => x0.width,
      _975: x0 => x0.scale,
      _976: (x0,x1) => { x0.value = x1 },
      _978: (x0,x1) => { x0.placeholder = x1 },
      _979: (x0,x1) => { x0.name = x1 },
      _981: x0 => x0.selectionDirection,
      _982: x0 => x0.selectionStart,
      _983: x0 => x0.selectionEnd,
      _986: x0 => x0.value,
      _988: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _989: x0 => x0.readText(),
      _990: (x0,x1) => x0.writeText(x1),
      _992: x0 => x0.altKey,
      _993: x0 => x0.code,
      _994: x0 => x0.ctrlKey,
      _995: x0 => x0.key,
      _996: x0 => x0.keyCode,
      _997: x0 => x0.location,
      _998: x0 => x0.metaKey,
      _999: x0 => x0.repeat,
      _1000: x0 => x0.shiftKey,
      _1001: x0 => x0.isComposing,
      _1003: x0 => x0.state,
      _1004: (x0,x1) => x0.go(x1),
      _1006: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1007: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1008: x0 => x0.pathname,
      _1009: x0 => x0.search,
      _1010: x0 => x0.hash,
      _1014: x0 => x0.state,
      _1017: (x0,x1) => x0.createObjectURL(x1),
      _1019: x0 => new Blob(x0),
      _1021: x0 => new MutationObserver(x0),
      _1022: (x0,x1,x2) => x0.observe(x1,x2),
      _1023: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1023(f,arguments.length,x0,x1) }),
      _1026: x0 => x0.attributeName,
      _1027: x0 => x0.type,
      _1028: x0 => x0.matches,
      _1029: x0 => x0.matches,
      _1033: x0 => x0.relatedTarget,
      _1035: x0 => x0.clientX,
      _1036: x0 => x0.clientY,
      _1037: x0 => x0.offsetX,
      _1038: x0 => x0.offsetY,
      _1041: x0 => x0.button,
      _1042: x0 => x0.buttons,
      _1043: x0 => x0.ctrlKey,
      _1047: x0 => x0.pointerId,
      _1048: x0 => x0.pointerType,
      _1049: x0 => x0.pressure,
      _1050: x0 => x0.tiltX,
      _1051: x0 => x0.tiltY,
      _1052: x0 => x0.getCoalescedEvents(),
      _1055: x0 => x0.deltaX,
      _1056: x0 => x0.deltaY,
      _1057: x0 => x0.wheelDeltaX,
      _1058: x0 => x0.wheelDeltaY,
      _1059: x0 => x0.deltaMode,
      _1066: x0 => x0.changedTouches,
      _1069: x0 => x0.clientX,
      _1070: x0 => x0.clientY,
      _1073: x0 => x0.data,
      _1076: (x0,x1) => { x0.disabled = x1 },
      _1078: (x0,x1) => { x0.type = x1 },
      _1079: (x0,x1) => { x0.max = x1 },
      _1080: (x0,x1) => { x0.min = x1 },
      _1081: x0 => x0.value,
      _1082: (x0,x1) => { x0.value = x1 },
      _1083: x0 => x0.disabled,
      _1084: (x0,x1) => { x0.disabled = x1 },
      _1086: (x0,x1) => { x0.placeholder = x1 },
      _1088: (x0,x1) => { x0.name = x1 },
      _1090: (x0,x1) => { x0.autocomplete = x1 },
      _1091: x0 => x0.selectionDirection,
      _1093: x0 => x0.selectionStart,
      _1094: x0 => x0.selectionEnd,
      _1097: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1098: (x0,x1) => x0.add(x1),
      _1101: (x0,x1) => { x0.noValidate = x1 },
      _1102: (x0,x1) => { x0.method = x1 },
      _1103: (x0,x1) => { x0.action = x1 },
      _1129: x0 => x0.orientation,
      _1130: x0 => x0.width,
      _1131: x0 => x0.height,
      _1132: (x0,x1) => x0.lock(x1),
      _1151: x0 => new ResizeObserver(x0),
      _1154: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1154(f,arguments.length,x0,x1) }),
      _1162: x0 => x0.length,
      _1163: x0 => x0.iterator,
      _1164: x0 => x0.Segmenter,
      _1165: x0 => x0.v8BreakIterator,
      _1166: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1167: x0 => x0.done,
      _1168: x0 => x0.value,
      _1169: x0 => x0.index,
      _1173: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1174: (x0,x1) => x0.adoptText(x1),
      _1175: x0 => x0.first(),
      _1176: x0 => x0.next(),
      _1177: x0 => x0.current(),
      _1183: x0 => x0.hostElement,
      _1184: x0 => x0.viewConstraints,
      _1187: x0 => x0.maxHeight,
      _1188: x0 => x0.maxWidth,
      _1189: x0 => x0.minHeight,
      _1190: x0 => x0.minWidth,
      _1191: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1191(f,arguments.length,x0) }),
      _1192: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1192(f,arguments.length,x0) }),
      _1193: (x0,x1) => ({addView: x0,removeView: x1}),
      _1194: x0 => x0.loader,
      _1195: () => globalThis._flutter,
      _1196: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1197: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1197(f,arguments.length,x0) }),
      _1198: f => finalizeWrapper(f, function() { return dartInstance.exports._1198(f,arguments.length) }),
      _1199: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1200: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1200(f,arguments.length,x0) }),
      _1201: x0 => ({runApp: x0}),
      _1202: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1202(f,arguments.length,x0,x1) }),
      _1203: x0 => x0.length,
      _1204: () => globalThis.window.ImageDecoder,
      _1205: x0 => x0.tracks,
      _1207: x0 => x0.completed,
      _1209: x0 => x0.image,
      _1215: x0 => x0.displayWidth,
      _1216: x0 => x0.displayHeight,
      _1217: x0 => x0.duration,
      _1220: x0 => x0.ready,
      _1221: x0 => x0.selectedTrack,
      _1222: x0 => x0.repetitionCount,
      _1223: x0 => x0.frameCount,
      _1266: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1266(f,arguments.length,x0) }),
      _1267: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1268: (x0,x1,x2) => x0.postMessage(x1,x2),
      _1269: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1270: (x0,x1) => x0.getItem(x1),
      _1271: (x0,x1,x2) => x0.setItem(x1,x2),
      _1272: (x0,x1) => x0.querySelectorAll(x1),
      _1273: (x0,x1) => x0.removeChild(x1),
      _1274: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1274(f,arguments.length,x0) }),
      _1275: (x0,x1) => x0.forEach(x1),
      _1276: x0 => x0.preventDefault(),
      _1277: (x0,x1) => x0.item(x1),
      _1278: () => new FileReader(),
      _1279: (x0,x1) => x0.readAsText(x1),
      _1280: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1280(f,arguments.length,x0) }),
      _1281: () => globalThis.initializeGA(),
      _1283: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,x26,x27,x28,x29,x30,x31,x32,x33) => ({screen: x0,event_category: x1,event_label: x2,send_to: x3,value: x4,non_interaction: x5,user_app: x6,user_build: x7,user_platform: x8,devtools_platform: x9,devtools_chrome: x10,devtools_version: x11,ide_launched: x12,flutter_client_id: x13,is_external_build: x14,is_embedded: x15,g3_username: x16,ide_launched_feature: x17,is_wasm: x18,ui_duration_micros: x19,raster_duration_micros: x20,shader_compilation_duration_micros: x21,cpu_sample_count: x22,cpu_stack_depth: x23,trace_event_count: x24,heap_diff_objects_before: x25,heap_diff_objects_after: x26,heap_objects_total: x27,root_set_count: x28,row_count: x29,inspector_tree_controller_id: x30,android_app_id: x31,ios_bundle_id: x32,is_v2_inspector: x33}),
      _1284: x0 => x0.screen,
      _1285: x0 => x0.user_app,
      _1286: x0 => x0.user_build,
      _1287: x0 => x0.user_platform,
      _1288: x0 => x0.devtools_platform,
      _1289: x0 => x0.devtools_chrome,
      _1290: x0 => x0.devtools_version,
      _1291: x0 => x0.ide_launched,
      _1293: x0 => x0.is_external_build,
      _1294: x0 => x0.is_embedded,
      _1295: x0 => x0.g3_username,
      _1296: x0 => x0.ide_launched_feature,
      _1297: x0 => x0.is_wasm,
      _1298: x0 => x0.ui_duration_micros,
      _1299: x0 => x0.raster_duration_micros,
      _1300: x0 => x0.shader_compilation_duration_micros,
      _1301: x0 => x0.cpu_sample_count,
      _1302: x0 => x0.cpu_stack_depth,
      _1303: x0 => x0.trace_event_count,
      _1304: x0 => x0.heap_diff_objects_before,
      _1305: x0 => x0.heap_diff_objects_after,
      _1306: x0 => x0.heap_objects_total,
      _1307: x0 => x0.root_set_count,
      _1308: x0 => x0.row_count,
      _1309: x0 => x0.inspector_tree_controller_id,
      _1310: x0 => x0.android_app_id,
      _1311: x0 => x0.ios_bundle_id,
      _1312: x0 => x0.is_v2_inspector,
      _1314: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,x26,x27,x28,x29) => ({description: x0,fatal: x1,user_app: x2,user_build: x3,user_platform: x4,devtools_platform: x5,devtools_chrome: x6,devtools_version: x7,ide_launched: x8,flutter_client_id: x9,is_external_build: x10,is_embedded: x11,g3_username: x12,ide_launched_feature: x13,is_wasm: x14,ui_duration_micros: x15,raster_duration_micros: x16,shader_compilation_duration_micros: x17,cpu_sample_count: x18,cpu_stack_depth: x19,trace_event_count: x20,heap_diff_objects_before: x21,heap_diff_objects_after: x22,heap_objects_total: x23,root_set_count: x24,row_count: x25,inspector_tree_controller_id: x26,android_app_id: x27,ios_bundle_id: x28,is_v2_inspector: x29}),
      _1315: x0 => x0.user_app,
      _1316: x0 => x0.user_build,
      _1317: x0 => x0.user_platform,
      _1318: x0 => x0.devtools_platform,
      _1319: x0 => x0.devtools_chrome,
      _1320: x0 => x0.devtools_version,
      _1321: x0 => x0.ide_launched,
      _1323: x0 => x0.is_external_build,
      _1324: x0 => x0.is_embedded,
      _1325: x0 => x0.g3_username,
      _1326: x0 => x0.ide_launched_feature,
      _1327: x0 => x0.is_wasm,
      _1343: () => globalThis.getDevToolsPropertyID(),
      _1344: () => globalThis.hookupListenerForGA(),
      _1345: (x0,x1,x2) => globalThis.gtag(x0,x1,x2),
      _1347: x0 => x0.event_category,
      _1348: x0 => x0.event_label,
      _1350: x0 => x0.value,
      _1351: x0 => x0.non_interaction,
      _1354: x0 => x0.description,
      _1355: x0 => x0.fatal,
      _1356: (x0,x1) => x0.createElement(x1),
      _1357: x0 => new Blob(x0),
      _1358: x0 => globalThis.URL.createObjectURL(x0),
      _1359: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1360: (x0,x1) => x0.append(x1),
      _1361: x0 => x0.click(),
      _1362: x0 => x0.remove(),
      _1363: x0 => x0.createRange(),
      _1364: (x0,x1) => x0.selectNode(x1),
      _1365: x0 => x0.getSelection(),
      _1366: x0 => x0.removeAllRanges(),
      _1367: (x0,x1) => x0.addRange(x1),
      _1368: (x0,x1) => x0.createElement(x1),
      _1369: (x0,x1) => x0.append(x1),
      _1370: (x0,x1,x2) => x0.insertRule(x1,x2),
      _1371: (x0,x1) => x0.add(x1),
      _1372: x0 => x0.preventDefault(),
      _1373: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1373(f,arguments.length,x0) }),
      _1374: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1375: () => globalThis.window.navigator.userAgent,
      _1376: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1376(f,arguments.length,x0) }),
      _1377: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1378: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1383: (x0,x1) => x0.closest(x1),
      _1384: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1385: x0 => x0.decode(),
      _1386: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1387: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1388: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1388(f,arguments.length,x0) }),
      _1389: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1389(f,arguments.length,x0) }),
      _1390: x0 => x0.send(),
      _1391: () => new XMLHttpRequest(),
      _1392: (x0,x1) => x0.querySelector(x1),
      _1393: (x0,x1) => x0.appendChild(x1),
      _1394: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1394(f,arguments.length,x0) }),
      _1395: Date.now,
      _1397: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1398: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1399: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1400: () => typeof dartUseDateNowForTicks !== "undefined",
      _1401: () => 1000 * performance.now(),
      _1402: () => Date.now(),
      _1403: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1404: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1405: () => new WeakMap(),
      _1406: (map, o) => map.get(o),
      _1407: (map, o, v) => map.set(o, v),
      _1408: x0 => new WeakRef(x0),
      _1409: x0 => x0.deref(),
      _1416: () => globalThis.WeakRef,
      _1420: s => JSON.stringify(s),
      _1421: s => printToConsole(s),
      _1422: (o, p, r) => o.replaceAll(p, () => r),
      _1423: (o, p, r) => o.replace(p, () => r),
      _1424: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1425: s => s.toUpperCase(),
      _1426: s => s.trim(),
      _1427: s => s.trimLeft(),
      _1428: s => s.trimRight(),
      _1429: (string, times) => string.repeat(times),
      _1430: Function.prototype.call.bind(String.prototype.indexOf),
      _1431: (s, p, i) => s.lastIndexOf(p, i),
      _1432: (string, token) => string.split(token),
      _1433: Object.is,
      _1434: o => o instanceof Array,
      _1435: (a, i) => a.push(i),
      _1436: (a, i) => a.splice(i, 1)[0],
      _1438: (a, l) => a.length = l,
      _1439: a => a.pop(),
      _1440: (a, i) => a.splice(i, 1),
      _1441: (a, s) => a.join(s),
      _1442: (a, s, e) => a.slice(s, e),
      _1443: (a, s, e) => a.splice(s, e),
      _1444: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1445: a => a.length,
      _1446: (a, l) => a.length = l,
      _1447: (a, i) => a[i],
      _1448: (a, i, v) => a[i] = v,
      _1450: o => o instanceof ArrayBuffer,
      _1451: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1453: o => o instanceof Uint8Array,
      _1454: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1455: o => o instanceof Int8Array,
      _1456: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1457: o => o instanceof Uint8ClampedArray,
      _1458: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1459: o => o instanceof Uint16Array,
      _1460: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1461: o => o instanceof Int16Array,
      _1462: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1463: o => o instanceof Uint32Array,
      _1464: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1465: o => o instanceof Int32Array,
      _1466: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1468: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1469: o => o instanceof Float32Array,
      _1470: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1471: o => o instanceof Float64Array,
      _1472: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1473: (t, s) => t.set(s),
      _1475: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1476: o => o.byteLength,
      _1477: o => o.buffer,
      _1478: o => o.byteOffset,
      _1479: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1480: (b, o) => new DataView(b, o),
      _1481: (b, o, l) => new DataView(b, o, l),
      _1482: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1483: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1484: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1485: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1486: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1487: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1488: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1489: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1490: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1491: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1492: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1493: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1496: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1497: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1498: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1499: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1500: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1501: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1514: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1515: (handle) => clearTimeout(handle),
      _1516: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1517: (handle) => clearInterval(handle),
      _1518: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1519: () => Date.now(),
      _1524: o => Object.keys(o),
      _1525: (x0,x1) => new WebSocket(x0,x1),
      _1526: (x0,x1) => x0.send(x1),
      _1527: (x0,x1,x2) => x0.close(x1,x2),
      _1529: x0 => x0.close(),
      _1530: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1531: (x0,x1) => globalThis.fetch(x0,x1),
      _1532: (x0,x1) => x0.get(x1),
      _1533: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1533(f,arguments.length,x0,x1,x2) }),
      _1534: (x0,x1) => x0.forEach(x1),
      _1535: x0 => x0.abort(),
      _1536: () => new AbortController(),
      _1537: x0 => x0.getReader(),
      _1538: x0 => x0.read(),
      _1539: x0 => x0.cancel(),
      _1540: x0 => ({withCredentials: x0}),
      _1541: (x0,x1) => new EventSource(x0,x1),
      _1542: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1542(f,arguments.length,x0) }),
      _1543: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1543(f,arguments.length,x0) }),
      _1544: x0 => x0.close(),
      _1545: (x0,x1,x2) => ({method: x0,body: x1,credentials: x2}),
      _1546: (x0,x1,x2) => x0.fetch(x1,x2),
      _1549: () => new XMLHttpRequest(),
      _1550: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1551: x0 => x0.send(),
      _1553: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1559: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1559(f,arguments.length,x0) }),
      _1560: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1560(f,arguments.length,x0) }),
      _1565: x0 => ({body: x0}),
      _1566: (x0,x1) => new Notification(x0,x1),
      _1567: () => globalThis.Notification.requestPermission(),
      _1568: x0 => x0.close(),
      _1569: x0 => x0.reload(),
      _1570: (x0,x1) => x0.groupCollapsed(x1),
      _1571: (x0,x1) => x0.log(x1),
      _1572: x0 => x0.groupEnd(),
      _1573: (x0,x1) => x0.warn(x1),
      _1574: (x0,x1) => x0.error(x1),
      _1575: x0 => x0.measureUserAgentSpecificMemory(),
      _1576: x0 => x0.bytes,
      _1586: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1586(f,arguments.length,x0) }),
      _1587: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1587(f,arguments.length,x0) }),
      _1588: x0 => x0.blur(),
      _1589: (x0,x1) => x0.replace(x1),
      _1590: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1600: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1601: (x0,x1) => x0.exec(x1),
      _1602: (x0,x1) => x0.test(x1),
      _1603: x0 => x0.pop(),
      _1605: o => o === undefined,
      _1607: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1609: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1610: o => o instanceof RegExp,
      _1611: (l, r) => l === r,
      _1612: o => o,
      _1613: o => o,
      _1614: o => o,
      _1615: b => !!b,
      _1616: o => o.length,
      _1618: (o, i) => o[i],
      _1619: f => f.dartFunction,
      _1620: () => ({}),
      _1621: () => [],
      _1623: () => globalThis,
      _1624: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1625: (o, p) => p in o,
      _1626: (o, p) => o[p],
      _1627: (o, p, v) => o[p] = v,
      _1628: (o, m, a) => o[m].apply(o, a),
      _1630: o => String(o),
      _1631: (p, s, f) => p.then(s, f),
      _1632: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        return 17;
      },
      _1633: o => [o],
      _1634: (o0, o1) => [o0, o1],
      _1635: (o0, o1, o2) => [o0, o1, o2],
      _1636: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1637: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1638: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1639: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1640: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1641: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1642: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1643: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1644: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1645: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1646: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1647: x0 => new ArrayBuffer(x0),
      _1648: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1649: x0 => x0.input,
      _1650: x0 => x0.index,
      _1651: x0 => x0.groups,
      _1652: x0 => x0.flags,
      _1653: x0 => x0.multiline,
      _1654: x0 => x0.ignoreCase,
      _1655: x0 => x0.unicode,
      _1656: x0 => x0.dotAll,
      _1657: (x0,x1) => { x0.lastIndex = x1 },
      _1658: (o, p) => p in o,
      _1659: (o, p) => o[p],
      _1662: x0 => x0.random(),
      _1665: () => globalThis.Math,
      _1666: Function.prototype.call.bind(Number.prototype.toString),
      _1667: Function.prototype.call.bind(BigInt.prototype.toString),
      _1668: Function.prototype.call.bind(Number.prototype.toString),
      _1669: (d, digits) => d.toFixed(digits),
      _1672: (d, precision) => d.toPrecision(precision),
      _1673: () => globalThis.document,
      _1674: () => globalThis.window,
      _1679: (x0,x1) => { x0.height = x1 },
      _1681: (x0,x1) => { x0.width = x1 },
      _1684: x0 => x0.head,
      _1685: x0 => x0.classList,
      _1689: (x0,x1) => { x0.innerText = x1 },
      _1690: x0 => x0.style,
      _1692: x0 => x0.sheet,
      _1693: x0 => x0.src,
      _1694: (x0,x1) => { x0.src = x1 },
      _1695: x0 => x0.naturalWidth,
      _1696: x0 => x0.naturalHeight,
      _1703: x0 => x0.offsetX,
      _1704: x0 => x0.offsetY,
      _1705: x0 => x0.button,
      _1712: x0 => x0.status,
      _1713: (x0,x1) => { x0.responseType = x1 },
      _1715: x0 => x0.response,
      _1764: (x0,x1) => { x0.responseType = x1 },
      _1765: x0 => x0.response,
      _1840: x0 => x0.style,
      _2317: (x0,x1) => { x0.src = x1 },
      _2324: (x0,x1) => { x0.allow = x1 },
      _2336: x0 => x0.contentWindow,
      _2769: (x0,x1) => { x0.accept = x1 },
      _2783: x0 => x0.files,
      _2809: (x0,x1) => { x0.multiple = x1 },
      _2827: (x0,x1) => { x0.type = x1 },
      _3525: (x0,x1) => { x0.dropEffect = x1 },
      _3530: x0 => x0.files,
      _3542: x0 => x0.dataTransfer,
      _3546: () => globalThis.window,
      _3588: x0 => x0.location,
      _3589: x0 => x0.history,
      _3605: x0 => x0.parent,
      _3607: x0 => x0.navigator,
      _3862: x0 => x0.isSecureContext,
      _3863: x0 => x0.crossOriginIsolated,
      _3866: x0 => x0.performance,
      _3871: x0 => x0.localStorage,
      _3879: x0 => x0.origin,
      _3888: x0 => x0.pathname,
      _3902: x0 => x0.state,
      _3927: x0 => x0.message,
      _3989: x0 => x0.appVersion,
      _3990: x0 => x0.platform,
      _3993: x0 => x0.userAgent,
      _3994: x0 => x0.vendor,
      _4044: x0 => x0.data,
      _4045: x0 => x0.origin,
      _4417: x0 => x0.readyState,
      _4426: x0 => x0.protocol,
      _4430: (x0,x1) => { x0.binaryType = x1 },
      _4433: x0 => x0.code,
      _4434: x0 => x0.reason,
      _6101: x0 => x0.type,
      _6142: x0 => x0.signal,
      _6200: x0 => x0.parentNode,
      _6214: () => globalThis.document,
      _6296: x0 => x0.body,
      _6339: x0 => x0.activeElement,
      _6973: x0 => x0.offsetX,
      _6974: x0 => x0.offsetY,
      _7059: x0 => x0.key,
      _7060: x0 => x0.code,
      _7061: x0 => x0.location,
      _7062: x0 => x0.ctrlKey,
      _7063: x0 => x0.shiftKey,
      _7064: x0 => x0.altKey,
      _7065: x0 => x0.metaKey,
      _7066: x0 => x0.repeat,
      _7067: x0 => x0.isComposing,
      _7973: x0 => x0.value,
      _7975: x0 => x0.done,
      _8155: x0 => x0.size,
      _8156: x0 => x0.type,
      _8163: x0 => x0.name,
      _8164: x0 => x0.lastModified,
      _8169: x0 => x0.length,
      _8175: x0 => x0.result,
      _8670: x0 => x0.url,
      _8672: x0 => x0.status,
      _8674: x0 => x0.statusText,
      _8675: x0 => x0.headers,
      _8676: x0 => x0.body,
      _10758: (x0,x1) => { x0.backgroundColor = x1 },
      _10804: (x0,x1) => { x0.border = x1 },
      _11082: (x0,x1) => { x0.display = x1 },
      _11246: (x0,x1) => { x0.height = x1 },
      _11936: (x0,x1) => { x0.width = x1 },
      _13023: () => globalThis.console,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
