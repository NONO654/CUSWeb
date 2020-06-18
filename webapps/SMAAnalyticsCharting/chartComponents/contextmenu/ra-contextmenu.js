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
    if (typeof GLOBAL.DS.RAComponents.contextmenu !== 'undefined') {
        return;
    }

    contextMenuPrototype = {
        is: 'ra-contextmenu'
    };

    contextMenuPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        var that = this;
    };

    contextMenuPrototype.setupMenu = function(args) {
        var that = this;

        // Args can be an object or a function
        if (typeof args === 'function') {
            args = args();
        }

        if (args.title) {
            this.querySelector('.titleDiv').textContent = args.title;
        }

        var items;
        if (args.items) {
            items = args.items;
        } else if (args instanceof Array) {
            items = args;
        }

        items.forEach(function(arg) {
            that.addMenuItem(arg);
        });

        // Sample menu request:
        /*
     * {title : 'blarg',
     *  items : [ {}, {}, {}, {}, {} ]
     * };
     */
    };

    contextMenuPrototype.addMenuItem = function(arg, index) {
        // A menu item has a name, one or more icons, and an action.
        // A menu item can have child items.

        // A name can be a string or a function that returns a string
        // Icons can be a string or array of strings, or a fn that returns str or
        // arr  An action is a function.  Children can be either an array of objects or
        // a function that returns as such.

        if (typeof arg === 'function') {
            arg = arg();
        }

        var that = this;

        var menuItem = document.createElement('ra-contextmenuitem');
        menuItem.setupItem(arg);
        index = index || null;

        var nextSibling = this.querySelector('.items').children[index + 1];
        if (nextSibling) {
            this.querySelector('.items').insertBefore(menuItem, nextSibling);
        } else {
            this.querySelector('.items').appendChild(menuItem);
        }

        menuItem.onExpand(function() {
            that.expandMenuItem(menuItem);
        });

        menuItem.onCollapse(function() {
            that.collapseMenuItem(menuItem);
        });

        return menuItem;
    };

    contextMenuPrototype.expandMenuItem = function(item) {
        var itemIndex = Array.prototype.indexOf.call(
            this.querySelector('.items').children,
            item
        );
        if (itemIndex === -1) {
            console.log('WARNING! Could not find menu item.');
            return;
        }

        var index = itemIndex;
        var newItem;

        if (item.expanded === false) {
            var childArgs = item.getChildren();

            for (var i = 0; i < childArgs.length; i++) {
                newItem = this.addMenuItem(childArgs[i], index);
                newItem.setParent(item);
                newItem.setIndent((item.indent || 0) + 1);

                index++;
            }
        }

        item.expanded = true;
        item.classList.add('expanded');
    };

    contextMenuPrototype.collapseMenuItem = function(item) {
        // Removes all descendants of an item from the menu.
        // Collapses the menu item.

        var that = this;

        item.expanded = false;
        item.classList.remove('expanded');

        var i, child;
        var items = this.querySelector('.items').children;

        for (var i = items.length - 1; i >= 0; i--) {
            var child = items[i];
            if (child.parent === item) {
                if (child.expanded) {
                    this.collapseMenuItem(child);
                }

                this.querySelector('.items').removeChild(child);
            }
        }
    };

    Polymer(contextMenuPrototype);
    GLOBAL.DS.RAComponents.contextmenu = contextMenuPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
