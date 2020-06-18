/*jslint plusplus:true*/

/**
 * SVG slider for  IE 9 - it does not support html 5 input range type. alternative is extjs slider  
 */
var swv6 = swv6 || {};
swv6.ui=swv6.ui|| {};
(function () {
    /**
     * @class swv6.Slider
     * @extends swv6.util.Publisher
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;
    
    CLASS =
        swv6.ui.Slider =
        function () {
            CLASS.base.ctor.apply(this, arguments);
            this.initialize.apply(this, arguments);
        };

    swv6.util.inherit(CLASS, BASE, {
        initialize: function (parent, value, min, max) {
            var that = this,
                zoomIn,
                zoomOut,
                track,
                thumb;
            
            this.addEvent('change');

            this.slideChoice = -1;

            this.min = min;
            this.max = max;

            this.el = new swv6.html.Div({
                cls : 'slider'
            });
            
            this.track = new swv6.html.Div({
                cls : 'track',
                parent : this.el
            });

            this.increment = new swv6.html.Div({
                cls : 'increment',
                events: {
                    click: function (evt) { zoomTree('in'); }
                },
                parent : this.el
            });

            this.decrement = new swv6.html.Div({
                cls : 'decrement',
                events: {
                    click: function (evt) { zoomTree('out'); }
                },
                parent : this.el
            });

            this.thumb = new swv6.html.Div({
                cls : 'thumb',
                events: {
                    mousedown: function (evt) { that.startSliderDrag(evt); },
                    dragstart: function (evt) { evt.cancelBubble = true; return false; }
                },
                parent : this.el
            });

            parent.appendChild(this.el.el);

            this.minPos = parseFloat(this.track.el.offsetTop) + 2; // 2px below the top of the track
            this.maxPos = this.minPos + parseFloat(this.track.el.offsetHeight) -
                          parseFloat(this.thumb.el.offsetHeight) - 2; // 2px above the bottom of the track
            
            this.setValue(value);

        },

        startSliderDrag: function (evt) {
            var that = this;

            if (this.dragStart) {
                // we're already in a drag?
                return;
            }
            
            // store original mouse handlers.
            this.fnMouseMove = window.onmousemove;
            this.fnMouseUp = window.onmouseup;
            
            this.dragStart = {
                clientY: evt.clientY,
                thumbY: parseFloat(this.thumb.el.offsetTop)
            };

            window.onmousemove = function (evt) { that.onMouseMove(evt); };
            window.onmouseup = function (evt) { that.onMouseUp(evt); };
            this.slideChoice = 1;
        },

        onMouseUp: function (evt) {
            delete this.dragStart;

            // restore original mouse handlers.
            window.onmousemove = this.fnMouseMove;
            window.onmouseup = this.fnMouseUp;
        },

        onMouseMove: function (evt) {
            var pos = this.dragStart.thumbY + (evt.clientY - this.dragStart.clientY),
                pct = (pos - this.minPos) / (this.maxPos - this.minPos),
                oldValue = this.value;

            this.setValue(this.min + (this.max - this.min) * (1-pct));
            
            if (this.value !== oldValue) {
                this.publish('change', this.value);
            }
        },
        
        endSliderDrag: function () {
            this.slideChoice = -1;
        },

        doSliderDrag: function (evt) {
            var posx = 0,
                posy = 0,
                pos,
                pct,
                oldValue;

            if (this.slideChoice < 0 || this.slideChoice !== 1) {
                return;
            }
            if (!evt) {
                evt = window.event;
            }
            if (evt.pageX || evt.pageY) {
                posx = evt.pageX;
                posy = evt.pageY;
            } else if (evt.clientX || evt.clientY) {
                posx = evt.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                posy = evt.clientY + document.body.scrollTop + document.documentElement.scrollTop;
            }

            pos = posy - 100;

            if (pos < this.minPos) {
                pos = this.minPos;
            }
            if (pos > this.maxPos) {
                pos = this.maxPos;
            }
            pct = (pos - this.minPos) / (this.maxPos - this.minPos);
            
            oldValue = this.value;            
            this.setValue(this.min + (this.max - this.min) * (1-pct));
            
            if (this.value !== oldValue) {
                this.publish('change', this.value);
            }
          
        },
        
        setValue: function (value) {
            if (value < this.min) {
                value = this.min;
            } else if (value > this.max) {
                value = this.max;
            }
            
            if (this.value !== value) {
                
                var pct = (value - this.min) / (this.max - this.min);
                this.thumb.el.style.top = (this.minPos + (this.maxPos - this.minPos) * (1-pct)) + 'px';

                this.value = value;
            }
        },
        
        setBounds: function (min, max) {
            this.min = min;
            this.max = max;
            this.setValue(this.value);
        }
    });

}());
