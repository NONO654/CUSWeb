define('DS/StuScenario/StuScenarioBlock', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/StuModel/StuServicesManager', 'DS/EPTaskPlayer/EPTask','DS/StuModel/StuService', 'DS/StuModel/StuAnimation'], function (STU, Instance, ServicesManager, Task) {
    'use strict';

    /*****************************************************************************
    Instance dedicated to block definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe a block object.
    * A block is a fragment of the sentence.
    * At this point a sentence has a "If ... Do ..." Semantic.
    * "If ..." and "Do ..." are two kinds of block.
    *
    * @exports ScenarioBlock
    * @class 
    * @constructor
    * @private
    * @extends STU.Instance
    * @memberof STU
    */
    var ScenarioBlock = function () {
        Instance.call(this);

        this.name = "ScenarioBlock";

        /**
         * This is the actor or one of its behavior on which the block is applied.
         *  
         * @member
         * @private
         * @type {STU.Actor | STU.Behavior}
         */
        this.subject = null;

        this.capacity = null;
        this.parameter = null;

        /*
        * As soon as a block has been executed in play mode this value is set to true.
        *
        * @property executed
        * @private
        * @type {boolean}
        * @default false
        */
        this.executed = false;

        this._functionPreparator;

        this.validated = false;

        this.blockType = "sensor";

        // Flag used by block hosting service capacity to know when to start the capacity
        this.startedOnce = false;

        // 
    };

    var GetActorOf = function(iActorOrBehavior) {
        return iActorOrBehavior instanceof STU.Behavior ? iActorOrBehavior.parent : iActorOrBehavior;
    }

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ScenarioBlock.prototype = new Instance();
    ScenarioBlock.prototype.constructor = ScenarioBlock;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////

    /**
     * Process executed when STU.ScenarioBlock is activating.
     *
     * @method
     * @private
     */
    ScenarioBlock.prototype.onActivate = function () {
        STU.Instance.prototype.onActivate.call(this);

        // if the block is empty it is considered as executed
        if (this.isEmpty() == true)
            this.executed = true;

        // When switching back to an old act, some block may keep their 'validated' state.
        // So here we force it to be 'false' when activating a block.
        this.validated = false;
    };
    /**
     * Process executed when STU.ScenarioBlock is activating.
     *
     * @method
     * @private
     */
    ScenarioBlock.prototype.onInitialize = function (iBlockType) {
        STU.Instance.prototype.onInitialize.call(this);

        this.blockType = iBlockType;
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] this");
        // console.log(this);
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] this.parameter");
        // console.log(this.parameter !== undefined && this.parameter !== null ? this.parameter : "NULL");
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] this.capacity");
        // console.log(this.capacity);
        if (this.capacity !== undefined && this.capacity !== null){

            // Test on time modifiers if any
            // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] onInitialize :");
            // console.log(this);

            // CAPACITY IS AN EVENT
            if (this.capacity instanceof STU.Event) {
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] capacity event to initialize (name :" + this.capacity.name + ")");
                // console.log(this.capacity);
                var event = EP.EventServices.getEventByType(this.capacity.name);

                // Some cowboy actor add "Event" at end (UIActor ...)
                if (event === undefined || event === null)
                    event = EP.EventServices.getEventByType(this.capacity.name + "Event");

                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] event found :");
                // console.log(event);
                // var event = STU[this.capacity.name]; pareil
                if (event !== null && event !== undefined) {

                    if (this.subject instanceof STU.Animation) {
                        this.subject.addObjectListener(event, this, 'onLocalSensorEventTriggered');
                        this.subject.parent.addObjectListener(event, this, 'onLocalSensorEventTriggered');
                    } else {
                        // retrieve actor (in some cases, this.subject ref a behavior of the actor, not the actor itself )
                        var actor = GetActorOf(this.subject);
                        actor.addObjectListener(event, this, 'onLocalSensorEventTriggered');
                        for (var i = 0; i < actor.behaviors.length; i++) {
                            actor.behaviors[i].addObjectListener(event, this, 'onLocalSensorEventTriggered');
                        }
                    }

                    return true;
                }
                else {
                    console.error("Initializing capacity, tried to get event '" + this.capacity.name + "' but it does not exist");
                    return false;
                }
            }
            // CAPACITY IS A SERVICE
            else if (this.capacity instanceof STU.Service) {
                if (this.capacity._mode == "function" || this.capacity._mode == "task") {
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] capacity service to initialize (name :" + typeof this.capacity.name + ")");
                    // console.log(this.capacity);

                    this.capacity.onInitialize();
                    
                    // Register event for service lifecycle
                    // /!\ can be optimized by listening event coming from its service :
                    //    > this.service.addObjectListener(STU.ServiceStartedEvent,this,'onServiceStarted');
                    // see in the future

                    EP.EventServices.addObjectListener(STU.ServiceStartedEvent,this,'onServiceStarted');
                    EP.EventServices.addObjectListener(STU.ServiceResumedEvent,this,'onServiceResumed');
                    EP.EventServices.addObjectListener(STU.ServicePausedEvent,this,'onServicePaused');
                    EP.EventServices.addObjectListener(STU.ServiceStoppedEvent,this,'onServiceStopped');
                    EP.EventServices.addObjectListener(STU.ServiceEndedEvent,this,'onServiceEnded');
                    return true;
                }
                else {
                    console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] Error initializing capacity. The mode is not correct or undefined");
                    return false;
                }


            }
            // CAPACITY IS A FUNCTION
            else if (this.capacity instanceof STU.Function) {

                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] capacity Function to initi");
                    if (this.capacity.parent != undefined && this.capacity.parent != null ) {

                        this.capacity.setCaller(this.subject);

                        return true;
                    }
                    else{
                        console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] Error initializing capacity, capacity has no parent");
                        return false;
                    }

            }
            else {
                console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] Error initializing capacity, capacity is not any of this type : Function, Service, Event");
                console.error(this.capacity);
            }

            // CAPACITY IS A FUNCTION
            //if (typeof this.capacity === 'function') {
           // }
        }

        // at this point the capacity is probably undefined, if there is a subject defined ... it is considered as an error. Otherwise it is juste an empty block
        if (this.subject !== undefined && this.subject !== null) {
            console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] Errror initializing capacity. May be capacity is undefined ");
        }

        return false;
    };

    ScenarioBlock.prototype.onServiceStarted = function (iEvent) {
        // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"] a service has been started');
        // console.log(iEvent);
        if(iEvent.service == this.capacity) {
            // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] i'm concerned by this event");
        }
    };
    ScenarioBlock.prototype.onServiceResumed = function (iEvent) {
        // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"] a service has been resumed');
        // console.log(iEvent);    
        if(iEvent.service == this.capacity) {
            // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] i'm concerned by this event");
        }
    };
    ScenarioBlock.prototype.onServicePaused = function (iEvent) {
        // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"] a service has been paused');
        // console.log(iEvent);
        if(iEvent.service == this.capacity) {
            // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] i'm concerned by this event");
        }
    };
    ScenarioBlock.prototype.onServiceStopped = function (iEvent) {
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] a service has been stopped");
        // console.log(iEvent);
        if(iEvent.service instanceof STU.Service && iEvent.service !== null) {
            // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] service stopped : " + iEvent.service.name);
            if (iEvent.service == this.capacity){
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] i'm concerned by this event (function mode)");
                this.validated = true;
                delete this.timeModifierCounter;
            }
        }
        else if (iEvent.service === null && iEvent.serviceName !== undefined && iEvent.serviceName !== null ) {
            // console.log('[ScenarioBlock | path : '+this.DebugPosition()+'] iEvent has no ref to any service but has service name set :' + iEvent.serviceName + "', will be compared to capacity name of block : '" +this.capacity.name+ "'");
            if (iEvent.serviceName == this.capacity.name && iEvent.actor == GetActorOf(this.subject)){
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] i'm concerned by this event (task mode) (same service name and same subject) ");
                this.validated = true;
                delete this.timeModifierCounter;
            }
        }
    };
    ScenarioBlock.prototype.onServiceEnded = function (iEvent) {

        // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"] a service has been ended');
        // console.log(iEvent);
        if (iEvent.service !== undefined &&  iEvent.service !== null && this.Capacity === iEvent.service) {

            // console.log("this.validated = true");
        }

    };

    ScenarioBlock.prototype.getCapacityType = function () {
        if (this.capacity !== undefined && this.capacity !== null) 
        {
            if (this.capacity instanceof STU.Event) return "Event";
            else if (this.capacity instanceof STU.Service) return "Service";
            else return "Function";
        }
    }

    /**
     * Process executed when STU.ScenarioBlock is deactivating.
     *
     * @method
     * @private
     */
    ScenarioBlock.prototype.onDeactivate = function () {
        
        if (this.blockType == "Sensor")
            this.validated = false;
        if (this.blockType == "Driver")
            this.executed = false;

        EP.EventServices.removeObjectListener(STU.ServiceStartedEvent, this, 'onServiceStarted');
        EP.EventServices.removeObjectListener(STU.ServiceResumedEvent, this, 'onServiceResumed');
        EP.EventServices.removeObjectListener(STU.ServicePausedEvent, this, 'onServicePaused');
        EP.EventServices.removeObjectListener(STU.ServiceStoppedEvent, this, 'onServiceStopped');
        EP.EventServices.removeObjectListener(STU.ServiceEndedEvent, this, 'onServiceEnded');

        STU.Instance.prototype.onDeactivate.call(this);
    };

    /**
     * Tell if this STU.ScenarioBlock is a sensor (or a driver).
     *
     * @method
     * @private
     * @return {Boolean}
     */
    ScenarioBlock.prototype.isSensor = function () {
        var isSensor = false;
        if (this instanceof STU.ScenarioSensor)
            isSensor = true;

        return isSensor;
    };

    /**
     * Tell if this STU.ScenarioBlock is empty.
     *
     * @method
     * @private
     * @return {Boolean}
     */
    ScenarioBlock.prototype.isEmpty = function () {
        var isEmpty = false;
        if (this.subject === null || this.subject === undefined)
            isEmpty = true;

        return isEmpty;
    };

    ScenarioBlock.prototype.reset = function () {
        this.validated = false;
        if (this.capacity instanceof STU.Service)
            this.startedOnce = false;
    };

    /**
     * Execute this STU.ScenarioBlock.
     *
     * @method
     * @private
     * @return {Boolean}
     */
    ScenarioBlock.prototype.execute = function (iExContext) {
        var subject = GetActorOf(this.subject);
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"]");

        if (this.blockType == "Sensor") {

            // We consider a block with a deactivated subject as "false"
            if (subject instanceof STU.Instance && !subject.isActive())
                return false;

            if (this.parameter != undefined && this.parameter != null && this.parameter.parameterValue != undefined && this.parameter.parameterValue != null) {
                this.capacity.setParameter(this.parameter.parameterValue);
            }
            var result = this.capacity.execute();
            this.validated = this._negated ? !result : result;
            
            return this.validated;

        }
        else if (this.blockType == "Driver") {

            // If the subject is not active, does not even call the capacity except if it is :
            // - the 'activate' capacity
            // - the 'starts' capacity of Act
            // return 'true' instead so that it consider this block as 'executed'
            if (subject instanceof STU.Instance && !subject.isActive() && this.capacity.name != "activate" && this.capacity.name != "starts" )
                return true;

            if (this.timeModifierType !== undefined && ( this.timeModifierType == "After" || this.timeModifierType == "During") && this.timeModifierValue !== undefined && this.timeModifierValue !== null ) {
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] there is a time modifier ");
                if (!this.hasOwnProperty("timeModifierCounter")){
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] create the time modifier counter and set it to 0");
                    this["timeModifierCounter"] = 0;
                }
                else{
                    this.timeModifierCounter += iExContext.deltaTime;
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] time modifier counting ... " + this.timeModifierCounter);
                }

                if (this.timeModifierType == "After" && this.timeModifierCounter < (this.timeModifierValue * (this.timeModifierUnit == 0 ? 1000 : 1))) {
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] (after) !!! " + this.timeModifierCounter +" < "+ this.timeModifierValue);
                    return;
                }
            }



            // in case this block host a Function capacity
            if (this.capacity instanceof STU.Function){

                if (this.parameter != undefined && this.parameter != null && this.parameter.parameterValue != undefined && this.parameter.parameterValue != null) {
                    this.capacity.setParameter(this.parameter.parameterValue);
                }

                this.capacity.execute();
                // At this step, if there is an time modifier 'After', we should reset the timeModifierCounter
                if (this.timeModifierType !== undefined && this.timeModifierType == "After")
                    this.timeModifierCounter = 0;

                // In case there is a time modifier "During"
                if (this.timeModifierType !== undefined && this.timeModifierType == "During"){

                    //console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] (during) !!! " + this.timeModifierCounter +" > "+ this.timeModifierValue);
                    if(this.timeModifierCounter > (this.timeModifierValue * (this.timeModifierUnit == 0 ? 1000 : 1)))
                        this.validated = true;
                    else
                        this.validated = false;
                }
                // When there is no time modifier
                else {
                    this.validated = true;
                }
                return this.validated;
            }
            // in case this block host a service capacity
            else if (this.capacity instanceof STU.Service) {
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] executing service capacity");

                // Initialize capacity by referencing method of subject
                this.capacity.setContext(this.subject,this.parameter); // NOTE : moved it to initialization // NOTE 2 : not possible to move it in initialization, see reason there

                // When do I start the service ??
                if (this.startedOnce == false  ) {
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] I will start my capacity because flag 'this.startedOnce' is false");
                    this.capacity.start();
                    this.capacity.startedBy = this;
                    this.startedOnce = true;
                    this.validated = false;
                    // to tell parent this block is not executed, the task has just begun or is running
                }
                else {
                    // here , may be the startedOnce flag is true, but the task is now under the responsability of another block...
                    if ((this.capacity.startedBy != null && this.capacity.startedBy != this)) {
                        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] capacity already started but not by me");
                        this.startedOnce = false;
                        this.validated = true;
                        return this.validated;
                    }

                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] my capacity  is already running () flag 'this.startedOnce' is true) ");
                }
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] started once : " + this.startedOnce+"/ _stopMe "+this.capacity._stopMe);
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] timeModifierType : " + this.timeModifierType+"/ timeModifierCounter "+this.timeModifierCounter+"/ timeModifierValue "+(this.timeModifierValue * (this.timeModifierUnit == 0 ? 1000 : 1)));
                
                // When do I stop the service ??
                if (this.capacity._mode == "function" || this.capacity._mode == "task" ) { // je nevois pas encore l'intéret de distinguer les 2 ici, a part peut étre pour le flag stopMe qui n'est pas utilisé par les service task
                    if (this.startedOnce == true && (
                            this.capacity._stopMe == true ||
                            (this.timeModifierType !== undefined && this.timeModifierType == "During" && this.timeModifierCounter > (this.timeModifierValue * (this.timeModifierUnit == 0 ? 1000 : 1)))
                            )
                        )
                    {
                        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] ask my capacity to stop ");
                        this.capacity.stop();
                        // this.timeModifierCounter = 0;
                        this.validated = true;
                    }

                }
                return this.validated;
            }
            

        }
    };

    /**
     * Build the arguments array of this STU.ScenarioBlock.
     *
     * @method
     * @private
     * @return {Array} 
     */
    ScenarioBlock.prototype.buildArgsArray = function () {
        var result = [];
        if( this.parameter !== null && this.parameter !== undefined && this.parameter instanceof STU.Instance &&
            this.parameter.parameterValue !== null && this.parameter.parameterValue !== undefined)
        {
            result.push(this.parameter.parameterValue);
        }

        return result;
    };
    /**
     * Build the arguments array of this STU.ScenarioBlock.
     *
     * @method
     * @private
     * @return {Array} 
     */
    ScenarioBlock.prototype.functionCaller = function (iFunctPreparator) {
        // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"]');
        // console.log(iFunctPreparator);
        // console.log(iFunctPreparator.toString().match(/function[^{]+\{([\s\S]*)\}$/)[1]);
        if (iFunctPreparator !== undefined && iFunctPreparator !== null ) {
            var fctStructure = iFunctPreparator.call(this.subject);
            var fctToCall;
            var caller;
            if ( fctStructure.ownerType == "actor"){
                if (fctStructure.fctName in this.subject) {
                    fctToCall = this.subject[fctStructure.fctName];
                    caller = this.subject;
                }
                else {
                    console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] no function '"+fctStructure.fctName+"' in actor '"+this.subject.name+"'");
                    return;
                }
            }
            //--------------------------------------------------------------------------------------------------------------------------------------------
            //  OPTIMISATION TO DO : move this research of the behavior at the initialization of the block and sotre it somewhere instead
            //                         of asking each time it's needed
            //--------------------------------------------------------------------------------------------------------------------------------------------
            // find the fct in one of the subject's behaviors
            else if (fctStructure.ownerType == "behavior") {
                var behavior = this.subject.getBehaviorByType(STU[fctStructure.ownerName]);
                if (behavior !== undefined && behavior !== null) {
                    if (fctStructure.fctName in behavior){
                        fctToCall = behavior[fctStructure.fctName];
                        caller = behavior;
                    }
                    else {
                        console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] no function '"+fctStructure.fctName+"' in behavior '"+behavior.name+"' of actor '"+this.subject.name+"'");
                        return;
                    }
                }
                else {
                    console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] no behavior LOL '"+fctStructure.ownerName+"' in actor '"+this.subject.name+"'");
                    return;
                }
            }
            else if (fctStructure.ownerType == "userscript") {
                //fctStructure.ownerName += "_instance";
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] function to call is in a userscript behavior of the subject and its name is : '" + fctStructure.ownerName + "'");
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] let's find this userscript");
                var behaviors = this.subject.getBehaviors();
                var behavior;
                // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] the subject has " + (behaviors!==undefined ? behaviors.length : 0) + " behaviors :");
                for (var indI = 0 ; indI < behaviors.length ; indI++) {
                    // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] behavior #" + indI);
                    // console.log(behaviors[indI]);
                    //if (behaviors[indI].name == fctStructure.ownerName || behaviors[indI].name == fctStructure.ownerName + "_instance") {
                    if (behaviors[indI].name == fctStructure.ownerName || behaviors[indI].name == fctStructure.ownerName ) {
                        behavior = behaviors[indI];
                        break;
                    }
                }


                
                if (behavior !== undefined && behavior !== null) {
                    if (fctStructure.fctName in behavior){
                        fctToCall = behavior[fctStructure.fctName];
                        caller = behavior;
                    }
                    else {
                        console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] no function '"+fctStructure.fctName+"' in behavior '"+behavior.name+"' of actor '"+this.subject.name+"'");
                        return;
                    }
                }
                else {
                    console.error("[ScenarioBlock | path : "+this.DebugPosition()+"] no behavior LOL '"+fctStructure.ownerName+"' in actor '"+this.subject.name+"'");
                    return;
                }

            }
            else if (fctStructure.ownerType == "service") {

                //----------------------------------------------------------------------------------------------------------
                //
                //  Functions here are fct used in NL to control a Service: Start, Stop, Resume, ....
                //      Not yet used netiher supported
                //
                //----------------------------------------------------------------------------------------------------------

                // The service we want to control : args
                // The actor that own the service we want to control : this.subject
                // The action we want to perform on this service : fctStructure.fctName

                    // CREER LE SERVICES MANAGER !!!
                    ServicesManager.dump();
                    var args = this.buildArgsArray();
                    // console.log(args);

                    // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"]+' for actor ' + this.subject.name);
                    var serviceToControl = ServicesManager.getServiceByActorAndName(this.subject,args);
                    // console.log('[ScenarioBlock | path : "+this.DebugPosition()+"] service to control is :');
                    // console.log(serviceToControl);
                    if (fctStructure.fctName in serviceToControl) {
                        return serviceToControl[fctStructure.fctName].call(serviceToControl);
                    }
                    else {
                        console.warn("[ScenarioBlock | path : "+this.DebugPosition()+"] no " + fctStructure.fctName + ' found in ' + serviceToControl.name);
                    }

                    return true;
            }
            if (fctToCall !== undefined ){
                var args = this.buildArgsArray();
                // console.log('[ScenarioBlock | path : '+this.DebugPosition()+'] calling the function');
                var result = fctToCall.apply(caller,args);
                return result;
            }
        }
    }


    ScenarioBlock.prototype.onLocalSensorEventTriggered = function (iEvent) {
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] event : ");
        // console.log(iEvent);
        // console.log("[ScenarioBlock | path : "+this.DebugPosition()+"] looking for param " + this.capacity._targetParam + " in event");
        

        if (this.parameter === undefined || this.parameter === null || this.parameter.parameterValue === undefined || this.parameter.parameterValue === null) {
            // console.log('[ScenarioBlock | path : '+this.DebugPosition()+'] block VALIDATED for this event (because no parameter on this block)');      
            this.validated = true;
            return;
        }

        if (this.capacity._targetParam in iEvent) {
            if (this.parameter.parameterValue === iEvent[this.capacity._targetParam]) { // TODO : dans le cas d'un event de fin de service qui est de type 'task', ce test n'est pas valide.
                // console.log('[ScenarioBlock | path : '+this.DebugPosition()+'] block VALIDATED for this event');            
                this.validated = true;
            }
            else {
                // console.log('[ScenarioBlock | path : '+this.DebugPosition()+'] block not validated cause found : ');
                // console.log( iEvent[this.capacity._targetParam]);
                // console.log(' for this event instread of :');
                // console.log(this.parameter.parameterValue);
            }
        }
        else {
            console.error('[ScenarioBlock | path : '+this.DebugPosition()+'] error did not found param ' + this.capacity._targetParam + ' in event : ');
            console.error(iEvent);
        }

        // Notify parent something happened here
        // this.parent.onEventTriggered(this);   : SHOULD BE USELESS NOW

    };

    /**
     * Return small string path giving info of block position.
     *
     * @method
     * @private
     */
    ScenarioBlock.prototype.DebugPosition = function () {
        var path = "";
        // Name of block
        if (this.name !== undefined && this.name !== null)
            path = "/" + this.name + path;
        else
            return "can't get name of block";

        // Name of sentence
        if (this.parent != undefined && this.parent !== null && this.parent.name !== undefined && this.parent.name !== null)
            path = "/" + this.parent.name + path;
        else
            return "can't get name of sentence";

        // Name of paragraph
        if (this.parent.parent != undefined && this.parent.parent !== null && this.parent.parent.name !== undefined && this.parent.parent.name !== null)
            path = "/" + this.parent.parent.name + path;
        else
            return "can't get name of paragrpah";

        // Name of Act
        if (this.parent.parent.parent !== undefined && this.parent.parent.parent !== null && this.parent.parent.parent.parent != undefined && this.parent.parent.parent.parent !== null && this.parent.parent.parent.name !== undefined && this.parent.parent.parent.name !== null)
            path = "/" + this.parent.parent.parent.parent.name + path;
        else
            return "can't get name of scenario";

        // Name of Scenario
        if (this.parent.parent.parent.parent.parent != undefined && this.parent.parent.parent.parent.parent !== null && this.parent.parent.parent.parent.parent.name !== undefined && this.parent.parent.parent.parent.parent.name !== null)
            path = this.parent.parent.parent.parent.parent.name + path;
        else
            return "can't get name of scenario";

        return path;
    };

    // Expose only those entities in STU namespace.
    STU.ScenarioBlock = ScenarioBlock;

    return ScenarioBlock;
});

define('StuScenario/StuScenarioBlock', ['DS/StuScenario/StuScenarioBlock'], function (ScenarioBlock) {
    'use strict';

    return ScenarioBlock;
});
