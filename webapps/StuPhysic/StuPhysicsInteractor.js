define('DS/StuPhysic/StuPhysicsInteractor', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask', 'DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'MathematicsES/MathsDef', 'DS/StuCameras/StuInputManager'],
	function (STU, Behavior, Task, EP, EventServices, DSMath) {
	'use strict';

	var PhysicsInteractorTask = function (iPhysicsInteractor) {
		Task.call(this);

		this.beh = iPhysicsInteractor;
	};


	PhysicsInteractorTask.prototype = new Task();
	PhysicsInteractorTask.prototype.constructor = PhysicsInteractorTask;

	PhysicsInteractorTask.prototype.onExecute = function (iExContext) {
		this.beh.onExecute();
	};

	 /**
     * Describe a behavior attached to interact with physicalized objects<br/>
     * 
     * To use it, you must have the following role: CHA - Marketing Content Animator
     *
     * @exports PhysicsInteractor
     * @class 
     * @constructor
     * @noinstancector
     * @public
	 * @extends {STU.Behavior}
     * @memberOf STU
     * @alias STU.PhysicsInteractor
     */
	var PhysicsInteractor = function () {

		var self = this;

		Behavior.call(this);

		this.name = "PhysicsInteractor"; 
		this.associatedTask;

		//////////////////////////////////////////////////////////////////////////
		// Properties that should NOT be visible in UI
		//////////////////////////////////////////////////////////////////////////
		// Init of the keyboard and the mouse manager 
		this._inputManager = null;
		this._planeMode = 0;
		this._MouseLeftPressed = false;
		this._MouseMiddlePressed = false;

		this._myActor = null;
		this._Target = null;

		// Store the actor that is manipulated
		this._actorPicked = null;
		this._PickOriginLocal = null;
		this._PickOriginWorld = null;
		this._PickOriginPlane = null;
		this._previousMotionType = 0;

		this._updatePickingPlan = false;

		// Used to apply a positive or a negative force
		this._push = false;

	    // IBS properties
		this._interactorType = 0;

		//////////////////////////////////////////////////////////////////////////
		// Properties that should be visible in UI
		//////////////////////////////////////////////////////////////////////////

	    /**
		* Interactor type
		*   0 = Grab
		*   1 = Drag
		*   2 = Push
		*   3 = Pull
		*
		* @type {number}
		* @public
		*/
	    // IBS properties
		Object.defineProperty(this, "interactorType", {
		    enumerable: true,
		    configurable: true,
		    get: function () {
		        return self._interactorType;
		    },
		    set: function (value) {
		        // simulate onMouseRelease
		        if (self._MouseLeftPressed) {

		            var SavePickedActor = self._actorPicked;

		            self._MouseLeftPressed = false;
		            self.onLeftClicRelease();
   
		            self._interactorType = value;

		            // simulate onMousePress
		            self._MouseLeftPressed = true;
		            self._actorPicked = SavePickedActor;

		            self.onLeftClicPress();
		        }
		        else {
		            self._interactorType = value;
		        }
		    }
		});



		/**
		 * Application Point: selector -> "Picking Point / Center of inertia"
		 *  0 = Picking point: use the picking point of the mouse as a reference to apply forces and motion (can introduce torque in the motion).
		 *  1 = Center of inertia: Apply forces or motion on the center of inertia.
		 *
		 * @public
		 * @type {number}
		 */
		this.applicationPoint = 0;

		/**
		 * Manipulation Plane
		 *  0 = Plane X/Y: plane used to pan an Actor3D on a planar horizontal surface.
		 *  1 = Camera/Z-UP: plane used to lift an Actor3D in the current camera view plan
		 *  2 = Automatic-Normal: automatically and dynamically select the best plane based on the normal of the picking point.
		 *  3 = Automatic-View : automatically and dynamically select the best plane based on camera view point.
		 *
		 * @public
		 * @type {number}
		 */
		this.manipulationPlane = 3;

		/**
		 * Show Interactor: Boolean.
		 * Show the Arrow during the interaction
		 *
		 * @public
		 * @type {boolean}
		 */
		this.showInteractor = true;

		/**
		 * Boolean. Apply a force propositional to the mass of the Rigid Object picked
		 * @public
		 * @type {boolean}
		 */
		this.massDependent = true;

		/**
		 * ForceFactor
		 * Modulate the forces applied on the Rigid Object by an arbitrary value
		 * @public
		 * @type {number}
		 */
		this.forceFactor = 100.0;


		/**
		 * Exectuted when the mouse is moving
		 * @private
		 */
		this.onMouseMove = function () {

			if (self.interactorType === 0) {
				self._push = false;
				self.onMouseMove_Grab();
				return;
			}

			if (self.interactorType === 1) {
				self._push = false;
				self.onMouseMove_Drag();
				return;
			}

			if (self.interactorType === 2) {
				self._push = true;
				self.onMouseMove_PushPull();
				return;
			}

			if (self.interactorType === 3) {
				self._push = false;
				self.onMouseMove_PushPull();
				return;
			}
		};

		/**
		 * Exectuted when a mouse button is pressed
		 * @private
		 * @param   {EP.MouseEvent}
		 */
		this.onMousePress = function (iMouseEvent) {

			// user manipulated the mouse

			if (iMouseEvent.button === EP.Mouse.EButton.eLeft && self._MouseMiddlePressed === false) {

				// Perform a picking raycast on the mouse position
				var PointPicked = self.pickPoint();

				if (PointPicked != null) {

					// Store the Actor picked by the user
				    self._actorPicked = PointPicked.getActor();


				    // vérifions que l'actor manipulé a bien un behavior physical et n'est pas déjà fixe / keyframé
				    if (self._actorPicked.RigidBody === undefined || self._actorPicked.RigidBody === null) {
				        self._actorPicked = null;
				        return;
				    }
				    // si le mode est 1 (fixed) ou 2 (keyframé), on ne veut pas manipuler les objets 
				    if (self._actorPicked.RigidBody.MotionType === 1 || self._actorPicked.RigidBody.MotionType === 2) {
				        self._actorPicked = null;
				        return;
				    }



					// compute the manipulation plane
					if (self.manipulationPlane === 0) {
						// X/Y plane
						self._planeMode = 0;
					} else if (self.manipulationPlane === 1) {
						// Camera-Zup plane
						self._planeMode = 1;
					} else if (self.manipulationPlane === 2) {

						// compute the plane to use according to the normal of the object picked

						// Compute the manipulation plane based on the picking normal
						var normalPicked = PointPicked.getNormal();

						// Normalize the result
						normalPicked.normalize();

						var Vector_Z = new DSMath.Vector3D(0,0,1);

						// compute the Angle of the Quaternion
						var cosAlpha = Vector_Z.dot(normalPicked);

						// chose the picking plan
						if (cosAlpha > 0.5 || cosAlpha < -0.5) {
							self._planeMode = 0;
						} else {
							self._planeMode = 1;
						}
					} else if (self.manipulationPlane === 3) {

						// compute the plane to use according to the orientation of the camera
						var cameraPlanes = self.getCameraViewPlan();
						var Vector_Z = new DSMath.Vector3D(0,0,1);

						// compute the Angle between The Z-Up and the cameraUp
						var cosAlpha = Vector_Z.dot(cameraPlanes.cameraUP);

						// chose the picking plan (non symmetrical choice : prefer the Up manipulator).
						if (cosAlpha > 0.7 || cosAlpha < -0.7) {
							self._planeMode = 1;
						} else {
							self._planeMode = 0;
						}
					}


					if (self.applicationPoint === 0) {
						// Store the picking point in world coordinate
						self._PickOriginWorld.set(PointPicked.point.x, PointPicked.point.y, PointPicked.point.z);

						// Now compute self picking point in the Actor local coordinate 
						// self result will be useful to recompute and update the position of our picking point when the actor is moving
						self._PickOriginLocal.set(self._PickOriginWorld.x, self._PickOriginWorld.y, self._PickOriginWorld.z);
						var transformMyActor = self._actorPicked.getTransform();
						var inverseTransform = transformMyActor.getInverse();
						self._PickOriginLocal = self._PickOriginLocal.clone().applyTransformation(inverseTransform);

					} else {
						// Get the centre of gravity of the RigidBody
						// Note : the centre of gravity is generally equal to the pivot point of most of canonic actors but different with Product
						var rigid = self._actorPicked.RigidBody.getRigidObject();
						var Inertia = rigid.GetInertia();
						var centerOfGravity = Inertia.GetCenterOfGravity();

						self._PickOriginLocal.set(centerOfGravity.oX, centerOfGravity.oY, centerOfGravity.oZ);

						var transformMyActor = self._actorPicked.getTransform();
						var PickOriginWorld_Point = self._PickOriginLocal.clone().applyTransformation(transformMyActor);
						// Cast the point into a Vector3D
						self._PickOriginWorld.set(PickOriginWorld_Point.x, PickOriginWorld_Point.y, PickOriginWorld_Point.z);
					}

					// Store the origin of the projection Plane
					self._PickOriginPlane = self._PickOriginWorld;

					// Store the mouse button-state
					self._MouseLeftPressed = true;

					// Do the physic stuff concerning the "Press" event
					self.onLeftClicPress();

				} else {
					console.log("No picking point");  
				}
			}

			if (iMouseEvent.button === EP.Mouse.EButton.eMiddle) {
				// Update du status souris
				self._MouseMiddlePressed = true;
			}

		};

		/**
		 * Executed when a mouse button is released
		 * @private
		 * @param   {EP.MouseEvent}
		 */
		this.onMouseRelease = function (iMouseEvent) {

			// user manipulated the mouse
			if (iMouseEvent.button === EP.Mouse.EButton.eLeft && self._MouseMiddlePressed === false) {

				self._MouseLeftPressed = false;

				// Do the physic stuff concerning the "Press" event
				self.onLeftClicRelease();
			}

			if (iMouseEvent.button === EP.Mouse.EButton.eMiddle) {
				// Update the mouse status
				self._MouseMiddlePressed = false;
			}
		};
	};

	PhysicsInteractor.prototype = new Behavior();
	PhysicsInteractor.prototype.constructor = PhysicsInteractor;
	PhysicsInteractor.prototype.protoId = "48C3C13D-778F-44DF-8C6C-FC6343BF35AB";
	PhysicsInteractor.prototype.pureRuntimeAttributes = [].concat(Behavior.prototype.pureRuntimeAttributes);


	/**
	 * Executed when the behavior is activating
	 * @private
	 */
	PhysicsInteractor.prototype.onActivate = function () {
		Behavior.prototype.onActivate.call(this);
		//Will be called on the experience start.

		this._inputManager = new STU.InputManager();
		if (this._inputManager === undefined || this._inputManager === null) {
			return this;
		}
		this._inputManager.initialize();
		this._inputManager.activate();
		this._inputManager.useMouse = true;

		this._myActor = this.getActor();
		var color = new STU.Color(255, 255, 255);
		this._myActor.color = color;
		this._myActor.hide();

		// gradient of color 
		this.rainbow = new PhysicsInteractor.Rainbow();
		this.rainbow.setSpectrum('FFFFFF', '0000AA');

		//  this.rainbow.setSpectrum('1D189E', '0914FD', '1F66FD', '25A8F3', '78D0C9', '7AFDD1', '62FF69', '28FE00', 'B6FE00', 'FFF803', 'FEC000', 'F89103', 'FB4602', 'FB0000');
		//  this.rainbow.setSpectrum('0000FF', '0000AA', 'FAD400', 'D70000');

		if (this._PickOriginWorld == null) {
			this._PickOriginWorld = new DSMath.Vector3D();
			this._PickOriginPlane = new DSMath.Vector3D();
		}

		if (this._PickOriginLocal == null) {
			this._PickOriginLocal = new DSMath.Point();
		}

		EventServices.addListener(EP.MousePressEvent, this.onMousePress);
		EventServices.addListener(EP.MouseReleaseEvent, this.onMouseRelease);
		EventServices.addListener(EP.MouseMoveEvent, this.onMouseMove);

		this.associatedTask = new PhysicsInteractorTask(this);
		EP.TaskPlayer.addTask(this.associatedTask);

	};

	/**
	 * Executed when the behavior is activating
	 * @private
	 */
	PhysicsInteractor.prototype.onDeactivate = function () {
		//Will be called on experience stop.
		EP.TaskPlayer.removeTask(this.associatedTask);
		delete this.associatedTask;

		EventServices.removeListener(EP.MousePressEvent, this.onMousePress);
		EventServices.removeListener(EP.MouseReleaseEvent, this.onMouseRelease);
		EventServices.removeListener(EP.MouseMoveEvent, this.onMouseMove);

		Behavior.prototype.onDeactivate.call(this);
	};



	/**
	 * Executed each frames
	 * @private
	 */
	PhysicsInteractor.prototype.onExecute = function () {

		if (this._MouseLeftPressed === false) {
			// Il ne se passe rien si on utilise pas le clic MouseLeft
			this._myActor.hide();
			return;
		}
		if (this._actorPicked === null) {
		    return;
		}

	    // _PickOriginLocal : le point pické sur l'actor manipulé, dans le repère de l'actor
	    // ce point est initialisé dans onMousePress et ne change pas au cours d'une manipulation
		var PickOriginLocal = this._PickOriginLocal.clone();
	    // la position dans le monde du point pické de l'actor manipulé
	    // vu que l'actor est déplacé, ce point se déplace en cours de manipulation (contrairement à _PickOriginLocal)
		var transformMyActor = this._actorPicked.getTransform();
		var PickOriginWorld = PickOriginLocal.applyTransformation(transformMyActor);



		// ---------------------------------------------------------------------------------------------
		// Update the application point of the initial picking point : if the picked actor has moved, we should update the picking point
		if (this._updatePickingPlan === true) {
		    this._PickOriginWorld.set(PickOriginWorld.x, PickOriginWorld.y, PickOriginWorld.z);
		}

		// ---------------------------------------------------------------------------------------------
		// Compute the target : we use the picking point as a reference to create a projection plane. 
	    // Then, the mouse is projected on the plane and we use the 3d coord of the result as a target.
	    //
	    // _PickOriginPlane = _PickOriginWorld = position du pickpoint au moment du clic
		this._Target = this.planeProjection(this._PickOriginPlane);

		// Note : it could be interesting to dissociate the "picking point" as source of the projection point ans the "picking point" as a source to apply forces and to display the arrow.
		// Observation : when we apply a force on a rigid, we want the origin of the force to follow the rigid but we don't always want the project point to move with the rigid 

		// Note Bis : I added _PickOriginPlane to store the origin of the projection plane instead of _PickOriginWorld
		 
		// ---------------------------------------------------------------------------------------------
		// We update the rendering properties of the arrow : set the position, the orientation and the scale of the 3Drep of the Arrow

		if (this._Target != null) {
			// update the arrow
			this.setPositionAndTarget(this._PickOriginWorld, this._Target, !this._push);
		}

		// ---------------------------------------------------------------------------------------------
		// ---- Update the color of the arrow : the color is based on the length of the vector
		if (this.showInteractor === true && this._Target != null) {
			var direction;
			if (this._push === true ) {
				var direction = DSMath.Vector3D.sub(this._PickOriginWorld, this._Target);
			} else {
				var direction = DSMath.Vector3D.sub(this._Target, this._PickOriginWorld);
			}

			// TODO : find a better way to compute the scale
			var ScaleFactor = direction.norm() / 25;
			var colorHex = this.rainbow.colourAt(ScaleFactor);
			var colorRGB = this.rainbow.hexToRgb(colorHex);
			var color = new STU.Color(colorRGB.r, colorRGB.g, colorRGB.b);
			this._myActor.color = color;
			this._myActor.show();
		} else {
			// Do not show the arrow
			this._myActor.hide();
		}

		// ---------------------------------------------------------------------------------------------

		// Do the Physic Stuff here
		this.onMouseMove();

	};

	/**
	 * Exectued when the left mouse button is pressed.
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicPress = function () {

		if (this.interactorType === 0) {
			this._push = false;
			this.onLeftClicPress_Grab();
			return;
		}

		if (this.interactorType === 1) {
			this._push = false;
			this.onLeftClicPress_Drag();
			return;
		}

		if (this.interactorType === 2) {
			this._push = true;
			this.onLeftClicPress_PushPull();
			return;
		}

		if (this.interactorType === 3) {
			this._push = false;
			this.onLeftClicPress_PushPull();
			return;
		}
	};

	/**
	 * Exectued when the left mouse button is released.
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicRelease = function () {

		if (this.interactorType === 0) {
			this._push = false;
			this.onLeftClicRelease_Grab();
			return;
		}

		if (this.interactorType === 1) {
			this._push = false;
			this.onLeftClicRelease_Drag();
			return;
		}

		if (this.interactorType === 2) {
			this._push = true;
			this.onLeftClicRelease_PushPull();
			return;
		}

		if (this.interactorType === 3) {
			this._push = false;
			this.onLeftClicRelease_PushPull();
			return;
		}
	};


	// ----------------------
	// Keyframed motion
	// ----------------------

	/**
	 * Exectued when the left mouse button is pressed
	 * and interaction type is set to grab
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicPress_Grab = function () {

	    if (this._actorPicked != null) {
			// We want to move a rigid object so we change the Motion type of the Rigid object
			this._previousMotionType = this._actorPicked.RigidBody.MotionType;

			this._actorPicked.RigidBody.MotionType = 2; // 2 is for "keyframed"
		}
	};

	/**
	 * Exectued when the left mouse button is released
	 * and interaction type is set to grab
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicRelease_Grab = function () {

		if (this._actorPicked != null) {

			// Stop moving the rigidBody : restore the previous motion type
			this._actorPicked.RigidBody.MotionType = this._previousMotionType;

			this._actorPicked = null;
		}
	};

	/**
	 * Exectued when the left mouse button is released, the mouse is moving
	 * and interaction type is set to grab
	 * @private
	 */
	PhysicsInteractor.prototype.onMouseMove_Grab = function () {
	    if (this._actorPicked != null && this._Target != null) {

	        // _Target : un vector qui tient la position au bout de la souris vers laquelle on tire l'actor manipulé

	        // _PickOriginLocal : le point pické sur l'actor manipulé, dans le repère de l'actor
	        // ce point est initialisé dans onMousePress et ne change pas au cours d'une manipulation
	        var PickOriginLocalPt = new DSMath.Point(this._PickOriginLocal.x, this._PickOriginLocal.y, this._PickOriginLocal.z);
	        var transformMyActor = this._actorPicked.getTransform();
	        var PickOriginWorldPt = PickOriginLocalPt.clone();
	        PickOriginWorldPt.applyTransformation(transformMyActor);

	        // PickOriginWorldPt : la position du point pické sur l'actor 
	        // dans le repère monde
            // au moment courant de la manipulation

	        var TargetPos = new DSMath.Vector3D(this._Target.x, this._Target.y, this._Target.z);
	        this._actorPicked.setPosition(TargetPos);
		}
		// -------------------------------
	};

	// -------------------------------
	// Apply a FORCE to drag the actor
	// -------------------------------
	/**
	 * Exectued when the left mouse button is pressed
	 * and interaction type is set to drag
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicPress_Drag = function () {
		// Nothing to do
		this._updatePickingPlan = true;
	};

	/**
	 * Exectued when the left mouse button is released
	 * and interaction type is set to drag
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicRelease_Drag = function () {

		if (this._actorPicked != null) {
			// Remove the Force to stop dragging the actor
			this._actorPicked.RigidBody.removeForce();

			this._updatePickingPlan = false;

			this._actorPicked = null;
		}
	};

	/**
	 * Exectued when the left mouse button is released, the mouse is moving
	 * and interaction type is set to drag
	 * @private
	 */
	PhysicsInteractor.prototype.onMouseMove_Drag = function () {
		// On calcul un vecteur force à appliquer sur le Rigid
		// -------------------------------------------------------
	    if (this._actorPicked != null && this._Target != null) {

			// to update the force in CDSdyn, we must remove it and apply it again with the new parameters
			this._actorPicked.RigidBody.removeForce();

			var direction = new DSMath.Vector3D();

			if (this._push == true) {
				direction = DSMath.Vector3D.sub(this._PickOriginWorld, this._Target);
			} else {
				direction = DSMath.Vector3D.sub(this._Target, this._PickOriginWorld);
			}

		    // We need less force to move an actor when we apply the force each frame than when we use an Impulse
            // IBS : ne faudrait il pas une force qui dépende du framerate ?
			var factor = this.forceFactor / 10;

			if (this.massDependent === true) {
				var actor_mass = this._actorPicked.RigidBody.mass;
				factor = actor_mass * factor;
			}

		    
			this._actorPicked.RigidBody.addForce(this._PickOriginWorld, direction, factor);

		    // IBS : pour éviter de rebondir sans amortissement quand la souris s'immobilise
		    //       ajouton un terme de viscosité
			var MyRigidObj = this._actorPicked.RigidBody.getRigidObject();

			var DragLinearViscosity = 0.95;
			var MyLinearV = MyRigidObj.GetLinearVelocity();
			MyRigidObj.SetLinearVelocity(MyLinearV.oVelX * DragLinearViscosity, MyLinearV.oVelY * DragLinearViscosity, MyLinearV.oVelZ * DragLinearViscosity);

			var DragAngularViscosity = 0.95;
			var MyAngularV = MyRigidObj.GetAngularVelocity();
			MyRigidObj.SetAngularVelocity(MyAngularV.oVelX * DragAngularViscosity, MyAngularV.oVelY * DragAngularViscosity, MyAngularV.oVelZ * DragAngularViscosity);
		}
		// -------------------------------
	};


	// ------------------------
	// Apply an impulse IMPULSE
	// ------------------------

	/**
	 * Exectued when the left mouse button is pressed
	 * and interaction type is set to push or pull
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicPress_PushPull = function () {
		// Nothing to do : only apply the impulse when we release the mouse button

		this._updatePickingPlan = true;
	};

	/**
	 * Exectued when the left mouse button is released
	 * and interaction type is set to push or pull
	 * @private
	 */
	PhysicsInteractor.prototype.onLeftClicRelease_PushPull = function () {

		// On calcul un vecteur d'impulse à appliquer sur le Rigid
		// -------------------------------------------------------
	    if (this._actorPicked != null && this._Target != null) {

			var direction = new DSMath.Vector3D();

			if (this._push === true) {
				direction = DSMath.Vector3D.sub(this._PickOriginWorld, this._Target);
			} else {
				direction = DSMath.Vector3D.sub(this._Target, this._PickOriginWorld);
			}

			var factor = this.forceFactor;

			if (this.massDependent === true) {
				var actor_mass = this._actorPicked.RigidBody.mass;
				var factor = actor_mass * this.forceFactor;
			}

			this._actorPicked.RigidBody.addImpulse(this._PickOriginWorld, direction, this.forceFactor);
			this._actorPicked = null;

			this._updatePickingPlan = false;
		}
		// -------------------------------
	};

	/**
	 * Exectued when the left mouse button is released, the mouse is moving
	 * and interaction type is set to push or pull
	 * @private
	 */
	PhysicsInteractor.prototype.onMouseMove_PushPull = function () {
		// Nothing to do : only apply the impulse when we release the mouse button
	};

	/**
	 * SetPositionAndTarget
	 * @public
	 * @param   {DSMath.Vector3D} iPosition
	 * @param   {DSMath.Vector3D} iTarget
	 * @param   {boolean} iReversed Swap the target and the position the display the reversed arrow
	 */
	PhysicsInteractor.prototype.setPositionAndTarget = function (iPosition, iTarget, iReversed) {

		var Position = new DSMath.Vector3D();
		var Target = new DSMath.Vector3D();

		if (iReversed == true) {
			// Swap the target and the position the display the reversed arrow
			Position = iTarget;
			Target = iPosition;
		} else {
			// Set the target and the position
			Position = iPosition;
			Target = iTarget;
		}

		// Set the position of the actor
		this._myActor.setPosition(Position);

		// Set the axis of the actor to be aligned with the target (the Array template is aligned with the Z axis)
		var axisToAlign = new DSMath.Vector3D(0,0,1);

		// compute the direction to the target
		var directionToTarget = DSMath.Vector3D.sub(Target, this._myActor.getPosition());

		// compute the Scale Factor to get the top of the actor on the target
		// TODO : compute the size of the actor to remove the hardcoded value.
		var ScaleFactor = directionToTarget.norm() / 500;

		// Compute the rotation Quaternion (IK "one bone" method)
		// ------------------------------------------------------
		var quat = new DSMath.Quaternion();

		// first normalize the target vector
		directionToTarget.normalize();

		// compute the rotation vector of the Quaternion
		var rotVector = DSMath.Vector3D.cross(axisToAlign, directionToTarget);

		// Normalize the result
		rotVector.normalize();

		// compute the Angle of the Quaternion
		var cosAlpha = axisToAlign.dot(directionToTarget);
		var alpha = Math.acos(cosAlpha);

		// Set the Quaternion values
		quat.makeRotation(rotVector, alpha);

		var eulerRot = this.quaternionToEuler(quat);

		// Set the Euler rotation
		this._myActor.setRotation(eulerRot);

		if (ScaleFactor < 0.001) {ScaleFactor = 0.001;}

		this._myActor.setScale(ScaleFactor);
	};

	/**
	 * PlaneProjection
	 * @public
	 * @param   {DSMath.Vector3D} iOrigin la position monde du pickpoint au moment du clic
	 */
	PhysicsInteractor.prototype.planeProjection = function (iOrigin) {
		// get the line from the camera to the mouse cursor
		var mouseLine = this.getLineFromMousePosition();

		// Create the projection Plane
		var ProjPlane = new DSMath.Plane();

		var originPlane = new DSMath.Point(iOrigin.x, iOrigin.y, iOrigin.z);
		ProjPlane.origin = originPlane;

		var vN1 = new DSMath.Vector3D();
		var vN2 = new DSMath.Vector3D();


		if (this._planeMode === 0) {
			// Plan XY
			vN1.set(1, 0, 0);
			vN2.set(0, 1, 0);

			// Blue Arrow
			this.rainbow.setSpectrum('FFFFFF', '0000AA');
		}

		if (this._planeMode === 1) {
		    var renderManager = STU.RenderManager.getInstance();
		    var gravityDirectionWorld = renderManager.getGravityVector(this._myActor, "World");

			// Plan align on the camera (for the Z UP)
			var cameraPlanes = this.getCameraViewPlan();
			vN1 = gravityDirectionWorld.clone();
			vN2 = cameraPlanes.cameraRight;

			// Green Arrow
			this.rainbow.setSpectrum('FFFFFF', '00AA00');
		}

		// Set the Plane Parameters
		ProjPlane.setVectors(vN1, vN2);

		// Compute the projection
		var intersectRes = ProjPlane.intersectLine(mouseLine);

		if (intersectRes.diag === 0) {
			// Take the first result
			var intersectVect = new DSMath.Vector3D();
			var intersectPoint = ProjPlane.evalPoint(intersectRes.param1OnPlane, intersectRes.param2OnPlane);
			intersectVect.set(intersectPoint.x, intersectPoint.y, intersectPoint.z);

			return intersectVect;

		} else {
			return null;
		}
	};

	/**
	 * Get a line passing by the camera and the mouse cursor (it's a 3D representation of the mouse 2D position).
	 * @public
	 * @return {DSMath.Line}
	 */
	PhysicsInteractor.prototype.getLineFromMousePosition = function () {

		var viewerSize = STU.RenderManager.getInstance().getViewerSize();

		var axis = this._inputManager.axis1;

		var x = (-axis.x + 1) / 2 * viewerSize.x;
		var y = (-axis.y - 1) / -2 * viewerSize.y;

		var _renderMngr = STU.RenderManager.getInstance();
		var point = new DSMath.Vector2D(x, y);

		var line = _renderMngr.getLineFromPosition(point);

		return line;
	};

	/**
	 * Method to get the Up/Right/Sigh vectors of the current camera
	 * @public
	 * @return  {Object}
	 */
	PhysicsInteractor.prototype.getCameraViewPlan = function () {

		var obj_out = {
			cameraUP: 0,
			cameraRight: 0,
			cameraSigh: 0
		};

		var rm = STU.RenderManager.getInstance();
		if (typeof rm === "undefined" || rm === null) {
			console.log("Unable to retrieve Render Manager.");
			return;
		}

		// Get the active Viewpoint (instead of the active camera to avoid probleme when this is no camera)
		var main3DViewpoint = rm.main3DViewpoint;

		if (typeof main3DViewpoint === "undefined" || main3DViewpoint === null) {
			console.log("main3DViewpoint is undefined or null");
			return;
		}

		var cameraSigh = new DSMath.Vector3D();
		main3DViewpoint.__stu__GetSightDirection(cameraSigh);

		var cameraUP = new DSMath.Vector3D();
		main3DViewpoint.__stu__GetUpDirection(cameraUP);

		// compute the Right vector based on the CrossProduct of the Up and front vector
		var cameraRight = DSMath.Vector3D.cross(cameraSigh, cameraUP);

		obj_out.cameraUP = cameraUP;
		obj_out.cameraRight = cameraRight;
		obj_out.cameraSigh = cameraSigh;

		return obj_out;
	};

	/**
	 * Method to convert quaternion into Euler angles
	 * @public
	 * @param   {DSMath.Quaternion}
	 */
	PhysicsInteractor.prototype.quaternionToEuler = function (iQuat) {

		// Get the matix from the Quaternion
		var RotMatrix = iQuat.getMatrix();

		// create a Transform operator
		var transformMyActor = new DSMath.Transformation();
		transformMyActor.matrix = RotMatrix;

		// Get the Euler Angles (in an array)
		var eulerangle = transformMyActor.getEuler();

		// Create a vector and set the angle
		var oRot = new DSMath.Vector3D();

		// swap the axe for some reason
		oRot.x = eulerangle[1];
		oRot.y = eulerangle[2];
		oRot.z = eulerangle[0];

		return oRot;
	};

	/**
	 * Method to convert Actor matrix into quaternion
	 * @private
	 * @param   {STU.Actor3D}
	 * @return  {DSMath.Quaternion}
	 */
	PhysicsInteractor.prototype.actorToQuaternion = function (iActor) {

		var transformMyActor = new DSMath.Transformation();
		transformMyActor = iActor.getTransform();

		var coefScale = 1.0 / currentScale;

		// remove the scaling component of the matrix
		var matrix3x3 = transformMyActor.matrix;
		var coefMatrix3x3 = matrix3x3.getArray();
		for (var i = 0; i < coefMatrix3x3.length; i++) {
			coefMatrix3x3[i] *= coefScale;
		}

		// Now we have a pure rotation matrix
		matrix3x3.setFromArray(coefMatrix3x3);

		var oQuat = new DSMath.Quaternion();
		matrix3x3.getQuaternion(oQuat);

		return oQuat;
	};


	/**
	 * Method to pick a point from the Mouse Position
	 * @private
     * @return  {STU.Intersection}
	 */
	PhysicsInteractor.prototype.pickPoint = function () {

		var mouse = EP.Devices.getMouse();

		var mousePosition = mouse.getPosition();

		var intersections = STU.RenderManager.getInstance()._pickFromPosition(mousePosition);
		var firstIntersection = intersections[0];

		if (firstIntersection === undefined || firstIntersection === null) {
			return null;
		} else {
			return firstIntersection;
		}
	};

	PhysicsInteractor.Rainbow = function () {
		var gradients = null;
		var minNum = 0;
		var maxNum = 100;
		var colours = ['ff0000', 'ffff00', '00ff00', '0000ff'];

		this.setColours = function (spectrum) {
			if (spectrum.length < 2) {
				throw new Error('Rainbow must have two or more colours.');
			} else {
				var increment = (maxNum - minNum) / (spectrum.length - 1);
				var firstGradient = new ColourGradient();
				firstGradient.setGradient(spectrum[0], spectrum[1]);
				firstGradient.setNumberRange(minNum, minNum + increment);
				gradients = [firstGradient];

				for (var i = 1; i < spectrum.length - 1; i++) {
					var colourGradient = new ColourGradient();
					colourGradient.setGradient(spectrum[i], spectrum[i + 1]);
					colourGradient.setNumberRange(minNum + increment * i, minNum + increment * (i + 1));
					gradients[i] = colourGradient;
				}

				colours = spectrum;
				return this;
			}
		};

		this.setColours(colours);
		this.setColors = this.setColours;

		this.setSpectrum = function () {
			this.setColours(arguments);
			return this;
		};

		this.setSpectrumByArray = function (array) {
			this.setColours(array);
			return this;
		};

		this.colourAt = function (number) {
			if (isNaN(number)) {
				console.log(number + ' is not a number');
			} else if (gradients.length === 1) {
				return gradients[0].colourAt(number);
			} else {
				var segment = (maxNum - minNum) / (gradients.length);
				var index = Math.min(Math.floor((Math.max(number, minNum) - minNum) / segment), gradients.length - 1);
				return gradients[index].colourAt(number);
			}
		};

		this.colorAt = this.colourAt;

		this.setNumberRange = function (minNumber, maxNumber) {
			if (maxNumber > minNumber) {
				minNum = minNumber;
				maxNum = maxNumber;
				this.setColours(colours);
			} else {
				console.log('maxNumber (' + maxNumber + ') is not greater than minNumber (' + minNumber + ')');
			}
			return this;
		};

		this.hexToRgb = function (hex) {

			var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);

			return result ? {
				r: parseInt(result[1], 16),
				g: parseInt(result[2], 16),
				b: parseInt(result[3], 16)
			} : null;
		};


	};

	function ColourGradient() {
		var startColour = 'ff0000';
		var endColour = '0000ff';
		var minNum = 0;
		var maxNum = 100;

		this.setGradient = function (colourStart, colourEnd) {
			startColour = this.getHexColour(colourStart);
			endColour = this.getHexColour(colourEnd);
		};

		this.setNumberRange = function (minNumber, maxNumber) {
			if (maxNumber > minNumber) {
				minNum = minNumber;
				maxNum = maxNumber;
			} else {
				console.log('maxNumber (' + maxNumber + ') is not greater than minNumber (' + minNumber + ')');
			}
		};

		this.colourAt = function (number) {
			return this.calcHex(number, startColour.substring(0, 2), endColour.substring(0, 2)) + this.calcHex(number, startColour.substring(2, 4), endColour.substring(2, 4)) + this.calcHex(number, startColour.substring(4, 6), endColour.substring(4, 6));
		};

		this.calcHex = function (number, channelStart_Base16, channelEnd_Base16) {
			var num = number;
			if (num < minNum) {
				num = minNum;
			}
			if (num > maxNum) {
				num = maxNum;
			}
			var numRange = maxNum - minNum;
			var cStart_Base10 = parseInt(channelStart_Base16, 16);
			var cEnd_Base10 = parseInt(channelEnd_Base16, 16);
			var cPerUnit = (cEnd_Base10 - cStart_Base10) / numRange;
			var c_Base10 = Math.round(cPerUnit * (num - minNum) + cStart_Base10);
			return this.formatHex(c_Base10.toString(16));
		};

		this.formatHex = function (hex) {
			if (hex.length === 1) {
				return '0' + hex;
			} else {
				return hex;
			}
		};

		this.isHexColour = function (string) {
			var regex = /^#?[0-9a-fA-F]{6}$/i;
			return regex.test(string);
		};

		this.getHexColour = function (string) {
			if (this.isHexColour(string)) {
				return string.substring(string.length - 6, string.length);
			} else {
				var colourNames =
					[
						['red', 'ff0000'],
						['lime', '00ff00'],
						['blue', '0000ff'],
						['yellow', 'ffff00'],
						['orange', 'ff8000'],
						['aqua', '00ffff'],
						['fuchsia', 'ff00ff'],
						['white', 'ffffff'],
						['black', '000000'],
						['gray', '808080'],
						['grey', '808080'],
						['silver', 'c0c0c0'],
						['maroon', '800000'],
						['olive', '808000'],
						['green', '008000'],
						['teal', '008080'],
						['navy', '000080'],
						['purple', '800080']
					];
				for (var i = 0; i < colourNames.length; i++) {
					if (string.toLowerCase() === colourNames[i][0]) {
						return colourNames[i][1];
					}
				}
				console.log(string + ' is not a valid colour.');
			}
		};
	}

	/**
	 * Print all methods of an object
	 * @method  getAllMethods
	 * @private
	 * @param   {Object}
	 */
	PhysicsInteractor.prototype.getAllMethods = function (obj) {

		var methods = [];
		var Properties = [];

		for (var m in obj) {
			if (typeof obj[m] == "function") {
				methods.push(m);
			} else {
				Properties.push(m);
			}
		}
		console.log(obj + "\n  " + methods.join("  \n  "));
		console.log("\n\n Properties :\n  " + Properties.join("  \n  "));
		console.log("\n Stringify = " + JSON.stringify(obj));
	};

	// Expose in STU namespace.
	STU.PhysicsInteractor = PhysicsInteractor;

	return PhysicsInteractor;
	});

define('StuPhysic/StuPhysicsInteractor', ['DS/StuPhysic/StuPhysicsInteractor'], function (PhysicsInteractor) {
    'use strict';

    return PhysicsInteractor;
});
