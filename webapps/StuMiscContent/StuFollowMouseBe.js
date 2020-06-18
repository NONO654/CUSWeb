/*
 * * @quickReview IBS 17:04:21 RenderManager fonctionne en rep�re world
 *						+ clickablestate sur les sous acteurs de l'objet manipul� (cas des roues primitives)
 *						+ gestion scaling globe
 */

define('DS/StuMiscContent/StuFollowMouseBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'MathematicsES/MathsDef',
		'DS/EPInputs/EPMousePressEvent', 'DS/EPInputs/EPMouseMoveEvent', 'DS/EPInputs/EPMouseClickEvent', 'DS/EPInputs/EPMouseReleaseEvent', 'DS/StuCameras/StuInputManager'
	],
	function(STU, Behavior, Task, EP, DSMath) {

		'use strict';

		var FollowMouseTask = function(iComp) {
			Task.call(this);
			this.comp = iComp;
		};
		FollowMouseTask.prototype = new Task();
		FollowMouseTask.prototype.constructor = FollowMouseTask;
		FollowMouseTask.prototype.onExecute = function(iExContext) {
			if (this.comp === undefined || this.comp === null) {
				return;
			}

			this.comp._deltaTime = iExContext.getDeltaTime() / 1000;

			//this.comp.update();

		};

		/**
		 * Behavior that permit to make an actor follow the user mouse cursor
		 *
		 * @exports FollowMouse
		 * @class 
		 * @constructor
		 * @noinstancector
		 * @public
		 * @extends {STU.Behavior}
		 * @memberOf STU
		 * @alias STU.FollowMouse
		 */
		var FollowMouse = function() {
			Behavior.call(this);
			this.name = "FollowMouse";

			/**
			 * Orientate the 3D actors according to the normal of the surface
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.alignToSurfaceNormal = true;

			/**
			 * If true the pick will work only on the other 3DActor present in the scene. If false, the picking will work also on the virtual environnement.
			 *
			 * @member
			 * @public
			 * @type {Boolean}
			 */
			this.projectOnlyOn3D = true;

			/**
			 * Define the condition of activation for the behavior
			 *
			 * @member
			 * @public
			 * @type {STU.FollowMouse.eActivationModes}
			 */
			this.activateOn = 0;

			/**
			 * Define the event of on which the actor will follow the mouse cursor 
			 *
			 * @member
			 * @public
			 * @type {STU.FollowMouse.eEventMode}
			 */
			this.mode = 0;

			//////////////////////////////////////////////////////////////////////////
			// Properties that should NOT be visible in UI
			//////////////////////////////////////////////////////////////////////////
			//this._deltaTime = 1;       

			this._inputManager = null;

			this._zLocation = new DSMath.Vector3D(0, 0, 1);
			this._xLocation = new DSMath.Vector3D(1, 0, 0);
			this._scaleLocation = 1;

			this._direction = null;
			this._activated = true;
			this._mousePressed = false;

		}; // FollowMouse.

		/**
		 * Enumeration of all activation modes.<br/>
		 *
		 * @enum {number}
		 * @public
		 *
		 */
		FollowMouse.eActivationModes = {
			eOnStart: 0,
			eNoActivation: 1
		};

		/**
		 * Enumeration of all activation modes.<br/>
		 *
		 * @enum {number}
		 * @public
		 *
		 */
		FollowMouse.eEventMode = {
			eMouseMove: 0,
			eMouseClick: 1
		};

		//==============================================================================
		FollowMouse.prototype = new Behavior();
		FollowMouse.prototype.constructor = FollowMouse;

		//==============================================================================
		/** 
		 * @private
		 */
		FollowMouse.prototype.onActivate = function() {
			STU.Behavior.prototype.onActivate.call(this);
			this.myTask = new FollowMouseTask(this);
			EP.TaskPlayer.addTask(this.myTask);

			if (this.mode === FollowMouse.eEventMode.eMouseClick) {
				EP.EventServices.addObjectListener(EP.MousePressEvent, this, 'onMousePressEvent');
				EP.EventServices.addObjectListener(EP.MouseReleaseEvent, this, 'onMouseReleaseEvent');
			}

			// Add Listener to get notified
			EP.EventServices.addObjectListener(EP.MouseMoveEvent, this, 'onMouseMoveEvent');
			// Add Listener to get notified
			EP.EventServices.addObjectListener(EP.MouseClickEvent, this, 'onMouseClickEvent');


			if (this.activateOn === FollowMouse.eActivationModes.eNoActivation) {
				this._activated = false;
			} else {
				this._activated = true;
			}

			this._inputManager = new STU.InputManager();
			if (this._inputManager === undefined || this._inputManager === null) {
				return this;
			}
			this._inputManager.initialize();
			this._inputManager.activate();
			this._inputManager.useMouse = true;

			var myActor = this.getActor();
			if (!(myActor instanceof STU.Actor3D)) {
				return;
			}

			this._scaleLocation = myActor.getScale();
			var myLocation = myActor.getLocation();
			if (myLocation !== null && myLocation !== undefined) {

				var myLocationTransform = myLocation.getTransform("World");
				this._xLocation.applyTransformation(myLocationTransform);
				this._zLocation.applyTransformation(myLocationTransform);
				this._xLocation.normalize();
				this._zLocation.normalize();
				this._scaleLocation *= myLocation.getScale("World");
				// myLocationTransform est la transfo telle que :
				// Pt_DéfiniDansRepereMyLocation.applyTransformation(myLocationTransform) == Pt_DéfiniDansRepereWorld
			}
		};
		//==============================================================================
		//==============================================================================
		/**
		 * @private
		 */
		FollowMouse.prototype.onDeactivate = function() {
			if (this._inputManager !== undefined && this._inputManager !== null) {

				this._inputManager.deactivate();
				this._inputManager.dispose();
				this._inputManager = null;
			}

			if (this.mode === FollowMouse.eEventMode.eMouseClick) {
				EP.EventServices.removeObjectListener(EP.MousePressEvent, this, 'onMousePressEvent');
				EP.EventServices.removeObjectListener(EP.MouseReleaseEvent, this, 'onMouseReleaseEvent');
			}

			// Remove Listener when you don't need it anymore
			EP.EventServices.removeObjectListener(EP.MouseMoveEvent, this, 'onMouseMoveEvent');
			// Remove Listener when you don't need it anymore
			EP.EventServices.removeObjectListener(EP.MouseClickEvent, this, 'onMouseClickEvent');

			EP.TaskPlayer.removeTask(this.myTask);
			STU.Behavior.prototype.onDeactivate.call(this);
		};
		//==============================================================================
		//==============================================================================

		/**
		 * This function will occurs when the user click a mouse button
		 * @private
		 */
		FollowMouse.prototype.onMouseClickEvent = function(iMouseClickEvent) {
			if (this._activated === false) {
				return;
			}
			if (this.mode !== FollowMouse.eEventMode.eMouseClick) {
				return;
			}

			this.computeActorPosition(iMouseClickEvent);
		}; //Mouse Click Event Handler
		//==============================================================================
		//==============================================================================

		/**
		 * This function will occurs when the user move its mouse
		 * @private
		 */
		FollowMouse.prototype.onMouseMoveEvent = function(iMouseMoveEvent) {
			if (this._activated === false) {
				return;
			}
			if (this.mode === FollowMouse.eEventMode.eMouseClick && this._mousePressed === false) {
				return;
			}

			this.computeActorPosition(iMouseMoveEvent);
		}; //Mouse Move Event Handler
		//==============================================================================
		//==============================================================================

		/**
		 * This function set the position of the actor according to the raycast effectued from the mouse
		 * @private
		 */
		FollowMouse.prototype.computeActorPosition = function(iMouseMoveEvent) {
			var mouseProjection = this.getMouseProjection(iMouseMoveEvent.getMouse().getPosition());

			var myActor = this.getActor();
			if (!(myActor instanceof STU.Actor3D)) {
				return;
			}

			myActor.setTransform(mouseProjection, "World");
		}; //Compute Actor Position
		//==============================================================================
		//==============================================================================

		/**
		 * Return the computed transform of the actor according to the raycast
		 * @public 
		 */
		FollowMouse.prototype.getMouseProjection = function(iMousePosition) {
			var viewerSize = STU.RenderManager.getInstance().getViewerSize();
			var axis = this._inputManager.axis1;
			var x = (-axis.x + 1) / 2 * viewerSize.x;
			var y = (-axis.y - 1) / -2 * viewerSize.y;

			var _renderMngr = STU.RenderManager.getInstance();
			var point = new DSMath.Vector2D(x, y);

			var line = _renderMngr.getLineFromPosition(point);

			this._direction = line.direction;
			var vectOrigin = new DSMath.Vector3D();

			var myActor = this.getActor();
			if (!(myActor instanceof STU.Actor3D)) {
				return;
			}

			// IBS : il faudrait changer le clickable state des sous acteurs de myActor
			var clickableState = myActor.clickable;
			myActor.clickable = false;
			var intersectArray = _renderMngr._pickFromLine(line, true, true);
			myActor.clickable = clickableState;


			var transform = this.actor.getTransform("World").clone();
			if (intersectArray.length > 0) {
				var intersectionIndice = 0;
				var foundIntersection = false;
				while (intersectionIndice < intersectArray.length && !foundIntersection) {
					var intersectedActor = intersectArray[intersectionIndice].getActor();

					if (intersectedActor !== null && intersectedActor !== undefined) {

						var intersectedActorIsMyActor = (myActor === intersectedActor);
						var intersectedActorParent = intersectedActor.getParent();
						while (intersectedActorParent !== null && intersectedActorParent !== undefined && !intersectedActorIsMyActor) {
							intersectedActorIsMyActor = (myActor === intersectedActorParent);
							intersectedActorParent = intersectedActorParent.getParent();
						}

						if (!intersectedActorIsMyActor) {
							foundIntersection = true;
							break;
						}
					} else {
						foundIntersection = true;
						break;
					}
					intersectionIndice = intersectionIndice + 1;
				}
				if (foundIntersection) {
					transform = this.getIntersectionTransform(intersectionIndice, intersectArray);
				} else {
					//console.log("intersectedActorIsMyActor !!");
				}
			} else {
				if (this.projectOnlyOn3D === false) {
					transform = this.getVirtualIntersectionTransform(line, vectOrigin, myActor);
				}
			}

			return transform;
		}; //Get Mouse Projection
		//==============================================================================   
		//==============================================================================   

		/**
		 * @private
		 * @param {any} i 
		 * @param {any} iIntersectArray 
		 * @returns {DSMath.Transformation}
		 */
		FollowMouse.prototype.getIntersectionTransform = function(i, iIntersectArray) {

			var transform, matrix;
			transform = this.actor.getTransform("World").clone();
			transform.vector.set(iIntersectArray[i].point.x, iIntersectArray[i].point.y, iIntersectArray[i].point.z);

			var d2 = transform.vector.squareNorm();
			if (d2 >= 100000000000 * 100000000000) {
				//console.log("TOO FAR !");
				transform.vector = this.actor.getPosition("World");
			}

			//===================================
			var targetPos;
			var intersectActor = iIntersectArray[i].getActor();
			if (intersectActor instanceof STU.Actor3D) {
				targetPos = intersectActor.getPosition("World");
			} else if (intersectActor instanceof DSMath.Vector3D) {
				targetPos = intersectActor.clone();
			}
			//===================================
			var intersectNormal = new DSMath.Vector3D();
			intersectNormal.set(iIntersectArray[i].normal.x, iIntersectArray[i].normal.y, iIntersectArray[i].normal.z);
			intersectNormal.normalize();

			matrix = new DSMath.Matrix3x3();

			if (this.alignToSurfaceNormal) {
				var mouseRaydir = this._direction.clone();
				var pickedSurfaceNormalVec = intersectNormal.clone();

				mouseRaydir.normalize();
				pickedSurfaceNormalVec.normalize();

            // vérifions que mouseRaydir et pickedSurfaceNormalVec sont en sens opposé
				var colinearValue = mouseRaydir.dot(pickedSurfaceNormalVec);
				if (colinearValue > 0) {
					pickedSurfaceNormalVec.multiplyScalar(-1);
				}

				// on a :
            // "mouseRaydir" la direction du rayon au bout de la souris
            // "pickedSurfaceNormalVec" la direction de la normale à la surface pickée là où la souris intersecte un objet, dans le sens opposé au rayon oeil-curseur
       
            // horizontalVec un vecteur horizontal (_|_ à _zLocation) et perpendiculaire à la normale à la surface snappée sous la souris
            // c'est le vecteur horizontal tangeant à la surface snappée
            // si on rempli le monde d'eau jusqu'au niveau du point snappé, la courbe que fait le bord de l'eau passant par le point snappé
            // dessinne une courbe dont la tangeante au point snappé est horizontalVec
            var horizontalVec = DSMath.Vector3D.cross(this._xLocation, pickedSurfaceNormalVec);
            // si intersectNormal est quasiment // _zLocation, ça devient difficile de définir horizontalVec
            // dans ce cas on inverse les rôles de _zLocation et _xLocation
            if (horizontalVec.norm() < 0.001) {
                horizontalVec = DSMath.Vector3D.cross(this._zLocation, pickedSurfaceNormalVec);
            }
            horizontalVec.normalize();


            // upHillVec un vecteur perpendiculaire à intersectNormal (pickedSurfaceNormalVec) et à horizontalVec
            // upHillVec est la direction tangeante à la surface snappée au point snappé qui suit la plus forte pente 
            var upHillVec = DSMath.Vector3D.cross(horizontalVec, pickedSurfaceNormalVec);
            upHillVec.normalize();
            

            // upHillVec, horizontalVec, pickedSurfaceNormalVec est une base orthonormée directe
            // on oriente le x de l'objet selon upHillVec
            // le y selon horizontalVec
            // le z selon pickedSurfaceNormalVec
				matrix.setFromArray([upHillVec.x, horizontalVec.x, pickedSurfaceNormalVec.x,
					upHillVec.y, horizontalVec.y, pickedSurfaceNormalVec.y,
                                 upHillVec.z, horizontalVec.z, pickedSurfaceNormalVec.z]);

				matrix.multiplyScalar(this._scaleLocation);
				//===================================
				/*if (intersectNormal.z > 0.5) {
				    // projecting the new sight direction on the ground to get a right direction parallel to the ground
				    var dirOnGround = DSMath.Vector3D.cross(this._xLocation, DSMath.Vector3D.cross(dir, this._xLocation));
				    dirOnGround.normalize();

				    // computing the right direction using the ground-projected sight direction
				    var right = DSMath.Vector3D.cross(this._xLocation, dirOnGround);
				    right.normalize();

				    // computing the up direction as usual
				    var up = DSMath.Vector3D.cross(dir, right);
				    up.normalize();
				}
				    //===================================
				else {
				    // projecting the new sight direction on the ground to get a right direction parallel to the ground
				    var dirOnGround = DSMath.Vector3D.cross(this._zLocation, DSMath.Vector3D.cross(dir, this._zLocation));
				    dirOnGround.normalize();

				    // computing the right direction using the ground-projected sight direction
				    var right = DSMath.Vector3D.cross(this._zLocation, dirOnGround);
				    right.normalize();

				    // computing the up direction as usual
				    var up = DSMath.Vector3D.cross(dir, right);
				    up.normalize();
				}

				// updating the transform
				matrix.setFromArray([up.x, right.x, dir.x,
				                    up.y, right.y, dir.y,
				                    up.z, right.z, dir.z]);*/

				transform.matrix = matrix;
			}

			//Check transform's validity
			var coef = transform.getArray();
			for (var i = coef.length - 1; i >= 0; i--) {
				var e = coef[i];
				if (!isFinite(e) || isNaN(e)) {
					console.error('iTransform argument contains NaN or infinite elements');
					return;
				}
			}

			return transform;
		}; //Get Intersection Transform
		//==============================================================================
		//==============================================================================

		/**
		 * @private
		 * @param {any} iLine 
		 * @returns {DSMath.Transformation}
		 */
		FollowMouse.prototype.getVirtualIntersectionTransform = function(iLine) {
			var origin = iLine.origin;
			var direction = iLine.direction;
			direction.normalize();
			var xMouse = direction.clone();
			xMouse.z = 0;
			xMouse.normalize();
			var cosAlpha = xMouse.dot(direction);
			var alpha = Math.acos(cosAlpha);
			var d = origin.z;
			var mouseDistance = (d / Math.sin(alpha));

			direction.multiplyScalar(mouseDistance);

			// updating the transform
			var vector = new DSMath.Vector3D(origin.x, origin.y, origin.z);
			vector.add(direction);

			var d2 = vector.squareNorm();
			var scene = this.actor.getLocation();
			if (d2 >= 10000000 * 10000000 * 3 || (scene !== null && scene !== undefined)) {
				vector = this.actor.getPosition("World");
			}

			var transform = new DSMath.Transformation();
			var matrix = this.actor.getTransform("World").matrix;

			transform.matrix = matrix;
			transform.vector = vector;
			return transform;
		}; //Get Virtual Intersection Transform
		//==============================================================================
		//==============================================================================

		/**
		 * Start the displacement according to the mouse position
		 * @method
		 * @public
		 */
		FollowMouse.prototype.followsMouse = function() {
			this._activated = true;
		};

		/**
		 * Stop the object displacement 
		 * @method
		 * @public
		 */
		FollowMouse.prototype.stopsFollowingMouse = function() {
			this._activated = false;
			this.dispatchEvent(new STU.ServiceStoppedEvent("followsMouse", this));
		};

		/**
		 * Return true if the actor is currently following the mouse
		 * @method
		 * @public
		 * @return {Boolean}
		 */
		FollowMouse.prototype.isFollowingMouse = function() {
			return this._activated;
		};
		
		/**
		 * @private
		 * @param {any} iMousePressEvent 
		 */
		FollowMouse.prototype.onMousePressEvent = function(iMousePressEvent) {
			this._mousePressed = true;
		};

		/**
		 * @private
		 * @param {any} iMouseReleaseEvent 
		 */
		FollowMouse.prototype.onMouseReleaseEvent = function(iMouseReleaseEvent) {
			this._mousePressed = false;
		};

		// Expose in STU namespace.
		STU.FollowMouse = FollowMouse;

		return FollowMouse;
	});

define('StuMiscContent/StuFollowMouseBe', ['DS/StuMiscContent/StuFollowMouseBe'], function(FollowMouse) {
	'use strict';

	return FollowMouse;
});
