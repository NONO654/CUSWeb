/* globals Polymer */
(function() {
    'use strict';
    var draggablePrototype = { is: 'ra-draggable' };

    draggablePrototype.createdCallback = function() {
        this.data = '';

        this.setAttribute('draggable', true);
        
        this.addEventListener('dragstart', function(e) {
            this.startDrag(e);
            // make sure the ghost image is attached to the cursor
            if(typeof e.dataTransfer.setDragImage === 'function'){
                e.dataTransfer.setDragImage(this, 0, 0);
            }
            // text/plain causes IE11 to vomit
            e.dataTransfer.setData('text', JSON.stringify(this.data));
        }.bind(this));
        
        this.addEventListener('dragend', function(e) {
            this.endDrag(e);
        }.bind(this));
    };

    draggablePrototype.setData = function(data) {
        this.data = data;
    };

    draggablePrototype.setDragStartCallback = function(cb) {
        // This will fire in addition to the default behavior.
        this.dragStarCallback = cb;
    };

    draggablePrototype.startDrag = function(e) {
        if (typeof this.dragStartCallback === 'function') {
            this.dragStartCallback(e);
        }
        try {
            window.DS.RAComponents.droptarget.setDragStartData(this.data);
            //window.DS.RAComponents.chartdroptarget.setDragStartData(this.data);
            //window.DS.RAComponents.gridcontainer.setDragStartData(this.data);
            //window.DS.RAComponents.simplecontainer.setDragStartData(this.data);
        } catch (err) {
            console.warn('Error setting dragstart data', err);
        }
    };

    draggablePrototype.endDrag = function() {
        try {
            window.DS.RAComponents.droptarget.clearDragData();
            //window.DS.RAComponents.chartdroptarget.clearDragData();
            //window.DS.RAComponents.gridcontainer.clearDragData();
            //window.DS.RAComponents.simplecontainer.clearDragData();
        } catch (err) {
            console.warn('Error clearing dragstart data', err);
        }
    };

    Polymer(draggablePrototype);

    window.DS.RAComponents.draggable = draggablePrototype;
})();
