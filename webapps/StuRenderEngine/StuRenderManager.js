/*
* @quickReview IBS 19:06:12 import from 422 : correction _pickFromRay + warning for older scripts
*						see ODT StudioCreativeContent_133B_GlobePickFromRayReferentials
* @quickReview IBS 18:04:18 ajustement gestion position/referential pour line et vector
* @quickReview IBS 18:04:16 creation primitives avec positionnement / referrentiel
*							idem pour setObjectPosition
*							correction duree de vie primitives (cas life == 0)
* @quickReview IBS 18:02:12 ExternalizeSharedTransfo : one for all primitives (better creation / destruction perfo)
* @quickreview IBS 18:02:07 deleteObject
* @quickreview IBS 18:01:31 gestion de position/couleur des debugprimitives via ExternalizedArrays
*				registerObject, setObjectPosition, setObjectColor, onStop, updateDebugPrimitives
* @quickreview IBS 18:01:22 IBS migration APIs H53
* @quickreview IBS 18:01:11 gestion GetActiveEnvironment cote JS sans appel aux bindings
* @quickReview IBS 18:01:04 IR-571599 init JS experienceScaleFactor
							clipping value + focus distance take experienceScale into account
* @quickReview IBS 18:01:04 revert reg APIs JS environments (private + tagged deprecated)
* @quickReview IBS 17:10:24 Globe FD01 : init scale plus tet + gestion gravity pour lune et mars
* @quickReview IBS 17:09:04 revue APIs environment - typage des objets environments
* @quickReview IBS 17:07:29 revue APIs environment (ByName,ByNumber etc)
* @quickReview IBS 17:07:07 commentaire pour doc
* @quickReview IBS 17:05:09 restore authoring environment e la fin du play
* @quickReview IBS 17:04:26 buildVisuServices
* @quickReview IBS 17:04:24 StuEnvironmentsManager.initStartupEnvironment();
* @quickReview IBS 17:04:21 RenderManager fonctionne en repere world : 
*						les inputs sont interpretes en repere world
*						les outputs sont generes en repere world
*						=> on cache la gestion scaling globe
*/

/* global define */
define('DS/StuRenderEngine/StuRenderManager', ['DS/StuCore/StuContext', 'DS/EP/EP', 'DS/StuCore/StuManager', 'DS/EPTaskPlayer/EPTask', 'MathematicsES/MathsDef'], function (STU, EP, Manager, Task, DSMath) {
    'use strict';

    /**
	 * Describe a task which manages the STU.RenderManager execution.
	 *
	 * @exports RenderManagerPreProcessTask
	 * @class
	 * @constructor
	 * @private
	 * @extends EP.Task
	 */
    var RenderManagerPreProcessTask = function (iRenderManager) {
        Task.call(this);
        this.name = 'RenderManagerPreProcessTask';
        this.renderManager = iRenderManager;
    };

    RenderManagerPreProcessTask.prototype = new Task();
    RenderManagerPreProcessTask.prototype.constructor = RenderManagerPreProcessTask;

    /**
	 * Process to execute when this STU.RenderManagerPreProcessTask is starting.
	 *
	 * @method
	 * @private
	 */
    RenderManagerPreProcessTask.prototype.onStart = function () {
        this.renderManager.onStart();

        var exp = this.currentExperience = STU.Experience.getCurrent();
        var currentCam = null;

        //ASO4: startup camera is no more defined on playsetting object but directly on the experience
        //var playSettings = exp.PlaySettings;
        //console.log(exp.startupCamera);

        if (exp.currentCamera !== undefined && exp.currentCamera !== null) {
            currentCam = exp.currentCamera;
        }
        else if (exp.startupCamera !== undefined && exp.startupCamera !== null) {
            currentCam = exp.startupCamera;
            //If current camera is not defined, we suppose the startup camera as the current one (edit: startup cam now persisted on experience)
            exp.currentCamera = currentCam;
        }

        if (currentCam !== null) {
            this.renderManager.setCurrentCamera(currentCam);

            /* jshint camelcase : false */
            if (this.renderManager.main3DViewpoint.__stu__IsLocked() === 0) {
                this.renderManager.main3DViewer.DeactivateDefaultNavigation();
            }
        }

        EP.TaskPlayer.removeTask(this);
    };

    /**
	 * Describe a task which manages the STU.RenderManager execution.
	 *
	 * @exports RenderManagerPostProcessTask
	 * @class
	 * @constructor
	 * @private
	 * @extends EP.Task
	 */
    var RenderManagerPostProcessTask = function (iRenderManager) {
        Task.call(this);
        this.name = 'RenderManagerPostProcessTask';
        this.associatedRenderManager = iRenderManager;
    };

    RenderManagerPostProcessTask.prototype = new Task();
    RenderManagerPostProcessTask.prototype.constructor = RenderManagerPostProcessTask;

    /**
	 * Process to execute when this STU.RenderManagerPostProcessTask is starting.
	 *
	 * @method
	 * @private
	 */
    RenderManagerPostProcessTask.prototype.onStart = function () {
        this.associatedRenderManager.onStart();
    };

    /**
	 * Process to execute when this STU.RenderManagerPostProcessTask is pausing.
	 *
	 * @method
	 * @private
	 */
    RenderManagerPostProcessTask.prototype.onPause = function () {
        this.associatedRenderManager.onPause();
    };

    /**
	 * Process to execute when this STU.RenderManagerPostProcessTask is resuming.
	 *
	 * @method
	 * @private
	 */
    RenderManagerPostProcessTask.prototype.onResume = function () {
        this.associatedRenderManager.onResume();
    };

    /**
	 * Process to execute when this STU.RenderManagerPostProcessTask is stopping.
	 *
	 * @method
	 * @private
	 */
    RenderManagerPostProcessTask.prototype.onStop = function () {
        this.associatedRenderManager.onStop();
    };

    /**
	 * Process to execute when this STU.RenderManagerPostProcessTask is executing.
	 *
	 * @method
	 * @private
	 * @param {EP.PlayerContext} iPlayerContext
	 */
    RenderManagerPostProcessTask.prototype.onExecute = function (iPlayerContext) {
        this.associatedRenderManager.onPostExecute(iPlayerContext);
    };


    /**
	 * Describe a task which manages the STU.RenderManager
	 * debug primitives execution.
	 *
	 * @exports RenderManagerMainTask
	 * @class
	 * @constructor
	 * @private
	 * @extends EP.Task
	 */
    var RenderManagerMainTask = function (iRenderManager) {
        Task.call(this);
        this.name = 'RenderManagerMainTask';
        this.rm = iRenderManager;
    };

    RenderManagerMainTask.prototype = new Task();
    RenderManagerMainTask.prototype.constructor = RenderManagerPostProcessTask;

    RenderManagerMainTask.prototype.onExecute = function (iPlayerContext) {
        this.rm.updateDebugPrimitives(iPlayerContext);
    };


    /**
	 * <p>Describe a STU.Manager which is managing the visual representation and cameras of the STU.Experience.</p>
	 * <p>Information about the main 3D Viewer are accessible through this API.</p>
	 *
	 * @example
	 * //Get the render manager
	 * var renderManager = STU.RenderManager.getInstance();
	 *
	 * //Get the current camera
	 * var currentCamera = renderManager.getCurrentCamera();
	 *
	 * @exports RenderManager
	 * @class
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends STU.Manager
	 * @memberof STU
     * @alias STU.RenderManager
	 */
    var RenderManager = function () {

        Manager.call(this);

        this.name = 'RenderManager';

        // Current Camera.
        this.currentCamera = null;

        // Pointer to a C++ object wrapping the Main3DViewer
        // That object is a StuViewer object
        this.main3DViewer;

        // Pointer to a C++ object wrapping the Main3DViewpoint
        // That object is a StuViewpoint3D object
        this.main3DViewpoint = null;

        // map of debug primitive objects
        this.map = {};

        //map of uniqueID and 3Dactor used for picking
        this.pickingMap = {};

        this.experienceScaleFactor = 1.0;

        this.currentExperience = null;
    };

    RenderManager.prototype = new Manager();
    RenderManager.prototype.constructor = RenderManager;

    /**
	 * Process to execute when this STU.RenderManager is initializing.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onInitialize = function () {
        this.currentCamera = null;
        this.main3DViewer = this.buildViewer();
        this.main3DViewpoint = this.buildViewpoint();
        this.StuGeomPrimitive_ISOManager = this.buildGeomPrimitive_ISOManager(); // jshint ignore:line
        this.SharedTransfo = new Float64Array(12);
        this.StuGeomPrimitive_ISOManager.ExternalizeSharedTransfo(this.SharedTransfo);
        this.activeEnvNumber = 0;
        this.environmentsServices = this.buildEnvironmentsManager();
        if (this.environmentsServices !== null && this.environmentsServices !== undefined) {
            if (this.environmentInit === false || this.environmentInit === undefined) {
                this.authoringEnvironment = this.environmentsServices.getActiveEnvironmentNumber();
                this.activeEnvNumber = this.environmentsServices.initStartupEnvironment();
                this.experienceScaleFactor = this.environmentsServices.getExperienceScaleFactor();
                this.environmentInit = true;
            }
        }
        // do not add this task now, but when the player
        // has finished loading so that this task ends up after 
        // all other (behavioral) tasks
        this.renderTask = new RenderManagerPostProcessTask(this);
        EP.TaskPlayer.addTask(this.renderTask, STU.getTaskGroup(STU.ETaskGroups.ePostProcess));

        //Current camera init
        EP.TaskPlayer.addTask(new RenderManagerPreProcessTask(this), STU.getTaskGroup(STU.ETaskGroups.ePreProcess));

        this.debugPrimitivesTask = new RenderManagerMainTask(this);
        EP.TaskPlayer.addTask(this.debugPrimitivesTask);
    };



    RenderManager.prototype.onPlayerPostStartEvent = function () {
        EP.EventServices.removeObjectListener(EP.PlayerPostStartEvent, this, 'onPlayerPostStartEvent');
        EP.TaskPlayer.addTask(this.renderTask);
        this.renderTask.start();
    };



    /**
	 * Register an actor in the picking map
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.registerActor = function (iUniqueId, actor) {
        this.pickingMap[iUniqueId] = actor;
    };


    /**
	 * Process to execute when this STU.RenderManager is disposing.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onDispose = function () {
        EP.TaskPlayer.removeTask(this.renderTask);
        EP.TaskPlayer.removeTask(this.debugPrimitivesTask);
        delete this.renderTask;
        delete this.debugPrimitivesTask;
        delete this.main3DViewer;

        this.pickingMap = {};
    };

    /**
	 * Return the current actor camera.
	 *
	 * @method
	 * @public
	 * @return {STU.Camera}
	 */
    RenderManager.prototype.getCurrentCamera = function () {
        var exp = STU.Experience.getCurrent();
        var expCamera = exp.currentCamera;
        if (expCamera !== null && expCamera !== undefined) {
            //this.renderManager.setCurrentCamera(exp.currentCamera);
            this.currentCamera = expCamera;
        }
        return this.currentCamera;
    };

    /**
	 * Set the current actor camera.
	 *
	 * @method
	 * @public
	 * @param {STU.Camera} iActorCamera
	 */
    RenderManager.prototype.setCurrentCamera = function (iActorCamera) {
        this.currentCamera = iActorCamera;

        var exp = STU.Experience.getCurrent();
        exp.currentCamera = iActorCamera;
    };

    /**
	 * Return the 3D viewer size.
	 *
	 * @method
	 * @public
	 * @return {DSMath.Vector2D}
	 */
    RenderManager.prototype.getViewerSize = function () {
        var size = new DSMath.Vector2D();
        this.main3DViewer.GetSize(size);
        return size;
    };

    /**
	 * returns the Inverse of the size(height) of a pixel in millimeter.
	 *
	 * @method
	 * @public
	 * @return {Number}
	 */
    RenderManager.prototype.getPixelDensity = function () {
        var size = {
            pxDensity: 0
        };
        this.main3DViewer.GetPixelDensity(size);
        return size.pxDensity;
    };

    /**
	 * Return a bounding sphere which is enclosing all geometry of the 3D viewer.
	 *
	 * @method
	 * @private
	 * @return {STU.Sphere} instance object corresponding to the bounding sphere
	 */
    RenderManager.prototype.getGlobalBoundingSphere = function () {

        // IBS GLOBE SCALE getGlobalBoundingSphere renvoit un resultat dans le repere Visu
        // on renvoit le resultat module par experience scale pour avoir une valeur dans le repere World

        var sphere = new STU.Sphere();
        this.main3DViewer.GetGlobalBoundingSphere(sphere);

        var ScaleFactor = 1.0 / this.experienceScaleFactor;
        sphere.setRadius(ScaleFactor * sphere.getRadius());
        var Center = sphere.getCenter();
        sphere.setCenter(Center.multiplyScalar(ScaleFactor));
        return sphere;
    };

    /**
	 * Generate a STU.Ray from a viewer position in 2D.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Vector2D} iPosition
	 * @return {STU.Ray}
	 */
    RenderManager.prototype.getRayFromPosition = function (iPosition) {

        // IBS GLOBE SCALE getRayFromPosition renvoit un resultat dans le repere Visu
        // on renvoit le resultat module par experience scale pour avoir une valeur dans le repere World

        var ray = new STU.Ray();
        this.main3DViewer.GetRayFromPosition(iPosition, ray);

        var ScaleFactor = 1.0 / this.experienceScaleFactor;
        var Origin = ray.getOrigin();
        ray.setOrigin(Origin.multiplyScalar(ScaleFactor));
        var Direction = ray.getDirection();
        ray.setDirection(Direction.multiplyScalar(ScaleFactor));
        var Length = ray.getLength();
        ray.setLength(ScaleFactor * Length);
        return ray;
    };

    /**
	 * Generate a DSMath.Line from a viewer position in 2D.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Vector2D} iPosition
	 * @return {DSMath.Line}
	 */
    RenderManager.prototype.getLineFromPosition = function (iPosition) {

        // IBS GLOBE SCALE getLineFromPosition 
        // iPosition est un point dans le repere ecran (X,Y)
        // je veux renvoyer un resultat dans le repere Monde
        // main3DViewer travaille dans le repere Visu

        var line = new DSMath.Line();
        this.main3DViewer.GetLineFromPosition(iPosition, line);

        // line de repere Visu e Monde
        var ScaleFactor = 1.0 / this.experienceScaleFactor;
        var scaleTransform = DSMath.Transformation.makeScaling(ScaleFactor, new DSMath.Point(0, 0, 0));
        line.applyTransformation(scaleTransform);

        return line;
    };


    /**
     * Perform a picking action from a viewer position in 2D through the current STU.Experience.
     *
     * Note: if iOptions.returnFirstIntersection is set to false, the return value is an array of STU.Intersection instead of a single or null object.
     * 
     * @method
     * @public
     *
     * @param {DSMath.Vector2D} iPosition 2D position of the picking origin, in screen's referential
     * @param {object} [iOptions] Additional options.
     * @param {boolean} [iOptions.returnFirstIntersection=true] If true, only the closest intersection is returned.
     * @param {boolean} [iOptions.pickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. This may greatly impact performances combined with iReturnFirstIntersection=false.
     * @param {STU.Actor3D} [iOptions.referential] Instance object corresponding to the referential where the output coordinate will be expressed. If null, output coordinate are experessed in world context.
     *
     * @return {STU.Intersection} A single intersection or an array of intersection, according to returnFirstIntersection value
     */
    RenderManager.prototype.pickFromScreen = function (iPosition, iOptions) {
        var intersections;
        var first = true;

        if (iOptions !== undefined) {
            if (iOptions.returnFirstIntersection !== undefined)
                first = iOptions.returnFirstIntersection;
            intersections = this._pickFromPosition(iPosition, iOptions.returnFirstIntersection, iOptions.pickAllElements, iOptions.referential);
        }
        else {
            intersections = this._pickFromPosition(iPosition);
        }

        if (first) {
            if (intersections.length != 0)
                return intersections[0];
            else
                return null;
        }

        return intersections;
    }

    /**
     * Perform a picking action from a STU.Ray through the current STU.Experience.
     *
     * Note: if iOptions.returnFirstIntersection is set to false, the return value is an array of STU.Intersection instead of a single or null object.
     * 
     * @method
     * @public
     *
     * @param {STU.Ray} iRay ray definition in given referential.
     * @param {object} [iOptions] Additional options.
     * @param {boolean} [iOptions.returnFirstIntersection=true] If true, only the closest intersection is returned.
     * @param {boolean} [iOptions.pickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. This may greatly impact performances combined with iReturnFirstIntersection=false.
     * @param {STU.Location} [iOptions.referential] STU.Location object corresponding to the referential where the output coordinate will be expressed. If null, output coordinate are experessed in world context.
     *
     * @return {STU.Intersection} A single intersection or an array of intersection, according to returnFirstIntersection value.
     */
    RenderManager.prototype.pickFromRay = function (iRay, iOptions) {
        var intersections;
        var first = true;

        if (iOptions !== undefined) {
            if (iOptions.returnFirstIntersection !== undefined)
                first = iOptions.returnFirstIntersection;
            intersections = this._pickFromRay(iRay, iOptions.returnFirstIntersection, iOptions.pickAllElements, iOptions.referential);
        }
        else {
            intersections = this._pickFromRay(iRay);
        }

        if (first) {
            if (intersections.length != 0)
                return intersections[0];
            else
                return null;
        }

        return intersections;
    }

    /**
     * Perform a picking action from a STU.Ray through the current STU.Experience.
     *
     * Note: if iOptions.returnFirstIntersection is set to false, the return value is an array of STU.Intersection instead of a single or null object.
     * 
     * @method
     * @private
     *
     * @param {DSMath.Line} iLine line definition in given referential.
     * @param {object} [iOptions] Additional options.
     * @param {boolean} [iOptions.returnFirstIntersection=true] If true, only the closest intersection is returned.
     * @param {boolean} [iOptions.pickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. This may greatly impact performances combined with iReturnFirstIntersection=false.
     * @param {STU.Location} [iOptions.referential] Instance object corresponding to the referential where the output coordinate will be expressed. If null, output coordinate are experessed in world context.
     *
     * @return {STU.Intersection} A single intersection or an array of intersection, according to returnFirstIntersection value
     */
    RenderManager.prototype.pickFromLine = function (iLine, iOptions) {
        var intersections;
        var first = true;

        if (iOptions !== undefined) {
            if (iOptions.returnFirstIntersection !== undefined)
                first = iOptions.returnFirstIntersection;

            intersections = this._pickFromLine(iLine, iOptions.returnFirstIntersection, iOptions.pickAllElements, iOptions.referential);
        }
        else {
            intersections = this._pickFromLine(iLine);
        }

        if (first) {
            if (intersections.length != 0)
                return intersections[0];
            else
                return null;
        }

        return intersections;
    }


    /**
     * Perform a picking action toward the ground from a specified origin through the current STU.Experience.
     *
     * @method
     * @public
     *
     * @param {DSMath.Point} iPosition the origin of the raycast expressed in the specified reference (in world reference if there is no reference specified).
     * @param {object} [iOptions] Additional options.     
     * @param {boolean} [iOptions.pickGeometry=true] If enabled, the picking will take in count the geometry of the actors present in the experience.
     * @param {boolean} [iOptions.pickTerrain=true] If enabled, the picking will take in count the mesh representing the terrain (Only in globe context).
     * @param {boolean} [iOptions.pickWater=true] If enabled, the picking will take in count the shader representing the water (Only in globe context).
     * @param {STU.Actor3D} [iOptions.referential] Instance object corresponding to the referential where the output coordinate will be expressed. If null, output coordinate are experessed in world context.
     *
     * @return {STU.Intersection}
     */
    RenderManager.prototype.pickGroundFromPosition = function (iPosition, iOptions) {
        var params = {};

        if (iPosition instanceof DSMath.Transformation) {
            params.position = new DSMath.Point(iPosition.vector.x, iPosition.vector.y, iPosition.vector.z);
        }
        else {
            params.position = iPosition.clone();
        }

        if (iOptions !== undefined) {
            params.pickGeometry = iOptions.pickGeometry;
            params.pickTerrain = iOptions.pickTerrain;
            params.pickWater = iOptions.pickWater;
            params.reference = iOptions.referential;
        }

        return this._pickGroundFromPosition(params);
    }


    /**
     * Create and display a box shape.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation} iTransform The origin of the box.
     * @param {DSMath.Vector3D} iSize The size of the box on each axis.
     * @param {object} [iOptions] Some aditional options.
     * @param {boolean} [iOptions.screenSize=false] If true, then size if interpreted as a constant screen size in mm.
     * @param {number} [iOptions.thickness] If set, then controls the thickness in mm of the drawn lines.
     * @param {boolean} [iOptions.wireframe=true] If true, the box is displayed with lines and not solid faces.
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime=-1] The lifetime of the displayed object. 
        <br/>if -1, the shape will be visible until destroyed
        <br/>if 0 the shape will be visible only one frame
        <br/>if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createBox = function (iTransform, iSize, iOptions) {
        var params = {};
        params.position = iTransform;
        params.size = iSize;
        params.close = false;
        params.centered = 1;
        params.alpha = 255;

        if (iOptions !== undefined) {
            params.lineWidth = iOptions.thickness;
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;

            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
            if (iOptions.screenSize !== undefined)
                params.screenSize = iOptions.screenSize === true ? 1 : 0;
            if (iOptions.wireframe !== undefined)
                params.closed = iOptions.wireframe === true ? 0 : 1;
        }

        var prim = new STU.VisuPrimitive();
        prim.id = this._createBox(params);
        return prim;
    }

    /**
     * Create and display a sphere shape.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation|DSMath.Point} iTransform The origin of the sphere.
     * @param {number} iRadius The radius of the sphere in mm.
     * @param {object} [iOptions] Some aditional options.
     * @param {boolean} [iOptions.screenSize=false] If true, then size if interpreted as a constant screen size in mm.          
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime=-1] The lifetime of the displayed object. 
        if -1, the shape will be visible until destroyed
        if 0 the shape will be visible only one frame
        if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createSphere = function (iTransform, iRadius, iOptions) {
        var params = {};
        params.position = iTransform;
        params.radius = iRadius;
        params.alpha = 255;

        if (iTransform instanceof DSMath.Point) {
            params.position = new DSMath.Transformation();
            params.position.setVector(iTransform.x, iTransform.y, iTransform.z);
        }

        if (iOptions !== undefined) {
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;


            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
            if (iOptions.screenSize !== undefined)
                params.screenSize = iOptions.screenSize === true ? 1 : 0;
        }

        var prim = new STU.VisuPrimitive();
        prim.id = this._createSphere(params);
        return prim;
    }

    /**
     * Create and display a point with a fixed size on screen.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation|DSMath.Vector3D|DSMath.Point} iPosition The position of the point shape.
     * @param {object} [iOptions] Some aditional options.
     * @param {boolean} [iOptions.size=2] If set, defines the radius of the point in mms on screen.
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime-1] The lifetime of the displayed object. 
        if -1, the shape will be visible until destroyed
        if 0 the shape will be visible only one frame
        if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createPoint = function (iPosition, iOptions) {
        var params = {};

        if (iPosition instanceof DSMath.Point || iPosition instanceof DSMath.Vector3D) {
            params.position = new DSMath.Transformation();
            params.position.setVector(iPosition.x, iPosition.y, iPosition.z);
        }
        else if (iPosition instanceof DSMath.Transformation) {
            params.position = iPosition;
        }

        params.alpha = 255;

        if (iOptions !== undefined) {
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;

            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
            if (iOptions.size !== undefined)
                params.size = iOptions.size / 2;
        }


        var prim = new STU.VisuPrimitive();
        prim.id = this._createPoint(params);
        return prim;
    }


    /**
     * Create and display a vector (an arrow) shape.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation|DSMath.Vector3D|DSMath.Point} iOrigin The origin of the arrow.
     * @param {DSMath.Vector3D} iDirection The direction the arrow is pointing toward.
     
     * @param {object} [iOptions] Some aditional options.     
     * @param {number} [iOptions.length=10] The length of the arrow (from the base to the tip of the head).
     * @param {number} [iOptions.thickness=auto] If set, controls the thickness in mms of the arrow's base. If unset, the thickness will be computed automatically (length / 100).
     * @param {number} [iOptions.headLength=auto] If set, controls the length of the arrow's head.
     * @param {number} [iOptions.headWidth=auto] If set, controls the width of the arrow's head.
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.     
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime] The lifetime of the displayed object. 
        if -1, the shape will be visible until destroyed
        if 0 the shape will be visible only one frame
        if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createVector = function (iOrigin, iDirection, iOptions) {

        var params = {};
        params.direction = iDirection.clone();
        params.length = 10;
        params.alpha = 255;
        params.screenSize = 1;

        if (iOrigin instanceof DSMath.Point || iOrigin instanceof DSMath.Vector3D) {
            params.startPoint = iOrigin.clone();
        }
        else if (iOrigin instanceof DSMath.Transformation) {
            params.startPoint = iOrigin.vector.clone();
        }

        if (iOptions !== undefined) {
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;
            params.headWidth = iOptions.headWidth;
            params.headLength = iOptions.headLength;

            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
            if (iOptions.length !== undefined)
                params.length = iOptions.length;
            if (iOptions.screenSize !== undefined)
                params.screenSize = iOptions.screenSize === true ? 1 : 0;
            if (iOptions.thickness != undefined)
                params.width = iOptions.thickness;
        }

        var prim = new STU.VisuPrimitive();
        prim.id = this._createVector(params);
        return prim;
    }

    /**
     * Create and display a line shape.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation|DSMath.Vector3D|DSMath.Point} iOrigin The origin of the line.
     * @param {DSMath.Transformation|DSMath.Vector3D|DSMath.Point} iEnd The end of the line.     
     * @param {object} [iOptions] Some aditional options.     
     * @param {number} [iOptions.thickness=auto] If set, controls the thickness in mms of the arrow's base. If unset, the thickness will be computed automatically (length / 100).     
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.     
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime=-1] The lifetime of the displayed object. 
        if -1, the shape will be visible until destroyed
        if 0 the shape will be visible only one frame
        if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createLine = function (iOrigin, iEnd, iOptions) {
        var params = {};
        params.alpha = 255;

        if (iOrigin instanceof DSMath.Point || iOrigin instanceof DSMath.Vector3D) {
            params.startPoint = iOrigin.clone();
        }
        else if (iOrigin instanceof DSMath.Transformation) {
            params.startPoint = iOrigin.vector.clone();
        }

        if (iEnd instanceof DSMath.Point || iEnd instanceof DSMath.Vector3D) {
            params.endPoint = iEnd.clone();
        }
        else if (iEnd instanceof DSMath.Transformation) {
            params.endPoint = iEnd.vector.clone();
        }

        if (iOptions !== undefined) {
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;
            params.width = iOptions.thickness;

            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
        }


        var prim = new STU.VisuPrimitive();
        prim.id = this._createLine(params);
        return prim;
    }


    /**
     * Create and display a axis system shape.
     *      
     * @method
     * @public
     *
     * @param {DSMath.Transformation} iTransform The tranformation defining the axis system.
     * @param {object} [iOptions] Some aditional options.     
     * @param {number} [iOptions.thickness=auto] If set, controls the thickness in mms of the arrow's base. If unset, the thickness will be computed automatically (length / 100).
     * @param {boolean} [iOptions.size=10] The length of each arrow representing the axes.     
     * @param {boolean} [iOptions.screenSize=true] If true, then size if interpreted as a constant screen size in mm.          
     * @param {STU.Actor3D} [iOptions.referential] The object corresponding to the referential in which the inputs informations are given.     
     * @param {STU.Color} [iOptions.color] The color of the displayed shape.
     * @param {number} [iOptions.opacity=1] The opacity of the displayed shape. 0 is fully transparent, 1 is fully opaque.
     * @param {number} [iOptions.lifetime=-1] The lifetime of the displayed object. 
        if -1, the shape will be visible until destroyed
        if 0 the shape will be visible only one frame
        if >0 the shape will be disappear progressively during N milliseconds
     * 
     * @return {STU.VisuPrimitive}
     */
    RenderManager.prototype.createAxes = function (iTransform, iOptions) {
        var params = {};
        params.position = iTransform;
        params.alpha = 255;
        params.size = 10;
        params.screenSize = true;

        if (iOptions !== undefined) {
            params.referential = iOptions.referential;
            params.color = iOptions.color;
            params.lifetime = iOptions.lifetime;
            if (iOptions.opacity !== undefined)
                params.alpha = iOptions.opacity * 255;
            if (iOptions.size !== undefined)
                params.size = iOptions.size;
            if (iOptions.screenSize !== undefined)
                params.screenSize = iOptions.screenSize === true ? 1 : 0;
        }

        var prim = new STU.VisuPrimitive();
        prim.id = this._createAxis(params);
        return prim;
    }



    /**
	 * Perform a picking action from a viewer position in 2D through the current STU.Experience.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Vector2D} iPosition
	 * @param {Boolean} [iReturnFirstIntersection=true] If true, the returned array will contain only the closest intersection.
	 * @param {Boolean} [iPickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. 
	 * This may greatly impact performances combined with iReturnFirstIntersection=false.
	 * @param {STU.Actor3D} [iReferential=null] Instance object corresponding to the referential where the output coordinate will be expressed. If null, output coordinate are experessed in world context.
	 * @return {Array.<STU.Intersection>}
	 */
    RenderManager.prototype._pickFromPosition = function (iPosition, iReturnFirstIntersection, iPickAllElements, iReferential) {

        // IBS GLOBE SCALE _pickFromPosition 
        // iPosition est un point dans le repere ecran (X,Y)
        // je veux renvoyer un resultat dans le repere Monde
        // main3DViewer travaille dans le repere Visu

        var intersections = [];
        var returnFirstIntersection = (typeof iReturnFirstIntersection === 'undefined') ? true : iReturnFirstIntersection;
        var pickAllElements = (typeof iPickAllElements === 'undefined') ? false : iPickAllElements;

        this.main3DViewer.PickFromPosition(iPosition, intersections, returnFirstIntersection, pickAllElements);
        var exp = STU.Experience.getCurrent();

        for (var i = 0; i < intersections.length; i++) {

            var interElem = intersections[i];
            var actor = null;

            // intersections de repere Visu e Monde
            var ScaleFactor = 1.0 / this.experienceScaleFactor;
            interElem.point.multiplyScalar(ScaleFactor);

            //uniqueID is created bv StuESActor3DBuilder and thus available only in native mode
            if (interElem.uniqueID !== undefined) {
                actor = this.pickingMap[interElem.uniqueID];
            }
            else {
                var actorName = interElem.actorName;
                if (actorName.length > 0) {
                    actor = exp.getActorByName(actorName, true);
                }
            }

            if (!pickAllElements && (actor === undefined || actor === null)) {
                continue;
            }

            if (iReferential !== null && iReferential !== undefined && iReferential instanceof STU.Actor3D) {
                var invTransfoScene = iReferential.getTransform("World").getInverse();
                interElem.point = interElem.point.applyTransformation(invTransfoScene);
                interElem.normal = interElem.normal.applyTransformation(invTransfoScene);
            }

            var intersection = new STU.Intersection();
            intersection.setPoint(interElem.point);
            intersection.setNormal(interElem.normal);
            intersection.setActor(actor);

            intersections[i] = intersection;
        }


        return intersections;
    };

    /**
	 * Perform a picking action from a STU.Ray through the current STU.Experience.
	 *
	 * @method
	 * @private
	 * @param {STU.Ray} iRay
	 * @param {Boolean} [iReturnFirstIntersection=true] If true, the returned array will contain only the closest intersection.
	 * @param {Boolean} [iPickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. 
	 * This may greatly impact performances combined with iReturnFirstIntersection=false.
	 * @param {STU.Location} [iReferential=null] Location object corresponding to the referential where the input coordinate should be expressed and the output coordinate will be expressed. If null, all coordinate are experessed in world context.
	 * @return {Array.<STU.Intersection>}
	 */
    RenderManager.prototype._pickFromRay = function (iRay, iReturnFirstIntersection, iPickAllElements, iReferential) {

        if (iReferential !== null && iReferential !== undefined && !iReferential instanceof STU.Location) {
            console.warn("Picking with a referential that is not a location should not be called");
        }

        // clone pour ne pas pourrir iRay, si il est réutilisé après
        var MyRay = new STU.Ray();
        MyRay.origin = iRay.origin.clone();
        MyRay.direction = iRay.direction.clone();
        MyRay.length = iRay.length;

        var VisuToWorldScaleFactor = 1.0
        var intersections = [];
        var returnFirstIntersection = (typeof iReturnFirstIntersection === 'undefined') ? true : iReturnFirstIntersection;
        var pickAllElements = (typeof iPickAllElements === 'undefined') ? false : iPickAllElements;

        // 1 : Express ray from iRef to World context if necessary
        if (iReferential !== null && iReferential !== undefined && iReferential instanceof STU.Actor3D) {

            var transformRefToWorld = iReferential.getTransform("World");
            MyRay.origin.applyTransformation(transformRefToWorld);
            MyRay.direction.applyTransformation(transformRefToWorld);
            MyRay.length /= transformRefToWorld.getScaling().scale;
        }

        // 2 : convert from World to Visu referetial (experienceScaleFactor)
        var VisuRay = new STU.Ray();
        VisuRay.origin = MyRay.origin.clone();
        VisuRay.direction = MyRay.direction.clone();
        VisuRay.length = MyRay.length;

        var WorldToVisuScaleFactor = this.experienceScaleFactor;
        VisuRay.setOrigin(MyRay.getOrigin().multiplyScalar(WorldToVisuScaleFactor));
        //VisuRay.setDirection(MyRay.getDirection().multiplyScalar(WorldToVisuScaleFactor));
        VisuRay.setLength(MyRay.getLength() * WorldToVisuScaleFactor);


        // 3 : PICK
        this.main3DViewer.PickFromRay(VisuRay, intersections, returnFirstIntersection, pickAllElements);

        VisuToWorldScaleFactor = 1.0 / this.experienceScaleFactor;
        var exp = STU.Experience.getCurrent();

        for (var i = 0; i < intersections.length; i++) {

            // 4 : convert result from Visu to World referential
            intersections[i].point.multiplyScalar(VisuToWorldScaleFactor);

            var interElem = intersections[i];
            var actor = null;

            // uniqueID is created bv StuESActor3DBuilder and thus available only in native mode
            if (interElem.uniqueID !== undefined) {
                actor = this.pickingMap[interElem.uniqueID];
            }
            else {
                var actorName = interElem.actorName;
                if (actorName.length > 0) {
                    actor = exp.getActorByName(actorName, true);
                }
            }

            if (!pickAllElements && (actor === undefined || actor === null)) {
                continue;
            }

            // 5 : convert result from World to iRef context if necessary
            if (iReferential !== null && iReferential !== undefined && iReferential instanceof STU.Actor3D) {
                var transformWorldToRef = iReferential.getTransform("World").getInverse();
                interElem.point = interElem.point.applyTransformation(transformWorldToRef);
                interElem.normal = interElem.normal.applyTransformation(transformWorldToRef);
            }

            var intersection = new STU.Intersection();
            intersection.setPoint(interElem.point);
            intersection.setNormal(interElem.normal);
            intersection.setActor(actor);

            // _pickPath is used with VIVE to be able to pick 3DUIActors            
            if(interElem._pickPath !== undefined){
                intersection._pickPath = interElem._pickPath;
            }

            intersections[i] = intersection;
        }

        return intersections;
    };

    /**
	 * Perform a picking action from a DSMath.Line through the current STU.Experience.
	 *
	 * @method
	 * @private
	 * @param {DSMath.Line} iLine
	 * @param {Boolean} [iReturnFirstIntersection=true] If true, the returned array will contain only the closest intersection.
	 * @param {Boolean} [iPickAllElements=false] If true, all objects intersected by the ray will be returned not only actors. 
	 * This may greatly impact performances combined with iReturnFirstIntersection=false.
	 * @param {STU.Actor3D} [iReferential=null] Instance object corresponding to the referential where the input coordinate should be expressed and the output coordinate will be expressed. If null, all coordinate are experessed in world context.
	 * @return {Array.<STU.Intersection>}
	 */
    RenderManager.prototype._pickFromLine = function (iLine, iReturnFirstIntersection, iPickAllElements, iReferential) {

        // IBS GLOBE SCALE _pickFromLine 
        // iLine est un rayon dans le repere monde
        // je veux renvoyer un resultat dans le repere Monde
        // main3DViewer travaille dans le repere Visu

        var intersections = [];
        var returnFirstIntersection = (typeof iReturnFirstIntersection === 'undefined') ? true : iReturnFirstIntersection;
        var pickAllElements = (typeof iPickAllElements === 'undefined') ? false : iPickAllElements;

        //Express Line in world context
        if (iReferential !== null && iReferential !== undefined && iReferential instanceof STU.Actor3D) {
            var transformScene = iReferential.getTransform();
            var transformSceneWorld = iReferential.getTransform("World");
            var transfoScene2World = DSMath.Transformation.multiply(transformSceneWorld, transformScene.getInverse());
            iLine.applyTransformation(transfoScene2World);
            var Scene2WorldScaling = transformSceneWorld.getScaling().scale / transformScene.getScaling().scale;
            //iRay.direction.applyTransformation(transfoScene2World);
            iLine.scale /= Scene2WorldScaling;
        }

        // iLine de repere Monde e Visu
        var WorldToVisuScaleFactor = this.experienceScaleFactor;
        var VisuLine = iLine.clone();
        VisuLine.set(WorldToVisuScaleFactor * iLine.origin.x, WorldToVisuScaleFactor * iLine.origin.y, WorldToVisuScaleFactor * iLine.origin.z, WorldToVisuScaleFactor * iLine.direction.x, WorldToVisuScaleFactor * iLine.direction.y, WorldToVisuScaleFactor * iLine.direction.z);

        this.main3DViewer.PickFromLine(VisuLine, intersections, returnFirstIntersection, pickAllElements);
        var exp = STU.Experience.getCurrent();

        for (var i = 0; i < intersections.length; i++) {

            var interElem = intersections[i];
            // intersections de repere Visu e Monde
            var VisuToWorldScaleFactor = 1.0 / this.experienceScaleFactor;
            interElem.point.multiplyScalar(VisuToWorldScaleFactor);

            var actor = null;

            //uniqueID is created bv StuESActor3DBuilder and thus available only in native mode
            if (interElem.uniqueID !== undefined) {
                actor = this.pickingMap[interElem.uniqueID];
            }
            else {
                var actorName = interElem.actorName;
                if (actorName.length > 0) {
                    actor = exp.getActorByName(actorName, true);
                }
            }

            if (!pickAllElements && (actor === undefined || actor === null)) {
                continue;
            }

            if (iReferential !== null && iReferential !== undefined && iReferential instanceof STU.Actor3D) {
                var invTransfoScene = iReferential.getTransform("World").getInverse();
                interElem.point = interElem.point.applyTransformation(invTransfoScene);
                interElem.normal = interElem.normal.applyTransformation(invTransfoScene);
            }

            var intersection = new STU.Intersection();
            intersection.setPoint(interElem.point);
            intersection.setNormal(interElem.normal);
            intersection.setActor(actor);

            intersections[i] = intersection;
        }


        return intersections;
    };


    /**
	 * Get the mouse position in the viewer
	 * 		(0,0) is the top left corner
	 * 		(getViewerSize().x, getViewerSize().y) is the bottom right corner
	 *
	 * @method
	 * @private
	 * @return  {DSMath.Vector2D}         Position of mouse
	 */
    RenderManager.prototype.getMousePosition = function () {
        var pos = new DSMath.Vector2D();
        this.main3DViewer.GetMousePosition(pos);
        return pos;
    };

    /**
	 * Set the mouse position in the viewer
	 * 		(0,0) is the top left corner
	 * 		(getViewerSize().x, getViewerSize().y) is the bottom right corner
	 *
	 * @method
	 * @private
	 * @param   {DSMath.Vector2D}     iPos Position of mouse
	 * @see STU.RenderManager.getViewerSize()
	 */
    RenderManager.prototype.setMousePosition = function (iPos) {
        this.main3DViewer.SetMousePosition(iPos);
    };

    /**
	 * Hide the mouse cursor
	 * @method
	 * @private
	 */
    RenderManager.prototype.hideMouseCursor = function () {
        this.main3DViewer.HideMouseCursor();
    };

    /**
	 * Restore the mouse cursor
	 * @method
	 * @private
	 */
    RenderManager.prototype.showMouseCursor = function () {
        this.main3DViewer.ShowMouseCursor();
    };

    /**
	 * highlight the input actor
	 * @method
	 * @private
	 * @param   {STU.Actor3D}     iActor actor which is to be highlighted.
	 * @param   {Integer}     iOption 1 for highlight and 0 for removing highlight
	 */
    RenderManager.prototype.highlight = function (actor, option) {
        var currentActor = actor.CATI3DExperienceObject;
        this.main3DViewer.HighlightDisplay(currentActor, option);
    };


    /**
	 * Prehighlight the input actor
	 * @method
	 * @private
	 * @param   {STU.Actor3D}     iActor actor which is to be highlighted.
	 * @param   {Integer}     iOption 1 for prehighlight and 0 for removing prehighlight
	 */
    RenderManager.prototype.preHighlight = function (actor, option) {
        var currentActor = actor.CATI3DExperienceObject;
        this.main3DViewer.PreHighlightDisplay(currentActor, option);
    };

    /**
	 * IBS TEST
	 * TODO : objet JS qui fourni des services globes / acces au GlobeEngine 
     * @private
	 */
    //RenderManager.prototype.getGravityVector = function (iPositionInGivenRef, oGravityDirInGivenRef, iWorkingReferential) {
    //this.main3DViewer.GetGravityVector(iPositionInGivenRef, oGravityDirInGivenRef, iWorkingReferential);

    RenderManager.prototype.getGravityVector = function (iActor, iRef) {
        // temporairement on fait une methode pourrie : on regarde si on a un GlobePositioningActor
        // si oui : 
        // on suppose qu'on est en globe, on renvoit l'axe -z de la location 
        // (CATIMovable de la location s'assure que l'axe z passe par le centre de la planete) 
        // si pas de location => gravity = (0,0,-1)

        var oGravity;

        var actorLocation = null;
        if (iActor !== null && iActor !== undefined) {
            actorLocation = iActor.getLocation();
        }

        if (actorLocation !== null && actorLocation !== undefined) {
            var LocationTransfo = actorLocation.getTransform("World"); // actorLocation pour garder une gravity constante dans une scene ?
            oGravity = new DSMath.Vector3D(0.0, 0.0, -1.0);
            oGravity.applyTransformation(LocationTransfo);

            if (iRef === "World") {
            }
            else if (iRef === "Location") {
                /*var locTransform = actorLocation.getTransform("World");
                var invLocTransform = locTransform.getInverse();
                oGravity.applyTransformation(invLocTransform);*/
                oGravity = new DSMath.Vector3D(0.0, 0.0, -1.0);
            }
            else if (iRef instanceof STU.Actor3D) {
                var refTransform = iRef.getTransform("World");
                var invRefTransform = refTransform.getInverse();
                oGravity.applyTransformation(invRefTransform);
            }

            //oGravity.negate();
            oGravity.normalize();
            return oGravity;
        }
        else {
            oGravity = new DSMath.Vector3D(0.0, 0.0, -1.0);
            if (iRef === "World" || iRef === "Location") {
            }
            else if (iRef instanceof STU.Actor3D) {
                var refTransform = iRef.getTransform("World");
                var invRefTransform = refTransform.getInverse();
                oGravity.applyTransformation(invRefTransform);
            }
            oGravity.normalize();
            return oGravity;
        }
    };

    // IBS TODO : mettre qqpart sur un objet JS qui va binder des methodes du GlobeEngine
    //RenderManager.prototype.globePickVertical = function (iPositionInWorldRef, oAltitude) {
    //	this.main3DViewer.GlobePickVertical(iPositionInWorldRef, oAltitude);
    //};

    /**
	 * Perform a picking action toward the ground from a specified origin through the current STU.Experience.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of these parameters :
	 * @param   {DSMath.Point} position : the origin of the raycast expressed in the specified reference (in world reference if there is no reference specified)
	 * @param   {STU.Actor3D} reference : the reference actor in which the origin and the result of the raycast will be expressed 
	 * @param   {boolean} pickGeometry : if enabled, the picking will take in count the geometry of the actors present in the experience.
	 * @param   {boolean} pickTerrain : if enabled, the picking will take in count the mesh representing the terrain (Only in globe context)
	 * @param   {boolean} pickWater : if enabled, the picking will take in count the shader representing the water (Only in globe context)
	 
	 *
	 * DEFAULT VALUES :
	 * position : [no default value]
	 * reference : null
	 * pickGeometry : true
	 * pickTerrain : true
	 * pickWater : true
	 */
    RenderManager.prototype._pickGroundFromPosition = function (iParams) {
        if (iParams !== null && iParams !== undefined) {
            var pickGeo = (iParams.pickGeometry !== null && iParams.pickGeometry !== undefined) ? iParams.pickGeometry : true;
            var pickTerrain = (iParams.pickTerrain !== null && iParams.pickTerrain !== undefined) ? iParams.pickTerrain : true;
            var pickWater = (iParams.pickWater !== null && iParams.pickWater !== undefined) ? iParams.pickWater : true;

            var pickRayLength_mm = 1000000;     // millimeters
            var planetRadius_m = 0;             // meters
            var planetOrigin_W_m = undefined;   // world ref, meters
            var planetOrigin_W_mm = undefined;  // world ref, millimeters
            var env = undefined;
            if (this.environmentsServices !== undefined && this.environmentsServices !== null) {
                env = STU.Experience.getCurrent().getActiveEnvironment();
            }

            if ((env === null || env === undefined) || !(env instanceof STU.Planets)) {
                pickTerrain = false;
                pickWater = false;
            } else {
                // IBS migration APIs H53
                var planet = env.getCurrentPlanet();
                planetRadius_m = planet.radius; // meters    no binding web
                pickRayLength_mm = planetRadius_m;
                planetOrigin_W_m = planet.getPlanetaryReferential().vector;
                planetOrigin_W_mm = planetOrigin_W_m.clone();
                planetOrigin_W_mm.multiplyScalar(1000);     // millimeters
            }

            var intersections = [];
            var pickOrigin_Ref_mm = new DSMath.Point(iParams.position.x, iParams.position.y, iParams.position.z);
            var pickOrigin_W_mm = pickOrigin_Ref_mm.clone();

            // pickOrigin_Ref_mm is expressed in the referential of iParams.reference
            // we want it expressed in world referential
            if (iParams.reference !== null && iParams.reference !== undefined) {
                var refTransfo_W = iParams.reference.getTransform("World");
                pickOrigin_W_mm.applyTransformation(refTransfo_W);
            }

            if (pickGeo) {
                var gravityVector_W = new DSMath.Vector3D(0, 0, -1);

                // le vecteur gravity varie suivant ces 2 situations:
                // Si le globe est actif ==> GravityVecteur = (planetOrigin - pickOrigin)
                if (env !== null && env !== undefined && (env instanceof STU.Planets)) {
                    gravityVector_W.set(pickOrigin_W_mm.x - planetOrigin_W_mm.x, pickOrigin_W_mm.y - planetOrigin_W_mm.y, pickOrigin_W_mm.z - planetOrigin_W_mm.z);
                    gravityVector_W.negate();
                    gravityVector_W.normalize();
                }
                //Sinon ==> gravityVector_W = new DSMath.Vector3D(0, 0, -1);

                var collisionRay = new STU.Ray();
                collisionRay.origin = pickOrigin_W_mm;
                collisionRay.direction = gravityVector_W;
                collisionRay.setLength(pickRayLength_mm);

                var hit = this._pickFromRay(collisionRay, true, false);
                if (hit.length > 0) {
                    intersections.push(hit[0]);
                }
            }

            if (pickTerrain || pickWater) {
                var planetCenterToPickOrigin_W_mm = (pickOrigin_W_mm.sub(planetOrigin_W_mm));
                var pickOrigin_W_m = new DSMath.Vector3D(pickOrigin_W_mm.x * 0.001, pickOrigin_W_mm.y * 0.001, pickOrigin_W_mm.z * 0.001); // conversion Point -> Vector et mm -> m
                var planetID = env.getCurrentPlanet().id;

                var altitudeGround_m = 0;
                var altitudeWater_m = 0;
                var altitude_m = 0;
                if (pickTerrain) {
                    altitudeGround_m = env.pickVertical(pickOrigin_W_m, planetID, false); // travaille dans repere monde en metres
                    altitude_m = altitudeGround_m;
                }
                if (pickWater && planetID === 0) {
                    altitudeWater_m = env.pickVertical(pickOrigin_W_m, planetID, true); // travaille dans repere monde en metres
                    if (altitudeWater_m > altitude_m) {
                        altitude_m = altitudeWater_m;
                    }
                }

                var up_W = planetCenterToPickOrigin_W_mm.clone().normalize();
                var planetCenterToPickResult_W_mm = DSMath.Vector3D.multiplyScalar(up_W, (planetRadius_m + altitude_m) * 1000);
                var pickResult_W_mm = new DSMath.Point(planetOrigin_W_mm.x + planetCenterToPickResult_W_mm.x, planetOrigin_W_mm.y + planetCenterToPickResult_W_mm.y, planetOrigin_W_mm.z + planetCenterToPickResult_W_mm.z);
                var intersection = new STU.Intersection();
                intersection.setPoint(pickResult_W_mm);
                intersections.push(intersection);
            }

            var nearestIntersection = null;
            var nearestDistance = -1;

            if (intersections.length < 1) {
                //console.warn("[_pickGroundFromPosition (RenderManager)] No ground detected");
                return null;
            } else if (intersections.length === 1) {
                nearestIntersection = intersections[0];
                nearestDistance = intersections[0].point.squareDistanceTo(pickOrigin_W_mm);
            } else {
                nearestIntersection = intersections[0];
                nearestDistance = intersections[0].point.squareDistanceTo(pickOrigin_W_mm);

                for (var i = intersections.length - 1; i > 0; i--) {
                    var distance = intersections[i].point.squareDistanceTo(pickOrigin_W_mm);
                    if (distance < nearestDistance) {
                        nearestIntersection = intersections[i];
                        nearestDistance = distance;
                    }
                }
            }

            //Express the result in reference
            if (iParams.reference !== null && iParams.reference !== undefined) {
                var invRefTransfo_W = iParams.reference.getTransform("World").getInverse();
                nearestIntersection.point = nearestIntersection.point.applyTransformation(invRefTransfo_W);
                if (nearestIntersection.normal !== null && nearestIntersection.normal !== undefined) {
                    nearestIntersection.normal = nearestIntersection.normal.applyTransformation(invRefTransfo_W);
                }
            }
            return nearestIntersection;
        }
    };



    // IBS NEW DEBUG PRIMITIVES
    /**
	 * Create a box primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of these parameters :
	 * @param   {double} size : the length of the box edges (all edges of the same size or vector of independant x,y,z sizes) 
	 * @param   {DSMath.Vector3D} size 
	 * @param   {boolean} centered : position is at the center of the box (vs at corner)
	 * @param   {boolean} screenSize : size is defined in screen mm, it is zoom independant
	 * @param   {STU.Box} box : position from two opposite corners expressed in given referential
	 * @param   {double} lineWidth : width of drawn edges
	 * @param   {boolean} closed : draws box faces (vs edges)
	 * @param   {DSMath.Transformation} position : position of box in given referential
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
	 *
     *
     * these parameters do not affect position : [lineWidth], [closed], [color], [alpha], [lifetime]
     * VALID SUBSET OF PARAMETERS FOR POSITION :
     * size, [centered] : a box of which the center/corner is at the origin of the default referential
     * size, position, [referential] : same as above but placed at position expressed in referential
     * box : a box with two corners reaching box.low.x/y/z and box.high.x/y/z in the default referential
     * box, referential : same as above but positions expressed in referential
     * 
	 * DEFAULT VALUES :
	 * size : 1000
	 * centered : false
	 * screenSize : 0
	 * box : [no default value]
	 * lineWidth : 0.01*(SizeX * SizeY * SizeZ)^(1/3)
	 * closed : false
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */

    RenderManager.prototype._createBox = function (iParams) {

        var refVisuTransform = new DSMath.Transformation();

        if (iParams.referential !== undefined && iParams.referential !== null) {
            var iRef = iParams.referential;
            if (iRef === undefined || iRef === null || iRef === "Location") {

                var ActiveLocation = this.environmentsServices.getActiveLocation();

                if (ActiveLocation !== undefined && ActiveLocation !== null) {
                    refVisuTransform = ActiveLocation.getTransform("Visu");
                } else { // on demande la position scene mais on ne trouve pas de scene => scene=world
                    iRef = "World";
                }
            }

            // position world = position par rapport au root de l'experience
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "World") {
                var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
                refVisuTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            // position visu = position par rapport au root de la visu
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "Visu") {
                refVisuTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            if (iRef instanceof STU.Actor3D) {
                refVisuTransform = iRef.getTransform("Visu");
            }
        }// if (iParams.referential

        // mode box
        // on fait passer box par la transform iParams.referential
        if (iParams.box !== undefined && iParams.box !== null) {
            var MyLowPoint = new DSMath.Point(iParams.box.low.x, iParams.box.low.y, iParams.box.low.z);
            MyLowPoint.applyTransformation(refVisuTransform);

            var MyHighPoint = new DSMath.Point(iParams.box.high.x, iParams.box.high.y, iParams.box.high.z);
            MyHighPoint.applyTransformation(refVisuTransform);

            iParams.box.low.x = MyLowPoint.x; iParams.box.low.y = MyLowPoint.y; iParams.box.low.z = MyLowPoint.z;
            iParams.box.high.x = MyHighPoint.x; iParams.box.high.y = MyHighPoint.y; iParams.box.high.z = MyHighPoint.z;

            var id = this.StuGeomPrimitive_ISOManager.createBox(iParams); // jshint ignore:line
            var obj = this.registerObject(id, iParams);
        }
            // mode size
        else {
            var id = this.StuGeomPrimitive_ISOManager.createBox(iParams); // jshint ignore:line
            var obj = this.registerObject(id, iParams);

            if (iParams !== undefined && iParams !== null) {
                if (iParams.position !== undefined && iParams.position !== null) {
                    if (iParams.referential !== undefined && iParams.referential !== null) {
                        this.setObjectPosition(id, iParams.position, iParams.referential);
                    }
                    else {
                        this.setObjectPosition(id, iParams.position);
                    }
                }
                else {
                    iParams.position = new DSMath.Transformation();
                    if (iParams.referential !== undefined && iParams.referential !== null) {
                        this.setObjectPosition(id, iParams.position, iParams.referential);
                    }
                    else {
                        this.setObjectPosition(id, iParams.position);
                    }
                }
            }
        }
        return obj;
    };
    /**
	 * Create a sphere primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of  these parameters :
	 * @param   {double} radius : the radius of the sphere
	 * @param   {boolean} screenSize : size is defined in screen mm, it is zoom independant
	 * @param   {DSMath.Transformation} position : position of sphere in world referential
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
	 *
	 * DEFAULT VALUES :
	 * radius : 1000.
	 * screenSize : 0
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */
    RenderManager.prototype._createSphere = function (iParams) {
        var id = this.StuGeomPrimitive_ISOManager.createSphere(iParams); // jshint ignore:line
        var obj = this.registerObject(id, iParams);

        if (iParams !== undefined && iParams !== null) {
            if (iParams.position !== undefined && iParams.position !== null) {
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
            else {
                iParams.position = new DSMath.Transformation();
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
        }
        return obj;
    };
    /**
	 * Create a point primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of  these parameters :
	 * @param   {double} size : the size of the point in screen-mm (zoom independant)
	 * @param   {DSMath.Transformation} position : position of point in world referential
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
	 * DEFAULT VALUES :
	 * size : 1. (screen size)
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */
    RenderManager.prototype._createPoint = function (iParams) {
        var id = this.StuGeomPrimitive_ISOManager.createPoint(iParams); // jshint ignore:line
        var obj = this.registerObject(id, iParams);

        if (iParams !== undefined && iParams !== null) {
            if (iParams.position !== undefined && iParams.position !== null) {
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
            else {
                iParams.position = new DSMath.Transformation();
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
        }
        return obj;
    };
    /**
	 * Create a vector primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of  these parameters :
	 * @param   {DSMath.Vector3D} startPoint : the not-pointy extremity of the vector
	 * @param   {DSMath.Vector3D} endPoint : the pointy extremity of the vector
	 * @param   {DSMath.Vector3D} direction : the direction of the vector
	 * @param   {double} length : length of the vector
	 * @param   {double} width : width of the vector shaft
	 * @param   {double} headLength : length of the pointy part of the vector
	 * @param   {double} headWidth : width of the pointy part of the vector
	 * @param   {boolean} screenSize : size is defined in screen mm, it is zoom independant
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
     *
     *
     * these parameters do not affect position : [width], [headLength], [headWidth], [closed], [color], [alpha], [lifetime]
     * VALID SUBSET OF PARAMETERS FOR POSITION :
     * startPoint, endPoint : a vector going from startpoint to endpoint expressed in default referential
     * startPoint, direction, length : a vector going from startpoint to startPoint + direction*length, expressed in default referential
     * startPoint, endPoint, [referential] : a vector going from startpoint to endpoint expressed in referential
     * startPoint, direction, length, [referential] : a vector going from startpoint to startPoint + direction*length, expressed in referential 
     *
	 * DEFAULT VALUES :
	 * length : 1000.
	 * screenSize : 0
	 * startPoint : {x:0 , y:0 , z:0}
	 * endPoint : {x:0 , y:0 , z:1000}
	 * direction : {x:0 , y:0 , z:1}     
	 * width : length/100
	 * headLength : length/10
	 * headWidth : length/50
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */
    RenderManager.prototype._createVector = function (iParams) {

        // on fait passer startpoint, endpoint, direction, length, width, headLength, headWidth par la transform iParams.referential
        if (iParams.referential !== undefined && iParams.referential !== null) {
            var iRef = iParams.referential;
            var refVisuTransform = new DSMath.Transformation();

            if (iRef === undefined || iRef === null || iRef === "Location") {

                var ActiveLocation = this.environmentsServices.getActiveLocation();

                if (ActiveLocation !== undefined && ActiveLocation !== null) {
                    refVisuTransform = ActiveLocation.getTransform("Visu");
                } else { // on demande la position scene mais on ne trouve pas de scene => scene=world
                    iRef = "World";
                }
            }

            // position world = position par rapport au root de l'experience
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "World") {
                var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
                refVisuTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            // position visu = position par rapport au root de la visu
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "Visu") {
                refVisuTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            if (iRef instanceof STU.Actor3D) {
                refVisuTransform = iRef.getTransform("Visu");
            }

            // on fait passer startpoint, endpoint, direction, length, width par la transform iParams.referential
            if (iParams.startPoint !== undefined && iParams.startPoint !== null) {
                var MyStartPoint = new DSMath.Point(iParams.startPoint.x, iParams.startPoint.y, iParams.startPoint.z);
                MyStartPoint.applyTransformation(refVisuTransform);
                iParams.startPoint.x = MyStartPoint.x;
                iParams.startPoint.y = MyStartPoint.y;
                iParams.startPoint.z = MyStartPoint.z;
            }

            if (iParams.endPoint !== undefined && iParams.endPoint !== null) {
                var MyEndPoint = new DSMath.Point(iParams.endPoint.x, iParams.endPoint.y, iParams.endPoint.z);
                MyEndPoint.applyTransformation(refVisuTransform);
                iParams.endPoint.x = MyEndPoint.x;
                iParams.endPoint.y = MyEndPoint.y;
                iParams.endPoint.z = MyEndPoint.z;
            }
            if (iParams.direction !== undefined && iParams.direction !== null) {
                iParams.direction.applyTransformation(refVisuTransform);
            }
            if (iParams.length !== undefined && iParams.length !== null) {
                iParams.length = iParams.length * refVisuTransform.getScaling().scale;
            }
            if (iParams.width !== undefined && iParams.width !== null) {
                iParams.width = iParams.width * refVisuTransform.getScaling().scale;
            }
            if (iParams.headLength !== undefined && iParams.headLength !== null) {
                iParams.headLength = iParams.headLength * refVisuTransform.getScaling().scale;
            }
            if (iParams.headWidth !== undefined && iParams.headWidth !== null) {
                iParams.headWidth = iParams.headWidth * refVisuTransform.getScaling().scale;
            }
        }// if (iParams.referential 

        var id = this.StuGeomPrimitive_ISOManager.createVector(iParams); // jshint ignore:line
        var obj = this.registerObject(id, iParams);
        return obj;
    };
    /**
	 * Create a line primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of  these parameters :
	 * @param   {DSMath.Vector3D} startPoint : the not-pointy extremity of the line
	 * @param   {DSMath.Vector3D} endPoint : the pointy extremity of the line
	 * @param   {DSMath.Vector3D} direction : the direction of the line
	 * @param   {double} length : length of the line
	 * @param   {double} width : width of the line
	 * @param   {boolean} screenSize : size is defined in screen mm, it is zoom independant
	 * @param   {DSMath.Transformation} position : position of box in world referential
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
     *
     * these parameters do not affect position : [width], [closed], [color], [alpha], [lifetime]
     * VALID SUBSET OF PARAMETERS FOR POSITION :
     * startPoint, endPoint : a vector going from startpoint to endpoint expressed in default referential
     * startPoint, direction, length : a vector going from startpoint to startPoint + direction*length, expressed in default referential
     * startPoint, endPoint, [referential] : a vector going from startpoint to endpoint expressed in referential
     * startPoint, direction, length, [referential] : a vector going from startpoint to startPoint + direction*length, expressed in referential 
     *
	 * DEFAULT VALUES :
	 * length : 1000.
	 * screenSize : 0
	 * startPoint : {x:0 , y:0 , z:0}
	 * endPoint : {x:0 , y:0 , z:1000}
	 * direction : {x:0 , y:0 , z:1}     
	 * width : length/100
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */
    RenderManager.prototype._createLine = function (iParams) {

        // on fait passer startpoint, endpoint, direction, length, width, par la transform iParams.referential
        if (iParams.referential !== undefined && iParams.referential !== null) {
            var iRef = iParams.referential;
            var refVisuTransform = new DSMath.Transformation();

            if (iRef === undefined || iRef === null || iRef === "Location") {

                var ActiveLocation = this.environmentsServices.getActiveLocation();

                if (ActiveLocation !== undefined && ActiveLocation !== null) {
                    refVisuTransform = ActiveLocation.getTransform("Visu");
                } else { // on demande la position scene mais on ne trouve pas de scene => scene=world
                    iRef = "World";
                }
            }

            // position world = position par rapport au root de l'experience
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "World") {
                var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
                refVisuTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            // position visu = position par rapport au root de la visu
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "Visu") {
                refVisuTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            if (iRef instanceof STU.Actor3D) {
                refVisuTransform = iRef.getTransform("Visu");
            }

            // on fait passer startpoint, endpoint, direction, length, width par la transform iParams.referential
            if (iParams.startPoint !== undefined && iParams.startPoint !== null) {
                var MyStartPoint = new DSMath.Point(iParams.startPoint.x, iParams.startPoint.y, iParams.startPoint.z);
                MyStartPoint.applyTransformation(refVisuTransform);
                iParams.startPoint.x = MyStartPoint.x;
                iParams.startPoint.y = MyStartPoint.y;
                iParams.startPoint.z = MyStartPoint.z;
            }

            if (iParams.endPoint !== undefined && iParams.endPoint !== null) {
                var MyendPoint = new DSMath.Point(iParams.endPoint.x, iParams.endPoint.y, iParams.endPoint.z);
                MyendPoint.applyTransformation(refVisuTransform);
                iParams.endPoint.x = MyendPoint.x;
                iParams.endPoint.y = MyendPoint.y;
                iParams.endPoint.z = MyendPoint.z;
            }
            if (iParams.direction !== undefined && iParams.direction !== null) {
                iParams.direction.applyTransformation(refVisuTransform);
            }
            if (iParams.length !== undefined && iParams.length !== null) {
                iParams.length = iParams.length * refVisuTransform.getScaling().scale;
            }
            if (iParams.width !== undefined && iParams.width !== null) {
                iParams.width = iParams.width * refVisuTransform.getScaling().scale;
            }
        }// if (iParams.referential 

        var id = this.StuGeomPrimitive_ISOManager.createLine(iParams); // jshint ignore:line
        var obj = this.registerObject(id, iParams);

        return obj;
    };
    /**
	 * Create an axis primitive.
	 *
	 * @method
	 * @private
	 * @param   {iParams}	an object which can contain a subset of  these parameters :
	 * @param   {double} size : length of the axis vectors
	 * @param   {boolean} screenSize : size is defined in screen mm, it is zoom independant
	 * @param   {DSMath.Transformation} position : position of axis in referential
     * @param   {STU.Actor3D} referential Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
	 * @param   {STU.Color}	color RGBA color of the primitive
	 * @param   {double}	alpha transparency of the primitive (0: fully transparent, 1: opaque)
	 * @param   {double}	lifetime lifetime of the primitive in ms
	 *							if -1 the primitive will be visible till destroyed
	 *							if 0 the primitive is visible only 1 frame
	 *							if >0 the primitive will disappear progressively
	 * DEFAULT VALUES :
	 * size : 10. (screen size)
	 * screenSize : 1
	 * position : ID
     * referential : World / Current location
	 * color : {r:255 , g:50 , b:50 , a:255}
	 * alpha : 255
	 */
    RenderManager.prototype._createAxis = function (iParams) {
        var id = this.StuGeomPrimitive_ISOManager.createAxis(iParams); // jshint ignore:line
        var obj = this.registerObject(id, iParams);

        if (iParams !== undefined && iParams !== null) {
            if (iParams.position !== undefined && iParams.position !== null) {
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
            else {
                iParams.position = new DSMath.Transformation();
                if (iParams.referential !== undefined && iParams.referential !== null) {
                    this.setObjectPosition(id, iParams.position, iParams.referential);
                }
                else {
                    this.setObjectPosition(id, iParams.position);
                }
            }
        }
        return obj;
    };









    /**
	 * Create a primitive object.
	 * For internal purpose only
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.registerObject = function (iId, iParams) {

        var position;
        if (iParams.position === undefined || iParams.position === null) {
            position = new DSMath.Transformation();
        }
        else {
            position = iParams.position;
        }

        var color;
        var alpha;
        if (iParams.color === undefined || iParams.color === null) {
            color = new STU.Color(255, 0, 0);
        }
        else {
            color = iParams.color;
        }
        if (color.a === undefined || color.a === null) {
            alpha = 255;
        }
        else {
            alpha = color.a;
        }

        if (iParams.alpha === undefined || iParams.alpha === null) {
            //alpha = 255;
        }
        else {
            alpha = iParams.alpha;
        }

        var lifetime;
        if (iParams.lifetime === undefined || iParams.lifetime === null) {
            lifetime = -1;
        }
        else {
            lifetime = iParams.lifetime;
        }

        var obj = {};
        obj.id = iId;
        obj.color = color;
        obj.alpha = alpha;
        obj.transfo = position;
        obj.life = lifetime;
        obj.age = 0;

        this.map[iId] = obj;
        return obj;
    };

    /**
    * Move a primitive object.
    * For internal purpose only
    *
    * @method
         * @param   {STU.Actor3D} iRef Instance object corresponding to the referential where the input position should be expressed 
                If null or undefined, all coordinate are experessed :
                    in current location referential if a location is active
                    in in world referential otherwise
                If referential == "World" all coordinate are experessed in world referential
                If referential == "Visu" all coordinate are experessed in visu referential
    * @private
    */
    RenderManager.prototype.setObjectPosition = function (iId, iPos, iRef) {
        var ID = -1;
        if (iId.id !== undefined) {
            ID = iId.id;
        }
        else {
            ID = iId;
        }
        if (this.map.hasOwnProperty(ID)) {
            var obj = this.map[ID];
            //obj.transfo = iPos;
            //var array = iPos.getArray();

            var refVisuTransform = new DSMath.Transformation();
            if (iRef === undefined || iRef === null || iRef === "Location") {

                var ActiveLocation = this.environmentsServices.getActiveLocation();

                if (ActiveLocation !== undefined && ActiveLocation !== null) {
                    refVisuTransform = ActiveLocation.getTransform("Visu");
                } else { // on demande la position scene mais on ne trouve pas de scene => scene=world
                    iRef = "World";
                }
            }

            // position world = position par rapport au root de l'experience
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "World") {
                var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
                refVisuTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            // position visu = position par rapport au root de la visu
            // le root de l'experience peut etre scale par rapport au root de la visu (globe)
            if (iRef === "Visu") {
                refVisuTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
                iRef = null;
            }

            if (iRef instanceof STU.Actor3D) {
                refVisuTransform = iRef.getTransform("Visu");
            }

            var TotalVisuTransform = DSMath.Transformation.multiply(refVisuTransform, iPos);

            obj.transfo = TotalVisuTransform;

            var array = TotalVisuTransform.getArray();
            var m = 0;
            for (m = 0; m < 12; m++) {
                this.SharedTransfo[m] = array[m];
            }
            this.StuGeomPrimitive_ISOManager.SetPosFromSharedTransfo(ID);
        }
    };
    /**
    * Change a primitive object's color.
    * For internal purpose only
    *
    * @method
    * @private
    */
    RenderManager.prototype.setObjectColor = function (iId, iCol, iAlpha) {
        var ID = -1;
        if (iId.id !== undefined) {
            ID = iId.id;
        }
        else {
            ID = iId;
        }

        var alpha = 255;
        if (iCol.a === undefined || iCol.a === null) {
            if (iAlpha === undefined || iAlpha === null) {
                alpha = 255;
            }
            else {
                alpha = iAlpha;
            }
        }
        else {
            alpha = iCol.a;
        }

        if (this.map.hasOwnProperty(ID)) {
            var obj = this.map[ID];

            if (iCol !== undefined) {
                if (iCol.hasOwnProperty("r")) {
                    obj.color.r = iCol.r;
                }
                if (iCol.hasOwnProperty("g")) {
                    obj.color.g = iCol.g;
                }
                if (iCol.hasOwnProperty("b")) {
                    obj.color.b = iCol.b;
                }
                if (iCol.hasOwnProperty("a")) {
                    obj.color.a = iCol.a;
                }
            }
            obj.alpha = alpha;
            this.StuGeomPrimitive_ISOManager.setColor(ID, obj.color.r, obj.color.g, obj.color.b, alpha);
        }
    };

    /**
    * Delete a primitive object.
    * For internal purpose only
    *
    * @method
    * @private
    */
    RenderManager.prototype.deleteObject = function (iId) {
        if (this.map[iId] !== undefined) {
            this.StuGeomPrimitive_ISOManager.delete(Number(iId));
            delete this.map[iId];
        }
    };

    /**
	 * Create a transformation given a position and a direction.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.createTransfoFromPosAndDir = function (iPos, iDir) {
        var transform = new DSMath.Transformation();
        var matrix = new DSMath.Matrix3x3();

        var dir = iDir.clone();
        dir.normalize();


        if (this.approxEqual(dir.x, 0, 0.01) && this.approxEqual(dir.y, 0, 0.01) && (this.approxEqual(dir.z, 1, 0.01) || this.approxEqual(dir.z, -1, 0.01))) {

            matrix.setFromArray([dir.z, 0, 0,
				0, dir.z, 0,
				0, 0, dir.z
            ]);
        } else {
            var Z = new DSMath.Vector3D();
            Z.z = 1;

            // projecting the new sight direction on the ground to get a right direction parallel to the ground
            var right = DSMath.Vector3D.cross(dir, DSMath.Vector3D.cross(dir, Z));
            right.normalize();

            // computing the up direction as usual
            var up = DSMath.Vector3D.cross(dir, right);
            up.normalize();


            matrix.setFromArray([right.x, up.x, dir.x,
				right.y, up.y, dir.y,
				right.z, up.z, dir.z
            ]);
        }

        transform.matrix = matrix;
        transform.vector = iPos.clone();

        return transform;
    };

    RenderManager.prototype.approxEqual = function (iV1, iV2, iEpsilon) {
        if (iEpsilon === null) {
            iEpsilon = 0.001;
        }
        return Math.abs(iV1 - iV2) < iEpsilon;
    };

    /**
	 * Process to execute when this STU.RenderManager is starting.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onStart = function () {
        // Applies the camera parameters to the main viewpoint
        // Useful for the Raytrace behavior when a capture occurs during the first execute tick 
        this.onPostExecute();
    };

    /**
	 * Process to execute when this STU.RenderManager is resuming.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onResume = function () {
        /* jshint camelcase : false */
        var currentCamera = this.getCurrentCamera();
        if (currentCamera !== undefined && currentCamera !== null && this.main3DViewpoint.__stu__IsLocked() === 0) {
            this.main3DViewer.DeactivateDefaultNavigation();
        }
    };

    /**
	 * Process to execute when this STU.RenderManager is pausing.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onPause = function () {
        this.main3DViewer.ActivateDefaultNavigation();
    };

    /**
	 * Process to execute when this STU.RenderManager is stopping.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onStop = function () {
        this.main3DViewer.ActivateDefaultNavigation();

        this.StuGeomPrimitive_ISOManager.deleteAll(); // jshint ignore:line

        if (this.authoringEnvironment !== null && this.authoringEnvironment !== undefined) {
            if (this.environmentsServices !== null && this.environmentsServices !== undefined) {
                if (this.authoringEnvironment === 0 || this.authoringEnvironment === undefined) {
                    this.activeEnvNumber = this.environmentsServices.deActivateEnvironment();
                }
                else {
                    this.activeEnvNumber = this.environmentsServices.setActiveEnvironmentByNumber(this.authoringEnvironment);
                }
                this.environmentInit = false;
            }
        }

    };

    /**
	 * Update this STU.RenderManager :
	 * Update the viewpoint from the current STU.Camera.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.onPostExecute = function () {
        /* jshint camelcase : false */
        var currentActorCamera;
        // var up;
        // var position;
        // var forward;

        // Retrieving the current camera		
        //currentActorCamera = this.getCurrentCamera();

        // Update main viewpoint from currently active camera.
        //
        // Note: it is valid to have no active camera, for example when the scene contains no camera.
        // In that case, there is no update of current viewpoint, and if the current session is happening
        // in an authoring window, the user keeps the ability to manipulate the viewer with the common
        // authoring view manipulation.    
        /*if (currentActorCamera !== undefined && currentActorCamera !== null &&
			this.main3DViewpoint !== undefined && this.main3DViewpoint !== null) {

            // update the viewpoint only if this one is not locked by the authoring
            if (this.main3DViewpoint.__stu__IsLocked() === 0) {                              
                var upWorld = currentActorCamera.getUp("Visu"); // in world ref
                var fwWorld = currentActorCamera.getForward("Visu"); // in world ref
                var posWorld = currentActorCamera.getPosition("Visu"); // in visu ref
                
                // TJR: rollbacked the viewpoint update because when the parent (if any) of the camera is moved
                // then the camera is not notified through event models, and the viewpoint is never updated
                // we will have to find a solution, either:
                //  - create a win task for camera update in case of play
                //  - get some event when a parent is moved (could be expensive)
                //  - leave it in current state...
                //this.main3DViewpoint.__stu__SetViewpoint(posWorld, fwWorld, upWorld);

                // those parameters are now updated upon model event
                
                // Set Camera angle
                this.main3DViewpoint.__stu__SetAngle(currentActorCamera.viewAngle);

                //Set near clip and far clip values
                this.main3DViewpoint.__stu__SetClippingValue(currentActorCamera.nearClip * this.experienceScaleFactor, currentActorCamera.farClip * this.experienceScaleFactor);

                //Apply current camera projection type to the main viewpoint
                this.main3DViewpoint.__stu__SetProjectionType(currentActorCamera.projectionType);
                if (currentActorCamera.projectionType === 1) {
                    this.main3DViewpoint.__stu__SetZoom(currentActorCamera.zoom);
                }
                if (currentActorCamera._focusDistance >= 0) {
                    this.main3DViewpoint.__stu__SetFocusDistance(currentActorCamera._focusDistance * this.experienceScaleFactor);
                }
            }
        }*/


    }; // update.

    /**
	 * Update debug primitives.
	 * Change the alpha of debug primitives that have a limited
	 * lifetime, and destroy them when their lifetime is reached.
	 *
	 * @method
	 * @private
	 */
    RenderManager.prototype.updateDebugPrimitives = function (iContext) {
        /* jshint camelcase : false */
        /* jshint -W089 */
        // updating debug primitives
        for (var p in this.map) {
            var obj = this.map[p];
            if (obj.life >= 0.0) {
                obj.age += iContext.deltaTime;
                if (obj.age > obj.life) {
                    this.StuGeomPrimitive_ISOManager.delete(Number(p));
                    delete this.map[p];
                } else {
                    var t = obj.age / obj.life;
                    var _alpha = (1 - t) * obj.alpha;

                    // NO
                    //this.setObjectColor(obj.id, obj.color, _alpha);
                    this.StuGeomPrimitive_ISOManager.setColor(obj.id, obj.color.r, obj.color.g, obj.color.b, _alpha);
                }
            }
        }
    };



    ////////////////////////////////
    ////// IBS JS APIs for ENVIRONMENTS

    RenderManager.prototype.getExperienceScaleFactor = function () {
        return this.experienceScaleFactor;
    };
    RenderManager.prototype.setExperienceScaleFactor = function (iFactor) {
        console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        console.log("setExperienceScaleFactor");
        console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        this.experienceScaleFactor = iFactor;
    };

    /**
    * @method
    * @private
    */
    RenderManager.prototype.getEnvsManager = function () {
        return this.environmentsServices;
    };

    /**
    * Get the active environment's name
    * @deprecated R2018x - see STU.Environment.isCurrent
    * @method
    * @public
    * @return {string} environment name, empty string if no active environment is found
    */
    RenderManager.prototype.getActiveEnvironmentName = function () {
        return this.environmentsServices.getActiveEnvironmentName();
    };

    /**
    * Get the active environment's position in this experience's resources
    * <br/> Private  : because environment number is not coherent with project view (alphabetical ordering)
    * 
    * @method
    * @private
    * @return {number} environment's position in this experience's resources, 0 if no active environment is found
    */
    //RenderManager.prototype.getActiveEnvironmentNumber = function () {
    //    return this.environmentsServices.getActiveEnvironmentNumber();
    //};

    /**
    * get the active environment
    *  
    * @deprecated R2018x - see STU.Environment.isCurrent
    * @method
    * @public
    * @return {STU.Environment} environment, null if no active environment is found
    */
    RenderManager.prototype.getActiveEnvironment = function () {
        var ActiveEnvNumber = this.activeEnvNumber;//this.environmentsServices.getActiveEnvironmentNumber();
        var CurrentExperience = STU.Experience.getCurrent();
        var ExpEnvs = CurrentExperience.environments;
        if (ExpEnvs !== undefined && ExpEnvs !== null && ActiveEnvNumber !== undefined && ActiveEnvNumber !== null && ActiveEnvNumber >= 1 && ActiveEnvNumber <= ExpEnvs.length) {
            return ExpEnvs[ActiveEnvNumber - 1];
        }
        else {
            return null;
        }
    };

    /**
        * get all environments
        *  
        * @deprecated R2018x - see STU.Experience.getEnvironments
        * @method
        * @public
        * @return {Array.<STU.Environment>} environments
        */
    RenderManager.prototype.getEnvironments = function () {
        var CurrentExperience = STU.Experience.getCurrent();
        var ExpEnvs = CurrentExperience.environments;
        return ExpEnvs;
    }

    /**
        * get an environment identified by its name
        *  
        * @deprecated R2018x - see STU.Experience.getEnvironmentByName
        * @method
        * @public
        * @param {string} the name of the environment from the current experience to find
        * @return {STU.Environment} environment, null if no environment is found with given name
        */
    RenderManager.prototype.getEnvironmentByName = function (iName) {
        var CurrentExperience = STU.Experience.getCurrent();
        var ExpEnvs = CurrentExperience.environments;
        if (ExpEnvs !== undefined && ExpEnvs !== null && ExpEnvs.length > 0) {
            var NbEnvs = ExpEnvs.length;

            for (var i = 0; i < NbEnvs; i++) {
                var Env = ExpEnvs[i];
                if (Env._varName === iName) {
                    return Env;
                }
            }
        }
        return null;
    };

    /**
    * get an environment identified by its position in the experience's environments
    * <br/> private : because environment number is not coherent with project view (alphabetical ordering) 
    * @method
    * @private
    * @param {number} the position of the environment in the current experience
    * @return {STU.Environment} environment, null if no environment is found at the given position
    */
    //RenderManager.prototype.getEnvironmentByNumber = function (iNumber) {
    //    var CurrentExperience = STU.Experience.getCurrent();
    //    var ExpEnvs = CurrentExperience.environments;
    //    if (ExpEnvs !== undefined && ExpEnvs !== null && iNumber >= 1 && iNumber <= ExpEnvs.length) {
    //        return ExpEnvs[iNumber - 1];
    //    }
    //    else {
    //        return null;
    //    }
    //};


    /**
        * deactivate the current active environment
        *  
        * @deprecated R2018x - see STU.Environment.setAsCurrent
        * @method
        * @public
        */
    RenderManager.prototype.deActivateEnvironment = function () {
        this.activeEnvNumber = this.environmentsServices.deActivateEnvironment();
    };

    /**
    * Activates an environment, identified by its name, to the experience
    *
    * @deprecated R2018x - see STU.Environment.setAsCurrent
    * @method
    * @public
    * @param {string} iName the name of the environment from the current experience to activate
    */
    RenderManager.prototype.setActiveEnvironmentByName = function (iName) {
        this.activeEnvNumber = this.environmentsServices.setActiveEnvironmentByName(iName);
    };

    /**
    * Activates an environment, identified by its position in the experience's resources
    * <br/> private : because environment number is not coherent with project view (alphabetical ordering)
    * @method
    * @private
    * @param {number} iPosition the position of the environment to activate (in the experience's resources)
    */
    //RenderManager.prototype.setActiveEnvironmentByNumber = function (iPosition) {
    //    this.activeEnvNumber = this.environmentsServices.setActiveEnvironmentByNumber(iPosition);
    //};


    /**
        * set the active environment
        *  
        * @deprecated R2018x - see STU.Environment.setAsCurrent
        * @method
        * @public
        * @param {STU.Environment} iNewActiveEnv the environment from the current experience to activate
        */
    RenderManager.prototype.setActiveEnvironment = function (iNewActiveEnv) {
        //var EnvName = iNewActiveEnv._varName;
        //this.environmentsServices.setActiveEnvironmentByName(EnvName); // bof
        var CurrentExperience = STU.Experience.getCurrent();
        var ExpEnvs = CurrentExperience.environments;
        if (ExpEnvs !== undefined && ExpEnvs !== null && ExpEnvs.length > 0) {
            var NbEnvs = ExpEnvs.length;

            for (var i = 0; i < NbEnvs; i++) {
                var Env = ExpEnvs[i];
                if (Env === iNewActiveEnv) {
                    this.activeEnvNumber = this.environmentsServices.setActiveEnvironmentByNumber(i + 1);
                }
            }
        }
    };

    //RenderManager.prototype.getActiveLocation = function () {
    //    return this.environmentsServices.getActiveLocation();
    //};

    //RenderManager.prototype.activateLocation = function (iActiveLoc){
    //    return this.environmentsServices.activateLocation(iActiveLoc);
    //};


    ////// ~IBS JS APIs for ENVIRONMENTS
    ////////////////////////////////



    STU.registerManager(RenderManager);

    // Expose in STU namespace.
    STU.RenderManager = RenderManager;

    return RenderManager;
});

define('StuRenderEngine/StuRenderManager', ['DS/StuRenderEngine/StuRenderManager'], function (RenderManager) {
    'use strict';

    return RenderManager;
});
