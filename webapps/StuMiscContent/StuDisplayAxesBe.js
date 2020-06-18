define('DS/StuMiscContent/StuDisplayAxesBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/StuRenderEngine/StuColor'], function (STU, Behavior, Task) {

    'use strict';


    var DisplayAxesTask = function (iComp) {
        Task.call(this);
        this.comp = iComp;
    };
    DisplayAxesTask.prototype = new Task();
    DisplayAxesTask.prototype.constructor = DisplayAxesTask;
    DisplayAxesTask.prototype.onExecute = function (iExContext) {
        if (this.comp === undefined || this.comp === null) {
            return;
        }
        this.comp.update(iExContext);
    };

    /**
    * Display the local axes of an actor
    *
    * @exports DisplayAxes
    * @class 
    * @constructor
    * @noinstancector
    * @public
    * @extends {STU.Behavior}
    * @memberOf STU
	* @alias STU.DisplayAxes
    */
    var DisplayAxes = function () {
        Behavior.call(this);
        this.name = "DisplayAxes";

        // variables projected from the model
        //public
        /**
         * The delay during which a primitive will be visible on screen.
         *
         * @member
         * @public
         * @type {Number}
         */
        this.lifetime = undefined;

        /**
         * The unit defined for the Period parameter and the Lifetime parameter. (ms or frame)
         *
         * @member
         * @public
         * @type {Number}
         */
        this.period = undefined;

        /**
         * Indicate if the Color parameter will be driven by the actor color
         *
         * @member
         * @public
         * @type {Boolean}
         */
        this.useActorColor = undefined;

        /**
         * Define if the behavior is enabled or not
         *
         * @member
         * @public
         * @type {Boolean}
         */
        this.enabled = undefined;

        /**
         * The primitive color value 
         *
         * @member
         * @public
         * @type {STU.Color}
         */
        this.color = undefined;

        /**
         * Array of boolean which permit to respectively display the X, Y and Z axis.
         *
         * @member
         * @public
         * @type {STU.BooleanXYZ}
         */
        this.displayDirection = null;

        /**
         * The unit defined for the Period parameter and the Lifetime parameter. (ms or frame)
         *
         * @member
         * @public
         * @type {STU.DisplayAxes.eTimeUnit}
         */
        this.timeUnit = 0;

        /**
         * Define if the primitives scale will be driven by the Scale parameter or by the Size On Screen parameter.
         * (0 : Fixed scale 
         * 1 : Linked To Screen)
         *
         * @member
         * @public
         * @type {STU.DisplayAxes.eScaleMode}
         */
        this.scaleMode = 0;

        /**
         * The primitive size coefficient. It will be multiply by the radius of the actor bounding box.
         *
         * @member
         * @public
         * @type {Number}
         */
        this.scaleValue = 0;

        /**
         * Percentage that define the size of the primitive according to the screen size
         *
         * @member
         * @public
         * @type {Number}
         */
        this.sizeOnScreen = 0;


        // private variables
        this._elapsedTime = 0;
        this._elapsedFrames = 0;
        this.displayDirectionX = true;
        this.displayDirectionY = true;
        this.displayDirectionZ = true;
        this._fixedLength = 1000;
    };

    //==============================================================================
    DisplayAxes.prototype = new Behavior();
    DisplayAxes.prototype.constructor = DisplayAxes;


    /**
    * An enumeration of all the supported scale mode.<br/>
    * It allows to refer in the code to a specific key.
    * @public
    * @enum {number}
    */
    DisplayAxes.eScaleMode = {
        eFixedSize: 0,
        eLinkedToScreen: 1
    };

    /**
     * An enumeration of all the supported time unit.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    DisplayAxes.eTimeUnit = {
        eMilliseconds: 0,
        eFrames: 1
    };

    //==============================================================================

    DisplayAxes.prototype.onActivate = function () {
        STU.Behavior.prototype.onActivate.call(this);
        this.myTask = new DisplayAxesTask(this);
        EP.TaskPlayer.addTask(this.myTask);

        //this._fixedLength = this.actor.getBoundingSphere().getRadius() / this.actor.getScale();
        // IBS getBoundingSphere with iRef
        this._fixedLength = this.actor.getBoundingSphere("World").getRadius();
        /*var p = this.actor.getParent();
        if (p !== null && p !== undefined && p instanceof STU.Actor3D) {
            var parentScale = p.getScale("World");
            this._fixedLength *= parentScale;
        }*/
    };

    //==============================================================================

    DisplayAxes.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.myTask);
        STU.Behavior.prototype.onDeactivate.call(this);
    };

    DisplayAxes.prototype.update = function (iContext) {
        if (!this.enabled) {
            return;
        }

        var t = this.getActor().getTransform("World");

        var dir = t.matrix.getFirstColumn().normalize();
        var right = t.matrix.getSecondColumn().normalize();
        var up = t.matrix.getThirdColumn().normalize();

        if (this.timeUnit == DisplayAxes.eTimeUnit.eMilliseconds) {
            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedTime >= this.period) {
                this._elapsedTime = 0;
            }

            if (this._elapsedTime == 0) {
                if (this.displayDirection.x) {
                    this.createAxes(dir, new STU.Color(255, 0, 0), this.lifetime);
                }
                if (this.displayDirection.y) {
                    this.createAxes(right, new STU.Color(0, 255, 0), this.lifetime);
                }
                if (this.displayDirection.z) {
                    this.createAxes(up, new STU.Color(0, 0, 255), this.lifetime);
                }                
            }
            
            this._elapsedTime += iContext.deltaTime;            
        }
        else if (this.timeUnit == DisplayAxes.eTimeUnit.eFrames) {
            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedFrame >= this.period) {
                this._elapsedFrame = 0;
            }

            if (this._elapsedFrames == 0) {
                var _lifetime = this.lifetime * (iContext.deltaTime);
                if (this.displayDirection.x) {
                    this.createAxes(dir, new STU.Color(255, 0, 0), _lifetime);
                }
                if (this.displayDirection.y) {
                    this.createAxes(right, new STU.Color(0, 255, 0), _lifetime);
                }
                if (this.displayDirection.z) {
                    this.createAxes(up, new STU.Color(0, 0, 255), _lifetime);
                }                
            }
            
            this._elapsedFrames++;            
        }

    };

    DisplayAxes.prototype.createAxes = function (iDirection, iColor, iLifetime) {
        var actorTransform = this.actor.getTransform("World");
        var rm = STU.RenderManager.getInstance();
        if (this.scaleMode === DisplayAxes.eScaleMode.eFixedSize) {
            //var _length = this.actor.getBoundingSphere().getRadius() * 1;
            if (this._fixedLength <= 0 || this.actor instanceof STU.PointActor) { // In case of empty 3DActor or PointActor
                this._fixedLength = 1000;
            }
            rm._createVector({ length: this._fixedLength * this.scaleValue, startPoint: actorTransform.vector, direction: iDirection, color: iColor, lifetime: iLifetime });
        }
        else if (this.scaleMode === DisplayAxes.eScaleMode.eLinkedToScreen) {
            //rm._createVector({ length: (this.sizeOnScreen * rm.getViewerSize().y * 1 / rm.getPixelDensity()) / 100, screenSize: 1, position: actorTransform, direction: iDirection, color: iColor, lifetime: this.lifetime });
            var _length = (this.sizeOnScreen * rm.getViewerSize().y * 1 / rm.getPixelDensity()) / 100;
            rm._createVector({ length: _length, screenSize: 1, startPoint: actorTransform.vector, direction: iDirection, color: iColor, lifetime: iLifetime });
        }
    };

    // Expose in STU namespace.
    STU.DisplayAxes = DisplayAxes;

    return DisplayAxes;
});

define('StuMiscContent/StuDisplayAxesBe', ['DS/StuMiscContent/StuDisplayAxesBe'], function (DisplayAxes) {
    'use strict';

    return DisplayAxes;
});
