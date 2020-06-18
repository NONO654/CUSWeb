/* globals d3 */
/* globals Polymer */
(function(GLOBAL) {
    'use strict';
    
    if (typeof GLOBAL.DS.RAComponents.overlayelement !== 'undefined') {
        return;
    }

    var overlayElementPrototype = {
        is: 'ra-overlayelement',
        behaviors: [GLOBAL.DS.RAComponents.callbacks]
    };

    overlayElementPrototype.createdCallback = function() {
        var that = this;
        
        this.reappendOnFocus = true;
        this.dragData = {};
        this.dimensions = {
            minHeight: 20 // This can be manually changed.
        };

        this.callbacks = { resize: [], close: [], dock: [], undock: [] };

        // Note: Shadow dom DOES NOT WORK VERY WELL as of 8/3/2016. All shadow dom
        // should probably be removed.  Explanation: Shadow dom would be great if it
        // actually worked, and it's possible to kind of use it  with Polymer.dom
        // methods, but this could easily be confusing for someone else trying to use
        // our work.  It would be better to use regular DOM for now, which will be
        // less efficient as far as creating things  goes (the application developer
        // will have to select and append to the content, rather than just appending
        // to the element), but probably less confusing.
        // this.shadowRootElement = Polymer.dom(this); //.createshadowRootElement();

        this.getDockWidth = function() {
            return that.getAttribute('width');
        };

        this.getDockHeight = function() {
            return that.getAttribute('height');
        };
    };

    overlayElementPrototype.setDockWidth = function(w) {
        if (typeof w === 'function') {
            this.getDockWidth = w;
        } else if (typeof w === 'number') {
            this.getDockWidth = function() {
                return w;
            };
        }
    };

    overlayElementPrototype.setDockHeight = function(h) {
        if (typeof h === 'function') {
            this.getDockHeight = h;
        } else if (typeof h === 'number') {
            this.getDockHeight = function() {
                return h;
            };
        }
    };
    
    
     overlayElementPrototype.setDraggable = function() {
        if (this.getAttribute('element-draggable') === 'true') {
                this.makeDraggable();
            }
    }
     

    overlayElementPrototype.initializeElement = function() {
        // For now, options NEED to be set before the element is attached!
        // They should be set using the "setOverlayAttributes" method or
        // declaritively as attributes.
        //
        if (this.initialized === true) {
            return;
        }

        if (this.hasAttribute('dockable')) {
            this.dockWidth = 50;
        }

        this.addFrameDiv();
        this.addTopBar();


        if (this.hasAttribute('element-title')) {
            this.addTitle();
        }

        if (this.getAttribute('closeButton') === 'true') {
            this.addCloseButton();
        }
        
        // sd4 - popout a chart into its own widget
        if (this.getAttribute('popoutButton') === 'true') {
            this.addPopoutButton();
        }
        // sd4 - download an image of the chart
        if (this.getAttribute('printButton') === 'true') {
            this.addPrintButton();
        }
        if (this.getAttribute('hideFrame') === 'true') {
            this.hideFrame();
        }
        
      
        if (this.getAttribute('resizable') === 'true') {
            this.makeResizable();
        }

        this.initialized = true;
    };

    overlayElementPrototype.attachedCallback = function() {
        if (this.initialized === true) {
            // make sure it gets sized/positioned
            this.sizeOverlay();
            this.positionOverlay();
            return;
        }
        if (this.getAttribute('shade') === 'true') {
            this.addShade();
        }

        this.initializeElement();
        this.sizeOverlay();
        this.positionOverlay();
    };

    // overlayElementPrototype.detachedCallback = function(){

    //  this.removeShade();

    //};

    overlayElementPrototype.addShade = function() {
        var that = this;

        var shadeDiv = document.createElement('div');
        shadeDiv.classList.add('shade');

        d3.select(shadeDiv).on('click', function() {
            that.parentElement.removeChild(that);
        });

        this.appendChild(shadeDiv);
    };

    overlayElementPrototype.addFrameDiv = function() {
        var frameDiv = document.createElement('div');
        frameDiv.classList.add('frame');

        this.appendChild(frameDiv);
    };

    overlayElementPrototype.addTopBar = function() {
        var frameDiv = this.querySelector('.frame');
        var topBar = document.createElement('div');
        topBar.classList.add('topBar');
        frameDiv.appendChild(topBar);

        var contentDiv = document.createElement('div');
        contentDiv.classList.add('content');
        frameDiv.appendChild(contentDiv);
    };

    overlayElementPrototype.addTitle = function() {
        var that = this;

        var title = this.getAttribute('element-title');

        var titleSpan = document.createElement('span');
        titleSpan.textContent = title;
        titleSpan.classList.add('titleSpan');

        this.querySelector('.topBar').appendChild(titleSpan);

        var titleEditable = this.getAttribute('titleEditable');
        if (titleEditable) {
            titleSpan.setAttribute('contenteditable', 'true');

            titleSpan.addEventListener('blur', function(e) {
                that.executeCallbacks('titleBlur', e);
            });

            titleSpan.addEventListener('keypress', function(e) {
                var key = e.which || e.keyCode;
                if (key === 13) {
                    e.preventDefault();
                    e.stopPropagation();
                    titleSpan.blur();
                }
            });

            titleSpan.addEventListener('keyup', function(e) {
                var newTitle = titleSpan.textContent;
                that.setAttribute('element-title', newTitle);
                that.executeCallbacks('titleChange', e);
            });
        }
    };

    overlayElementPrototype.addCloseCallback = function(fn) {
        this.addCallback('close', fn);
    };

    overlayElementPrototype.removeCloseCallback = function(fn) {
        this.removeCallback('close', fn);
    };

    overlayElementPrototype.hideFrame = function() {
        this.querySelector('.frame').classList.add('HideFrame');
        this.querySelector('.topBar').classList.add('HideFrameTopBar');
        this.querySelector('.content').classList.add('HideFrameContent');
    };

    overlayElementPrototype.addPopoutButton = function() {
        var that = this;

        var popoutButton = document.createElement('div');
        popoutButton.classList.add('popoutButton');

        this.querySelector('.topBar').appendChild(popoutButton);

        popoutButton.addEventListener('mousedown', function(e) {
            that.callbacks.popout.forEach(function(cb) {
                cb.call(that);
            });
            // that.remove();

            e.stopPropagation();
            e.preventDefault();
        });
    };
    overlayElementPrototype.addPrintButton = function() {
        var that = this;

        var printButton = document.createElement('div');
        printButton.classList.add('printButton');

        this.querySelector('.topBar').appendChild(printButton);

        printButton.addEventListener('mousedown', function(e) {
            that.callbacks.print.forEach(function(cb) {
                cb.call(that);
            });
            // that.remove();

            e.stopPropagation();
            e.preventDefault();
        });
    };
    overlayElementPrototype.addCloseButton = function() {
        var that = this;

        var closeButton = document.createElement('div');
        closeButton.classList.add('closeButton');

        this.querySelector('.topBar').appendChild(closeButton);

        closeButton.addEventListener('mousedown', function(e) {
            that.close();

            e.stopPropagation();
            e.preventDefault();
        });
    };

    overlayElementPrototype.close = function() {
        var that = this;

        this.callbacks.close.forEach(function(cb) {
            cb.call(that);
        });
        this.parentElement.removeChild(this);
    };

    overlayElementPrototype.makeDraggable = function() {
        var that = this;

        var topBar = this.querySelector('.topBar');
        topBar.classList.add('topBar-draggable');

        topBar.addEventListener('mousedown', function(e) {
            if(that.reappendOnFocus){
                // this pushes this ra-overlayelement to the front
                // if reappendOnFocus is false, then it's assumed that
                // element order is being maintained in some other
                // way (e.g., z-index)
                that.parentElement.appendChild(that);
            }
            that.startDrag(e, that);
        });
    };

    overlayElementPrototype.startDrag = function(event, element) {
        // Move the targeted overlay element

        var that = this;

        var parent = this.parentElement;

        if (this.docked && this.getAttribute('dockable')) {
            this.onUndock(event);
        }

        this.dragData = {
            startMouseX: event.clientX,
            startMouseY: event.clientY,
            startElementX: this.dimensions.x,
            startElementY: this.dimensions.y
        };

        var mouseMoveListener = function(e) {
            that.onOverlayDrag(e, element);

            e.preventDefault();
            e.stopPropagation();
        };

        var endDragListener = function(e) {
            that.endOverlayDrag(e, element);

            // End the drag on a mouseup or when the mouse leaves the body.
            parent.removeEventListener('mousemove', mouseMoveListener);
            parent.removeEventListener('mouseup', endDragListener);
            parent.removeEventListener('mouseleave', endDragListener);
        };

        parent.addEventListener('mousemove', mouseMoveListener);

        parent.addEventListener('mouseup', endDragListener);

        parent.addEventListener('mouseleave', endDragListener);
    };

    overlayElementPrototype.onOverlayDrag = function(event) {
        // Clamp x and y such that the div remains in its parent.
        var x =
            this.dragData.startElementX +
            (event.clientX - this.dragData.startMouseX);
        x = Math.max(x, 0);
        x = Math.min(x, this.parentElement.offsetWidth - this.dimensions.width);

        var y =
            this.dragData.startElementY +
            (event.clientY - this.dragData.startMouseY);
        y = Math.max(y, 0);
        y = Math.min(
            y,
            this.parentElement.offsetHeight - this.dimensions.height
        );

        d3.select(this).style({ top: y + 'px', left: x + 'px' });

        if (this.getAttribute('dockable') === 'true') {
            // var dockWidth = 50;
            if (
                y < this.dockWidth ||
                y >
                    this.parentElement.offsetHeight -
                        this.dimensions.height -
                        this.dockWidth ||
                x < this.dockWidth ||
                x >
                    this.parentElement.offsetWidth -
                        this.dimensions.width -
                        this.dockWidth
            ) {
                this.highlightDockZone(event);
            } else {
                this.unhighlightDockZone();
            }
        }
    };

    overlayElementPrototype.endOverlayDrag = function(event, element) {
        this.onOverlayDrag(event, element); // Make sure position is updated!

        // Update dimensions for next drag
        this.dimensions.x =
            this.dragData.startElementX +
            (event.clientX - this.dragData.startMouseX);
        this.dimensions.y =
            this.dragData.startElementY +
            (event.clientY - this.dragData.startMouseY);

        if (this.getAttribute('dockable') && this.dockHighlight) {
            this.onDock();
        }
    };

    overlayElementPrototype.addResizeCallback = function(fn) {
        this.addCallback('resize', fn);
    };

    overlayElementPrototype.removeResizeCallback = function(fn) {
        this.removeCallback('resize', fn);
    };

    overlayElementPrototype.makeResizable = function() {
        // popoverDiv.resizable({'stop' : this.onResize()});
        var that = this;

        var xCur = undefined,
            yCur = undefined,
            xStart = undefined,
            yStart = undefined,
            xChange = 0,
            yChange = 0,
            leftStart = this.dimensions.x,
            heightStart = this.dimensions.height,
            widthStart = this.dimensions.width,
            dragActive = false, // drag has started
            dragVarsSet = false; // drag has started and the variables for sizing are set
        
        var spyOnScreen = function(e) {
            xCur = e.screenX;
            yCur = e.screenY;
            if(!dragVarsSet){
                
                if(!xStart){
                    // remember where we started
                    xStart = xCur;
                }
                if(!yStart){
                    // remember where we started
                    yStart = yCur;
                }
                dragVarsSet = true;
            }
        
            
            // calculate the change in position
            xChange = xCur - xStart;
            yChange = yCur - yStart;
        };
        // this is a hack :'( to get screenX/pageX/whateverX working in FF
        document.addEventListener('dragover', spyOnScreen);

        var startDrag = function(e) {
            dragActive = true;
            e.stopPropagation();
            e.dataTransfer.dropEffect = 'move';
            
            // reset the sizing parameters
            xCur = undefined;
            yCur = undefined;
            xStart = undefined;
            yStart = undefined;
            xChange = undefined;
            yChange = undefined;
            dragVarsSet = false;
            
            var elem = e.target; // I saw references that this could cause a memory issue?

            if(typeof e.dataTransfer.setDragImage === 'function'){
                e.dataTransfer.setDragImage(elem, 0, 0);
            }
            // firefox requires something for data ... :(
            e.dataTransfer.setData('text', '');
            
            leftStart = this.dimensions.x;
            heightStart = Number(this.dimensions.height);
            widthStart = Number(this.dimensions.width);

            GLOBAL.DS.RAComponents.droptarget.clearDragData();
            GLOBAL.DS.RAComponents.chartdroptarget.clearDragData();
            GLOBAL.DS.RAComponents.gridcontainer.clearDragData();
        }.bind(this);

        var endDrag = function(e) {
            dragActive = false;
            e.stopPropagation();
            that.onResize();
            
            // reset the sizing parameters
            xCur = undefined;
            yCur = undefined;
            xStart = undefined;
            yStart = undefined;
            xChange = undefined;
            yChange = undefined;
            dragVarsSet = false;
        }.bind(this);

        this.setupResizeCallbacks(
            'e-ResizeHandle',
            startDrag,
            function() {
                if(!dragVarsSet){
                    return;
                }
                if (widthStart + xChange >= 0) {
                    that.dimensions.width = widthStart + xChange;
                }
                d3.select(that).style({ width: that.dimensions.width + 'px' });
            },
            endDrag
        );

        this.setupResizeCallbacks(
            'w-ResizeHandle',
            startDrag,
            function() {
                if(!dragVarsSet){
                    return;
                }
                if (widthStart - xChange >= 0) {
                    that.dimensions.width = widthStart - xChange;
                    that.dimensions.x = leftStart + xChange;
                }
                d3.select(that).style({
                    width: that.dimensions.width + 'px',
                    left: that.dimensions.x + 'px'
                });
            },
            endDrag
        );

        this.setupResizeCallbacks(
            's-ResizeHandle',
            startDrag,
            function() {
                if(!dragVarsSet){
                    return;
                }
                var yChange = yCur - yStart;
                if (heightStart + yChange >= 0) {
                    that.dimensions.height = heightStart + yChange;
                }
                d3.
                    select(that).
                    style({ height: that.dimensions.height + 'px' });
            },
            endDrag
        );

        this.setupResizeCallbacks(
            'se-ResizeHandle',
            startDrag,
            function() {
                if(!dragVarsSet){
                    return;
                }
                var xChange = xCur - xStart,
                    yChange = yCur - yStart;
                if (widthStart + xChange >= 0) {
                    that.dimensions.width = widthStart + xChange;
                }
                if (heightStart + yChange >= 0) {
                    that.dimensions.height = heightStart + yChange;
                }
                d3.select(that).style({
                    width: that.dimensions.width + 'px',
                    height: that.dimensions.height + 'px'
                });
            },
            endDrag
        );

        this.setupResizeCallbacks(
            'sw-ResizeHandle',
            startDrag,
            function() {
                if(!dragVarsSet){
                    return;
                }
                var xChange = xCur - xStart,
                    yChange = yCur - yStart;
                if (widthStart - xChange >= 0) {
                    that.dimensions.width = widthStart - xChange;
                    that.dimensions.x = leftStart + xChange;
                }
                if (heightStart + yChange >= 0) {
                    that.dimensions.height = heightStart + yChange;
                }
                d3.select(that).style({
                    width: that.dimensions.width + 'px',
                    left: that.dimensions.x + 'px',
                    height: that.dimensions.height + 'px'
                });
            },
            endDrag
        );
    };

    overlayElementPrototype.setupResizeCallbacks = function(
        className,
        startDragCallback,
        dragCallback,
        endDragCallback
    ) {
        var element = document.createElement('div');
        element.classList.add(className);
        element.setAttribute('draggable', 'true');
        element.ondragstart = startDragCallback;
        element.ondrag = dragCallback;
        element.ondragend = endDragCallback;
        this.appendChild(element);
    };

    overlayElementPrototype.onResize = function(resizeData) {
        var that = this;

        this.callbacks.resize.forEach(function(cb) {
            cb.call(that, resizeData);
        });
    };

    overlayElementPrototype.addContent = function() {
        // Adds the content element to the shadow root, based on what elements are
        // already there.

        if (this.querySelector('.content')) {
            // this.querySelector('.content').appendChild(document.createElement('content'));
        } else {
            var contentDiv = document.createElement('div');
            contentDiv.classList.add('.content');
            this.appendChild(contentDiv);
        }
    };

    overlayElementPrototype.setOverlayAttributes = function(options) {
        if (options.resizable === 'true') {
            // All resizable divs are draggable.
            options['element-draggable'] = 'true';
        }
        
        this.options = options;

        // Create a mobile dialog that can be used to generate a new chart.
        Object.keys(options).forEach(function(key){
            this.setAttribute(key, options[key]);
        }.bind(this));
    };
    
    overlayElementPrototype.getOverlayAttributes = function(){
        var attributes = {};
        
        Object.keys(this.options).forEach(function(key){
            attributes[key] = this.getAttribute(key);
        }.bind(this));
        
        return attributes;
    };

    overlayElementPrototype.sizeOverlay = function() {
        /*if(this.querySelector('.frame')){
        d3.select(this.querySelector('.frame')).style({
            'height' : (+this.getAttribute('height') + 26) + 'px',
            'width' : (+this.getAttribute('width') + 6) + 'px'
        });
    } else {
        d3.select(this).style({
            'background' : 'red',
            'height' : this.getAttribute('height') + 'px',
            'width' : this.getAttribute('width') + 'px'
        });
    }*/

        var width, height;
        if (
            typeof this.dimensions.width !== 'undefined' &&
            typeof this.dimensions.height !== 'undefined'
        ) {
            width = this.dimensions.width;
            height = this.dimensions.height;
            d3.
                select(this).
                style({ height: height + 'px', width: width + 'px' });
        } else {
            width = this.getAttribute('width');
            height = this.getAttribute('height');
            d3.select(this).style({
                height: Number(height) + 26 + 'px',
                width: Number(width) + 6 + 'px'
            });
        }

        this.dimensions.width = width;
        this.dimensions.height = height;
    };

    overlayElementPrototype.positionOverlay = function() {
        if (this.docked === false) {
            return;
        }

        var parentHeight = this.parentElement.offsetHeight,
            parentWidth = this.parentElement.offsetWidth;

        var position;
        if (!this.hasAttribute('position')) {
            position = 'center';
        } else {
            position = this.getAttribute('position');
        }

        var positionArgs = position.split(' ');

        var el;
        // if(this.querySelector('.frame')){
        //  el = this.querySelector('.frame');
        //} else {
        el = this;
        //}

        var height = this.dimensions.height || this.getAttribute('height');
        var width = this.dimensions.width || this.getAttribute('width');
        var top;
        var left;

        if (
            typeof this.dimensions.x !== 'undefined' &&
            typeof this.dimensions.y !== 'undefined'
        ) {
            top = this.dimensions.y + 'px';
            left = this.dimensions.x + 'px';
        } else if (positionArgs[0] === 'center') {
            top = (Number(parentHeight) - height) / 2 + 'px';
            left = (Number(parentWidth) - width) / 2 + 'px';
        } else if (positionArgs[0] === 'coordinates') {
            top = Number(positionArgs[2]) || Number(parentHeight) / 2;
            left = Number(positionArgs[1]) || Number(parentWidth) / 2;

            top -= height / 2;
            left -= width / 2;

            top += 'px';
            left += 'px';
        } else if (positionArgs[0] === 'last-click') {
            if (this.parentElement.clickCoordinates) {
                top = this.parent.clickCoordinates.y;
                left = this.parent.clickCoordinates.x;
            }
        } /* else if(positionArgs[0] === 'dock'){
         var p = positionArgs[1] || 'bottom';

         if(p === 'top' || p === 'left'){
             top = 0;
             left = 0;
         } else if(p === 'bottom'){
             top = parentHeight - height;
             left = 0;
         } else if(p === 'right'){
             top = 0;
             left = parentWidth - width;
         }
     }*/

        if (positionArgs[0] === 'dock') {
            this.onDock();
        } else {
            this.dimensions.x = Number(left.split('p')[0]);
            this.dimensions.y = Number(top.split('p')[0]);
            d3.select(el).style({ top: top, left: left });
        }
    };

    overlayElementPrototype.highlightDockZone = function(event) {
        if (typeof this.dockHighlight === 'undefined') {
            this.dockHighlight = document.createElement('div');
            // Styles are inline since this element will be appended to the parent.
            d3.select(this.dockHighlight).style({
                border: '2px solid green',
                background: 'none',
                position: 'absolute'
            });

            this.parentElement.insertBefore(this.dockHighlight, this);
        }

        console.log('highlight dock zone!');
        console.log('Dock width: ' + this.dockWidth);

        var x =
            this.dragData.startElementX +
            (event.clientX - this.dragData.startMouseX);

        var y =
            this.dragData.startElementY +
            (event.clientY - this.dragData.startMouseY);

        console.log('x:');
        console.log(x);
        console.log('y:');
        console.log(y);

        // Note: empty syles are required to reset values, since the drop zone is
        // resized  instead of re created.
        if (y < this.dockWidth && (y < x || y)) {
            // Top drop zone
            this.dockDirection = 'top';
        } else if (
            y >
            this.parentElement.offsetHeight -
                this.dimensions.height -
                this.dockWidth
        ) {
            // Bottom drop zone
            this.dockDirection = 'bottom';
        } else if (x < this.dockWidth) {
            // Left drop zone
            this.dockDirection = 'left';
        } else if (
            x >
            this.parentElement.offsetWidth -
                this.dimensions.width -
                this.dockWidth
        ) {
            // Right drop zone
            this.dockDirection = 'right';
        }

        d3.
            select(this.dockHighlight).
            style(this.getDockDimensions(this.dockDirection));
    };
    
    overlayElementPrototype.updateDockPosition = function(){
        var dockDirection = this.getAttribute('dockDirection');
        
        d3.select(this).style(this.getDockDimensions(dockDirection));
    }

    overlayElementPrototype.onDock = function(direction) {
        var that = this;

        var direction =
            direction ||
            this.dockDirection ||
            this.getAttribute('dockdirection') ||
            this.getAttribute('position').split(' ')[1] ||
            'bottom';

        

        // QW8: This stuff needs to be called before the callback, since callbacks
        // may need to know the  dock direction.
        this.docked = true;
        this.setAttribute('position', 'dock');
        this.setAttribute('dockDirection', direction);
        this.unhighlightDockZone();
        
        this.updateDockPosition();

        this.callbacks.dock.forEach(function(cb) {
            //'that' is supplied both as the 'this' argument and as a variable.
            // This is because I'm not sure how this should eventually work, and
            // want  it to work both ways for now.
            // -qw8 9/9/16
            cb.call(that, that);
        });
    };

    overlayElementPrototype.getDockDimensions = function(direction) {
        // Accepts argument elementOf['top, 'bottom', 'left', 'right]

        console.log('Get dock dimensions!');
        console.log('Dock height:');
        console.log(this.getDockHeight());

        // Returns style block for highlight block/element.
        if (direction === 'top') {
            return {
                left: '0px',
                right: '0px',
                bottom: '',
                top: '0px',
                height: this.getDockHeight() + 'px',
                width: ''
            };
        } else if (direction === 'bottom') {
            return {
                left: '0px',
                right: '0px',
                bottom: '0px',
                top: '',
                height: this.getDockHeight() + 'px',
                width: ''
            };
        } else if (direction === 'left') {
            return {
                left: '0px',
                right: '',
                bottom: '0px',
                top: '0px',
                height: '',
                width: this.getDockWidth() + 'px'
            };
        } else if (direction === 'right') {
            return {
                left: '',
                right: '0px',
                bottom: '0px',
                top: '0px',
                height: '',
                width: this.getDockWidth() + 'px'
            };
        }
    };

    overlayElementPrototype.unhighlightDockZone = function() {
        if (this.dockHighlight) {
            this.parentElement.removeChild(this.dockHighlight);

            delete this.dockHighlight;
            delete this.dockDirection;
        }
    };

    overlayElementPrototype.addDockCallback = function(cb) {
        this.addCallback('dock', cb);
    };

    overlayElementPrototype.removeDockCallback = function(cb) {
        this.removeCallback('dock', cb);
    };

    overlayElementPrototype.onUndock = function(event) {
        var that = this;

        //var direction = this.dockDirection;
        var width = this.getAttribute('width');

        d3.select(this).style({
            bottom: '',
            right: '',
            height: this.getAttribute('height') + 'px',
            width: width + 'px'
        });

        var parentClientRect = this.parentElement.getBoundingClientRect();
//        var clientRect = this.getBoundingClientRect();

        var x = event.clientX - parentClientRect.left - width / 2;
        var y = event.clientY - parentClientRect.top;

        x = Math.max(x, 0);
        x = Math.min(x, this.parentElement.offsetWidth - this.dimensions.width);

        y = Math.max(y, 0);
        y = Math.min(
            y,
            this.parentElement.offsetHeight - this.dimensions.height
        );

        d3.select(this).style({ top: y + 'px', left: x + 'px' });

        this.docked = false;

        // Update dimensions
        this.dimensions.x = x;
        this.dimensions.y = y;

        /*var position = this.getAttribute('position');
    if(this.hasAttribute('position')){
        var positionArgs = position.split(' ');
        for(var i = 0; i < positionArgs.length; i++){

        }
    }*/

        this.callbacks.undock.forEach(function(cb) {
            cb.call(that, that);
        });
    };

    overlayElementPrototype.addUndockCallback = function(fn) {
        this.addCallback('undock', fn);
    };

    Polymer(overlayElementPrototype);
    GLOBAL.DS.RAComponents.overlayelement = overlayElementPrototype;
})(this);
