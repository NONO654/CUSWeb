define('DS/StuModel/StuService', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance', 'DS/EPTaskPlayer/EPTask', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent', 'DS/StuModel/StuServicesManager'], function (STU, Instance, Task, EventServices, Event, ServicesManager) {
    'use strict';

    //=============================================================================//
    // Service started event
    //=============================================================================//
    var ServiceStartedEvent = function (iService,iActor) {
        // console.log('[ServiceStartedEvent] creation');
        Event.call(this);

        this.serviceName = iService instanceof STU.Service ? iService.name : iService;
        this.service = iService instanceof STU.Service ? iService : null ;
        this.actor = iActor instanceof STU.Behavior ? iActor.parent : iActor;
    };

    ServiceStartedEvent.prototype = new Event();
    ServiceStartedEvent.prototype.constructor = ServiceStartedEvent;
    ServiceStartedEvent.prototype.type = 'ServiceStartedEvent';

    // Expose in STU namespace.
    STU.ServiceStartedEvent = ServiceStartedEvent;
    EventServices.registerEvent(ServiceStartedEvent);

    //=============================================================================//
    // Service resumed event
    //=============================================================================//
    var ServiceResumedEvent = function (iService,iActor) {
        // console.log("[ServiceResumedEvent] creation");
        Event.call(this);

        this.serviceName = iService instanceof STU.Service ? iService.name : iService;
        this.service = iService instanceof STU.Service ? iService : null ;
        this.actor = iActor instanceof STU.Behavior ? iActor.parent : iActor;
    };

    ServiceResumedEvent.prototype = new Event();
    ServiceResumedEvent.prototype.constructor = ServiceResumedEvent;
    ServiceResumedEvent.prototype.type = 'ServiceResumedEvent';

    // Expose in STU namespace.
    STU.ServiceResumedEvent = ServiceResumedEvent;
    EventServices.registerEvent(ServiceResumedEvent);

    //=============================================================================//
    // Service paused event
    //=============================================================================//
    var ServicePausedEvent = function (iService,iActor) {
        // console.log("[ServicePausedEvent] creation");
        Event.call(this);

        this.serviceName = iService instanceof STU.Service ? iService.name : iService;
        this.service = iService instanceof STU.Service ? iService : null ;
        this.actor = iActor instanceof STU.Behavior ? iActor.parent : iActor;
    };

    ServicePausedEvent.prototype = new Event();
    ServicePausedEvent.prototype.constructor = ServicePausedEvent;
    ServicePausedEvent.prototype.type = 'ServicePausedEvent';

    // Expose in STU namespace.
    STU.ServicePausedEvent = ServicePausedEvent;
    EventServices.registerEvent(ServicePausedEvent);

    //=============================================================================//
    // Service stopped event
    //=============================================================================//
    var ServiceStoppedEvent = function (iService,iActor) {
        // console.log("[ServiceStoppedEvent] creation");
        Event.call(this);

        this.serviceName = iService instanceof STU.Service ? iService.name : iService;
        this.service = iService instanceof STU.Service ? iService : null ;
        this.actor = iActor instanceof STU.Behavior ? iActor.parent : iActor;
    };

    ServiceStoppedEvent.prototype = new Event();
    ServiceStoppedEvent.prototype.constructor = ServiceStoppedEvent;
    ServiceStoppedEvent.prototype.type = 'ServiceStoppedEvent';

    // Expose in STU namespace.
    STU.ServiceStoppedEvent = ServiceStoppedEvent;
    EventServices.registerEvent(ServiceStoppedEvent);

    //=============================================================================//
    // Service ended event
    //=============================================================================//
    var ServiceEndedEvent = function (iService,iActor) {
        // console.log("[ServiceEndedEvent] creation");
        Event.call(this);

        this.serviceName = iService instanceof STU.Service ? iService.name : iService;
        this.service = iService instanceof STU.Service ? iService : null ;
        this.actor = iActor instanceof STU.Behavior ? iActor.parent : iActor;
    };

    ServiceEndedEvent.prototype = new Event();
    ServiceEndedEvent.prototype.constructor = ServiceEndedEvent;
    ServiceEndedEvent.prototype.type = 'ServiceEndedEvent';

    // Expose in STU namespace.
    STU.ServiceEndedEvent = ServiceEndedEvent;
    EventServices.registerEvent(ServiceEndedEvent);

    //=============================================================================//
    // Service task
    //=============================================================================//
    var ServiceTask = function(iService) {
        Task.call(this);
        this.service = iService;
        this.name = "Im associated task of " + iService.name;
    };

    ServiceTask.prototype = new Task();
    ServiceTask.prototype.constructor = ServiceTask;

    
    ServiceTask.prototype.onExecute = function(iExContext) {
        // console.log("[ServiceTask::onExecute] task of " + this.service.name + " - stop me : " + this.service.stopMe );

        if (this.service._stopMe)
            return;

        if (this.service.fctEnd !== undefined && this.service.fctEnd.apply(this.service.context.caller,[this.service.context.parameter,iExContext])) {
            
            // Send ServiceEnded
            var endEvent = new ServiceEndedEvent(this.service);
            this.service.context.actor.dispatchEvent(endEvent);

            
            // console.log("[ServiceTask::onExecute] deleting task");
            // this.service.stop(); OR this.stop() ne sert a rien car la tache n'est pas stopbbale, on est en plein dans un execute !!
            
            // A enlever quand le control de fin de tache sera mieux fait ailleurs
            //EP.TaskPlayer.removeTask(this);
            this.service._stopMe = true;
        }
        else
            this.service.fctExecute.apply(this.service.context.caller,[this.service.context.parameter,iExContext]);

        
    };
    //=============================================================================//


    //=============================================================================//
    // Service class
    //=============================================================================//

    /**
	 * @exports Service
	 * @class
	 * @constructor
	 * @noinstancector
	 * @private
	 * @extends STU.Instance
	 * @memberof STU
	 * @alias STU.Service
	 */
    var Service = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "Service";

        // this.fctStart;
        // this.fctExecute;
        // this.fctEnd;
        // this.fctStop;

        // state variable
        this.running;
        this.paused;
        this.stopped;

        // Context
        // { 
        //     'caller' : <actor/behavior hosting the capacity>,
        //     'parameter' : <some parameter, TODO>
        //     'actor'  : actor directly or actor hosting the behavior (computed auto)
        // }
        this.context = {};

        // task
        this.associatedTask;

        // this.startedOnce = false; -> resp transfered to hosting block

        // flag used by service to point the block who started it
        this.startedBy = null;

        this._stopMe = false;

    };

    Service.prototype = new Instance();
    Service.prototype.constructor = Service;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} instance object corresponding to the experience
    */
    Service.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    
    Service.prototype.setContext = function (iCaller,iParameter) {

        if (iCaller !== undefined && iCaller !== null) {
            this.context.caller = iCaller;
            this.context.actor = iCaller instanceof STU.Behavior ? iCaller.parent : iCaller;
        }
        else {
            console.error('[Service::setContext] undefined iCaller');
        }

        // console.log('[Service::'+this.name+'] setContext');
        // iParameter
        if (iParameter !== undefined && iParameter !== null && iParameter.parameterValue !== undefined && iParameter.parameterValue !== null) {
            this.context.parameter = iParameter.parameterValue;
        }      


    };

    Service.prototype.onInitialize = function () {
        Instance.prototype.onInitialize.call(this);

        // console.log('[Service::'+this.name+'] onInitialize');
        // console.log(this);
        // console.log(this.parent);


        // this         ---> the Service capacity
        // this.parent  ---> the UserScript template behavior OR another behavior

        if (this._mode == "function" || this._mode == "task") {

            if (this.parent === undefined) console.error ("[Service::onInitialize::"+this.name+"] capacity has no parent");
            
            // FUNCTION START
            if (this._fctStart !== undefined && this._fctStart !== "") {
                if (this._fctStart in this.parent)
                    this.fctStart   = this.parent[this._fctStart];
                else {
                    console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctStart+"' found in : ");
                    console.warn(this.parent);
                }
            }
            else{
                console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function Start name not defined");
            }
            
            // FUNCTION STOP
            if (this._fctStop !== undefined && this._fctStop !== "") {
                if (this._fctStop in this.parent)
                    this.fctStop   = this.parent[this._fctStop];
                else {
                    console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctStop+"' found in : ");
                    console.warn(this.parent);
                }
            }
            else{
                console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function Stop name not defined");
            }
            
            if (this._mode == "function") {
                // FUNCTION EXECUTE
                if (this._fctExecute !== undefined && this._fctExecute !== "") {
                    if (this._fctExecute in this.parent)
                        this.fctExecute   = this.parent[this._fctExecute];
                    else {
                        console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctExecute+"' found in : ");
                        console.warn(this.parent);
                    }
                }
                else{
                    console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function Execute name not defined");
                }
                
                // FUNCTION END
                if (this._fctEnd !== undefined && this._fctEnd !== "") {
                    if (this._fctEnd in this.parent)
                        this.fctEnd   = this.parent[this._fctEnd];
                    else {
                        console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctEnd+"' found in : ");
                        console.warn(this.parent);
                    }
                }
                else{
                    console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function End name not defined");
                }
            }
            else if (this._mode == "task") {
                // FUNCTION PAUSE
                if (this._fctPause !== undefined && this._fctPause !== "") {
                    if (this._fctPause in this.parent)
                        this.fctPause   = this.parent[this._fctPause];
                    else {
                        console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctPause+"' found in : ");
                        console.warn(this.parent);
                    }
                }
                else{
                    // IR-465944 - no function 'Pause' exposed for R419, so no warning message should be displayed for missing fct
                    // console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function Pause name not defined");
                }
                
                // FUNCTION RESUME
                if (this._fctResume !== undefined && this._fctResume !== "") {
                    if (this._fctResume in this.parent)
                        this.fctResume   = this.parent[this._fctResume];
                    else {
                        console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctResume+"' found in : ");
                        console.warn(this.parent);
                    }
                }
                else{
                    // IR-465944 - no function 'Resume' exposed for R419, so no warning message should be displayed for missing fct
                    // console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function Resume name not defined");
                }
                // FUNCTION ISPLAYING
                if (this._fctIsPlaying !== undefined && this._fctIsPlaying !== "") {
                    if (this._fctIsPlaying in this.parent)
                        this.fctIsPlaying   = this.parent[this._fctIsPlaying];
                    else {
                        console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] no '"+this._fctIsPlaying+"' found in : ");
                        console.warn(this.parent);
                    }
                }
                else{
                    console.warn("[Service::onInitialize::"+this.parent.name+"::"+this.name+"] function IsPlaying name not defined");
                }
            }

            // register in parent different event possible
            // console.log('[Service::'+this.name+'] onInitialize');
            this.running = false;

            // check fctStart, ftcExecute, etc are defined
            if (this._mode == "function") {
                // Comment test for not mandatory fct
                // if (this.fctStart === undefined)    console.warn('[Service::onInitialize] fctStart not defined');
                if (this.fctExecute === undefined)  console.warn('[Service::onInitialize] fctExecute not defined');
                if (this.fctEnd === undefined)      console.warn('[Service::onInitialize] fctEnd not defined');
                // if (this.fctStop === undefined)     console.warn('[Service::onInitialize] fctStop not defined');
            }
            else if (this._mode == "task") { 
                if (this.fctStart === undefined)    console.warn('[Service::onInitialize] fctStart not defined');
                //if (this.fctPause === undefined)    console.warn('[Service::onInitialize] fctPause not defined');
                //if (this.fctResume === undefined)   console.warn('[Service::onInitialize] fctResume not defined');
                if (this.fctStop === undefined)     console.warn('[Service::onInitialize] fctStop not defined');
                if (this.fctIsPlaying === undefined)console.warn('[Service::onInitialize] fctIsPlaying not defined');
            }
            else {
                console.error('[Service::onInitialize] mode of service is not correct, got ' + this._mode + ' but exepected task or function');
            }

            if (this.parent !== undefined && this.parent !== null) {
                if (this.parent instanceof STU.Behavior && this.parent.parent !== undefined && this.parent.parent !== null)
                    ServicesManager.registerService(this.parent.parent,this);
                else
                    ServicesManager.registerService(this.parent,this);
            }
        }
        else {
            console.error("[ScenarioBlock::"+this.parent.name+"::"+this.name+"] Error initializing capacity. The mode is not correct or undefined");
            return false;
        }
    };


    Service.prototype.start = function () {
        // console.log('[Service::'+this.name+'::start]');

        // For both 'task' and 'function' mode, start function need to be called
        if (this.fctStart !== undefined) this.fctStart.apply(this.parent,[this.context.parameter,null]);

        if (this._mode == "function") {
            this.associatedTask = new ServiceTask(this);
            EP.TaskPlayer.addTask(this.associatedTask);
            this.associatedTask.start();
        }

        var startEvent = new ServiceStartedEvent(this);
        this.context.actor.dispatchEvent(startEvent);

        this.running = true;
        //this.startedOnce = true;

        return true;
    };
    Service.prototype.resume = function () {
        // console.log('[Service::'+this.name+'] resume ' + this.name);

        if (this._mode == "function") {
            this.associatedTask.resume();
        }
        else {
            if (this.fctResume !== undefined)
                this.fctResume.apply(this.parent,[this.context.parameter,null]);
            else
                console.warn("[Service] can't resume service because no fctResume defined")
        }
        
        var resumeEvent = new ServiceResumedEvent(this);
        this.context.actor.dispatchEvent(resumeEvent);

        this.paused = false;
        this.running = true;

        return true;
    };
    Service.prototype.pause = function () {
        // console.log('[Service::'+this.name+'] pause ' + this.name);


        if (this._mode == "function") {
            this.associatedTask.pause();
        }
        else {
            if (this.fctPause !== undefined)
                this.fctPause.apply(this.parent,[this.context.parameter,null]);
            else
                console.warn("[Service] can't Pause service because no fctPause defined")
        }

        var pauseEvent = new ServicePausedEvent(this);
        this.context.actor.dispatchEvent(pauseEvent);

        this.paused = true;
        this.running = false;

        return true;
    };
    Service.prototype.stop = function () {
        // console.log('[Service::'+this.name+'] stop : ' + this.name);
        //if (this.fctStop !== undefined) this.fctStop.apply(this.parent,[this.context.parameter,null]);
    
        var stopped = false;

        if (this._mode == "function") {

            // console.log('actor : ' + this.context.actor.name + '/ parameter : ' + this.context.parameter.name + ' / mode : ' + this._mode + ' / service name : ' + this.name + ' / associated task : ' + this.associatedTask.name );

            if (this.fctStop !== undefined)
                this.fctStop.apply(this.parent,[this.context.parameter])

            // console.log('test pourri : est ce stoppable? : ' + this.associatedTask.isStoppable());
            if (this.associatedTask !== undefined && this.associatedTask !== null && this.associatedTask.isStoppable()){
                // console.log('[Service::'+this.name+'] REALYY CALLING STOP !!!!!!!!');
                this.associatedTask.stop();
                EP.TaskPlayer.removeTask(this.associatedTask);
                delete this.associatedTask;
                this.associatedTask = null;
                stopped = true;
            }
        }
        else {
            if (this.fctStop !== undefined){
                this.fctStop.apply(this.parent,[this.context.parameter,null]);
                stopped = true;
            }
            else{
                console.warn("[Service] can't Stop service because no fctStop defined")
            }
        }

        if (stopped) {
            var stopEvent = new ServiceStoppedEvent(this);
            this.context.actor.dispatchEvent(stopEvent);
            
            this.running = false;
            this._stopMe = false;
        }

        return true;
    };

    Service.prototype.getPlayState = function () {
        if (this.associatedTask !== undefined && this.associatedTask !== null)
            return this.associatedTask.getPlayState();
        else
            return Task.EPlayState.eStopped;
    };
    Service.prototype.isPlaying = function () {
        // console.log('[Service::isPlaying::'+this.name+'] of ' + this.parent.name + ' of ' + this.parent.parent.name);
        if (this._mode == "function") {
            if (this.associatedTask !== undefined && this.associatedTask !== null) {

                //Task.EPlayState = { eStarting: 0, eStarted: 1, ePausing: 2, ePaused: 3, eResuming: 4, eResumed: 5, eStopping: 6, eStopped: 7, eExecuting: 8, eExecuted: 9 };

                var playState = this.associatedTask.getPlayState();
                // console.log('[Service::isPlaying::'+this.name+']' + playState);
                return this.associatedTask.isPlaying();
            }
            else{
                // console.log('[Service::isPlaying::'+this.name+'] has no associated task so it is not playing');
                return false;
            }
        }
        else {  // In the case of a Service based on task, we ask the function behind 'fctExecute' to test the play state of the service
            if (this.fctIsPlaying !== undefined) {
                return this.fctIsPlaying.apply(this.parent,[this.context.parameter]);
            }
            else {
                console.error("[Service::isPlaying::"+this.name+"] can't say if service is playing because no fctIsPlaying defined");
                return false;
            }
        }
    };

    // Expose in STU namespace.
    STU.Service = Service;

    return Service;
});

define('StuModel/StuService', ['DS/StuModel/StuService'], function (Service) {
    'use strict';

    return Service;
});
