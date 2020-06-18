define('MathematicsES/MathMat2x2JSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathVector2DJSImpl'
  ],

  function (DSMath, TypeCheck, TypeCheckInternal, Vector2D)
  {
    'use strict';

    /**
    * @public
    * @exports Matrix2x2
    * @class
    * @classdesc Representation of a Matrix2x2
    *
    * @constructor
    * @constructordesc
    * The DSMath.Matrix2x2 constructor creates a square matrix of dimension 2.
    * <br>
    * By default, the created matrix is the Identity matrix.
    * @param {Number} [iM00=1] The coef in row 0 column 0
    * @param {Number} [iM01=0] The coef in row 0 column 1
    * @param {Number} [iM10=0] The coef in row 1 column 0
    * @param {Number} [iM11=1] The coef in row 1 column 1
    * @memberof DSMath
    */
    var Matrix2x2 = function ()
    {
      this.coef = [1, 0,
                   0, 1];

      for (var i = 0; i < arguments.length; i++)
      {
        this.coef[i] = arguments[i];
      }
    };

    /**
    * The coefficients of the Matrix2x2.
    * @public
    * @member
    * @instance
    * @name coef
    * @type {Number}
    * @memberOf DSMath.Matrix2x2
    */
    Matrix2x2.prototype.coef = null;

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Matrix2x2
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.clone(); // m1==m0 but m1!==m0
    * @returns {DSMath.Matrix2x2} The cloned Matrix2x2.
    */
    Matrix2x2.prototype.clone = function ()
    {
      var c = this.coef;
      var oM = new Matrix2x2(c[0], c[1], c[2], c[3]);
      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method copy
    * @instance
    * @description
    * Copies the given Matrix2x2.
    * @param {DSMath.Matrix2x2} iM The matrix to copy.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2();
    * var m2 = m1.copy(m0); // m2===m1 and m2==m0 but m2!==m0
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Matrix2x2);

      this.setFromArray(iToCopy.coef);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method set
    * @instance
    * @description
    * Assigns new coefficients to <i>this</i> matrix. The coefficients are duplicated.
    * <br>
    * All parameters have to be provided. Otherwise <i>this</i> stays unchanged.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM01 The coef in row 0 column 1
    * @param {Number} iM10 The coef in row 1 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * var m1 = m0.set(0,1,2,3); // m0===m1 and m0.coef=[0,1,2,3]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference.
    */
    Matrix2x2.prototype.set = function ()
    {
      DSMath.TypeCheck(Array.prototype.slice.call(arguments), false, ['number'], 4); // must be an array of at least 4 numbers

      if (arguments.length == 4)
      {
        var c = this.coef;
        c[0] = arguments[0]; c[1] = arguments[1];
        c[2] = arguments[2]; c[3] = arguments[3];
      }
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method setFromArray
    * @instance
    * @description
    * Assigns new coefficients to <i>this</i> matrix. The coefficients are duplicated.
    * @param {Number[]} iCoef     Array of size 4 containing the new matrix coefficients.
    * @param {Number}   [iMode=0] 0 if the array is [m00,m01,m10,m11], 1 if it is [m00,m10,m01,m11]
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * var newCoef = [0,1,2,3];
    * var m1 = m0.setFromArray(newCoef);   // m0===m1 and m0.coef==[0,1,2,3] but m0.coef!==newCoef.
    * var m2 = m0.setFromArray(newCoef,1); // m0.coef=[0,2,1,3]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference.
    */
    Matrix2x2.prototype.setFromArray = function (iCoef, iMode)
    {
      DSMath.TypeCheck(iCoef, true, ['number'], 4);
      DSMath.TypeCheck(iMode, false, 'number');

      var c = this.coef;
      iMode = iMode || 0;
      if (iMode == 0)
      {
        c[0] = iCoef[0]; c[1] = iCoef[1];
        c[2] = iCoef[2]; c[3] = iCoef[3];
      } else
      {
        c[0] = iCoef[0]; c[2] = iCoef[1];
        c[1] = iCoef[2]; c[3] = iCoef[3];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getArray
    * @instance
    * @description
    * Retrieves a copy of the matrix coefficients into an array of size 4.
    * @param {Number}   [iMode=0] 0 if the array to retrieve should be [m00,m01,m10,m11], 1 if it should be [m00,m10,m01,m11]
    * @param {Number[]} [oCoef]   Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var coef0 = m0.getArray();  // coef0=[0,1,2,3] but coef0!==m0.coef
    * var coef1 = m0.getArray(1); // coef1=[0,2,1,3]
    * @returns {Number[]} The reference of the operation result
    */
    Matrix2x2.prototype.getArray = function (iMode, oCoef)
    {
      DSMath.TypeCheck(iMode, false, 'number');
      DSMath.TypeCheck(oCoef, false, ['number'], 4);

      oCoef = oCoef || new Array(4);
      iMode = iMode || 0;
      var c = this.coef;

      if (iMode == 0)
      {
        oCoef[0] = c[0]; oCoef[1] = c[1];
        oCoef[2] = c[2]; oCoef[3] = c[3];
      } else
      {
        oCoef[0] = c[0]; oCoef[2] = c[1];
        oCoef[1] = c[2]; oCoef[3] = c[3];
      }

      return oCoef;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method setFirstColumn
    * @instance
    * @description
    * Sets the first column coef.
    * @param {DSMath.Vector2D} iV The vector containing the new first column coef
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var v0 = new DSMath.Vector2D(4,5);
    * var m1 = m0.setFirstColumn(v0); // m1===m0 and m1=[4,1,5,3]
    * @returns {DSMath.Vector2D} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.setFirstColumn = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var c = this.coef;
      c[0] = iV.x;
      c[2] = iV.y;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getFirstColumn
    * @instance
    * @description
    * Retrieves the first column under the form of a Vector2D.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var firstColm0 = m0.getFirstColumn(); // firstColm0=(0,2)
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Matrix2x2.prototype.getFirstColumn = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = oV || new Vector2D();
      var c = this.coef;
      oV.x = c[0];
      oV.y = c[2];
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method setSecondColumn
    * @instance
    * @description
    * Sets the second column coef.
    * @param {DSMath.Vector2D} iV The vector containing the new second column coef
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var v0 = new DSMath.Vector2D(4,5);
    * var m1 = m0.setSecondColumn(v0); // m1===m0 and m1=[0,4,2,5]
    * @returns {DSMath.Vector2D} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.setSecondColumn = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var c = this.coef;
      c[1] = iV.x;
      c[3] = iV.y;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getSecondColumn
    * @instance
    * @description
    * Retrieves the second column under the form of a Vector2D.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var secColm0 = m0.getSecondColumn(); // secColm0=(1,3)
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Matrix2x2.prototype.getSecondColumn = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = oV || new Vector2D();
      var c = this.coef;
      oV.x = c[1];
      oV.y = c[3];
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeRotation
    * @instance
    * @description
    * Sets the matrix coef to represent a rotation.
    * @param {Number} iAngle The angle of the rotation
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * m0.makeRotation(Math.PI/2); // m0=[0,-1,1,0]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.makeRotation = function (iAngle)
    {
      DSMath.TypeCheck(iAngle, true, 'number');

      var sina = Math.sin(iAngle);
      var cosa = Math.cos(iAngle);

      var c = this.coef;

      c[0] = cosa; c[1] = -sina;
      c[2] = sina; c[3] = cosa;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeDiagonal
    * @instance
    * @description
    * <i>This</i> matrix becomes a diagonal matrix with the coefs given.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.makeDiagonal(4,5); // m1===m0 and m1=[4,0,0,5]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.makeDiagonal = function (iM00, iM11)
    {
      DSMath.TypeCheck(iM00, true, 'number');
      DSMath.TypeCheck(iM11, true, 'number');

      var c = this.coef;

      c[0] = iM00; c[1] = 0.;
      c[2] = 0.; c[3] = iM11;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeScaling
    * @instance
    * @description
    * <i>This</i> matrix becomes a scaling matrix of the scale given.
    * @param {Number} iS The scale.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.makeScaling(4); // m1===m0 and m1=[4,0,0,4]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.makeScaling = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      return this.makeDiagonal(iS, iS, iS);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method inverse
    * @instance
    * @description
    * Inverses <i>this</i> matrix.
    * <br>
    * The matrix stays unchanged if it can't be reversed.
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * m0.makeRotation(Math.PI/2); // m0=[0,-1,1,0]
    * var m1 = m0.inverse(); // m1===m0 and m1=[0,1,-1,0]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.inverse = function ()
    {
      var c = this.coef;

      var a11 = c[0];

      var det = this.determinant();

      if (Math.abs(det) > DSMath.defaultTolerances.epsilonForSquareRelativeTest)
      {
        c[0] = c[3] / det;
        c[1] = -c[1] / det;

        c[2] = -c[2] / det;
        c[3] = a11 / det;
      }

      return this;
    }

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getInverse
    * @instance
    * @description
    * Returns the inverse of <i>this</i> matrix.
    * <br>
    * If <i>this</i> matrix is not reversible, the returned matrix will be a copy of <i>this</i>
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * m0.makeRotation(Math.PI/2); // m0=[0,-1,1,0]
    * var m1 = m0.getInverse(); // m1!==m0 and m1=[0,1,-1,0]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.prototype.getInverse = function (oM)
    {
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? oM.copy(this) : this.clone();
      return oM.inverse();
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method transpose
    * @instance
    * @description
    * Transposes <i>this</i> matrix.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.transpose(); // m1===m0 and m1=[0,2,1,3]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.transpose = function ()
    {
      var c = this.coef;

      c[1] = c[2] + (c[2] = c[1], 0);

      return this;
    }

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getTranspose
    * @instance
    * @description
    * Returns the transpose of <i>this</i> matrix.
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation)
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.getTranspose(); // m1!==m0 and m1=[0,2,1,3]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.prototype.getTranspose = function (oM)
    {
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? oM.copy(this) : this.clone();
      return oM.transpose();
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method determinant
    * @instance
    * @description
    * Computes the determinant of <i>this</i> matrix.
    * @example
    * var m0 = new DSMath.Matrix2x2(1,2,3,4)
    * var detM0 = m0.determinant(); // detM0=-2
    * @returns {Number} The determinant of the matrix.
    */
    Matrix2x2.prototype.determinant = function ()
    {
      var c = this.coef;
      return (c[0] * c[3] - c[1] * c[2]);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method trace
    * @instance
    * @description
    * Computes the sum of the elements on the matrix diagonal.
    * @example
    * var m0 = new DSMath.Matrix2x2(1,2,3,4);
    * var traceM0 = m0.trace(); // traceM0=5
    * @returns {Number} The sum of the elements on the matrix diagonal.
    */
    Matrix2x2.prototype.trace = function ()
    {
      var c = this.coef;
      return (c[0] + c[3]);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method infiniteNorm
    * @instance
    * @description
    * Returns the infinite norm of <i>this</i> matrix.
    * <br>
    * The infinite norm is the supremum of the absolute value of the coefficients.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,-2,-3);
    * var infNormM0 = m0.infiniteNorm(); // infNormM0=3
    * @returns {Number} The supremum of the absolute value of the 
    */
    Matrix2x2.prototype.infiniteNorm = function ()
    {
      var max = 0;

      for (var i = 0; i < 4; i++)
      {
        var c = this.coef[i];
        max = (max * max < c * c) ? Math.abs(c) : max;
      }

      return max;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method getScale
    * @instance
    * @description
    * Computes the scale performed by <i>this</i> matrix.
    * <br>
    * The scale equals Math.pow(<i>this</i>.determinant(),1./2.). It only has a meaning if <i>this</i>.isScaling() is true.
    * @example
    * var m0 = DSMath.Matrix2x2.makeScaling(5);
    * var m1 = new DSMath.Matrix2x2(1,1,0,1);
    * var m0Scale = m0.getScale(); //m0Scale=5
    * var m1Scale = m1.getScale(); //m1Scale=1 but m1.isScaling()=false so it is hard to interpretate.
    * @returns {Number} The scale value of the scaling made by <i>this</i> matrix. The scale is negative if <i>this</i> matrix does a reflexion.
    */
    Matrix2x2.prototype.getScale = function ()
    {
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var epsilongRel = DSMath.defaultTolerances.epsilonForRelativeTest;
      var det = this.determinant();

      var scale = 0;
      if (Math.abs(det) >= epsilongRel)
      {
        scale = (Math.abs(Math.abs(det) - 1) <= 2 * epsgRel) ? 1 : Math.sqrt(Math.abs(det));
        scale *= (det > 0) ? 1 : -1;
      }

      return scale;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isOrthogonal
    * @instance
    * @description
    * Determines whether the matrix contains orthogonal vectors.
    * <br>
    * The vectors can not be normalized. If the norm is null then vectors are considered as orthogonal.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = DSMath.Matrix2x2.makeRotation(Math.PI/2);
    * var m0IsOrtho = m0.isOrthogonal(); // m0IsOrtho==false
    * var m1IsOrtho = m1.isOrthogonal(); // m1IsOrtho==true
    * @returns {Boolean} true if <i>this</i> contains orthogonal vectors, false otherwise.
    */
    Matrix2x2.prototype.isOrthogonal = function ()
    {
      var c = this.coef;

      var sqEpsRel = DSMath.defaultTolerances.epsgForSquareRelativeTest;

      var sqNormC0 = c[0] * c[0] + c[2] * c[2];
      var sqNormC1 = c[1] * c[1] + c[3] * c[3];

      var dotC0C1 = c[0] * c[1] + c[2] * c[3];

      var isOrthogonal = (dotC0C1 * dotC0C1 <= sqEpsRel * sqNormC0 * sqNormC1);

      return isOrthogonal;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isScaling
    * @instance
    * @description
    * Determines whether the matrix performs a scaling or not.
    * <br>
    * The matrix performs a scaling if it contains orthogonal vectors of the same non null norm.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs a scaling.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2(2,0, 0,-2);
    * var m0IsScaling = m0.isScaling(); // m0IsScaling==false
    * var m1IsScaling = m1.isScaling(); // m1IsScaling==true
    * @returns {Boolean} true if <i>this</i> performs a scaling, false otherwise.
    */
    Matrix2x2.prototype.isScaling = function (oS)
    {
      DSMath.TypeCheck(oS, false, Object);

      var c = this.coef;
      var isScaling = false;
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var sqEpsgRel = epsgRel * epsgRel;
      var sqEpsilonRel = DSMath.defaultTolerances.epsilonForSquareRelativeTest;

      if (this.isOrthogonal())
      {
        var scale = Math.abs(this.getScale());
        if (oS) oS.scale = scale;
        var sqNorm = scale * scale;

        if (sqNorm > sqEpsilonRel)
        {
          var sqNormC0 = c[0] * c[0] + c[2] * c[2];
          var sqNormC1 = c[1] * c[1] + c[3] * c[3];

          isScaling = ((Math.abs(sqNormC0 / sqNorm - 1) < 2 * epsgRel + sqEpsgRel) &&
                        (Math.abs(sqNormC1 / sqNorm - 1) < 2 * epsgRel + sqEpsgRel));
        }
      }

      return isScaling;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isReflecting
    * @instance
    * @description
    * Determines whether the matrix performs a reflection or not.
    * <br>
    * The matrix performs a reflection if it contains orthogonal vectors of the same non null norm and has a negative determinant.
    * @example
    * var m0 = new DSMath.Matrix2x2(2,0,0,2);
    * var m1 = new DSMath.Matrix2x2(2,0,0,-2);
    * var m0IsReflecting = m0.isReflecting(); // m0IsReflecting==false
    * var m1IsReflecting = m1.isReflecting(); // m1IsReflecting==true
    * @returns {Boolean} true if <i>this</i> performs a reflection, false otherwise.
    */
    Matrix2x2.prototype.isReflecting = function ()
    {
      var isReflecting = this.isScaling();
      isReflecting = (isReflecting && this.determinant() < 0);
      return isReflecting;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isAnIsometry
    * @instance
    * @description
    * Determines whether the matrix is an isometry or not.
    * @param {Object} [oD] Fill the properties "direct" of oD if <i>this</i> is an isometry matrix (true if direct, false otherwise).
    * @example
    * var m0 = new DSMath.Matrix2x2();
    * m0.makeRotation(Math.PI/2); // m0=[0,-1,1,0]
    * var m1 = new DSMath.Matrix2x2(0,1,2,3);
    * var m0isAnIsometry = m0.isAnIsometry(); // m0isAnIsometry==true
    * var m1isAnIsometry = m1.isAnIsometry(); // m1isAnIsometry==false
    * @returns {Boolean} true if <i>this</i> is an isometry, false otherwise.
    */
    Matrix2x2.prototype.isAnIsometry = function (oD)
    {
      DSMath.TypeCheck(oD, false, Object);

      var c = this.coef;
      var isAnIsometry = false;
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var sqEpsgRel = epsgRel * epsgRel;
      var sqEpsilonRel = DSMath.defaultTolerances.epsilonForSquareRelativeTest;
      var det = this.determinant();

      if (det * det > sqEpsilonRel && this.isOrthogonal())
      {
        var sqNormC0 = c[0] * c[0] + c[2] * c[2];
        var sqNormC1 = c[1] * c[1] + c[3] * c[3];

        isAnIsometry = ((Math.abs(sqNormC0 - 1) < 2 * epsgRel + sqEpsgRel) &&
                         (Math.abs(sqNormC1 - 1) < 2 * epsgRel + sqEpsgRel));

        if (isAnIsometry && oD) oD.direct = (det > 0);
      }

      return isAnIsometry;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isAScaling
    * @instance
    * @description
    * Determines whether the matrix is only a scaling matrix or not.
    * <br>
    * The matrix is only a scaling if it only contains diagonal coefs of the same non null value.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs at least a scaling.
    * @example
    * var m0 = new DSMath.Matrix2x2(2,0,0,2);
    * var m1 = new DSMath.Matrix2x2(2,0,0,-2);
    * var m0IsAScaling = m0.isAScaling(); // m0IsAScaling==true
    * var m1IsAScaling = m1.isAScaling(); // m1IsAScaling==false
    * @returns {Boolean} true if <i>this</i> is only a scaling, false otherwise.
    */
    Matrix2x2.prototype.isAScaling = function (oS)
    {
      DSMath.TypeCheck(oS, false, Object);

      oS = oS || { scale: 1 };
      var isAScaling = false;

      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;

      if (this.isScaling(oS))
      {
        var trace = this.trace();
        isAScaling = (trace > 0 && Math.abs(trace - 2 * oS.scale) <= Math.max(trace, 1) * epsgRel);
      }

      return isAScaling;
    };

    /**
     * @typedef RotationAngle
     * @type Object
     * @property {Number} angle The angle of the quaternion rotation
     */

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method isARotation
    * @instance
    * @description
    * Determines whether the matrix is only a rotation matrix or not.
    * <br>
    * The matrix is only a rotation if it is a direct isometry.
    * @param {RotationAngle} [oRotationAngle] Filled if given.
    * @example
    * var m0 = new DSMath.Matrix2x2(2,0,0,2);
    * var m1 = new DSMath.Matrix2x2(0,-1,1,0);
    * var m2 = new DSMath.Matrix2x2(-1,0 ,0,1);
    * var m1Data = {angle:0};
    * var m0IsARotation = m0.isARotation();       // m0IsARotation==false
    * var m1IsARotation = m1.isARotation(m1Data); // m1IsARotation==true and m1Data={angle:PI/2};
    * var m2IsARotation = m2.isARotation();       // m2IsARotation==false
    * @returns {Boolean} true if <i>this</i> is only a rotation, false otherwise.
    */
    Matrix2x2.prototype.isARotation = function (oRotationAngle)
    {
      DSMath.TypeCheck(oRotationAngle, false, Object);

      var direct = { direct: false };
      var isARotation = this.isAnIsometry(direct);
      isARotation = (isARotation && direct.direct);

      if (isARotation && oRotationAngle)
      {
        oRotationAngle.angle = Math.atan2(this.coef[2], this.coef[0]);
      }

      return isARotation;
    }

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method add
    * @instance
    * @description
    * Adds a given matrix to <i>this</i> matrix.
    * @param {DSMath.Matrix2x2} iM The matrix <i>this</i> is to be added.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2(3,2,1,0);
    * var m3 = m0.add(m1); // m3===m0 and m3=[3,3,3,3]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.add = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix2x2);

      var c = this.coef;
      var m = iM.coef;

      for (var i = 0; i < 4; i++)
      {
        c[i] += m[i];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method sub
    * @instance
    * @description
    * Subtracts a given Matrix2x2 to <i>this</i> matrix.
    * @param {DSMath.Matrix2x2} iM The matrix <i>this</i> is to be subtracted.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2(3,2,1,0);
    * var m3 = m0.sub(m1); // m3===m0 and m3=[-3,-1,1,3]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.sub = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix2x2);

      var c = this.coef;
      var m = iM.coef;

      for (var i = 0; i < 4; i++)
      {
        c[i] -= m[i];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method multiply
    * @instance
    * @description
    * Multiplies a given Matrix2x2 to <i>this</i> matrix.
    * @param {DSMath.Matrix2x2} iM            The matrix <i>this</i> is to be multiplied.
    * @param {Boolean}          [iLeft=false] false if the multiplication is made on the right of <i>this</i>, true otherwise.
    * @example
    * var s0 = new DSMath.Matrix2x2();
    * s0.makeDiagonal(1,2);
    * var r0 = new DSMath.Matrix2x2();
    * r0.makeRotation(Math.PI/2);
    * var m = r0.multiply(s0); // m===r0 and m=[0,-2, 1,0]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.multiply = function (iM, iLeft)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(iLeft, false, Boolean);

      iLeft = iLeft || false;

      var c = this.coef;
      var m = iM.coef;
      var m00 = m[0]; var m01 = m[1];
      var m10 = m[2]; var m11 = m[3];

      if (!iLeft)
      {
        for (var i = 0; i < 2; i++)
        {
          var idS = 2 * i;
          var t0 = c[idS];
          var t1 = c[idS + 1];

          c[idS] = t0 * m00 + t1 * m10;
          c[idS + 1] = t0 * m01 + t1 * m11;
        }
      } else
      {
        for (var i = 0; i < 2; i++)
        {
          var t0 = c[i];
          var t1 = c[2 + i];

          c[i] = m00 * t0 + m01 * t1;
          c[2 + i] = m10 * t0 + m11 * t1;
        }
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method multiplyScalar
    * @instance
    * @description
    * Multiplies each coefficient of <i>this</i> matrix by a scalar.
    * @param {Number} iS The scalar.
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = m0.multiplyScalar(2); // m1===m0 and m1=[0,2,4,6]
    * @returns {DSMath.Matrix2x2} <i>this</i> modified matrix reference
    */
    Matrix2x2.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      var c = this.coef;

      c[0] *= iS; c[1] *= iS;
      c[2] *= iS; c[3] *= iS;

      return this;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */
    /**
    * @public
    * @name identity
    * @type {DSMath.Matrix2x2}
    * @readonly
    * @memberOf DSMath.Matrix2x2
    * @description The identity matrix [1,0,0,1]
    */
    Object.defineProperty(Matrix2x2, "identity", {
      value: new Matrix2x2(1, 0, 0, 1),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Matrix2x2.identity); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeRotation
    * @static
    * @description
    * Creates a matrix equals to the rotation by the angle around the axis given.
    * @param {DSMath.Vector2D} iAxis  The axis of the rotation.
    * @param {Number}          iAngle The angle of the rotation
    * @example
    * var m0 = DSMath.Matrix2x2.makeRotation(Math.PI/2); // m0=[0,-1,1,0]
    * @returns {DSMath.Matrix2x2} The created matrix.
    */
    Matrix2x2.makeRotation = function (iAngle)
    {
      DSMath.TypeCheck(iAngle, true, 'number');

      var result = new Matrix2x2();
      return result.makeRotation(iAngle);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeDiagonal
    * @static
    * @description
    * Creates a diagonal matrix from the three given values.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @example
    * var m0 = DSMath.Matrix2x2.makeDiagonal(9,10); //m0=[9,0,0,10]
    * @returns {DSMath.Matrix2x2} The created matrix.
    */
    Matrix2x2.makeDiagonal = function (iM00, iM11)
    {
      DSMath.TypeCheck(iM00, true, 'number');
      DSMath.TypeCheck(iM11, true, 'number');

      var result = new Matrix2x2();
      return result.makeDiagonal(iM00, iM11);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method makeRotation
    * @static
    * @description
    * Creates a scaling matrix from the scalar given.
    * @param {Number} iS The scale.
    * @example
    * var m0 = DSMath.Matrix2x2.makeScaling(3); // m0=[3,0,0,3]
    * @returns {DSMath.Matrix2x2} The created matrix.
    */
    Matrix2x2.makeScaling = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      var result = new Matrix2x2();
      return result.makeScaling(iS);
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method add
    * @static
    * @description
    * Adds two given matrix.
    * @param {DSMath.Matrix2x2} iM1  The matrix to add.
    * @param {DSMath.Matrix2x2} iM2  The matrix to add.
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2(3,2,1,0);
    * var m3 = DSMath.Matrix2x2.add(m0,m1); // m3!==m0 and m3=[3,3,3,3]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.add = function (iM1, iM2, oM)
    {
      DSMath.TypeCheck(iM1, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(iM2, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? oM : new Matrix2x2();

      var c = oM.coef;
      var m1 = iM1.coef;
      var m2 = iM2.coef;

      for (var i = 0; i < 4; i++)
      {
        c[i] = m1[i] + m2[i];
      }

      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method sub
    * @static
    * @description
    * Substract two given matrix.
    * @param {DSMath.Matrix2x2} iM1 The matrix.
    * @param {DSMath.Matrix2x2} iM2 The matrix to substract from iM1.
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = new DSMath.Matrix2x2(3,2,1,0);
    * var m3 = DSMath.Matrix2x2.sub(m0, m1); // m3===m0 and m3=[-3,-1,1,3]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.sub = function (iM1, iM2, oM)
    {
      DSMath.TypeCheck(iM1, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(iM2, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? oM : new Matrix2x2();

      var c = oM.coef;
      var m1 = iM1.coef;
      var m2 = iM2.coef;

      for (var i = 0; i < 4; i++)
      {
        c[i] = m1[i] - m2[i];
      }

      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method multiply
    * @static
    * @description
    * Multiplies two given matrix.
    * @param {DSMath.Matrix2x2} iMLeft The matrix on the left of the multiplication.
    * @param {DSMath.Matrix2x2} iMRight The matrix on the right of the multiplication.
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var s0 = new DSMath.Matrix2x2();
    * s0.makeDiagonal(1,2);
    * var r0 = new DSMath.Matrix2x2();
    * r0.makeRotation(Math.PI/2);
    * var m = DSMath.Matrix2x2.multiply(r0,s0); // m!=r0 and m=[0,-2,1,0]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.multiply = function (iMLeft, iMRight, oM)
    {
      DSMath.TypeCheck(iMLeft, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(iMRight, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? (oM === iMRight) ? oM.multiply(iMLeft, true) : oM.copy(iMLeft).multiply(iMRight)
               : iMLeft.clone().multiply(iMRight);
      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix2x2
    * @method multiplyScalar
    * @static
    * @description
    * Multiplies each coefficient of a given matrix by a scalar.
    * @param {DSMath.Matrix2x2} iM The matrix.
    * @param {Number} iS The scalar.
    * @param {DSMath.Matrix2x2} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix2x2(0,1,2,3);
    * var m1 = DSMath.Matrix2x2.multiplyScalar(m0,2); // m1!=m0 and m1=[0,2,4,6]
    * @returns {DSMath.Matrix2x2} The reference of the operation result.
    */
    Matrix2x2.multiplyScalar = function (iM, iS, oM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix2x2);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oM, false, DSMath.Matrix2x2);

      oM = (oM) ? oM.copy(iM) : iM.clone();
      return oM.multiplyScalar(iS);
    };

    DSMath.Matrix2x2 = Matrix2x2;

    return Matrix2x2;
  }
);
