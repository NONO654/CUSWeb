define('DS/StuMiscContent/StuDisplayVolumeBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef', 'DS/StuVirtualObjects/StuPointActor',
	'DS/StuVirtualObjects/StuPathActor'], function (STU, Behavior, Task, EP, DSMath) {

    'use strict';

    var DisplayVolumeTask = function (iComp) {
        Task.call(this);
        this.comp = iComp;
    };
    DisplayVolumeTask.prototype = new Task();
    DisplayVolumeTask.prototype.constructor = DisplayVolumeTask;
    DisplayVolumeTask.prototype.onExecute = function (iExContext) {
        if (this.comp === undefined || this.comp === null) {
            return;
        }
        this.comp.update(iExContext);

    };

    /**
    * Display the Bounding Sphere/Box of an actor
    *
    * @exports DisplayVolume
    * @class 
    * @constructor
    * @noinstancector
    * @public
    * @extends {STU.Behavior}
    * @memberOf STU
	* @alias STU.DisplayVolume
    */
    var DisplayVolume = function () {
        Behavior.call(this);
        this.name = "DisplayVolume";

        // private variables
        this._elapsedTime = 0;
        this._elapsedFrames = 0;
        this._BBoxInfo = 0;

        // variables projected from the model

        /**
        * The delay during which a primitive will be visible on screen (in frame or ms according to the timeUnit parameter).
        *
        * @member
        * @public
        * @type {Number}
        */
        this.lifetime = undefined;

        /**
        * Time that represents the interval between the creations of two visual primitive (in frame or ms according to the timeUnit parameter). 
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
        * The shape of the volume (0: Box, 1: Sphere)
        *
        * @member
        * @public
        * @type {STU.DisplayVolume.eShape}
        */
        this.volumeShape = 0;

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
        * 0: Milliseconds, 1: Frames
        *
        * @member
        * @public
        * @type {STU.DisplayVolume.eTimeUnit}
        */
        this.timeUnit = 0;

    };

    //==============================================================================
    DisplayVolume.prototype = new Behavior();
    DisplayVolume.prototype.constructor = DisplayVolume;


    /**
     * An enumeration of all the supported time unit.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    DisplayVolume.eTimeUnit = {
        eMilliseconds: 0,
        eFrames: 1
    };

    /**
     * An enumeration of all the supported shape to display.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    DisplayVolume.eShape = {
        eBox: 0,
        eSphere: 1
    };

    //==============================================================================

    DisplayVolume.prototype.onActivate = function () {
        STU.Behavior.prototype.onActivate.call(this);
        this.myTask = new DisplayVolumeTask(this);
        EP.TaskPlayer.addTask(this.myTask);

        if (this.actor instanceof STU.PathActor) {
            this._BBoxInfo = this.computePathBBox();
        }

        //var t = this.actor.getTransform().clone();
        //this.actor.getTransform().setRotationFromEuler([0,0,0]);
        /*console.log(this.actor.name);
        console.log(this.actor.getTransform().matrix.coef);
        console.log(this.actor.getParent().getTransform().matrix.coef);
        console.log(DSMath.Matrix3x3.multiply(this.actor.getTransform().matrix, this.actor.getParent().getTransform().matrix).coef);
        console.log("===========================================");*/
        //this.actor.setTransform(t);
    };

    //==============================================================================

    DisplayVolume.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.myTask);
        STU.Behavior.prototype.onDeactivate.call(this);
    };

    DisplayVolume.prototype.update = function (iContext) {
        if (!this.enabled) {
            return;
        }

        //var actor = this.getActor();
        this.lifetime = this.lifetime < 0 ? -1 : this.lifetime;

        if (this.timeUnit === DisplayVolume.eTimeUnit.eMilliseconds) {
            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedTime >= this.period) {
                this._elapsedTime = 0;
            }

            if (this._elapsedTime == 0) {
                this.createVolume(this.lifetime);
            }

            this._elapsedTime += iContext.deltaTime;

        }
        else if (this.timeUnit === DisplayVolume.eTimeUnit.eFrames) {
            // [IR-460727] when period is set, displaying at t0, then t+period
            if (this._elapsedFrame >= this.period) {
                this._elapsedFrame = 0;
            }

            if (this._elapsedFrames == 0) {
                this.createVolume(this.lifetime * iContext.deltaTime);
            }

            this._elapsedFrames++;
        }
    };

    DisplayVolume.prototype.createVolume = function (iLifetime) {
        if (iLifetime === null || iLifetime === undefined) {
            console.error();
            return;
        }

        var rm = STU.RenderManager.getInstance();
        var actor = this.getActor();

        // removing scale from transfo, because already present in bounding 
        // parameters
        var actorTransform = actor.getTransform("World").clone();
        var actorScale = actor.getScale();
        //transform.matrix.multiplyScalar(1 / scale);


        // [IR-461056] reuse actor color when asked
        var col;
        if (this.useActorColor) {
            col = this.getActor().color;
        }
        else {
            col = this.color;
        }

        if (this.volumeShape === DisplayVolume.eShape.eSphere) {
            var radius = 100;
            var newTransform = new DSMath.Transformation();
            // [IR-460698] display volume for Path, Point and empty Actors
            if (this.actor instanceof STU.PointActor) {
                newTransform.vector = this.actor.getPosition();
            }
                // [IR-460698] display volume for Path, Point and empty Actors
            else if (this.actor instanceof STU.PathActor) {
                newTransform.vector = this._BBoxInfo.center;
                radius = this._BBoxInfo.diameter * 0.5;
            }
            else {
				// IBS getBoundingSphere with iRef
                var bs = actor.getBoundingSphere("Parent");
                if (bs.radius > 0) {
                    radius = bs.radius;
                }

                //in case that local axis != world axis
                newTransform.vector = new DSMath.Vector3D(bs.center.x, bs.center.y, bs.center.z);
            }

            // [IR-470944] Applying parent transform
            var p = this.actor.getParent();
            if (p !== null && p !== undefined && p instanceof STU.Actor3D) {
                var transform = this.actor.getTransform(p);
                var e = transform.getEuler();
                var euler = new DSMath.Vector3D(e[1], e[2], e[0]);
                var rot = DSMath.Matrix3x3.makeRotationFromEuler([euler.z, euler.x, euler.y]);
                rot.inverse();
                var m = actorTransform.matrix.clone();
                m.multiplyScalar(1 / this.actor.getScale(p));
                //console.log(this.actor.getScale(p));
                var mF = DSMath.Matrix3x3.multiply(m, rot);
                newTransform.vector.applyMatrix3x3(mF);
                //===================================================

                //var t = p.getTransform().clone();
                //newTransform.vector.applyTransformation(t);

                newTransform.multiply(p.getTransform("World").clone());
                //newTransform.vector.multiplyScalar(1/this.actor.getScale("World"));
                //console.log(newTransform.vector);

                //var t = p.getTransform().clone();
                //newTransform.vector.applyTransformation(t);
            }
            rm._createSphere({ radius: radius, position: newTransform, color: col, alpha: this.opacity, lifetime: iLifetime });
        }

        if (this.volumeShape === DisplayVolume.eShape.eBox) {
            // [IR-460698] display volume for Path, Point and empty Actors 
            if (this.actor instanceof STU.PointActor) {
                var bSize = new DSMath.Vector3D(100, 100, 100);
                rm._createBox({ size: bSize, color: col, alpha: this.opacity, lifetime: iLifetime, closed: 1, position: this.actor.getTransform() });
            }
                // [IR-460698] display volume for Path, Point and empty Actors
            else if (this.actor instanceof STU.PathActor) {
                rm._createBox({ box: this._BBoxInfo.Bbox, color: col, alpha: this.opacity, lifetime: iLifetime, closed: 1, position: this.actor.getTransform() });
            }
            else {
                var MyTransfo = this.actor.getTransform("World");
                var MyParams = { excludeChildren: 0, orientation: MyTransfo };
                var MyBBox = this.actor.getOrientedBoundingBox(MyParams);
                if (MyBBox.high.isEqual(MyBBox.low, 0.0001)) {
                    var bSize = new DSMath.Vector3D(100, 100, 100);
                    rm._createBox({ size: bSize, color: col, alpha: this.opacity, lifetime: iLifetime, closed: 1, position: MyTransfo });
                }
                else {
                    rm._createBox({ box: MyBBox, color: col, alpha: this.opacity, lifetime: iLifetime, closed: 1, position: MyTransfo });
                }
            }
        }
    };

    DisplayVolume.prototype.computePathBBox = function () {
        var BBox = new STU.Box;
        var listspoint = this.actor.pointslist;
        BBox.high = new DSMath.Point(listspoint[0].position[0], listspoint[0].position[1], listspoint[0].position[2]);
        BBox.low = BBox.high.clone();

        for (var i = 0; i < listspoint.length; i++) {
            if (listspoint[i].position[0] > BBox.high.x) {
                BBox.high.x = listspoint[i].position[0];
            }
            if (listspoint[i].position[0] < BBox.low.x) {
                BBox.low.x = listspoint[i].position[0];
            }

            if (listspoint[i].position[1] > BBox.high.y) {
                BBox.high.y = listspoint[i].position[1];
            }
            if (listspoint[i].position[1] < BBox.low.y) {
                BBox.low.y = listspoint[i].position[1];
            }

            if (listspoint[i].position[2] > BBox.high.z) {
                BBox.high.z = listspoint[i].position[2];
            }
            if (listspoint[i].position[2] < BBox.low.z) {
                BBox.low.z = listspoint[i].position[2];
            }
        }

        if (BBox.high.x === BBox.low.x) {
            BBox.high.x += 10;
            BBox.low.x -= 10;
        }
        if (BBox.high.y === BBox.low.y) {
            BBox.high.y += 10;
            BBox.low.y -= 10;
        }
        if (BBox.high.z === BBox.low.z) {
            BBox.high.z += 10;
            BBox.low.z -= 10;
        }

        var center = new DSMath.Vector3D(BBox.low.x, BBox.low.y, BBox.low.z);
        center.add(new DSMath.Vector3D(BBox.high.x, BBox.high.y, BBox.high.z));
        center.multiplyScalar(0.5);
        center.add(this.actor.getPosition());

        var d = new DSMath.Vector3D(BBox.high.x, BBox.high.y, BBox.high.z);
        d.sub(new DSMath.Vector3D(BBox.low.x, BBox.low.y, BBox.low.z));
        var diameter = d.norm();

        return { Bbox: BBox, center: center, diameter: diameter };
    };

    // Expose in STU namespace.
    STU.DisplayVolume = DisplayVolume;

    return DisplayVolume;
});

define('StuMiscContent/StuDisplayVolumeBe', ['DS/StuMiscContent/StuDisplayVolumeBe'], function (DisplayVolume) {
    'use strict';

    return DisplayVolume;
});
