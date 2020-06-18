
var swv6 = swv6 || {};

(function () {
    /**
     * @class swv6.ui.ContextMenu
     * @extends swv6.util.Publisher
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.ContextMenu =
        function (parent, cls) {
            CLASS.base.ctor.apply(this);
            this.initialize(parent, cls);
        };

    swv6.util.inherit(CLASS, BASE, {
        
        mouseInside: false,
        hooked: false,

        initialize: function (parent, cls) {
            
            // create this control's html elements.
            this.el = document.createElement('div');
            this.bg = document.createElement('div');
            this.list = document.createElement('ul');

            this.el.appendChild(this.bg);
            this.el.appendChild(this.list);

            if (cls) {
                this.el.setAttribute('class', cls);
            }

            this.el.setAttribute('style', 'top: 0; left: 0; visibility: hidden; position: absolute');

            // create the 9-image background
            this.bg.setAttribute('class', 'pop-up-bg');
            this.bg.innerHTML =
                '<table cellspacing="0">' +
                '    <tbody>' +
                '        <tr><td class="tl"></td><td class="tc"></td><td class="tr"></td></tr>' +
                '        <tr><td class="ml"></td><td class="mc"></td><td class="mr"></td></tr>' +
                '        <tr><td class="bl"></td><td class="bc"></td><td class="br"></td></tr>' +
                '    </tbody>' +
                '</table>';

            this.list.setAttribute('class', 'context-menu');

            this.el.onmousedown = swv6.util.delegate(this, this.onMouseDown);

            // add the menu element to a parent, if one has been provided.
            if (parent) {
                parent.appendChild(this.el);
            }

            this.addEvent('clicked');
            this.addEvent('hidden');

        },

        addTextItem: function (text, cls, fn, options) {
            var item = new swv6.ui.ContextMenuTextItem(text, cls, fn, options);

            this.list.appendChild(item.el);
            item.sub('clicked', this, this.onclick);

            return item;
        },

        addSeparator: function (text, cls, fn) {
            var item = new swv6.ui.ContextMenuSeparator();

            this.list.appendChild(item.el);

            return item;
        },

        show: function (x, y, container) {
            var scrollTop, scrollLeft,
                cmx, cmy,
                cmxMax, cmyMax;
            
            if (container) {
                scrollTop = container.scrollTop;
                scrollLeft = container.scrollLeft;
            } else {
                scrollTop = document.body.scrollTop || document.documentElement.scrollTop;
                scrollLeft = document.body.scrollLeft || document.documentElement.scrollLeft;
            }
            
            x = x || 0;
            y = y || 0;
            
            cmx = x + scrollLeft;
            cmy = y + scrollTop;
            cmxMax = window.innerWidth - this.el.offsetWidth - 5;
            cmyMax = window.innerHeight - this.el.offsetHeight - 5;

            if(cmx > cmxMax) {
                cmx = cmxMax;
            }
            if(cmy > cmyMax){
                cmy = cmyMax;
            }
            this.el.style.left = cmx + 'px';
            this.el.style.top = cmy + 'px';            
                       
            this.el.style.visibility = '';

            if (!this.hooked) {
                this.hooked = true;
                document.ev.sub('onmousedown', this, this.onDocumentMouseDown);
            }
        },

        hide: function () {
            this.el.style.visibility = 'hidden';
            this.publish('hidden', this);

            if (this.hooked) {
                this.hooked = false;
                document.ev.unsub('onmousedown', this, this.onDocumentMouseDown);
            }
        },
        
        onclick: function (item) {
            this.publish('clicked', this, item);
            this.hide();
        },
        
        onDocumentMouseDown: function (evt) {
            // hide the menu for any clicks outside of the menu.
            if (!this.mouseInside) {
                this.hide();
            }
            this.mouseInside = false;
        },
        
        onMouseDown: function (evt) {
            // prevent document mouse down handler from hiding the menu when the event
            //     originates from within the menu.
            // (Can't simply thwart event, since this affects button counting functionality.)
            this.mouseInside = true;
        },
        
        destroy: function () {
            this.el.parentNode.removeChild(this.el);
        }
        
    });

}());


(function () {
    /**
     * @class swv6.ui.ContextMenuItem
     * @extends swv6.util.Publisher
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.ContextMenuItem =
        function (cls) {
            CLASS.base.ctor.apply(this, arguments);

            this.el = document.createElement('li');
            this.el.setAttribute('class', 'context-menu-item ' + cls);
        };

    swv6.util.inherit(CLASS, BASE, {
        show: function () {
            this.el.style.display = '';
        },
        
        hide: function () {
            this.el.style.display = 'none';
        }
    });

}());

(function () {
    /**
     * @class swv6.ui.ContextMenuTextItem
     * @extends swv6.ui.ContextMenuItem
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.ContextMenuItem;

    CLASS =
        swv6.ui.ContextMenuTextItem =
        function (text, cls, fn, options) {
            CLASS.base.ctor.call(this, cls);
            this.initialize(text, cls, fn, options);
        };

    swv6.util.inherit(CLASS, BASE, {
        
        initialize: function (text, cls, fn, options) {
            this.text = text;
            this.cls = cls;
            this.fn = fn;
            
            this.button = document.createElement('button');
            this.icon = document.createElement('div');
            this.content = document.createElement('div');

            this.el.appendChild(this.button);
            this.button.appendChild(this.icon);
            this.button.appendChild(this.content);

            this.icon.setAttribute('class', 'icon');
            this.content.setAttribute('class', 'content');
            this.content.innerHTML = text;
			// options  - such as data localize
			if(options){				
				this.content.setAttribute(options.name, options.value);
			}
            this.button.onclick = swv6.util.delegate(this, this.onclick);

            this.addEvent('clicked');              
        },
        
        onclick: function () {
            if (this.fn) {
                this.fn.apply();
            }
            this.publish('clicked', this);
        }
                       
    });

}());


(function () {
    /**
     * @class swv6.ui.ContextMenuSeparator
     * @extends swv6.ui.ContextMenuItem
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.ContextMenuItem;

    CLASS =
        swv6.ui.ContextMenuSeparator =
        function () {
            CLASS.base.ctor.call(this, 'separator');
        };

    swv6.util.inherit(CLASS, BASE, {
    });

}());

