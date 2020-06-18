define('DS/StuMiscContent/StuExplodeBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPEventServices/EPEvent', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef', 'DS/EPInputs/EPKeyboard'], function (STU, Behavior, Event, Task, EP, DSMath) {
    'use strict';

    var globalVariable = true;

    //Explode task definition

    var ExplodeTask = function (iExplode) {

        Task.call(this);

        this.comp = iExplode;

    };

    ExplodeTask.prototype = new Task();
    ExplodeTask.prototype.constructor = ExplodeTask;

    /**
	 * Explode a product by driving the product's children (in the hierarchy) away from the exploding center
	 *
	 * @exports Explode
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends {STU.Behavior}
	 * @memberOf STU
	 * @alias STU.Explode
	 */
    var Explode = function () {

        Behavior.call(this);

        this.componentInterface = this.protoId;

        this.name = "Explode";
        /**
		 * Method of activation of task (mouse click/keyboard/no activation)
		 *
		 * @member
		 * @public
		 * @type {STU.Explode.eActivateOn}
		 */
        this.activateOn = 0;

        /**
		 * Mapped key for keyboard activation.
		 *
		 * @member
		 * @public
		 * @type {EP.Keyboard.EKey}
		 */
        this.activationKey = EP.Keyboard.EKey.eE;

        /**
		 * Filter collections
		 *
		 * @member
		 * @public
		 * @type {STU.Collection}
		 */
        this.impactedObjects = null;

        /**
		 * Explode center given by user(Generally empty Actor3D)
		 *
		 * @member
		 * @public
		 * @type {STU.Actor3D}
		 */
        this.explodeCenter = null;

        /**
		 * Type of mode (Linear / Spherical)
		 *
		 * @member
		 * @private
		 * @type {enum}
		 */
        this.mode = 0;

        /**
		 * Type of linearMode (OneSide / BothSide)
		 *
		 * @member
		 * @public
		 * @type {STU.Explode.eLinearMode}
		 */
        this.linearMode = 0;

        /**
		 * Type of Linear Direction (Positive / Negative)
		 *
		 * @member
		 * @private
		 * @type {enum}
		 */
        this.linearDirection = 0;

        /**
		 * Axis of reference
		 * 0: X axis, 1: -X axis, 2: Y axis, 3: -Y axis, 4: Z axis, 5: -Z axis
		 * @member
		 * @public
		 * @type {STU.Explode.eAxis}
		 */
        this.directionAxis = 0;

        /**
		 * Total duration of explode
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
        this.duration = 5;

        /**
		 * Total distance of explode(maximum distance part will reach at this distance)
		 *
		 * @member
		 * @public
		 * @type {number}
		 */
        this.distanceFactor = 3.0;
        this.distance = 300;

        /**
		 * The coordinate reference used for the direction axis
		 *
		 * @member
		 * @public
		 * @type {STU.Explode.eReference}
		 */
        this.reference = 0;

        //########################################################################
        // PRIVATE
        //########################################################################

        /**
		 * State to maintain forward explode or reverse explode
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.state = 0;

        /**
		 * Capacity variable to know whether explode is started or not
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.isExplode = false;

        /**
		 * Array of parse assembly
		 *
		 * @member
		 * @private
		 * @type {array}
		 */
        this.elmts = [];

        /**
		 * Axis of explode (in case of linear mode)
		 *
		 * @member
		 * @private
		 * @type {vector}
		 */
        this.axisTranslation = 0;

        /**
		 * Maximum distance part from explode center
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.maximumDistance = 0.0;

        /**
		 * Maximum negative distance part from explode center
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.maxNegDistance = 0.0;

        /**
		 * Maximum positive distance part from explode center
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.maxPosDistance = 0.0;

        /**
		 * Total number of parts in the assembly
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.count = 0;

        /**
		 * Check first element is root ot not
		 *
		 * @member
		 * @private
		 * @type {boolean}
		 */
        this.root = true;

        /**
		 * Stores the real center of explosion
		 *
		 * @member
		 * @private
		 * @type {STU.Actor3D}
		 */
        this.rootActorCentre;

        /**
		 * Speed at which maximum distance part from center will explode
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.speed = 0.0;

        /**
		 * Position of maximum distance part at any instant from its original position
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.currentValue = 0.0;

        /**
		 * Time per frame
		 *
		 * @member
		 * @private
		 * @type {number}
		 */
        this.currentTime = 0.0;

        /**
		 * To change the direction of explosion
		 *
		 * @member
		 * @private
		 * @type {boolean}
		 */
        this.reverseDirection = false;

        /**
		 * For has explode ended capacity
		 *
		 * @member
		 * @private
		 * @type {boolean}
		 */
        this.explodeEnded = false;

        /**
		 * Array to store the normalization value each time
		 *
		 * @member
		 * @private
		 * @type {array}
		 */
        this.finalArr = [];
    };

    Explode.prototype = new Behavior();
    Explode.prototype.constructor = Explode;

    /**
     * An enumeration of all the supported direction axis.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public 
     */
    Explode.eAxis = {
        eXPositive: 0,
        eXNegative: 1,
        eYPositive: 2,
        eYNegative: 3,
        eZPositive: 4,
        eZNegative: 5,
    };

    /**
     * An enumeration of all the supported direction for the linear mode.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    Explode.eLinearMode = {
        eOneSide: 0,
        eBothSide: 1,
    };

    /**
     * An enumeration of all the supported coordinate reference.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    Explode.eActivateOn = {
        eMouseClick: 0,
        eKeyPress: 1,
        eNoActivation: 2,
    };

    /**
     * An enumeration of all the supported coordinate reference.<br/>
     * It allows to refer in the code to a specific key.
     *
     * @enum {number}
     * @public
     */
    Explode.eReference = {
        eLocal: 0,
        eWorld: 1,
    };


    /**
	 * Process to execute when this STU.Explode is activating. 
	 *
	 * @method
	 * @private
	 */
    Explode.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        //add listeners based on input method
        if (this.activateOn === 0) {
            EP.EventServices.addObjectListener(STU.ClickablePressEvent, this, 'onClickablePress');
        }
        else if (this.activateOn === 1) {
            EP.EventServices.addObjectListener(EP.KeyboardPressEvent, this, 'onKeyboardEvent');
        }

        this.associatedTask = new ExplodeTask(this);

        var positiveAxis = (this.directionAxis === Explode.eAxis.eXPositive) || (this.directionAxis === Explode.eAxis.eYPositive) || (this.directionAxis === Explode.eAxis.eZPositive);
        this.linearDirection = positiveAxis ? 0 : 1;

        if (this.impactedObjects) {	//If collection is present, parse collection first
            this.parseCollectionHierarchy(this.impactedObjects, this.elmts);
        }
        else {						// If collection is not present

            /**
			* parseHierarchyLinear method consider the hierarchy of all the elments
			* parseHierarchy method doesn't bother about the hierarchy of the elements
			*/
            if (this.mode === 0) {
                this.parseHierarchyLinear(this.getActor(), this.elmts);	//For linear mode
            }

        }

        /**
		 * rootActorCentre will be explode centre of defined by user
		 * default will be bounding box sphere center of root
		 */

        if (!this.explodeCenter) {
            var bSphere = this.getActor().getBoundingSphere();
            this.distance = (bSphere.getRadius() * this.distanceFactor) - bSphere.getRadius();
            this.rootActorCentre = bSphere.getCenter();
        }
        else {
            var bSphere = this.explodeCenter.getBoundingSphere();
            this.distance = (bSphere.getRadius() * this.distanceFactor) - bSphere.getRadius();
            this.rootActorCentre = bSphere.getCenter();
        }

        if (this.reference === Explode.eReference.eWorld) {
            if (this.directionAxis === 0 || this.directionAxis === 1) {
                this.axisTranslation = new DSMath.Vector3D(1, 0, 0);
                //this.axisTranslation.x = 1;
            }
            else if (this.directionAxis === 2 || this.directionAxis === 3) {
                this.axisTranslation = new DSMath.Vector3D(0, 1, 0);
                //this.axisTranslation.y = 1;
            }
            else if (this.directionAxis === 4 || this.directionAxis === 5) {
                this.axisTranslation = new DSMath.Vector3D(0, 0, 1);
                //this.axisTranslation.z = 1;
            }
        }
        else {
            var parent = this.getActor().getParent();
            var matrix = this.getActor().getTransform(parent).matrix;
            if (this.directionAxis === 0 || this.directionAxis === 1) {
                this.axisTranslation = matrix.getFirstColumn();
            }
            else if (this.directionAxis === 2 || this.directionAxis === 3) {
                this.axisTranslation = matrix.getSecondColumn();
            }
            else if (this.directionAxis === 4 || this.directionAxis === 5) {
                this.axisTranslation = matrix.getThirdColumn();
            }
        }


        /**
		 * Calculation of distance for each parts from explode center
		 * 
		 * For each mode we are calculating factor, by which that part will explode
		 *
		 * For linear mode
		 * elmts array is sorted according to distance of each part
		 * maximumDistance will be the max distance part from explode center
		 *
		 * For Spherical mode
		 * We have divided sphere according to each segment of 45 degree in horizontal direction and full vertical.
		 * Currently circle will have 8 such segment, we can increase the no of segments for better accuracy and result later.
		 * In that strip, we are calculating maximum distance part in that region
		 * Giving a factor to each part by which they should explode(uniform factor)
		*/
        this.distanceCalculations(this.axisTranslation, this.elmts);

        //var len = this.elmts.length;
        //for (var elmt in this.elmts) {
        //	console.log("\n working x=" + this.elmts[elmt].localBBCenter.x + "y =" + this.elmts[elmt].localBBCenter.y + "z is" + this.elmts[elmt].localBBCenter.z);

        //	//if ((this.elmts[elmt].localBBCenter.x == 0) && (this.elmts[elmt].localBBCenter.y == 0) && (this.elmts[elmt].localBBCenter.z == 0))
        //	//	this.elmts.splice(parseInt(elmt), 1);
        //}

        if ((this.mode === 0) && (globalVariable === true)) {
            if (this.linearDirection === 1 && this.linearMode === 0) {
                this.elmts.sort(function (a, b) {
                    if (a.distance < b.distance) {
                        return 1;
                    }
                    if (a.distance > b.distance) {
                        return -1;
                    }
                    // a must be equal to b
                    return 0;
                });
                this.maximumDistance = this.elmts[this.count - 1].distance;
            }
            else {
                this.elmts.sort(function (a, b) {
                    if (a.distance > b.distance) {
                        return 1;
                    }
                    if (a.distance < b.distance) {
                        return -1;
                    }
                    // a must be equal to b
                    return 0;
                });
                this.maximumDistance = this.elmts[this.count - 1].distance;
            }
        }

        // calculating and giving factor for both side case in linear mode
        if ((this.mode === 0) && (globalVariable === true) && (this.linearMode === 1)) {
            this.maxNegDistance = this.elmts[0].distance;	//Maximum negative Distance
            this.maxPosDistance = this.elmts[this.count - 1].distance;	//Maximum positive Distance

            if (this.maxNegDistance < 0) {
                this.maxNegDistance = this.maxNegDistance * (-1);
            }

            if (this.maxPosDistance < 0) {
                this.maxPosDistance = this.maxPosDistance * (-1);
            }

            if (this.maxNegDistance > this.maxPosDistance) {
                this.maximumDistance = this.maxNegDistance;
            }
            else {
                this.maximumDistance = this.maxPosDistance;
            }


            if ((this.maximumDistance === 0) && (this.maxPosDistance === 0) && (this.maxNegDistance === 0)) {
                this.maximumDistance = 1;
                this.maxPosDistance = 1;
                this.maxNegDistance = 1;
            }

            var pos = 0;
            var neg = this.negCount.count;
            for (var i = 0; i < this.elmts.length; i++) {
                if (this.elmts[i].distance < 0) {
                    this.elmts[i].factor = (neg-- / this.negCount.count) * (this.maxNegDistance / this.maximumDistance);
                }
                else {
                    pos++;
                    this.elmts[i].factor = (pos / this.posCount.count) * (this.maxPosDistance / this.maximumDistance);
                }
            }

        }

        // Factor allocation for linear mode with oneside case
        if ((this.mode === 0) && (this.linearMode === 0)) {
            for (var i = 0; i < this.elmts.length; i++) {
                this.elmts[i].factor = (i + 1) / this.count;
            }
        }

        if ((this.mode === 0) && (this.linearMode === 0) && (this.linearDirection === 1)) {
            this.axisTranslation.x *= (-1);
            this.axisTranslation.y *= (-1);
            this.axisTranslation.z *= (-1);
        }

    };

    /**
	 * Callback called on a mouse click
	 * Also taking account the click on any of the children of the hierarchy root
	 * @method
	 * @private
	 */
    Explode.prototype.onClickablePress = function (iEvent) {
        var thisActor = iEvent.getActor();
        var parent = thisActor.getParent();

        // If click on any of children, than reach to hierarchy
        if (thisActor !== this.getActor()) {
            while (parent !== null && parent !== undefined && parent !== this.getActor()) {
                parent = parent.getParent();
            }
        }
        if (parent) {
            if (this.state === 0) {
                this.state = 1;
                this.reverseDirection = false;
                EP.TaskPlayer.addTask(this.associatedTask);
                this.associatedTask.start();
                this.directionChange();
            }
            else {
                this.state = 0;
                this.directionChange();
                this.reverseDirection = true;
            }
        }
    };

    /**
	 * Callback called when a keyboard key is hit
	 * @method
	 * @private
	 */
    Explode.prototype.onKeyboardEvent = function (iKeyboardEvent) {

        if (iKeyboardEvent instanceof EP.KeyboardPressEvent) {
            if (iKeyboardEvent.getKey() === this.activationKey) {
                if (this.state === 0) {
                    this.state = 1;
                    this.reverseDirection = false;
                    EP.TaskPlayer.addTask(this.associatedTask);
                    this.associatedTask.start();
                    this.directionChange();
                }
                else {
                    this.state = 0;
                    this.directionChange();
                    this.reverseDirection = true;
                }
            }
        }
    };

    /**
	 * Callback called when a keyboard key pressed or mouse clicked
	 * Changes current time and current value into just opposite remaining time and reaming value
	 * @method
	 * @private
	 */
    Explode.prototype.directionChange = function () {
        //change time and value to 0 if cycle is completed.
        if (this.currentTime >= this.duration) {
            this.currentTime = 0;
            this.currentValue = 0.0;
            this.explodeEnded = false;
        }
            //if we reverse in between, we have to go back from existing position.
        else if (this.currentTime !== 0) {
            this.currentTime = this.duration - this.currentTime;
            if (this.maximumDistance < 0) {
                if (this.linearDirection === 0) {
                    this.currentValue = (this.distance - this.maximumDistance) - this.currentValue;
                }
                else {
                    this.currentValue = (this.distance + this.maximumDistance) - this.currentValue;
                }
            }
            else {
                this.currentValue = (this.distance - this.maximumDistance) - this.currentValue;
            }
        }
    };

    /**
	 * Parse Hierarchy test
	 * General method for parse of any assembly
	 * Taking account of children as well as hierarchy nodes
	 * @method
	 * @private
	 */
    Explode.prototype.parseHierarchyTest = function (iActor, parseArray) {

        var subActors = iActor.getSubActors();
        var queue = [];

        if (subActors.length !== 0) {
            for (var subActor in subActors) {
                parseArray.push(subActors[subActor]);
                queue.push(subActors[subActor]);
                this.count++;
            }

            var len = queue.length;
            for (var i = 0; i < len; i++) {
                this.parseHierarchyTest(queue[i], parseArray);
            }

            for (var i = 0; i < len; i++) {
                queue.splice(i, 1);
            }
        }
    };

    /**
	 * General method for parse of any assembly
	 * Taking account of children as well as hierarchy nodes
	 * @method
	 * @private
	 */
    Explode.prototype.parseHierarchyLinear = function (iActor, parseArray) {
        var subActors = iActor.getSubActors();
        if (subActors.length === 0) {
            parseArray.push(iActor);
            this.count++;
            return null;
        }
        else {
            if (this.root) {
                this.root = false;
                for (var i = 0; i < subActors.length ; i++) {
                    this.parseHierarchyLinear(subActors[i], parseArray);
                }
            }
            else {
                parseArray.push(iActor);
                this.count++;
                for (var i = 0; i < subActors.length ; i++) {
                    this.parseHierarchyLinear(subActors[i], parseArray);
                }
            }

        }
    };

    /**
	 * Parse method for collection
	 * Does not taking account of children of hierarchy
	 * @method
	 * @private
	 */
    Explode.prototype.parseCollectionHierarchy = function (iCollection, iCollectionArray) {
        var collectionObjects = iCollection.getObjects();
        this.count = iCollection.getObjectCount();
        for (var i = 0; i < this.count; i++) {
            iCollectionArray.push(collectionObjects[i]);
        }
    };


    /**
	 * Method to hide all the children of an element
	 * It is used to calculate the bounding box of an element, not taking account of its children
	 * @method
	 * @private
	 */
    Explode.prototype.hideAndShowVisibility = function (iActor, mode) {
        var subActors = iActor.getSubActors();

        if (subActors.length === 0) {
            return null;
        }
        else {
            for (var i = 0; i < subActors.length; i++) {
                this.hideAndShowVisibility(subActors[i], mode);
                subActors[i].CATI3DXGraphicalProperties.SetShowMode(mode);
            }
        }
    };


    /**
	 * Distance calculation function for each part from center of explode
	 * @method
	 * @private
	 */
    Explode.prototype.distanceCalculations = function (axisVar, distanceArray) {

        function countObject() {
            this.count = 0;
        }

        var sliceAngle = 2 * Math.PI / this.count;

        if ((this.mode === 0) && (this.linearMode === 1)) {	// defined for linear mode wih Both side case
            this.posCount = new countObject();
            this.negCount = new countObject();
        }
        for (var iElmt = 0; iElmt < distanceArray.length; iElmt++) {
            var parent = distanceArray[iElmt].getParent();
            distanceArray[iElmt].initPos = distanceArray[iElmt].getPosition(parent);

            var bb = new STU.Box();
            // hide all the children of element in distanceArray[iElmt]
            this.hideAndShowVisibility(distanceArray[iElmt], 0);

            // Calculation of bounding box of an element
            var absTransfo = distanceArray[iElmt].getTransform(parent);
            distanceArray[iElmt].StuIRepresentation.GetBoundingBox(bb, absTransfo, 0);

            distanceArray[iElmt].localBBCenter = new DSMath.Point();

            distanceArray[iElmt].localBBCenter.set(((bb.high.x + bb.low.x) / 2), ((bb.high.y + bb.low.y) / 2), ((bb.high.z + bb.low.z) / 2));

            // Show all the children of the element in distanceArray[iElmt]
            this.hideAndShowVisibility(distanceArray[iElmt], 1);

            //Distance calculation of Linear Mode
            if (this.mode === 0) {

                distanceArray[iElmt].distance = this.linearBoundaryDistance(distanceArray[iElmt].localBBCenter, this.rootActorCentre, this.axisTranslation);
                if ((this.mode === 0) && (this.linearMode === 1)) {
                    if (distanceArray[iElmt].distance < 0) {
                        this.negCount.count++;
                    }
                    else {
                        this.posCount.count++;
                    }
                }

            }
        }

    };

    /**
	 * Calculate signed distance between part and explode center
	 * @method
	 * @private
	 */
    Explode.prototype.linearBoundaryDistance = function (point, root, axis) {
        return (point.x - root.x) * axis.x + (point.y - root.y) * axis.y + (point.z - root.z) * axis.z;
    };

    /**
	 * Calcualte absolute distance between part and explode center
	 * @method
	 * @private
	 */
    Explode.prototype.boundaryDistance = function (point, root) {
        return Math.sqrt((root.x - point.x) * (root.x - point.x) + (root.y - point.y) * (root.y - point.y) + (root.z - point.z) * (root.z - point.z));
    };

    /**
	 * Calculate the value of theta and phi for each part
	 * Used only for spherical mode
	 * @method
	 * @private
	 */
    Explode.prototype.sphericalDistribution = function (array, elmt, root) {

        var point = array[elmt].localBBCenter;
        var pi = 3.1415926;

        var thetaValue = (Math.atan((root.y - point.y) / (root.x - point.x))) * 180 / Math.PI;
        var phiValue = (Math.atan(Math.sqrt((root.x - point.x) * (root.x - point.x) + (root.y - point.y) * (root.y - point.y)) / (root.z - point.z))) * 180 / Math.PI;

        // NaN is checked for infinity as tan value can be infinity
        if (isNaN(thetaValue)) {
            if ((root.y - point.y) < 0) {
                thetaValue = -90.0;
            }
            else {
                thetaValue = 90.0;
            }
        }

        if (isNaN(phiValue)) {
            phiValue = 90.0;
        }

        array[elmt].distance = Math.sqrt((root.x - point.x) * (root.x - point.x) + (root.y - point.y) * (root.y - point.y) + (root.z - point.z) * (root.z - point.z));
        array[elmt].theta = parseInt(thetaValue);
        array[elmt].phi = parseInt(phiValue);
    };

    /**
	 * Calculate the value of sin theta and costheta of each element
	 * Used only for circle mode
	 * @method
	 * @private
	 */
    Explode.prototype.circleDistribution = function (array, elmt, root, slice) {
        var point = array[elmt].localBBCenter;
        var angle = slice * (parseInt(elmt) + 1);
        array[elmt].distance = Math.sqrt((root.x - point.x) * (root.x - point.x) + (root.y - point.y) * (root.y - point.y) + (root.z - point.z) * (root.z - point.z));
        array[elmt].cosTheta = Math.cos(angle);
        array[elmt].sinTheta = Math.sin(angle);
    };

    /**
	 * Method called at the time of start the task by task manager
	 * @method
	 * @private
	 */
    ExplodeTask.prototype.onStart = function () {
        this.deltaTime = 0.0;
        this.normalizeStep = 0.0;
        this.isExplode = true;

        //variables for showing the bounding box
        if (this.comp.showBoundingBox) {
            this.color = new STU.Color(0, 255, 255);
            this.alpha = 0.5;
        }
    };

    /**
	 * Method called at the time of stopping current task
	 * @method
	 * @private
	 */
    ExplodeTask.prototype.onStop = function () {
        for (var elmt in this.comp.elmts) {
            var parent = this.comp.elmts[elmt].getParent();
            this.comp.elmts[elmt].setPosition(this.comp.elmts[elmt].initPos, parent);
        }
    };

    //Cubic easing function for calculate easing steps
    ExplodeTask.prototype.easeInOutCubic = function (n) {

        var q = 0.48 - n / 1.04;
        var Q = Math.sqrt(0.1734 + q * q);
        var x = Q - q;
        var X = Math.pow(Math.abs(x), 1 / 3) * (x < 0 ? -1 : 1);
        var y = -Q - q;
        var Y = Math.pow(Math.abs(y), 1 / 3) * (y < 0 ? -1 : 1);
        var t = X + Y + 0.5;
        return (1 - t) * 3 * t * t + t * t * t;

    };

    /**
	 * Method called at the time of execution current task
	 * @method
	 * @private
	 * @param  iExContext Execution context
	 */
    ExplodeTask.prototype.onExecute = function (context) {
        this.deltaTime = (context.getDeltaTime() / 1000);

        if (this.comp.currentTime < this.comp.duration) {
            this.comp.currentTime += this.deltaTime;
        }

        var normalizeTime = this.comp.currentTime / this.comp.duration; //time between 0-1
        this.normalizeStep = this.easeInOutCubic(normalizeTime);

        if ((normalizeTime * 100) >= 100.00) {
            this.normalizeStep = 1.00;
        }

        if ((this.comp.reverseDirection === false) && (this.normalizeStep < 1.00)) {
            this.comp.finalArr.push(this.normalizeStep);
        }

        //if (this.comp.mode == 3)
        //	this.motionTask(this.comp.elmts);
        //else
        this.explodeTask(this.comp.elmts, this.comp.axisTranslation);


        //for showing the actual bounding box on screen
        if (this.comp.showBoundingBox) {
            var rm = STU.RenderManager.getInstance();
            for (var iElmt = 0; iElmt < this.comp.elmts.length; iElmt++) {
                //var currentSubActor = this.comp.elmts[elmt].getSubActors();
                //var subActorCount = currentSubActor.length;
                //for (var subActor in currentSubActor) {
                //	currentSubActor[subActor].CATI3DXGraphicalProperties.SetShowMode(0);
                //}
                this.comp.hideAndShowVisibility(this.comp.elmts[iElmt], 0);
                //var bb = this.comp.elmts[iElmt].getBoundingBox();
                var MyParams = { excludeChildren: 0, orientation: this.comp.elmts[iElmt].getTransform() };
                var bb = this.comp.elmts[iElmt].getOrientedBoundingBox(MyParams);
                //var subActorCount = currentSubActor.length;
                //for (var subActor in currentSubActor) {
                //	currentSubActor[subActor].CATI3DXGraphicalProperties.SetShowMode(1);
                //}
                this.comp.hideAndShowVisibility(this.comp.elmts[iElmt], 1);
                //var tr = new DSMath.Transformation();
                //tr.vector.set(bb.low.x, bb.low.y, bb.low.z);
                //rm._createBox({ box: bb, color: this.color, alpha: this.alpha * 255, lifetime: 0 });
                var worldTransfo = this.comp.elmts[iElmt].getTransform("World");
                rm._createBox({ box: bb, color: this.color, alpha: this.alpha * 255, lifetime: 0, position: worldTransfo });
            }
        }

        /* For creating bounding Sphere
		this.renderManager._createSphere(this.comp.getActor().getBoundingSphere().getRadius(), this.comp.getActor().getTransform(), this.color, 1, -1);
		*/
        // ends 
    };

    ExplodeTask.prototype.motionTask = function (iElmtArray) {
        //this.comp.pathAmount = this.normalizeStep;

        //var tempNormalizeStep = this.normalizeStep;
        //if (this.comp.mode == 3) {
        //	//var circlePointPos = new ThreeDS.Mathematics.Point();
        //	if (this.comp.reverseDirection) {
        //		var len = this.comp.finalArr.length;
        //		if (len > 0)
        //			tempNormalizeStep = this.comp.finalArr.pop();
        //		else
        //			tempNormalizeStep = 0;
        //	}
        //}

        //for (var elmt in iElmtArray) {
        //	if ((iElmtArray[elmt] !== null) && (iElmtArray[elmt] !== undefined)) {
        //		var tempPathAmount = iElmtArray[elmt].factor * tempNormalizeStep;
        //		//console.log("\n temp path amount" + tempPathAmount);
        //		var actorPos = this.comp.targetPath.getValue(tempPathAmount);
        //		iElmtArray[elmt].setPosition(actorPos);
        //	}
        //}
    };

    /**
	 * Method responsible for actual movement of parts by distance
	 * Called per frame
	 * @method
	 * @private
	 * @param assembly hierarchy array and explode direction
	 */
    ExplodeTask.prototype.explodeTask = function (iElmtArray, iExplodeDir) {
        // Actual distance which maximum distance part have to travel
        // considering all cases, when all parts are already in negative direction or postive direction
        // Distance of travel can be differnt

        var maxdis = 0;

        if ((this.comp.mode === 0) && (this.comp.linearMode === 0) && (this.comp.linearDirection === 1)) {
            maxdis = this.comp.distance + this.comp.maximumDistance;
        }
        else {
            maxdis = this.comp.distance - this.comp.maximumDistance;
        }


        if (!this.comp.explodeEnded) { // To check maximum distance part already reached or not

            var vec = new DSMath.Vector3D();

            // Speed of translation
            this.comp.speed = this.normalizeStep * maxdis - this.comp.currentValue;

            if (this.comp.reverseDirection) {
                this.comp.speed = this.comp.speed * (-1);
            }

            var tempSpeed;


            var circlePointPos = new DSMath.Vector3D();
            var tempNormalizeStep = this.normalizeStep;
            /*if ((this.comp.mode === 2) || (this.comp.mode === 3)) {
                //var circlePointPos = new ThreeDS.Mathematics.Point();
                if (this.comp.reverseDirection) {
                    var len = this.comp.finalArr.length;
                    if (len > 0) {
                        tempNormalizeStep = this.comp.finalArr.pop();
                    }
                    else {
                        tempNormalizeStep = 0;
                    }
                }
            }*/


            for (var iElmt = 0; iElmt < iElmtArray.length; iElmt++) {
                if ((iElmtArray[iElmt] !== null) && (iElmtArray[iElmt] !== undefined)) {

                    // Final factor calculation for each mode, by that part will translate
                    if (this.comp.mode === 0) {
                        var totalFactor;
                        var parent = iElmtArray[iElmt].getParent();

                        /*if (parent != null && parent != this.comp.getActor()) {
                    		totalFactor = iElmtArray[iElmt].factor - parent.factor;
                        }
                        else*/
                        totalFactor = iElmtArray[iElmt].factor;

                        vec.set(this.comp.axisTranslation.x, this.comp.axisTranslation.y, this.comp.axisTranslation.z);

                        if ((globalVariable === true) && this.comp.linearMode === 0) {
                            tempSpeed = this.comp.speed * totalFactor;
                        }

                        else if ((globalVariable === true) && this.comp.linearMode === 1) {
                            if (iElmtArray[iElmt].distance < 0) {
                                tempSpeed = this.comp.speed * (-1) * totalFactor;
                            }
                            else {
                                tempSpeed = this.comp.speed * totalFactor;
                            }
                        }
                        else {
                            tempSpeed = this.comp.speed * (iElmtArray[iElmt].distance / this.comp.maximumDistance);
                        }
                    }

                    // final translation vector
                    if ((this.comp.mode === 0) || (this.comp.mode === 1)) {
                        vec.multiplyScalar(tempSpeed);
                        var finalpos = iElmtArray[iElmt].initPos;
                        finalpos.add(vec);
                        //var parent = iElmtArray[iElmt].getParent();
                        iElmtArray[iElmt].setPosition(finalpos, parent);
                    }

                    //vec.multiplyScalar(tempSpeed);
                    //iElmtArray[iElmt].translate(vec);


                } else {
                    console.error("Invaldid elmt #" + iElmt);
                }
            }
        } else {
            for (var iElmt = 0; iElmt < iElmtArray.length; iElmt++) {
                var pos = iElmtArray[iElmt].getPosition();
                //console.log("\n the position is x is " + pos.x + " y is " + pos.y + " z is " + pos.z);
            }
        }

        // Updating current value at each frame
        if (this.comp.currentValue < (maxdis)) {
            if (this.comp.reverseDirection) {
                this.comp.currentValue = this.comp.currentValue - this.comp.speed;
            }
            else {
                this.comp.currentValue = this.comp.currentValue + this.comp.speed;
            }
        }
        else {
            this.comp.explodeEnded = true;
            if (this.comp.state === 0) {
                this.comp.dispatchEvent(new STU.ServiceStoppedEvent("doCollapse", this.comp));
            }
            else {
                this.comp.dispatchEvent(new STU.ServiceStoppedEvent("explode", this.comp));
            }
        }
    };

    /**
	 * Process to execute when this STU.Explode is deactivating. 
	 *
	 * @method
	 * @private
	 */
    Explode.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.associatedTask);
        EP.EventServices.removeObjectListener(STU.ClickablePressEvent, this, 'onClickablePress');
        EP.EventServices.removeObjectListener(EP.KeyboardPressEvent, this, 'onKeyboardEvent');
        delete this.associatedTask;

        Behavior.prototype.onDeactivate.call(this);
    };

    // Capacities in Explode behavior-

    /**
	 * explode method and capacity
	 * Worked only in No Activation mode
	 * 
	 * Case 1. with no arguments
	 * behave like driver capacity
	 * explode the hierarchy, if it was not exploded already
	 *
	 *
	 * Case 2. With one argument present
	 * Work like explode method with percentage
	 * In one frame it will explode till given percentage
	 * Used as work like slider
	 *
	 *
	 * Case 3. With more than one argument present
	 * gives error
	 * @public
	 */

    Explode.prototype.explode = function () {
        if (arguments.length === 0) {
            if (this.state === 0) {
                this.state = 1;
                this.reverseDirection = false;
                EP.TaskPlayer.addTask(this.associatedTask);
                this.associatedTask.start();
                this.directionChange();
            }
        }
        else if (arguments.length === 1) {
            // Called when explode with percentage is called
            var maxdis = 0;
            if ((this.mode === 0) && (this.linearMode === 0) && (this.linearDirection === 1)) {
                maxdis = this.distance + this.maximumDistance;
            }
            else {
                maxdis = this.distance - this.maximumDistance;
            }

            if (!this.explodeEnded) {
                var vec = new DSMath.Vector3D();
                arguments[0] = arguments[0] * 0.01;
                console.log("arguments are" + arguments[0]);
                this.speed = maxdis * arguments[0] - this.currentValue;

                if (this.reverseDirection) {
                    this.speed = this.speed * (-1);
                }

                var tempSpeed;


                var circlePointPos = new DSMath.Vector3D();
                var tempNormalizeStep = arguments[0];
                //if ((this.comp.mode == 2) || (this.comp.mode == 3)) {
                //	//var circlePointPos = new DSMath.Point();
                //	if (this.comp.reverseDirection) {
                //		var len = this.comp.finalArr.length;
                //		if (len > 0)
                //			tempNormalizeStep = this.comp.finalArr.pop();
                //		else
                //			tempNormalizeStep = 0;
                //	}
                //}

                for (var iElmt = 0; iElmt < this.elmts.length; iElmt++) {
                    if ((this.elmts[iElmt] !== null) && (this.elmts[iElmt] !== undefined)) {

                        // Final factor calculation for each mode, by that part will translate
                        if (this.mode === 0) {
                            var totalFactor;
                            var parent = this.elmts[iElmt].getParent();

                            totalFactor = this.elmts[iElmt].factor;

                            vec.set(this.axisTranslation.x, this.axisTranslation.y, this.axisTranslation.z);

                            if ((globalVariable === true) && this.linearMode === 0) {
                                tempSpeed = this.speed * totalFactor;
                            }

                            else if ((globalVariable === true) && this.linearMode === 1) {
                                if (this.elmts[iElmt].distance < 0) {
                                    tempSpeed = this.speed * (-1) * totalFactor;
                                }
                                else {
                                    tempSpeed = this.speed * totalFactor;
                                }
                            }
                            else {
                                tempSpeed = this.speed * (this.elmts[iElmt].distance / this.maximumDistance);
                            }
                        }


                        // final translation vector
                        if ((this.mode === 0) || (this.mode === 1)) {
                            vec.multiplyScalar(tempSpeed);
                            var finalpos = this.elmts[iElmt].initPos;
                            finalpos.add(vec);
                            this.elmts[iElmt].setPosition(finalpos);
                        }

                    } else {
                        console.error("Invaldid elmt #" + iElmt);
                    }
                }
            }

        }
        else {
            //Pour override le pb de Natural Language qui envoie un tableau d'argument {0: undefined, 1: null}
            if (arguments[0] === undefined && arguments[1] === null) {
                this.explode();
                // Stop Service
                this.associatedTask.comp.dispatchEvent(new STU.ServiceStoppedEvent("doCollapse", this.associatedTask.comp));
            }
            else {
                console.error("[Explode]: Too many arguments given ");
            }
        }
    };

    /**
	 * doCollapse driver capacity
	 * Worked only in No Activation mode
	 * doCollapse the hierarchy, if it was exploded already
	 * @public
	 */
    Explode.prototype.doCollapse = function () {
        if (this.state === 1) {
            this.state = 0;
            this.directionChange();
            this.reverseDirection = true;
            // Stop Service
            this.associatedTask.comp.dispatchEvent(new STU.ServiceStoppedEvent("explode", this.associatedTask.comp));
        }
    };

    /**
	 * isExploding sensor capacity
	 * Worked only in No Activation mode
	 * To check whether explode has started or not
	 * @public
     * @return {Boolean}
	 */
    Explode.prototype.isExploding = function () {
        if (this.isExplode === true) {
            return true;
        }
        else {
            return false;
        }
    };

    /**
	 * hasExploded sensor capacity
	 * Worked only in No Activation mode
	 * To check whether explode has completed or not
	 * @public
	 * @return {Boolean}
	 */
    Explode.prototype.hasExploded = function () {
        if (this.explodeEnded === true) {
            return true;
        }
        else {
            return false;
        }
    };

    /**
	 * isCollapsed sensor capacity
	 * Worked only in No Activation mode
	 * To check whether the object is not exploded
	 * @public
     * @return {Boolean}
	 */
    Explode.prototype.isCollapsed = function () {
        /*if (this.currentTime === 0) {
            return true;
        }*/
        if (this.explodeEnded === true && this.reverseDirection === true) {
            return true;
        }
        else {
            return false;
        }
    };
    // Expose in STU namespace.
    STU.Explode = Explode;

    return Explode;
});

define('StuMiscContent/StuExplodeBe', ['DS/StuMiscContent/StuExplodeBe'], function (Explode) {
    'use strict';

    return Explode;
});
