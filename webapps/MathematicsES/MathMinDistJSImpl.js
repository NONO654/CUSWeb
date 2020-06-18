//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript pt - curve minimum distance utility operator
//===================================================================
// 22/11/18 Q48 Creation
// 20/12/18 Q48 Choice of function to minimise (_FX)
// 20/12/18 Q48 Add debug (_DEBUG)
// 24/01/19 Q48 Tolerance consistency
// 06/02/19 Q48 Check validity of derivatives to stop solver
// 14/02/19 Q48 Move current code to MathMinDistPtCrvJSImpl
// 14/02/19 Q48 Re-use this operator to be a "parent" min-dist operator
//===================================================================

define('MathematicsES/MathMinDistJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathDebugUtils',
   'MathematicsES/MathMinDistPtCrvJSImpl',
   'MathematicsES/MathMinDistCrvCrvJSImpl',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathPoint2DJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathCircleJSImpl',
   'MathematicsES/MathEllipseJSImpl',
   'MathematicsES/MathNurbsCurveJSImpl'
  ],

  function (DSMath, TypeCheck, TypeCheckInternal, DebugUtils, MinDistPtCrv, MinDistCrvCrv, Point, Point2D, Vector3D, Line, Circle, Ellipse, NurbsCurve)
  {
    'use strict';
    
    /**
    * @private
    * @typedef Geometry
    * @type Object
    * @property {DSMath.Point | DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve} _Geometry The geometry object
    * @property {Number[]} _Range The limits of the geometry (if a curve)
    */

    /**
    * @private
    * @exports MinDist
    * @class
    * @classdesc Utlity class to compute the minimum distance between two geometries (point - curve or curve - curve)
    *
    * @constructor
    * @constructordesc
    * The DSMath.MinDist constructor creates a min-dist object from two Geometry objects
    * @param {Geometry} iGeometry1 The first geometry (point or curve)
    * @param {Geometry} iGeometry2 The second geometry (point or curve)
    * @memberof DSMath
    */

    var MinDist = function (iGeometry1, iGeometry2)
    {
      DSMath.TypeCheck(iGeometry1, true, Object);
      DSMath.TypeCheck(iGeometry2, true, Object);
      DSMath.TypeCheck(iGeometry1._Geometry, true, DSMath.Point | DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve);
      DSMath.TypeCheck(iGeometry1._Range, false, ['number']);
      DSMath.TypeCheck(iGeometry2._Geometry, true, DSMath.Point | DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve);
      DSMath.TypeCheck(iGeometry2._Range, false, ['number']);

      // Attributes
      // -------------------------------------

      this.Geometry1 = iGeometry1;
      this.Geometry2 = iGeometry2;

      // Internal methods
      // -------------------------------------

      this.IsValidPoint = function (iGeometry)
      {
        DSMath.TypeCheckInternal(iGeometry, true, Object);

       if (iGeometry._Geometry.constructor == DSMath.Point)
         return true;

        return false;
      }

      this.IsValidCurve = function (iGeometry)
      {
        DSMath.TypeCheckInternal(iGeometry, true, Object);

        var isCurve = false;
       if (iGeometry._Geometry.constructor == DSMath.Line)
         isCurve = true;

       if (iGeometry._Geometry.constructor == DSMath.Circle)
         isCurve = true;

       if (iGeometry._Geometry.constructor == DSMath.Ellipse)
         isCurve = true;

       if (iGeometry._Geometry.constructor == DSMath.NurbsCurve)
         isCurve = true;

        if (isCurve && iGeometry._Range != undefined)
          return true;

        return false;
      }

      // ---------------------------------------------------------------------------------
      // DEBUG
      // ---------------------------------------------------------------------------------
      //this._DEBUG = 0;
      //this._DEBUG = null;
      this._DEBUG = new DSMath.DebugUtils();

      this._FX = 0; // evaluation option (changes "target" function to be minimised)
    };

    // ---------------------------------------------------------------------------------
    // Data members
    // ---------------------------------------------------------------------------------

    MinDist.prototype.Geometry1 = null;
    MinDist.prototype.Geometry2 = null;

    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    // ---------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------
    
    /**
    * @private
    * @memberof DSMath.MinDist
    * @method UpdateGeometry
    * @instance
    * @description
    * Update one of the input geometries
    * @param {Number} [0 or 1] The index of the new geometry
    * @param {Geoemtry} The new geometry to set
    * @example
    * var e0 = new DSMath.Ellipse(50.0, 5.0).setCenter(0.0, 0.0, 0.0).setVectors(1,0,0, 0,1,0);
    * var geomEllipse = { _Geometry : e0, _Range : [0.0, DSMath.constants.PI2] };
    * var geomTarget = { _Geometry : new DSMath.Point(10.0, 0.0, 0.0) };
    * var m0 = new DSMath.MinDist(geomEllipse, geomTarget);
    * var geomTarget2 = { _Geometry : new DSMath.Point(60.0, 0.0, 0.0) };
    * m0.UpdateGeometry(1, geomTarget2);
    * var sol = m0.Run(); // sol = 0.0;
    * @returns {Boolean} The curve parameter corresponding to the point of minimum distance
    */
    MinDist.prototype.UpdateGeometry = function (iIndex, iGeometry)
    {
      DSMath.TypeCheck(iIndex, true, 'number');
      DSMath.TypeCheck(iGeometry, true, Object);

      if (iIndex === 0)
      {
        this.Geometry1 = iGeometry;
        return true;
      }

      if (iIndex === 1)
      {
        this.Geometry2 = iGeometry;
        return true;
      }

      return false;
    };

    /**
    * @private
    * @memberof DSMath.MinDist
    * @method Run
    * @instance
    * @description
    * Runs the relevant minimum distance operator
    * @param {Number | DSMath.Point2D} [iT] An init points to start from
    * @example
    * var e0 = new DSMath.Ellipse(50.0, 5.0).setCenter(0.0, 0.0, 0.0).setVectors(1,0,0, 0,1,0);
    * var geomEllipse = { _Geometry : e0, _Range : [0.0, DSMath.constants.PI2] };
    * var geomTarget = { _Geometry : new DSMath.Point(60.0, 0.0, 0.0) };
    * var m0 = new DSMath.MinDist(geomEllipse, geomTarget); 
    * var sol = m0.Run(); // sol = 0.0;
    * @returns {Number | DSMath.Point2D} The curve parameter(s) corresponding to the point of minimum distance
    */
    MinDist.prototype.Run = function (iT)
    {
      DSMath.TypeCheck(iT, false, ['number', DSMath.Point2D]);

      if (this._DEBUG.IsActive(1))
        console.log("MinDist::Run between " + this._DEBUG.PrintType(this.Geometry1._Geometry) + " and " + this._DEBUG.PrintType(this.Geometry2._Geometry));

      // Point <-> Curve
      // ---------------

      if (this.IsValidPoint(this.Geometry1) && this.IsValidCurve(this.Geometry2))
      {
        var minDistPtCrv = new DSMath.MinDistPtCrv(this.Geometry2._Geometry, this.Geometry2._Range, this.Geometry1._Geometry);
        
        minDistPtCrv._DEBUG._LEVEL = this._DEBUG._LEVEL;
        if (this._FX)
          minDistPtCrv._FX = this._FX;

        var oSol = minDistPtCrv.Run(iT);
        
        if (this._DEBUG.IsActive(1))
          console.log("MinDist::Run returning " + oSol);
        
        return oSol;
      }

      // Curve <-> Point
      // ---------------

      if (this.IsValidCurve(this.Geometry1) && this.IsValidPoint(this.Geometry2))
      {
        var minDistPtCrv = new DSMath.MinDistPtCrv(this.Geometry1._Geometry, this.Geometry1._Range, this.Geometry2._Geometry);
        
        minDistPtCrv._DEBUG = this._DEBUG;
        if (this._FX)
          minDistPtCrv._FX = this._FX;

        var oSol = minDistPtCrv.Run(iT);

        if (this._DEBUG.IsActive(1))
          console.log("MinDist::Run returning " + oSol);

        return oSol;
      }

      // Curve <-> Curve
      // ---------------

      if (this.IsValidCurve(this.Geometry1) && this.IsValidCurve(this.Geometry2))
      {
        var minDistCrvCrv = new DSMath.MinDistCrvCrv(this.Geometry1._Geometry, this.Geometry1._Range, this.Geometry2._Geometry, this.Geometry2._Range);

        minDistCrvCrv._DEBUG = this._DEBUG;

        var oSol = minDistCrvCrv.Run(iT);

        if (this._DEBUG.IsActive(1))
          console.log("MinDist::Run returning " + oSol.getArray());

        return oSol;
      }

      return false;
    };

    DSMath.MinDist = MinDist;

    return MinDist;
  }
);
