/*jslint plusplus:true*/

var swv6 = swv6 || {};
swv6.svg = swv6.svg || {};

(function () {
    /**
     * @class swv6.svg.SVGParser
     * @extends Object
     * @private
     * An internal tool for generating svg elements.
     */
    'use strict';
    var CLASS,
        BASE = Object;

    CLASS =
        swv6.svg.SVGParser =
        function (ns) {
            this.ns = ns || {};
        };

    swv6.util.inherit(CLASS, BASE, {

        svg: undefined,

        parse: function (xml) {
            var isSVG = (xml.substr(0, 4) === '<svg'),
                div,
                svg,
                el,
                ns,
                s;
            
            div = document.createElement("div");

            if (!isSVG) {
                // wrap xml in svg element.
                s = '<svg ';
                for (ns in this.ns) {
                    if (this.ns.hasOwnProperty(ns)) {
                        s += ns + '="' + this.ns[ns] + '" ';
                    }
                }
                s += '>';
                s += xml;
                s += '</svg>';

                xml = s;
            }

            div.innerHTML = xml;

            svg = div.children[0];

            if (isSVG) {
                el = svg;
            } else {
                el = svg.childNodes[0];
            }

            return el;
        }

    });

}());

(function () {
    /**
     * @class swv6.svg.Element
     * @extends swv6.util.Publisher
     * The base object for all SVG elements. 
     */
    /**
     * @cfg {String} xml
     * *** incomplete ***
     * An xml string fully defining this element, along with any children.
     */
    /**
     * @cfg {swv6.svg.Element} parent
     * An svg element to which this node will be added.
     */
    /**
     * @cfg {Object} attr
     * A collection of attributes to be applied to this element.
     */
    /**
     * @cfg {Array} children
     * An array of children to be added to this element.  Each array member may be either an swv6.svg.Element,
     * or a valid config object for a new swv6.svg.Element.
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
        swv6.svg.Element =
        function (config) {
            
            CLASS.base.ctor.call(this, config);

            this.children = [];
            
            this.load(config);

        };

    swv6.util.inherit(CLASS, BASE, {

        children: undefined,

        ns: {
            '': 'http://www.w3.org/2000/svg',
            xlink: 'http://www.w3.org/1999/xlink'
        },
        
        /**
         * @event onclick
         * Triggered when element is clicked.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ondblclick
         * Triggered when element is double-clicked.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmousedown
         * Triggered when the mouse is pressed down over the element.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseup
         * Triggered when the mouse is raised over the element.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmousemove
         * Triggered when the mouse is moved over the element.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseover
         * Triggered when the mouse enters the element or any of its children.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event onmouseout
         * Triggered when the mouse exits the element or any of its children.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event oncontextmenu
         * Triggered when the context mouse button (typically RMB) is clicked over the element.
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        /**
         * @event ontouchstart
         * Triggered when the a user touches this element
         * @param {swv6.svg.Element} this
         * @param {Object} event The browser event.
         */
        events: {
            onclick: true,
            ondblclick: true,
            onmousedown: true,
            onmouseup: true,
            onmousemove: true,
            onmouseover: true,
            onmouseout: true,
            oncontextmenu: true,
            ontouchstart: true
        },

        /**
         * @cfg {String} tag
         * The tag name for this svg element.
         */
        tag: '',
        /**
         * @cfg {String} cls
         * A class, or classes, to be applied to this element.
         */
        cls: '',
        /**
         * @cfg {swv6.svg.Element} parent
         * An svg element to which this node will be added.
         */
        parent: undefined,
        /**
         * @cfg {Number} x
         * The x position for this element.
         */
        x: 0,
        /**
         * @cfg {Number} y
         * The y position for this element.
         */
        y: 0,
        /**
         * @cfg {Number} width
         * The width for this element.
         */
        width: 0,
        /**
         * @cfg {Number} height
         * The height for this element.
         */
        height: 0,
        /**
         * @cfg {String} title
         * A tooltip value
         */
        title: '',
        /**
         * @cfg {String} text
         * The value to apply as the textContent for an svg element.
         */
        text: '',

        getParser: function () {
            var parser = new swv6.svg.SVGParser(CLASS.prototype.ns);

            CLASS.prototype.getParser = function () {
                return parser;
            };

            return parser;
        },

        // private
        load: function (config) {
            var xml, root,
                added = false;

            if (config.xml) {
                root = this.getParser().parse(config.xml);
            } 
            if (root || config.dom) {
                this.loadFromXMLDom(root || config.dom);
            } else if (config.tag) {
                this.loadFromJSON(config);
            }
            
            if (config.parent) {
                config.parent.addChild(this);
            }
        },

        // private
        loadFromXMLDom: function (dom) {
            var tag = dom.tagName,
                attrs = dom.attributes,
                children = dom.childNodes,
                attr,
                child,
                i;

            this.el = document.createElementNS(this.ns[''], tag);
            for (i=0; i<attrs.length; i++) {
                attr = attrs[i];
                if ((attr.name !== 'xmlns') && (attr.name !== 'xmlns:xlink')) {
                    this.setAttribute(attr.name, attr.value);
                }
            }


            for (i=0; i<children.length; i++) {
                child = children[i];
                if ( child.nodeName !== '#text') {
                    child = new swv6.svg.Element({
                        dom: children[i]
                    });
                    this.addChild(child);
                } else {
                    this.el.appendChild(child);
                    i--; // changing parent affects children array.
                }
            }
            
            // TODO: initialize element properties, such as x and y positions, based on finalized element attributes.
        },

        // private
        loadFromJSON: function (config) {
            var tag = config.tag,
                attrs = config.attr,
                children = config.children,
                child,
                attr,
                i;

            this.el = document.createElementNS('http://www.w3.org/2000/svg', tag);

            if (attrs) {
                for (attr in attrs) {
                    if (attrs.hasOwnProperty(attr)) {
                        if (attr === 'class') {
                            this.addClass(attrs[attr]);
                        } else {
                            this.setAttributeNS(attr, attrs[attr]);
                        }
                    }
                }
            }

            if (children) {
                for (i=0; i<children.length; i++) {
                    child = children[i];                
                    if (!(child instanceof swv6.svg.Element)) {
                        child = new swv6.svg.Element(child);
                    }
                    this.addChild(child);
                }
            }

            this.tag = tag;
            if (config.cls) {
                this.addClass(config.cls);
            }
            if (config.title) {
                this.setTitle(config.title);
            }
            if (config.text) {
                this.setText(config.text);
            }
            if (config.x) {
                this.setX(config.x);
            }
            if (config.y) {
                this.setY(config.y);
            }
            if (config.width) {
                this.setWidth(config.width);
            }
            if (config.height) {
                this.setHeight(config.height);
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
         * Adds a child to this element.
         * @param {String} child The child to add.
         * @return {swv6.svg.Element} The added child element.  null if addition failed.
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
            var that = this,
                name = event.substr(2); // cut off the leading 'on'

            // attach self to the svg element's event handler.
            this.el.addEventListener(
                name, 
                function (evt) {
                    that.publish(event, that, evt);
                }
            );
        }, 

        /**
         * Adds a class to this element.
         * @param {String} cls The class name to add.
         */
        addClass: function (cls) {
            // can't use this.el.classList, since this doesn't work in IE (even with polyfill)
            this.cls = swv6.util.addClass(this.cls, cls);
            this.el.setAttribute('class', this.cls);
        },

        /**
         * Removes a class from this element.
         * @param {String} cls The class name to remove.
         */
        removeClass: function (cls) {
            // can't use this.el.classList, since this doesn't work in IE (even with polyfill)
            this.cls = swv6.util.removeClass(this.cls, cls);
            this.el.setAttribute('class', this.cls);
        },

        /**
         * Tests if this element has a specific class.
         * @param {String} cls The class name to test for.
         */
        hasClass: function (cls) {
            // can't use this.el.classList, since this doesn't work in IE (even with polyfill)
            return swv6.util.hasClass(this.cls, cls);
        },

        /**
         * Retrieves this element's defs element.
         * @return {String} This element's defs element.
         */
        getDefs: function () {
            if (!this.defs) {
                this.defs = this.addChild( new swv6.svg.Defs({}) );
            }
            return this.defs;
        },

        /**
         * Sets a tooltip for this element.
         * @param {String} title The tooltip text.
         */
        setTitle: function (title) {
            if (!this.titleEl) {
                // SVG tooltips are implemented as child 'title' elements.
                this.titleEl = this.addChild(
                    new swv6.svg.Element({
                        tag: 'title',
                        text: title
                    })
                );
            } else {
                this.titleEl.el.textContent = title;
            }
        },

        /**
         * Sets the textContent for this element.
         * @param {String} text The textContent for this element.
         */
        setText: function (text) {
            this.text = text;
            this.el.textContent = text;
        },

        /**
         * Sets the id of this element.
         * @param {String} id The id of this element.
         */
        setID: function (id) {
            this.id = id;
            this.setAttribute('id', id);
        },

        /**
         * Retrieves the id of this element.
         * @return {String} This element's id.
         */
        getID: function () {
            return this.id;
        },

        /**
         * Gets the x position of this element.
         * @return {Number} This element's x position.
         */
        getX: function () {
            return this.x;
        },

        /**
         * Gets the y position of this element.
         * @return {Number} This element's y position.
         */
        getY: function () {
            return this.y;
        },

        /**
         * Sets the x position of this element.
         * @param {Number} x This element's x position.
         */
        setX: function (x) {
            if (this.x !== x) {
                this.x = x;
                this.setAttribute('x', x);
            }
        },

        /**
         * Sets the y position of this element.
         * @param {Number} y This element's y position.
         */
        setY: function (y) {
            if (this.y !== y) {
                this.y = y;
                this.setAttribute('y', y);
            }
        },

        /**
         * Sets the y position of this element.
         * @param {Number} x This element's x position.
         * @param {Number} y This element's y position.
         */
        setPosition: function (x, y) {
            this.setX(x);
            this.setY(y);
        },

        /**
         * Sets the width of this element.
         * @param {Number} width This element's width.
         */
        setWidth: function (width) {
            if (this.width !== width) {
                this.width = width;
                this.setAttribute('width', width);
            }
        },

        /**
         * Sets the height of this element.
         * @param {Number} height This element's height.
         */
        setHeight: function (height) {
            if (this.height !== height) {
                this.height = height;
                this.setAttribute('height', height);
            }
        },
        
        /**
         * Sets the width and height of this element.
         * @param {Number} width This element's width.
         * @param {Number} height This element's height.
         */
        setSize: function (width, height) {
            this.setWidth(width);
            this.setHeight(height);
        },

        /**
         * Gets the bounding box for this element.
         * @return {Object} This element's bounding box (x, y, width, height).
         */
        getBBox: function () {
            var bbox;

            try {
                bbox = this.el.getBBox();
            } catch (e) {
                // Occurs when element is hidden. Is there a way to test for this?
                bbox = { x: 0, y:0, width: 0, height: 0 }; 
            }

            return bbox;
        }

    });

}());

(function () {
    /**
     * @class swv6.svg.SVG
     * @extends swv6.svg.Element
     * An object representation of the SVG 'svg' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.SVG =
        function (config) {
            var a;
            
            config = config || {};
            config.tag = 'svg';

            a = config.attr = config.attr || {};
            
            a.width = a.width || 0;
            a.height = a.height || 0;
            a.preserveAspectRatio = a.preserveAspectRatio || 'xMidYMid';
            a.viewBox = '0 0 ' + a.width + ' ' + a.height;

            CLASS.base.ctor.call(this, config);            
        };

    swv6.util.inherit(CLASS, BASE, {
        setSize: function (width, height) {
            this.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
            CLASS.base.setSize.call(this, width, height);
        }
    });

}());


(function () {
    /**
     * @class swv6.svg.G
     * @extends swv6.svg.Element
     * An object representation of the SVG 'g' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.G =
        function (config) {
            config.tag = 'g';
            CLASS.base.ctor.call(this, config);
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @inheritdoc
         */
        setX: function (x) {
            this.setPosition(x, this.y);
        },

        /**
         * @inheritdoc
         */
        setY: function (y) {
            this.setPosition(this.x, y);            
        },

        /**
         * @inheritdoc
         */
        setPosition: function (x, y) {
            if ((this.x !== x) || (this.y !== y)) {
                this.x = x;
                this.y = y;
                this.setAttribute('transform', 'translate(' + x + ',' + y + ')');
            }
        }
    });

}());

(function () {
    /**
     * @class swv6.svg.Line
     * @extends swv6.svg.Element
     * An object representation of the SVG 'line' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.Line =
        function (config) {
            config = config || {};

            config.tag = 'line';

            CLASS.base.ctor.call(this, config);

            if (config.x1) {
                this.setX1(config.x1);
            }
            if (config.x2) {
                this.setX2(config.x2);
            }
            if (config.y1) {
                this.setY1(config.y1);
            }
            if (config.y2) {
                this.setY2(config.y2);
            }

        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @cfg {Number} x1
         * The x-axis coordinate of the start of the line.
         */
        x1: 0,
        /**
         * @cfg {Number} x2
         * The x-axis coordinate of the end of the line.
         */
        x2: 0,
        /**
         * @cfg {Number} y1
         * The y-axis coordinate of the start of the line.
         */
        y1: 0,
        /**
         * @cfg {Number} y2
         * The y-axis coordinate of the end of the line.
         */
        y2: 0,

        /**
         * Sets the x-axis coordinate of the start of this line.
         * @param {Number} x The x-axis coordinate.
         */
        setX1: function (x) {
            this.setAttribute('x1', x);
        },

        /**
         * Sets the x-axis coordinate of the end of this line.
         * @param {Number} x The x-axis coordinate.
         */
        setX2: function (x) {
            this.setAttribute('x2', x);
        },

        /**
         * Sets the y-axis coordinate of the start of this line.
         * @param {Number} y The y-axis coordinate.
         */
        setY1: function (y) {
            this.setAttribute('y1', y);
        },

        /**
         * Sets the y-axis coordinate of the end of this line.
         * @param {Number} y The y-axis coordinate.
         */
        setY2: function (y) {
            this.setAttribute('y2', y);
        }
    });

}());

(function () {
    /**
     * @class swv6.svg.Rect
     * @extends swv6.svg.Element
     * An object representation of the SVG 'rect' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.Rect =
        function (config) {
            config = config || {};
            
            config.tag = 'rect';
                        
            CLASS.base.ctor.call(this, config);
            
            if (config.rx) {
                this.setRX(config.rx);
            }
            if (config.ry) {
                this.setRY(config.ry);
            }

//            this.setAttribute('shape-rendering', 'optimizeSpeed');

        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @cfg {String} rx
         * The x radius for this Rect.
         */
        rx: 0,
        /**
         * @cfg {String} ry
         * The y radius for this Rect.
         */
        ry: 0,
        
        /**
         * @inheritdoc
         */
        setX: function (x) {
            this.update(x, this.y, this.width, this.height);
        },

        /**
         * @inheritdoc
         */
        setY: function (y) {
            this.update(this.x, y, this.width, this.height);
        },

        /**
         * @inheritdoc
         */
        setWidth: function (width) {
            this.update(this.x, this.y, width, this.height);
        },

        /**
         * @inheritdoc
         */
        setHeight: function (height) {
            this.update(this.x, this.y, this.width, height);
        },

        /**
         * @inheritdoc
         */
        setPosition: function (x, y) {
            this.update(x, y, this.width, this.height);
        },

        /**
         * @inheritdoc
         */
        setSize: function (width, height) {
            this.update(this.x, this.y, width, height);
        },

        // private
        update: function (x, y, width, height) {
            x = (width >= 0) ? x : x + width;
            y = (height >= 0) ? y : y + height;
            width = (width >= 0) ? width : -width;
            height = (height >= 0) ? height : -height;

            CLASS.base.setX.call(this, x);
            CLASS.base.setY.call(this, y);
            CLASS.base.setWidth.call(this, width);
            CLASS.base.setHeight.call(this, height);
        },
        
        /**
         * Sets the x radius for this Rect.
         * @param {Number} rx This Rect's x radius.
         */
        setRX: function (rx) {
            this.rx = rx;
            this.setAttribute('rx', rx);
        },

        /**
         * Sets the y radius for this Rect.
         * @param {Number} ry This Rect's y radius.
         */
        setRY: function (ry) {
            this.ry = ry;
            this.setAttribute('ry', ry);
        }
    });

}());


(function () {
    /**
     * @class swv6.svg.Text
     * @extends swv6.svg.Element
     * An object representation of the SVG 'text' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.Text =
        function (config) {
            config.tag = 'text';
            this.text = config.text;

            CLASS.base.ctor.call(this, config);

//            this.setAttribute('text-rendering', 'optimizeSpeed');
            
        };

    swv6.util.inherit(CLASS, BASE, {
    });

}());


(function () {
    /**
     * @class swv6.svg.Image
     * @extends swv6.svg.Element
     * An object representation of the SVG 'image' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.Image =
        function (config) {
            config.tag = 'image';

            CLASS.base.ctor.call(this, config);

            if (config.href) {
                this.setHRef(config.href);
            }

//            this.setAttribute('image-rendering', 'optimizeSpeed');

        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @cfg {String} href
         * The href, or image source, for this image element.
         */
        href: '',

        /**
         * Sets the href for this element.
         * @param {String} href The href for this element.
         */
        getHRef: function (href) {
            return this.href;
        },

        /**
         * Retrieves the href for this element.
         * @return {String} The href for this element.
         */
        setHRef: function (href) {
            this.href = href;
            this.setAttributeNS('xlink:href', this.href);
        }
    });

}());


(function () {
    /**
     * @class swv6.svg.Path
     * @extends swv6.svg.Element
     * An object representation of the SVG 'path' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element;

    CLASS =
        swv6.svg.Path =
        function (config) {
            config = config ||{};
            config.tag = 'path';
            CLASS.base.ctor.call(this, config);
        };

    swv6.util.inherit(CLASS, BASE, {
    });

}());


(function () {
    /**
     * @class swv6.svg.Defs
     * @extends swv6.svg.Element
     * An object representation of the SVG 'defs' element
     */
    'use strict';
    var CLASS,
        BASE = swv6.svg.Element,
        LASTDEFID = 0;

    CLASS =
        swv6.svg.Defs =
        function (config) {
            config = config ||{};
            config.tag = 'defs';
            CLASS.base.ctor.call(this, config);
        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @inheritdoc
         */
        addChild: function (child) {
            var item = CLASS.base.addChild.call(this, child);
            item.setID('def' + (LASTDEFID++)); // give each def a unique id.
            return item;
        }
    });

}());
