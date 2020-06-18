// Context Menu Element
/* Description:
 *
 *    The purpose of the context menu element is to provide a menu
 *    element with multiple options that can be clicked on in order
 *    to execute a variety of tasks.
 *
 *
 */

(function(GLOBAL, template) {
    if (typeof GLOBAL.DS.RAComponents.contextitem !== 'undefined') {
        return;
    }

    contextItemPrototype = {
        is: 'ra-contextmenuitem'
    };

    contextItemPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        var that = this;

        this.querySelector(
            '.expansionButton'
        ).addEventListener('click', function(e) {
            if (that.expanded === true) {
                that._onCollapse();
                e.preventDefault();
                e.stopPropagation();
            } else {
                that._onExpand();
                e.preventDefault();
                e.stopPropagation();
            }
        });

        this.expandCallback = function() {};
        this.collapseCallback = function() {};
        this.clickCallback = function() {};

        this.addEventListener('click', function(e) {
            that.clickCallback(e);
        });

        this.expanded = false;

        this.data = {};
    };

    contextItemPrototype.getChildren = function() {
        if (this.data.children) {
            return this.data.children;
        }

        return [];
    };

    contextItemPrototype.setIndent = function(indent) {
        var indentSize = 10;
        this.style.paddingLeft = indentSize * indent + 'px';

        this.indent = indent;
    };

    contextItemPrototype.setupItem = function(args) {
        var that = this;
        // A menu item has a name, one or more icons, and an action.
        // A menu item can have child items.

        // A name can be a string or a function that returns a string
        // Icons can be a string or array of strings, or a fn that returns str or
        // arr  An action is a function.  Children can be either an array of objects or
        // a function that returns as such.

        if (typeof args === 'function') {
            args = args();
        }

        if (!args.children) {
            this.querySelector('.expansionButton').style.display = 'none';
        }

        if (args.title) {
            this.querySelector('.title').textContent =
                typeof args.title === 'function' ? args.title() : args.title;
        } else {
            args.title.style.display = 'none';
        }

        var icons =
            typeof args.icons === 'function' ? args.icons() : args.icons;
        icons = icons || [];

        icons.forEach(function(iconUrl) {
            var icon = document.createElement('div');
            icon.classList.add('icon');
            that.querySelector('.iconsDiv').appendChild(icon);

            // TODO: Set icon url as background image of div.
        });

        if (icons.length === 0) {
            this.querySelector('.iconsDiv').style.display = 'none';
        }

        if (typeof args.action === 'function') {
            this.clickCallback = args.action;
        }

        this.data = args;
    };

    contextItemPrototype.setParent = function(parent) {
        this.parent = parent;
    };

    contextItemPrototype.refreshItem = function(args) {
        // Not sure if this is needed...
    };

    contextItemPrototype.addMenuItem = function(arg, index) {
        if (typeof arg === 'function') {
            arg = arg();
        }

        var that = this;

        var menuItem = document.createElement('ra-contextitemitem');
        menuItem.setupItem(arg);
        index = index || null;
    };

    contextItemPrototype.expandMenuItem = function(item) {
        var itemIndex = Array.prototype.indexOf.call(this.children, item);
        if (itemIndex === -1) {
            console.log('WARNING! Could not find menu item.');
            return;
        }

        var index = itemIndex + 1;
        var newItem;

        if (item.expanded === 'false') {
            var childArgs = item.getChildren();

            for (var i = 0; i < childArgs.length; i++) {
                newItem = this.addMenuItem(childArgs[i], index);
                newItem.setParent(item);
                index++;
            }
        }

        item.expanded = true;
        item.classList.add('expanded');
    };

    contextItemPrototype._onCollapse = function() {
        if (typeof this.collapseCallback === 'function') {
            this.collapseCallback();
        }
    };

    contextItemPrototype._onExpand = function() {
        if (typeof this.expandCallback === 'function') {
            this.expandCallback();
        }
    };

    contextItemPrototype.onCollapse = function(fn) {
        this.collapseCallback = fn;
    };

    contextItemPrototype.onExpand = function(fn) {
        this.expandCallback = fn;
    };

    Polymer(contextItemPrototype);
    GLOBAL.DS.RAComponents.contextitem = contextItemPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
