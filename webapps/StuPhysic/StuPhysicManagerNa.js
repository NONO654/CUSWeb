// * @quickReview IBS 15:06:22 correction noms pour les outils reccord/replay 
// * @quickReview IBS 18:07:06 fix tentative CLK-3290213 CLK-3293193
/* global define */
define('DS/StuPhysic/StuPhysicManagerNa', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuCore/StuEnvServices', 'DS/StuPhysic/StuCDSDynFactory'
],
    function (STU, EP, StuEnvServices, StuCDSDynFactory) {
    'use strict';

    //////////////////////////////////////////////////////////////////////////
    // PhysicManagerTask
    //////////////////////////////////////////////////////////////////////////
    var PhysicTask = function (iManager) {

        EP.Task.call(this);

        this.name = "PhysicManagerTask";

        this.associatedManager = iManager;
    };


    PhysicTask.prototype = new EP.Task();
    PhysicTask.prototype.constructor = PhysicTask;

    PhysicTask.prototype.onExecute = function (iExContext) {
        this.associatedManager.run(iExContext);
        return this;
    };

    PhysicTask.prototype.onStart = function () {
        console.debug("PhysicManagerTask onStart");
        this.associatedManager.onStart();
    };

    PhysicTask.prototype.onStop = function () {
        console.debug("PhysicManagerTask onStop");
        this.associatedManager.onStop();
    };


    //////////////////////////////////////////////////////////////////////////
    // PhysicManager
    //////////////////////////////////////////////////////////////////////////
    
    var PhysicManager = function () {

        // IBS TEST PolyhedralClashEngine
        var myEnvServices = new StuEnvServices();
        var res = myEnvServices.CATGetEnv("IBSTestPolyhedralClashEngine");
        //console.log("StuEnvServices.CATGetEnv : " + res);
        if(res==="1")
            this._TestPolyhedralClashEngine = true;
        else
            this._TestPolyhedralClashEngine = false;

        STU.Manager.call(this);

        this.name = "PhysicManager";

        this.associatedTask;

        this.AllObjects = [];
        this.IsOKToRun = false;
        this.ObjectCount = 0;	// IBS correction noms pour les outils reccord/replay 

        // storage for CDSdyn Objects
        this.DynFactory = null;
        this.DynSolverConfig = null;
        this.DynSolver = null;
        this.DynPhysicalWorld = null;

        this.speedFactor = 1.0;
        //this.gravity = -9810; //unit -> mm / s^2
        this.worldSize = { x: 10000000, y: 10000000, z: 10000000 }; // mm
        this.nFrame = 0;

    };

    PhysicManager.prototype = new STU.Manager();
    PhysicManager.prototype.constructor = PhysicManager;
    PhysicManager.prototype.protoId = "4666D8D5-A4A4-4348-B348-61CCCBC6C283";

    /*
    * Process to execute when this STU.PhysicManager is initializing.
    *
    * @method
    * @private
    */
    PhysicManager.prototype.onInitialize = function () {

        console.debug("PhysicManager: onInitialize ");

        this.associatedTask = new PhysicTask(this);
        EP.TaskPlayer.addTask(this.associatedTask, STU.getTaskGroup(STU.ETaskGroups.ePostProcess));

        // initialize the factory
        //this.DynFactory = CDSDynCreateFactory();
        this.DynFactory = StuCDSDynFactory.buildCDSDynFactory();

        if (this.DynFactory !== undefined && this.DynFactory !== null) {

            this.DynSolverConfig = this.DynFactory.CreateSolverConfig("MySolverConfig");
            this.DynSolver = this.DynFactory.CreateSolver("MyCDSDynSolver", this.DynSolverConfig);

            // TEST : Mode relative -> test pas tres concluant, a casse tous les joins.
            // this.DynSolver.EnableRRMode();
            // TEST

            // Create the DynWorld
            this.DynPhysicalWorld = this.DynFactory.CreateWorld("MyCDSDynWorld", 0.001); // iDistanceUnits -> creative works in mm

            this.DynSolver.SetWorld(this.DynPhysicalWorld);
            this.DynPhysicalWorld.SetSize(this.worldSize.x, this.worldSize.y, this.worldSize.z); // on commence par un petit monde
            // set the gravity : unit -> mm / s ^ 2
            this.DynPhysicalWorld.SetGravity(0, 0, -9810);

            // IBS TEST PolyhedralClashEngine
            if (this._TestPolyhedralClashEngine) {
                this.DynSolver.AddCustomCollisionEngine(dynExternal("CATCDSPolyhedralClashEngine", null));
                console.log("AddCustomCollisionEngine!!!!");
            }
        }
    };

    /*
    * Process to execute when STU.PhysicManager is disposing.
    *
    * @method
    * @private
    */
    PhysicManager.prototype.onDispose = function () {

        console.debug("PhysicManager: onDispose ");

        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;

        // Release the rigid objects registred
        for (var key in this.AllObjects) {
            if (this.AllObjects.hasOwnProperty(key)) {

                var obj = this.AllObjects[key];

                if (obj !== undefined && obj !== null) {
                    this.DynFactory.ReleaseObject(obj.CDSDynRigidBody);
                }
                else {
                    console.error("invalid object registed in Trigger Zone Manager");
                }
            }
        }

        // empty the array
        STU.clear(this.AllObjects);
        this.AllObjects.length = 0;

        // Release des object CDSDyn
        this.DynFactory.ReleaseObject(this.DynSolverConfig);
        this.DynSolverConfig = null;

        this.DynFactory.ReleaseObject(this.DynSolver);
        this.DynSolver = null;

        this.DynFactory.ReleaseObject(this.DynPhysicalWorld);
        this.DynPhysicalWorld = null;

        this.speedFactor = 1.0;
        this.nFrame = 0;
        // Release de la factory : bon y'a un leak mais crach dans CDSdyn si on detruit la factory alors en attendant que ce soit fixe..
        // IBS TEST : decommente
        // XE8 : recommente CD lors de deux play a la suite
        // IBS Septembre 2015 : decommente pour permettres aux gens de CDSDyn d'analyser le pb
        // pb chez michael migliore, comment?en attendant correction pour rectifier ODT
        //CDSDynRemoveFactory(this.DynFactory);
        // IBS July 2018 : uncommented : fix tentative CLK-3290213 CLK-3293193
        CDSDynRemoveFactory(this.DynFactory);
    };


    PhysicManager.prototype.run = function (iExContext) {
        this.nFrame++;
        if (this._countdown > 0) {
            // Skip the firsts Frames to avoid simulation freezing at the beginning of the Play
            this._countdown = this._countdown - 1;
            return;
        }

        //var DeltaMilliseconde = iExContext.getDeltaTime();
        //[IR-537905] When there is big reduction in the framerate we don't want that the solver make a big step 
        // Then to avoid big step in the simulation we smooth our received framerate by averaging it
        var DeltaMilliseconde = iExContext.getElapsedTime() / this.nFrame; 

        if (DeltaMilliseconde !== 0) {

            // compute the delta time in "s" unit
            var DeltaTime = this.speedFactor * (DeltaMilliseconde) / 1000;

            this.DynSolver.SetDeltaTimeStep(DeltaTime);

            var objCount = this.AllObjects.length;

            // Set des positions du rigid pour tous les obj keyfram?
            for (var j = 0; j < objCount; j += 1) {
                this.AllObjects[j].keyframed();
            }


            // RUN DU SOLVER ICI (bloquant ou non bloquant ?)
            this.DynSolver.Run();

            // le run peut changer les positions donne aux objets driven
            // => Force les positions des positions driven
            /*for (var j = 0; j < objCount; j += 1) {
                if (this.AllObjects[j].MotionType === 2) {

                    var pos = this.AllObjects[j].computeRigidPosBasedOnActor();
                    this.AllObjects[j].setPhysicPos(pos);
                }
            }*/


            // update des positions resultantes du run du solver
            for (var i = 0; i < objCount; i += 1) {

                if (this.DrivenWithoutCollision && this.AllObjects[i].MotionType === 2 ) {
                }
                else {
                    this.AllObjects[i].updateNode3D();
                }
            }
        } else {
            console.debug("StuPhysicManager.run() : Warning -> getDeltaTime = 0  ");
        }
    };

    PhysicManager.prototype.registerRigidBody = function (iRigid) {
        console.debug(" PhysicManager registerRigidBody iRigid:" + iRigid.stuId);

        this.AllObjects[this.AllObjects.length] = iRigid;

        return this.AllObjects.length;
    };

	// IBS correction noms pour les outils reccord/replay 
    PhysicManager.prototype.getObjectCount = function () {
        this.ObjectCount = this.ObjectCount + 1;
        return this.ObjectCount;
    };

    PhysicManager.prototype.onStart = function () {
        console.debug("PhysicManager: onStart ");

        // nb of frames skipped before starting the simulation
        this._countdown = 5;

        //Read physical parameters from experience settings
        var exp = STU.Experience.getCurrent();
        var settings = exp.PlaySettings;
        if (settings !== undefined && settings !== null) {
            var simulSpeed = settings.simulationSpeed;
            if (simulSpeed !== undefined && simulSpeed !== null) {
                this.speedFactor = simulSpeed;
            }

            var gravity = settings.gravity;
            if (gravity !== undefined && gravity !== null) {
                this.gravity = gravity * 1000;
                this.DynPhysicalWorld.SetGravity(0, 0, this.gravity);
            }

            var worldSize = settings.worldSize;
            if (worldSize !== undefined && worldSize !== null) {
                this.worldSize.x = worldSize.x;
                this.worldSize.y = worldSize.y;
                this.worldSize.z = worldSize.z;

                this.DynPhysicalWorld.SetSize(this.worldSize.x, this.worldSize.y, this.worldSize.z); 
            }
        }
    };


    PhysicManager.prototype.onStop = function () {
        console.debug("PhysicManager: onStop ");
    };

    // Need to Register the Prototype into the Stu.Bridge because our componant don't have feature yet
    STU.Bridge.getInstance().registerPrototype(PhysicManager.prototype);

    // Add the manager
    STU.registerManager(PhysicManager);

    // Expose in STU namespace.
    STU.PhysicManager = PhysicManager;

    return PhysicManager;
});

define('StuPhysic/StuPhysicManagerNa', ['DS/StuPhysic/StuPhysicManagerNa'], function (PhysicManager) {
    'use strict';

    return PhysicManager;
});
