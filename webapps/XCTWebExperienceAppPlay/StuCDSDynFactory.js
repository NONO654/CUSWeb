define('DS/XCTWebExperienceAppPlay/StuCDSDynFactory', ['DS/StuPhysic/StuCDSDynFactory'], function (StuCDSDynFactory) {
    'use strict';

    StuCDSDynFactory.buildCDSDynFactory = function () {
        return {
            CreateBox: function () { },
            CreateForce: function () {
                return {
                     SetApplicationPoint: function () { },
                     SetForceComponent: function () { },
                     SetTorqueComponent: function () { }
                };
            },
            CreateMaterial: function () { },
            CreateRigidBody: function () {
                return {
                     SetOrigin: function () { },
                     SetOrientation: function () { },
                     EnableAutomaticDeactivation: function () { },
                     SetMaterial: function () { },
                     SetAngularDamping: function () { },
                     SetLinearVelocity: function () { },
                     SetAngularVelocity: function () { }
                };
            },
            ReleaseObject: function () { },
            CreateInertia: function () {
                 return {
                     SetMass: function () { },
                     SetInertia: function () { },
                     SetCenterOfGravity: function () { }
                 };
            },
            CreateSolverConfig: function () { },
            CreateSolver: function () {
                return {
                    SetWorld: function () { },
                    AddRigidBody: function () { },
                    AddImpulse: function () { },
                    AddForce: function () { },
                    RemoveForce: function () { }
                };
            },
            CreateWorld: function () {
                return {
                    SetSize: function () { },
                    SetGravity: function () { },
                };
            },
        };
    };

    StuCDSDynFactory.buildCDSDynInertiaComputer = function (shape, volumicMass) {
        return {
            Run: function () { this.usedVar = volumicMass;},
            GetMass: function () { },
            GetPrincipalInertia: function () {
                return {
                    oInertia: null,
                    oInertiaOrientation: null
                };
            },
            GetCoG: function () {
                return {
                    oCoG: [null, null, null]
                };
            }
        };
    };

    StuCDSDynFactory.removeCDSDynInertiaComputer = function (inertiaComputer) {
        this.usedVar = inertiaComputer;
    };
});
