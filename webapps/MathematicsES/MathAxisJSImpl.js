define('MathematicsES/MathAxisJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathPointJSImpl'
  ],
  
  function (DSMath, TypeCheck, Vector3D, Point)
  {
    'use strict';

    /**
    * @public
    * @exports Axis
    * @class
    * @classdesc Representation of an Axis.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Axis constructor creates an Axis in 3D, which is represented by an origin and three orthonormalized vector.
    * <br>
    * By default, the created axis is the (0,x,y,z) axis.
    * @param {DSMath.Point}    [iO=(0,0,0)]  The axis origin.
    * @param {DSMath.Vector3D} [iD1=(1,0,0)] The first  axis vector.
    * @param {DSMath.Vector3D} [iD2=(0,1,0)] The second axis vector.
    * @param {DSMath.Vector3D} [iD3=(0,0,1)] The third  axis vector.
    * @memberof DSMath
    */
    var Axis = function (iO, iD1, iD2, iD3)
    {
      DSMath.TypeCheck(iO, false, DSMath.Point);
      DSMath.TypeCheck(iD1, false, DSMath.Vector3D);
      DSMath.TypeCheck(iD2, false, DSMath.Vector3D);
      DSMath.TypeCheck(iD3, false, DSMath.Vector3D);

      this.origin = (iO) ? iO.clone() : new Point(0, 0, 0);

      var dir = new Array(3);
      dir[0] = (iD1) ? iD1.clone() : new Vector3D(1, 0, 0);
      dir[1] = (iD2) ? iD2.clone() : new Vector3D(0, 1, 0);
      dir[2] = (iD3) ? iD3.clone() : new Vector3D(0, 0, 1);

      /** @nodoc */
      this.getDirectionsNotCloned = function ()
      {
        return dir;
      };
    };

    /**
    * The origin property of an axis.
    * @member
    * @instance
    * @name origin
    * @public
    * @type { DSMath.Point }
    * @memberOf DSMath.Axis
    */
    Axis.prototype.origin = null;

    /**
    * @public
    * @memberof DSMath.Axis
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> axis.
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var a1 = a0.clone(); // a1==a0 but a1!==a0
    * @returns {DSMath.Axis} The cloned axis.
    */
    Axis.prototype.clone = function ()
    {
      return new Axis().copy(this);
    };

    /**
    * @public
    * @memberof DSMath.Axis
    * @method copy
    * @instance
    * @description
    * Copies the given Axis.
    * @param {DSMath.Axis} iA The axis to copy.
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var a1 = new DSMath.Axis();
    * var a2 = a1.copy(a0); // a2===a1 and a2==a0 but a2!==a0
    * @returns {DSMath.Axis} <i>this</i> modified axis reference.
    */
    Axis.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Axis);

      var dir = this.getDirectionsNotCloned();
      var dirToCopy = iToCopy.getDirectionsNotCloned();
      dir[0].copy(dirToCopy[0]);
      dir[1].copy(dirToCopy[1]);
      dir[2].copy(dirToCopy[2]);

      this.origin.copy(iToCopy.origin);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Axis
    * @method setOrigin
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> axis origin.
    * @param {Number | DSMath.Point} iX Value for the x coordinate or the point to copy.
    * @param {Number} [iY=0] Value for the y coordinate. Not used if iX is a Point.
    * @param {Number} [iZ=0] Value for the z coordinate. Not used if iX is a Point.
    * @example
    * var a0 = new DSMath.Axis().setOrigin(1,2,3); // a0.origin=[1,2,3]
    * var p0 = new DSMath.Point(1,1,1);
    * a0.setOrigin(p0);                             // a0.origin=[1,1,1] (copy of p0).
    * p0.set(0,0,0);                                // a0.origin=[1,1,1]
    * @returns {DSMath.Axis} <i>this</i> modified axis reference.
    */
    Axis.prototype.setOrigin = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Point]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      if (iX.constructor === Point)
        this.origin.copy(iX);
      else
        this.origin.set(iX, iY || 0, iZ || 0);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Axis
    * @method setVectors
    * @instance
    * @description
    * Assigns new directions to <i>this</i> axis.
    * @param {DSMath.Vector3D} iV1 The first vector.
    * @param {DSMath.Vector3D} iV2 The second vector.
    * @param {DSMath.Vector3D} iV3 The third vector.
    * @example
    * var v0 = new DSMath.Vector3D( 1,1,0);
    * var v1 = new DSMath.Vector3D(-1,1,0);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3) // a0.origin=(1,2,3)
    * var a1 = a0.setVectors(v0,v1,DSMath.Vector3D.zVect); // a1===a0
    * var dir = a1.getDirections(); // dir[0]=(1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0) and dir[2]=(0,0,1)
    * @returns {DSMath.Axis} <i>this</i> modified axis reference.
    */
    Axis.prototype.setVectors = function (iV1, iV2, iV3)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV3, true, DSMath.Vector3D);

      var dir = this.getDirectionsNotCloned();
      dir[0].copy(iV1);
      dir[1].copy(iV2);
      dir[2].copy(iV3);
      Vector3D.orthoNormalize(dir[0], dir[1], dir[2]);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Axis
    * @method setVectorsFromMatrix
    * @instance
    * @description
    * Assigns new directions to <i>this</i> axis from a given matrix.
    * <br>
    * The matrix column vectors are orthonormalized to create the axis (first column vector normalized then we change the other to have the orthogonality).
    * <br>
    * The matrix column vector shall no be coplanar. In such case, the missing vector information is determined by a default behavior.
    * @param {DSMath.Matrix3x3} iM The matrix.
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var dir = a0.getDirections(); // dir[0]=(0,1,0) and dir[1]=(-1,0,0) and dir[2]=(0,0,1)
    * @returns {DSMath.Axis} <i>this</i> modified axis reference.
    */
    Axis.prototype.setVectorsFromMatrix = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);

      var dir = this.getDirectionsNotCloned();
      iM.getFirstColumn(dir[0]);
      iM.getSecondColumn(dir[1]);
      iM.getThirdColumn(dir[2]);
      Vector3D.orthoNormalize(dir[0], dir[1], dir[2]);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Axis
    * @method getDirections
    * @instance
    * @description
    * Retrieves the directions of <i>this</i> axis.
    * @param {DSMath.Vector3D[]} [oD] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var dir = a0.getDirections(); //dir[0]=(0,1,0) and dir[1]=(-1,0,0) and dir[2]=(0,0,1)
    * @returns {DSMath.Vector3D[]} The reference of the operation result - The three cloned directions.
    */
    Axis.prototype.getDirections = function (oD)
    {
      DSMath.TypeCheck(oD, false, [DSMath.Vector3D], 3);

      var dir = this.getDirectionsNotCloned();
      if (!oD)
        return new Array(dir[0].clone(), dir[1].clone(), dir[2].clone());
      else
      {
        oD[0].copy(dir[0]);
        oD[1].copy(dir[1]);
        oD[2].copy(dir[2]);
        return oD;
      }
    }

    /**
    * @public
    * @memberof DSMath.Axis
    * @method getFirstDirection
    * @instance
    * @description
    * Retrieves the first direction of <i>this</i> axis.
    * @param {DSMath.Vector3D} [oD1] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var dir1 = a0.getFirstDirection(); // dir[0]=(0,1,0)
    * @returns {DSMath.Vector3D} The reference of the operation result - The first cloned direction.
    */
    Axis.prototype.getFirstDirection = function (oD1)
    {
      DSMath.TypeCheck(oD1, false, DSMath.Vector3D);

      var dir = this.getDirectionsNotCloned();
      oD1 = (oD1) ? oD1.copy(dir[0]) : dir[0].clone();
      return oD1;
    }

    /**
    * @public
    * @memberof DSMath.Axis
    * @method getSecondDirection
    * @instance
    * @description
    * Retrieves the second direction of <i>this</i> axis.
    * @param {DSMath.Vector3D} [oD2] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var dir2 = a0.getSecondDirection(); // dir[1]=(-1,0,0)
    * @returns {DSMath.Vector3D} The reference of the operation result - The second cloned direction.
    */
    Axis.prototype.getSecondDirection = function (oD2)
    {
      DSMath.TypeCheck(oD2, false, DSMath.Vector3D);

      var dir = this.getDirectionsNotCloned();
      oD2 = (oD2) ? oD2.copy(dir[1]) : dir[1].clone();
      return oD2;
    }

    /**
    * @public
    * @memberof DSMath.Axis
    * @method getThirdDirection
    * @instance
    * @description
    * Retrieves the third direction of <i>this</i> axis.
    * @param {DSMath.Vector3D} [oD3] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
    * var dir2 = a0.getThirdDirection(); // dir[2]=(0,0,1)
    * @returns {DSMath.Vector3D} The reference of the operation result - The third cloned direction.
    */
    Axis.prototype.getThirdDirection = function (oD3)
    {
      DSMath.TypeCheck(oD3, false, DSMath.Vector3D);

      var dir = this.getDirectionsNotCloned();
      oD3 = (oD3) ? oD3.copy(dir[2]) : dir[2].clone();
      return oD3;
    }

    /**
    * @public
    * @memberof DSMath.Axis
    * @method applyTransformation
    * @instance
    * @description
    * Transforms <i>this</i> axis by applying the given transformation on its origins and the directions.
    * <br>
    * The transformation has to be reversible.
    * @param {DSMath.Transformation} iT The Transformation.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1));
    * var a0 = new DSMath.Axis().setOrigin(1,2,3);
    * var a1 = a0.applyTransformation(t0); // a1===a0 and a1.origin=(0,1,3)
    * var dir = a1.getDirections();        //dir[0]=(0,1,0) and dir[1]=(-1,0,0) and dir[2]=(0,0,1)
    * @returns {DSMath.Axis} <i>this</i> modified axis reference.
    */
    Axis.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      var dir = this.getDirectionsNotCloned();

      this.origin.applyTransformation(iT);
      dir[0].applyTransformation(iT);
      dir[1].applyTransformation(iT);
      dir[2].applyTransformation(iT);

      if (!iT.matrix.isAnIsometry())
      {
        // The vectors are no longer orthonormalize ==> we make them again.
        this.setVectors(dir[0], dir[1], dir[2]);
      }

      return this;
    };

    DSMath.Axis = Axis;

    return Axis;

  }
);
