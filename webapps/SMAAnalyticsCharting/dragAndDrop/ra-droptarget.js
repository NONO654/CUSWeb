(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.droptarget !== 'undefined') {
        return;
    }

    /*
 NEW DROP TARGET PARADIGM:
 A drop target can hold one or more drop handlers.
 Each drop handler can specify either a single type
 or a function as its drop filter, which will specify
 acceptable target types for that drop filter. If the
 drop filter is a string, the type of the dragged data
 must match that string. If the drop filter is a function,
 that function will be passed the type, which it will
 evaluate and return 'true' if that type denotes an
 acceptable payload for the target.

 Each drop handler will then have a drop listener defined
 on it, which will execute on a successful drop. A drop
 listener will be passed the EVENT, from which it will
 be expected to internally parse the data.

 Drop handlers can also support a dragEnter listener. In
 the case of a dragEnter event, the SAME filtering function
 will be used to determine if the drop handler is a viable
 target for the payload, after which the dragEnter listener
 will fire. This callback will also be passed the event.

 A drop target also implements all behaviors on a drop handler
 itself, allowing a developer to define listeners and filters
 on the drop target. This is done to allow a dropTarget to handle
 behaviors that should fire for all acceptable events, as well as
 to reduce overhead in the case of drop targets that are expected
 to handle only a single data type. Note that it is probably best
 practice to use a dropHandler even in the case of a dropTarget
 handling only a single data type, if the addition of other data
 types in the future would require different behavior than the
 behavior specified on the dropTarget. A dropFilter defined on a
 drop taret will apply ONLY to the listeners defined on the drop
 target, not on listeners defined on drop handlers which are children
 of that drop target.
*/

    var dropTargetPrototype = {
        is: 'ra-dropTarget',
        behaviors: [GLOBAL.DS.RAComponents.drophandler]
    };

    dropTargetPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.drophandler.createdCallback.call(this);

        var that = this;

        this.dragging = false;

        this.addEventListener('dragover', function(e) {
            e.preventDefault();
        });

        this.addEventListener('drop', function(e) {
            that.onDrop(e);
            that.onDragLeave(e);
        });

        this.addEventListener('dragenter', function(e) {
            that.onDragEnter(e);
        });

        this.addEventListener('mouseout', function(e) {
            // NOTE: dragleave fires not only on an actual dragleave event, but also
            // when the user moves  from an element to a child of that element. This
            // is not desirable behavior, so rather than  using the standard dragleave
            // event, we will listen for the mouseout event and use it to fire  our
            // dragleave handler if one has been assigned and there is an active drag
            // event happening.
            if (this.dragging === true) {
                this.onDragLeave(e);
            }
        });
    };

    dropTargetPrototype.setDragStartData = function(data) {
        dropTargetPrototype.dragStartData = data;
    };
    
    dropTargetPrototype.getDragStartData = function(data) {
        return dropTargetPrototype.dragStartData;
    };
    

    dropTargetPrototype.clearDragData = function(data) {
        dropTargetPrototype.dragCounter = 0; // need to track
        delete dropTargetPrototype.dragStartData;
    };
    dropTargetPrototype.onDragEnter = function(e) {
        this.dragging = true;

        e.preventDefault();
        // e.stopPropagation();

        if (typeof this.dragEnterListener === 'function') {
            if (!this.checkFilter(dropTargetPrototype.dragStartData)) {
                this.dragEnterListener(e);
            }
        }

        this.propogateToDropHandlers(function(dropHandler) {
            if (typeof dropHandler.dragEnterListener === 'function') {
                if (!dropHandler.checkFilter(dropTargetPrototype.dragStartData)) {
                    dropHandler.dragEnterListener(e);
                }
            }
        });
    };

    dropTargetPrototype.onDragLeave = function(e) {
        if (typeof this.dragLeaveHandler === 'function') {
            this.dragLeaveHandler(e);
        }

        this.classList.remove('dragHover');
    };

    dropTargetPrototype.onDrop = function(e) {
        e.preventDefault();
        e.stopPropagation();

        var dropTypes = e.dataTransfer.types;

        var that = this;

        var dragData = this.getParsedData(e); // getParsedData is inherited from the prototype of dropHandler.

        if (typeof this.dropListener === 'function') {
            if (!this.checkFilter(dropTargetPrototype.dragStartData)) {
                GLOBAL.DS.RAComponents.drophandler.onDrop.call(that, e);
            }
        }

        this.propogateToDropHandlers(function(dropHandler) {
            if (!dropHandler.checkFilter(dropTargetPrototype.dragStartData)) {
                dropHandler.onDrop(e);
            }
        });
    };

    // helper function to search for drop handlers that are children of the drop
    // target
    dropTargetPrototype.propogateToDropHandlers = function(callback) {
        if (typeof callback !== 'function') {
            return;
        }
        Array.prototype.forEach.call(
            this.children,
            function(dropHandler) {
                if (dropHandler.tagName.toLowerCase() !== 'ra-drophandler') {
                    // this is not actually a drop handler element
                    return;
                }
                callback.call(this, dropHandler);
            },
            this
        );
    };

    Polymer(dropTargetPrototype);
    GLOBAL.DS.RAComponents.droptarget = dropTargetPrototype;

    // Define a drop target with a few default styles/behaviors.
    var defaultDropTargetPrototype = {
        is: 'ra-defaultdroptarget',
        behaviors: [dropTargetPrototype]
    };

    defaultDropTargetPrototype.createdCallback = function() {
        dropTargetPrototype.createdCallback.call(this);
    };

    Polymer(defaultDropTargetPrototype);
    GLOBAL.DS.RAComponents.defaultdroptarget = defaultDropTargetPrototype;
})(this);
