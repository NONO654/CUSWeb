///////////////////////////////////////////////////////////////////////
///////////////////////// prototype.js ////////////////////////////////
///////////////////////////////////////////////////////////////////////

var Prototype = {
  Version: '1.3.0',
  emptyFunction: function() {}
}

var Class = {
  create: function() {
    return function() { 
      this.initialize.apply(this, arguments);
    }
  }
}

var Abstract = new Object();

Object.extend = function(destination, source) {
  for (property in source) {
    destination[property] = source[property];
  }
  return destination;
}
/*
Object.prototype.extend = function(object) {
  return Object.extend.apply(this, [this, object]);
}
*/
Function.prototype.bindTA = function(object) {
  var __method = this;
  return function() {
    __method.apply(object, arguments);
  }
}

Function.prototype.bindAsEventListener = function(object) {
  var __method = this;
  return function(event) {
    __method.call(object, event || window.event);
  }
}

Number.prototype.toColorPart = function() {
  var digits = this.toString(16);
  if (this < 16) return '0' + digits;
  return digits;
}

var Try = {
  these: function() {
    var returnValue;

    for (var i = 0; i < arguments.length; i++) {
      var lambda = arguments[i];
      try {
        returnValue = lambda();
        break;
      } catch (e) {}
    }

    return returnValue;
  }
}

/*--------------------------------------------------------------------------*/

var PeriodicalExecuter = Class.create();
PeriodicalExecuter.prototype = {
  initialize: function(callback, frequency) {
    this.callback = callback;
    this.frequency = frequency;
    this.currentlyExecuting = false;

    this.registerCallback();
  },

  registerCallback: function() {
    setInterval(this.onTimerEvent.bindTA(this), this.frequency * 1000);
  },

  onTimerEvent: function() {
    if (!this.currentlyExecuting) {
      try { 
        this.currentlyExecuting = true;
        this.callback(); 
      } finally { 
        this.currentlyExecuting = false;
      }
    }
  }
}

/*--------------------------------------------------------------------------*/

function $$() {
  var elements = new Array();

  for (var i = 0; i < arguments.length; i++) {
    var element = arguments[i];
    if (typeof element == 'string')
    {
        // mpk - we don't set id for our fields but seems to work in IE
        element = document.getElementById(element);

        if (element == null)
        {
            for (var j = 0; j < document.forms.length; j++)
            {
                if (document.forms[j].elements[arguments[i]] != null)
                {
                    element = document.forms[j].elements[arguments[i]];
                    break;
                }
            }
        }
    }
            
    if (arguments.length == 1) 
      return element;

    elements.push(element);
  }

  return elements;
}

if (!Array.prototype.push) {
  Array.prototype.push = function() {
        var startLength = this.length;
        for (var i = 0; i < arguments.length; i++)
      this[startLength + i] = arguments[i];
      return this.length;
  }
}

if (!Function.prototype.apply) {
  // Based on code from http://www.youngpup.net/
  Function.prototype.apply = function(object, parameters) {
    var parameterStrings = new Array();
    if (!object)     object = window;
    if (!parameters) parameters = new Array();
    
    for (var i = 0; i < parameters.length; i++)
      parameterStrings[i] = 'parameters[' + i + ']';
    
    object.__apply__ = this;
    var result = eval('object.__apply__(' + 
      parameterStrings[i].join(', ') + ')');
    object.__apply__ = null;
    
    return result;
  }
}

Object.extend(String.prototype, {
  stripTags: function() {
    return this.replace(/<\/?[^>]+>/gi, '');
  },

  escapeHTML: function() {
    var div = document.createElement('div');
    var text = document.createTextNode(this);
    div.appendChild(text);
    return div.innerHTML;
  },

  unescapeHTML: function() {
    var div = document.createElement('div');
//    div.innerHTML = this.stripTags();
    div.innerHTML = this;
    
    // some text like "&" does not create a child node
    if (div.childNodes[0] == null)
        return (this);
    else
        return div.childNodes[0].nodeValue;
  }
});

var Ajax = {
  getTransport: function() {
    return Try.these(
      function() {return new ActiveXObject('Msxml2.XMLHTTP')},
      function() {return new ActiveXObject('Microsoft.XMLHTTP')},
      function() {return new XMLHttpRequest()}
    ) || false;
  }
}

Ajax.Base = function() {};
Ajax.Base.prototype = {
  setOptions: function(options) {
    this.options = Object.extend({
      method:       'post',
      asynchronous: true,
      parameters:   ''
    }, options || {});
  },

  responseIsSuccess: function() {
    return this.transport.status == undefined
        || this.transport.status == 0 
        || (this.transport.status >= 200 && this.transport.status < 300);
  },

  responseIsFailure: function() {
    return !this.responseIsSuccess();
  }
}

Ajax.Request = Class.create();
Ajax.Request.Events = 
  ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete'];

Ajax.Request.prototype = Object.extend(new Ajax.Base(), {
  initialize: function(url, options) {
    this.transport = Ajax.getTransport();
    this.setOptions(options);
//replace the &amp; with &. This was done to have xhtml standards. now we dont need this while
//invoking the url
    url = url.replace(/\&amp;/g,"&");
//
    this.request(url);
  },

  request: function(url) {
    var parameters = this.options.parameters || '';
    if (parameters.length > 0) parameters += '&_=';

    try {
      if (this.options.method == 'get')
        url += '?' + parameters;

      this.transport.open(this.options.method, url,
        this.options.asynchronous);

      if (this.options.asynchronous) {
        this.transport.onreadystatechange = this.onStateChange.bindTA(this);
        setTimeout((function() {this.respondToReadyState(1)}).bindTA(this), 10);
      }

      this.setRequestHeaders();

      var body = this.options.postBody ? this.options.postBody : parameters;
      this.transport.send(this.options.method == 'post' ? body : null);

    } catch (e) {
    }
  },

  setRequestHeaders: function() {
    var requestHeaders = 
      ['X-Requested-With', 'XMLHttpRequest',
       'X-Prototype-Version', Prototype.Version];

    if (this.options.method == 'post') {
      //requestHeaders.push('Content-type', 'application/x-www-form-urlencoded');

      /* Force "Connection: close" for Mozilla browsers to work around
       * a bug where XMLHttpReqeuest sends an incorrect Content-length
       * header. See Mozilla Bugzilla #246651. 
       */
      if (this.transport.overrideMimeType)
        requestHeaders.push('Connection', 'close');
    }

    if (this.options.requestHeaders)
      requestHeaders.push.apply(requestHeaders, this.options.requestHeaders);

    for (var i = 0; i < requestHeaders.length; i += 2)
      this.transport.setRequestHeader(requestHeaders[i], requestHeaders[i+1]);
  },

  onStateChange: function() {
    var readyState = this.transport.readyState;
    if (readyState != 1)
      this.respondToReadyState(this.transport.readyState);
  },

  respondToReadyState: function(readyState) {
    var event = Ajax.Request.Events[readyState];

    if (event == 'Complete')
      (this.options['on' + this.transport.status]
       || this.options['on' + this.responseIsSuccess ? 'Success' : 'Failure']
       || Prototype.emptyFunction)(this.transport);       

    (this.options['on' + event] || Prototype.emptyFunction)(this.transport);    
  }
});

Ajax.Updater = Class.create();
Ajax.Updater.ScriptFragment = '(?:<script.*?>)((\n|.)*?)(?:<\/script>)';

Object.extend(Object.extend(Ajax.Updater.prototype, Ajax.Request.prototype), {
  initialize: function(container, url, options) {
    this.containers = {
      success: container.success ? $$(container.success) : $$(container),
      failure: container.failure ? $$(container.failure) :
        (container.success ? null : $$(container))
    }

    this.transport = Ajax.getTransport();
    this.setOptions(options);

    var onComplete = this.options.onComplete || Prototype.emptyFunction;
    this.options.onComplete = (function() {
      this.updateContent();
      onComplete(this.transport);      
    }).bindTA(this);

    this.request(url);
  },

  updateContent: function() {
    var receiver = this.responseIsSuccess() ?
      this.containers.success : this.containers.failure;

    var match    = new RegExp(Ajax.Updater.ScriptFragment, 'img');
    var response = this.transport.responseText.replace(match, '');
    var scripts  = this.transport.responseText.match(match);

    if (receiver) {
      if (this.options.insertion) {
        new this.options.insertion(receiver, response);
      } else {
        receiver.innerHTML = response;
      }
    }

    if (this.responseIsSuccess()) {
      if (this.onComplete)
        setTimeout((function() {this.onComplete(
          this.transport)}).bindTA(this), 10);
    }

    if (this.options.evalScripts && scripts) {
      match = new RegExp(Ajax.Updater.ScriptFragment, 'im');
      setTimeout((function() {
        for (var i = 0; i < scripts.length; i++)
          eval(scripts[i].match(match)[1]);
      }).bindTA(this), 10);
    }
  }
});

Ajax.PeriodicalUpdater = Class.create();
Ajax.PeriodicalUpdater.prototype = Object.extend(new Ajax.Base(), {
  initialize: function(container, url, options) {
    this.setOptions(options);
    this.onComplete = this.options.onComplete;

    this.frequency = (this.options.frequency || 2);
    this.decay = 1;

    this.updater = {};
    this.container = container;
    this.url = url;

    this.start();
  },

  start: function() {
    this.options.onComplete = this.updateComplete.bindTA(this);
    this.onTimerEvent();
  },

  stop: function() {
    this.updater.onComplete = undefined;
    clearTimeout(this.timer);
    (this.onComplete || Ajax.emptyFunction).apply(this, arguments);
  },

  updateComplete: function(request) {
    if (this.options.decay) {
      this.decay = (request.responseText == this.lastText ? 
        this.decay * this.options.decay : 1);

      this.lastText = request.responseText;
    }
    this.timer = setTimeout(this.onTimerEvent.bindTA(this), 
      this.decay * this.frequency * 1000);
  },

  onTimerEvent: function() {
    this.updater = new Ajax.Updater(this.container, this.url, this.options);
  }
});

/*--------------------------------------------------------------------------*/

if (!window.Element) {
  var Element = new Object();
}

Object.extend(Element, {
  toggle: function() {
    for (var i = 0; i < arguments.length; i++) {
      var element = $$(arguments[i]);
      element.style.display = 
        (element.style.display == 'none' ? '' : 'none');
    }
  },

  hide: function() {
	  if(this.typeAheadFullSearch && this.selectionMode == "multiple") {
		  this.selectedRowsMap = new HashMap();
	  }
	  for (var i = 0; i < arguments.length; i++) {
		  var element = $$(arguments[i]);
		  element.style.display = 'none';
	  }
  },

  show: function() {
    for (var i = 0; i < arguments.length; i++) {
      var element = $$(arguments[i]);
      element.style.display = '';
    }
  },

  remove: function(element) {
    element = $$(element);
    element.parentNode.removeChild(element);
  },
   
  getHeight: function(element) {
    element = $$(element);
    return element.offsetHeight; 
  },

  hasClassName: function(element, className) {
    element = $$(element);
    if (!element)
      return;
    var a = element.className.split(' ');
    for (var i = 0; i < a.length; i++) {
      if (a[i] == className)
        return true;
    }
    return false;
  },

  addClassName: function(element, className) {
    element = $$(element);
    Element.removeClassName(element, className);
    element.className += ' ' + className;
  },

  removeClassName: function(element, className) {
    element = $$(element);
    if (!element)
      return;
    var newClassName = '';
    var a = element.className.split(' ');
    for (var i = 0; i < a.length; i++) {
      if (a[i] != className) {
        if (i > 0)
          newClassName += ' ';
        newClassName += a[i];
      }
    }
    element.className = newClassName;
  },
  
  // removes whitespace-only text node children
  cleanWhitespace: function(element) {
    var element = $$(element);
    for (var i = 0; i < element.childNodes.length; i++) {
      var node = element.childNodes[i];
      if (node.nodeType == 3 && !/\S/.test(node.nodeValue)) 
        Element.remove(node);
    }
  }
});

var Toggle = new Object();
Toggle.display = Element.toggle;

/*--------------------------------------------------------------------------*/


Abstract.Insertion = function(adjacency) {
  this.adjacency = adjacency;
}

Abstract.Insertion.prototype = {
  initialize: function(element, content) {
    this.element = $$(element);
    this.content = content;
    
    if (this.adjacency && this.element.insertAdjacentHTML) {
      this.element.insertAdjacentHTML(this.adjacency, this.content);
    } else {
      this.range = this.element.ownerDocument.createRange();
      if (this.initializeRange) this.initializeRange();
      this.fragment = this.range.createContextualFragment(this.content);
      this.insertContent();
    }
  }
}

var Insertion = new Object();

Insertion.Before = Class.create();
Insertion.Before.prototype = Object.extend(new Abstract.Insertion('beforeBegin'), {
  initializeRange: function() {
    this.range.setStartBefore(this.element);
  },
  
  insertContent: function() {
    this.element.parentNode.insertBefore(this.fragment, this.element);
  }
});

Insertion.Top = Class.create();
Insertion.Top.prototype = Object.extend(new Abstract.Insertion('afterBegin'), {
  initializeRange: function() {
    this.range.selectNodeContents(this.element);
    this.range.collapse(true);
  },
  
  insertContent: function() {  
    this.element.insertBefore(this.fragment, this.element.firstChild);
  }
});

Insertion.Bottom = Class.create();
Insertion.Bottom.prototype = Object.extend(new Abstract.Insertion('beforeEnd'), {
  initializeRange: function() {
    this.range.selectNodeContents(this.element);
    this.range.collapse(this.element);
  },
  
  insertContent: function() {
    this.element.appendChild(this.fragment);
  }
});

Insertion.After = Class.create();
Insertion.After.prototype = Object.extend(new Abstract.Insertion('afterEnd'), {
  initializeRange: function() {
    this.range.setStartAfter(this.element);
  },
  
  insertContent: function() {
    this.element.parentNode.insertBefore(this.fragment, 
      this.element.nextSibling);
  }
});


/*--------------------------------------------------------------------------*/

Abstract.TimedObserver = function() {}
Abstract.TimedObserver.prototype = {
  initialize: function(element, frequency, callback) {
    this.frequency = frequency;
    this.element   = $$(element);
    this.callback  = callback;
    
    this.lastValue = this.getValue();
    this.registerCallback();
  },
  
  registerCallback: function() {
    setInterval(this.onTimerEvent.bindTA(this), this.frequency * 1000);
  },
  
  onTimerEvent: function() {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  }
}

/*--------------------------------------------------------------------------*/

Abstract.EventObserver = function() {}
Abstract.EventObserver.prototype = {
  initialize: function(element, callback) {
    this.element  = $$(element);
    this.callback = callback;
    
    this.lastValue = this.getValue();
    if (this.element.tagName.toLowerCase() == 'form')
      this.registerFormCallbacks();
    else
      this.registerCallback(this.element);
  },
  
  onElementEvent: function() {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  },
  
  registerFormCallbacks: function() {
    var elements = Form.getElements(this.element);
    for (var i = 0; i < elements.length; i++)
      this.registerCallback(elements[i]);
  },
  
  registerCallback: function(element) {
    if (element.type) {
      switch (element.type.toLowerCase()) {
        case 'checkbox':  
        case 'radio':
          element.target = this;
          element.prev_onclick = element.onclick || Prototype.emptyFunction;
          element.onclick = function() {
            this.prev_onclick(); 
            this.target.onElementEvent();
          }
          break;
        case 'password':
        case 'text':
        case 'textarea':
        case 'select-one':
        case 'select-multiple':
          element.target = this;
          element.prev_onchange = element.onchange || Prototype.emptyFunction;
          element.onchange = function() {
            this.prev_onchange(); 
            this.target.onElementEvent();
          }
          break;
      }
    }    
  }
}

if (!window.Event) {
  var Event = new Object();
}

Object.extend(Event, {
  KEY_BACKSPACE: 8,
  KEY_TAB:       9,
  KEY_RETURN:   13,
  KEY_ESC:      27,
  KEY_LEFT:     37,
  KEY_UP:       38,
  KEY_RIGHT:    39,
  KEY_DOWN:     40,
  KEY_DELETE:   46,
  KEY_SHIFT:    16,
  KEY_CTRL:     17,
  element: function(event) {
    return event.target || event.srcElement;
  },

  isLeftClick: function(event) {
    return (((event.which) && (event.which == 1)) ||
            ((event.button) && (event.button == 1)));
  },

  pointerX: function(event) {
    return event.pageX || (event.clientX + 
      (document.documentElement.scrollLeft || document.body.scrollLeft));
  },

  pointerY: function(event) {
    return event.pageY || (event.clientY + 
      (document.documentElement.scrollTop || document.body.scrollTop));
  },

  stop: function(event) {
    if (event.preventDefault) { 
      event.preventDefault(); 
      event.stopPropagation(); 
    } else {
      event.returnValue = false;
    }
  },

  // find the first node with the given tagName, starting from the
  // node the event was triggered on; traverses the DOM upwards
  findElement: function(event, tagName) {
    var element = Event.element(event);
    while (element.parentNode && (!element.tagName ||
        (element.tagName.toUpperCase() != tagName.toUpperCase())))
      element = element.parentNode;
    return element;
  },
  
  observers: false,
  
  _observeAndCache: function(element, name, observer, useCapture) {
    if(!this.observers) this.observers = [];
	/* Bug fix: IR-053189V6R2011x and IR-053194V6R2011x */
	if(null != element){
		if(element.addEventListener) {
		  this.observers.push([element,name,observer,useCapture]);
		  element.addEventListener(name, observer, useCapture);
		} 
	}
  },
  
  unloadCache: function() {
    if(!Event.observers) return;
    for(var i=0; i<Event.observers.length; i++) {
      Event.stopObserving(Event.observers[i][0],Event.observers[i][1],Event.observers[i][2],Event.observers[i][3]);
      Event.observers[i][0] = null;
    }
    Event.observers = false;
  },

  observe: function(element, name, observer, useCapture) {
    var element = $$(element);
    useCapture = useCapture || false;
    
    if (name == 'keypress') {
      if (navigator.appVersion.indexOf('AppleWebKit') > 0) {
        this._observeAndCache(element, 'keydown', observer, useCapture);
        return;
      }
      this._observeAndCache(element, 'keypress', observer, useCapture);
    } else {
      this._observeAndCache(element, name, observer, useCapture);
    }
  },

  stopObserving: function(element, name, observer, useCapture) {
    var element = $$(element);
    useCapture = useCapture || false;
    
    if (name == 'keypress') {
      if (navigator.appVersion.indexOf('AppleWebKit') > 0) {
        element.removeEventListener('keydown', observer, useCapture);
        return;
      }
      if (element.removeEventListener) {
        element.removeEventListener('keypress', observer, useCapture);
      } 
    } else {
      if (element.removeEventListener) {
        element.removeEventListener(name, observer, useCapture);
      }
    }
  }
});

// prevent memory leaks
Event.observe(window,'unload', Event.unloadCache, false);

var Position = {

  // set to true if needed, warning: firefox performance problems
  // NOT neeeded for page scrolling, only if draggable contained in
  // scrollable elements
  includeScrollOffsets: false, 

  // must be called before calling withinIncludingScrolloffset, every time the
  // page is scrolled
  prepare: function() {
    this.deltaX =  window.pageXOffset 
                || document.documentElement.scrollLeft 
                || document.body.scrollLeft 
                || 0;
    this.deltaY =  window.pageYOffset 
                || document.documentElement.scrollTop 
                || document.body.scrollTop 
                || 0;
  },

  realOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.scrollTop  || 0;
      valueL += element.scrollLeft || 0; 
      element = element.parentNode;
    } while (element);
    return [valueL, valueT];
  },

cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      if (element.id != "divPageBody") {
        valueT += element.offsetTop  || 0;
        valueL += element.offsetLeft || 0;
      }
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  },

  // caches x/y coordinate pair to use with overlap
  within: function(element, x, y) {
    if (this.includeScrollOffsets)
      return this.withinIncludingScrolloffsets(element, x, y);
    this.xcomp = x;
    this.ycomp = y;
    this.offset = this.cumulativeOffset(element);

    return (y >= this.offset[1] &&
            y <  this.offset[1] + element.offsetHeight &&
            x >= this.offset[0] && 
            x <  this.offset[0] + element.offsetWidth);
  },

  withinIncludingScrolloffsets: function(element, x, y) {
    var offsetcache = this.realOffset(element);

    this.xcomp = x + offsetcache[0] - this.deltaX;
    this.ycomp = y + offsetcache[1] - this.deltaY;
    this.offset = this.cumulativeOffset(element);

    return (this.ycomp >= this.offset[1] &&
            this.ycomp <  this.offset[1] + element.offsetHeight &&
            this.xcomp >= this.offset[0] && 
            this.xcomp <  this.offset[0] + element.offsetWidth);
  },

  // within must be called directly before
  overlap: function(mode, element) {  
    if (!mode) return 0;  
    if (mode == 'vertical') 
      return ((this.offset[1] + element.offsetHeight) - this.ycomp) / 
        element.offsetHeight;
    if (mode == 'horizontal')
      return ((this.offset[0] + element.offsetWidth) - this.xcomp) / 
        element.offsetWidth;
  },

  clone: function(source, target) {
    source = $$(source);
    target = $$(target);
    target.style.position = 'absolute';
    var offsets = this.cumulativeOffset(source);
    target.style.top    = offsets[1] + 'px';
    target.style.left   = offsets[0] + 'px';
    target.style.width  = source.offsetWidth + 'px';
    target.style.height = source.offsetHeight + 'px';
  }
}


//////////////////////////////////////////////////////////////////////////////
/////////////////////// effects.js ///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Effect = {}
Effect2 = Effect; // deprecated

/* ------------- transitions ------------- */

Effect.Transitions = {}

Effect.Transitions.linear = function(pos) {
  return pos;
}
Effect.Transitions.sinoidal = function(pos) {
  return (-Math.cos(pos*Math.PI)/2) + 0.5;
}
Effect.Transitions.reverse  = function(pos) {
  return 1-pos;
}
Effect.Transitions.flicker = function(pos) {
  return ((-Math.cos(pos*Math.PI)/4) + 0.75) + Math.random(0.25);
}
Effect.Transitions.wobble = function(pos) {
  return (-Math.cos(pos*Math.PI*(9*pos))/2) + 0.5;
}
Effect.Transitions.pulse = function(pos) {
  return (Math.floor(pos*10) % 2 == 0 ? 
    (pos*10-Math.floor(pos*10)) : 1-(pos*10-Math.floor(pos*10)));
}
Effect.Transitions.none = function(pos) {
  return 0;
}
Effect.Transitions.full = function(pos) {
  return 1;
}

/* ------------- element ext -------------- */

Element.makePositioned = function(element) {
  element = $$(element);
  if(element.style.position == "")
    element.style.position = "relative";
}

Element.makeClipping = function(element) {
  element = $$(element);
  element._overflow = element.style.overflow || 'visible';
  if(element._overflow!='hidden') element.style.overflow = 'hidden';
}

Element.undoClipping = function(element) {
  element = $$(element);
  if(element._overflow!='hidden') element.style.overflow = element._overflow;
}

/* ------------- core effects ------------- */

Effect.Base = function() {};
Effect.Base.prototype = {
  setOptions: function(options) {
    this.options = Object.extend({
      transition: Effect.Transitions.sinoidal,
      duration:   1.0,   // seconds
      fps:        25.0,  // max. 100fps
      sync:       false, // true for combining
      from:       0.0,
      to:         1.0
    }, options || {});
  },
  start: function(options) {
    this.setOptions(options || {});
    this.currentFrame = 0;
    this.startOn      = new Date().getTime();
    this.finishOn     = this.startOn + (this.options.duration*1000);
    if(this.options.beforeStart) this.options.beforeStart(this);
    if(!this.options.sync) this.loop();  
  },
  loop: function() {
    var timePos = new Date().getTime();
    if(timePos >= this.finishOn) {
      this.render(this.options.to);
      if(this.finish) this.finish(); 
      if(this.options.afterFinish) this.options.afterFinish(this);
      return;  
    }
    var pos   = (timePos - this.startOn) / (this.finishOn - this.startOn);
    var frame = Math.round(pos * this.options.fps * this.options.duration);
    if(frame > this.currentFrame) {
      this.render(pos);
      this.currentFrame = frame;
    }
    this.timeout = setTimeout(this.loop.bindTA(this), 10);
  },
  render: function(pos) {
    if(this.options.transition) pos = this.options.transition(pos);
    pos *= (this.options.to-this.options.from);
    pos += this.options.from; 
    if(this.options.beforeUpdate) this.options.beforeUpdate(this);
    if(this.update) this.update(pos);
    if(this.options.afterUpdate) this.options.afterUpdate(this);  
  },
  cancel: function() {
    if(this.timeout) clearTimeout(this.timeout);
  }
}

Effect.Parallel = Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype, Effect.Base.prototype), {
  initialize: function(effects) {
    this.effects = effects || [];
    this.start(arguments[1]);
  },
  update: function(position) {
    for (var i = 0; i < this.effects.length; i++)
      this.effects[i].render(position);  
  },
  finish: function(position) {
    for (var i = 0; i < this.effects.length; i++)
      if(this.effects[i].finish) this.effects[i].finish(position);
  }
});

// Internet Explorer caveat: works only on elements the have
// a 'layout', meaning having a given width or height. 
// There is no way to safely set this automatically.
Effect.Opacity = Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $$(element);
    options = Object.extend({
      from: 0.0,
      to:   1.0
    }, arguments[1] || {});
    this.start(options);
  },
  update: function(position) {
    this.setOpacity(position);
  }, 
  setOpacity: function(opacity) {
    opacity = (opacity == 1) ? 0.99999 : opacity;
    this.element.style.opacity = opacity;
    this.element.style.filter = "alpha(opacity:"+opacity*100+")";
  }
});

Effect.MoveBy = Class.create();
Object.extend(Object.extend(Effect.MoveBy.prototype, Effect.Base.prototype), {
  initialize: function(element, toTop, toLeft) {
    this.element      = $$(element);
    this.originalTop  = parseFloat(this.element.style.top || '0');
    this.originalLeft = parseFloat(this.element.style.left || '0');
    this.toTop        = toTop;
    this.toLeft       = toLeft;
    Element.makePositioned(this.element);
    this.start(arguments[3]);
  },
  update: function(position) {
    topd  = this.toTop  * position + this.originalTop;
    leftd = this.toLeft * position + this.originalLeft;
    this.setPosition(topd, leftd);
  },
  setPosition: function(topd, leftd) {
    this.element.style.top  = topd  + "px";
    this.element.style.left = leftd + "px";
  }
});

Effect.Scale = Class.create();
Object.extend(Object.extend(Effect.Scale.prototype, Effect.Base.prototype), {
  initialize: function(element, percent) {
    this.element = $$(element)
    options = Object.extend({
      scaleX: true,
      scaleY: true,
      scaleContent: true,
      scaleFromCenter: false,
      scaleMode: 'box',        // 'box' or 'contents' or {} with provided values
      scaleFrom: 100.0
    }, arguments[2] || {});
    this.originalTop    = this.element.offsetTop;
    this.originalLeft   = this.element.offsetLeft;
    if(this.element.style.fontSize=="") this.sizeEm = 1.0;
    if(this.element.style.fontSize && this.element.style.fontSize.indexOf("em")>0)
      this.sizeEm      = parseFloat(this.element.style.fontSize);
    this.factor = (percent/100.0) - (options.scaleFrom/100.0);
    if(options.scaleMode=='box') {
      this.originalHeight = this.element.clientHeight;
      this.originalWidth  = this.element.clientWidth; 
    } else 
    if(options.scaleMode=='contents') {
      this.originalHeight = this.element.scrollHeight;
      this.originalWidth  = this.element.scrollWidth;
    } else {
      this.originalHeight = options.scaleMode.originalHeight;
      this.originalWidth  = options.scaleMode.originalWidth;
    }
    this.start(options);
  },

  update: function(position) {
    currentScale = (this.options.scaleFrom/100.0) + (this.factor * position);
    if(this.options.scaleContent && this.sizeEm) 
      this.element.style.fontSize = this.sizeEm*currentScale + "em";
    this.setDimensions(
      this.originalWidth * currentScale, 
      this.originalHeight * currentScale);
  },

  setDimensions: function(width, height) {
    if(this.options.scaleX) this.element.style.width = width + 'px';
    if(this.options.scaleY) this.element.style.height = height + 'px';
    if(this.options.scaleFromCenter) {
      topd  = (height - this.originalHeight)/2;
      leftd = (width  - this.originalWidth)/2;
      if(this.element.style.position=='absolute') {
        if(this.options.scaleY) this.element.style.top = this.originalTop-topd + "px";
        if(this.options.scaleX) this.element.style.left = this.originalLeft-leftd + "px";
      } else {
        if(this.options.scaleY) this.element.style.top = -topd + "px";
        if(this.options.scaleX) this.element.style.left = -leftd + "px";
      }
    }
  }
});

Effect.Highlight = Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $$(element);
    
    // try to parse current background color as default for endcolor
    // browser stores this as: "rgb(255, 255, 255)", convert to "#ffffff" format
    var endcolor = "#ffffff";
    var current = this.element.style.backgroundColor;
    if(current && current.slice(0,4) == "rgb(") {
      endcolor = "#";
      var cols = current.slice(4,current.length-1).split(',');
      var i=0; do { endcolor += parseInt(cols[i]).toColorPart() } while (++i<3); }
      
    var options = Object.extend({
      startcolor:   "#ffff99",
      endcolor:     endcolor,
      restorecolor: current 
    }, arguments[1] || {});
    
    // init color calculations
    this.colors_base = [
      parseInt(options.startcolor.slice(1,3),16),
      parseInt(options.startcolor.slice(3,5),16),
      parseInt(options.startcolor.slice(5),16) ];
    this.colors_delta = [
      parseInt(options.endcolor.slice(1,3),16)-this.colors_base[0],
      parseInt(options.endcolor.slice(3,5),16)-this.colors_base[1],
      parseInt(options.endcolor.slice(5),16)-this.colors_base[2] ];

    this.start(options);
  },
  update: function(position) {
    var colors = [
      Math.round(this.colors_base[0]+(this.colors_delta[0]*position)),
      Math.round(this.colors_base[1]+(this.colors_delta[1]*position)),
      Math.round(this.colors_base[2]+(this.colors_delta[2]*position)) ];
    this.element.style.backgroundColor = "#" +
      colors[0].toColorPart() + colors[1].toColorPart() + colors[2].toColorPart();
  },
  finish: function() {
    this.element.style.backgroundColor = this.options.restorecolor;
  }
});

Effect.ScrollTo = Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $$(element);
    Position.prepare();
    var offsets = Position.cumulativeOffset(this.element);
    var max = window.innerHeight ? 
      window.height - window.innerHeight :
      document.body.scrollHeight - 
        (document.documentElement.clientHeight ? 
          document.documentElement.clientHeight : document.body.clientHeight);
    this.scrollStart = Position.deltaY;
    this.delta  = (offsets[1] > max ? max : offsets[1]) - this.scrollStart;
    this.start(arguments[1] || {});
  },
  update: function(position) {
    Position.prepare();
    window.scrollTo(Position.deltaX, 
      this.scrollStart + (position*this.delta));
  }
});

/* ------------- prepackaged effects ------------- */

Effect.Fade = function(element) {
  options = Object.extend({
  from: 1.0,
  to:   0.0,
  afterFinish: function(effect) 
    { Element.hide(effect.element);
      effect.setOpacity(1); } 
  }, arguments[1] || {});
  new Effect.Opacity(element,options);
}

Effect.Appear = function(element) {
  options = Object.extend({
  from: 0.0,
  to:   1.0,
  beforeStart: function(effect)  
    { effect.setOpacity(0);
      Element.show(effect.element); },
  afterUpdate: function(effect)  
    { Element.show(effect.element); }
  }, arguments[1] || {});
  new Effect.Opacity(element,options);
}

Effect.Puff = function(element) {
  new Effect.Parallel(
   [ new Effect.Scale(element, 200, { sync: true, scaleFromCenter: true }), 
     new Effect.Opacity(element, { sync: true, to: 0.0, from: 1.0 } ) ], 
     { duration: 1.0, 
      afterUpdate: function(effect) 
       { effect.effects[0].element.style.position = 'absolute'; },
      afterFinish: function(effect)
       { Element.hide(effect.effects[0].element); }
     }
   );
}

Effect.BlindUp = function(element) {
  Element.makeClipping(element);
  new Effect.Scale(element, 0, 
    Object.extend({ scaleContent: false, 
      scaleX: false, 
      afterFinish: function(effect) 
        { 
          Element.hide(effect.element);
          Element.undoClipping(effect.element);
        } 
    }, arguments[1] || {})
  );
}

Effect.BlindDown = function(element) {
  $$(element).style.height   = '0px';
  Element.makeClipping(element);
  Element.show(element);
  new Effect.Scale(element, 100, 
    Object.extend({ scaleContent: false, 
      scaleX: false, 
      scaleMode: 'contents',
      scaleFrom: 0,
      afterFinish: function(effect) {
        Element.undoClipping(effect.element);
      }
    }, arguments[1] || {})
  );
}

Effect.SwitchOff = function(element) {
  new Effect.Appear(element,
    { duration: 0.4,
     transition: Effect.Transitions.flicker,
     afterFinish: function(effect)
      { effect.element.style.overflow = 'hidden';
        new Effect.Scale(effect.element, 1, 
         { duration: 0.3, scaleFromCenter: true,
          scaleX: false, scaleContent: false,
          afterUpdate: function(effect) { 
           if(effect.element.style.position=="")
             effect.element.style.position = 'relative'; },
          afterFinish: function(effect) { Element.hide(effect.element); }
         } )
      }
    } );
}

Effect.DropOut = function(element) {
  new Effect.Parallel(
    [ new Effect.MoveBy(element, 100, 0, { sync: true }), 
      new Effect.Opacity(element, { sync: true, to: 0.0, from: 1.0 } ) ], 
    { duration: 0.5, 
     afterFinish: function(effect)
       { Element.hide(effect.effects[0].element); } 
    });
}

Effect.Shake = function(element) {
  new Effect.MoveBy(element, 0, 20, 
    { duration: 0.05, afterFinish: function(effect) {
  new Effect.MoveBy(effect.element, 0, -40, 
    { duration: 0.1, afterFinish: function(effect) { 
  new Effect.MoveBy(effect.element, 0, 40, 
    { duration: 0.1, afterFinish: function(effect) {  
  new Effect.MoveBy(effect.element, 0, -40, 
    { duration: 0.1, afterFinish: function(effect) {  
  new Effect.MoveBy(effect.element, 0, 40, 
    { duration: 0.1, afterFinish: function(effect) {  
  new Effect.MoveBy(effect.element, 0, -20, 
    { duration: 0.05, afterFinish: function(effect) {  
  }}) }}) }}) }}) }}) }});
}

Effect.SlideDown = function(element) {
  element = $$(element);
  element.style.height   = '0px';
  Element.makeClipping(element);
  Element.cleanWhitespace(element);
  Element.makePositioned(element.firstChild);
  Element.show(element);
  new Effect.Scale(element, 100, 
   Object.extend({ scaleContent: false, 
    scaleX: false, 
    scaleMode: 'contents',
    scaleFrom: 0,
    afterUpdate: function(effect) 
      { effect.element.firstChild.style.bottom = 
          (effect.originalHeight - effect.element.clientHeight) + 'px'; },
    afterFinish: function(effect) 
      {  Element.undoClipping(effect.element); }
    }, arguments[1] || {})
  );
}
  
Effect.SlideUp = function(element) {
  element = $$(element);
  Element.makeClipping(element);
  Element.cleanWhitespace(element);
  Element.makePositioned(element.firstChild);
  Element.show(element);
  new Effect.Scale(element, 0, 
   Object.extend({ scaleContent: false, 
    scaleX: false, 
    afterUpdate: function(effect) 
      { effect.element.firstChild.style.bottom = 
          (effect.originalHeight - effect.element.clientHeight) + 'px'; },
    afterFinish: function(effect)
      { 
        Element.hide(effect.element);
        Element.undoClipping(effect.element);
      }
   }, arguments[1] || {})
  );
}

Effect.Squish = function(element) {
 new Effect.Scale(element, 0, 
   { afterFinish: function(effect) { Element.hide(effect.element); } });
}

Effect.Grow = function(element) {
  element = $$(element);
  var options = arguments[1] || {};
  
  var originalWidth = element.clientWidth;
  var originalHeight = element.clientHeight;
  element.style.overflow = 'hidden';
  Element.show(element);
  
  var direction = options.direction || 'center';
  var moveTransition = options.moveTransition || Effect.Transitions.sinoidal;
  var scaleTransition = options.scaleTransition || Effect.Transitions.sinoidal;
  var opacityTransition = options.opacityTransition || Effect.Transitions.full;
  
  var initialMoveX, initialMoveY;
  var moveX, moveY;
  
  switch (direction) {
    case 'top-left':
      initialMoveX = initialMoveY = moveX = moveY = 0; 
      break;
    case 'top-right':
      initialMoveX = originalWidth;
      initialMoveY = moveY = 0;
      moveX = -originalWidth;
      break;
    case 'bottom-left':
      initialMoveX = moveX = 0;
      initialMoveY = originalHeight;
      moveY = -originalHeight;
      break;
    case 'bottom-right':
      initialMoveX = originalWidth;
      initialMoveY = originalHeight;
      moveX = -originalWidth;
      moveY = -originalHeight;
      break;
    case 'center':
      initialMoveX = originalWidth / 2;
      initialMoveY = originalHeight / 2;
      moveX = -originalWidth / 2;
      moveY = -originalHeight / 2;
      break;
  }
  
  new Effect.MoveBy(element, initialMoveY, initialMoveX, { 
    duration: 0.01, 
    beforeUpdate: function(effect) { $$(element).style.height = '0px'; },
    afterFinish: function(effect) {
      new Effect.Parallel(
        [ new Effect.Opacity(element, { sync: true, to: 1.0, from: 0.0, transition: opacityTransition }),
          new Effect.MoveBy(element, moveY, moveX, { sync: true, transition: moveTransition }),
          new Effect.Scale(element, 100, { 
            scaleMode: { originalHeight: originalHeight, originalWidth: originalWidth }, 
            sync: true, scaleFrom: 0, scaleTo: 100, transition: scaleTransition })],
        options); }
    });
}

Effect.Shrink = function(element) {
  element = $$(element);
  var options = arguments[1] || {};
  
  var originalWidth = element.clientWidth;
  var originalHeight = element.clientHeight;
  element.style.overflow = 'hidden';
  Element.show(element);

  var direction = options.direction || 'center';
  var moveTransition = options.moveTransition || Effect.Transitions.sinoidal;
  var scaleTransition = options.scaleTransition || Effect.Transitions.sinoidal;
  var opacityTransition = options.opacityTransition || Effect.Transitions.none;
  
  var moveX, moveY;
  
  switch (direction) {
    case 'top-left':
      moveX = moveY = 0;
      break;
    case 'top-right':
      moveX = originalWidth;
      moveY = 0;
      break;
    case 'bottom-left':
      moveX = 0;
      moveY = originalHeight;
      break;
    case 'bottom-right':
      moveX = originalWidth;
      moveY = originalHeight;
      break;
    case 'center':  
      moveX = originalWidth / 2;
      moveY = originalHeight / 2;
      break;
  }
  
  new Effect.Parallel(
    [ new Effect.Opacity(element, { sync: true, to: 0.0, from: 1.0, transition: opacityTransition }),
      new Effect.Scale(element, 0, { sync: true, transition: moveTransition }),
      new Effect.MoveBy(element, moveY, moveX, { sync: true, transition: scaleTransition }) ],
    options);
}

Effect.Pulsate = function(element) {
  var options    = arguments[1] || {};
  var transition = options.transition || Effect.Transitions.sinoidal;
  var reverser   = function(pos){ return transition(1-Effect.Transitions.pulse(pos)) };
  reverser.bindTA(transition);
  new Effect.Opacity(element, 
    Object.extend(Object.extend({  duration: 3.0,
       afterFinish: function(effect) { Element.show(effect.element); }
    }, options), {transition: reverser}));
}

Effect.Fold = function(element) {
 $$(element).style.overflow = 'hidden';
 new Effect.Scale(element, 5, Object.extend({   
   scaleContent: false,
   scaleTo: 100,
   scaleX: false,
   afterFinish: function(effect) {
   new Effect.Scale(element, 1, { 
     scaleContent: false, 
     scaleTo: 0,
     scaleY: false,
     afterFinish: function(effect) { Element.hide(effect.element) } });
 }}, arguments[1] || {}));
}

// old: new Effect.ContentZoom(element, percent)
// new: Element.setContentZoom(element, percent) 

Element.setContentZoom = function(element, percent) {
  var element = $$(element);
  element.style.fontSize = (percent/100) + "em";  
  if(navigator.appVersion.indexOf('AppleWebKit')>0) window.scrollBy(0,0);
}


//////////////////////////////////////////////////////////////////////////////
/////////////////////// controls.js //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Element.collectTextNodesIgnoreClass = function(element, ignoreclass) {
if (element)
{
        if ($$(element).childNodes)
        {
          var children = $$(element).childNodes;
          var text     = "";
          var classtest = new RegExp("^([^ ]+ )*" + ignoreclass+ "( [^ ]+)*$","i");
          
          for (var i = 0; i < children.length; i++) {
            if(children[i].nodeType==3) {
              text+=children[i].nodeValue;
            } else {
              if((!children[i].className.match(classtest)) && children[i].hasChildNodes())
                text += Element.collectTextNodesIgnoreClass(children[i], ignoreclass);
            }
          }
          
          return text;
        }
}
}

// TypeAhead.Base handles all the autocompletion functionality 
// that's independent of the data source for autocompletion. This
// includes drawing the autocompletion menu, observing keyboard
// and mouse events, and similar.
//
// Specific TypeAheads need to provide, at the very least, 
// a getUpdatedChoices function that will be invoked every time
// the text inside the monitored textbox changes. This method 
// should get the text for which to provide autocompletion by
// invoking this.getEntry(), NOT by directly accessing
// this.element.value. This is to allow incremental tokenized
// autocompletion. Specific auto-completion logic (AJAX, etc)
// belongs in getUpdatedChoices.
//
// Tokenized incremental autocompletion is enabled automatically
// when an TypeAhead is instantiated with the 'tokens' option
// in the options parameter, e.g.:
// new Ajax.TypeAhead('id','upd', '/url/', { tokens: ',' });
// will incrementally autocomplete with a comma as the token.
// Additionally, ',' in the above example can be replaced with
// a token array, e.g. { tokens: new Array (',', '\n') } which
// enables autocompletion on multiple tokens. This is most 
// useful when one of the tokens is \n (a newline), as it 
// allows smart autocompletion after linebreaks.

var TypeAhead = {}
TypeAhead.Base = function() {};
TypeAhead.Base.prototype = {
		base_initialize: function(element, update, hidden_element, options) {
	this.element     = $$(element); 
	this.update      = $$(update);  
	this.has_focus   = false; 
	this.changed     = false; 
	this.active      = false; 
	this.index       = 0;     
	this.entry_count = 0;
	this.hidden_element = null;
	this.hidden_element_name = hidden_element;
	this.hidden_element_oid = null;
	this.hidden_element_oid_name = hidden_element ? hidden_element + "OID" : null;
	this.divClick = false;

	this.init_display_value = null;
	this.init_hidden_value = null;
	this.init_hidden_oid_value = null;
	this.chosen = true;
	if(this.isSB && currentCell.target!=null){
		typeahedRef=this;      
	}
	if (this.setOptions)
		this.setOptions(options);
	else
		this.options = {}

	this.options.tokens       = this.options.tokens || new Array();
	this.options.frequency    = this.options.frequency || 0.4;
	this.options.min_chars    = this.options.min_chars || 1;
	this.options.onShow       = this.options.onShow || 
	function(element, update){ 
		if(!update.style.position || update.style.position=='absolute') {
			update.style.position = 'absolute';
			var offsets = Position.cumulativeOffset(element);
			update.style.left = offsets[0] + 'px';
			update.style.top  = (offsets[1] + element.offsetHeight) + 'px';

		}
		new Effect.Appear(update,{duration:0.10});
	};
	this.options.onHide = this.options.onHide || 
	function(element, update){ new Effect.Fade(update,{duration:0.10}) };

	if(this.options.indicator)
		this.indicator = $$(this.options.indicator);

	if (typeof(this.options.tokens) == 'string') 
		this.options.tokens = new Array(this.options.tokens);

	this.observer = null;

	Element.hide(this.update);
	this.clickedOutside = false;
	if(isIE){
		Event.observe(this.element, "focusout", this.onBlur.bindAsEventListener(this));
	}
	else{
	Event.observe(this.element, "blur", this.onBlur.bindAsEventListener(this));
	}
	//if(uiType == "structureBrowser"){
		Event.observe(this.update, "mousedown", this.typeAheadClick.bindAsEventListener(this));
	//}
	Event.observe(this.element, "keydown", this.onKeyDown.bindAsEventListener(this));
	if(isIE || (navigator.appVersion.indexOf('AppleWebKit') > 0)){
		Event.observe(this.element, "keyup", this.onKeyPress.bindAsEventListener(this));
		Event.observe( document,"mousedown", this.onMousedown.bindAsEventListener(this));
	}
	Event.observe(this.element, "keypress", this.onKeyPress.bindAsEventListener(this));
	Event.observe(this.element, "focus", this.onFocus.bindAsEventListener(this));
	Event.observe(this.element, "dblclick", this.onDblClick.bindAsEventListener(this));
//	Event.observe(this.element, "change", this.onChange.bindAsEventListener(this));
},

setElementValue: function(value) {
	if(value)
	{
	// Modified for IR-188371V6R2014
			this.element.value = value;  
	}
},

isObjectId : function _isObjectId(idOrNot) {
	try {
		if(idOrNot == "") return false;
		var ids = idOrNot.split("|");
		for(var i = 0; i < ids.length; i++) {
			var idArray = ids[i].split(".");		
			for(var j = 0; j < idArray.length ; j++) {   
				if(isNaN(idArray[j]))
					return false;				            
			}
		}
		return true;
	} catch (ex) {
		return false;
	}
},

setHiddenElementValue: function(value) {
	this.initHiddenElement();
	if(this.typeAheadFullSearch && this.isObjectId(value)) {
		this.callSubmitURL(value);
	} else if((this.typeAheadFullSearch && this.typeChooser) || this.hidden_element_oid == null) {
		this.hidden_element.value = value;  
	} else {
		this.hidden_element.value = this.element.value;
		this.hidden_element_oid.value = value;
	}
},

show: function() {
	if(this.typeAheadFullSearch &&  this.element && this.element.parentNode == null){
		return true;
	}
	if(this.update.style.display=='none'){
		this.options.onShow(this.element, this.update);
	}
	if(!this.iefix && isIE && this.update.style.position=='absolute' && !this.typeAheadFullSearch) {
		new Insertion.After(this.update, 
				'<iframe id="' + this.update.id + '_iefix" '+
				'style="display:none;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" ' +
		'src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
		this.iefix = $$(this.update.id+'_iefix');
	}
	if(this.iefix) {
		Position.clone(this.update, this.iefix);
		this.iefix.style.zIndex = 1;
		this.update.style.zIndex = 2;
		Element.show(this.iefix);
		this.iefix.style.height="1px";
		this.iefix.style.width="1px";
	}
},

hide: function() {
	if(this.update.style.display=='') this.options.onHide(this.element, this.update);
	if(this.iefix) Element.hide(this.iefix);
},

startIndicator: function() {
	if(this.indicator) Element.show(this.indicator);
},

stopIndicator: function() {
	if(this.indicator) Element.hide(this.indicator);
},

onKeyPress: function(event) {
	var key = event.keyCode;
	if (key == 0)
	{
		key = event.which;
	}
	if(this.active)
		switch(key) {
		case Event.KEY_RETURN:
			if(this.noResults){
				this.hide();
			}else{
			this.select_entry();
			}
			
			Event.stop(event);
			// falls thru
		case Event.KEY_ESC:
			if(this.typeAheadFullSearch && this.typeAheadValidate)this.validate();
			this.selectedRowsMap = new HashMap();
			this.hide();
			this.active = false;
			return;
		case Event.KEY_LEFT:
		case Event.KEY_RIGHT:
		case Event.KEY_UP:
		case Event.KEY_DOWN:
			//modified for bug IR-029605V6R2011
			if(isIE){
				return;
			}
			if((event.keyCode==0 && event.which==40)
					||(event.keyCode==0 && event.which==38)
					||(event.keyCode==0 && event.which==39)
					||(event.keyCode==0 && event.which==37))
			{  
				/* To avoid the conflict caused due to keycode properties 
				  	of (,&,',% keys and the Direction keys */
				break;     
			}
			Event.stop(event);
			return;
		}
	else 
		if(key==Event.KEY_TAB || key==Event.KEY_RETURN) 
		{
			return;
		}

	this.changed = true;
	this.has_focus = true;
    this.chosen = false;
	if(this.observer) clearTimeout(this.observer);
	this.observer = 
		setTimeout(this.onObserverEvent.bindTA(this), this.options.frequency*1000);
},

// We need a keydown handler for IE which
// does not generate a keypress event for
// DEL, BACKSPACE 

onKeyDown: function(event) {
	var key = event.keyCode;
	if (key == 0)
	{
		key = event.which;
	}

	if(this.active){
		switch(key) {
		case Event.KEY_LEFT:
		case Event.KEY_RIGHT:
			return;
		case Event.KEY_UP:
			this.mark_previous();
			this.render(true);
			if(navigator.appVersion.indexOf('AppleWebKit')>0) Event.stop(event);
			return;
		case Event.KEY_DOWN:
			this.mark_next();
			this.render(true);
			if(navigator.appVersion.indexOf('AppleWebKit')>0) Event.stop(event);
			return;
		case Event.KEY_RETURN:
			if(this.noResults){
				this.hide();
			}else if(this.typeAheadFullSearch){ 
				this.onClick(event, this.selectedTR);
			}
		case Event.KEY_TAB:
			if(!this.typeAheadFullSearch){
				this.select_entry();
			}
			this.hide();
			this.active = false;
			return;
		}
	} else  {
		if(key==Event.KEY_TAB || key==Event.KEY_RETURN) 
			return;
	}

	this.changed = true;
	this.has_focus = true;

	if (key == Event.KEY_DELETE || key == Event.KEY_BACKSPACE)
	{
		this.chosen = false;
		if(this.observer) clearTimeout(this.observer);
		this.observer = 
			setTimeout(this.onObserverEvent.bindTA(this), this.options.frequency*1000);
	}
},

onHover: function(event) {
	var element = Event.findElement(event, 'TR');
	if(this.index != element.autocompleteIndex) 
	{
		this.index = element.autocompleteIndex;
		this.render();
	}
	Event.stop(event);
},
//this event handler is for typeAhead Div Click
typeAheadClick: function (event){
	this.divClick= true;
	this.update.title="divClick";
},
onClick: function(event, selectedTR) {
	var element = Event.findElement(event, 'TR');
	if(selectedTR){
		element = selectedTR;
	}
	if(this.typeAheadFullSearch) {
		if(element.getAttribute("value") == "ViewAllResults") {
			this.hide();
			this.active = false;
			var rangeURL = this.rangeHelperURL.replace(new RegExp("&amp;", "g"), "&");
			rangeURL = getDynamicSearchRefinements(rangeURL, this.hidden_element.name);
			if(rangeURL.indexOf("submitURL")==-1) {
				rangeURL += "&submitURL=../common/AEFSearchUtil.jsp";
			}
			if(this.isSB || this.isSBMassUpdate) {
				this.initHiddenElement();
				rangeURL += "&fieldNameActual="+this.hidden_element.name;
				rangeURL += "&fieldNameDisplay="+this.element.name;
				if(this.isSBMassUpdate) {
					rangeURL += "&formName=emxTableForm_2";
					showModalDialog(rangeURL, 700, 500, true);
				}
				if(this.isSB) {
					rangeURL += "&formName=emxTableForm";
					var colName = colMap.getColumnByIndex(currentColumnPosition-1).getAttribute("name");
					var colV    = emxEditableTable.getCellValueByRowId(this.rowId,colName);
					if(this.selectionMode == "multiple") {
						this.validate();
					}
					//IR-154865V6R2013x
					this.element.value = colV.value.current.display;
					var rootNode = getRequestSetting("objectId");
		            var rootObjectId = rootNode != null ? rootNode : "";
		            
					watchForChange1(this.element.name, colV.value.current.display, this.rowId);
					var ftsAppendParams=  "&fieldName="+colName+"&rowObjectId="+colV.objectid+"&rowRelId="+colV.relid+"&isFromChooser=true&rootObjectId="+rootObjectId+"&uiType=StructureBrowser&timeStamp="+timeStamp;
					var fieldValuesParams = "fieldValues=" + encodeURIComponent(emxUICore.toJSONString(emxEditableTable.getRowColumnValues(this.rowId)));
					var targetWindowName = "NonModalWindow" + (new Date()).getTime();
					var levelParams = "level=" + currentRow.getAttribute("level");
	                objWindow = window.open('', targetWindowName, 'width=600,height=600');
	                registerChildWindows(objWindow, getTopWindow());
	            	objWindow.focus();
	            	submitPostToSelfSB(rangeURL,ftsAppendParams + "&" + fieldValuesParams + "&" + levelParams,targetWindowName);
	               	
				}
			}else{
				showModalDialog(rangeURL, 700, 500, true);
			}
			return;
		}
	}

	this.index = element.autocompleteIndex;

	if(this.isSB && currentCell.target != null) 
	{
		if(this.typeAheadFullSearch && this.selectionMode == "multiple") {
			if(this.selectedRowsMap.Contains(this.index)) {
				this.selectedRowsMap.Remove(this.index);
				Element.removeClassName(element, "selected");
			} else {
				this.selectedRowsMap.Put(this.index, element);
				Element.addClassName(element, "selected");
			}
			this.element.focus();
			return ;
		} else {
			if(!this.typeAheadFullSearch) {
				value = Element.collectTextNodesIgnoreClass(this.get_current_entry(), 'informal');
				this.setElementValue(value);
			} else {
				value = this.get_current_entry().getAttribute("displayValue");
			}

			if(this.typeChooser) {
				this.setElementValue(this.get_current_entry().getAttribute("displayValue"));
				this.setHiddenElementValue(this.get_current_entry().getAttribute("value"));
			}

			if(this.element.id != "selectListManualTextBoxToKeyIn" && this.element.id != "typeAheadTextBoxToKeyIn" ) {
				var colName = colMap.getColumnByIndex(currentColumnPosition-1).getAttribute("name");

				if(!this.typeAheadFullSearch) {
					emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),colName,this.element.value,this.element.value);
				} else if(this.typeChooser) {
					updateTextWithHelper(this.rowId,true);
					this.hide();
					this.active = false;
					return;
				} else {
					var colV = emxEditableTable.getCellValueByRowId(currentRow.getAttribute("id"),colName);
					this.element.value = colV.value.current.display;					
					this.setHiddenElementValue(this.get_current_entry().getAttribute("value"));					
					var sameDisplayValSelected = colV.value.current.display == this.get_current_entry().getAttribute("displayValue");
					watchForChange1(this.getHiddenFieldName(uiType),colV.value.current.display,currentRow.getAttribute("id"), sameDisplayValSelected);			
				}
			}
		}
	}
	else if(this.typeAheadFullSearch) {
		if(this.selectionMode == "multiple") {
			if(this.selectedRowsMap.Contains(this.index)) {
				this.selectedRowsMap.Remove(this.index);
				Element.removeClassName(element, "selected");
			} else {
				this.selectedRowsMap.Put(this.index, element);
				Element.addClassName(element, "selected");
			}
			this.element.focus();
			return ;
		} else {
			this.chosen = true;
			value = this.get_current_entry().getAttribute("value");
			var hiddenVal = this.hidden_values[value];
			if(hiddenVal != null && hiddenVal != "undefined" && hiddenVal != undefined) {
				this.setHiddenElementValue(hiddenVal);
			}
			if(this.typeChooser) {
				this.setElementValue(this.get_current_entry().getAttribute("displayValue"));
				this.reloadOpener();
			}
		}
	} else {
		this.select_entry();
	}

	this.hide();
	this.active = false;
	this.element.focus();
	if(!this.isSB && this.hidden_element){
		temp = this.hidden_element.name;		
		temp = temp.replace(/ /g,'_');
		if(temp != undefined && FormHandler.GetField(temp) != null){			
			setTimeout(function(){
				FormHandler.GetField(temp).HandleChangeEvent();				
			},250);
		}
	}
},

onDone: function(event) {
	var selectedRows = this.selectedRowsMap.ToArray();
	var separator = "|";
	if(this.typeChooser) {
		separator = ",";
	}
	this.done = true;
	if(selectedRows.length > 0) {
		this.chosen = true;
	}
	this.active = false;
	this.element.focus();
	this.onBlur();

	var hiddenValue = null;
	var dispValue = null;
	for(var i = 0; i < selectedRows.length; i++) {
		var selectedRow = selectedRows[i];
		var value = selectedRow.getAttribute("value");
		var dvalue = selectedRow.getAttribute("displayvalue");
		if(hiddenValue != null) {
			hiddenValue += separator + this.hidden_values[value];
			dispValue   += separator + dvalue;
		} else {
			hiddenValue = this.hidden_values[value];
			dispValue = dvalue;
		}
	}
	this.selectedRowsMap = new HashMap();

	this.setHiddenElementValue(hiddenValue);
	
	if(this.typeChooser) {
		this.setElementValue(dispValue);
		this.reloadOpener();
	}

	if(this.isSB && this.typeChooser) {
		updateTextWithHelper(this.rowId , true);
	} else if(this.isSB) {
		this.setElementValue(dispValue);
		var colName = colMap.getColumnByIndex(currentColumnPosition-1).getAttribute("name");
		var colV    = emxEditableTable.getCellValueByRowId(this.rowId,colName);
		var sameDisplayValSelected = colV.value.current.display == dispValue;		
		watchForChange1(this.getHiddenFieldName(uiType),dispValue,currentRow.getAttribute("id"), sameDisplayValSelected);
	}

},

onCancel: function(event) {
	this.selectedRowsMap = new HashMap();
	this.active = false;
	this.element.focus();
	this.chosen = false;
	this.done = true;
	this.onBlur();
},

onDblClick: function(event) {
	if(!this.typeAheadFullSearch && !this.element.readOnly) {
		this.has_focus = true;
		this.updateChoices(this.buildList(this.orig_display_values, false));
		Event.stop(event);
	}
},

onMousedown:function(event) {
	if(isIE || (navigator.appVersion.indexOf('AppleWebKit') > 0)){
		if(event.srcElement.className == " type-ahead-body"){
			this.clickedOutside = false;
		}
		else{
			this.clickedOutside=true;
		}
		if(this.typeAheadFullSearch && this.getUiType()!= "structureBrowser"){
			if(event.srcElement.id == "divPageBody" ){
				this.clickedOutside = false;
			}
		}
	}
},


onBlur: function(event) {
	// needed to make click events working

	if((isIE || (navigator.appVersion.indexOf('AppleWebKit') > 0)) &&  !(this.clickedOutside) ){
		//this.element.focus();
	}

	else{
		if(this.typeAheadFullSearch && this.selectionMode == "multiple"){
			if(this.done){
				setTimeout(this.hide.bindTA(this), 250);
				this.done = false;
			} else if(jQuery(this.update).find("#nr-ta-body-id").length) {
				setTimeout(this.hide.bindTA(this), 150);
			} else {
				return;
			}
		}
		else {
			setTimeout(this.hide.bindTA(this), 250);
		}
		this.has_focus = false;
		this.active = false;
		var newValue = false;

		// if they haven't chosen a value from the list and there is a url
		// to supply values or a hidden element, then assume they entered
		// a bogus value and revert to the initial value in the field.

		var strDisplayValues = "";
		if (this.orig_display_values != null)
		{
			strDisplayValues=this.orig_display_values.join(",");
		}

		if ((this.chosen == false && (this.url != null && this.url.length > 0)) || (this.url == null || this.url == ""))
		{
			if (this.init_display_value != null)
			{
				var elementName=this.element.name;
				var elementDisplayName="";
				if (this.hidden_element && this.hidden_element.name)
				{
					elementDisplayName=this.hidden_element.name+"Display";
					elementDisplayName=elementDisplayName.toLowerCase();
				}
				elementName=elementName.toLowerCase();
				if((elementName!= "selectlistmanualtextboxtokeyin") && (elementName==elementDisplayName || (this.url!=null && this.url.length>0)))
				{
					if (this.hidden_element != null)
					{
						if(!this.typeAheadFullSearch)
							this.setHiddenElementValue(this.element.value);
						if(this.typeAheadFullSearch && this.hidden_element.value != this.init_hidden_value)
							this.setHiddenElementValue(this.element.value);
					}

					if(this.typeAheadValidate){
						this.validate();
					}
					if(this.typeAheadFullSearch && !this.typeAheadValidate && this.isSB && !this.divClick) {
						var colName = colMap.getColumnByIndex(currentColumnPosition-1).getAttribute("name");		  
						emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),colName,this.element.value,this.element.value);
					}
				}
			}
		}
	}
}, 
  
  validate: function() {
	  this.element.value = this.init_display_value;  
	  if(this.init_hidden_value != null)
		  this.hidden_element.value = this.init_hidden_value;
	  if(this.hidden_element_oid != null)
		  this.hidden_element_oid.value = this.init_hidden_oid_value;
  },
  
  onFocus: function(event) {
    
    // Find the hidden element and save a reference to it.  This is done
    // here because the hidden element is usually defined later in the form
    // than the visible element.  That means it will be undefined during
    // initialization time for this object.  So we grab it here when
    // the visible field gains focus.
    
    if(this.typeAheadFullSearch && !this.active) {
    	this.element.select();
    }
    if (this.hidden_element == null && this.hidden_element_name != null && this.hidden_element_name.length > 0)
    {
        this.hidden_element = $$(this.hidden_element_name);
    }
       
    if (this.hidden_element_oid == null && this.hidden_element_oid_name != null && this.hidden_element_oid_name.length > 0)
    {
        this.hidden_element_oid = $$(this.hidden_element_oid_name);
    }
    
    // For the same reason as above, we gather the initial hidden and
    // display field values here.  These will replace typed in values
    // that were not returned from the JPO when the user leaves the field.

    if (this.init_display_value == null)
    {
        this.init_display_value = this.element.value;
        
        if (this.hidden_element != null)
        {
            this.init_hidden_value = this.hidden_element.value;
        }
        if (this.hidden_element_oid != null)
        {
            this.init_hidden_oid_value = this.hidden_element_oid.value;
        }
    }
  }, 

  render: function(scrollIntoView) {
	  if(this.noResults){
		this.show();
	  } else if(this.entry_count > 0 && !this.noResults) {
		  for (var i = 0; i < this.entry_count; i++) {
			  
			  if(this.index==i){
			  		Element.addClassName(this.get_entry(i),"hover");
					this.selectedTR = this.get_entry(i);
			  }else{
					  Element.removeClassName(this.get_entry(i),"hover");
			  }
		  }
		  if(this.has_focus || this.element.id == "selectListManualTextBoxToKeyIn") { 
			  if(scrollIntoView){
				  this.update.firstChild.scrollTop = this.get_current_entry().offsetTop - (this.get_current_entry().offsetTop + this.get_current_entry().offsetHeight) % this.update.firstChild.clientHeight;
			  }
			  var flag = this.show();
			  this.active = true;
			  if(flag){
					return true;
			  }
		  }

		  if(this.element.id == "selectListManualTextBoxToKeyIn"){
			  this.update.style.zIndex = 2;
		  }
	  } else this.hide();
  },
  
  mark_previous: function() {
    if(this.index > 0) this.index--
      else this.index = this.entry_count-1;
  },
  
  mark_next: function() {
    if(this.index < this.entry_count-1) this.index++
      else this.index = 0;
  },
  
  get_entry: function(index) {
    var entryItem = this.update.firstChild.childNodes[index];

      
      //this.update.firstChild.firstChild.childNodes[0] -> TBODY
    if(this.update.firstChild.firstChild.childNodes[0]) {
    	  entryItem = this.update.firstChild.firstChild.childNodes[0].childNodes[index];
    }
    return entryItem;
  },
  
  get_current_entry: function() {
    return this.get_entry(this.index);
  },
  
  select_entry: function() {
    this.active = false;
//    value = Element.collectTextNodesIgnoreClass(this.get_current_entry(), 'informal').unescapeHTML();    
    if(!this.typeAheadFullSearch)
    	value = Element.collectTextNodesIgnoreClass(this.get_current_entry(), 'informal');
    else
    	//value = this.first_child(this.get_current_entry()).getAttribute("value");    	
    	value = this.get_current_entry().getAttribute("value");
    
    this.updateElement(value);
    this.element.focus();
  },

  updateElement: function(value) {
	  var last_token_pos = this.findLastToken();
	  if (last_token_pos != -1) {
		  var new_value = this.element.value.substr(0, last_token_pos + 1);
		  var whitespace = this.element.value.substr(last_token_pos + 1).match(/^\s+/);
		  if (whitespace)
			  new_value += whitespace[0];       
		  //this.element.value = new_value + value;
		  this.setElementValue(new_value + value);
	  } else {
		  this.setElementValue(value);
	  } 

	  // called when something chosen from the list
	  this.chosen = true;

	  // update the hidden element
	  if (this.hidden_element != null)
	  {
		  var hiddenValue = null;

		  if (this.orig_hidden_values != null)
		  {
			  hiddenValue = this.orig_hidden_values[value];
		  }

		  if (hiddenValue == null && this.hidden_values != null)
		  {
			  hiddenValue = this.hidden_values[value];
		  }

		  // finally store the value
		  if (hiddenValue != null)
		  {
			  var strElementName=this.element.name+"_msvalue";
			  strElementName="document.forms[0].elements['"+strElementName+"']";
			  if (eval(strElementName))
			  {
				  //this.hidden_element.value = this.element.value;
				  this.setHiddenElementValue(value);
			  }
			  else
			  {
				  //this.hidden_element.value = hiddenValue;
				  this.setHiddenElementValue(hiddenValue);
			  }           
		  }
	  }

	  this.reloadOpener();
	  this.setElementValue(value);
  },
  
  initHiddenElement : function () {
	  if (this.hidden_element == null && this.hidden_element_name != null && this.hidden_element_name.length > 0) {
		  this.hidden_element = $$(this.hidden_element_name);
	  }
  } ,
  
  reloadOpener : function () {
	  if (this.element.name=='TypeActualDisplay' && this.rangeHelperURL.indexOf("ReloadOpener=false") == -1) {
		  if (this.element.value!=this.init_display_value) {
			  if(getTopWindow().reload) {
				  getTopWindow().reload();
			  } else {
				  window.reload();
			  }
		  }
	  } 

  } ,
  
  getSubmitURL : function (uiType) {
	  
	  try {
		  var qb = new Query(this.rangeHelperURL.replace(/\&amp;/g,"&"));
		  var submitURL = qb.getValue("submitURL");
		  if(submitURL == null || submitURL == "") {
			  submitURL = "../common/AEFSearchUtil.jsp";
		  }

		  // For SB Mass Update, this.hidden_element is null for first time selection.
		  this.initHiddenElement();
		  
		  qb.remove("submitURL");
		  qb.remove("table");
		  qb.remove("form");
		  qb.remove("type");
		  qb.remove("field");
		  qb.remove("fieldNameOID");
		  qb.remove("suiteKey");

		  qb.set("typeAhead","true");
		  qb.set("fieldNameActual",this.hidden_element.name);
		  qb.set("fieldNameDisplay",this.getHiddenFieldName(uiType));
		  qb.set("frameName",this.getFrameName(uiType));
		  qb.set("typeAhead","true");
		  qb.set("uiType",uiType);

		  submitURL += "?" + qb.getSearch();

		  return submitURL;
	  } catch (e) {
		  return "../common/AEFSearchUtil.jsp";
	  }
  },
  
  callSubmitURL: function(value) {
	  var uiType = this.getUiType();
	  var hiddenFrame = this.getHiddenFrame(uiType);
	  var submitURL = this.getSubmitURL(uiType);
	  //var url = submitURL+"?typeAhead=true&fieldNameActual=" + this.hidden_element.name + "&fieldNameDisplay=" + this.getHiddenFieldName(uiType) + "&frameName=" + this.getFrameName(uiType);

	  //When multiple selection enabled, send multiple tableRowId
	  var ids = value.split("|");
	  for(var i = 0; i < ids.length; i++) {
		  submitURL += "&emxTableRowId=" + ids[i];
	  }
	  
	  var targetWindow = hiddenFrame.contentWindow != null ? hiddenFrame.contentWindow : hiddenFrame.window;
	  submitWithCSRF(submitURL,targetWindow);
  },
  
  getUiType : function() {
	  try {
		  var qb = new Query(this.url.replace(/\&amp;/g,"&"));
		  var uiType = qb.getValue("uiType");
		  return uiType;
	  }
	  catch(e) {
		  return null;
	  }
  },  
  
  getHiddenFieldName: function (uiType) {
	  if(uiType == "structureBrowser") 
		  return this.element.name;
	  else
		  return this.hidden_element.name+"Display";
  },
  
  getFrameName : function(uiType) {
	  var name = "";
	  switch(uiType)
	  {
		  case "form":
			  name = "";
			  break;
	  }
	  return name;
  },  
  
  getHiddenFrame : function(uiType) {
	  
	  var name;
	  switch(uiType)
	  {
		  case "form":
			  name = "formEditHidden";
			  break;
		  case "structureBrowser":
			  name = "listHidden";
			  break;
		  case "createForm":
			  name = "formCreateHidden";
			  break;
	  }
	  return findFrame(parent, name);
  },  
  
  adjustDivWidth: function () {
	  if(this.getUiType() !== "structureBrowser") {
		  var isSlideIn = window.document.location.href.indexOf("targetLocation=slidein") != -1;
		  if(isSlideIn) {
			  if(this.typeAheadDivWidth == null) {
				  this.typeAheadDivWidth = this.update.offsetWidth;
			  }
			  if(this.typeAheadDivWidth > "300" || this.update.offsetWidth > "300") {
				  this.update.style.width='95%';
				  this.update.firstChild.style.minHeight= "43px";
				  //IR-145563V6R2013 - IE9.
				  //this.update.firstChild.style.overflow='auto';
			  }
		  }
	  }
  },
  
  adjustDivPosition: function () {

	  if(this.getUiType()== "structureBrowser") { 
		  if(isIE && isMaxIE7 ){
			  //in IE7, type ahead div gets shrinked
			  this.update.firstChild.style.width = "100%";
			  if(this.selectionMode == "multiple"){
				  this.update.lastChild.style.width = "100%";
			  }
		  } 
		  this.update.style.position = 'absolute';
		  var offsets = Position.cumulativeOffset(this.element);
		  this.update.style.left = offsets[0] + 'px';
		  this.update.style.top  = (offsets[1] + this.element.offsetHeight) + 'px';

		  var windowHeight=emxUICore.getWindowHeight();
		  var windowWidth = emxUICore.getWindowWidth();
		  var divHeight = this.update.offsetHeight;
		  var divWidth = this.update.offsetWidth;
		  var divTop = this.update.offsetTop;
		  var divLeft =this.update.offsetLeft;
		  var diffHeight = windowHeight - divHeight - divTop;
		  var diffWidth= windowWidth- divWidth - divLeft;
		  if(diffHeight < 0){
			  divTop = divTop - divHeight- this.element.offsetHeight;
			  if(divTop < 0){	
				  if(this.selectionMode == "multiple"){
					  var newHeight = this.update.offsetHeight - this.update.lastChild.offsetHeight - 8 + divTop +'px';
				  }
				  else{
					  var newHeight = this.update.offsetHeight - 8 + divTop +'px';
				  }

				  if(isIE){
					  this.update.firstChild.style.maxHeight = newHeight;
				  }else{
					  this.update.firstElementChild.style.maxHeight = newHeight;
				  }
				  this.update.style.top="0px";
			  }
			  else{	
				  this.update.style.top=divTop+'px';
			  }
		  }
		  if(diffWidth < 0) {
			  divLeft= divLeft + diffWidth;
			  if(divLeft >= 0) {
				  this.update.style.left=divLeft + 'px';
			  } else {
				  //when the tyeahead div width is more than the window width
				  this.update.style.width = "70%";
				  this.update.style.left= (0.29 * windowWidth) + 'px';
				  this.update.firstChild.style.overflow="auto";
			  }

		  }
		  if(isIE && isMaxIE7 ){
			  //reverting the css changes done for IE 7
			  this.update.firstChild.style.width = "auto";
			  if(this.selectionMode == "multiple"){
				  this.update.lastChild.style.width = "auto";
			  }
		  }
	  }

	  else {
		  this.update.style.position = 'absolute';
		  var offsets = Position.cumulativeOffset(this.element);
		  this.update.style.top  = (offsets[1] + this.element.offsetHeight) + 'px';
		  var divHeight = this.update.offsetHeight;
		  var divTop  = offsets[1] + this.element.offsetHeight ;
		  var scrollPosTop = 0;
		  var contentPageHeight = 0; 
		  if(document.getElementById('divPageBody')) {
			  scrollPosTop       = document.getElementById('divPageBody').scrollTop;
			  contentPageHeight  = document.getElementById('divPageBody').offsetHeight;
		  } else {
			  /*for self-edit form*/
			  if (document.documentElement && document.documentElement.scrollTop) {
				  scrollPosTop =  document.documentElement.scrollTop;
			  } else {
				  scrollPosTop = document.body.scrollTop;
			  }
			  contentPageHeight  = parent.document.getElementById('divPageBody').offsetHeight;
		  }
		  var divTopOffset = divTop - scrollPosTop;
		  var avlbSpaceBelow = contentPageHeight - divTopOffset;
		  var avlbSpaceAbove = divTopOffset - this.element.offsetHeight;

		  if(avlbSpaceBelow < divHeight)  {
			  var newHeight = divHeight;
			  if(avlbSpaceAbove > avlbSpaceBelow) {
				  var adjustedDivTop = divTopOffset - this.element.offsetHeight - divHeight;
				  if(adjustedDivTop > 0) {
					  // enough space available to accomodate type ahead div without div resizing
					  this.update.style.top= adjustedDivTop + scrollPosTop + "px";
				  }  else {
					  if(this.selectionMode == "multiple"){
						  newHeight = divTopOffset - this.element.offsetHeight  - this.update.lastChild.offsetHeight - 8  + "px";
					  } else {
						  newHeight = divTopOffset - this.element.offsetHeight  - 8  + "px";
					  }
					  this.update.style.top = scrollPosTop + "px";
				  }  
			  } else {
				  if(this.selectionMode == "multiple"){
					  newHeight = avlbSpaceBelow - this.update.lastChild.offsetHeight - 9 + "px";
				  } else {
					  newHeight = avlbSpaceBelow - 9 + "px";
				  }
			  }
			  if(isIE) {
				  this.update.firstChild.style.maxHeight = newHeight;
			  } else {
				  this.update.firstElementChild.style.maxHeight = newHeight;
			  }
		  }
	  }
} ,
 
  
  updateChoices: function(choices) {
	  if(!this.changed && this.has_focus) {
			  // Clear the type ahead div content before appending new choice list
			  if(this.update.firstChild) {
				  this.update.innerHTML = "";
			  }
			  this.update.appendChild(choices);
		  var entryList = this.update.firstChild;
		  this.noResults = true;
		  if(!(entryList.childNodes[0].nodeName =="SPAN")){
			  entryList = this.update.firstChild.firstChild; 
			  this.noResults = false;
		  }	  
		  if(this.typeAheadFullSearch && !this.noResults) {
			  //Add Footer to Type Ahead Div
			  var divFooter = document.createElement("DIV");
			  Element.addClassName(divFooter, "type-ahead-foot");
			  var objTable = document.createElement("table");
			  divFooter.appendChild(objTable);
			  var objTBody = document.createElement("tbody");
			  objTable.appendChild(objTBody);
			  var objTR = document.createElement("tr");
			  objTBody.appendChild(objTR);
			  var objTD = document.createElement("td");
			  objTR.appendChild(objTD);
			  Element.addClassName(objTD,"buttons");
			  var objUL = document.createElement("ul");
			  objTD.appendChild(objUL);
			  var doneBtn = document.createElement("li");
			  var cancelBtn = document.createElement("li");
			  doneBtn.innerHTML = "<a class='btn-done' href=\"javascript:;\"><span>" + emxUIConstants.STR_FPDONE + "</span></a>";
			  cancelBtn.innerHTML = "<a class='btn-cancel' href=\"javascript:;\"><span>" + emxUIConstants.STR_FPCANCEL + "</span></a>";
			  objUL.appendChild(doneBtn);
			  objUL.appendChild(cancelBtn);
			  Event.observe(doneBtn, "click", this.onDone.bindAsEventListener(this));
			  Event.observe(cancelBtn, "click", this.onCancel.bindAsEventListener(this));
			  this.update.appendChild(divFooter);
		  }

		  Element.cleanWhitespace(this.update);
		  Element.cleanWhitespace(this.update.firstChild);
		  this.index = 0;
		  if(!this.noResults){
		  if(entryList && entryList.childNodes && entryList.childNodes.length > 0) {
				  if(entryList.childNodes[0]) {
					  this.entry_count = entryList.childNodes[0].childNodes.length;
				  }	 
			  //this.entry_count = entryList.childNodes.length;
			  for (var i = 0; i < this.entry_count; i++) {
				  entry = this.get_entry(i);
				  entry.autocompleteIndex = i;
				  this.addObservers(entry);
				  value = Element.collectTextNodesIgnoreClass(entry, 'informal');
				  if(this.typeAheadFullSearch || !("createform" == this._uiType || "form" == this._uiType)){
					  value = value.unescapeHTML();
				  }
				  if ((this.index == 0) && (value == this.element.value))
				  {
					  this.index = i;
				  }
			  }
		  } else { 
			  this.entry_count = 0;
		  }
		  }
		 this.stopIndicator();
		 var flag = this.render();
		 if(this.typeAheadFullSearch && flag != true && this.element && this.element.parentNode != null ) {
		 	this.adjustDivPosition();
			this.adjustDivWidth();
	     }
	}
  },

  addObservers: function(element) {
    Event.observe(element, "mouseover", this.onHover.bindAsEventListener(this));
    Event.observe(element, "click", this.onClick.bindAsEventListener(this));
  },

  onObserverEvent: function() {
    this.changed = false;   
    this.chosen = false;

    if(this.getEntry() && this.getEntry().length >= this.characterCount) {
      this.startIndicator();
      this.getUpdatedChoices();
    } else {
      this.active = false;
      this.hide();
    }
  },

  getEntry: function() {
    var token_pos = this.findLastToken();
    if (token_pos != -1){
      var ret = this.element.value.substr(token_pos + 1).replace(/^\s+/,'').replace(/\s+$/,'');
    }
    else{
      var ret = this.element.value;  
      if("**" != ret){
		ret = ret.replace(/\*+/g, "*");    //remove multiple occureance to single
		ret = ret.replace(/^\*/g, "");     // remove the first occurence
      }  
    }
    return /\n/.test(ret) ? '' : ret;
  },

  findLastToken: function() {
    var last_token_pos = -1;

    for (var i=0; i<this.options.tokens.length; i++) {
      var this_token_pos = this.element.value.lastIndexOf(this.options.tokens[i]);
      if (this_token_pos > last_token_pos)
        last_token_pos = this_token_pos;
    }
    return last_token_pos;
  }
}

Ajax.TypeAhead = Class.create();
Ajax.TypeAhead.prototype = Object.extend(new TypeAhead.Base(), 
Object.extend(new Ajax.Base(), {
	initialize: function(element, update, hidden_element,  url, display, hidden, characterCount, options, typeAheadValidate, selectionMode, rangeHelperURL, rowId, isSBMassUpdate, tempUIType) {
      this.base_initialize(element, update, hidden_element, options);
    this.options.asynchronous = true;
    this.options.onComplete   = this.onComplete.bindTA(this)
    this.options.method       = 'post';
    this.options.ignore_case  = true,
    this.url                  = url;
    this.orig_display_values  = [];
    this.orig_hidden_values   = null;
    this.display_values       = null;
    this.hidden_values        = null;
    this.all                  = false;
    this.characterCount       = characterCount;
    this.typeAheadFullSearch  = this.url.indexOf("emxTypeAheadFullSearch.jsp") != -1;
    this.typeAheadValidate    = typeAheadValidate || false;
    this.selectionMode        = selectionMode;
    this.rangeHelperURL       = rangeHelperURL;
    this.rowId			      = rowId;
    this.selectedRowsMap      = new HashMap();
    this.done                 = false;
    this._uiType              = tempUIType ? tempUIType.toLowerCase():"";

    this.isSB 				  = false;
    this.isSBMassUpdate		  = isSBMassUpdate || false;
    if(typeof(uiType) != "undefined" && uiType == "structureBrowser" && !isSBMassUpdate) {
    	this.isSB = true;
    }

    this.typeAheadDivWidth    = null;
    if(this.rangeHelperURL){
    	this.typeChooser          = this.rangeHelperURL.indexOf("emxTypeChooser.jsp") != -1;
    }
    
    if (!this.typeAheadFullSearch && display != null && display.length > 0)
    {
    	this.orig_display_values  = display;
        if (hidden != null && hidden.length == display.length)
        {
            // build an associative array to look up hidden values
            this.orig_hidden_values = new Object();
            for (var i = 0; i < display.length; i++)
            {
                this.orig_hidden_values[display[i]] = hidden[i];
            }
        }

        // sort after the association because 
        // the values are order dependent
        display.sort();
    }
	//add class to typeAheadDiv
	if(this.typeAheadFullSearch) {
		Element.addClassName(this.update, "type-ahead");
		Element.removeClassName(this.update, "type_ahead");
		if(this.selectionMode && this.selectionMode == "multiple") {
			Element.addClassName(this.update, "multiple");
		}
	}
  },
  
/**
 * Throughout, whitespace is defined as one of the characters
 *  "\t" TAB \u0009
 *  "\n" LF  \u000A
 *  "\r" CR  \u000D
 *  " "  SPC \u0020
 *
 * This does not use Javascript's "\s" because that includes non-breaking
 * spaces (and also some other characters).
 */


/**
 * Determine whether a node's text content is entirely whitespace.
 *
 * @param nod  A node implementing the |CharacterData| interface (i.e.,
 *             a |Text|, |Comment|, or |CDATASection| node
 * @return     True if all of the text content of |nod| is whitespace,
 *             otherwise false.
 */
is_all_ws: function( nod )
{
  // Use ECMA-262 Edition 3 String and RegExp features
  return !(/[^\t\n\r ]/.test(nod.data));
},


/**
 * Determine if a node should be ignored by the iterator functions.
 *
 * @param nod  An object implementing the DOM1 |Node| interface.
 * @return     true if the node is:
 *                1) A |Text| node that is all whitespace
 *                2) A |Comment| node
 *             and otherwise false.
 */

is_ignorable: function( nod )
{
  return ( nod.nodeType == 8) || // A comment node
         ( (nod.nodeType == 3) && this.is_all_ws(nod) ); // a text node, all ws
},

/**
 * Version of |previousSibling| that skips nodes that are entirely
 * whitespace or comments.  (Normally |previousSibling| is a property
 * of all DOM nodes that gives the sibling node, the node that is
 * a child of the same parent, that occurs immediately before the
 * reference node.)
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest previous sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
node_before: function( sib )
{
  while ((sib = sib.previousSibling)) {
    if (!this.is_ignorable(sib)) return sib;
  }
  return null;
},

/**
 * Version of |nextSibling| that skips nodes that are entirely
 * whitespace or comments.
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest next sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
node_after: function( sib )
{
  while ((sib = sib.nextSibling)) {
    if (!this.is_ignorable(sib)) return sib;
  }
  return null;
},

/**
 * Version of |lastChild| that skips nodes that are entirely
 * whitespace or comments.  (Normally |lastChild| is a property
 * of all DOM nodes that gives the last of the nodes contained
 * directly in the reference node.)
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The last child of |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
last_child: function( par )
{
  var res=par.lastChild;
  while (res) {
    if (!this.is_ignorable(res)) return res;
    res = res.previousSibling;
  }
  return null;
},

/**
 * Version of |firstChild| that skips nodes that are entirely
 * whitespace and comments.
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The first child of |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
first_child: function( par )
{
  var res=par.firstChild;
  while (res) {
    if (!this.is_ignorable(res)) return res;
    res = res.nextSibling;
  }
  return null;
},

/**
 * Version of |data| that doesn't include whitespace at the beginning
 * and end and normalizes all whitespace to a single space.  (Normally
 * |data| is a property of text nodes that gives the text of the node.)
 *
 * @param txt  The text node whose data should be returned
 * @return     A string giving the contents of the text node with
 *             whitespace collapsed.
 */
data_of: function( txt )
{
  var data = txt.data;
  // Use ECMA-262 Edition 3 String and RegExp features
  data = data.replace(/[\t\n\r ]+/g, " ");
  if (data.charAt(0) == " ")
    data = data.substring(1, data.length);
  if (data.charAt(data.length - 1) == " ")
    data = data.substring(0, data.length - 1);
  return data;
},

  getUpdatedChoices: function()
  {
	// if we match something in the original list, keep displaying it
	if (this.match(this.orig_display_values) == true)
	{
		this.updateChoices(this.buildList(this.orig_display_values, true));
	}
	else
	{
		if ((this.url != null && this.url.length > 0) &&
				this.all == false &&
				this.getEntry().length >= this.characterCount &&
				(this.type_ahead == null || this.type_ahead != this.getEntry().substring(0, this.characterCount)))
		{
			if(!this.typeAheadFullSearch) {
				entry = 'type_ahead_filter=' + encodeURIComponent(this.getEntry().substring(0, this.characterCount));
				if (this.options.method == 'post') {
					this.options.requestHeaders = [];
					this.options.requestHeaders.push('Content-type', 'application/x-www-form-urlencoded');
				}
			}
			else {
				entry = 'type_ahead_filter=' + encodeURIComponent(this.getEntry().replace(/\t/g, ''));
			}

			this.options.parameters = this.options.callback ? this.options.callback(this.element, entry) : entry;
			if(this.typeAheadFullSearch) 
			{
				var fieldValues = [];
				if(this.isSB)
				{
					fieldValues = emxEditableTable.getRowColumnValues(this.rowId);
				}
				else if (!this.isSBMassUpdate){
					fieldValues = FormHandler.GetFieldValues();
				}					
				this.options.method = "post";
				var json = {};
				json.fieldValues = fieldValues;
				json.type_ahead_filter = encodeURIComponent(this.getEntry().replace(/\t/g, ''));
				this.options.postBody = emxUICore.toJSONString(json);
				this.options.requestHeaders = [];
				this.options.requestHeaders.push("Content-type","text/plain; charset=UTF-8");
			}
			new Ajax.Request(this.url.replace(/\&amp;/g,"&"), this.options);
		}
		else
		{
			// filter the existing list from program
			this.updateChoices(this.buildList(this.display_values, true));
		}
	}
  },
  
  buildList: function(values, filter)
  {
	  var divBody = document.createElement("DIV");
	  Element.addClassName(divBody, "type-ahead-body");
	  var response = "<table>";  
	  var UIType = document.getElementById("uiType").value;
    if (values != null)
    {
        var entry = this.getEntry();
        var codecVal = "";
        var paramJSON = {};
        if("createform" == this._uiType){
        	paramJSON.decodeType = "html";
        }else if ("form" == this._uiType){
        	paramJSON.encodeType = "html";
        }
        paramJSON.entry = entry;
        paramJSON.uiType = this._uiType;
        paramJSON.ignoreCase = this.options.ignore_case;
		paramJSON.typeAheadFullSearch = this.typeAheadFullSearch;
        var found_pos = -1; 
        for (var i = 0 ; i < values.length; i++)
        {
            var elem = values[i];
            paramJSON.elem = values[i];
            found_pos = getEntryStringIndex(paramJSON);
            var condition = this.typeAheadFullSearch ? true : found_pos >= 0;
            if (filter == false || condition)
            {
            	var _displayValue = values[i];
            	if(!this.typeAheadFullSearch && !("createform" == UIType || "form" == UIType)){
            		_displayValue = values[i].escapeHTML();
            	}
                response += "<tr><td><span>" + _displayValue  + "</span></td></tr>";
            }
        }
    }
    
    response += "</table>";
    divBody.innerHTML = response;
    return divBody;
  },
  
  buildListForTypeAhead: function(values, filter, noResultValue)
  {
	  var divBody = document.createElement("DIV");
	  var noResults = false;
	  Element.addClassName(divBody, "type-ahead-body");
	  jQuery(divBody).attr('id', 'ta-body-id');
	  if(values.length == 1 && (noResultValue.indexOf(emxUIConstants.TYPEAHEAD_NORESULTS) != -1)) {
		  noResults= true;
	  }
	  var response = "<table>";
	  if (values != null)
	  {
		  for (var i = 0 ; i < values.length; i++)
		  {
			  var elem = values[i];

			  // escape the text so that we can use special characters
			  response += values[i] ;
		  }
	  }
	  if(noResults) {
		  jQuery(divBody).attr('id', 'nr-ta-body-id');
	  }
	  response += "</table>";
	  divBody.innerHTML = response;
	  return divBody;
  },
  
  
  match: function(values)
  {
    var entry = this.getEntry();
    var codecVal = entry;
    var paramJSON = {};
    if("createform" == this._uiType){
    	paramJSON.decodeType = "html";
    }else if ("form" == this._uiType){
    	paramJSON.encodeType = "html";
    }
    paramJSON.entry = entry;
    paramJSON.uiType = this._uiType;
    paramJSON.ignoreCase = this.options.ignore_case;
	paramJSON.typeAheadFullSearch = this.typeAheadFullSearch;
    for (var i = 0 ; i < values.length; i++)
    {
    	 paramJSON.elem = values[i];
         found_pos = getEntryStringIndex(paramJSON);
         if (found_pos == 0){
            return (true);
    }
     }
  
    return (false);
  },
  
  onComplete: function(request)
  {
    // parse the xml
    var objDOM = emxUICore.createXMLDOM();
    
    // hack because we get the response with some whitespace before <?xml
    // which causes the parser to fail.  Also, if and error is returned
    // the string won't start with <?xml.
    var responseText = request.responseText.substring(request.responseText.indexOf('<'));
    if (responseText.indexOf("<?xml") != 0)
    {
        // show the error
        document.write(request.responseText);
        return;
    }
    
    objDOM.loadXML(responseText);
//      if (objDOM.parseError.errorCode != 0)
//      alert("errorCode: " + objDOM.parseError.errorCode + "\n" +
//          "filepos: " + objDOM.parseError.filepos + "\n" +
//          "line: " + objDOM.parseError.line + "\n" +
//          "linepos: " + objDOM.parseError.linepos + "\n" +
//          "reason: " + objDOM.parseError.reason + "\n" +
//          "srcText: " + objDOM.parseError.srcText + "\n" +
//          "url: " + objDOM.parseError.url);
    emxUICore.checkDOMError(objDOM);
    
    // build the choices array
    var root = objDOM.documentElement;
    var objField = this.first_child(root);
    var objValues = this.first_child(objField);
    //var values = objValues.childNodes;
    var values = emxUICore.selectNodes(objValues, "v");
    
    // determine value of "all" (values sent) attribute
    var all = ("true" == objValues.attributes.getNamedItem("all").nodeValue);

    var count = objValues.attributes.getNamedItem("count").nodeValue;
    if(this.typeAheadFullSearch)
    	var searchLimitReached = objValues.attributes.getNamedItem("searchLimitReached").nodeValue;

    var node;
    var display = new Array();
    var hidden = new Object();
    var j = 0;
    var colsInRow = 1;
    for (var i = 0; i < values.length; i++)
    {
        node = this.first_child(values[i]);
        if (!this.typeAheadFullSearch && node)
        {
            // get the display value
            if (node.nodeName == "d")
            {
            	//modified for IR-033985
            	var txt= this.first_child(node);
            	if(txt!= null){
                display[j] = this.data_of(txt);
                }
				else{
				display[j]= " ";
				}	
				
                // get the hidden value
                node = this.node_after(node);
                if (node && node.nodeName == "h");
                {
                    // build the associative array of hidden values
                    node = this.first_child(node);
                    if (node != null)
                    {
                        hidden[display[j]] = this.data_of(node);
                    }
                }
                
                j++;
            }           
        }
        else
        {
        	var columns = emxUICore.selectNodes(values[i], "c");
        	var dvalues  = [];
        	var id = values[i].getAttribute("id");
        	var name = values[i].getAttribute("name");
        	if(this.typeChooser && name === "") {
        		name = emxUICore.getText(columns[0]);
        	}
        	if(count !== "0") {
        		dvalues.push("<tr value='" + id + "' displayValue=\"" + name + "\">");
        	}
        	else {
        		dvalues.push("<tr value=''");
        		/*Element.removeClassName(this.update, "multiple");
        		this.selectionMode = "single";*/
        	}
        	
        	for(var l = 0; l < columns.length; l++)
        	{  
        		var tdValue= "";
        		if(columns[l].getAttribute("isHTML")== "true"){
        			tdValue = emxUICore.getText(columns[l]);
        		}else{
        			tdValue = getXSSEncodedValue({"value":emxUICore.getText(columns[l]), "encodeType":"html"});
        		}
        		if(l == 0){
        			dvalues.push("<td><span class='object'>" + tdValue + "</span></td>");
        		}
        		else {
        			dvalues.push("<td>" + tdValue + "</td>");
        		}
        	}
        	dvalues.push("</tr>");
        	
        	
        	display[j] = dvalues.join("");
        	if(id != null && id != "") {
        		hidden[id] = id;
        	}
        	j++;
        	if(columns.length > colsInRow ) {
        		colsInRow = columns.length;
        	}
       	}
    }
    
    if(this.typeAheadFullSearch && searchLimitReached == "true") {
    	var dvalues = [];
    	dvalues.push("<tr value='ViewAllResults'><td colspan='" + colsInRow + "'><span class='view-all'>");
    	dvalues.push(emxUIConstants.STR_VIEW_ALL_SEARCH_RESULTS);
    	dvalues.push("</span></td></tr>");
    	display[j] = dvalues.join("");
    }
 
    // sort the results
    if(!this.typeAheadFullSearch)
    	display.sort();

    // save the results in this object
    
    if(!this.typeAheadFullSearch)
    {
    	this.display_values = display;    	
    	this.all = all;
    	this.type_ahead = this.getEntry().substring(0, this.characterCount);
    }
    this.hidden_values = hidden;
    // update the div
    if(!this.typeAheadFullSearch)
    	this.updateChoices(this.buildList(display, true));
    else
    	this.updateChoices(this.buildListForTypeAhead(display, true, values[0].getAttribute("name")));
}


}));

function watchForChange1(name, val, rowId, sameDisplayValSelected){	
    if(document.forms[0][name].value == val){
        setTimeout(function(){
        	if(document.forms[0][name].value == val && !sameDisplayValSelected){
        		watchForChange1(name, val, rowId);
        	}else{
        		updateTextWithHelper(rowId, true);
        	}
        },10);
    }else{
    	updateTextWithHelper(rowId, true);
    }
}

function getEntryStringIndex(paramJSON){
	var codecVal = "";
	var found_pos = -1;    
	if(paramJSON.ignoreCase){
		var elemLowerCase = paramJSON.elem.toLowerCase();
		var entryLowerCase = paramJSON.entry.toLowerCase();
		entryLowerCase = strReplaceAll(entryLowerCase ,"*", "");
		if(elemLowerCase.length >= entryLowerCase.length){
		    found_pos = elemLowerCase.indexOf(entryLowerCase);
		}
		if(found_pos != 0 && !paramJSON.typeAheadFullSearch){
			if("createform" == paramJSON.uiType){  
				paramJSON.value = elemLowerCase;		
				codecVal = getXSSDecodedValue(paramJSON);
				if(codecVal.length >= entryLowerCase.length){
				    found_pos = codecVal.indexOf(entryLowerCase);
				}
			}else if ("form" == paramJSON.uiType){
				paramJSON.value = entryLowerCase;			
				codecVal = getXSSEncodedValue(paramJSON);
				if(elemLowerCase.length >= codecVal.length){
				    found_pos = elemLowerCase.indexOf(codecVal);
				}
			}
		}
	}else{
		if(paramJSON.elem.length >= paramJSON.entry.length){
		    found_pos = paramJSON.elem.indexOf(paramJSON.entry);
		}
		if(found_pos != 0 && !paramJSON.typeAheadFullSearch){
			if("createform" == paramJSON.uiType){  
				paramJSON.value = paramJSON.elem;      				
				codecVal = getXSSDecodedValue(paramJSON);
				if(codecVal.length >= paramJSON.entry.length){
				    found_pos = codecVal.indexOf(paramJSON.entry);
				}
			}else if ("form" == paramJSON.uiType){
				paramJSON.value = paramJSON.entry;
				codecVal = getXSSEncodedValue(paramJSON);
				if(paramJSON.elem.length >= codecVal.length){
				    found_pos = paramJSON.elem.indexOf(codecVal);
				}
			}
		}
	}
	return found_pos;
}

function getDynamicSearchRefinements(url, curFieldName, fieldValues, isFromChooser) {
	var qurl   = new Query(url);
	var qfield = qurl.getValue("field");
	var qfieldProgram = qurl.getValue("fieldProgram");
	if(qfieldProgram != null && qfieldProgram != ""){
		var uiType	    = document.getElementById("uiType").value;
		var dynamicQuery = qfieldProgram.split(":");
		var qjson = {};
		if(uiType == "structureBrowser" && isFromChooser ){
			qjson.fieldValues = fieldValues;
		}else{
			qjson.fieldValues = FormHandler.GetFieldValues();
		}
		var timeStamp     = document.getElementById("timeStamp").value;
		var mode			= document.getElementById("mode").value;
		var jurl          = new Query("../emxTypeAheadFullSearch.jsp");
		jurl.set("timeStamp", timeStamp);
		jurl.set("uiType", 	uiType);
		jurl.set("mode", 		mode);
		jurl.set("field", 	curFieldName);
		jurl.set("program", 	"emxTypeAheadFullSearch");
		jurl.set("function",  "getQueryField");
		jurl.set("fieldProgram",  qfieldProgram);
		if(isFromChooser){
			jurl.set("isFromChooser",  "true");
		}
		var fieldValue = emxUICore.GetJsonRemote(jurl.toString(),qjson).field;
		if(qfield != null && qfield != "") {
			fieldValue = qfield + ":" + fieldValue;
		}
		qurl.replace("field", fieldValue, true);
		url = qurl.toString();
	}
	return url;
}

