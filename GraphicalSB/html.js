/*jslint plusplus:true*/

var swv6 = swv6 || {};
swv6.html = swv6.html || {};

(function () {
    /**
     * @class swv6.html.Element
     * @extends swv6.util.Publisher
     * The base object for all HTML elements. 
     */
    /**
     * @cfg {String} xml
     * *** incomplete ***
     * An xml string fully defining this element, along with any children.
     */
    /**
     * @cfg {swv6.html.Element} parent
     * An html element to which this node will be added.
     */
    /**
     * @cfg {Object} attr
     * A collection of attributes to be applied to this element.
     */
    /**
     * @cfg {Array} children
     * An array of children to be added to this element.  Each array member may be either an swv6.html.Element,
     * or a valid config object for a new swv6.html.Element.
     */
    /**
     * @cfg {String} dom
     * *** incomplete ***
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher,
        LASTDEFID = 0;

    CLASS =
        swv6.html.Element =
        function (config) {

            CLASS.base.ctor.call(this, config);

            this.children = [];
            
            this.load(config);
        };

    swv6.util.inherit(CLASS, BASE, {

        children: undefined,

        /**
         * @cfg {String} tag
         * The tag name for this html element.
         */
        tag: '',
        /**
         * @cfg {String} cls
         * A class, or classes, to be applied to this element.
         */
        cls: '',
        /**
         * @cfg {swv6.html.Element} parent
         * An html element to which this node will be added.
         */
        parent: undefined,

        /**
         * @event onclick
         * Triggered when element is clicked.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ondblclick
         * Triggered when element is double-clicked.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmousedown
         * Triggered when the mouse is pressed down over the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseup
         * Triggered when the mouse is raised over the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmousemove
         * Triggered when the mouse is moved over the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseenter
         * Triggered when the mouse enters the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseleave
         * Triggered when the mouse exits the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseover
         * Triggered when the mouse enters the element or any of its children.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseout
         * Triggered when the mouse exits the element or any of its children.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmousewheel
         * Triggered when the mouse wheel is scrolled is moved over the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event oncontextmenu
         * Triggered when the context mouse button (typically RMB) is clicked over the element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onfocus
         * Triggered when this element gets the focus.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ontouchstart
         * Triggered when the user touches this element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ontouchmove
         * Triggered when the a user changes the touched location.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ontouchend
         * Triggered when the a user removes a touch from this element.
         * @param {swv6.html.Element} this
         * @param {Object} event The browser event.
         */
        events: {
            onclick: true,
            ondblclick: true,
            onmousedown: true,
            onmouseup: true,
            onmousemove: true,
            onmouseenter: true,
            onmouseleave: true,
            onmouseover: true,
            onmouseout: true,
            onmousewheel: true,
            onDOMMouseScroll: true,
            oncontextmenu: true,
            onfocus: true,
            ontouchstart: true,
            ontouchmove: true,
            ontouchend: true,
            ondrop: true,
            ondragover: true,
            ondragenter: true,
            ondragleave: true
        },

        // private
        load: function (config) {
            var xml, root,
                added = false;

            //if (config.xml) {
                // Only supports JSON for the moment
                // root = this.parser.parse(config.xml);
           // } 
            if (root || config.dom) {
                // Only supports JSON for the moment
                // this.loadFromXMLDom(root || config.dom);                
            } else if (config.tag) {
                this.loadFromJSON(config);
            }
            
            if (config.parent) {
                if (config.parent instanceof swv6.html.Element) {
                    config.parent.addChild(this);
                } else {
                    config.parent.appendChild(this.el);
                }
            }
        },

        // private
        loadFromJSON: function (config) {
            var tag = config.tag || 'div',
                attrs = config.attr || [],
                styles = config.style || [],
                children = config.children || [],
                events = config.events || [],
                child,
                attr,
                event,
                style,
                i,
                s,
                ns;

            this.el = document.createElement(tag);
            this.tag = tag;

            if (config.parent) {
                if (config.parent instanceof swv6.html.Element) {
                    config.parent.addChild(this);
                } else {
                    config.parent.appendChild(this.el);
                }
            }

            for (attr in attrs) {
                if (attrs.hasOwnProperty(attr)) {
                    this.setAttribute(attr, attrs[attr]);
                }
            }

            for (style in styles) {
                if (styles.hasOwnProperty(style)) {
                    this.el.style[style] = styles[style];
                }
            }

            for (i=0; i<children.length; i++) {
                child = children[i];                
                if (!(child instanceof swv6.html.Element)) {
                    child = new swv6.html.Element(child);
                }
                this.addChild(child);
            }

            for (event in events) {
                if (events.hasOwnProperty(event)) {
                    this.el.addEventListener(event, events[event], false);
                }
            }

            if (config.cls) {
                this.addClass(config.cls);
            }

            if (config.innerHTML) {
                this.el.innerHTML = config.innerHTML;
            }

        },

        /**
         * Gets an attribute on this element.
         * @param {String} name The name of the attribute.
         * @return {String} The value of the attribute.
         */
        getAttribute: function (name) {
            this.el.getAttribute(name);
        },

        /**
         * Sets an attribute on this element.
         * @param {String} name The name of the attribute.
         * @param {String} value The value of the attribute.
         */
        setAttribute: function (name, value) {
            this.el.setAttribute(name, value);
        },

        /**
         * Sets a *namespaced* attribute on this element.
         * @param {String} name The name of the attribute.
         * @param {String} value The value of the attribute.
         */
        setAttributeNS: function (name, value) {
            var prefix,
                ns = null,
                index;

            index = name.indexOf(':');
            if (index !== -1) {
                prefix = name.substr(0, index);
                name = name.substr(index+1);
            }

            ns = (!prefix) ? null : this.ns[prefix];

            this.el.setAttributeNS(ns, name, value);
        },

        /**
         * Removes an attribute from this element.
         * @param {String} name The name of the attribute.
         */
        removeAttribute: function (name) {
            this.el.removeAttribute(name);
        },

        /**
         * Removes a *namespaced* attribute from this element.
         * @param {String} name The name of the attribute.
         */
        removeAttributeNS: function (name, value) {
            var prefix,
                ns = null,
                index;

            index = name.indexOf(':');
            if (index !== -1) {
                prefix = name.substr(0, index);
                name = name.substr(index+1);
            }

            ns = (!prefix) ? null : this.ns[prefix];

            this.el.removeAttribute(name);
        },

        /**
         * Adds a child to this element.
         * @param {String} child The child to add.
         * @return {swv6.html.Element} The added child element.  null if addition failed.
         */
        addChild: function (child) {
            this.children.push(child);
            this.el.appendChild(child.el);
            child.parent = this;
            return child;
        },

        /**
         * Inserts a child to this element before another specified element.
         * @param {String} child The child to add.
         * @param {swv6.svg.Element} reference The child will be added before this node .
         * @return {swv6.svg.Element} The added child element.  null if addition failed.
         */
        insertChild: function (child, reference) {
            var i = this.children.indexOf(reference);            
            this.children.splice(i, 0, child);
            this.el.insertBefore(child.el, reference.el);
            child.parent = this;
            return child;
        },

        /**
         * Removes a child from this element.
         * @param {String} child The child to remove.
         * @return {Boolean} True if removed, false otherwise.
         */
        removeChild: function (child) {
            var i,
                cn = this.children,
                removed = false;

            for (i=0; i<cn.length; i++) {
                if (cn[i] === child) {
                    cn.splice(i, 1); 
                    this.el.removeChild(child.el);
                    removed = true;
                    break;
                }
            }

            return removed;
        },

        // private
        // overrides swv6.util.Publisher.onFirstSubscribe
        onFirstSubscribe: function (event) {
            var that = this;
            // attach self to the html element's event handler.
            if (event.substr(2,3) === 'DOM') {
                this.el.addEventListener(
                    event.substr(2), 
                    function (evt) {
                        that.publish(event, that, evt);
                    }
                );
            } else if (event === 'onmouseleave') {
                // mouse leave event isn't supported across all browsers,
                // so this will simulate it.
                this.subscribe('onmouseout', this, this.mouseLeaveFn);
            } else {
                this.el[event] = function (evt) {
                    that.publish(event, that, evt);
                };
            }
        }, 

        /**
         * Adds a class to this element.
         * @param {String} cls The class name to add.
         */
        addClass: function (cls) {
            this.cls = swv6.util.addClass(this.cls, cls);
            this.el.setAttribute('class', this.cls);
        },

        /**
         * Removes a class from this element.
         * @param {String} cls The class name to remove.
         */
        removeClass: function (cls) {
            this.cls = swv6.util.removeClass(this.cls, cls);
            this.el.setAttribute('class', this.cls);
        },

        /**
         * Tests if this element has a specific class.
         * @param {String} cls The class name to test for.
         */
        hasClass: function (cls) {
            return swv6.util.hasClass(this.cls, cls);
        },

        /**
         * Gets the bounding box for this element.
         * @return {Object} This element's bounding box (x, y, width, height).
         */
        getBBox: function () {
            return {
                x: this.el.offsetLeft,
                y: this.el.offsetTop,
                width: this.el.offsetWidth,
                height: this.el.offsetHeight
            };
        },

        setSize: function (width, height) {
            this.el.style.width = width + 'px';
            this.el.style.height = height + 'px';
        },

        setTransform: function (a, b, c, d, e, f) {
            var t = 'matrix(' + a + ',' + b + ',' + c + ',' + d + ',' + e + ',' + f + ')';
            this.transform = {
                a: a,
                b: b,
                c: c,
                d: d,
                e: e,
                f: f
            };

            this.el.style.transform = t;
            if (this.el.style.webkitTransform !== undefined) {
                this.el.style.webkitTransform = t;
            }
            if (this.el.style.msTransform !== undefined) {
                this.el.style.msTransform = t;
            }

        },

        getTransform: function () {
            return this.transform;
        },

        getAppliedStyle: function (prop)
        {
            if (this.el.currentStyle) {
                CLASS.prototype.getAppliedStyle = function (prop) {
                    return this.el.currentStyle[prop];
                };
            } else if (window.getComputedStyle) {
                CLASS.prototype.getAppliedStyle = function (prop) {
                    return document.defaultView.getComputedStyle(this.el,null).getPropertyValue(prop);
                };
            }
            return this.getAppliedStyle(prop);
        },
        
        // private
        // allows mouse leave events for all browsers
        mouseLeaveFn: function (element, evt) {
            var el = evt.toElement,
                leave = true;

            while (leave && el && (el !== document.body)) {
                if (el === this) {
                    leave = false;
                }
                el = el.parentNode;
            }

            if (leave) {
                this.publish('onmouseleave', this, evt);
            }
        }

    });

}());


(function () {
    /**
     * @class swv6.html.Div
     * @extends swv6.html.Element
     * An object representation of the HTML 'div' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.html.Element;

    CLASS =
        swv6.html.Div =
        function (config) {
            config.tag = 'div';
            CLASS.base.ctor.call(this, config);
        };

    swv6.util.inherit(CLASS, BASE, {
    });

}());
