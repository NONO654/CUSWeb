/*jslint plusplus:true*/
/*globals window*/

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};
swv6.svg = swv6.svg || {};
(function () {
    /**
     * @class swv6.ui.Camera
     * @extends swv6.util.Publisher
     * A virtual camera capable of manipulating the current view.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.Camera =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.addEvent('pan');
            this.addEvent('zoom');
            this.addEvent('change');

            this.svg = new swv6.svg.SVG();

            this.viewport = config.viewport.el;
            this.setScene(config.scene);

            this.position = this.createPosition({type: 'matrix'});

            if (config.padding) {
                this.padding = config.padding;
            }

        };

    swv6.util.inherit(CLASS, BASE, {
        
        svg: undefined,
        scene: undefined,
        viewport: undefined,

        minZoom: 0.01,
        maxZoom: 3,
        padding: {
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        },

        position: undefined,

        txCount: 0,

        // depricated
        refresh: function () {
        },

        setScene: function (scene) {
            this.scene = scene;

            if (this.scene instanceof swv6.svg.Element) {
                this.setTransform = this.setSVGTransform;
            } else if (this.scene instanceof swv6.html.Element) {
                this.setTransform = this.setHTMLTransform;
            } else {
                throw 'Unsupported scene object.';
            }

            this.scene.setAttribute(
                'style',
                (this.scene.getAttribute('style') || '') + ' ' +
                'transform-origin: left top; ' +
                '-moz-transform-origin: left top; ' +
                '-webkit-transform-origin: left top; ' +
                '-ms-transform-origin: left top;'
            );

        },

        // private
        setTransfrom: undefined, // determined in setScene function

        // private
        setSVGTransform: function (matrix) {
            var s = "matrix(" + matrix.a + "," + matrix.b + "," + matrix.c + "," + matrix.d + "," + matrix.e + "," + matrix.f + ")";
            // if the scene is an SVG element, then we apply a transform attribute
            this.scene.setAttribute("transform", s);
        },

        // private
        setHTMLTransform: function (matrix) {
            // if the scene is an HTML element, a transform is added to the element's style.
            this.scene.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.e, matrix.f);
        },

        getCurrentZoom: function () {
            return this.position.getMatrix().a;
        },

        /**
         * Gets the current transform matrix of the scene.
         * Prefer getPosition instead.
         */
        getCTM: function() {
            return this.cloneMatrix(this.position.getMatrix());
        },

        /**
         * Sets the current transform matrix of the scene.
         * Prefer setPosition instead.
         */
        setCTM: function(matrix, animationTime) {
            var path = this.createPath(),
                position = {
                    type: 'matrix',
                    matrix: matrix
                };

            if (animationTime) {
                path.addPosition({
                    time: animationTime,
                    position: position
                });
                path.run();
            } else {
                this.setPosition(position);
            }
        },

        getTxCount: function () {
            return this.txCount;
        },

        /**
         * TODO: description
         */
        getPosition: function () {
            return this.position;
        },

        /**
         * TODO: description
         */
        setPosition: function (position, force) {

            if (!(position instanceof swv6.ui.Camera.Position)) {
                position = this.createPosition(position);
            }

            //copy position into a fixed matrix position
            this.position = position.getFixed();

            this.txCount++;

            // using animation frames to prevent updating svg transform too frequently.
            if (!this.interval || force) {
                this.updatePosition();
            }
        },

        // private
        updatePosition: function () {
            var that = this,
                s,
                m, matrix,
                txCount,
                w, h;

            if (this.interval) {
                window.cancelAnimationFrame(this.interval);
                this.interval = undefined;
            }

            txCount = this.txCount;

            matrix = this.position.getMatrix();
            m = this.lastMatrix || this.svg.el.createSVGMatrix();

            this.setTransform(matrix);

            if (m.a !== matrix.a) {
                this.publish('zoom', matrix.a, m.a);
            }

            if ((m.e !== matrix.e) || (m.f !== matrix.f)) {
                this.publish('pan', matrix.e, matrix.f);
            }

            this.publish('change', matrix);

            this.lastMatrix = matrix;

            // using animation frames to prevent updating svg transform too frequently.
            this.interval = window.requestAnimationFrame( function () {
                that.interval = undefined;
                // if txCount has changed, then a new position has come in since our last update.
                if ( that.txCount !== txCount ) {
                    that.updatePosition();
                }
            });
        },

        getCenter: function () {
            var matrix = this.position.getMatrix(),
                sc = matrix.a;
                
            return {
                x: ((this.viewport.offsetWidth / 2) - matrix.e) / sc,
                y: ((this.viewport.offsetHeight / 2) - matrix.f) / sc
            };
        },

        setCenter: function (x, y, animate) {
            var sc = this.getCurrentZoom(),
                tx = (this.viewport.offsetWidth / 2) - (x * sc),
                ty = (this.viewport.offsetHeight / 2) - (y * sc);

            this.setCTM(
                this.createMatrix(sc, 0, 0, sc, tx, ty),
                (animate === undefined) ? 200 : animate
            );
        },

        zoom: function (factor, centerX, centerY, andCenter, animate) {
            var viewport = this.viewport,
                matrix = this.cloneMatrix(this.position.getMatrix()),
                pt1,
                pt2,
                inv,
                path = this.createPath(),
                position;

            if (matrix) {

                // Ensure requested zoom is within max and min values.
                if (factor > this.maxZoom) {
                    factor = this.maxZoom;
                } else if (factor < this.minZoom) {
                    factor = this.minZoom;
                }

                // find center of view in svg coordinates
                pt1 = this.svg.el.createSVGPoint();

                if (centerX === undefined) {
                    centerX = viewport.offsetWidth / 2;  // center x of viewport
                }
                if (centerY === undefined) {
                    centerY = viewport.offsetHeight / 2;  // center y of viewport
                }
                pt1.x = centerX;
                pt1.y = centerY;

                inv = matrix.inverse();
                pt1 = pt1.matrixTransform(inv);

                if (andCenter === true) {
                    pt2 = this.svg.el.createSVGPoint();

                    pt2.x = viewport.offsetWidth / 2;  // center x of viewport
                    pt2.y = viewport.offsetHeight / 2; // center y of viewport
                    pt2 = pt2.matrixTransform(inv);
                } else {
                    pt2 = pt1;
                }

                position = this.createPosition({
                    type: 'matrix',
                    matrix: matrix                          // apply the zoom transformations to the current matrix.
                                .translate(pt2.x, pt2.y)    // 3. move center of zoom to its new position.
                                .scale(factor / matrix.a)   // 2. do the zoom
                                .translate(-pt1.x, -pt1.y)  // 1. move center of zoom to origin.
                });

                if (animate) {
                    path.addPosition({
                        time: animate,
                        position: position
                    });
                    path.run();
                } else {
                    this.setPosition(position);
                }
            }

        },

        // units are in scene space, not viewport space.
        zoomToBox: function (x, y, width, height, animate) {
            var path = this.createPath(),
                position = {
                    type: 'box',
                    x: x,
                    y: y,
                    width: width,
                    height: height
                };

            if (animate) {
                path.addPosition({
                    time: animate,
                    position: position
                });
                path.run();
            } else {
                this.setPosition(position);
            }

        },

        fitWindow: function (animate) {
            var path = this.createPath(),
                position = {
                    type: 'fit',
                    el: this.scene,
                    padding: this.padding
                };

            if (animate) {
                path.addPosition({
                    time: animate,
                    position: position
                });
                path.run();
            } else {
                this.setPosition(position);
            }

        },

        // returned units in scene space.
        getFitFOV: function () {
            var p = swv6.ui.Camera.Position.create({
                type: 'fit',
                camera: this,
                el: this.scene,
                padding: this.padding
            });
            return p.getFOV();
        },

        getMinFOV: function () {
            return {
                x: 0,
                y: 0,
                width: this.viewport.offsetWidth / this.maxZoom,
                height: this.viewport.offsetHeight / this.maxZoom
            };
        },

        getMaxFOV: function () {
            return {
                x: 0,
                y: 0,
                width: this.viewport.offsetWidth / this.minZoom,
                height: this.viewport.offsetHeight / this.minZoom
            };
        },

        // returned units in tree space.
        getFOV: function (padding) {
            return this.position.getFOV(padding);
        },

        matricesAreEquivalent: function (m1, m2) {
            var delta = 0.0001;
            return (
                m1 && m2 &&
                (Math.abs(m1.a - m2.a) < delta) &&
                (Math.abs(m1.b - m2.b) < delta) &&
                (Math.abs(m1.c - m2.c) < delta) &&
                (Math.abs(m1.d - m2.d) < delta) &&
                (Math.abs(m1.e - m2.e) < delta) &&
                (Math.abs(m1.f - m2.f) < delta)
            );
        },

        createMatrix: function (a, b, c, d, e, f) {
            var matrix = this.svg.el.createSVGMatrix();

            matrix.a = a;
            matrix.b = b;
            matrix.c = c;
            matrix.d = d;
            matrix.e = e;
            matrix.f = f;
            
            return matrix;
        },

        cloneMatrix: function (m) {
            return this.createMatrix(m.a, m.b, m.c, m.d, m.e, m.f);
        },

        createPosition: function (config) {
            config.camera = this;
            return swv6.ui.Camera.Position.create(config);
        },

        createPath: function (config) {
            config = config || {};
            config.camera = this;
            return new swv6.ui.Camera.Path(config);
        }
    });

}());


(function () {
    /**
     * @class swv6.ui.Camera.Position
     * A position for a camera.
     */
    'use strict';
    var CLASS,
        BASE = Object,
        types = {};

    CLASS =
        swv6.ui.Camera.Position =
        function (config) {
            var m = config.camera.svg.el.createSVGMatrix();

            m.a = 1;
            m.b = 0;
            m.c = 0;
            m.d = 1;
            m.e = 0;
            m.f = 0;

            this.matrix = m;

            this.camera = config.camera;
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {swv6.ui.Camera} camera
         * The related camera
         */
        camera: undefined,

        // private
        matrix: undefined,

        /**
         * Retrieves the camera matrix for this position
         * @return {Object} The matrix, containing values a-f.
         * @return {Number} return.a The a matrix value
         * @return {Number} return.b The b matrix value
         * @return {Number} return.c The c matrix value
         * @return {Number} return.d The d matrix value
         * @return {Number} return.e The e matrix value
         * @return {Number} return.f The f matrix value
         */
        getMatrix: function () {
            return this.matrix;
        },

        /**
         * Retrieves the field of view for the camera at this position
         * @param {Object} [padding] Padding to factor into the fov.
         * @param {Number} [padding.top = 0]
         * @param {Number} [padding.right = 0]
         * @param {Number} [padding.bottom = 0]
         * @param {Number} [padding.left = 0]
         * @return {Object} The field of view
         * @return {Number} return.x The x coordinate
         * @return {Number} return.y The y coordinate
         * @return {Number} return.width The width
         * @return {Number} return.height The height
         */
        getFOV: function (padding) {
            var m = this.getMatrix(),
                vp = this.camera.viewport,
                fov;

            if (padding) {
                fov = {
                    x: -(m.e - padding.left) / m.a,
                    y: -(m.f - padding.top) / m.a,
                    width: (vp.offsetWidth - padding.left - padding.right) / m.a,
                    height: (vp.offsetHeight - padding.top - padding.bottom) / m.a
                };
            } else {
                fov = {
                    x: -m.e / m.a,
                    y: -m.f / m.a,
                    width: vp.offsetWidth / m.a,
                    height: vp.offsetHeight / m.a
                };
            }

            return fov;
        },

        /**
         * Retrieves the zoom value for this position.
         * @return {Number} The zoom value
         */
        getZoom: function () {
            return this.getMatrix().a;
        },

        /**
         * Retrieves a fixed representation of this position.  Useful with position types
         * whose actual positions may vary depending on other factors.  
         * For example, Box positions may change based on viewport size, and Fit positions 
         * may change based on the scene and viewport sizes.
         * @return {swv6.ui.Camera.Position} The fixed position
         */
        getFixed: function () {
            return this.camera.createPosition({
                type: 'matrix',
                matrix: this.getMatrix()
            });
        },

        fromSceneToViewport: function (x, y) {
            var m = this.getMatrix();
            return {
                x: x * m.a + m.e,
                y: y * m.d + m.f
            };
        },

        fromViewportToScene: function (x, y) {
            var m = this.getMatrix();
            return {
                x: (x - m.e) / m.a,
                y: (y - m.f) / m.d
            };
        },

        equivalent: function (position) {
            var m1 = this.getMatrix(),
                m2 = position.getMatrix();

            return (m1.a === m2.a) &&
                   (m1.b === m2.b) &&
                   (m1.c === m2.c) &&
                   (m1.d === m2.d) &&
                   (m1.e === m2.e) &&
                   (m1.f === m2.f);
        },

        zoom: function (factor) {
            var viewport = this.camera.viewport,
                svg = this.camera.svg,
                center,
                position,
                matrix = this.getMatrix();

            center = svg.el.createSVGPoint();
            center.x = viewport.offsetWidth / 2;
            center.y = viewport.offsetHeight / 2;
            center = center.matrixTransform(matrix.inverse());

            position = this.camera.createPosition({
                type: 'matrix',
                matrix: matrix                                // apply the zoom transformations to the current matrix.
                            .translate(center.x, center.y)    // 3. move center of zoom to its new position.
                            .scale(factor / matrix.a)         // 2. do the zoom
                            .translate(-center.x, -center.y)  // 1. move center of zoom to origin.
            });

            return position;
        }

    });

    /**
     * Registers a camera position type.
     * @static
     * @param {String} type A unique identifier for this type of position.
     * @param {swv6.ui.Camera.Position} position The constructor for this type of position.
     */
    swv6.ui.Camera.Position.register = function (type, position) {
        types[type] = position;
    };

    /**
     * Creates a camera position of the appropriate type based on the config's 'type' attribute.
     * @static
     * @param {Object} config A config item for the position.
     * @return {swv6.ui.Camera.Position} The camera position.  Undefined if type not registered.
     */
    swv6.ui.Camera.Position.create = function (config) {
        var t = config.type,
            p = undefined;

        if (t && types[t]) {
            p = new types[t](config);
        }

        return p;
    };

}());

(function () {
    /**
     * @class swv6.ui.Camera.Position.Matrix
     * @extends swv6.ui.Camera.Position
     * A matrix position for a camera, in the form:<pre><code>
     [a c e]
     [b d f]</code></pre>
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Camera.Position;

    CLASS =
        swv6.ui.Camera.Position.Matrix =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            if (config.matrix) {
                config = config.matrix;
            }

            this.matrix.a = config.a || this.a;
            this.matrix.b = config.b || this.b;
            this.matrix.c = config.c || this.c;
            this.matrix.d = config.d || this.d;
            this.matrix.e = config.e || this.e;
            this.matrix.f = config.f || this.f;
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {Object} matrix
         * An SVG Matrix to use for the matrix values.
         */

        /**
         * @cfg {Number} a
         * The a component of the matrix.
         */
        a: 1,

        /**
         * @cfg {Number} b
         * The b component of the matrix.
         */
        b: 0,

        /**
         * @cfg {Number} c
         * The c component of the matrix.
         */
        c: 0,

        /**
         * @cfg {Number} d
         * The d component of the matrix.
         */
        d: 1,

        /**
         * @cfg {Number} e
         * The e component of the matrix.
         */
        e: 0,

        /**
         * @cfg {Number} f
         * The f component of the matrix.
         */
        f: 0

    });

    swv6.ui.Camera.Position.register('matrix', swv6.ui.Camera.Position.Matrix);

}());


(function () {
    /**
     * @class swv6.ui.Camera.Position.Box
     * @extends swv6.ui.Camera.Position
     * A position for a camera.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Camera.Position;

    CLASS =
        swv6.ui.Camera.Position.Box =
        function (config) {
            var p = (config && config.padding) || {};

            CLASS.base.ctor.apply(this, arguments);

            this.x = config.x;
            this.y = config.y;
            this.width = config.width;
            this.height = config.height;

            this.padding = {};
            this.padding.right = p.right || 0;
            this.padding.left = p.left || 0;
            this.padding.top = p.top || 0;
            this.padding.bottom = p.bottom || 0;

        };

    swv6.util.inherit(CLASS, BASE, {
        /**
         * @cfg {Number} x
         * The x position of the box
         */
        x: 0,

        /**
         * @cfg {Number} y
         * The y position of the box
         */
        y: 0,

        /**
         * @cfg {Number} width
         * The width position of the box
         */
        width: 0,

        /**
         * @cfg {Number} height
         * The height position of the box
         */
        height: 0,

        /**
         * @cfg {String} align
         * The alignment position of the box.
         */
        align: undefined,

        /**
         * @cfg {Object} padding Padding to place around the box.
         * @cfg [padding.top = 0]
         * @cfg [padding.right = 0]
         * @cfg [padding.bottom = 0]
         * @cfg [padding.left = 0]
         */
        padding: undefined,

        getMatrix: function () {
            var w = this.camera.viewport.offsetWidth - this.padding.left - this.padding.right,
                h = this.camera.viewport.offsetHeight - this.padding.top - this.padding.bottom,
                arVP = w / h,
                arBox = this.width / this.height,
                scale;

            scale = (arVP > arBox) ? (h / this.height) : (scale = w / this.width);

            if (scale > this.camera.maxZoom) {
                scale = this.camera.maxZoom - 0.001;
            }

            if (scale < this.camera.minZoom) {
                scale = this.camera.minZoom;
            }

            this.matrix.a = scale;
            this.matrix.b = 0;
            this.matrix.c = 0;
            this.matrix.d = scale;
            this.matrix.e = this.padding.left - (scale * this.x) + (w - (scale * this.width)) / 2;
            this.matrix.f = this.padding.top - (scale * this.y);

            return this.matrix;
        }

    });

    swv6.ui.Camera.Position.register('box', swv6.ui.Camera.Position.Box);

}());


(function () {
    /**
     * @class swv6.ui.Camera.Position.Fit
     * @extends swv6.ui.Camera.Position
     * A position for a camera.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Camera.Position.Box;

    CLASS =
        swv6.ui.Camera.Position.Fit =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.el = config.el;
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {swv6.svg.Element} el
         * An SVG element object to fit this position to.
         */
        el: undefined,

        getMatrix: function () {
//            var bbox = this.el.getBBox();

            this.x = this.el.getX();
            this.y = this.el.getY();
            this.width = this.el.getWidth();
            this.height = this.el.getHeight();

            return CLASS.base.getMatrix.apply(this);
        }

    });

    swv6.ui.Camera.Position.register('fit', swv6.ui.Camera.Position.Fit);

}());

/*
(function () {
    /**
     * @class swv6.ui.Camera.Position.Point
     * @extends swv6.ui.Camera.Position
     * A position for a camera.
     * INCOMPLETE.
     * /
    'use strict';
    var CLASS,
        BASE = swv6.ui.Camera.Position;

    CLASS =
        swv6.ui.Camera.Position.Point =
        function (config) {
            // TODO:
            CLASS.base.ctor.apply(this, arguments);

            this.el = config.el;
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {Number} x
         * The x position of the box
         * /
        x: 0,

        /**
         * @cfg {Number} y
         * The y position of the box
         * /
        y: 0,

        /**
         * @cfg {Number} zoom
         * The zoom level for the camera
         * /
        zoom: undefined,

        getMatrix: function () {
            // TODO:
            
            return CLASS.base.getMatrix.apply(this);
        }

    });

    swv6.ui.Camera.Position.register('fit', swv6.ui.Camera.Position.Fit);

}());
*/

(function () {
    /**
     * @class swv6.ui.Camera.Position.Track
     * @extends swv6.ui.Camera.Position
     * A position for a camera, useful for setting a scene element's position in the camera's viewport.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Camera.Position;

    CLASS =
        swv6.ui.Camera.Position.Track =
        function (config) {

            CLASS.base.ctor.apply(this, arguments);

            this.zoom = config.zoom || this.camera.getCurrentZoom();
            this.trackFn = config.trackFn;
        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {Number} zoom
         * The zoom level for the camera (defaults to current zoom)
         */
        zoom: undefined,

        /**
         * Returns the screen location that should be mapped to a viewport location.
         * @return {Object} The screen and viewport positions
         * @return {Object} return.screen The screen coordinates
         * @return {Number} return.screen.x The screen's x coordinate
         * @return {Number} return.screen.y The screen's y coordinate
         * @return {Object} return.viewport The viewport coordinates
         * @return {Number} return.viewport.x The viewport's x coordinate
         * @return {Number} return.viewport.y The viewport's y coordinate
         */
        trackFn: function () {
            return {
                screen: {x: 0, y: 0},
                viewport: {x: 0, y: 0}
            };
        },

        getMatrix: function () {
            var track = this.trackFn(),
                sp = track.screen,   // scene point
                vp = track.viewport; // viewport point

            // Find the matrix that maps the screen position to viewport position.
            this.matrix.a = this.zoom;
            this.matrix.b = 0;
            this.matrix.c = 0;
            this.matrix.d = this.zoom;
            this.matrix.e = vp.x - (sp.x * this.zoom);
            this.matrix.f = vp.y - (sp.y * this.zoom);

            return this.matrix;
            
        }

    });

    swv6.ui.Camera.Position.register('track', swv6.ui.Camera.Position.Track);

}());

(function () {
    /**
     * @class swv6.ui.Camera.Path
     * Path management for a camera.
     */
    'use strict';
    var CLASS,
        BASE = Object,

    CLASS =
        swv6.ui.Camera.Path =
        function (config) {
            this.camera = config.camera;
        };

    swv6.util.inherit(CLASS, BASE, {

        deferred: undefined,
        camera: undefined,
        time: undefined,
        start: undefined,
        finish: undefined,

        /**
         * <p>Adds a position to this path.</p>
         * <p><b>Note:</b> currently paths only accept TWO positions maximum.  If two positions are used, 
         * one must have time: 0.  If only one position is supplied, the start point is assumed to be 
         * current camera position.</p>
         * @param {Object} data An object containing position and time information
         * @param {swv6.ui.Camera.Position} data.position A position for this path
         * @param {Number} data.time A time (in ms) the position should be reached within this path
         */
        addPosition: function (data) {
            var position;

            if (data.position instanceof swv6.ui.Camera.Position) {
                position = data.position;
            } else {
                data.position.camera = this.camera;
                position = swv6.ui.Camera.Position.create(data.position);
            }

            if ((data.time <= 0) && !this.start) {
                this.start = position;
            } else if ((data.time > 0) && !this.finish) {
                this.finish = position;
                this.time = data.time;
            }
            
            return this;
        },

        /**
         * Executes this path.
         * @return {swv6.util.Promise} A promise, providing notification of progress and completion.
         */
        run: function () {
            var that = this,
                now,
                pct;

            if (!this.deferred) {
                this.deferred = new swv6.util.Deferred();

                if (!this.start) {
                    this.start = this.camera.getPosition();
                }
                if (!this.finish) {
                    this.finish = this.camera.getPosition();
                }

                now = Date.now();
                pct = 0;
                delete this.t0; // will be initialized in first call to onInterval.

                this.lastIntervalPct = 0;
                this.interval = setInterval(
                    function () {
                        that.onInterval();
                    },
                    10
                );
                that.onInterval();
            }

            return this.deferred.promise;
        },


        getPosition: function (pct, lastPct) {
            var position,
                cameraPosition = this.camera.getPosition(),
                m0, m1;

            if (pct === 0) {

                position = this.start;

            } else if (pct === 1) {

                position = this.finish;

            } else {

                lastPct = lastPct || 0;

                m0 = cameraPosition.getMatrix();

                if (lastPct <= pct) {
                    pct = (pct - lastPct) / (1 - lastPct);
                    m1 = this.finish.getMatrix();
                } else {
                    // we're running the path in reverse!
                    pct = 1 - (pct / lastPct);
                    m1 = this.start.getMatrix();
                }

                position = this.camera.createPosition({
                    type: 'matrix',
                    a: m0.a + (m1.a - m0.a) * pct,
                    b: m0.b + (m1.b - m0.b) * pct,
                    c: m0.c + (m1.c - m0.c) * pct,
                    d: m0.d + (m1.d - m0.d) * pct,
                    e: m0.e + (m1.e - m0.e) * pct,
                    f: m0.f + (m1.f - m0.f) * pct
                });

            }

            return position;

        },

        // private
        onInterval: function () {
            var now = Date.now(),
                pct, pct2,
                position,
                abort = false,
                halt = false;

            if (!this.t0) {
                // This little nicety ensures we get an event w/ a '0' pct value first,
                //    just because it's sometimes handy.
                this.t0 = Date.now();
                pct = 0;
            } else {
                pct = (now - this.t0) / this.time;

                // if the camera position has been modified by some means outside of this path,
                // terminate this paths actions.
                abort = (this.camera.getTxCount() !== this.lastTxCount);
            }

            if (pct >= 1) {
                pct = 1;
                halt = true;
            }

            if (!abort) {
                position = this.getPosition(pct, this.lastIntervalPct);

                this.camera.setPosition(position);

                this.deferred.notify({
                    pct: pct,
                    position: position
                });

                this.lastIntervalPct = pct;
                this.lastTxCount = this.camera.getTxCount();

            } else {
                halt = true;
            }

            if (halt) {
                this.deferred.resolve(this);
                clearInterval(this.interval);
            }

        }

    });

}());
