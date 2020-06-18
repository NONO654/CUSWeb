/*
* @quickReview IBS 18:04:18 ajustement gestion position/referential pour globe (IR-586334)
*/
define('DS/StuMiscContent/StuDisplayPositionBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'DS/StuVirtualObjects/StuPointActor'], function (STU, Behavior, Task, EP) {

    'use strict';

    var DisplayPositionTask = function (iComp) {
        Task.call(this);
        this.comp = iComp;
    };
    
    DisplayPositionTask.prototype = new Task();
    DisplayPositionTask.prototype.constructor = DisplayPositionTask;
    DisplayPositionTask.prototype.onExecute = function (iExContext) {
        if (this.comp === undefined || this.comp === null) {
            return;
        }
        this.comp.update(iExContext);
    };

    /**
    * Display the position of an actor using sphere primitive
    *
    * @exports DisplayPosition
    * @class 
    * @constructor
    * @noinstancector
    * @public
    * @extends {STU.Behavior}
    * @memberOf STU
	* @alias STU.DisplayPosition
    */
    var DisplayPosition = function () {
        Behavior.call(this);
        this.name = "DisplayPosition";

        // private variables
        this._elapsedTime = 0;
        this._elapsedFrame = 0;
        this._fixedLength = 1000;

        // variables projected from the model

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
        * The primitive opacity value. From 0 to 255.
        *
        * @member
        * @public
        * @type {Number}
        */
        this.opacity = 0;

        /**
        * The unit defined for the Period parameter and the Lifetime parameter. (ms or frame)
        *
        * @member
        * @public
        * @type {STU.DisplayPosition.eTimeUnit}
        */
        this.timeUnit = 0;

        /**
        * Define if the primitives scale will be driven by the Scale parameter or by the Size On Screen parameter.
        * 0 : Fixed scale 
        * 1 : Linked To Screen
        *
        * @member
        * @public
        * @type {STU.DisplayPosition.eScaleMode}
        */
        this.scaleMode = 0;

        /**
        * The primitive size coefficient. It will be multiply by the radius of the actor bounding box.
        *
        * @member
        * @public
        * @type {Number}
        */
        this.scaleValue = 500;

        /**
        * Percentage that define the size of the primitive according to the screen size
        *
        * @member
        * @public
        * @type {Number}
        */
        this.sizeOnScreen = 0;

    };

    //==============================================================================
    DisplayPosition.prototype = new Behavior();
    DisplayPosition.prototype.constructor = DisplayPosition;

    /**
     * An enumeration of all the supported scale mode.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    DisplayPosition.eScaleMode = {
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
    DisplayPosition.eTimeUnit = {
        eMilliseconds: 0,
        eFrames: 1
    };

    //==============================================================================

    DisplayPosition.prototype.onActivate = function () {
        STU.Behavior.prototype.onActivate.call(this);
        this.myTask = new DisplayPositionTask(this);
        EP.TaskPlayer.addTask(this.myTask);

		// IBS getBoundingSphere with iRef
        this._fixedLength = this.actor.getBoundingSphere("World").getRadius() * 1;
        if (this._fixedLength <= 0 || this.actor instanceof STU.PointActor) { // In case of empty 3DActor or PointActor
            this._fixedLength = 1000;
        }

        /*var p = this.actor.getParent();
        if (p !== null && p !== undefined && p instanceof STU.Actor3D) {
            var parentScale = p.getScale("World");
            this._fixedLength *= parentScale;
        }*/
    };

    //==============================================================================

    DisplayPosition.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.myTask);
        STU.Behavior.prototype.onDeactivate.call(this);
    };


    DisplayPosition.prototype.update = function (iContext) {
        if (!this.enabled) {
            return;
        }

        // [IR-460688] extract only position from actor transform, to avoid unwanted rescaling        
        var pos = this.getActor().getPosition("World");
        var transform = new DSMath.Transformation();
        transform.setVector(pos.x, pos.y, pos.z);
                

        var _alpha = this.opacity;
        var color = this.color;
        if (this.useActorColor) {
            color = this.actor.color;
        }

        if (this.timeUnit === 0) { //milliseconds            

            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedTime >= this.period) {
                this._elapsedTime = 0;
            }

            if (this._elapsedTime == 0) {
                this.createPrimitive(transform, this._fixedLength * this.scaleValue, color, _alpha, this.lifetime);                
            }
            
            this._elapsedTime += iContext.deltaTime;
            
        }
        else if (this.timeUnit === 1) { // frames

            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedFrame >= this.period) {
                this._elapsedFrame = 0;
            }

            if (this._elapsedFrame == 0) {
                var _lifetime = this.lifetime * iContext.deltaTime;
                this.createPrimitive(transform, this._fixedLength * this.scaleValue, color, _alpha, _lifetime);                
            }
            
            this._elapsedFrame++;
            
        }
    };

    DisplayPosition.prototype.createPrimitive = function (iTransform, iRadius, iColor, iAlpha, iLifetime) {
        var rm = STU.RenderManager.getInstance();
        if (this.scaleMode === 0) {
            rm._createSphere({ position: iTransform, referential: "World", color: iColor, alpha: iAlpha, size: 0, radius: iRadius, lifetime: iLifetime });
        }
        else {
            rm._createPoint({ position: iTransform, referential: "World", color: iColor, alpha: iAlpha, size: (this.sizeOnScreen * rm.getViewerSize().y * 1 / rm.getPixelDensity() * 0.5) / 100, lifetime: iLifetime });
        }
    };

    DisplayPosition.prototype.lerp = function (iMin, iMax, iVal) {
        var t_ = 1 - iVal;
        var value = t_ * iMin + iVal * iMax;
        return value;
    };

    // Expose in STU namespace.
    STU.DisplayPosition = DisplayPosition;

    return DisplayPosition;
});

define('StuMiscContent/StuDisplayPositionBe', ['DS/StuMiscContent/StuDisplayPositionBe'], function (DisplayPosition) {
    'use strict';

    return DisplayPosition;
});
