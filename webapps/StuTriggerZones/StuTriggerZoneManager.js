define('DS/StuTriggerZones/StuTriggerZoneManager', ['DS/StuCore/StuContext', 'DS/StuCore/StuManager', 'DS/EPEventServices/EPEvent', 'DS/EPTaskPlayer/EPTask'], function (STU, Manager, Event, Task) {
    'use strict';

    /**
     * This event is thrown when an object enters a trigger zone.
     *
     * @example
     * beScript.onStart = function () {
     *     var actor = this.getActor();
     *     actor.addObjectListener(STU.TriggerZoneEnterEvent, beScript, 'onTZEnter');
     * };
     * 
     * beScript.onStop = function () {
     *     var actor = this.getActor();
     *     actor.removeObjectListener(STU.TriggerZoneEnterEvent, beScript, 'onTZEnter');
     * };
     * 
     * beScript.onTZEnter = function (iEvent) {
     *     console.log("My parent actor has entred a trigger zone :");
     * };
     *
     *
     * @exports TriggerZoneEnterEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends {EP.Event}
     * @memberOf STU
	 * @alias STU.TriggerZoneEnterEvent
     */
    var TriggerZoneEnterEvent = function (iZone, iObject) {
        Event.call(this);

        /**
         * The trigger zone in which an object has entered
         *
         * @member
         * @public
         * @type {STU.Actor}
         */

        this.zone = iZone !== undefined ? iZone : null;

        /**
         * The Actor that has entered the zone
         *
         * @member
         * @public
         * @type {STU.Actor}
         */
        this.object = iObject !== undefined ? iObject : null;
    };

    TriggerZoneEnterEvent.prototype = new Event();
    TriggerZoneEnterEvent.prototype.constructor = TriggerZoneEnterEvent;
    TriggerZoneEnterEvent.prototype.type = 'TriggerZoneEnterEvent';

    // Expose in STU namespace.
    STU.TriggerZoneEnterEvent = TriggerZoneEnterEvent;

    EP.EventServices.registerEvent(TriggerZoneEnterEvent);


    /**
     * This event is thrown when an object exists a trigger zone.
     *
     * @example
     *
     * beScript.onStart = function () {
     *     var actor = this.getActor();
     *     actor.addObjectListener(STU.TriggerZoneExitEvent, beScript, 'onTZExit');
     * };
     * 
     * beScript.onStop = function () {
     *     var actor = this.getActor();
     *     actor.removeObjectListener(STU.TriggerZoneExitEvent, beScript, 'onTZExit');
     * };
     * 
     * beScript.onTZExit = function (iEvent) {
     *     console.log("My parent actor has exited a trigger zone :");
     * };
     *
     *
     * @exports TriggerZoneExitEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends {EP.Event}
     * @memberOf STU
	 * @alias STU.TriggerZoneExitEvent
     */
    var TriggerZoneExitEvent = function (iZone, iObject) {
        Event.call(this);

        /**
         * The zone in which an object has entered
         *
         * @member
         * @public
         * @type {STU.Actor}
         */
        this.zone = iZone !== undefined ? iZone : null;

        /**
         * The object (STU.Actor) that has entered the zone
         *
         * @member
         * @public
         * @type {STU.Actor}
         */
        this.object = iObject !== undefined ? iObject : null;
    };

    TriggerZoneExitEvent.prototype = new Event();
    TriggerZoneExitEvent.prototype.constructor = TriggerZoneExitEvent;
    TriggerZoneExitEvent.prototype.type = 'TriggerZoneExitEvent';

    // Expose in STU namespace.
    STU.TriggerZoneExitEvent = TriggerZoneExitEvent;

    EP.EventServices.registerEvent(TriggerZoneExitEvent);


    /**
     * This event is thrown when an object is included in a trigger zone (inclusiontype==2)
     * or when a triggerzone is included in an object (inclusiontype==1)
     *
     * @example
     * beScript.onStart = function () {
     *     var actor = this.getActor();
     *     actor.addObjectListener(STU.TriggerZoneInclusionEvent, beScript, 'onTZInclusion');
     * };
     * 
     * beScript.onStop = function () {
     *     var actor = this.getActor();
     *     actor.removeObjectListener(STU.TriggerZoneInclusionEvent, beScript, 'onTZInclusion');
     * };
     * 
     * beScript.onTZInclusion = function (iEvent) {
     *     console.log("An inclusion is detected");
     * };
     *
     *
     * @exports TriggerZoneInclusionEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends {EP.Event}
     * @memberOf STU
     * @alias STU.TriggerZoneInclusionEvent
     */
    var TriggerZoneInclusionEvent = function (iZone, iObject, iInclusionType) {
        Event.call(this);

        /**
         * The trigger zone involved in the inclusion
         *
         * @member
         * @public
         * @type {STU.Actor}
         */

        this.zone = iZone !== undefined ? iZone : null;

        /**
         * The Actor involved in the inclusion
         *
         * @member
         * @public
         * @type {STU.Actor}
         */
        this.object = iObject !== undefined ? iObject : null;

        /**
         * The inclusion type :
         * 3 : TriggerZone is included in object
         * 2 : Object included in TriggerZone
         *
         * @member
         * @public
         * @type {number}
         */
        this.inclusiontype = iInclusionType !== undefined ? iInclusionType : null;
    };

    TriggerZoneInclusionEvent.prototype = new Event();
    TriggerZoneInclusionEvent.prototype.constructor = TriggerZoneInclusionEvent;
    TriggerZoneInclusionEvent.prototype.type = 'TriggerZoneInclusionEvent';

    // Expose in STU namespace.
    STU.TriggerZoneInclusionEvent = TriggerZoneInclusionEvent;

    EP.EventServices.registerEvent(TriggerZoneInclusionEvent);


    /**
     * This event is thrown when an object is no longer included in a trigger zone (inclusiontype==2)
     * or when a triggerzone is no longer included in an object (inclusiontype==1)
     * This necessarily comes after a TriggerZoneInclusionEvent
     * @example
     * beScript.onStart = function () {
     *     var actor = this.getActor();
     *     actor.addObjectListener(STU.TriggerZoneEndInclusionEvent, beScript, 'onTZEndInclusion');
     * };
     * 
     * beScript.onStop = function () {
     *     var actor = this.getActor();
     *     actor.removeObjectListener(STU.TriggerZoneEndInclusionEvent, beScript, 'onTZEndInclusion');
     * };
     * 
     * beScript.onTZEndInclusion = function (iEvent) {
     *     console.log("An inclusion is no longer detected");
     * };
     *
     *
     * @exports TriggerZoneEndInclusionEvent
     * @class
     * @constructor
     * @noinstancector
     * @public
     * @extends {EP.Event}
     * @memberOf STU
     * @alias STU.TriggerZoneEndInclusionEvent
     */
    var TriggerZoneEndInclusionEvent = function (iZone, iObject, iInclusionType) {
        Event.call(this);

        /**
         * The trigger zone involved in the inclusion
         *
         * @member
         * @public
         * @type {STU.Actor}
         */

        this.zone = iZone !== undefined ? iZone : null;

        /**
         * The Actor involved in the inclusion
         *
         * @member
         * @public
         * @type {STU.Actor}
         */
        this.object = iObject !== undefined ? iObject : null;

        /**
         * The inclusion type :
         * 3 : TriggerZone is included in object
         * 2 : Object included in TriggerZone
         *
         * @member
         * @public
         * @type {number}
         */
        this.inclusiontype = iInclusionType !== undefined ? iInclusionType : null;
    };

    TriggerZoneEndInclusionEvent.prototype = new Event();
    TriggerZoneEndInclusionEvent.prototype.constructor = TriggerZoneEndInclusionEvent;
    TriggerZoneEndInclusionEvent.prototype.type = 'TriggerZoneEndInclusionEvent';

    // Expose in STU namespace.
    STU.TriggerZoneEndInclusionEvent = TriggerZoneEndInclusionEvent;

    EP.EventServices.registerEvent(TriggerZoneEndInclusionEvent);


    //////////////////////////////////////////////////////////////////////////
    // TriggerZoneManagerTask
    //////////////////////////////////////////////////////////////////////////
    var TriggerZoneManagerTask = function (iManager) {
        Task.call(this);
        this.name = "TriggerZoneManagerTask";
        this.associatedManager = iManager;
    };

    TriggerZoneManagerTask.prototype = new Task();
    TriggerZoneManagerTask.prototype.constructor = TriggerZoneManagerTask;

    TriggerZoneManagerTask.prototype.onExecute = function (iExContext) {
        this.associatedManager.run();
        return this;
    };

    TriggerZoneManagerTask.prototype.onStart = function () {
        //console.debug("TriggerZoneManagerTask onStart");
        this.associatedManager.onStart();
    };

    TriggerZoneManagerTask.prototype.onStop = function () {
        //console.debug("TriggerZoneManagerTask onStop");
        this.associatedManager.onStop();
    };

    //////////////////////////////////////////////////////////////////////////
    // TriggerZoneManager
    //////////////////////////////////////////////////////////////////////////
    var TriggerZoneManager = function () {

        Manager.call(this);

        this.name = "TriggerZoneManager";

        this.associatedTask;

        this.AllObjects = [];
        this.IsOKToRun = false;
        //this.associatedTask;

        //console.debug("StuTriggerZoneManager CTOR " + this.stuId);

    };

    TriggerZoneManager.prototype = new Manager();
    TriggerZoneManager.prototype.constructor = TriggerZoneManager;

    TriggerZoneManager.prototype.onInitialize = function () {
        ////console.debug("TZ MANAGER INIT"); 

    	this.MyCPPObj = this.getTriggerZoneManager();//stu__TriggerZoneManager.__stu__GetTriggerZoneManager();
        this.MyCPPObj.__stu__Init(this);

        this.associatedTask = new TriggerZoneManagerTask(this);
        EP.TaskPlayer.addTask(this.associatedTask);
    };

    TriggerZoneManager.prototype.onDispose = function () {
        ////console.debug("TZ MANAGER DISPOSE"); 

        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;

        STU.clear(this.AllObjects);
        this.AllObjects.length = 0;
        this.MyCPPObj.__stu__Dispose();
        this.deleteTriggerZoneManager()//stu__TriggerZoneManager.__stu__DeleteTriggerZoneManager();
    };

    TriggerZoneManager.prototype.registerTriggerZone = function (iActor) {
        //console.debug(" TriggerZoneManager RegisterTriggerZone actor:" + iActor.stuId);

        if (!(iActor instanceof STU.Actor)) {
            console.error("TriggerZoneManager registerTriggerZone invalid input, actor expected");
            return;
        }
        var visuObject = undefined;
        visuObject = iActor.CATI3DGeoVisu;
        if (visuObject !== undefined && visuObject !== null) {
            var ID = this.MyCPPObj.__stu__RegisterTriggerZone(visuObject);
            this.AllObjects[ID] = iActor;
            return ID;
        }
        return;
    };

    TriggerZoneManager.prototype.registerTriggeringObject = function (iActor) {
        //console.debug(" TriggerZoneManager RegisterTriggeringObject actor:" + iActor.stuId);

        if (!(iActor instanceof STU.Actor)) {
            console.error("TriggerZoneManager registerTriggeringObject invalid input, actor expected");
            return;
        }


        // TJR not necessary anymore as in manager's initialization we retrieve ALL actors
        /*
        // IBS IR-310227-3DEXPERIENCER2015x si j'ai des subactors je vais registerer mes subactors, en plus de moi
        var subActors = iActor.getSubActors();
        var s;
        var subactorCount = subActors.length;
        for (s = 0; s < subactorCount; ++s) {
            var subActor = subActors[s];
            if (subActor !== undefined && subActor !== null && subActor instanceof STU.Actor3D) {
                this.registerTriggeringObject(subActor);
            }
        }
        */

        if (iActor.CATI3DGeoVisu !== undefined && iActor.CATI3DGeoVisu !== null) {
            var ID = this.MyCPPObj.__stu__RegisterTriggeringObject(iActor.CATI3DGeoVisu);
            this.AllObjects[ID] = iActor;
            return ID;
        } else if (iActor.StuIRepresentation !== undefined && iActor.StuIRepresentation !== null) {
            var ID = this.MyCPPObj.__stu__RegisterTriggeringObject(iActor.StuIRepresentation);
            this.AllObjects[ID] = iActor;
            return ID;
        } else {
            console.error("TriggerZoneManager registerTriggeringObject invalid input, CATI3DGeoVisu + StuIRepresentation are null or undefined");            
            return;
        }
    };

    TriggerZoneManager.prototype.unRegisterTriggerZone = function (iID) {
        //console.debug(" TriggerZoneManager UnRegisterTriggerZone id:" + iID);

        this.MyCPPObj.__stu__UnRegisterTriggerZone(iID);
        this.AllObjects[iID] = null;
    };

    TriggerZoneManager.prototype.unRegisterTriggeringObject = function (iID) {
        //console.debug(" TriggerZoneManager UnRegisterTriggeringObject id:" + iID);

        this.MyCPPObj.__stu__UnRegisterTriggeringObject(iID);
        this.AllObjects[iID] = null;
    };

    TriggerZoneManager.prototype.onTriggerZoneEntry = function (iIDTriggerZone, iIDTriggering) {
        //console.debug(" TriggerZoneManager TriggerZoneEntry " + this.stuId);
        //console.debug(" TriggerZone : " + iIDTriggerZone);
        //console.debug(" TriggeringObj : " + iIDTriggering);

        // create a new Trigger Zone Enter event and sent it to the declared
        // event target
        var e = new STU.TriggerZoneEnterEvent();
        e.zone = this.AllObjects[iIDTriggerZone];
        e.object = this.AllObjects[iIDTriggering];

        //console.debug(" 1 ");

        
        var eTarget = null;

        if (e.zone instanceof STU.Actor) {
            eTarget = e.zone.eventTarget;
        }

        if (eTarget === undefined || eTarget === null) {
            eTarget = e.zone;
        }

        //console.debug(" 2 ");

        var sendIt = false;
        if (e.zone.objectFilter === undefined || e.zone.objectFilter === null) {
            sendIt = true;
        } else if (e.zone.objectFilter instanceof STU.Actor && e.zone.objectFilter === e.object) {
            sendIt = true;
        }
            // IBS May 2014 : instanceof STU.Collection is KO :
            // Uncaught TypeError: Expecting a function in instanceof check, but got [object Object]
            //else if (e.zone.objectFilter instanceof STU.Collection && e.zone.objectFilter.HasObject(e.object)) {
            //    sendIt = true;
            //}
        else {
            //console.debug("discarding triggering object as not being part of filtered objects");
        }

        //console.debug(" 3 ");

        if (sendIt) {
            //console.debug("dispatching event to:" + eTarget.name);
            eTarget.dispatchEvent(e, false);

            // TLY > Add this to be more consistent with clickable
            //     > Next step: Remove the target that does not make sens anymore
            if (eTarget !== e.zone) { // e.zone.dispatchEvent(e)
                this._sendTZEvent(e, e.zone);
            }
        }

        //console.debug(" 4 ");
    };

    TriggerZoneManager.prototype.onTriggerZoneExit = function (iIDTriggerZone, iIDTriggering) {
        //console.debug(" TriggerZoneManager TriggerZoneExit " + this.stuId);
        //console.debug(" TriggeringObj : " + iIDTriggering);
        //console.debug(" TriggerZone : " + iIDTriggerZone);

        // create a new Trigger Zone Enter event and sent it to the declared
        // event target
        var e = new STU.TriggerZoneExitEvent();
        e.zone = this.AllObjects[iIDTriggerZone];
        e.object = this.AllObjects[iIDTriggering];

        //console.debug(" 1 ");

        
        var eTarget = null;

        if (e.zone instanceof STU.Actor) {
            eTarget = e.zone.eventTarget;
        }

        if (eTarget === undefined || eTarget === null) {
            eTarget = e.zone;
        }

        //console.debug(" 2 ");

        var sendIt = false;
        if (e.zone.objectFilter === undefined || e.zone.objectFilter === null) {
            sendIt = true;
        } else if (e.zone.objectFilter instanceof STU.Actor && e.zone.objectFilter === e.object) {
            sendIt = true;
        }
            // IBS May 2014 : instanceof STU.Collection is KO :
            // Uncaught TypeError: Expecting a function in instanceof check, but got [object Object]
            //else if (e.zone.objectFilter instanceof STU.Collection && e.zone.objectFilter.HasObject(e.object)) {
            //    sendIt = true;
            //}
        else {
            //console.debug("discarding triggering object as not being part of filtered objects");
        }

        //console.debug(" 3 ");

        if (sendIt) {
            //console.debug("dispatching event to:" + eTarget.name);
            eTarget.dispatchEvent(e, false);

            // TLY > Add this to be more consistent with clickable
            //     > Next step: Remove the target that does not make sens anymore
            if (eTarget !== e.zone) { // e.zone.dispatchEvent(e)
                this._sendTZEvent(e, e.zone);
            }
        }

        //console.debug(" 4 ");
    };

    TriggerZoneManager.prototype.onTriggerZoneInclusion = function (iIDTriggerZone, iIDTriggering, iInclusionType) {
        //console.debug(" TriggerZoneManager onTriggerZoneInclusion " + this.stuId);
        //console.debug(" TriggerZone : " + iIDTriggerZone);
        //console.debug(" TriggeringObj : " + iIDTriggering);
        //console.debug(" InclusionType : " + iInclusionType);

        // create a new Trigger Zone Inclusion event and sent it to the declared
        // event target
        var e = new STU.TriggerZoneInclusionEvent();
        e.zone = this.AllObjects[iIDTriggerZone];
        e.object = this.AllObjects[iIDTriggering];
        e.inclusiontype = iInclusionType;

        //console.debug(" 1 ");

        
        var eTarget = null;

        if (e.zone instanceof STU.Actor) {
            eTarget = e.zone.eventTarget;
        }

        if (eTarget === undefined || eTarget === null) {
            eTarget = e.zone;
        }

        //console.debug(" 2 ");

        var sendIt = false;
        if (e.zone.objectFilter === undefined || e.zone.objectFilter === null) {
            sendIt = true;
        } else if (e.zone.objectFilter instanceof STU.Actor && e.zone.objectFilter === e.object) {
            sendIt = true;
        }
            // IBS May 2014 : instanceof STU.Collection is KO :
            // Uncaught TypeError: Expecting a function in instanceof check, but got [object Object]
            //else if (e.zone.objectFilter instanceof STU.Collection && e.zone.objectFilter.HasObject(e.object)) {
            //    sendIt = true;
            //}
        else {
            //console.debug("discarding triggering object as not being part of filtered objects");
        }

        //console.debug(" 3 ");

        if (sendIt) {
            //console.debug("dispatching event to:" + eTarget.name);
            eTarget.dispatchEvent(e, false);

            // TLY > Add this to be more consistent with clickable
            //     > Next step: Remove the target that does not make sens anymore
            if (eTarget !== e.zone) { // e.zone.dispatchEvent(e)
                this._sendTZEvent(e, e.zone);
            }
        }

        //console.debug(" 4 ");
    };


    TriggerZoneManager.prototype.onTriggerZoneEndInclusion = function (iIDTriggerZone, iIDTriggering, iInclusionType) {
        //console.debug(" TriggerZoneManager onTriggerZoneEndInclusion " + this.stuId);
        //console.debug(" TriggerZone : " + iIDTriggerZone);
        //console.debug(" TriggeringObj : " + iIDTriggering);
        //console.debug(" InclusionType : " + iInclusionType);

        // create a new Trigger Zone Inclusion event and sent it to the declared
        // event target
        var e = new STU.TriggerZoneEndInclusionEvent();
        e.zone = this.AllObjects[iIDTriggerZone];
        e.object = this.AllObjects[iIDTriggering];
        e.inclusiontype = iInclusionType;

        //console.debug(" 1 ");

        
        var eTarget = null;

        if (e.zone instanceof STU.Actor) {
            eTarget = e.zone.eventTarget;
        }

        if (eTarget === undefined || eTarget === null) {
            eTarget = e.zone;
        }

        //console.debug(" 2 ");

        var sendIt = false;
        if (e.zone.objectFilter === undefined || e.zone.objectFilter === null) {
            sendIt = true;
        } else if (e.zone.objectFilter instanceof STU.Actor && e.zone.objectFilter === e.object) {
            sendIt = true;
        }
            // IBS May 2014 : instanceof STU.Collection is KO :
            // Uncaught TypeError: Expecting a function in instanceof check, but got [object Object]
            //else if (e.zone.objectFilter instanceof STU.Collection && e.zone.objectFilter.HasObject(e.object)) {
            //    sendIt = true;
            //}
        else {
            //console.debug("discarding triggering object as not being part of filtered objects");
        }

        //console.debug(" 3 ");

        if (sendIt) {
            //console.debug("dispatching event to:" + eTarget.name);
            eTarget.dispatchEvent(e, false);

            // TLY > Add this to be more consistent with clickable
            //     > Next step: Remove the target that does not make sens anymore
            if (eTarget !== e.zone) { // e.zone.dispatchEvent(e)
                this._sendTZEvent(e, e.zone);
            }
        }

        //console.debug(" 4 ");
    };

    TriggerZoneManager.prototype.run = function () {
        if (this.IsOKToRun === true)
            this.MyCPPObj.__stu__Run();
    };

    TriggerZoneManager.prototype.onStart = function () {

        //console.debug("TriggerZoneManager: onStart ");
        // if some registered trigger zone react with all object of the experience
        // parse the it, and retrieve all triggering objects

        // IBS ONSTART/ONSTOP : je met ça onStart / onStop
        // IBS FEATURIZE TRIGGERZONES : les TZ se register toutes seules, 
        // le manager doit être initialisé plus tôt ( onInitialize )
        // 
        // this.MyCPPObj.__stu__Init(this);

        // Note: for now, we do that always    

        
        var actors = STU.Experience.getCurrent().getAllActors();
        var actorCount = actors.length;

        // IBS : si TOUTES les TZ definissent un objectFilter : seuls les objets de la scene
        // faisant partie d'un de ces objectFilter doivent etre registered
        var a;
        var bFoundTriggerZoneWithNoObjFilter = false;
        var ObjectsInTZFilter = new Array();
        for (a = 0; a < actorCount; ++a) {
            var triggerZone = actors[a];
            if (triggerZone !== undefined && triggerZone !== null && triggerZone instanceof STU.TriggerZoneActor) {
                if (triggerZone.objectFilter !== undefined && triggerZone.objectFilter !== null) {
                    
                    if (triggerZone.objectFilter instanceof STU.Actor) {
                        if (!ObjectsInTZFilter.includes(triggerZone.objectFilter))
                        ObjectsInTZFilter.push(triggerZone.objectFilter);
                    }
                    // IBS May 2014 : instanceof STU.Collection is KO :
                    //else if (triggerZone.objectFilter instanceof STU.Collection) 
                    else{
                        bFoundTriggerZoneWithNoObjFilter = true;
                    }

                }// if (actor.objectFilter
                else {
                    bFoundTriggerZoneWithNoObjFilter = true;
                }
            }//  if (triggerZone !== undefined
        }//  for (a = 0

        if (!bFoundTriggerZoneWithNoObjFilter) {
            actors = ObjectsInTZFilter;
            //console.log("FILTERED TRIGGERING OBJECTS !!");
        }


        // TJR: implementation of an optimisation used in the Summer Project 2015
        // allowing to filter actors that participate to Trigger Zones with a specific
        // behavior
        // TODO: plan to deliver that officially one day !
        var filteredActors = new Array();
        actorCount = actors.length;
        for (a = 0; a < actorCount; ++a) {
            if (actors[a].TriggerZoneOptimFilter !== undefined) {
                filteredActors.push(actors[a]);
            }
        }
        if (filteredActors.length != 0) {
            actors = filteredActors;
        }



        actorCount = actors.length; 
        for (a = 0; a < actorCount; ++a) {
            var actor = actors[a];

            if (actor !== undefined && actor !== null && actor instanceof STU.TriggerZoneActor) {
                // les trigger zones se register toutes seules
            }
                // IBS ajoute test sur Text2DActor : les Text2DActor derrivent de Actor3D (pour le moment) mais on en veut pas pour les TZ
            else if (actor !== undefined && actor !== null && actor instanceof STU.Actor3D ) {
                this.registerTriggeringObject(actor);
            }
        }

        var NbTriggerZones = this.MyCPPObj.__stu__GetNbTriggerZones();
        var NbTriggeringObj = this.MyCPPObj.__stu__GetNbTriggeringObjects();
        if (NbTriggeringObj > 0 && NbTriggerZones > 0) {
            this.IsOKToRun = true;
        }

    };

    TriggerZoneManager.prototype.onStop = function () {

        //console.debug("unregistering trigger zones and triggering objects");
        for (var key in this.AllObjects) {
            if (this.AllObjects.hasOwnProperty(key)) {
                var obj = this.AllObjects[key];
                if (obj !== undefined && obj !== null && obj instanceof STU.Actor) {
                    var actor = obj;
                    if (actor !== undefined && actor !== null && actor instanceof STU.TriggerZoneActor) {
                        //this.unRegisterTriggerZone(parseInt(key));
                    } else if (actor !== undefined && actor !== null && actor instanceof STU.Actor3D) {
                        this.unRegisterTriggeringObject(parseInt(key));
                    }
                } else {
                    console.error("invalid object registed in Trigger Zone Manager");
                }
            }
        }
    };

    TriggerZoneManager.prototype._sendTZEvent = function (iTZEvent, iActor) {
        if (iActor !== undefined && iActor !== null && iTZEvent !== undefined && iTZEvent !== null) {
            //iTZEvent.setActor(iActor);

            iActor.dispatchEvent(iTZEvent);
        }
    };

    STU.registerManager(TriggerZoneManager);

    // Expose in STU namespace.
    STU.TriggerZoneManager = TriggerZoneManager;

    return TriggerZoneManager;
});

define('StuTriggerZones/StuTriggerZoneManager', ['DS/StuTriggerZones/StuTriggerZoneManager'], function (TriggerZoneManager) {
    'use strict';

    return TriggerZoneManager;
});
