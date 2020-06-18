/*jslint plusplus:true*/

var swv6 = swv6 || {};
swv6.util = swv6.util || {};



// requestAnimFrame and cancelAnimFrame polyfill
(function() {
    'use strict';
    window.requestAnimationFrame = window.requestAnimationFrame       ||
                                   window.webkitRequestAnimationFrame ||
                                   window.mozRequestAnimationFrame    ||
                                   window.oRequestAnimationFrame      ||
                                   window.msRequestAnimationFrame     ||
                                   function (callback) {
                                       return setTimeout(callback, 16);
                                   };

    window.cancelAnimationFrame =  window.cancelAnimationFrame       ||
                                   window.webkitCancelAnimationFrame ||
                                   window.mozCancelAnimationFrame    ||
                                   window.oCancelAnimationFrame      ||
                                   window.msCancelAnimationFrame     ||
                                   function (id) {
                                       clearTimeout(id);
                                   };
}());

// String trim polyfill
if(!String.prototype.trim) {
    String.prototype.trim = function () {
        'use strict';
        return this.replace(/^\s+|\s+$/g,'');
    };
}


// a simple helper to merge attributes from two objects into one new object.
swv6.util.join = function (o1, o2) {
    var result = {},
        attr;

    for (attr in o1) {
        if (o1.hasOwnProperty(attr)) {
            result[attr] = o1[attr];
        }
    }
    for (attr in o2) {
        if (o2.hasOwnProperty(attr)) {
            result[attr] = o2[attr];
        }
    }

    return result;
};

swv6.util.thwart = function (e) {
    'use strict';
    if(e.preventDefault) {
        swv6.util.thwart = function (e) {
            e.preventDefault();
        };
    } else {
        swv6.util.thwart = function (e) {
            e.returnValue = false;
        };
    }
    swv6.util.thwart(e);
};

swv6.util.burst = function (e) {
    'use strict';
    if(e.stopPropagation) {
        swv6.util.burst = function (e) {
            e.stopPropagation();
        };
    } else {
        swv6.util.burst = function (e) {
            e.cancelBubble = true;
        };
    }
    swv6.util.burst(e);
};

/**
 * @class swv6.util
 * A collection of utility functions and classes.
 * @singleton
 */

(function () {
    /**
     * Returns a reference to an SVG element within a document.
     * Useful for creating matrices and points.
     * @return {Object} An SVG element.
     */
    swv6.util.getSVG = function () {
        var svg = document.getElementsByTagName('svg')[0];
        swv6.util.getSVG = function () {
            return svg;
        };
        return svg;
    }; 
}());


(function () {
    'use strict';
    /**
     * A utility function which creates callable functions with the given scope.
     * @return {Function} A function delegate.
     */
    swv6.util.delegate = function (scope, fn, args) {
        return function () {
            fn.apply(scope, args);
        };
    };
}());


(function () {
    'use strict';
    /**
     * Performs set logic on two arrays, using a compare function to determine equality.
     * @param {Array} setA The first set.
     * @param {Array} setB The second set.
     * @param {Function} compare The function used to determine equailty between set members.
     * @return {Object} The result sets.
     * @return {Array} return.complementA All items in B but not in A.
     * @return {Array} return.complementB All items in A but not in B.
     * @return {Array} return.intersection All items shared by both A and B.
     * @return {Array} return.union All items in A and B.
     * @return {Array} return.difference All items *not* shared by both A and B.
     */
    swv6.util.setTheory = function (setA, setB, compare) {
        var existing = [],
            i, j,
            aa, a, // a for setA
            bb, b, // b for setB
            intersection = [];

        // copy elements into temp arrays.
        aa = setA.slice(0);
        bb = setB.slice(0);

        for (i = aa.length - 1; i >= 0; i--) {
            a = aa[i];
            for (j = bb.length - 1; j >= 0; j--) {
                b = bb[j];
                if (compare(a, b)) {
                    // item exists in both sets.
                    intersection.unshift([a, b]); // add both forms of item to intersection set.
                    aa.splice(i, 1); // remove this from new items list.
                    bb.splice(j, 1); // remove this from old items list.
                }
            }
        }

        return {
            complementA: bb,
            complementB: aa,
            intersection: intersection,
            union: aa.concat(intersection, bb),
            difference: aa.concat(bb)
        };
    };
}());


(function () {
    'use strict';

    // Since classList support is sketchy, these can be used instead.

    var regex = function (cls) {
        // regex looks for space delimited class names, taking start and end of string into account
        return new RegExp('(?:^| )(' + cls + ')(?: |$)');
    };

    /**
     * Adds a class to an existing class list. 
     * @param {String} list An existing class list.
     * @param {String} cls The class to be added to the existing class list.
     * @return {String} The updated class list.
     */
    swv6.util.addClass = function (list, cls) {
        if (!swv6.util.hasClass(list, cls)) {
            list += ' ' + cls;
        }
        return list;
    };

    /**
     * Removes a class from an existing class list. 
     * @param {String} list An existing class list.
     * @param {String} cls The class to be removed the existing class list.
     * @return {String} The updated class list.
     */
    swv6.util.removeClass = function (list, cls) {
        return list.replace(regex(cls), ' ');
    };

    /**
     * Checks if an existing class list contains a given class. 
     * @param {String} list A class list.
     * @param {String} cls The class being searched for.
     * @return {Boolean} True if cls is in list, false otherwise.
     */
    swv6.util.hasClass = function (list, cls) {
        return (list.match(regex(cls)) !== null);
    };

}());

(function () {
    var ss = undefined;

    getSS = function () {
        if (!ss) {
            ss = createStyleSheet().sheet;
        }
        return ss;
    };
    
    createStyleSheet = function () {
        var sheet = document.createElement('style');
        document.body.appendChild(sheet);
        return sheet;
    };

    swv6.util.createRule = function (selector, styles) {
        var ss = getSS(),
            rule,
            style;

        ss.insertRule(selector + " { }", 0);
        rule = ss.cssRules[0];

        if (styles) {
            for(style in styles) {
                if(styles.hasOwnProperty(style)) {
                    rule.style[style] = styles[style];
                }
            }        
        }

        return rule;
    };

}());
    
(function () {
    'use strict';
/*
    var BaseObject = {
        ctor: function () {}
    };
*/
    /**
     * Provides standard OOP inheritance functionality for JS objects.
     * <p>example:</p><pre><code>
// Object will inherit from basic javascript Object.
// If a 'ctor' property is present in the properties, it will be used as a constructor.
MyClass = swv6.util.inherit(properties);

// Object will inherit from base.
// If a 'ctor' property is present in the properties, it will be used as a constructor.
MyClass = swv6.util.inherit(base, properties);

// Object will inherit from base.
// The provided 'ctor' function will be used as a constructor.
MyClass = swv6.util.inherit(ctor, base, properties);
     * </code></pre>

     * <p>In each of the above examples, the objects created using the MyClass constructor will inherit all properties
     * and methods found in the 'properties' object, in addition to any inherited members from the base class.</p>
     * <p>Further derived objects may override any of these
     * properties, and can then access these base properties via DERIVED_CLASS.base.</p>
     * <p>example:</p><pre><code>
var Door = swv6.util.inherit({

    ctor: function () {
        this.isOpen = false;
    },

    open: function () {
        this.isOpen = true;
    }
    
    close: function () {
        this.isOpen = false;
    }
});

var LockableDoor = swv6.util.inherit(Test, {

    ctor: function (name) {
        LockableDoor.base.ctor.apply(this);
        this.isLocked = false;
    },

    open: function () {
        if (!this.isLocked) {
            LockableDoor.base.open.apply(this);
        }
    },
    
    setLocked: function (locked) {
        this.isLocked = locked;
    }
});

var door = new LockableDoor();
door.open();  // succeeds, door.isOpen is now true;
door.close(); // door.isOpen is now false;
door.setLocked(true); // lock door
door.open();  // fails, door.isOpen is still false;
     * </code></pre>
     * <p>If no constructor is provided, either as the first argument or as a member of the properties,
     * a default constructor will be used that merely calls the object's base ctor.</p>
     * @param {Array} [args] Arguments, as described above.
     * @return {Function} A constructor function.
     */
    swv6.util.inherit = function () {
        var args = [].splice.call(arguments,0),
            ctor,
            base, 
            properties,
            fn,
            Tmp,
            tmp,
            prop;
    
        if (args.length === 1) {
            base = Object;
            properties = args[0];
        } else if (args.length === 2) {
            base = args[0];
            properties = args[1];
        } else {
            ctor = args[0];
            base = args[1];
            properties = args[2];
        }
    
        if (ctor) {
            fn = ctor;
        } else if (properties.ctor) {
            fn = properties.ctor;
        } else {
            fn = (base.prototype && base.prototype.ctor) 
                ? function () {
                      base.prototype.ctor.apply(this, arguments);
                  }
                : function () {};
        }
        
        Tmp = function () {};
        if(base !==undefined){
        	        
	        Tmp.prototype = base.prototype;
	        tmp = new Tmp();
	        
	        fn.prototype = tmp;
	        fn.base = base.prototype;
	
	        if (!properties.ctor) {
	            properties.ctor = fn;
	        }
	
	        for(prop in properties) {
	            if(properties.hasOwnProperty(prop)) {
	                fn.prototype[prop] = properties[prop];
	            }
	        }        
    	}
        return fn;
    };
    
}());

(function () {
    /**
     * @class swv6.util.Publisher
     * An object implementing the observer pattern.
     */
    'use strict';

    swv6.util.Publisher = swv6.util.inherit({
        events: {},
        _events: undefined,

        ctor: function () {
            this._events = {};
        },

        /**
         * Adds an event that can be listened for by observers of this object.
         * @param {String} event The name of the new event.
         */
        addEvent: function (event) {
            if (this.events[event] === undefined) {
                this.events = swv6.util.join(this.events, {}); // copy
                this.events[event] = true;
            }
//            this.events[event] = this.events[event] || true;
//            if (this.events[event] === undefined) {
//            }
        },

        /**
         * Adds a listener function for a specific event.
         * @param {String} event The name of the event being subscribed to.
         * @param {Object/undefined} scope An object that will be used for the scope of the callback function.
         * @param {Function} fn A callback function to be called when the event is fired.
         * @return {Boolean} True if succeeded, false otherwise.
         */
        subscribe: function (event, scope, fn) {
            var success = false,
                e;

            if (this.events[event]) {
                e = this._events[event];
                if (e === undefined) {
                    // lazy instantiation
                    this.onFirstSubscribe(event);
                    e = this._events[event] = [];
                }
                e.push({fn: fn, scope: scope});
                success = true;
            }

            return success;
        },

        /**
         * Removes a listener function for a specific event.
         * @param {String} event The name of the event being unsubscribed from.
         * @param {Object/undefined} scope An object that was used for the scope of the callback function.
         * @param {Function} fn A callback function that was to be called when the event was fired.
         * @return {Boolean} True if succeeded, false otherwise.
         */
        unsubscribe: function (event, scope, fn) {
            var success = false,
                e, i, o, found;

            e = this._events[event];
            if (e !== undefined) {
                for (i=0; (i < e.length) && !found; i++) {
                    o = e[i];
                    if ((o.fn === fn) && (o.scope === scope)) {
                        found = true;
                        e = e.splice(i, 1);
                    }
                }

                success = found;
            }

            return success;
        },
        
        /**
         * Fires an event, notifying all of its listeners.
         * @param {String} event The name of the event being fired.
         * @param {Array} args (optional) An object that was used for the scope of the callback function.
         * @return {Boolean} True if succeeded, false otherwise.
         */
        publish: function (event) {
            var success = true,
                ret,
                e, i, o, found, args;

            e = this._events[event];
            if (e !== undefined) {
                args = [].splice.call(arguments,1);
                if (e.length) {
                    e = e.slice(0); // get a shallow copy.
                    for (i=0; (i < e.length) && !found; i++) {
                        o = e[i];
                        // handlers may return true or false.
                        ret = o.fn.apply(o.scope, args);
                        if ((ret === undefined) || (ret === null)) {
                            // if handler didn't return anything, assume true.
                            ret = true;
                        }
                        success = success && ret;
                    }
                }
            }
            
            return success;
        },
        
        /**
         * Allows for lazy event instantiation, to prevent allocation of resources for events
         * that are never used.
         * @protected
         * @param {String} event The name of the event being instantiated.
         */
        onFirstSubscribe: function (event) {
            
        },
        
        /**
         * @inheritdoc swv6.util.Publisher#subscribe
         */
        sub:   function (event, scope, fn) { this.subscribe(event, scope, fn); },
        /**
         * @inheritdoc swv6.util.Publisher#unsubscribe
         */
        unsub: function (event, scope, fn) { this.unsubscribe(event, scope, fn); }
    });
    
}());


(function () {
    /**
     * @class swv6.util.XMLParser
     * A cross-browser XML parser.
     */
    'use strict';
    var CLASS,
        BASE = Object;

    CLASS =
        swv6.util.XMLParser =
        function (xml) {
            if (xml !== undefined) {
                this.parse(xml);
            }
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * Converts an xml string into an XMLDOM object, platform independently.
         * @param {String} xml The xml to parse.
         * @return {XMLDOM} .
         */
        parse: (function () {
            var fn;
            if (typeof window.DOMParser !== "undefined") {
                fn = function(xml) {
                    var dom = ( new window.DOMParser() ).parseFromString(xml, "text/xml");
                    return dom;
                };
            } else if ((typeof window.ActiveXObject !== "undefined") &&
                    new window.ActiveXObject("Microsoft.XMLDOM")) {
                fn = function(xml) {
                    dom = new window.ActiveXObject("Microsoft.XMLDOM");
                    dom.async = "false";
                    dom.loadXML(xml);
                    return dom;
                };
            } else {
                throw 'No XML parser found';
            }
            return fn;
        }())

    });

    
}());



(function () {
    'use strict';
    var buttons = 0;

    document.ev = new swv6.util.Publisher();
    document.ev.addEvent('onmousedown');
    document.ev.addEvent('onmouseup');
    document.ev.addEvent('onmousemove');
    document.ev.addEvent('onmouseover');
    document.ev.addEvent('onmouseout');
    document.ev.addEvent('ontouchstart');
    document.ev.addEvent('ontouchmove');
    document.ev.addEvent('ontouchend');

    document.onmousedown = function (evt) {
        buttons += Math.pow(2, evt.button);
        document.ev.publish('onmousedown', evt);
    };

    document.onmouseup = function (evt) {
        buttons -= Math.pow(2, evt.button);
        document.ev.publish('onmouseup', evt);
    };

    document.onmousemove = function (evt) {
        document.ev.publish('onmousemove', evt);
    };

    document.onmouseover = function (evt) {
        document.ev.publish('onmouseover', evt);
    };

    document.onmouseout = function (evt) {
        document.ev.publish('onmouseout', evt);
    };

    document.ontouchstart = function (evt) {
        document.ev.publish('ontouchstart', evt);
    };

//    document.ontouchmove = function (evt) {
//        document.ev.publish('ontouchmove', evt);
//    };

    document.ontouchend = function (evt) {
        document.ev.publish('ontouchend', evt);
    };

    document.addEventListener('touchmove', function (evt) {
        document.ev.publish('ontouchmove', evt);
    });
//    document.addEventListener('touchstart', function (evt) {
//        document.ev.publish('touchstart', evt);
//        swv6.burst(evt);
//        swv6.thwart(evt);
//    });

    document.getButtons = function () {
        return buttons;
    };

}());

(function () {
    /**
     * @class swv6.util.DragManager
     * @extends swv6.util.Publisher
     * A visual tree customized for the Product Structure application.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.util.DragManager =
        function (config) {
            CLASS.base.ctor.call(this, config);

            this.targets = [];

            this.started = false;
            this.startPoint = null;
            this.dragging = false;

            this.dragStartDistance = 10;
        };

    swv6.util.inherit(CLASS, BASE, {

        events: {
            ondragstart: true,
            ondragend: true,
            ondragcancel: true,
            ondrag: true,
            ondragenter: true,
            ondragleave: true,
            ondrop: true
        },

        start: function () {
            this.over = [];

            this.dragging = false;
            this.started = true;
            this.startPoint = null;

            document.ev.sub('onmousemove', this, this.handleMouseMove);
            document.ev.sub('onmouseup', this, this.handleMouseUp);

            document.ev.sub('ontouchmove', this, this.handleMouseMove);
            document.ev.sub('ontouchend', this, this.handleMouseUp);

        },

        end: function () {
            if (this.dragging) {
                this.dragging = false;
                this.publish('ondragend');
            }

            document.ev.unsub('onmousemove', this, this.handleMouseMove);
            document.ev.unsub('onmouseup', this, this.handleMouseUp);

            document.ev.unsub('ontouchmove', this, this.handleMouseMove);
            document.ev.unsub('ontouchend', this, this.handleMouseUp);
        },

        cancel: function () {
            if (this.dragging) {
                this.publish('ondragcancel');
            }

            this.end();
        },

        handleMouseMove: function (evt) {
            var targets,
                target,
                sets,
                i,
                d;

            if (this.started) {
                if (!this.dragging) {
                    if (this.startPoint) {
                        d = Math.sqrt(Math.pow(evt.clientX - this.startPoint.clientX, 2) + Math.pow(evt.clientY - this.startPoint.clientY, 2));

                        if (d >= this.dragStartDistance) {
                            this.dragging = true;
                            this.publish('ondragstart');
                        }
                    } else {
                        this.startPoint = evt;
                    }
                }
                if (this.dragging) {
                    if (evt.touches) {
                        evt = evt.touches[0];
                    }

                    targets = this.getTargetsUnder(evt);
        
                    sets = swv6.util.setTheory(targets, this.over, function (a, b) { return (a[0] === b[0]);});

                    this.over = targets;
        
                    // find which targets we've just entered.
                    for (i=0; i<sets.complementB.length; i++) {
                        target = sets.complementB[i];
                        this.publish('ondragenter', evt, target[0], target[1]);
                    }

                    // find which targets we've just left.
                    for (i=0; i<sets.complementA.length; i++) {
                        target = sets.complementA[i];
                        this.publish('ondragleave', evt, target[0], target[1]);
                    }
        
                    this.publish('ondrag', evt);
        
                }
            }

            return false;
        },

        handleMouseUp: function (evt) {
            var i, targets, metas;

            if (this.dragging) {
                targets = [];
                metas = [];

                // find which targets we've just left.
                for (i=0; i<this.over.length; i++) {
                    targets.push(this.over[i][0]);
                    metas.push(this.over[i][1]);
                }

                this.publish('ondrop', evt, targets, metas);
            }

            if (this.over.length === 0) {
                this.cancel();
            } else {
                this.end();
            }

            return false;
        },

        addTarget: function (target, meta) {
            this.targets.push([target, meta]);
        },

        removeTarget: function (target) {
            var i;

            for (i=0; i<this.targets.length; i++) {
                if (this.targets[i] === target) {
                    this.targets.splice(i, 1);
                    break;
                }
            }
        },

        clearTargets: function () {
            this.targets = [];
        },

        getTargetsUnder: function (evt) {
            var i,
                target,
                targets = [];

            for (i=0; i<this.targets.length; i++) {
                target = this.targets[i];

                if (this.hitTest(target[0], evt.clientX, evt.clientY)) {
                    targets.push(target);
                }
            }

            return targets;
        },

        hitTest: function (target, x, y) {
            var hit,
                b;

            if (target.hitTest) {
                hit = target.hitTest(x,y);
            } else {
                if (target.getBounds) {
                    b = target.getBounds();
                }
                else if (target instanceof SVGElement) {
                    b = this.getSVGBounds(target);
                }
                else if (target instanceof HTMLElement) {
                    b = this.getHTMLBounds(target);
                } else {
                    b = { x: 0, y:0, l:0, r:0, t:0, b:0 };
                }

                hit = ((x > b.l) && (x < b.r) && (y > b.t) && (y < b.b));
            }

            return hit;
        },

        getHTMLBounds: function (el) {
            var bb = el.getBoundingClientRect();
            return { x: bb.left, y:bb.top, l:bb.left, r:bb.right, t:bb.top, b:bb.bottom };
        },

        getSVGBounds: function (el) {
            var bb,
                ctm,
                svg,
                pt,
                b = {};

            try {
                svg = el.ownerSVGElement;
                pt = svg.createSVGPoint();
    
                bb = el.getBBox();
                ctm = el.getScreenCTM();
    
                pt.x = bb.x;
                pt.y = bb.y;
                pt = pt.matrixTransform(ctm);
                b.l = pt.x;
                b.t = pt.y;
    
                pt.x = bb.width;
                pt.y = bb.height;
                ctm.e = ctm.f = 0;
                pt = pt.matrixTransform(ctm);
                b.r = b.l + pt.x;
                b.b = b.t + pt.y;
            } catch (e) {
                // Occurs when element is hidden.  Is there a way to test for this?
                b = { x: 0, y:0, l:0, r:0, t:0, b:0 };
            }
            return b;
        }

    });

}());


/*
 * Some test code for swv6.util.inherit
 */
/*
    var Test = swv6.util.inherit({
    
        ctor: function () {
            this.name = 'name is test';
    
            Test.base.ctor.call(this);
        },
    
        hello: function () {
            alert('hello: ' + this.name);        
        }
    });
    
    var test = new Test();
    
    
    var Test2 = swv6.util.inherit(Test, {
    
        hello2: function () {
            alert('hello2: ' + this.name);        
        }
    });
        
    var Test3 = swv6.util.inherit(Test2, {
    
        ctor: function (name) {
            Test3.base.ctor.apply(this);
            this.name = name;
        },
    });
    var test3 = new Test3('from test3');
        
    test3.hello(); // alerts 'hello: name from test3'
    test3.hello2(); // alerts 'hello2: name from test3'
*/

/*
 * Some test code for swv6.util.Publisher
 */
/*
    var Subscriber = new swv6.util.inherit({
        ctor: function (name) {
            this.name = name;
            Subscriber.base.ctor.apply(this, arguments);
        },
        itemMoved: function (data) {
            alert(this.name + ' caught moved: ' + data);
        }
    });
    var Publisher = new swv6.util.inherit(swv6.util.Publisher, {
        ctor: function () {
            Publisher.base.ctor.apply(this, arguments);
            this.addEvent('move');
        }
    });
    
    var s = new Subscriber('s');
    var s2 = new Subscriber('s2');
    var p = new Publisher();
    
    p.subscribe('move', s, s.itemMoved);
    p.subscribe('move', s2, s2.itemMoved);
    
    p.publish('move', '10,25'); // 2 alerts, one for each subscriber.
    
    p.unsubscribe('move', s, s.itemMoved);
    
    p.publish('move', '20,50'); // only 1 alert now.
*/


