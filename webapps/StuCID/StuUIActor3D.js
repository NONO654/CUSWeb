define('DS/StuCID/StuUIActor3D', ['DS/StuCore/StuContext',
                                   'DS/StuRenderEngine/StuActor3D'], function (STU, Actor3D) {
    'use strict';

    var geterSeter = function (self, varName) {
        if (!STU.isEKIntegrationActive()) {
            Object.defineProperty(self, varName, {
                enumerable: true,
                configurable: true,
                get: function () {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        return self.CATI3DExperienceObject.GetValueByName(varName);
                    }
                },
                set: function (value) {
                    if (self.CATI3DExperienceObject !== undefined && self.CATI3DExperienceObject !== null) {
                        self.CATI3DExperienceObject.SetValueByName(varName, value);
                    }
                }
            });
        }
    };

    /**
    * Describes the base actor for all 3D UI Actors.
    * This class proposes properties and functions common to all 3D UI Actors.
    *
	* @exports UIActor3D
	* @class
	* @constructor
	* @noinstancector 
	* @public
	* @extends STU.Actor3D
	* @memberof STU
	* @alias STU.UIActor3D
	*/
    var UIActor3D = function () {

        Actor3D.call(this);
        this.name = 'UIActor3D';
        this.CATICXP3DUIActor;

        /**
        * Get/Set width
        *
        * @member
        * @instance
        * @name width
        * @public
        * @type {number}
        * @memberOf STU.UIActor3D
        */
        geterSeter(this, "width");


        /**
        * Get/Set height
        *
        * @member
        * @instance
        * @name height
        * @public
        * @type {number}
        * @memberOf STU.UIActor3D
        */
        geterSeter(this, "height");

        /**
        * Get/Set enabled
        *
        * @member
        * @instance
        * @name enabled
        * @public
        * @type {boolean}
        * @memberOf STU.UIActor3D
        */
        geterSeter(this, "enabled");

        /**
        * A 3D UI Actor has no color. <br/>
        * Changing this property will have no effect
        *
        * @public
        * @member
        * @instance
        * @type {STU.Color}
        */
        this.color;

        /**
        * A 3D UI Actor has no property clickable. <br/>
        * Changing this property will have no effect
        *
        * @public
        * @member
        * @instance
        * @type {boolean}
        * @see STU.UIActor3D#enabled
        */
        this.clickable;

    };

    UIActor3D.prototype = new Actor3D();
    UIActor3D.prototype.constructor = UIActor3D;
    UIActor3D.prototype.featureCatalog = 'CXP3DUIActor_Spec.feat';
    UIActor3D.prototype.featureStartup = 'CXP3DUIActor_Spec';

    UIActor3D.prototype.onInitialize = function () {
        Actor3D.prototype.onInitialize.call(this);
        if (this.CATICXP3DUIActor !== null && this.CATICXP3DUIActor !== undefined) {
            this.CATICXP3DUIActor.setESObject(this);
        }
    };

    UIActor3D.prototype.doUIDispatchEvent = function (iEventName, params) {
        var event;
        if (params == null || params === undefined) {
            event = new STU[iEventName]();
        } else {
            event = new STU[iEventName](params);
        }
        if (event !== undefined) {
            this.dispatchEvent(event);
        }
    };

    /** 
    * @method
    * @private
    * @see STU.UIActor3D#enable
    */
    UIActor3D.prototype.isEnabled = function () {
        return this.enabled;
    }

    /**
    * Disables this STU.UIActor3D.
    *
    * @method
    * @private
    * @see STU.UIActor3D#enable
    */
    UIActor3D.prototype.disables = function () {
        this.enabled = false;
    };

    /**
    * Enables this STU.UIActor3D.
    *
    * @method
    * @private
    * @see STU.UIActor3D#enable
    */
    UIActor3D.prototype.enables = function () {
        this.enabled = true;
    };

    // Expose in STU namespace.
    STU.UIActor3D = UIActor3D;

    return UIActor3D;
});

define('StuCID/StuUIActor3D', ['DS/StuCID/StuUIActor3D'], function (UIActor3D) {
    'use strict';

    return UIActor3D;
});
