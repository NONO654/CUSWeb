// * @quickReview IBS 19:08:06 Deactivate mechanism
// * @quickReview IBS 16:05:20 MLK
// * @quickReview IBS 15:06:22 correction noms pour les outils reccord/replay 
// * @quickReview IBS 15:06:22 gestion scaling 

// SCALING :
//
//  imaginons qu'on a un actor qui participe à la dyn qui a été scalé dans la scène
//  cet acteur a donc une position qui est la combinaison d'une rotation, d'une translation et d'un scaling
//
//  NOTE SUR L'ORDRE DES MATRICES SCALING-TRANSLATION
//  le scaling est appliqué "en premier" sur l'objet, avant la rotation et translation 
//          ce qui veut dire : si j'ai un bidule de dimension 1 à la position (0,0,0)
//          j'applique un scaling de 2 sur le bidule et je le bouge à la position (15,0,0)
//          c'est équivalent à dire : 
//                  j'applique la matrice diagonale de determinant 2 à l'objet sans position (homothétie centre O, rapport 2)
//                  puis je déplace le résultat d'une translation (15,0,0)
//          ce n'est PAS équivalent à :
//                  je translate l'objet d'une translation (15,0,0)
//                  puis j'applique la matrice diagonale de determinant 2 à l'objet sans position (homothétie centre O, rapport 2)
//          parceque dans le 2e cas, le scaling s'appliquera également au vecteur de translation, et le résultat est différent
//
//          donc ce que je vois à l'écran c'est le résultat de 
//          Mt * Ms * P
//          où P est un point de l'objet "ininital" (sans position, sans scaling, tel qu'il apparraitrait dans open in new window),
//          Ms une matrice de scaling et Mt une matrice de translation
//
//
//  COMMENT GERER LE SCALING
//  TL;DR : mal
//  il y a 2 moyens de faire participer un objet product à la dyn : maillage (CreateMesh) ou bounding box (CreateBox)
//  quand je génère un maillage ou une boite englobante, je peux prendre en compte le scaling de l'objet, directement à la génération du maillage/BBox
//  c'est fait dans StuCreateDynMeshCmd::GenerateMesh
//  le maillage/BBox englobe l'objet scalé
//  ici je récupère le maillage / Bbox qui prend en compte le scaling et je créé l'objet dyn RigidBody correspondant
//  c'est fait dans :
//  RigidBody.prototype.onActivate
//      ...
//      else if (MyActor instanceof STU.Actor3D)
//          ...
//  coté CDSDyn, personne ne sait que l'objet a été scalé, CDSDyn va gérer des matrices sans scaling et c'est ça qu'on veut
//
//  au cours du play je récupère des positions de CDSDyn qui fait bouger les objets, sans être au courant qu'ils sont issus de scaling
//  ça se passe dans RigidBody.prototype.updateNode3D
//
//  dans le cas maillage, à chaque pas de temps je récupère une nouvelle position Mt'
//  j'applique cette position à l'actor ( MyActor.setPosition(posActor)) et ce que je vais voir à l'écran c'est
//  Mt' * Ms * P
//  tout va bien.
//
//  dans le cas BBox, c'est plus compliqué.
//  j'ai un bidule qui a été modélisé de telle sorte qu'il n'est pas centré à l'origine du repère dans lequel il a été créé
//  par exemple :
//
//
//            MON OBJET     
//     ^                    
//     Y                    
//     |      _____         
//     |     /     |        
//     |    /      |        
//     |   /       |        
//     |   \_______/        
//     |                    
//     |----------------X> 
//    O                     
//
//  j'insert cet objet dans une scène scalé et translaté 
//
//
//       MA SCENE
//                         MON OBJET
//  Y                               __________
//  |                             /           |
//  |                 ^          /            |
//  |                 Y         /             |
//  |                 |        /              |
//  |                 |       /               |
//  |                 |      /                |
//  |                 |      \                /
//  |                 |       \______________/ 
//  |                 |                        
//  |                 |
//  |                 |
//  |                 |----------------X> 
//  |
//  |
//  |------------------------------------X>
//
//   je calcule une BBox de cet objet, dans son repère ça me donne un truc comme ça :
//
//      MA BBOX
//       ___________________
//      |        __________ |
//      |      /           ||
// ^    |     /            ||
// Y    |    /             ||
// |    |   /              ||
// |    |  /               ||
// |    | /                ||
// |    | \                /|
// |    |  \______________/ |
// |    |___________________|
// |
// |
// |----------------X> 
//
//
//
//  j'appel CreateBox pour créer une boite qui est de la bonne taille
//  CreateBox ne prend pas de position, juste une taille, et créé une boite centrée sur l'origine, comme ça :
//
//
//      CREATEBOX
//       ___________________
//      |                   |
//      |                   |
//      |         ^Y        |
//      |         |         |
//      |         |         |
//      |         -----X>   |
//      |                   |
//      |                   |
//      |                   |
//      |___________________|
//
//
//  Je dois donc mémoriser la translation nécessaire à appliquer à cette boite centrée à l'origine 
//  pour qu'elle aille englober l'acteur qu'elle repèsente
//  appelons cette tranlation T
//  _BB_Local_Coord contient (-T) 
//  la position de la boite qui représente mon objet dans la CDSDyn-scène est obtenu comme ça :
//  . récupérer la position de mon objet dans ma scène créative
//  . virer la partie scaling (déjà prise en compte au calcul de la taille de la BBox)
//  . appliquer la partie rotation à T (qui est l'offset entre la boite et l'objet qu'elle doit contenir) => T'
//
//  => position de la boite qui représente mon objet dans la CDSDyn-scène = position l'objet dans la creative-scène + T'
//  voir computeRigidPosBasedOnActor
//
//  réciproquement, quand on veut mettre à jour la position de l'acteur à partir d'une nouvelle position de la boite dans la CDSDyn-scène
//  . récupérer l'orientation de la boite => c'est la même orientation que mon objet
//  . appliquer cette rotation à (-T) (qui est l'offset entre la boite et l'objet qu'elle doit contenir) => T'
//  . on ne touche pas au scaling de l'actor, et on espère que ça se passe bien
//
//  => position de l'objet dans la creative-scène = position la boite qui représente mon objet dans la CDSDyn-scène + T'
//  voir updateNode3D



define('DS/StuPhysic/StuPhysicRigidBody', ['DS/StuCore/StuContext', 'MathematicsES/MathsDef', 'DS/StuPhysic/StuCDSDynFactory', 'DS/StuModel/StuBehavior',
    'DS/StuPhysic/StuPhysicManagerNa', 'DS/StuGeometricPrimitives/StuTorusActor'],
    function (STU, DSMath, StuCDSDynFactory) {
        'use strict';

        /**
         * Describe a behavior attached to an Actor3D to make it physicalized (i.e. reactive to gravity and collisions with the other Rigid Body of the scene).<br/>
         * 
         * To use it, you must have the following role: CHA - Marketing Content Animator
         *
         * @exports RigidBody
         * @class 
         * @constructor
         * @noinstancector
         * @public
         * @extends STU.Behavior
         * @memberOf STU
         * @alias STU.RigidBody
         */

        var RigidBody = function () {
            STU.Behavior.call(this);
            this.name = "RigidBody";

            //////////////////////////////////////////////////////////////////////////
            // Properties that should be visible in UI
            //////////////////////////////////////////////////////////////////////////


            // IBS properties : normallement pas nécessaire de définir un get/set pour MotionType
            // parce que ce paramètre est réutilisé à chaque frame dans ::keyframed, ::updateNode3D
            //this.MotionType = 0;

            /**
             * Defines the motion type for Rigid Body. <br/>
             * There are 3 possible motion types:<br/>
             *    0 <-> Dynamic : the Rigid Body can move and react to collision with other Rigid Body.<br/>
             *    1 <-> Fixed : the Rigid Body is fixed. It cannot move but it makes other Rigid Body react when collided by them.<br/>
             *    2 <-> Driven : the position of the Rigid Body is driven by the position of the Actor3D. Each frame, the physical solver
             *    tries to match the position of the Actor3D and takes in account the collisions and the gravity. <br/>
             *
             * @type {number}
             */
            Object.defineProperty(this, "motionType", {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._motionType;
                },
                set: function (value) {
                    this._motionType = value;
                    if (this.CDSDynRigidBody !== null && this.CDSDynRigidBody !== undefined) {
                        if (value === 1) {
                            // MotionType = 1 -> the rigid is fixed
                            this.CDSDynRigidBody.SetFixed(1);
                        }
                        else {
                            // Set the FixedProperty in case of the MotionType has been modified without updating the CDSdyn Property
                            this.CDSDynRigidBody.SetFixed(0);
                        }
                    }
                }
            });


            /**
           * Get/Set Density
           * This property must be set between 0 and 1
           * @member
           * @name Density
           * @public
           * @type {number}
           * @memberOf STU.RigidBody
           */
            Object.defineProperty(this, "density", {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._density;
                },
                set: function (value) {
                    if (value < 0.0) {
                        value = 0.0;
                    }
                    this._density = value;
                    this.VolumicMass = 0.000001 * this._density;

                    if (this.CDSDynRigidBody !== null && this.CDSDynRigidBody !== undefined) {
                        var MyInertia = this.CDSDynRigidBody.GetInertia();
                        if (MyInertia !== null && MyInertia !== undefined) {

                            var MyShape = this.CDSDynRigidBody.GetShape();

                            if (MyShape !== null && MyShape !== undefined) {
                                //var myInertiaComputer = CDSDynCreateInertiaComputer(MyShape, this.VolumicMass); // IBS CHECK MLK myInertiaComputer OK
                                var myInertiaComputer = StuCDSDynFactory.buildCDSDynInertiaComputer(MyShape, this.VolumicMass);
                                myInertiaComputer.Run();

                                var mass = myInertiaComputer.GetMass();
                                //var inertia = myInertiaComputer.GetPrincipalInertia();
                                //var CoG = myInertiaComputer.GetCoG();
                                //var NewInertia = PhysManager.DynFactory.CreateInertia("NewInertia");
                                //this.CDSDynRigidBody.SetInertia(NewInertia);
                                MyInertia.SetMass(mass);

                                // Store the mass and the inertia
                                this.mass = mass;
                                //CDSDynRemoveInertiaComputer(myInertiaComputer);
                                StuCDSDynFactory.removeCDSDynInertiaComputer(myInertiaComputer);             // IBS CHECK MLK ~myInertiaComputer
                            }
                        }
                    }
                }
            });

            /**
            * Get/Set Restitution
            * This property must be set between 0 and 1
            * @member
            * @name Restitution
            * @public
            * @type {number}
            * @memberOf STU.RigidBody
            */
            Object.defineProperty(this, "restitution", {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._restitution;
                },
                set: function (value) {
                    if (value < 0.0) {
                        value = 0.0;
                    }
                    if (value > 1.0) {
                        value = 1.0;
                    }

                    this._restitution = value;

                    if (this.CDSDynRigidBody !== null && this.CDSDynRigidBody !== undefined) {
                        var MyMaterial = this.CDSDynRigidBody.GetMaterial();
                        if (MyMaterial !== null && MyMaterial !== undefined) {
                            MyMaterial.SetRestitutionCoeff(value, false);
                        }
                    }
                }
            });


            /**
            * Get/Set Friction
            * This property must be set between 0 and 1
            * @member
            * @name Friction
            * @public
            * @type {number}
            * @memberOf STU.RigidBody
            */
            Object.defineProperty(this, "friction", {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._friction;
                },
                set: function (value) {
                    if (value < 0.0) {
                        value = 0.0;
                    }
                    if (value > 1.0) {
                        value = 1.0;
                    }

                    this._friction = value;

                    if (this.CDSDynRigidBody !== null && this.CDSDynRigidBody !== undefined) {
                        var MyMaterial = this.CDSDynRigidBody.GetMaterial();
                        if (MyMaterial !== null && MyMaterial !== undefined) {
                            MyMaterial.SetFrictionCoeff(value);
                        }
                    }
                }
            });


            /**
            * Get/Set Damping
            * Simulate the loss of angular energy of a system.
            * Express in percentage diminution of angular velocity per second.
            * This property must be set between 0 and 1
            * @member
            * @name Damping
            * @public
            * @type {number}
            * @memberOf STU.RigidBody
            */
            Object.defineProperty(this, "damping", {
                enumerable: true,
                configurable: true,
                get: function () {
                    return this._damping;
                },
                set: function (value) {
                    if (value < 0.0) {
                        value = 0.0;
                    }
                    if (value > 1.0) {
                        value = 1.0;
                    }

                    this._damping = value;

                    if (this.CDSDynRigidBody !== null && this.CDSDynRigidBody !== undefined) {
                        this.CDSDynRigidBody.SetAngularDamping(value);
                    }
                }
            });


            //////////////////////////////////////////////////////////////////////////
            // Properties that should not be visible in UI
            //////////////////////////////////////////////////////////////////////////

            this._motionType = 0;
            this._density = 1;
            this._restitution = 0.5;
            this._friction = 0.4;
            this._damping = 0.0;

            this._keyframedMaxForce = -1;
            this._keyframedMaxTorque = -1;
            this._force = null;

            // Store the BoundingBox local coord (relative to the pivot point of the actor)
            // We need this info because the pivotPoint of the physic object can be different from the pivot point of the Actor.
            // With the current design, the pivot point of the Rigid Body is the center of the bounding box of the visu Object.
            this._BB_Local_Coord = null;
            this._isInit = false;
        };


        RigidBody.prototype = new STU.Behavior();
        RigidBody.prototype.protoId = "C6F31100-F661-4014-86B0-8890FA24F2D6";
        RigidBody.prototype.constructor = RigidBody;

        //Will be called on the experience start.
        RigidBody.prototype.onActivate = function () {
            console.debug("RigidBody onActivate");
            // ----------------------------------------------------

            if (this._isInit === false) {
                // au premier activate, on initialise
                this.RigidBodyActivated = true;
                this.buildCDSDynRigidBody();
            }

            // au activates suivants, on réactive un behavior qui a déjà été initialisé
            else {
                console.debug("RigidBody Already intialized");

                // réactivation
                if (this.RigidBodyActivated === false) {
                    this.RigidBodyActivated = true;
                    // restore la position du RigidBody dans le monde dyn
                    this.updateRigidPos();
                    // restore la vitesse  du RigidBody dans le monde dyn
                    this.CDSDynRigidBody.SetLinearVelocity(this.LinVelAtDeactivate.oVelX, this.LinVelAtDeactivate.oVelY, this.LinVelAtDeactivate.oVelZ);
                    this.CDSDynRigidBody.SetAngularVelocity(this.AngVelAtDeactivate.oVelX, this.AngVelAtDeactivate.oVelY, this.AngVelAtDeactivate.oVelZ);
                }
            }
        };

        RigidBody.prototype.buildCDSDynRigidBody = function () {

            // Creation de la Shape physique
            // -----------------------------

            var PhysManager = STU.PhysicManager.getInstance();
            this.MyActor = this.getActor();
            var MyActor = this.MyActor;
            var currentScale = MyActor.getScale();
            var CDSDynshape = null;

            // IBS TEST PolyhedralClashEngine
            var CDSDynshapeFromRepStream = null;
            if (PhysManager._TestPolyhedralClashEngine) {
                console.log("TestPolyhedralClashEngine!!");
                var RepStream = new Object();
                RepStream.size = 0;
                RepStream.stream = "X";
                MyActor.StuIRepresentation.GetRepStream(RepStream);
                CDSDynshapeFromRepStream = PhysManager.DynFactory.CreateCustomShape("MyCDSDynshapeFromRepStream" + PhysManager.getObjectCount().toString(), dynExternal("CATCDSPolyhedralShape", RepStream.stream));
            }

            if (MyActor instanceof STU.CubeActor) {

                // BugFix : we take the absolute value since you can enter a negative value in the property view without affecting the mesh
                var ActorLength = Math.abs(MyActor.length);
                var ActorWidth = Math.abs(MyActor.width);
                var ActorHeight = Math.abs(MyActor.height);

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateBox("MyCDSDynshape" + PhysManager.getObjectCount().toString(), (currentScale * ActorLength / 2), (currentScale * ActorWidth / 2), (currentScale * ActorHeight / 2));

            } else if (MyActor instanceof STU.PlaneActor) {
                //CDSDynshape = PhysManager.DynFactory.CreatePlane("CDSDynshape");
                // on donne une épaisseur au plan pour avoir inertie, volume etc
                var ActorLength = Math.abs(MyActor.length);
                var ActorWidth = Math.abs(MyActor.width);
                var ActorHeight;
                if (ActorLength < ActorWidth) {
                    ActorHeight = ActorLength / 1000.0;
                }
                else {
                    ActorHeight = ActorWidth / 1000.0;
                }

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateBox("MyCDSDynshape" + PhysManager.getObjectCount().toString(), (currentScale * ActorLength / 2), (currentScale * ActorWidth / 2), (currentScale * ActorHeight));

            } else if (MyActor instanceof STU.CapsuleActor) {

                // Ignore the negative values. 
                var ActorRadius = Math.abs(MyActor.radius);
                var ActorHeight = Math.abs(MyActor.height);

                // the Height of the capsule in CDSdyn is the distance between the 2 demi-sphere. In creative it's the total length.
                var capsuleHeight = ActorHeight - (ActorRadius * 2);

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateCapsule("MyCDSDynshape" + PhysManager.getObjectCount().toString(), (currentScale * capsuleHeight / 2), currentScale * ActorRadius, currentScale * ActorRadius);

            } else if (MyActor instanceof STU.CylinderActor) {

                var ActorHeight = Math.abs(MyActor.height);
                var ActorRadius = Math.abs(MyActor.radius);

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateCylinder("MyCDSDynshape" + PhysManager.getObjectCount().toString(), (currentScale * ActorHeight / 2), currentScale * ActorRadius);

            } else if (MyActor instanceof STU.TorusActor) {

                // Not torus in CDSdyn so create cylinder
                var ActorHeight = Math.abs(MyActor.radius2);
                var ActorRadius = Math.abs(MyActor.radius1) + ActorHeight;

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateCylinder("MyCDSDynshape" + PhysManager.getObjectCount().toString(), (currentScale * ActorHeight), currentScale * ActorRadius);

            } else if (MyActor instanceof STU.SphereActor) {

                var ActorRadius = 0;

                // Clamp the radius because of the shitty behavors of the primitive generator
                if (MyActor.radius > 0) {
                    ActorRadius = MyActor.radius;
                } else {
                    ActorRadius = 0.1;
                }

                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateSphere("MyCDSDynshape" + PhysManager.getObjectCount().toString(), currentScale * ActorRadius);

            } else if (MyActor instanceof STU.ConeActor) {

                // A cone can be decompose by a cynlinder and a non symetric capsule 
                // Create a Compound composed of 2 Shapes
                // IBS CHECK MLK CDSDynshape OK
                CDSDynshape = PhysManager.DynFactory.CreateCompound("MyConeCompound" + PhysManager.getObjectCount().toString(), 2);

                var ActorRadius = Math.abs(MyActor.radius);
                var ActorHeight = Math.abs(MyActor.height);
                var iQuaternion = [0, 0, 0, 1];

                // The radius of the lower demi-sphere is smaller that the radius of the cone. We compute the radius so the bottom of the demi-sphere is also the bottom of the cone
                var BottomRadiusCapsule = (ActorRadius * ActorHeight) / (ActorRadius + ActorHeight);

                // the Height of the capsule in CDSdyn is the distance between the 2 demi-sphere. In creative it's the total length.
                var capsuleHeight = ActorHeight - (ActorRadius);

                // The radius of the upper demi-sphere must be small but not null.
                var topRadius = 0.0001;

                var capsHeight = (currentScale * (((ActorHeight + ActorRadius) / 2))) + topRadius;

                // IBS CHECK MLK CDSDynCapsule OK
                var CDSDynCapsule = PhysManager.DynFactory.CreateCapsule("MyCDSDynshape" + PhysManager.getObjectCount().toString(), capsuleHeight / 2, currentScale * BottomRadiusCapsule, topRadius);

                // Set the position of the capsule relativly to the pivot point of the cone (dont forget to include the little offset to avoid the cone to rotate like a SpinTop)
                var iPositionCone = [0, 0, capsHeight - topRadius];

                CDSDynshape.AddPart(CDSDynCapsule, iPositionCone, iQuaternion, null);
                PhysManager.DynFactory.ReleaseObject(CDSDynCapsule); // IBS CHECK MLK ~CDSDynCapsule

                // -------------------------------------------------------------   

                // Make a cylinder to make the bottom of the cone flat
                var CylinderHeight = (currentScale * MyActor.height / 50);

                var iPositionCy = [0, 0, CylinderHeight];

                // IBS CHECK MLK CDSDynCylinder OK
                var CDSDynCylinder = PhysManager.DynFactory.CreateCylinder("MyCDSDynshape" + PhysManager.getObjectCount().toString(), CylinderHeight, currentScale * MyActor.radius);

                CDSDynshape.AddPart(CDSDynCylinder, iPositionCy, iQuaternion, null);
                PhysManager.DynFactory.ReleaseObject(CDSDynCylinder); // IBS CHECK MLK ~CDSDynCylinder

                // -------------------------------------------------------------   
            }
            else if (MyActor instanceof STU.Actor3D) {

                var GeomMode = MyActor._dynMeshGenerationParam_GeomMode;
                if (GeomMode === 2) {
                    // dynMeshNbMeshes
                    // dynMeshNbVerticesPerMesh
                    // dynMeshVertices
                    // dynMeshNbTrianglesPerMesh
                    // dynMeshTriangles
                    // _dynMeshScaling
                    var NbMeshes = MyActor._dynMeshNbMeshes;
                    var MeshesScale = MyActor._dynMeshScaling;
                    if (NbMeshes === 1) {
                        var CurrentVertex = 0;
                        var CurrentTriangle = 0;
                        var NbVertices = MyActor._dynMeshNbVerticesPerMesh[0];
                        var NbTriangles = MyActor._dynMeshNbTrianglesPerMesh[0];

                        var MeshVertices = [];
                        for (var iV = 0; iV < NbVertices; iV++) {
                            MeshVertices[3 * iV] = (MyActor._dynMeshVertices[3 * CurrentVertex]) * MeshesScale;
                            MeshVertices[3 * iV + 1] = (MyActor._dynMeshVertices[3 * CurrentVertex + 1]) * MeshesScale;
                            MeshVertices[3 * iV + 2] = (MyActor._dynMeshVertices[3 * CurrentVertex + 2]) * MeshesScale;
                            CurrentVertex++;
                        }

                        var MeshTriangles = [];
                        for (var iT = 0; iT < NbTriangles; iT++) {
                            MeshTriangles[3 * iT] = MyActor._dynMeshTriangles[3 * CurrentTriangle];
                            MeshTriangles[3 * iT + 1] = MyActor._dynMeshTriangles[3 * CurrentTriangle + 1];
                            MeshTriangles[3 * iT + 2] = MyActor._dynMeshTriangles[3 * CurrentTriangle + 2];
                            CurrentTriangle++;
                        }
                        // IBS CHECK MLK CDSDynshape OK
                        CDSDynshape = PhysManager.DynFactory.CreateMesh("MyCDSDynshape" + PhysManager.getObjectCount().toString(), NbVertices, NbTriangles, MeshVertices, MeshTriangles);
                    }
                    if (NbMeshes > 1) {
                        // IBS CHECK MLK CDSDynshape OK
                        CDSDynshape = PhysManager.DynFactory.CreateCompound("MyConeCompound" + PhysManager.getObjectCount().toString(), NbMeshes);

                        var CurrentMesh = 0;
                        var CurrentVertex = 0;
                        var CurrentTriangle = 0;
                        for (var iM = 0; iM < NbMeshes; iM++) {
                            var NbVertices = MyActor._dynMeshNbVerticesPerMesh[iM];
                            var NbTriangles = MyActor._dynMeshNbTrianglesPerMesh[iM];

                            var MeshVertices = [];
                            for (var iV = 0; iV < NbVertices; iV++) {
                                MeshVertices[3 * iV] = MyActor._dynMeshVertices[3 * CurrentVertex];
                                MeshVertices[3 * iV + 1] = MyActor._dynMeshVertices[3 * CurrentVertex + 1];
                                MeshVertices[3 * iV + 2] = MyActor._dynMeshVertices[3 * CurrentVertex + 2];
                                CurrentVertex++;
                            }

                            var MeshTriangles = [];
                            for (var iT = 0; iT < NbTriangles; iT++) {
                                MeshTriangles[3 * iT] = MyActor._dynMeshTriangles[3 * CurrentTriangle];
                                MeshTriangles[3 * iT + 1] = MyActor._dynMeshTriangles[3 * CurrentTriangle + 1];
                                MeshTriangles[3 * iT + 2] = MyActor._dynMeshTriangles[3 * CurrentTriangle + 2];
                                CurrentTriangle++;
                            }
                            // IBS CHECK MLK Mesh OK
                            var Mesh = PhysManager.DynFactory.CreateMesh("MyCDSDynshape" + PhysManager.getObjectCount().toString(), NbVertices, NbTriangles, MeshVertices, MeshTriangles);
                            Mesh.SetConvexVerified(true);

                            // all positions are included in vertices coordinates
                            var Position = [0, 0, 0];
                            var Quaternion = [0, 0, 0, 1];
                            CDSDynshape.AddPart(Mesh, Position, Quaternion, null);
                            PhysManager.DynFactory.ReleaseObject(Mesh); // IBS CHECK MLK ~Mesh
                        }//for (var iM 
                    }//if (NbMeshes > 1)

                }// if (GeomMode === 2)
                else {
                    var BoundingBox = new STU.Box();
                    // IBS TEST
                    if (MyActor._dynMeshBBox_XMin !== null && MyActor._dynMeshBBox_XMin !== undefined) {
                        BoundingBox.low.x = MyActor._dynMeshBBox_XMin;
                        BoundingBox.low.y = MyActor._dynMeshBBox_YMin;
                        BoundingBox.low.z = MyActor._dynMeshBBox_ZMin;
                        BoundingBox.high.x = MyActor._dynMeshBBox_XMax;
                        BoundingBox.high.y = MyActor._dynMeshBBox_YMax;
                        BoundingBox.high.z = MyActor._dynMeshBBox_ZMax;
                    }
                    else {
                        var absTransfo = MyActor.getTransform();
                        MyActor.StuIRepresentation.GetBoundingBox(BoundingBox, absTransfo, 1); // local
                    }

                    var xdim = 0.5 * (BoundingBox.high.x - BoundingBox.low.x);
                    var ydim = 0.5 * (BoundingBox.high.y - BoundingBox.low.y);
                    var zdim = 0.5 * (BoundingBox.high.z - BoundingBox.low.z);

                    // IBS CHECK MLK CDSDynshape OK
                    CDSDynshape = PhysManager.DynFactory.CreateBox("MyCDSDynshape" + PhysManager.getObjectCount().toString(), xdim, ydim, zdim);

                    // la position de la box dans le referrentiel de l'acteur :
                    var PosBoundingBox_Local = new DSMath.Vector3D();
                    PosBoundingBox_Local.x = 0.5 * (BoundingBox.high.x + BoundingBox.low.x);
                    PosBoundingBox_Local.y = 0.5 * (BoundingBox.high.y + BoundingBox.low.y);
                    PosBoundingBox_Local.z = 0.5 * (BoundingBox.high.z + BoundingBox.low.z);

                    // we store the position of the actor in the bounding element local coord
                    this._BB_Local_Coord = DSMath.Vector3D.negate(PosBoundingBox_Local);
                }
            }//else if (MyActor instanceof STU.Actor3D) {

            this.VolumicMass = 0.000001 * this.Density;

            // Compute Mass and Inertia of the Shape
            // -------------------------------------
            //var myInertiaComputer = CDSDynCreateInertiaComputer(CDSDynshape, this.VolumicMass);
            var myInertiaComputer = StuCDSDynFactory.buildCDSDynInertiaComputer(CDSDynshape, this.VolumicMass);     // IBS CHECK MLK myInertiaComputer OK
            myInertiaComputer.Run();

            var mass = myInertiaComputer.GetMass();
            var inertia = myInertiaComputer.GetPrincipalInertia();
            var CoG = myInertiaComputer.GetCoG();

            // IBS CHECK MLK CurrentInertia OK
            var CurrentInertia = PhysManager.DynFactory.CreateInertia("MyInertia" + PhysManager.getObjectCount().toString());

            CurrentInertia.SetMass(mass);
            CurrentInertia.SetInertia(inertia.oInertia, inertia.oInertiaOrientation);
            CurrentInertia.SetCenterOfGravity(CoG.oCoG[0], CoG.oCoG[1], CoG.oCoG[2]);
            //myInertiaComputer.ApplyToInertiaObject(CurrentInertia);

            // Store the mass and the inertia
            this.mass = mass;
            this.inertia = inertia;
            //CDSDynRemoveInertiaComputer(myInertiaComputer);
            StuCDSDynFactory.removeCDSDynInertiaComputer(myInertiaComputer);          // IBS CHECK MLK ~myInertiaComputer

            // Create the Rigid object
            // -----------------------
            // IBS CHECK MLK CDSDynRigidBody OK

            // IBS TEST PolyhedralClashEngine
            if (null !== CDSDynshapeFromRepStream) {
                this.CDSDynRigidBody = PhysManager.DynFactory.CreateRigidBody("MyCDSDynRigidBody" + PhysManager.getObjectCount().toString(), CDSDynshapeFromRepStream, null, CurrentInertia);
                PhysManager.DynFactory.ReleaseObject(CDSDynshapeFromRepStream);  // IBS CHECK MLK ~CDSDynshapeFromRepStream
            }
            else {
                this.CDSDynRigidBody = PhysManager.DynFactory.CreateRigidBody("MyCDSDynRigidBody" + PhysManager.getObjectCount().toString(), CDSDynshape, null, CurrentInertia);
            }

            PhysManager.DynFactory.ReleaseObject(CDSDynshape);  // IBS CHECK MLK ~CDSDynshape   
            PhysManager.DynFactory.ReleaseObject(CurrentInertia);  // IBS CHECK MLK ~CurrentInertia

            // Set dynamic properties
            if (this.MotionType === 1) {
                // MotionType = 1 -> the rigid is fixed
                this.CDSDynRigidBody.SetFixed(1);
            }

            // Set the pos of the rigid object
            this.updateRigidPos();

            // TEST : do not deactivate the rigid
            this.CDSDynRigidBody.EnableAutomaticDeactivation(false);

            // Register the rigidbody into the solver
            PhysManager.DynSolver.AddRigidBody(this.CDSDynRigidBody, 1);

            // CreateMaterial (CATReal iRestitutionCoeff=0.5f, CATReal iFrictionCoeff=0.4f, CDSDynHRESULT *oDiag=NULL, CATBoolean iEnableRestitutionCoeffGreaterThanOne=FALSE)
            var CDSDynMaterial = PhysManager.DynFactory.CreateMaterial("MyCDSDynMaterial" + PhysManager.getObjectCount().toString(), this.Restitution, this.Friction, 0);
            this.CDSDynRigidBody.SetMaterial(CDSDynMaterial);
            PhysManager.DynFactory.ReleaseObject(CDSDynMaterial); // IBS CHECK MLK CDSDynMaterial

            // Set the same value for linear and angular damping        
            //this.CDSDynRigidBody.SetLinearDamping(this.Damping); // we keep default cdsdyn values for now  
            this.CDSDynRigidBody.SetAngularDamping(this.Damping);

            // Register the RigidBody into the PhysManager
            PhysManager.registerRigidBody(this);

            // The Rigid object is now initialyzed and ready to used (i.e. ready to be used to create a Joint)
            this._isInit = true;
        };




        RigidBody.prototype.onDeactivate = function () {
            //Will be called on experience stop.
            console.debug("RigidBody onDeactivate");

            //var PhysManager = STU.PhysicManager.getInstance();
            // PhysManager.DynFactory.ReleaseObject(this.CDSDynRigidBody);  // IBS CHECK MLK CDSDynRigidBody

            // save CDSDynRigidBody velocities
            this.LinVelAtDeactivate = this.CDSDynRigidBody.GetLinearVelocity();
            this.AngVelAtDeactivate = this.CDSDynRigidBody.GetAngularVelocity();

            // store object outside of physical world boundaries
            var PhysManager = STU.PhysicManager.getInstance();
            this.CDSDynRigidBody.SetOrigin(2 * PhysManager.worldSize.x + Math.random() * PhysManager.worldSize.x, 2 * PhysManager.worldSize.y + Math.random() * PhysManager.worldSize.y, 2 * PhysManager.worldSize.z + Math.random() * PhysManager.worldSize.z);

            // deactivate
            this.RigidBodyActivated = false;
        };

        /**
         * Return rigid objects
         * to be used only by other Physic Behaviors (like Joins)
         *
         * @private
         * @return  {Object}
         */
        RigidBody.prototype.getRigidObject = function () {

            // Initialize the Rigid object if it's not ready to use
            if (this._isInit === false) {
                this.buildCDSDynRigidBody();
            }

            // Return the CDSDyn object
            return this.CDSDynRigidBody;
        };

        /**
         * Apply an impulse to push or pull the Actor3D (an impulse is a punctual force)
         *
         * @public
         * @param   {DSMath.Vector3D} iApplyOn Space point location where the force will be applied
         * @param   {DSMath.Vector3D} iForceVector Force vector
         * @param   {Number} iForceFactor Force factor
         */
        RigidBody.prototype.addImpulse = function (iApplyOn, iForceVector, iForceFactor) {

            iForceFactor = (typeof iForceFactor === 'undefined') ? 1 : iForceFactor;

            var PhysManager = STU.PhysicManager.getInstance();

            var iCoordarray = [iApplyOn.x, iApplyOn.y, iApplyOn.z];

            var iImpulseVectorarray = [iForceVector.x * iForceFactor, iForceVector.y * iForceFactor, iForceVector.z * iForceFactor];

            PhysManager.DynSolver.AddImpulse(this.CDSDynRigidBody, iCoordarray, iImpulseVectorarray, 1);

        };

        /**
         * Add a force at a specific point in space
         *
         * @public
         * @param   {DSMath.Vector3D} iApplyOn Space point location where the force will be applied
         * @param   {DSMath.Vector3D} iForceVector Force vector
         * @param   {Number} iForceFactor Force factor
         */
        RigidBody.prototype.addForce = function (iApplyOn, iForceVector, iForceFactor) {

            // Une force à la fois pour le moment
            this.removeForce();

            var PhysManager = STU.PhysicManager.getInstance();
            this._force = PhysManager.DynFactory.CreateForce("MyDyn_force", this.CDSDynRigidBody);  // IBS CHECK MLK _force OK

            // On set l'origine de la force
            this._force.SetApplicationPoint(iApplyOn.x, iApplyOn.y, iApplyOn.z, 0);
            // on set le vecteur en ref World
            this._force.SetForceComponent(iForceVector.x * iForceFactor, iForceVector.y * iForceFactor, iForceVector.z * iForceFactor, 0);
            this._force.SetTorqueComponent(0, 0, 0, 0);

            PhysManager.DynSolver.AddForce(this._force);
        };

        /**
         * Remove the force added with addForce
         * @public
         */
        RigidBody.prototype.removeForce = function () {
            if (this._force !== null) {
                var PhysManager = STU.PhysicManager.getInstance();
                PhysManager.DynSolver.RemoveForce(this._force);
                PhysManager.DynFactory.ReleaseObject(this._force);  // IBS CHECK MLK ~_force
                this._force = null;
            }
        };


        /**
         * Set the actor position and synchronize the physic engine
         * @public
         * @param   {DSMath.Vector3D} iPosition
         */
        RigidBody.prototype.setPhysicPos = function (iPosition) {
            // ----------------------------------------------------
            //  Creative Behavior ---> CDSDyn rigid body & Actor 3D
            // ----------------------------------------------------
            var MyActor = this.MyActor;

            // Set the Actor's Position
            MyActor.setPosition(iPosition);

            // Set the RigidBody position
            this.updateRigidPos();

            // Reset the inertia
            this.CDSDynRigidBody.SetLinearVelocity(0, 0, 0);
            this.CDSDynRigidBody.SetAngularVelocity(0, 0, 0);
        };


        // ------------------------------
        //  Actor  ---> CDSDyn Rigid body
        // ------------------------------

        /**
         * Take the Pos of actor and apply it on the rigid object
         * @private
         */
        RigidBody.prototype.updateRigidPos = function () {
            if (this.RigidBodyActivated === false) {
                return;
            }

            var pos = this.computeRigidPosBasedOnActor();

            // Set the origin Position and orientation of the Rigid Object
            this.CDSDynRigidBody.SetOrigin(pos.position.x, pos.position.y, pos.position.z);
            this.CDSDynRigidBody.SetOrientation(pos.arrayOfCoord);
        };

        /**
         * Take the Pos of actor and try to apply it on the rigid object by using the keyframed controler
         * Note: The physic solver must be called after the behaviors in order to take in account the new position setted by those behaviors
         * 
         * @private
         */
        RigidBody.prototype.keyframed = function () {
            if (this.MotionType === 2) {
                var PhysManager = STU.PhysicManager.getInstance();
                var KeyframedController_1 = PhysManager.DynSolver.GetKeyframedController("KeyframedController_1");

                var pos = this.computeRigidPosBasedOnActor();

                var PosArray = [pos.position.x, pos.position.y, pos.position.z];

                // TryMoveToPositionAndOrientation( Rigid, Pos, Quat, iOverrideExistingKFRequest, iMaxForce , iMaxTorque)
                var resu = KeyframedController_1.TryMoveToPositionAndOrientation(this.CDSDynRigidBody, PosArray, pos.arrayOfCoord, 1, this._keyframedMaxForce, this._keyframedMaxTorque);
            }
        };


        /**
         * Compute the position of the rigid object (could be different from the pivot point of the actor) and his quaternion
         * @private
         */
        RigidBody.prototype.computeRigidPosBasedOnActor = function () {

            var obj_out = {
                position: 0,
                arrayOfCoord: 0
            };

            var MyActor = this.MyActor;

            var currentScale = MyActor.getScale();
            var coefScale = 1.0 / currentScale;

            var transformMyActor = MyActor.getTransform(); //DSMath.Transformation();

            var actorPos = MyActor.getPosition();

            if (this._BB_Local_Coord !== null) {

                // IBS : la BBox prend en compte le scaling de l'actor
                // ici on ne veut que les composantes de rotation/translation de l'actor
                // du coup je vire la composante scaling (on suppose le scaling uniforme)
                // voir commentaires SCALING en tête du fichier
                var point1 = new DSMath.Point();
                //var scaleParam = { center: point1, scale: coefScale, isScaling: 1 };
                var invScaling = new DSMath.Transformation();
                invScaling.makeScaling(coefScale, point1);//Deprecated: invScaling.setScaling(scaleParam);
                transformMyActor.multiply(invScaling);

                // compute the position Offset if the pivot point of the actor is not equal to the pivot point of the physic object
                var bb_local_clone = this._BB_Local_Coord.clone();
                var actorLocal = bb_local_clone.applyTransformation(transformMyActor);//transformMyActor.applyToVector(this._BB_Local_Coord);

                // the position of the actor is the sum of the World Pos of the BB and the relative local Pos of the actor 
                obj_out.position = DSMath.Vector3D.sub(actorPos, actorLocal);

            } else {

                obj_out.position = actorPos;
            }

            // Le rigid body doit etre placé au centre de la bounding sphere
            // On part du principe que le quaterion de l'acteur est le meme que celui de la bounding sphere

            // remove the scaling component of the matrix
            var matrix3x3 = transformMyActor.matrix;
            var coefMatrix3x3 = matrix3x3.getArray();
            for (var i = 0; i < coefMatrix3x3.length; i++) {
                coefMatrix3x3[i] *= coefScale;
            }

            // Now we have a pure rotation matrix
            matrix3x3.setFromArray(coefMatrix3x3);

            var q1 = new DSMath.Quaternion();
            matrix3x3.getQuaternion(q1);

            // Get the 4 parameters of the Quaterion
            obj_out.arrayOfCoord = q1.getArray(0);

            return obj_out;
        };

        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.isDynamic = function () { return this.MotionType == 0; };
        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.isFixed = function () { return this.MotionType == 1; };
        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.isDriven = function () { return this.MotionType == 2; };
        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.becomesDynamic = function () { this.MotionType = 0 };
        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.becomesFixed = function () { this.MotionType = 1 };
        /**
         * @private
         * @return {Boolean}
         */
        RigidBody.prototype.becomesDriven = function () { this.MotionType = 2 };

        /**
         * Take the Pos of the rigide object and apply it on the actor
         * @private
         */
        RigidBody.prototype.updateNode3D = function () {
            // Do not update the Actor if the Rigid is unactive / fixed
            if (this.CDSDynRigidBody.IsActive() === false) {
                return;
            }
            if (this.RigidBodyActivated === false) {
                return;
            }

            if (this.MotionType !== 1) {
                // Get the actor
                var MyActor = this.MyActor;

                // Update the Orientation of the 3D Actor
                // --------------------------------------

                // Get the cdsdynQuaterion 
                var rotQuat = this.CDSDynRigidBody.GetOrientation();

                // Create a quaterion based on our mathematic framework
                var q1 = new DSMath.Quaternion();
                q1.setFromArray(rotQuat.oOrientationQuaternion, 0);

                // Get the matix from the quaterion
                var RotMatrix = q1.getMatrix();

                // create a Transform operator
                var transformMyActor = new DSMath.Transformation();
                transformMyActor.matrix = RotMatrix;

                // Get the Euler Angles (in an array)
                var eulerangle = transformMyActor.getEuler();

                // Create a vector and set the angle
                var EulerRot = new DSMath.Vector3D();

                // swap the axe for some reason
                EulerRot.x = eulerangle[1];
                EulerRot.y = eulerangle[2];
                EulerRot.z = eulerangle[0];

                // Set the Euler rotation
                MyActor.setRotation(EulerRot);


                // Update the Position of the 3DActor
                // ----------------------------------

                // Get the CDSdyn position of the RigidBody
                var origine = this.CDSDynRigidBody.GetOrigin();

                // transform the array into a Vector3D object
                var posRigid = new DSMath.Vector3D();
                posRigid.x = origine.oX;
                posRigid.y = origine.oY;
                posRigid.z = origine.oZ;

                var posActor = new DSMath.Vector3D();

                if (this._BB_Local_Coord !== null) {
                    // Here we know where is the Bounding element of the actor and we need to compute his position
                    // We have the position of the actor in the relative local space of the Bounding element and we want to apply the new orientation of the BB

                    // Create the Mathematics.Transformation based on the actor scaling and rotation matrix of the rigid
                    var BBTransforme = new DSMath.Transformation();
                    BBTransforme.matrix = RotMatrix;

                    // IBS : le scale est géré ailleurs, voir commentaires SCALING en tête du fichier
                    //var scaleParam = {
                    //    center: posRigid,
                    //    scale: MyActor.getScale(),
                    //    isScaling: 1.
                    //};
                    //BBTransforme.setScaling(scaleParam);
                    var bb_local_clone = this._BB_Local_Coord.clone();
                    var actorLocal = bb_local_clone.applyTransformation(BBTransforme);

                    // the position of the actor is the sum of the World Pos of the BB and the relative local Pos of the actor 
                    posActor = DSMath.Vector3D.add(posRigid, actorLocal);

                } else {
                    posActor = posRigid;
                }

                // Set the Actor's Position
                MyActor.setPosition(posActor);
            }
        };

        // Expose in STU namespace.
        STU.RigidBody = RigidBody;
        return RigidBody;

    });

define('StuPhysic/StuPhysicRigidBody', ['DS/StuPhysic/StuPhysicRigidBody'], function (RigidBody) {
    'use strict';

    return RigidBody;
});
