define('DS/StuScenario/StuScenarioSentence', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/EPTaskPlayer/EPTask'], function (STU, Instance, Task) {
    'use strict';

    /*****************************************************************************
    Task dedicated to Sentence execution. This task will invoke the "execute"
    method on sentence instances.
	
    @constructor
    @param {ScenarioSentence} iScenarioSentence - The sentence instance to "execute".
    *****************************************************************************/
    var ScenarioSentenceTask = function (iScenarioSentence) {
        Task.call(this);

        this.sentence = iScenarioSentence;

        this.blockMode = "sensor";
        this.playMode = "normal";
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ScenarioSentenceTask.prototype = new Task();
    ScenarioSentenceTask.constructor = ScenarioSentenceTask;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////
    ScenarioSentenceTask.prototype.onExecute = function (iExContext) {
        if (this.sentence !== undefined && this.sentence !== null ) {
            // console.log("[ScenarioSentenceTask | task of "+this.sentence.DebugPosition()+"::onExecute] play Mode : " +this.playMode + " / block Mode : " +this.blockMode);
            if (this.playMode == "normal") {
                if (this.blockMode == "sensor"){
                    var AllSensorsValid = this.sentence.executeSensors(iExContext);
                    if (AllSensorsValid) {
                        this.blockMode = "driver";
                        this.sentence.startDrivers();
                    }
                }
                else if (this.blockMode == "driver"){
                    this.sentence.executeDrivers(iExContext);
                }
                else{
                    console.error("Incorrect mode of execution for sentence (expecting 'sensor' or 'driver' but got : " + this.sentence.stuId + " instead )");
                }
                    
            }
            else if (this.playMode == "while"){
                if (this.blockMode == "sensor") {
                    var AllSensorsValid = this.sentence.executeSensors(iExContext);
                    if (AllSensorsValid) {
                        this.blockMode = "driver";
                        this.sentence.startDrivers();
                    }
                }
                else if (this.blockMode == "driver") {
                    if (this.sentence.executeSensors(iExContext)){
                        this.sentence.executeDrivers(iExContext);
                    }
                    else{
                        this.sentence.stopAllDrivers();
                        this.blockMode = "sensor";
                        //console.log("[ScenarioSentenceTask | task of "+this.sentence.DebugPosition()+"::onExecute] BONUS play Mode : " +this.playMode + " / block Mode : " +this.blockMode);
                    }
                }
            }
        }
    };

    /*****************************************************************************
    Instance dedicated to sentence definition.
    The "execute" method should be overridden on each Sentence instance.

    @constructor
    *****************************************************************************/

    /**
    * Describe a sentence object.
    * A sentence is a fragment of the natural language logics.
    * At this point a sentence has a "If ... Do ..." Semantic
    *
    * @exports ScenarioSentence
    * @class 
    * @constructor
    * @private
    * @extends STU.Instance
    * @memberof STU
    */
    var ScenarioSentence = function () {
        Instance.call(this);

        this.name = "ScenarioSentence";

        /*
        * This is the collection of blocks contained within the act.
        *
        * @property blocks
        * @private
        * @type {Array.<STU.ScenarioBlock>}
        */
        this.blocks = [];

        /*
            NEW CAP MODEL
        */
        this.sensorBlocks = [];
        this.sensorOperators = [];
        this.driverBlocks = [];
        this.driverOperators = [];

        this.highLevelSensor = [];
        this.highLevelDriver = [];


        /*
        * This is the collection of blocks contained within the act.
        *
        * @property blocks
        * @private
        * @type {Array.<STU.ScenarioBlock>}
        */
        this.blocks = [];

        /*
        * Tells if the sentence is active or not.
        *
        * @property activation
        * @private
        * @type {boolean}
        * @default true
        */
        this.activation = true;

        /*
        * Tells if the sentence is in repeat mode or not.
        *   used at end of this.executeDrivers to decide if the sentence is deactivated or reset
        * @property repeatability
        * @private
        * @type {boolean}
        * @default true
        */
        this.repeatability = false;

        /*
        * As soon as a sentence has been fully executed in play mode this value is set to true.
        *
        * @property executed
        * @private
        * @type {boolean}
        * @default false
        */
        this.executed = false;

        /**
         * This is the associated task that will be executed at the run time.
         *
         * @member
         * @private
         * @type {EP.Task}
         */
        this.associatedTask;

        this.indexDriver = 0;
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ScenarioSentence.prototype = new Instance();
    ScenarioSentence.prototype.constructor = ScenarioSentence;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////

    /**
     * Process executed when STU.ScenarioSentence is initializing.
     *
     * @method
     * @private
     */
    ScenarioSentence.prototype.onInitialize = function () {
        
        if (this.activity == false) return;

        STU.Instance.prototype.onInitialize.call(this);

        this.highLevelSensor = [];
        this.highLevelDriver = [];
        var lowLevelSensor = [];
        var lowLevelDriver = [];


        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] ''''''''''''''''''''''''''''''''''''''''''");
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] '   Initialization of Scenario Sentence  '");
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] ''''''''''''''''''''''''''''''''''''''''''");
        // console.log(this.sensorOperators);

        // IR-644550 : continue to support old formating : "EachTime"
        if(this.sensorOperators[0] == "Each Time" || this.sensorOperators[0] == "EachTime" || this.sensorOperators[0] == "While")
            this.repeatability = true;

        // Initialization of Sensors block
        for (var blockIndex = 0; blockIndex < this.sensorBlocks.length; blockIndex++) {
        	var block = this.sensorBlocks[blockIndex];

        	// Initialize block and register it if the initialization is OK
            // Here we call directly the onInitialize of block (instead of initialize() because we need the result right now)
            // So we need to set the 'initialized' state here because it won't be set where it should be (in StuInstance::initialize())
            block.initialized = true;
        	if (block.onInitialize("Sensor")) {
        		if (this.sensorOperators[blockIndex] == "Or") {
        			this.highLevelSensor.push(lowLevelSensor);
        			lowLevelSensor = [];
        		}
        		lowLevelSensor.push(block);

        		if (blockIndex == this.sensorBlocks.length - 1) {
        			this.highLevelSensor.push(lowLevelSensor);
        		}
            }
            // See below comment on [IR-639183]
            else {
                if (blockIndex == this.sensorBlocks.length - 1) {
                    this.highLevelSensor.push(lowLevelSensor);
                }
            }
        }

        // Debug this.highLevelSensor
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] Dumping all sensors");
        // console.log(this.highLevelSensor);
        // for (var i = 0; i < this.highLevelSensor.length; i++) {
        //     for (var j = 0; j < this.highLevelSensor[i].length; j++) {
        //         //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] sensor ["+i+","+j+"]");
        //         console.log(this.highLevelSensor[i][j]);
        //     }
        // }

        // Initialization of driver blocks
        for (var blockIndex = 0; blockIndex < this.driverBlocks.length; blockIndex++) {
        	var block = this.driverBlocks[blockIndex];

        	// Initialize block and register it if the initialization is OK
            // Here we call directly the onInitialize of block (instead of initialize() because we need the result right now)
            // So we need to set the 'initialized' state here because it won't be set where it should be (in StuInstance::initialize())
            block.initialized = true;
        	if (block.onInitialize("Driver")) {
        		if (this.driverOperators[blockIndex] == "Then") {
        			this.highLevelDriver.push(lowLevelDriver);
        			lowLevelDriver = [];
        		}
        		lowLevelDriver.push(block);

        		if (blockIndex == this.driverBlocks.length - 1) {
        			this.highLevelDriver.push(lowLevelDriver);
        		}
        	}
            // [IR-639183] When a series of block ends with an invalid block (ie. failing to block.onInitialize()), 
            // it fails to add the last lowLevelDriver in highLevelDriver... which leads to invalid behavior :(
            // So we are doing it here
            else {
        		if (blockIndex == this.driverBlocks.length - 1) {
        			this.highLevelDriver.push(lowLevelDriver);
        		}
            }
        }

        // Debug this.highLevelDriver
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] Dumping all drivers");
        // console.log(this.highLevelDriver);
        // for (var i = 0; i < this.highLevelDriver.length; i++) {
        //     for (var j = 0; j < this.highLevelDriver[i].length; j++) {
        //         //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] driver ["+i+","+j+"]");
        //         console.log(this.highLevelDriver[i][j]);
        //     }
        // }

    };



    /**
     * Process executed when STU.ScenarioSentence is disposing.
     *
     * @method
     * @private
     */
    ScenarioSentence.prototype.onDispose = function () {
        for (var blockIndex in this.blocks) {
            var block = this.blocks[blockIndex];
            if (block instanceof STU.ScenarioBlock) {
                block.dispose();
            }
        }

        STU.Instance.prototype.onDispose.call(this);
    };

    /**
     * Process executed when STU.ScenarioSentence is activating.
     *
     * @method
     * @private
     */
    ScenarioSentence.prototype.onActivate = function () {
        
        if (this.activation == false)
            return;

        Instance.prototype.onActivate.call(this);


        for (var blockIndex in this.sensorBlocks) {
            var block = this.sensorBlocks[blockIndex];
            if (block instanceof STU.ScenarioBlock) {
                block.activate();
            }
        }

        for (var blockIndex in this.driverBlocks) {
            var block = this.driverBlocks[blockIndex];
            if (block instanceof STU.ScenarioBlock) {
                block.activate();
            }
        }

        this.associatedTask = new ScenarioSentenceTask(this);
        this.associatedTask.playMode = this.sensorOperators[0] == "While" ? "while" : "normal";
        EP.TaskPlayer.addTask(this.associatedTask);

        // TEMP ???
        if (EP.TaskPlayer.isPlaying())
            this.associatedTask.start();
        // END TEMP
    };

    /**
     * Process executed when STU.ScenarioSentence is deactivating.
     *
     * @method
     * @private
     */
    ScenarioSentence.prototype.onDeactivate = function () {

        if (this.activation == false)
            return;

        //console.log(new Error().stack);
        this.executed = false;

        for (var blockIndex in this.sensorBlocks) {
            var block = this.sensorBlocks[blockIndex];
            if (block instanceof STU.ScenarioBlock) {
                block.deactivate();
            }
        }

        for (var blockIndex in this.driverBlocks) {
            var block = this.driverBlocks[blockIndex];
            if (block instanceof STU.ScenarioBlock) {
                block.deactivate();
            }
        }

        // See if it is needed to keep this block
        // It may be usefull when switching back to an old act : to be tested
        // for (var k = 0; k < this.highLevelSensor.length; k++){
        //     for (var l = 0; l < this.highLevelSensor[k].length; l++){
        //         this.highLevelSensor[k][l].validated = false;
        //     }
        // }

        if (this.associatedTask !== undefined && this.associatedTask !== null){

            EP.TaskPlayer.removeTask(this.associatedTask);
            delete this.associatedTask;
        }

        Instance.prototype.onDeactivate.call(this);
    };

    /**
     * Execute this STU.ScenarioSentence.
     *
     * @method
     * @private
     * @return {Boolean} : 'true' when all sensors have been validated, 'false'  when it is not
     */
    ScenarioSentence.prototype.executeSensors = function (iExContext) {
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeSensors]");

        // Dumping state of all sensors
        //var dump = " AVANT ";
        //for (var k = 0; k < this.highLevelSensor.length; k++){
        //   for (var l = 0; l < this.highLevelSensor[k].length; l++){
        //       dump += k+","+l+":"+this.highLevelSensor[k][l].validated+" / ";
        //   }
        //}

        var sensorValidator = true;
        for (var i = 0; i < this.highLevelSensor.length; i++) {
            sensorValidator = true;
            for (var j = 0; j < this.highLevelSensor[i].length && sensorValidator; j++) {
                if (this.highLevelSensor[i][j].getCapacityType() == "Event") {
                    sensorValidator = sensorValidator && this.highLevelSensor[i][j].validated;
                }
                else {
                    sensorValidator = sensorValidator && this.highLevelSensor[i][j].execute(iExContext);
                }
            }
            // reset all sensor event flag to false
            for (var j = 0; j < this.highLevelSensor[i].length; j++)
                this.highLevelSensor[i][j].validated = false;

            // Mechanism for "Or" operator
            // it is sufficient tu have to true in one loop to consider all sensors as valid
            if (sensorValidator)
                return true;
        }

        // Dumping state of all sensors
        //dump += " APRES :";
        //for (var k = 0; k < this.highLevelSensor.length; k++){
        //   for (var l = 0; l < this.highLevelSensor[k].length; l++){
        //       dump += k+","+l+":"+this.highLevelSensor[k][l].validated+" / ";
        //   }
        //}
        //console.log(dump);
        //console.log("[M1Q-ScenarioSentence::"+this.name+"::executeSensors] sensor valid ? " + sensorValidator);
        return sensorValidator;
    };


    /**
     * Execute this STU.ScenarioSentence.
     *
     * @method
     * @private
     * @return {Boolean} : 'true' when all drivers have been succesfully executed, 'false'  when it is not finished yet
     */
    ScenarioSentence.prototype.executeDrivers = function (iExContext) {
        // console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] block group #" + this.indexDriver);
        var driverValidator = true;
        if (this.indexDriver >= this.highLevelDriver.length)
            return false;

        for (var j = 0; j < this.highLevelDriver[this.indexDriver].length; j++) {
            var block = this.highLevelDriver[this.indexDriver][j];
            // console.log('[M1Q-ScenarioSentence::'+this.name+'::executeDrivers] executeDrivers ['+this.indexDriver+']['+j+'] block.validated : '+block.validated);
            if (!block.validated) {
                // console.log('[M1Q-ScenarioSentence::'+this.name+'::executeDrivers] executeDrivers : executing driver ['+this.indexDriver+']['+j+']');
                driverValidator = block.execute(iExContext) && driverValidator;
            }
        }

        // At this step, the executed block above may have deleted this current sentence...
        // In this case, the rest of the function has non sense
        if (!this.isActive())
            return;

        // 'driverValidator' indicates if the low level driver block group is ended.
        // If it is, we will play the next low level driver block group
        if (driverValidator){
            // console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] block group  "+this.indexDriver+" validated");
            this.unvalidateAllDriverBlock();
            this.indexDriver++;

            if (this.indexDriver === this.highLevelDriver.length) {
                this.indexDriver = 0;
                if (this.repeatability == true)
                    this.associatedTask.blockMode = "sensor";
                else
                    this.onDeactivate();
            }
        }
        else{
            return false;
        }
    };

    ScenarioSentence.prototype.stopAllDrivers = function () {
        // console.log("[M1Q-ScenarioSentence::"+this.name+"::stopAllDrivers]");
        for (var i = 0; i < this.highLevelDriver.length; i++){
            for (var j = 0; j < this.highLevelDriver[i].length; j++){
                if (this.highLevelDriver[i][j].capacity !== undefined && this.highLevelDriver[i][j].capacity !== null && this.highLevelDriver[i][j].capacity instanceof STU.Service) {
                    if (this.highLevelDriver[i][j].capacity.isPlaying())
                        this.highLevelDriver[i][j].capacity.stop();
                    this.highLevelDriver[i][j].startedOnce = false;
                    // console.log("["+i+"]["+j+"] validated false");
                    this.highLevelDriver[i][j].validated = false;
                }
            }
        }
        this.indexDriver = 0;
    }

    ScenarioSentence.prototype.unvalidateAllDriverBlock = function () {
        for (var i = 0; i < this.highLevelDriver.length; i++){
            for (var j = 0; j < this.highLevelDriver[i].length; j++){
                this.highLevelDriver[i][j].reset();
            }
        }
    }

    ScenarioSentence.prototype.startDrivers = function () {
        // console.log("[M1Q-ScenarioSentence::"+this.name+"::startDrivers]");
        // prepare drivers
        // TODO ...
        // not sure :
        // this.stopAllDrivers(); // NOTE : if you do this here, stop event will be sent for every driver of the sentence at the beginning
        this.unvalidateAllDriverBlock();

        // tell associated task we are now in mode "driver"
        this.indexDriver = 0;
        this.associatedTask.blockMode = "driver";


    }
    /**
     * Execute this STU.ScenarioSentence.
     *
     * @method
     * @private
     * @return {Boolean}
     */
     /*  USELESS NOW, NEED TO BE REMOVED
    ScenarioSentence.prototype.onEventTriggered = function (iBlock) {
        //parse blocks

        // for (var i = 0; i < this.highLevelSensor.length; i++) {
        //     for (var j = 0; j < this.highLevelSensor[i].length; j++) {
        //         ////console.log("[M1Q-ScenarioSentence::"+this.name+"::executeDrivers] ["+i+","+j+"]");
        //         //console.log(this.highLevelSensor[i][j].capacity);
        //         if (this.highLevelSensor[i][j] == iBlock)
        //             this.highLevelSensor[i][j].validated = true;
        //             console.log('[M1Q-ScenarioSentence::'+this.name+'::executeDrivers] sensor triggered in highLevelSensor #' + i);
        //     }
        // }

        if (this.associatedTask.blockMode == "driver" && this.repeatability) { // if drivers are currently running 
            if (this.executeSensors()) { // execute sensors to see if we need to stop currently running drivers and then start new one
                this.stopAllDrivers();
                this.unvalidateAllDriverBlock();
                this.startDrivers();

            }

        }
    };
    */
    /**
     * Restart this STU.ScenarioSentence.
     *
     * @method
     * @private
     * @return {Boolean}
     */
    ScenarioSentence.prototype.restart = function () {



        // restart the sentence
        if (this.executed == true) {
            this.executed = false;

            for (var blockIndex in this.blocks) {
                var block = this.blocks[blockIndex];
                if (block instanceof STU.ScenarioBlock) {
                    if (block.isEmpty() != true)
                    block.executed = false;
                }
            }
        }



        return;
    }

    /**
     * Tell if this STU.ScenarioSentence contain a sensor.
     *
     * @method
     * @private
     * @return {Boolean}
     */
    ScenarioSentence.prototype.containSensor = function () {
        var result = false;

        //parse blocks
        for (var blockIndex in this.blocks) {
            var block = this.blocks[blockIndex];
            if (block instanceof STU.ScenarioSensor && block.isEmpty() == false) {
                result = true;
                break;
            }
        }

        return result;
    }

    /**
     * Return small string path giving info of block position.
     *
     * @method
     * @private
     */
    ScenarioSentence.prototype.DebugPosition = function () {
        var path = "";
        // Name of sentence
        if (this.name !== undefined && this.name !== null)
            path = "/" + this.name + path;
        else
            return "can't get name of block";

        // Name of paragraph
        if (this.parent != undefined && this.parent !== null && this.parent.name !== undefined && this.parent.name !== null)
            path = "/" + this.parent.name + path;
        else
            return "can't get name of sentence";

        // Name of Act
        if (this.parent.parent != undefined && this.parent.parent !== null && this.parent.parent.name !== undefined && this.parent.parent.name !== null)
            path = "/" + this.parent.parent.name + path;
        else
            return "can't get name of paragrpah";

        // Name of Scenario
        if (this.parent.parent.parent !== undefined && this.parent.parent.parent !== null && this.parent.parent.parent.parent != undefined && this.parent.parent.parent.parent !== null && this.parent.parent.parent.name !== undefined && this.parent.parent.parent.name !== null)
            path = "/" + this.parent.parent.parent.parent.name + path;
        else
            return "can't get name of scenario";

        return path;
    };

    // Expose only those entities in STU namespace.
    STU.ScenarioSentenceTask = ScenarioSentenceTask;
    STU.ScenarioSentence = ScenarioSentence;

    return ScenarioSentence;
});

define('StuScenario/StuScenarioSentence', ['DS/StuScenario/StuScenarioSentence'], function (ScenarioSentence) {
    'use strict';

    return ScenarioSentence;
});
