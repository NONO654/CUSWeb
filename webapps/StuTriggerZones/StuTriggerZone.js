
/*
DEPRECATED - SEE TriggerZoneActor

define('DS/StuTriggerZones/StuTriggerZone', ['DS/StuCore/StuContext'], function (STU) {	
	'use strict';

//////////////////////////////////////////////////////////////////////////
// TriggerZoneTask
//
// HACK: using the task only for initializing and uninitializing the
// TriggerZone component. Waiting for a better method (activate / deactivate)
// from infra team.
//////////////////////////////////////////////////////////////////////////
var TriggerZoneTask = function (iComponent) {
    EP.Task.call(this);
    this.name = "TriggerZoneTask";
    this.comp = iComponent;
};

TriggerZoneTask.prototype = new EP.Task();
TriggerZoneTask.constructor = TriggerZoneTask;

TriggerZoneTask.prototype.onStart = function () {

    if (this.comp === undefined || this.comp === null) {
        console.error("TriggerZoneTask onStart task has an invalid component");
        return;
    }

    var actor = this.comp.getActor();
    if (actor === null) {
        // we are on a component prototype, we should not run a task
        return;
    }

    if (actor.hasOwnProperty("isPreset") && actor.isPreset == 1) {
        // we are on an actor preset, we should not run a task
        console.error("TriggerZoneTask onStart should not start if coming form a preset");
        return;
    }
};

TriggerZoneTask.prototype.onStop = function () {
    console.debug("TriggerZoneTask onStop");

    if (this.comp === undefined || this.comp === null) {
        console.error("TriggerZoneTask onStart task has an invalid component");
        return;
    }

    var actor = this.comp.getActor();
    if (actor === null) {
        // we are on a component prototype, we should not run a task
        return;
    }

    if (actor.hasOwnProperty("isPreset") && actor.isPreset == 1) {
        // we are on an actor preset, we should not run a task
        console.error("TriggerZoneTask onStart should not start if coming form a preset");
        return;
    }
};

var TriggerZone = function () {

    // Prevents multiple calls of constructor fct
    if (this.hasOwnProperty("name")) {
        return;
    }

    STU.Behavior.call(this);
    this.componentInterface = this.protoId;
    this.name = "TriggerZone";
	this.associatedTask;
    this.visu = null;
     
    

    // il faut que ça ce soit initialisé aux mêmes valeurs que coté c++
    // StudioCreativeContentUI\StudioGeometricPrimitivesEditors.m\src\StudioGeometricPrimitivesEditors.cpp
    this._myType = 1;
    this._myRadius=650.0;
    this._myLength=1000.0;
    this._myWidth=1000.0;
    this._myHeight=1000.0;
    this._myOffsetPosition = new ThreeDS.Mathematics.Vector3D();
    this._myOffsetRotation = new ThreeDS.Mathematics.Vector3D();

    Object.defineProperty(this, "type", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myType;
        },
        set: function (value) {
            this._myType = value;
            this.UpdateVisuObject();
        }
    });
    Object.defineProperty(this, "radius", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myRadius;
        },
        set: function (value) {
            this._myRadius = value;
            this.UpdateVisuObject();
        }
    });
    Object.defineProperty(this, "length", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myLength;
        },
        set: function (value) {
            this._myLength = value;
            this.UpdateVisuObject();
        }
    });
    Object.defineProperty(this, "width", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myWidth;
        },
        set: function (value) {
            this._myWidth = value;
            this.UpdateVisuObject();
        }
    });
    Object.defineProperty(this, "height", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myHeight;
        },
        set: function (value) {
            this._myHeight = value;
            this.UpdateVisuObject();
        }
    });

    Object.defineProperty(this, "offsetPosition", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myOffsetPosition;
        },
        set: function (value) {   
            this._myOffsetPosition = value;
            this.UpdateVisuObject();
        }
    });

    Object.defineProperty(this, "offsetRotation", {
        enumerable: true,
        configurable: true,
        get: function () {
            return this._myOffsetRotation;
        },
        set: function (value) {
            this._myOffsetRotation = value;
            this.UpdateVisuObject();
        }
    });



    // This filter allows to select the objects that are going
    // to trigger the zone
    // 
    // Can be either:
    //      - an actor: only this actor triggers the zone
    //      - a collection: only actors inside the collection
    //      - null: all actors of the experience trigger the zone        
    this.objectFilter = null;

    // This property allows to specify a target that will receive the event
    // sent when an object enters or exists the trigger zone.
    //
    // Can be either:
    //      - an actor: only this actor will receive the events
    //      - a collection: all object from this collection will receive the events
    //      - null: only the actor hosting the trigger zone will receive the events
    this.eventTarget = null;


    //console.log("StuTriggerZone : CTOR " + JSON.stringify(this.stuId));

    this.TriggerZoneEntry = function () {
        console.debug("TriggerZone TriggerZoneEntry " + this.stuId);

    };
    this.TriggerZoneExit = function () {
        console.debug("TriggerZone TriggerZoneExit " + this.stuId);
    };
};



TriggerZone.prototype = new STU.Behavior();
TriggerZone.prototype.constructor = TriggerZone;
TriggerZone.prototype.protoId = "1E8C6FED-ABD1-4412-BD73-477B3494A175";

TriggerZone.prototype.onActivate = function () {

	STU.Behavior.prototype.onActivate.call(this);

	this.associatedTask = new TriggerZoneTask(this);
	EP.TaskPlayer.addTask(this.associatedTask);

    this.visu = stu__TriggerZone.__stu__GetTriggerZone();
    this.initVisuObject();
    var MyManager = STU.TriggerZoneManager.getInstance();
    MyManager.registerTriggerZone(this.getActor());
};

TriggerZone.prototype.onDeactivate = function () {
	EP.TaskPlayer.removeTask(this.associatedTask);
	delete this.associatedTask;

	STU.Behavior.prototype.onDeactivate.call(this);

    var MyManager = STU.TriggerZoneManager.getInstance();
    MyManager.unRegisterTriggerZone(this.getActor());
    this.disposeVisuObject();
};

TriggerZone.prototype.initVisuObject = function () {
    if(this.visu !== undefined && this.visu !== null){
        this.visu.__stu__Init();
        this.UpdateVisuObject();
    }
};

// method used by trigger zone to get the visu object
TriggerZone.prototype.getVisuObject = function () {
   var visuObject = null;
   if(this._myType === 0){ // type product
       var myActor = this.getActor();
       if (myActor instanceof STU.Actor) {
        
           //var compPrim = iActor.getBehaviorByType(STU.Primitive3D);
           //if (compPrim) {
           // TODO: find another way to get this primitive initialized
           // before initialization of TZ Manager
           //compPrim.initVisuObject();
           //visuObject = compPrim.getVisuObject();                
           //}

           var comp3D = myActor.getBehaviorByType(STU.Node3D);
           visuObject = comp3D.getRenderable();
       }
   }
   else{
      visuObject = this.visu;
   }
   return visuObject
};

TriggerZone.prototype.UpdateVisuObject = function () {

    if(this.visu !== undefined && this.visu !== null){
        if(this._myType===0){
            var visuObject = this.getVisuObject(); 
            this.visu.__stu__SetType(0);
            this.visu.__stu__SetObjectHoldingVisu(visuObject);
        }

        this.visu.__stu__SetType(this._myType);
        this.visu.__stu__SetRadius(this._myRadius);
        this.visu.__stu__SetLength(this._myLength);
        this.visu.__stu__SetWidth(this._myWidth);
        this.visu.__stu__SetHeight(this._myHeight);
        this.visu.__stu__SetRotation(this._myOffsetRotation);
        this.visu.__stu__SetTranslation(this._myOffsetPosition);
    }
};


TriggerZone.prototype.disposeVisuObject = function () {
    this.visu.__stu__Dispose();
    this.visu = null;
};


// [TJR] for now, we cannot declare actor/collection ref properties
// from JS component prototype, therefore those properties are
// declared at C++ side. So, we prevent those JS properties
// from being registered in the prototype for now
// IBS : les paramètres double remontent vers le C++ en int, pour éviter ça on les met dans cette liste
// pour ne pas qu'ils remontent vers le C++
TriggerZone.prototype.pureRuntimeAttributes = ["objectFilter", "eventTarget","length","width","height","radius"].concat(STU.Behavior.prototype.pureRuntimeAttributes);



// Expose in STU namespace.
STU.TriggerZone = TriggerZone;

return TriggerZone;
});

define('StuTriggerZones/StuTriggerZone', ['DS/StuTriggerZones/StuTriggerZone'], function (TriggerZone) {
    'use strict';

    return TriggerZone;
});
*/
