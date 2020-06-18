/* global define */
define('DS/StuMiscContent/StuTrafficManager', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'MathematicsES/MathsDef', 'DS/StuModel/StuCollection'], function (STU, EP, Behavior,
    Task, DSMath) {
    'use strict';

    var TrafficManagerTask = function (iComp) {
        Task.call(this);
        this.comp = iComp;
    };

    TrafficManagerTask.prototype = new Task();
    TrafficManagerTask.prototype.constructor = TrafficManagerTask;


    /**
     * Method called each frame by the task manager
     *
     * @method
     * @private
     * @param  iExContext Execution context
     */
    TrafficManagerTask.prototype.onStart = function (iExContext) {
        // Special inits
        var err = this.comp.checkParameters();
    };

    /**
     * Method called each frame by the task manager
     *
     * @method
     * @private
     * @param  iExContext Execution context
     */
    TrafficManagerTask.prototype.onExecute = function (iExContext) {
        if ('executeOneFrame' in this.comp) {
            this.comp.executeOneFrame(iExContext);
        }
    };


    /**
     * TrafficManager distribute a collection of car over the targeted path
     *
     * @exports TrafficManager
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.Behavior}
     * @memberOf STU
     * @alias STU.TrafficManager
     */
    var TrafficManager = function () {
        Behavior.call(this);
        this.name = 'TrafficManager';
        this.associatedTask;

        this._resetRoadCollection = true;
        this._resetCarCollection = true;

        // General properties
        /**
         * Destination
         * @public
         * @type {STU.PathActor}
         */
        this.roads = null;
        this._roadsCollection = null;
        Object.defineProperty(this, 'roads', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._roadsCollection;
            },
            set: function (value) {
                var goodArgsType = (value instanceof STU.Collection) || (value instanceof STU.PathActor);
                if (goodArgsType) {
                    this._roadsCollection = value;

                    this._resetRoadCollection = true;
                } else {
                    console.warn('[TrafficManager] : Roads should be defined by a collection or a PathActor !');
                }
            }
        });

        /**
         * The car collection used for the distribution
         * @private
         * @type {STU.Collection}
         */
        this.cars = null;
        this._carsCollections = null;
        this._carsArray = [];
        Object.defineProperty(this, 'cars', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._carsCollections;
            },
            set: function (value) {
                var goodArgsType = (value instanceof STU.Collection);
                if (goodArgsType) {

                    //console.log('[TrafficManager] : SET CARS !');

                    this._carsCollections = value;

                    this._resetCarCollection = true;
                } else {
                    console.warn('[TrafficManager] : Cars should be defined by a collection !');
                }
            }
        });

        /**
         * The dispersion of the distribution (0 to 1)
         * @type {Number}
         * @public
         */
        this.trafficDispersion = 0;
        this._trafficDispersion = 0;
        Object.defineProperty(this, 'trafficDispersion', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._trafficDispersion;
            },
            set: function (value) {
                if (value >= 0 && value <= 1) {
                    this._trafficDispersion = value;
                    this._resetTraffic = true;
                }
                else {
                    console.warn("[Traffic Manager] : \"Traffic dispersion\" value should be between 0 and 1");
                }
            }
        });

        /**
         * The density of the distribution (0 to 1)
         * @type {Number}
         * @public
         */
        this.trafficLoad = 1;
        this._trafficLoad = 1;
        Object.defineProperty(this, 'trafficLoad', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._trafficLoad;
            },
            set: function (value) {
                if (value >= 0 && value <= 1) {
                    this._trafficLoad = value;
                    this._resetTraffic = true;
                }
                else {
                    console.warn("[Traffic Manager] : \"Traffic load\" value should be between 0 and 1");
                }
            }
        });

        /**
         * Maximum Speed of the cars (km/h)
         * @type {Number}
         * @public
         */
        this.maximumSpeed = 50;
        this._maximumSpeed = 50;
        this._convertedSpeed = 50;
        Object.defineProperty(this, 'maximumSpeed', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._maximumSpeed;
            },
            set: function (value) {
                this._maximumSpeed = value;
                this._convertedSpeed = value / (3.6 * this.samplingDistance);
            }
        });

        /**
         * True if you want to rotate the wheels. (Time expensive)
         * @type {Boolean}
         * @public
         */
        this.rotateWheels = true;

        // Advanced

        /**
         * The interval between each raycast to analyse the topology of the area on the path
         * @type {Number}
         * @public
         */
        this.samplingDistance = 1000;

        /**
         * True if you want to show the computed path
         * @type {Boolean}
         * @public
         */
        this.displayComputedPath = true;

        /**
         * True if you want to compute and use the ground topology under the path
         * @type {Boolean}
         * @public
         */
        this.projectOnGround = false;

        /**
         * Array of car actors, that will be instantiated only once in the traffic
         * @type {STU.Actor3D[]}
         * @public
         */
        this.uniqueCars = null;
        this._uniqueCars = null;
        Object.defineProperty(this, 'uniqueCars', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._uniqueCars;
            },
            set: function (value) {
                //var goodArgsType = (value instanceof STU.Collection);
                //if (goodArgsType) {   
                this._uniqueCars = value;
                this._resetCarCollection = true;
                //} 
                /*else {
                    console.warn('[TrafficManager] : Cars should be defined by a collection !');
                }*/
            }
        });

        /**
         * Array of car templates, that will be instantiated multiple times 
         * @type {STU.Actor3D[]}
         * @public
         */
        this.multipleCars = null;
        this._multipleCars = null;
        Object.defineProperty(this, 'multipleCars', {
            enumerable: true,
            configurable: true,
            get: function () {
                return this._multipleCars;
            },
            set: function (value) {
                //var goodArgsType = (value instanceof STU.Collection);
                //if (goodArgsType) {   
                this._multipleCars = value;
                this._resetCarCollection = true;
                //} 
                /*else {
                    console.warn('[TrafficManager] : Cars should be defined by a collection !');
                }*/
            }
        });

        //***********************************************************************************
        //                                      PRIVATE
        //***********************************************************************************

        /**
         * Init flag
         * @private
         * @type {Boolean}
         */
        this._init = false;

        /**
         * Seed use for random() - ODT
         * @private
         * @type {Number}
         */
        this._seed = 0;

        /**
         * Number of car in the collection
         * @private
         * @type {Number}
         */
        this._collectionLength = 0;

        /**
         * The array containing all roads
         * @private
         * @type {Number}
         */
        this._trafficPaths = [];

        /**
         * ...
         * @private
         * @type {Number}
         */
        this._stopTimer = 0;

        /**
         * ...
         * @private
         * @type {Number}
         */
        this._startTimer = 0;

        /**
         * Time needed to start the traffic
         * @private
         * @type {Number}
         */
        this._timeToStart = 5;

        /**
         * Time needed to stop the traffic
         * @private
         * @type {Number}
         */
        this._timeToStop = 5;

        /**
         * State variable indicating if the traffic is on
         * @private
         * @type {Number}
         */
        this._trafficStart = true;

        /**
         * Right Intersections
         * @private
         * @type {Array}
         */
        this._rightIntersections = [];
        /**
         * Left Intersections
         * @private
         * @type {Array}
         */
        this._leftIntersections = [];

        /**
         * The reference position of each car in the virtual path
         * @private
         * @type {Array}
         */
        this._positionList = [];

        /**
         * Car's initial position list
         * @private
         * @type {Array}
         */
        this._carInitialPositions = [];

        /**
         * Car's scale list
         * @private
         * @type {Number}
         */
        this._carsCollectionscale = [];

        /**
         * The current car's position in the virtual path
         * @private
         * @type {Array}
         */
        this._carVirtualPosition = [];

        /**
         * Car's length list
         * @private
         * @type {Array}
         */
        this._carLength = [];

        /**
         * Car's width list
         * @private
         * @type {Array}
         */
        this._carWidth = [];

        /**
         * Car's visibility list
         * @private
         * @type {Array}
         */
        this._carVisibility = [];


        //this._carsLength = {};

        /**
         * The total distance of the virtual Path
         * @private
         * @type {Number}
         */
        this._estimedTime = 0;


        /**
         * Store the current time
         * @private
         * @type {Number}
         */
        this._currentTime = 0;

        /**
         * Array containing all car template
         * @private
         * @type {Array}
         */
        this._carsTemplateArray = [];

        /**
         * Array containing all car instance
         * @private
         * @type {Array}
         */
        this._carsActorsArray = [];

        /**
         * Array containing all car instance rearranged randomly
         * @private
         * @type {Array}
         */
        this._randomizedCarsActorsArray = [];

        /**
         * Number of unique cars
         * @private
         * @type {Number}
         */
        this._totalUniqueCars = 0;

        /**
         * Sum of all car instance's length
         * @private
         * @type {Number}
         */
        this._totalCarInstanceLength = 0;

        /**
         * Sum of all car instance's length
         * @private
         * @type {Number}
         */
        this._totalDynamicInstanceCars = 0;

        /**
         * Path's length allocated for static instance
         * @private
         * @type {Number}
         */
        this._pathLengthForInstances = 0;

        /**
         * Path's length allocated for dynamic instance
         * @private
         * @type {Number}
         */
        this._pathLengthForTemplates = 0;

        /**
         * Sum of all path's length 
         * @private
         * @type {Number}
         */
        this._totalPathLength = 0;

        /**
         * Smallest car size
         * @private
         * @type {Number}
         */
        this._smallestSize = 0;

        /**
         * Distance between each car
         * @private
         * @type {Number}
         */
        this._securityDist = 0;

        /**
         * Number of cars
         * @private
         * @type {Number}
         */
        this._totalCars = 0;

        /**
         * Sum of all template's distribution weight
         * @private
         * @type {Number}
         */
        this._distribWeightSum = 0;

        /**
         * Array that containing the first dynamic instance of each template
         * @private
         * @type {Boolean}
         */
        this._firstInstanceOfTemplate = [];

        /**
         * The template that we are currently instanciating dynamic instance
         * @private
         * @type {Boolean}
         */
        this._currentTemplateBehavior = null;

        /**
         * ODT Flag
         * @private
         * @type {Boolean}
         */
        this._isODT = false;

        this._dumpErrors = true;

        this._initialMaxSpeed = null;

        this._visibiltyUpdateNeeded = false;

        this._globeLocation = null;

        this._templatesLength = [];

        this._currentFrame = 0;

    };
    TrafficManager.prototype = new Behavior();
    TrafficManager.prototype.constructor = TrafficManager;

    /**
     * ...
     *
     * @exports TrafficPath
     * @class 
     * @constructor
     * @noinstancector
     * @private
     */
    var TrafficPath = function (iPath) {
        //STU.PathActor.call(this);
        this.path = iPath;
        //this.cars = [];

        this.getLength = function () {
            if (this.path !== null && this.path !== undefined) {
                return this.path.getLength();
            }
            return null;
        };

        this.getName = function () {
            if (this.path !== null && this.path !== undefined) {
                return this.path.name;
            }
            return null;
        };

        this.getStartPosition = function (iReference) {
            if (this.path !== null && this.path !== undefined) {
                return this.path.getValue(0, iReference);
            }
            return null;
        };

        this.getEndPosition = function (iReference) {
            if (this.path !== null && this.path !== undefined) {
                return this.path.getValue(1, iReference);
            }
            return null;
        };

        this.getValue = function (iValue, iReference) {
            if (this.path !== null && this.path !== undefined) {
                return this.path.getValue(iValue, iReference);
            }
            return null;
        };

        this.getLocation = function () {
            return this.path.getLocation();
        };
    };

    /**
     * ...
     *
     * @exports TrafficPosition
     * @class 
     * @constructor
     * @noinstancector
     * @private
     */
    var TrafficPosition = function (iPosition, iRoad) {
        this.position = iPosition;
        this.road = iRoad;
    };

    /**
     * Process executed when STU.TrafficManager is activating
     *
     * @method
     * @private
    */
    TrafficManager.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this.associatedTask = new TrafficManagerTask(this);
        EP.TaskPlayer.addTask(this.associatedTask);

        this._globeLocation = null;//this.actor.getLocation();
    };

    /**
     * Process executed when STU.TrafficManager is deactivating
     *
     * @method
     * @private
     */
    TrafficManager.prototype.onDeactivate = function () {
        if(Array.isArray(this._multipleCars)){
            for (var i = 0; i < this._multipleCars.length; i++) {
                //console.log("Remove all instance of: " + this.multipleCars[i].carTemplate.name);
    
                //this.multipleCars
                var exp = STU.Experience.getCurrent();
                var templateActor = this._multipleCars[i].carTemplate;//exp.getActorTemplateByReference(this._multipleCars[i].carTemplate);
                templateActor.deleteDynamicInstances();
            }
        }

        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;
        Behavior.prototype.onDeactivate.call(this);
    };

    /**
     * Random number generator with seed
     * @method
     * @private
     */
    TrafficManager.prototype.seededRandom = function (max, min) {
        this._seed = (this._seed + 1) % 233280;
        max = max || 1;
        min = min || 0;
        this._seed = (this._seed * 9301 + 49297) % 233280;
        var rnd = this._seed / 233280;
        return min + rnd * (max - min);
    };

    /**
     * Math.sign is redefined here because the getSignedAngleTo
     * in MathematicsWeb/MathematicsES.mweb/src/MathVector3DJSImpl.js  
     * uses Math.sign which is only available since ECMA script 2015. 
     * Our V8 engine uses a much older version so Math.sign is not available for us. 
     * 
     * @private
     */
    Math.sign = Math.sign || function (x) {
        x = +x; // convert to a number
        if (x === 0 || isNaN(x)) {
            return x;
        }
        return x > 0 ? 1 : -1;
    };

    /*
     * Check if all the parameters are correctly set
     * @method
     * @private
     */
    TrafficManager.prototype.checkParameters = function (iDumpError) {
        if (iDumpError === undefined || iDumpError === null) { iDumpError = true }
        var err = 0;
        var warn = 0;

        /**
        * Roads Parameter
        */
        if (this._roadsCollection === undefined || this._roadsCollection === null) {
            if (iDumpError) {
                console.error('[TrafficManager] : Roads is not defined!');
            }
            err++;
        } else {
            var goodArgsType = (this._roadsCollection instanceof STU.Collection) || (this._roadsCollection instanceof STU.PathActor);
            if (goodArgsType === false) {
                if (iDumpError) {
                    console.error('[TrafficManager] : Roads should be defined by a collection or a PathActor !');
                }
                err++;
            }
        }

        if ((this.multipleCars !== undefined && this.multipleCars !== null) && (this.uniqueCars !== undefined && this.uniqueCars !== null)) {
            if (this.uniqueCars.length === 0 && this.multipleCars.length === 0) {
                if (iDumpError) {
                    console.error('[TrafficManager] : Multiple and Unique cars array should not be both empty or null');
                }
                err++;
            }
        }
        else {
            var count = 0;
            if (this.uniqueCars === undefined || this.uniqueCars === null) {
                if (iDumpError) {
                    console.warn('[TrafficManager] : uniqueCars is not defined!');
                }
                warn++;
                count++;
            }
            if (this.multipleCars === undefined || this.multipleCars === null) {
                if (iDumpError) {
                    console.warn('[TrafficManager] : multipleCars is not defined!');
                }
                warn++;
                count++;
            }
            if (count === 2) {
                if (iDumpError) {
                    console.error('[TrafficManager] : Multiple and Unique cars array should not be both empty or null');
                }
                err++;
            }
        }

        /**
        * maximum speed Parameter
        */
        if (this._maximumSpeed < 0) {
            if (iDumpError) {
                console.warn('[TrafficManager] : \'Maximum Speed\' should be greater than 0 !');
            }
            err++;
        }

        /**
        * traffic Load Parameter
        */
        if (this.trafficLoad < 0 || this.trafficLoad > 1) {
            if (iDumpError) {
                console.warn('[TrafficManager] : \'Traffic Load\' should be between 0 and 1 !');
            }
            if (this.trafficLoad < 0) {
                this.trafficLoad = 0;
                warn++;
            }
            if (this.trafficLoad > 1) {
                this.trafficLoad = 1;
                warn++;
            }
        }

        /**
        * traffic dispersion Parameter
        */
        if (this.trafficDispersion < 0 || this.trafficDispersion > 1) {
            if (iDumpError) {
                console.warn('[TrafficManager] : \'Traffic Dispersion\' should be between 0 and 1 !');
            }
            if (this.trafficDispersion < 0) {
                this.trafficDispersion = 0;
                warn++;
            }
            if (this.trafficDispersion > 1) {
                this.trafficDispersion = 1;
                warn++;
            }
        }

        /**
        * traffic dispersion Parameter
        */
        if (this.samplingDistance < 0) {
            if (iDumpError) {
                console.warn('[TrafficManager] : \'Sampling Distance\' should be greater than 0 !');
            }
            err++;
        }

        //return err;
        return { errors: err, warnings: warn };
    };

    /**
     * Executed at each frame
     * @method
     * @private
     */
    TrafficManager.prototype.executeOneFrame = function (context) {
        var checking = this.checkParameters(this._dumpErrors);

        if (this._dumpErrors) {
            this._dumpErrors = false; // We want to dump error and warning once
        }

        if (checking.errors === 0) {
            if (this._resetCarCollection || this._resetRoadCollection) {
                this._startTimer = 0;
                this._deltaTime = 0;
            }

            if (this._resetCarCollection) {
                this.analyzeUniqueCarArray();
                this.analyzeMultipleCarArray();

                this._resetCarCollection = false;
                // this._resetRoadCollection = true;
                this._analyseTemplateFirstInstance = true;
                this._carAnalysisFrame = this._currentFrame;
            }

            if (this._carAnalysisFrame !== this._currentFrame) {
                if (this._analyseTemplateFirstInstance) {
                    this.analyseTemplateFirstInstance();
                    this._analyseTemplateFirstInstance = false;
                    this._resetRoadCollection = true;
                }
                if (this._resetRoadCollection) {
                    this.analyzeRoadCollection();
                    this._resetRoadCollection = false;
                    this._resetTraffic = true;
                }
                if (this._resetTraffic) {
                    this.initCars();
                    this._resetTraffic = false;
                }
            }


            this._currentFrame++;
            if (this._currentFrame > 10000) {
                this._currentFrame = 0;
            }

            //manage traffic
            if (this._trafficStart === true) {
                this._startTimer += context.deltaTime * 0.001;
                if (this._startTimer > this._timeToStart) {
                    this._startTimer = this._timeToStart;
                }
                var startCoeff = (this._startTimer / this._timeToStart);

                this._currentTime += context.deltaTime * startCoeff;
                if (this._currentTime > this._estimedTime / this._convertedSpeed) {
                    this._currentTime -= this._estimedTime / this._convertedSpeed;
                }
                //update Traffic
                this._deltaTime = context.deltaTime * startCoeff;
                this.updateTraffic();

                this._stopTimer = 0;
            }
            else {
                this._stopTimer += context.deltaTime * 0.001;
                //var timeToStop = 5;
                if (this._stopTimer > this._timeToStop) {
                    this._stopTimer = this._timeToStop;
                }
                var stopCoeff = 1 - (this._stopTimer / this._timeToStop);

                if (stopCoeff > 0) {
                    //update Time
                    this._currentTime += context.deltaTime * stopCoeff;
                    if (this._currentTime > this._estimedTime / this._convertedSpeed) {
                        this._currentTime -= this._estimedTime / this._convertedSpeed;
                    }

                    //update Traffic
                    this._deltaTime = context.deltaTime * stopCoeff;
                    this.updateTraffic();
                }

                this._startTimer = 0;
            }

            if (this._visibiltyUpdateNeeded === true) {
                this._visibiltyUpdateNeeded = false;
            }
        }
    };

    TrafficManager.prototype.analyzeUniqueCarArray = function () {
        // cleaning arrays before refilling it
        this._carsActorsArray.splice(0, this._carsActorsArray.length);

        if (this._uniqueCars !== undefined && this._uniqueCars !== null) {
            for (var i = 0; i < this._uniqueCars.length ; i++) {
                var actor = this._uniqueCars[i].carActor;
                if (actor !== null && actor !== undefined) {
                    var carBeh = actor.CarController;
                    if (carBeh === null || carBeh === undefined) {
                        console.warn("[Traffic Manager]: " + actor.name + " doesn't have a CarController");
                    } else {
                        var s_ok = carBeh.setTrafficManagerOverride();
                        if (!s_ok) {
                            console.warn("[Traffic Manager]: " + actor.name + " doesn\'t have its wheels defined, it will be excluded from the cars array");
                        } else {
                            this._carsActorsArray.push(actor);
                            this._totalUniqueCars++;

                            //Car Measurement
                            var bbox = actor.getBoundingBox();

                            var tmpPoint = bbox.low.clone();
                            tmpPoint.z = bbox.high.z;
                            tmpPoint.y = bbox.high.y;
                            var lengthX = bbox.high.distanceTo(tmpPoint);

                            tmpPoint = bbox.low.clone();
                            tmpPoint.z = bbox.high.z;
                            tmpPoint.x = bbox.high.x;
                            var lengthY = bbox.high.distanceTo(tmpPoint);

                            var length = (lengthY > lengthX) ? lengthY : lengthX;

                            this._totalCarInstanceLength += length;
                            console.debug(actor.name + " size: " + length);

                            if (this._smallestSize === 0) {
                                this._smallestSize = length;
                            }
                            else {
                                if (length < this._smallestSize) {
                                    this._smallestSize = length;
                                }
                            }
                        }
                    }
                }
            }
        }
    };

    TrafficManager.prototype.analyzeMultipleCarArray = function () {
        this._carsTemplateArray.splice(0, this._carsTemplateArray.length);

        if (this._multipleCars !== undefined && this._multipleCars !== null) {
            for (var i = 0; i < this._multipleCars.length ; i++) {
                if (this._multipleCars[i] !== undefined && this._multipleCars[i] !== null) {
                    var template = this._multipleCars[i].carTemplate;
                    if (template !== null && template !== undefined) {
                        var doInstanciate = true;
                        if (this._multipleCars[i].distributionWeight <= 0) {
                            console.warn("[Traffic Manager]: " + template.name + " Bad distribution weight, no instance of this template will be present in the traffic flow");
                            doInstanciate = false;
                        }
                        else if (this._trafficLoad <= 0) {
                            console.warn("[Traffic Manager]: Traffic Load equals to 0 then no dynamic instance will be created");
                            doInstanciate = false;
                        }
                        else {
                            this._distribWeightSum += this._multipleCars[i].distributionWeight;
                        }

                        if (doInstanciate) {
                            this._carsTemplateArray.push(this._multipleCars[i]);

                            var exp = STU.Experience.getCurrent();
                            var templateActor = this._multipleCars[i].carTemplate;//exp.getActorTemplateByReference(this._multipleCars[i].carTemplate);
                            templateActor.createDynamicInstance({ name: template.name, parent: null, incrementName: true, callbackCaller: this, onActivationSuccess: this.onFirstTemplateActorInstanciation });
                            //this._multipleCars[i].carLength = this._templatesLength[i];
                            //this._multipleCars[i].carLength = length;
                            //templateActor.carLength = length;
                        }
                    }
                    else {
                        console.warn("[Traffic Manager]: Template #" + (i + 1) + " is undefined");
                    }
                }
            }
        }
    };

    TrafficManager.prototype.onFirstTemplateActorInstanciation = function (iActor) {
        this._firstInstanceOfTemplate.push(iActor);
        //iActor.visible = false;

        var carBeh = iActor.CarController;
        if (carBeh === null || carBeh === undefined) {
            console.warn("[Traffic Manager]: Car template \"" + iActor.name + "\" doesn't have a CarController");
        }
        else {
            //var s_ok = carBeh.setTrafficManagerOverride();
            carBeh.__internal__.trafficManagerOverride = true;
        }
    };

    TrafficManager.prototype.analyseTemplateFirstInstance = function () {
        for (var i = 0; i < this._firstInstanceOfTemplate.length; i++) {
            var iActor = this._firstInstanceOfTemplate[i];
            var carBeh = iActor.CarController;
            if (carBeh === null || carBeh === undefined) {
                console.warn("[Traffic Manager]: Car template \"" + iActor.name + "\" doesn't have a CarController");
            }
            else {
                var s_ok = carBeh.setTrafficManagerOverride();
                if (!s_ok) {
                    console.warn("[Traffic Manager]: Car template \"" + iActor.name + "\" doesn\'t have its wheels defined, it will be excluded from the cars array");
                }
                else {
                    //var length = carBeh.__internal__.carLength * 1.2;

                    //Car Measurement
                    var bbox = iActor.getBoundingBox();
                    iActor.visible = false;

                    var tmpPoint = bbox.low.clone();
                    tmpPoint.z = bbox.high.z;
                    tmpPoint.y = bbox.high.y;
                    var lengthX = bbox.high.distanceTo(tmpPoint);

                    tmpPoint = bbox.low.clone();
                    tmpPoint.z = bbox.high.z;
                    tmpPoint.x = bbox.high.x;
                    var lengthY = bbox.high.distanceTo(tmpPoint);

                    var length = (lengthY > lengthX) ? lengthY : lengthX;

                    carBeh.__internal__.carLength = length;

                    if (this._smallestSize === 0) {
                        this._smallestSize = length;
                    }
                    else {
                        if (length < this._smallestSize) {
                            this._smallestSize = length;
                        }
                    }
                    this._multipleCars[i].carLength = length;
                    this._carsActorsArray.push(iActor);
                }
            }
        }
    };

    TrafficManager.prototype.analyzeRoadCollection = function () {
        //Paths        
        this._trafficPaths = [];
        if (this._roadsCollection instanceof STU.Collection) {
            for (var i = 0; i < this._roadsCollection.getObjectCount() ; i++) {
                var actor = this._roadsCollection.getObjectAt(i);
                if (actor !== null || actor !== undefined) {
                    if ((actor instanceof STU.PathActor) === false) {
                        console.warn("[Traffic Manager]: " + actor.name + " is not a Path Actor, it will be excluded from the roads collection");
                    }
                    else if (actor.getLength() < this._smallestSize) {
                        console.warn("[Traffic Manager]: " + actor.name + " is too small, it will be excluded from the roads collection");
                    }
                    else {
                        var trafficPath = new TrafficPath(actor);//actor
                        this._trafficPaths.push(trafficPath);
                        this._totalPathLength += trafficPath.getLength();
                    }
                }
            }
        } else {
            var trafficPath = new TrafficPath(this._roadsCollection);//this._roadsCollection
            this._trafficPaths.push(trafficPath);
            this._totalPathLength += trafficPath.getLength();
        }

        console.debug("[Traffic Manager]: Total path length: " + this._totalPathLength);
        this.computeFlowConfiguration();        //this.initPaths();
    };

    TrafficManager.prototype.computeFlowConfiguration = function () {
        this._securityDist = this._smallestSize / 2;
        console.debug("[Traffic Manager]: Smallest car size: " + this._smallestSize);
        console.debug("[Traffic Manager]: SecurityDist: " + this._securityDist);
        console.debug("[Traffic Manager]: Number of unique car: " + this._totalUniqueCars);

        this._pathLengthForInstances = this._totalCarInstanceLength + (this._securityDist * this._totalUniqueCars);
        this._pathLengthForTemplates = this._totalPathLength - this._pathLengthForInstances;
        this._meanCarLength = 0;

        console.debug("[Traffic Manager]: Length for Instance: " + this._pathLengthForInstances);
        console.debug("[Traffic Manager]: Length for Template: " + this._pathLengthForTemplates);

        var exp = STU.Experience.getCurrent();
        for (var i = 0; i < this._carsTemplateArray.length; i++) {
            var flowPercentage = this._carsTemplateArray[i].distributionWeight / this._distribWeightSum;
            this._carsTemplateArray[i].normalizedWeight = flowPercentage;
            var lenghtForInstances = flowPercentage * this._carsTemplateArray[i].carLength;
            this._meanCarLength += lenghtForInstances;
        }
        this._unsecureMaxCarCount = this._pathLengthForTemplates / this._meanCarLength;
        console.debug("[Traffic Manager]: max car count (unsafe) " + this._unsecureMaxCarCount);
        this._secureMaxCarCount = (this._pathLengthForTemplates - (this._unsecureMaxCarCount * this._securityDist)) / this._meanCarLength;
        this._secureMaxCarCount = Math.floor(this._secureMaxCarCount);
        console.debug("[Traffic Manager]: max car count (safe) at density = 1: " + this._secureMaxCarCount);


        for (var i = 0; i < this._carsTemplateArray.length; i++) {
            this._currentTemplateBehavior = this._firstInstanceOfTemplate[i].CarController;
            var maxCarcount = Math.floor(this._carsTemplateArray[i].normalizedWeight * this._secureMaxCarCount);
            this._carsTemplateArray[i].maxCarCount = maxCarcount;
            var carCount = Math.floor(maxCarcount * this.trafficLoad);
            console.debug("[Traffic Manager]: There will be " + carCount + " instance of " + this._carsTemplateArray[i].carTemplate.name);
            for (var j = 1; j < carCount; j++) {
                var template = this._carsTemplateArray[i].carTemplate;//exp.getActorTemplateByReference(this._carsTemplateArray[i].carTemplate);
                template.createDynamicInstance({ name: template.name, parent: null, incrementName: true, callbackCaller: this, onActivationSuccess: this.onActorInstanciation });
            }
        }

        this.initPaths();
    };

    TrafficManager.prototype.onActorInstanciation = function (iActor) {
        var carBeh = iActor.CarController;
        if (carBeh === null || carBeh === undefined) {
            console.warn("[Traffic Manager]: Car template \"" + iActor.name + "\" doesn't have a CarController");
        }
        else {
            // var s_ok = carBeh.setTrafficManagerOverrideByCopy(this._firstInstanceOfTemplate[0].CarController);
            var s_ok = carBeh.setTrafficManagerOverrideByCopy(this._currentTemplateBehavior);
            // var s_ok = carBeh.setTrafficManagerOverride();
            if (!s_ok) {
                console.warn("[Traffic Manager]: Car template \"" + iActor.name + "\" doesn\'t have its wheels defined, it will be excluded from the cars array");
            }
            else {
                this._carsActorsArray.push(iActor);
            }
        }
    };


    TrafficManager.prototype.initPaths = function () {
        this.setCarsClickablity(false);

        /* global STUTST*/
        if (typeof STUTST === 'object' && typeof STUTST.JSDumpOdt === 'function') {
            this._isODT = true;
        }

        //Compute ground topology for each path
        this._trafficPaths.forEach(this.computeGround, this);

        var carCount = this._carsActorsArray.length;
        //declare an array of index
        var carIndexArray = [];
        for (var i = 0; i < carCount; i++) {
            carIndexArray.push(i);
        }
        //create a list where cars are randomized
        this._randomizedCarsActorsArray = [];
        for (var i = 0; i < carCount; i++) {
            var rnd = this._isODT ? this.seededRandom() : Math.random();
            var ri = Math.floor(rnd * carIndexArray.length); // Random Index position in the array
            var rs = carIndexArray.splice(ri, 1); // Splice out a random element using the ri var
            var selectedCarIndex = rs[0];

            this._randomizedCarsActorsArray[i] = this._carsActorsArray[selectedCarIndex];
        }

        this.setCarsClickablity(true);
    };

    TrafficManager.prototype.computeGround = function (currentRoad) {
        var currentPathValue = 0;
        var _globeLocation = currentRoad.getLocation();
        var currentPathPosition = currentRoad.getStartPosition(_globeLocation); //Scene

        var success = false;
        var point = null;
        if (this.projectOnGround) {
            //[IR-464665] Adding an offset on Z axis for the ground computation
            currentPathPosition.z += this._securityDist;

            //We check here if the path is placed above a ground
            var rm = STU.RenderManager.getInstance();
            var pickingParams = {
                position: currentPathPosition,
                reference: _globeLocation,
                pickGeometry: true,
                pickTerrain: true,
                pickWater: false
            };
            point = rm._pickGroundFromPosition(pickingParams).point;
            success = (point !== null && point !== undefined && point instanceof DSMath.Point);

            if (!success) {
                console.warn("[TrafficManager] Ground not found for " + currentRoad.getName());
            }
        }

        var trackingPosition = success ? new DSMath.Vector3D(point.x, point.y, point.z) : currentPathPosition.clone();

        var localPathDirection = new DSMath.Vector3D();
        var upVector = new DSMath.Vector3D(0, 0, 1);
        trackingPosition.z += 1500;
        currentPathPosition.z = 0;

        while (currentPathValue < currentRoad.getLength()) {
            currentPathValue += this.samplingDistance;
            if (currentPathValue > currentRoad.getLength()) {
                currentPathValue = currentRoad.getLength();
            }

            var newPosition = currentRoad.getValue(currentPathValue / currentRoad.getLength(), _globeLocation);
            newPosition.z = 0;
            var compareVector = newPosition.clone();
            compareVector.sub(currentPathPosition);
            if (compareVector.norm() > 1) {
                localPathDirection = compareVector.clone();
            }
            localPathDirection.normalize();
            var rightVector = DSMath.Vector3D.cross(localPathDirection, upVector);
            rightVector.normalize();

            // Compute wheels intersections & Add to the intersections list
            var height = this.computeTrafficWheelIntersections(currentRoad, trackingPosition, rightVector, success);

            //Adapt the tracking position for next round
            if (success) {
                if ((trackingPosition.z - height) !== 1500 && height !== null) {
                    trackingPosition.z = height + 1500;
                }
            }
            currentPathPosition = newPosition;
            //this._EntirePositionList.push(trackingPosition.clone()); //currentRoad.positionList.push(trackingPosition.clone());
            //this._EntirePositionList.push(new TrafficPosition(trackingPosition.clone(), currentRoad));
            this._positionList.push(new TrafficPosition(trackingPosition.clone(), currentRoad));

            // Add the tracking position 
            if (this.displayComputedPath) {
                var _scale = (_globeLocation !== null && _globeLocation !== undefined) ? _globeLocation.getScale("World") : 1;
                var tmpPoint = new DSMath.Point(trackingPosition.x, trackingPosition.y, trackingPosition.z);
                if (_globeLocation !== null && _globeLocation !== undefined) {
                    var transformScene = _globeLocation.getTransform();
                    var transformSceneWorld = _globeLocation.getTransform("World");
                    var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());
                    //tmpPoint = new DSMath.Point(trackingPosition.x, trackingPosition.y, trackingPosition.z);
                    tmpPoint.applyTransformation(transfoScene2World);
                }

                var localTransfo = new DSMath.Transformation();
                var iColor = new STU.Color(0, 0, 255);
                var render = STU.RenderManager.getInstance();
                localTransfo.vector = trackingPosition;
                render._createSphere({
                    radius: 300 * _scale,
                    position: localTransfo,
                    color: iColor,
                    alpha: 255,
                    lifetime: -1
                });
            }
            trackingPosition.add(compareVector);
        }
    };

    TrafficManager.prototype.computeTrafficWheelIntersections = function (iRoad, iTrackingPosition, iRightVector, iGroundIncluded) {
        var origin = iTrackingPosition.clone();
        var right = iRightVector.clone();
        var rightOrigin = origin.clone();
        var leftOrigin = origin.clone();
        var moveRight = right.clone();
        var moveLeft = right.clone();
        moveRight.multiplyScalar(750);
        moveLeft.multiplyScalar(-750);
        rightOrigin.add(moveRight);
        leftOrigin.add(moveLeft);

        var rightIntersection;
        var leftIntersection;
        var _globeLocation = null;

        if (iGroundIncluded) {
            rightIntersection = this.getFirstIntersectPointDown(rightOrigin, iRoad.getLocation());
            leftIntersection = this.getFirstIntersectPointDown(leftOrigin, iRoad.getLocation());
            if (rightIntersection.actor !== null && rightIntersection.actor !== undefined) {
                _globeLocation = rightIntersection.actor.getLocation();
            }
        }
        else {
            var upVector = new DSMath.Vector3D(0, 0, 1);

            rightIntersection = new STU.Intersection();
            rightIntersection.setActor(this.path);
            rightIntersection.setNormal(upVector);
            rightIntersection.point = new DSMath.Point();
            this.vectorToPoint(rightOrigin, rightIntersection.point);

            leftIntersection = new STU.Intersection();
            leftIntersection.setActor(this.path);
            leftIntersection.setNormal(upVector);
            leftIntersection.point = new DSMath.Point();
            this.vectorToPoint(leftOrigin, leftIntersection.point);
        }

        this._rightIntersections.push(rightIntersection);
        this._leftIntersections.push(leftIntersection);
        // var intersect = new TrafficIntersection(leftIntersection, rightIntersection, iRoad);
        // this._intersections.push(intersect);

        // Debug //
        if (this.displayComputedPath) {
            var _scale = 1;
            var rightIntersectionWorld = rightIntersection.getPoint();//new DSMath.Point(rightIntersection.getPoint().x, rightIntersection.getPoint().y, rightIntersection.getPoint().z);
            var leftIntersectionWorld = leftIntersection.getPoint();//new DSMath.Point(leftIntersection.getPoint().x, leftIntersection.getPoint().y, leftIntersection.getPoint().z);
            if (_globeLocation !== null && _globeLocation !== undefined) {
                var transformScene = _globeLocation.getTransform();
                var transformSceneWorld = _globeLocation.getTransform("World");
                var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());
                rightIntersectionWorld.applyTransformation(transfoScene2World);
                leftIntersectionWorld.applyTransformation(transfoScene2World);
                _scale = transformSceneWorld.matrix.getScale();
            }

            var localTransfo = new DSMath.Transformation();
            var iColor = new STU.Color(0, 255, 0);
            var render = STU.RenderManager.getInstance();
            if (rightIntersection !== 0) {
                localTransfo.vector = rightIntersectionWorld;//this.pointToVector(rightIntersection.getPoint());
                render._createSphere({
                    radius: 300 * _scale,
                    position: localTransfo,
                    color: iColor,
                    alpha: 255,
                    lifetime: -1
                });
            }
            if (leftIntersection !== 0) {
                localTransfo.vector = leftIntersectionWorld;//this.pointToVector(leftIntersection.getPoint());
                render._createSphere({
                    radius: 300 * _scale,
                    position: localTransfo,
                    color: iColor,
                    alpha: 255,
                    lifetime: -1
                });
            }
        }

        if (rightIntersection !== 0 && leftIntersection !== 0) {
            if (iGroundIncluded) {
                return (rightIntersection.getPoint().z - leftIntersection.getPoint().z) / 2 + rightIntersection.getPoint().z;
            }
            else {
                return 0;
            }
        }

        return null;
    };

    TrafficManager.prototype.initCars = function () {
        // [IR-465284] [IR-465278] computing driving car count according on traffic load
        var carCountForLoad = this._randomizedCarsActorsArray.length;

        // computing driving cars positions according to dispersion
        // the computed positions are in fact indices of the discretized position list
        var randomPositions = [];
        randomPositions[0] = 0; // first car position is always the begining of the path

        for (var i = 1; i < carCountForLoad; i++) {
            // important to have a stable random seed when replaying in ODT 
            var rnd = this._isODT ? this.seededRandom() : Math.random();
            //var value = (i + (rnd * this._trafficDispersion)) / carCountForLoad * (this._positionList.length);

            var distanceNeeded = (this._randomizedCarsActorsArray[i].CarController.__internal__.carLength * 0.5) + (this._randomizedCarsActorsArray[i - 1].CarController.__internal__.carLength * 0.5) + this._securityDist;

            var value = (i + (rnd * this._trafficDispersion)) / carCountForLoad * (this._positionList.length - ((distanceNeeded * this._trafficDispersion) / this.samplingDistance));
            randomPositions[i] = value;

            if ((randomPositions[i] - randomPositions[i - 1]) < (distanceNeeded / this.samplingDistance)) {
                var diff = (distanceNeeded / this.samplingDistance) - (randomPositions[i] - randomPositions[i - 1]);
                randomPositions[i] += diff;
            }
        }


        var pathFirstPos = this._trafficPaths[0].getStartPosition();
        //Configure cars Array ==> Maybe make a TrafficCar Struct
        for (var i = 0; i < carCountForLoad; i++) {
            this._randomizedCarsActorsArray[i].CarController.setCarPosition(pathFirstPos);
            this._carLength.push(this._randomizedCarsActorsArray[i].CarController.__internal__.carLength);
            this._carWidth.push(this._randomizedCarsActorsArray[i].CarController.__internal__.carWidth);
            this._carVisibility.push(true);
            this._carVirtualPosition[i] = 0;
            this._carInitialPositions.push(randomPositions[i]);
            this._carsCollectionscale[i] = this._randomizedCarsActorsArray[i].getScale();
        }

        this._estimedTime = this._positionList.length;
        this._visibiltyUpdateNeeded = true;
    };


    TrafficManager.prototype.updateTraffic = function () {
        var currentReference = this._currentTime * this._convertedSpeed;

        for (var i = 0; i < this._randomizedCarsActorsArray.length; i++) {
            var currentValue = this._carInitialPositions[i] - currentReference;

            if (currentValue <= 0) {
                currentValue += this._estimedTime;
            }

            if (currentValue + 1 < this._positionList.length) {

                currentValue = this._positionList.length - 1 - currentValue;
                //currentValue = this._positionList.length - currentValue;
                var previousValue = this._carVirtualPosition[i];

                //Ici on gere le changement de route
                if (previousValue > currentValue) {
                    this._randomizedCarsActorsArray[i].CarController.setCarPosition(this._positionList[0].position.clone());
                    previousValue = 0;
                }

                this._carVirtualPosition[i] = currentValue;

                var previousPosition = this.getTrafficPosition(previousValue);
                var nextPosition = this.getTrafficPosition(currentValue);

                if (nextPosition === undefined) {
                    return;
                }

                //3 times the car length 
                var carPathRatio = this._carLength[i] * 3 / this._totalPathLength * this._positionList.length;
                var idx = Math.min(this._positionList.length - 1, currentValue + carPathRatio);
                //var nextAheadPosition = this.getTrafficPosition(idx);
                var nextAheadPosition = this.getTrafficPosition(idx, currentValue);

                var nextAheadDirection = DSMath.Vector3D.sub(nextAheadPosition, nextPosition).normalize();
                nextPosition.sub(previousPosition);
                var nextDirection = nextPosition.clone().normalize();

                var angleAhead = nextDirection.getSignedAngleTo(nextAheadDirection, DSMath.Vector3D.zVect);

                this._randomizedCarsActorsArray[i].translate(nextPosition);

                var intersections = this.getTrafficCarIntersections(i, currentValue);

                if (intersections !== null) {
                    this._randomizedCarsActorsArray[i].CarController.trafficManagerUpdate(intersections, this._deltaTime / 1000, this._convertedSpeed * this.samplingDistance, this.rotateWheels, angleAhead);

                    if (this._carVisibility[i] === false || this._visibiltyUpdateNeeded === true) {
                        this._randomizedCarsActorsArray[i].setVisible(true);
                        this._carVisibility[i] = true;
                    }
                }
                else {
                    if (this._carVisibility[i] === true) {
                        this._randomizedCarsActorsArray[i].setVisible(false);
                        this._carVisibility[i] = false;
                    }
                }

            }
            else {
                if (this._carVisibility[i] === true) {
                    this._randomizedCarsActorsArray[i].setVisible(false);
                    this._carVisibility[i] = false;
                }
            }

        }
    };

    TrafficManager.prototype.getTrafficPosition = function (i, currentValue) {
        if (i < 0 || i > this._positionList.length) {
            console.warn('[TrafficManager]: getPosition -> i out of boundaries');
            return;
        }
        var floor = Math.floor(i);
        var ceil = Math.ceil(i);
        var percent = i - floor;

        if (currentValue !== undefined && currentValue !== null) {
            var currentValueFloor = Math.floor(currentValue);
            var diff = i - currentValue;
            for (var j = 0; j < Math.ceil(diff) ; j++) {
                if (this._positionList[Math.floor(i - j)].road === this._positionList[currentValueFloor].road) {
                    return this._positionList[Math.floor(i - j)].position.clone();
                }
            }
        }
        //console.log(i);
        var pos1 = this._positionList[floor].position.clone();
        var pos2 = this._positionList[ceil].position.clone();

        pos1.x = pos2.x * percent + (1 - percent) * pos1.x;
        pos1.y = pos2.y * percent + (1 - percent) * pos1.y;
        pos1.z = pos2.z * percent + (1 - percent) * pos1.z;

        return pos1;
    };

    /**
     * Get the intersections associated to the car, at a certain position
     * @method
     * @private
     */
    TrafficManager.prototype.getTrafficCarIntersections = function (carNumber, currentValue) {
        var carLength = this._carLength[carNumber] / 1000;
        //var carWidth = this._carWidth[carNumber] / 1000;

        var frontValue = Math.min(currentValue + carLength / 2, this._positionList.length);
        var backValue = Math.max(currentValue - carLength / 2, 0);

        var intersections = {};
        var intersectionFL;
        var intersectionFR;
        var intersectionBL;
        var intersectionBR;
        //var isOutOfBound = Math;.ceil(currentValue) > this._positionList.length || Math.ceil(frontValue) > this._positionList.length;
        var isNotOutOfBound = Math.ceil(currentValue) < this._positionList.length && Math.ceil(frontValue) < this._positionList.length;

        //the nose of the car is not on the same road
        if (isNotOutOfBound && this._positionList[Math.ceil(currentValue)].road !== this._positionList[Math.ceil(frontValue)].road) {
            var diff = frontValue - currentValue;
            intersectionFL = this.getAverageIntersection(this._leftIntersections, frontValue - diff);
            intersectionFR = this.getAverageIntersection(this._rightIntersections, frontValue - diff);
            intersectionBL = this.getAverageIntersection(this._leftIntersections, backValue - diff);
            intersectionBR = this.getAverageIntersection(this._rightIntersections, backValue - diff);
            return null;
        }

            //the back of the car is not on the same road
        else if (this._positionList[Math.ceil(currentValue)].road !== this._positionList[Math.floor(backValue)].road) {
            var diff = currentValue - backValue;
            intersectionFL = this.getAverageIntersection(this._leftIntersections, frontValue + diff);
            intersectionFR = this.getAverageIntersection(this._rightIntersections, frontValue + diff);
            intersectionBL = this.getAverageIntersection(this._leftIntersections, backValue + diff);
            intersectionBR = this.getAverageIntersection(this._rightIntersections, backValue + diff);
            return null;
        }
            //All car's part are on the same road
        else {
            intersectionFL = this.getAverageIntersection(this._leftIntersections, frontValue);
            intersectionFR = this.getAverageIntersection(this._rightIntersections, frontValue);
            intersectionBL = this.getAverageIntersection(this._leftIntersections, backValue);
            intersectionBR = this.getAverageIntersection(this._rightIntersections, backValue);
        }

        /*this.checkAndRectifyIntersection(intersectionFL, intersectionBL, carLength);
        this.checkAndRectifyIntersection(intersectionFR, intersectionBR, carLength);
        this.checkAndRectifyIntersection(intersectionFR, intersectionFL, carWidth);
        this.checkAndRectifyIntersection(intersectionBR, intersectionBL, carWidth);*/
        intersections.WheelFL = intersectionFL;
        intersections.WheelFR = intersectionFR;
        intersections.WheelBL = intersectionBL;
        intersections.WheelBR = intersectionBR;
        return intersections;
    };

    /**
     * Get the intersection at a specific value
     * @method
     * @private
     */
    TrafficManager.prototype.getAverageIntersection = function (intersectionList, value) {
        var floor = Math.floor(value);
        var ceil = Math.ceil(value);
        var percent = value - floor;
        var intersect1 = intersectionList[floor];
        var intersect2 = intersectionList[ceil];
        if (intersect1 === 0 || intersect2 === 0 || intersect2 === undefined || intersect1 === undefined) {
            return 0;
        }
        if (percent === 0) {
            return intersect1;
        }

        var result = new STU.Intersection();
        var p1 = intersect1.getPoint();
        var p2 = intersect2.getPoint();
        var n1 = intersect1.getNormal();
        var n2 = intersect2.getNormal();
        p1.x = p2.x * percent + (1 - percent) * p1.x;
        p1.y = p2.y * percent + (1 - percent) * p1.y;
        p1.z = p2.z * percent + (1 - percent) * p1.z;
        n1.x = n2.x * percent + (1 - percent) * n1.x;
        n1.y = n2.y * percent + (1 - percent) * n1.y;
        n1.z = n2.z * percent + (1 - percent) * n1.z;
        result.setPoint(p1);
        result.setNormal(n1);
        result.setActor(intersect1.getActor());
        return result;
    };

    /**
     * Take 2 intersection, and recitfy the distance if needed
     * @method
     * @private
     */
    TrafficManager.prototype.checkAndRectifyIntersection = function (i1, i2, distance) {
        if (i1 === 0 || i2 === 0) {
            return;
        }
        var v1 = this.pointToVector(i1.getPoint());
        var v2 = this.pointToVector(i2.getPoint());
        var diff = DSMath.Vector3D.sub(v1, v2);
        var moveCoef = (diff.norm() - distance * 1000) / 2;
        diff.normalize();
        diff.multiplyScalar(moveCoef);
        v1.sub(diff);
        v2.add(diff);
        this.vectorToPoint(v1, i1.point);
        this.vectorToPoint(v2, i2.point);
    };

    /**
     * Start the traffic by increasing the cars speed.
     * @method
     * @public
     */
    TrafficManager.prototype.startTraffic = function () {
        this._trafficStart = true;
    };

    /**
     * stop the traffic by decreasing the cars speed.
     * @method
     * @public
     */
    TrafficManager.prototype.stopTraffic = function () {
        this._trafficStart = false;
    };

    TrafficManager.prototype.isTrafficStopped = function () {
        return (this._trafficStart === false && this._stopTimer === this._timeToStop);
    };


    //////////////////////////////////////////////////////////////////////////////////

    /**
     * Use the coordinate of a point to set a vector
     * @method
     * @private
     */
    TrafficManager.prototype.pointToVector = function (point) {
        var vector = new DSMath.Vector3D(point.x, point.y, point.z);
        return vector;
    };

    /**
     * Use the coordinate of a point to set a vector
     * @method
     * @private
     */
    TrafficManager.prototype.vectorToPoint = function (vector, point) {
        point.x = vector.x;
        point.y = vector.y;
        point.z = vector.z;
    };

    /**
     * Do a raycast and return the first intersection if there is any. If not, return 0
     * @method
     * @private
     */
    TrafficManager.prototype.getFirstIntersectPointDown = function (position, iGlobeLocation) {
        var renderManager = STU.RenderManager.getInstance();
        /*var rayVect = new STU.Ray();
        rayVect.origin.x = position.x;
        rayVect.origin.y = position.y;
        rayVect.origin.z = position.z;
        rayVect.direction.x = 0;
        rayVect.direction.y = 0;
        rayVect.direction.z = -1;
        rayVect.length = 1000000;
        //var intersectArray = renderManager._pickFromRay(rayVect);
        var intersectArray = renderManager._pickFromRay(rayVect, true, true, iGlobeLocation);
        if (intersectArray.length > 0) {
            return intersectArray[0];
        } else {
            return 0;
        }*/
        var pickingParams = {
            position: position,
            reference: iGlobeLocation,
            pickGeometry: true,
            pickTerrain: true,
            pickWater: false
        };
        var intersection = renderManager._pickGroundFromPosition(pickingParams);
        if (intersection !== null && intersection !== undefined) {
            return intersection;
        } else {
            return 0;
        }
    };

    /**
     * Permit to activate/deactive all car's clickable variable
     * @method
     * @private
     */
    TrafficManager.prototype.setCarsClickablity = function (iBool) {
        for (var i = 0; i < this._carsActorsArray.length; i++) {
            this._carsActorsArray[i].clickable = iBool;
        }
    };

    TrafficManager.prototype.setCarsVisibility = function (iBool) {
        for (var i = 0; i < this._carsActorsArray.length; i++) {
            this._carsActorsArray[i].visible = iBool;
        }
    };


    STU.TrafficManager = TrafficManager;
    return TrafficManager;

});

define('StuMiscContent/StuTrafficManager', ['DS/StuMiscContent/StuTrafficManager'], function (TrafficManager) {
    'use strict';

    return TrafficManager;
});
