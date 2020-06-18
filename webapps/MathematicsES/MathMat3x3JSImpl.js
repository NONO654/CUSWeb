define('MathematicsES/MathMat3x3JSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathVector3DJSImpl'
  ],
   
  function (DSMath, TypeCheck, TypeCheckInternal, Vector3D)
  {
    'use strict';

    /**
    * @public
    * @exports Matrix3x3
    * @class
    * @classdesc Representation of a Matrix3x3
    *
    * @constructor
    * @constructordesc
    * The DSMath.Matrix3x3 constructor creates a square matrix of dimension 3.
    * <br>
    * By default, the created matrix is the Identity matrix.
    * @param {Number} [iM00=1] The coef in row 0 column 0
    * @param {Number} [iM01=0] The coef in row 0 column 1
    * @param {Number} [iM02=0] The coef in row 0 column 2
    * @param {Number} [iM10=0] The coef in row 1 column 0
    * @param {Number} [iM11=1] The coef in row 1 column 1
    * @param {Number} [iM12=0] The coef in row 1 column 2
    * @param {Number} [iM20=0] The coef in row 2 column 0
    * @param {Number} [iM21=0] The coef in row 2 column 1
    * @param {Number} [iM22=1] The coef in row 2 column 2
    * @memberof DSMath
    */
    var Matrix3x3 = function ()
    {
      this.coef = [1, 0, 0,
                   0, 1, 0,
                   0, 0, 1];

      for (var i = 0; i < arguments.length; i++)
      {
        this.coef[i] = arguments[i];
      }
    };

    /**
    * The coefficients of the Matrix3x3.
    * @public
    * @member
    * @instance
    * @name coef
    * @type {Number}
    * @memberOf DSMath.Matrix3x3
    */
    Matrix3x3.prototype.coef = null;

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Matrix3x3
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.clone(); // m1==m0 but m1!==m0
    * @returns {DSMath.Matrix3x3} The cloned Matrix3x3.
    */
    Matrix3x3.prototype.clone = function ()
    {
      var c = this.coef;
      var oM = new Matrix3x3(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8]);
      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method copy
    * @instance
    * @description
    * Copies the given Matrix3x3.
    * @param {DSMath.Matrix3x3} iM The matrix to copy.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = new DSMath.Matrix3x3();
    * var m2 = m1.copy(m0); // m2===m1 and m2==m0 but m2!==m0
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Matrix3x3);

      this.setFromArray(iToCopy.coef);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method set
    * @instance
    * @description
    * Assigns new coefficients to <i>this</i> matrix. The coefficients are duplicated.
    * <br>
    * All parameters have to be provided. Otherwise <i>this</i> stays unchanged.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM01 The coef in row 0 column 1
    * @param {Number} iM02 The coef in row 0 column 2
    * @param {Number} iM10 The coef in row 1 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @param {Number} iM12 The coef in row 1 column 2
    * @param {Number} iM20 The coef in row 2 column 0
    * @param {Number} iM21 The coef in row 2 column 1
    * @param {Number} iM22 The coef in row 2 column 2
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * var m1 = m0.set(0,1,2,3,4,5,6,7,8); // m0===m1 and m0.coef=[0,1,2,3,4,5,6,7,8]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference.
    */
    Matrix3x3.prototype.set = function ()
    {
      if (arguments.length == 9)
      {
        var c = this.coef;
        c[0] = arguments[0]; c[1] = arguments[1]; c[2] = arguments[2];
        c[3] = arguments[3]; c[4] = arguments[4]; c[5] = arguments[5];
        c[6] = arguments[6]; c[7] = arguments[7]; c[8] = arguments[8];
      }
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method setFromArray
    * @instance
    * @description
    * Assigns new coefficients to <i>this</i> matrix. The coefficients are duplicated.
    * @param {Number[]} iCoef     Array of size 9 containing the new matrix coefficients.
    * @param {Number}   [iMode=0] 0 if the array is [m00,m01,m02,m10,m11,12,m20,m21,m22], 1 if it is [m00,m10,m21,m01,m11,m21,m02,m12,m22]
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * var newCoef = [0,1,2,3,4,5,6,7,8];
    * var m1 = m0.setFromArray(newCoef);   // m0===m1 and m0.coef==[0,1,2,3,4,5,6,7,8] but m0.coef!==newCoef.
    * var m2 = m0.setFromArray(newCoef,1); // m0.coef=[0,3,6,1,4,7,2,5,8]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference.
    */
    Matrix3x3.prototype.setFromArray = function (iCoef, iMode)
    {
      DSMath.TypeCheck(iCoef, true, ['number'], 9);
      DSMath.TypeCheck(iMode, false, 'number');

      var c = this.coef;
      iMode = iMode || 0;
      if (iMode == 0)
      {
        c[0] = iCoef[0]; c[1] = iCoef[1]; c[2] = iCoef[2];
        c[3] = iCoef[3]; c[4] = iCoef[4]; c[5] = iCoef[5];
        c[6] = iCoef[6]; c[7] = iCoef[7]; c[8] = iCoef[8];
      } else
      {
        c[0] = iCoef[0]; c[1] = iCoef[3]; c[2] = iCoef[6];
        c[3] = iCoef[1]; c[4] = iCoef[4]; c[5] = iCoef[7];
        c[6] = iCoef[2]; c[7] = iCoef[5]; c[8] = iCoef[8];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getArray
    * @instance
    * @description
    * Retrieves a copy of the matrix coefficients into an array of size 9.
    * @param {Number}    [iMode=0] 0 if the array to retrieve should be [m00,m01,m02,m10,m11,m12,m20,m21,m22], 1 if it should be [m00,m10,m21,m01,m11,m21,m02,m12,m22]
    * @param {Number[]} [oCoef] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var coef0 = m0.getArray();  // coef0=[0,1,2,3,4,5,6,7,8] but coef0!==m0.coef
    * var coef1 = m0.getArray(1); // coef1=[0,3,6,1,4,7,2,5,8]
    * @returns {Number[]} The reference of the operation result
    */
    Matrix3x3.prototype.getArray = function (iMode, oCoef)
    {
      DSMath.TypeCheck(iMode, false, 'number');
      DSMath.TypeCheck(oCoef, false, [], []);

      oCoef = oCoef || new Array(9);
      iMode = iMode || 0;
      var c = this.coef;

      if (iMode == 0)
      {
        oCoef[0] = c[0]; oCoef[1] = c[1]; oCoef[2] = c[2];
        oCoef[3] = c[3]; oCoef[4] = c[4]; oCoef[5] = c[5];
        oCoef[6] = c[6]; oCoef[7] = c[7]; oCoef[8] = c[8];
      } else
      {
        oCoef[0] = c[0]; oCoef[3] = c[1]; oCoef[6] = c[2];
        oCoef[1] = c[3]; oCoef[4] = c[4]; oCoef[7] = c[5];
        oCoef[2] = c[6]; oCoef[5] = c[7]; oCoef[8] = c[8];
      }

      return oCoef;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method setFirstColumn
    * @instance
    * @description
    * Sets the first column coef.
    * @param {DSMath.Vector3D} iV The vector containing the new first column coef
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var v0 = new DSMath.Vector3D(9,10,11);
    * var m1 = m0.setFirstColumn(v0); // m1===m0 and m1=[9,1,2, 10,4,5, 11,7,8]
    * @returns {DSMath.Vector3D} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.setFirstColumn = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var c = this.coef;
      c[0] = iV.x;
      c[3] = iV.y;
      c[6] = iV.z;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getFirstColumn
    * @instance
    * @description
    * Retrieves the first column under the form of a Vector3D.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var firstColm0 = m0.getFirstColumn(); // firstColm0=(0,3,6)
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Matrix3x3.prototype.getFirstColumn = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = oV || new Vector3D();
      var c = this.coef;
      oV.x = c[0];
      oV.y = c[3];
      oV.z = c[6];
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method setSecondColumn
    * @instance
    * @description
    * Sets the second column coef.
    * @param {DSMath.Vector3D} iV The vector containing the new second column coef
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var v0 = new DSMath.Vector3D(9,10,11);
    * var m1 = m0.setSecondColumn(v0); // m1===m0 and m1=[0,9,2, 3,10,5, 6,11,8]
    * @returns {DSMath.Vector3D} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.setSecondColumn = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var c = this.coef;
      c[1] = iV.x;
      c[4] = iV.y;
      c[7] = iV.z;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getSecondColumn
    * @instance
    * @description
    * Retrieves the second column under the form of a Vector3D.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var secColm0 = m0.getSecondColumn(); // secColm0=(1,4,7)
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Matrix3x3.prototype.getSecondColumn = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = oV || new Vector3D();
      var c = this.coef;
      oV.x = c[1];
      oV.y = c[4];
      oV.z = c[7];
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method setThirdColumn
    * @instance
    * @description
    * Sets the third column coef.
    * @param {DSMath.Vector3D} iV The vector containing the new third column coef
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var v0 = new DSMath.Vector3D(9,10,11);
    * var m1 = m0.setThirdColumn(v0); // m1===m0 and m1=[0,1,9, 3,4,10, 6,7,11]
    * @returns {DSMath.Vector3D} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.setThirdColumn = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var c = this.coef;
      c[2] = iV.x;
      c[5] = iV.y;
      c[8] = iV.z;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getThirdColumn
    * @instance
    * @description
    * Retrieves the third column under the form of a Vector3D.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var thirdColm0 = m0.getThirdColumn(); // thirdColm0=(2,5,8)
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Matrix3x3.prototype.getThirdColumn = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = oV || new Vector3D();
      var c = this.coef;
      oV.x = c[2];
      oV.y = c[5];
      oV.z = c[8];
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeRotation
    * @instance
    * @description
    * Sets the matrix coef to represent the rotation specified by an axis and angle.
    * @param {DSMath.Vector3D} iAxis  The axis of the rotation.
    * @param {Number}          iAngle The angle of the rotation
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * m0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0,1,0,0,0,0,1]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.makeRotation = function (iAxis, iAngle)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');

      var normV = iAxis.norm();

      var x = iAxis.x / normV;
      var y = iAxis.y / normV;
      var z = iAxis.z / normV;

      var sina = Math.sin(iAngle);
      var cosa = Math.cos(iAngle);
      var t = 1 - cosa;
      var tx = t * x;
      var ty = t * y;

      var c = this.coef;

      c[0] = tx * x + cosa;
      c[1] = tx * y - sina * z;
      c[2] = tx * z + sina * y;
      c[3] = tx * y + sina * z;
      c[4] = ty * y + cosa;
      c[5] = ty * z - sina * x;
      c[6] = tx * z - sina * y;
      c[7] = ty * z + sina * x;
      c[8] = t * z * z + cosa;

      return this;
    };


    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeRotationFromEuler
    * @instance
    * @description
    * <i>This</i> matrix becomes a rotation equals to rotation combination defined from euler angles.
    * @param {Number[]} iE The array of euler angles ordered as the iEOrder provided.
    * @param {String} [iEOrder] The euler angle order (default ZXY).
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * var m1 = m0.makeRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2]); // m1===m0
    * // m0=|0.5, 0.5, 1/&#8730;2|
    * //    |0.5, 0.5,-1/&#8730;2|
    * //    |-1/&#8730;2, 1/&#8730;2, 0|
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.makeRotationFromEuler = function (iEuler, iEulerOrder)
    {
      DSMath.TypeCheck(iEuler, true, ['number'], 3);
      DSMath.TypeCheck(iEulerOrder, false, String);

      var eulerOrder = iEulerOrder || 'ZXY';

      var angle1 = iEuler[0];
      var angle2 = iEuler[1];
      var angle3 = iEuler[2];

      var Cos1 = Math.cos(angle1); var Sin1 = Math.sin(angle1);
      var Cos2 = Math.cos(angle2); var Sin2 = Math.sin(angle2);
      var Cos3 = Math.cos(angle3); var Sin3 = Math.sin(angle3);

      var c = this.coef;

      if (eulerOrder === 'XYZ')
      {
        c[0] = Cos2 * Cos3; c[1] = -Cos2 * Sin3; c[2] = Sin2;
        c[3] = Cos1 * Sin3 + Cos3 * Sin1 * Sin2; c[4] = Cos1 * Cos3 - Sin1 * Sin2 * Sin3; c[5] = -Cos2 * Sin1;
        c[6] = Sin1 * Sin3 - Cos1 * Cos3 * Sin2; c[7] = Cos3 * Sin1 + Cos1 * Sin2 * Sin3; c[8] = Cos1 * Cos2;
      }
      else if (eulerOrder === 'YXZ')
      {
        c[0] = Cos1 * Cos3 + Sin1 * Sin2 * Sin3; c[1] = Cos3 * Sin1 * Sin2 - Cos1 * Sin3; c[2] = Cos2 * Sin1;
        c[3] = Cos2 * Sin3; c[4] = Cos2 * Cos3; c[5] = -Sin2;
        c[6] = Cos1 * Sin2 * Sin3 - Cos3 * Sin1; c[7] = Cos1 * Cos3 * Sin2 + Sin1 * Sin3; c[8] = Cos1 * Cos2;
      }
      else if (eulerOrder === 'XZY')
      {
        c[0] = Cos2 * Cos3; c[1] = -Sin2; c[2] = Cos2 * Sin3;
        c[3] = Sin1 * Sin3 + Cos1 * Cos3 * Sin2; c[4] = Cos1 * Cos2; c[5] = Cos1 * Sin2 * Sin3 - Cos3 * Sin1;
        c[6] = Cos3 * Sin1 * Sin2 - Cos1 * Sin3; c[7] = Cos2 * Sin1; c[8] = Cos1 * Cos3 + Sin1 * Sin2 * Sin3;
      }
      else if (eulerOrder === 'ZYX')
      {
        c[0] = Cos1 * Cos2; c[1] = Cos1 * Sin2 * Sin3 - Cos3 * Sin1; c[2] = Sin1 * Sin3 + Cos1 * Cos3 * Sin2;
        c[3] = Cos2 * Sin1; c[4] = Cos1 * Cos3 + Sin1 * Sin2 * Sin3; c[5] = Cos3 * Sin1 * Sin2 - Cos1 * Sin3;
        c[6] = -Sin2; c[7] = Cos2 * Sin3; c[8] = Cos2 * Cos3;
      }
      else if (eulerOrder === 'YZX')
      {
        c[0] = Cos1 * Cos2; c[1] = Sin1 * Sin3 - Cos1 * Cos3 * Sin2; c[2] = Cos3 * Sin1 + Cos1 * Sin2 * Sin3;
        c[3] = Sin2; c[4] = Cos2 * Cos3; c[5] = -Cos2 * Sin3;
        c[6] = -Cos2 * Sin1; c[7] = Cos1 * Sin3 + Cos3 * Sin1 * Sin2; c[8] = Cos1 * Cos3 - Sin1 * Sin2 * Sin3;
      }
      else // ZXY - default order
      {
        c[0] = Cos3 * Cos1 - (Sin2 * Sin3 * Sin1); c[1] = -Cos2 * Sin1; c[2] = Cos1 * Sin3 + (Cos3 * Sin2 * Sin1);
        c[3] = Cos1 * Sin2 * Sin3 + (Cos3 * Sin1); c[4] = Cos2 * Cos1; c[5] = Sin3 * Sin1 - (Cos3 * Cos1 * Sin2);
        c[6] = -Cos2 * Sin3; c[7] = Sin2; c[8] = Cos2 * Cos3;
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeDiagonal
    * @instance
    * @description
    * <i>This</i> matrix becomes a diagonal matrix with the coefs given.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @param {Number} iM22 The coef in row 2 column 2
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.makeDiagonal(9,10,11); // m1===m0 and m1=[9,0,0,0,10,0,0,0,11]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.makeDiagonal = function (iM00, iM11, iM22)
    {
      DSMath.TypeCheck(iM00, true, 'number');
      DSMath.TypeCheck(iM11, true, 'number');
      DSMath.TypeCheck(iM22, true, 'number');

      var c = this.coef;

      c[0] = iM00; c[1] = 0.; c[2] = 0.;
      c[3] = 0.; c[4] = iM11; c[5] = 0.;
      c[6] = 0.; c[7] = 0.; c[8] = iM22;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeScaling
    * @instance
    * @description
    * <i>This</i> matrix becomes a scaling matrix of the scale given.
    * @param {Number} iS The scale.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.makeScaling(3); // m1===m0 and m1=[3,0,0, 0,3,0, 0,0,3]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.makeScaling = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      return this.makeDiagonal(iS, iS, iS);
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method inverse
    * @instance
    * @description
    * Reverses <i>this</i> matrix.
    * <br>
    * The matrix stays unchanged if it can't be reversed.
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * m0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0, 1,0,0, 0,0,1]
    * var m1 = m0.inverse(); // m1===m0 and m1=[0,1,0, -1,0,0, 0,0,1]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.inverse = function ()
    {
      var c = this.coef;

      var a11 = c[0]; var a12 = c[1]; var a13 = c[2];
      var a21 = c[3]; var a22 = c[4]; var a23 = c[5];
      var a31 = c[6]; var a32 = c[7]; var a33 = c[8];

      var det = this.determinant();

      if (Math.abs(det) > DSMath.defaultTolerances.epsilonForSquareRelativeTest)
      {
        c[0] = (a22 * a33 - a32 * a23) / det;
        c[1] = (a32 * a13 - a12 * a33) / det;
        c[2] = (a12 * a23 - a22 * a13) / det;

        c[3] = (a31 * a23 - a21 * a33) / det;
        c[4] = (a11 * a33 - a31 * a13) / det;
        c[5] = (a21 * a13 - a11 * a23) / det;

        c[6] = (a21 * a32 - a31 * a22) / det;
        c[7] = (a31 * a12 - a11 * a32) / det;
        c[8] = (a11 * a22 - a21 * a12) / det;
      }

      return this;
    }

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getInverse
    * @instance
    * @description
    * Returns the inverse of <i>this</i> matrix.
    * <br>
    * If <i>this</i> matrix is not inversible, the returned matrix will be a copy of <i>this</i>
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * m0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0, 1,0,0, 0,0,1]
    * var m1 = m0.getInverse(); // m1!==m0 and m1=[0,1,0, -1,0,0, 0,0,1]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.prototype.getInverse = function (oM)
    {
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? oM.copy(this) : this.clone();
      return oM.inverse();
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method transpose
    * @instance
    * @description
    * Transposes <i>this</i> matrix.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.transpose(); // m1===m0 and m1=[0,3,6,1,4,7,2,5,8]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.transpose = function ()
    {
      var c = this.coef;

      c[1] = c[3] + (c[3] = c[1], 0);
      c[2] = c[6] + (c[6] = c[2], 0);
      c[5] = c[7] + (c[7] = c[5], 0);

      return this;
    }

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getTranspose
    * @instance
    * @description
    * Returns the transpose of <i>this</i> matrix.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation)
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.getTranspose(); // m1!==m0 and m1=[0,3,6,1,4,7,2,5,8]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.prototype.getTranspose = function (oM)
    {
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? oM.copy(this) : this.clone();
      return oM.transpose();
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method determinant
    * @instance
    * @description
    * Computes the determinant of <i>this</i> matrix.
    * @example
    * var m0 = new DSMath.Matrix3x3(1,2,3, 0,4,5, 0,0,6);
    * var detM0 = m0.determinant(); // detM0=24
    * @returns {Number} The determinant of the matrix.
    */
    Matrix3x3.prototype.determinant = function ()
    {
      var c = this.coef;
      var a11 = c[0]; var a12 = c[1]; var a13 = c[2];
      var a21 = c[3]; var a22 = c[4]; var a23 = c[5];
      var a31 = c[6]; var a32 = c[7]; var a33 = c[8];

      return ((a11 * a22 * a33 + a21 * a32 * a13 + a23 * a12 * a31) -
              (a31 * a22 * a13 + a11 * a23 * a32 + a21 * a12 * a33));
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method trace
    * @instance
    * @description
    * Computes the sum of the elements on the matrix diagonal.
    * @example
    * var m0 = new DSMath.Matrix3x3(1,2,3, 0,4,5, 0,0,6);
    * var traceM0 = m0.trace(); // traceM0=11
    * @returns {Number} The sum of the elements on the matrix diagonal.
    */
    Matrix3x3.prototype.trace = function ()
    {
      var c = this.coef;
      return ((c[0] + c[4] + c[8]));
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method infiniteNorm
    * @instance
    * @description
    * Returns the infinite norm of <i>this</i> matrix.
    * <br>
    * The infinite norm is the supremum of the absolute value of the coefficients.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,-5,-6,-7,-8);
    * var infNormM0 = m0.infiniteNorm(); // infNormM0=8
    * @returns {Number} The supremum of the absolute value of the 
    */
    Matrix3x3.prototype.infiniteNorm = function ()
    {
      var max = 0;

      for (var i = 0; i < 9; i++)
      {
        var c = this.coef[i];
        max = (max * max < c * c) ? Math.abs(c) : max;
      }

      return max;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getQuaternion
    * @instance
    * @description
    * Computes a unit quaternion q = [ s, x, y, z ] associated with <i>this</i> matrix.
    * <br>
    * This matrix has to be a rotation to retrieve a consistent result (<i>this</i>.isARotation()=true)
    * @param {DSMath.Quaternion} [oQ] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * m0.makeRotation(new DSMath.Vector3D(0,0,1), Math.PI/2);
    * var q0 = m0.getQuaternion(); // q0=[s=1/&#8730;2,x=0,y=0,z=1/&#8730;2]
    * @return {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.prototype.getQuaternion = function (oQ)
    {
      DSMath.TypeCheck(oQ, false, DSMath.Quaternion);

      oQ = oQ || new DSMath.Quaternion();

      var coef = this.coef;
      var trace1 = coef[0] + coef[4] + coef[8];

      if (trace1 > 0)
      {
        var scal = 2.0 * Math.sqrt(1. + trace1);
        oQ.s = 0.25 * scal;
        oQ.x = (coef[7] - coef[5]) / scal;
        oQ.y = (coef[2] - coef[6]) / scal;
        oQ.z = (coef[3] - coef[1]) / scal;
      }
      else if ((coef[0] > coef[4]) && (coef[0] > coef[8]))
      {
        var FourX = Math.sqrt(1.0 + coef[0] - coef[4] - coef[8]) * 2;
        oQ.s = (coef[7] - coef[5]) / FourX;
        oQ.x = 0.25 * FourX;
        oQ.y = (coef[1] + coef[3]) / FourX;
        oQ.z = (coef[2] + coef[6]) / FourX;
      }
      else if (coef[4] > coef[8])
      {
        var FourY = Math.sqrt(1.0 + coef[4] - coef[0] - coef[8]) * 2;
        oQ.s = (coef[2] - coef[6]) / FourY;
        oQ.x = (coef[1] + coef[3]) / FourY;
        oQ.y = 0.25 * FourY;
        oQ.z = (coef[5] + coef[7]) / FourY;
      }
      else
      {
        var FourZ = Math.sqrt(1.0 + coef[8] - coef[0] - coef[4]) * 2;
        oQ.s = (coef[3] - coef[1]) / FourZ;
        oQ.x = (coef[2] + coef[6]) / FourZ;
        oQ.y = (coef[5] + coef[7]) / FourZ;
        oQ.z = 0.25 * FourZ;
      }

      oQ.normalize();

      return oQ;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getEuler
    * @instance
    * @description
    * Computes the Euler angle (in radian) associated to <i>this</i> matrix of the provided order.
    * <br>
    * This matrix has to be a rotation to retrieve a consistent result (<i>this</i>.isARotation()=true)
    * @param {String} [iEOrder] The euler angles order (default ZXY).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0), Math.PI/2);
    * var eulerAngles = m0.getEuler(); // eulerAngles=[Az=-Math.PI/4, Ax=Math.PI/4, Ay=Math.PI/2]
    * @returns {Number[]} The array of euler angles.
    */
    Matrix3x3.prototype.getEuler = function (iEulerOrder)
    {
      DSMath.TypeCheck(iEulerOrder, false, String);

      var eulerOrder = iEulerOrder || 'ZXY';

      var oAngle1, oAngle2, oAngle3;
      var coefs = this.coef;
      var cosAngleTol = DSMath.defaultTolerances.epsilonForSqrtAngleTest * DSMath.constants.SQRT2;

      if (eulerOrder === 'XYZ')
      {
        oAngle2 = Math.asin(coefs[2]);
        var Cos2 = Math.cos(oAngle2);

        if (Math.abs(Cos2) > cosAngleTol)
        {
          oAngle3 = Math.atan2(-coefs[1], coefs[0]);
          oAngle1 = Math.atan2(-coefs[5], coefs[8]);
        } else
        {
          oAngle1 = Math.atan2(coefs[7], coefs[4]);
          oAngle3 = 0;
        }
      } else if (eulerOrder === 'YXZ')
      {
        oAngle2 = Math.asin(-coefs[5]);
        var Cos2 = Math.cos(oAngle2);

        if (Math.abs(Cos2))
        {
          oAngle3 = Math.atan2(coefs[3], coefs[4]);
          oAngle1 = Math.atan2(coefs[2], coefs[8]);
        } else
        {
          oAngle1 = Math.atan2(-coefs[6], coefs[0]);
          oAngle3 = 0;
        }
      } else if (eulerOrder === 'ZYX')
      {
        oAngle2 = Math.asin(-coefs[6]);
        var Cos2 = Math.cos(oAngle2);
        if (Math.abs(Cos2) > cosAngleTol)
        {
          oAngle1 = Math.atan2(coefs[3], coefs[0]);
          oAngle3 = Math.atan2(coefs[7], coefs[8]);
        } else
        {
          oAngle1 = Math.atan2(-coefs[1], coefs[4]);
          oAngle3 = 0;
        }
      } else if (eulerOrder === 'YZX')
      {
        oAngle2 = Math.asin(coefs[3]);
        var Cos2 = Math.cos(oAngle2);

        if (Math.abs(Cos2) > cosAngleTol)
        {
          oAngle1 = Math.atan2(-coefs[6], coefs[0]);
          oAngle3 = Math.atan2(-coefs[5], coefs[4]);
        } else
        {
          oAngle1 = Math.atan2(coefs[2], coefs[8]);
          oAngle3 = 0;
        }
      } else if (eulerOrder === 'XZY')
      {
        oAngle2 = Math.asin(-coefs[1]);
        var Cos2 = Math.cos(oAngle2);
        if (Math.abs(Cos2) > cosAngleTol)
        {
          oAngle1 = Math.atan2(coefs[7], coefs[4]);
          oAngle3 = Math.atan2(coefs[2], coefs[0]);
        } else
        {
          oAngle1 = Math.atan2(-coefs[5], coefs[8]);
          oAngle3 = 0;
        }
      } else
      { // Default order ZXY
        oAngle2 = Math.asin(coefs[7]);
        var CosX = Math.cos(oAngle2);

        if (Math.abs(CosX) > cosAngleTol)
        {
          var SinZ = -coefs[1] / CosX;  //double SinZ = -A12 / CosX;
          var CosZ = coefs[4] / CosX;   //double CosZ =  A22 / CosX;
          oAngle1 = Math.atan2(SinZ, CosZ); //  oAngle1 = CATAtan(SinZ, CosZ );
          var SinY = -coefs[6] / CosX;
          var CosY = coefs[8] / CosX;
          oAngle3 = Math.atan2(SinY, CosY);
        }
        else
        {
          oAngle2 = (coefs[7] > 0) ? Math.PI / 2.0 : -Math.PI / 2.0;
          oAngle3 = 0.;
          var SinZ = coefs[2] / coefs[7];
          var CosZ = coefs[0];
          oAngle1 = Math.atan2(SinZ, CosZ);
        }
      }

      var v1 = [oAngle1, oAngle2, oAngle3];

      return v1;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method getScale
    * @instance
    * @description
    * Computes the scale performed by <i>this</i> matrix.
    * <br>
    * The scale equals Math.pow(<i>this</i>.determinant(),1./3.). It only has a meaning if <i>this</i>.isScaling() is true.
    * @example
    * var m0 = DSMath.Matrix3x3.makeScaling(5);
    * var m1 = new DSMath.Matrix3x3(1,1,1,0,1,0,0,0,2);
    * var m0Scale = m0.getScale(); //m0Scale=5
    * var m1Scale = m1.getScale(); //m1Scale=&#8731;2 but m1.isScaling()=false so it is hard to interpretate.
    * @returns {Number} The scale value of the scaling made by <i>this</i> matrix. The scale is negative if <i>this</i> matrix does a reflexion.
    */
    Matrix3x3.prototype.getScale = function ()
    {
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var epsilongRel = DSMath.defaultTolerances.epsilonForRelativeTest;
      var det = this.determinant();

      var scale = 0;
      if (Math.abs(det) >= epsilongRel)
      {
        scale = (Math.abs(Math.abs(det) - 1) <= 3 * epsgRel) ? 1 : Math.pow(Math.abs(det), 1. / 3.);
        scale *= (det > 0) ? 1 : -1;
      }

      return scale;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isOrthogonal
    * @instance
    * @description
    * Determines whether the matrix contains orthogonal vectors.
    * <br>
    * The vectors can not be normalized. If the norm is null then vectors are considered as orthogonal.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,-5,-6,-7,-8);
    * var m1 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var m0IsOrtho = m0.isOrthogonal(); // m0IsOrtho==false
    * var m1IsOrtho = m1.isOrthogonal(); // m1IsOrtho==true
    * @returns {Boolean} true if <i>this</i> contains orthogonal vectors, false otherwise.
    */
    Matrix3x3.prototype.isOrthogonal = function ()
    {
      var c = this.coef;

      var sqEpsRel = DSMath.defaultTolerances.epsgForSquareRelativeTest;

      var sqNormC0 = c[0] * c[0] + c[3] * c[3] + c[6] * c[6];
      var sqNormC1 = c[1] * c[1] + c[4] * c[4] + c[7] * c[7];
      var sqNormC2 = c[2] * c[2] + c[5] * c[5] + c[8] * c[8];

      var dotC0C1 = c[0] * c[1] + c[3] * c[4] + c[6] * c[7];
      var dotC0C2 = c[0] * c[2] + c[3] * c[5] + c[6] * c[8];
      var dotC1C2 = c[1] * c[2] + c[4] * c[5] + c[7] * c[8];

      var isOrthogonal = ((dotC0C1 * dotC0C1 <= sqEpsRel * sqNormC0 * sqNormC1) &&
                          (dotC0C2 * dotC0C2 <= sqEpsRel * sqNormC0 * sqNormC2) &&
                          (dotC1C2 * dotC1C2 <= sqEpsRel * sqNormC1 * sqNormC2));

      return isOrthogonal;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isScaling
    * @instance
    * @description
    * Determines whether the matrix performs a scaling or not.
    * <br>
    * The matrix performs a scaling if it contains orthogonal vectors of the same non null norm.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs a scaling.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,-5,-6,-7,-8);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,-2,0, 0,0,-2);
    * var m0IsScaling = m0.isScaling(); // m0IsScaling==false
    * var m1IsScaling = m1.isScaling(); // m1IsScaling==true
    * @returns {Boolean} true if <i>this</i> performs a scaling, false otherwise.
    */
    Matrix3x3.prototype.isScaling = function (oS)
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
          var sqNormC0 = c[0] * c[0] + c[3] * c[3] + c[6] * c[6];
          var sqNormC1 = c[1] * c[1] + c[4] * c[4] + c[7] * c[7];
          var sqNormC2 = c[2] * c[2] + c[5] * c[5] + c[8] * c[8];

          isScaling = ((Math.abs(sqNormC0 / sqNorm - 1) < 2 * epsgRel + sqEpsgRel) &&
                        (Math.abs(sqNormC1 / sqNorm - 1) < 2 * epsgRel + sqEpsgRel) &&
                        (Math.abs(sqNormC2 / sqNorm - 1) < 2 * epsgRel + sqEpsgRel));
        }
      }

      return isScaling;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isReflecting
    * @instance
    * @description
    * Determines whether the matrix performs a reflection or not.
    * <br>
    * The matrix performs a reflection if it contains orthogonal vectors of the same non null norm and has a negative determinant.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,-2);
    * var m0IsReflecting = m0.isReflecting(); // m0IsReflecting==false
    * var m1IsReflecting = m1.isReflecting(); // m1IsReflecting==true
    * @returns {Boolean} true if <i>this</i> performs a reflection, false otherwise.
    */
    Matrix3x3.prototype.isReflecting = function ()
    {
      var isReflecting = this.isScaling();
      isReflecting = (isReflecting && this.determinant() < 0);
      return isReflecting;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isAnIsometry
    * @instance
    * @description
    * Determines whether the matrix is an isometry or not.
    * @param {Object} [oD] Fill the properties "direct" of oD if <i>this</i> is an isometry matrix (true if direct, false otherwise).
    * @example
    * var m0 = new DSMath.Matrix3x3();
    * m0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0, 1,0,0, 0,0,1]
    * var m1 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m0isAnIsometry = m0.isAnIsometry(); // m0isAnIsometry==true
    * var m1isAnIsometry = m1.isAnIsometry(); // m1isAnIsometry==false
    * @returns {Boolean} true if <i>this</i> is an isometry, false otherwise.
    */
    Matrix3x3.prototype.isAnIsometry = function (oD)
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
        var sqNormC0 = c[0] * c[0] + c[3] * c[3] + c[6] * c[6];
        var sqNormC1 = c[1] * c[1] + c[4] * c[4] + c[7] * c[7];
        var sqNormC2 = c[2] * c[2] + c[5] * c[5] + c[8] * c[8];

        isAnIsometry = ((Math.abs(sqNormC0 - 1) < 2 * epsgRel + sqEpsgRel) &&
                       (Math.abs(sqNormC1 - 1) < 2 * epsgRel + sqEpsgRel) &&
                       (Math.abs(sqNormC2 - 1) < 2 * epsgRel + sqEpsgRel));

        if (isAnIsometry && oD) oD.direct = (det > 0);
      }

      return isAnIsometry;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isAScaling
    * @instance
    * @description
    * Determines whether the matrix is only a scaling matrix or not.
    * <br>
    * The matrix is only a scaling if it only contains diagonal coefs of the same non null value.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs at least a scaling.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,-2,0, 0,0,-2);
    * var m0IsAScaling = m0.isAScaling(); // m0IsAScaling==true
    * var m1IsAScaling = m1.isAScaling(); // m1IsAScaling==false
    * @returns {Boolean} true if <i>this</i> is only a scaling, false otherwise.
    */
    Matrix3x3.prototype.isAScaling = function (oS)
    {
      DSMath.TypeCheck(oS, false, Object);

      oS = oS || { scale: 1 };
      var isAScaling = false;

      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;

      if (this.isScaling(oS))
      {
        var trace = this.trace();
        isAScaling = (trace > 0 && Math.abs(trace - 3 * oS.scale) <= Math.max(trace, 1) * epsgRel);
      }

      return isAScaling;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method isARotation
    * @instance
    * @description
    * Determines whether the matrix is only a rotation matrix or not.
    * <br>
    * The matrix is only a rotation if it is a direct isometry.
    * @param {RotationData} [oRotationData] Filled if given.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(0,-1,0, 1,0,0, 0,0,1);
    * var m2 = new DSMath.Matrix3x3(-1,0,0 ,0,1,0, 0,0,1);
    * var m1Data = {angle:0, vector:new DSMath.Vector3D()};
    * var m0IsARotation = m0.isARotation();       // m0IsARotation==false
    * var m1IsARotation = m1.isARotation(m1Data); // m1IsARotation==true and m1Data={angle:PI/2,vector:[0,0,1]};
    * var m2IsARotation = m2.isARotation();       // m2IsARotation==false
    * @returns {Boolean} true if <i>this</i> is only a rotation, false otherwise.
    */
    Matrix3x3.prototype.isARotation = function (oRotationData)
    {
      DSMath.TypeCheck(oRotationData, false, Object);

      var direct = { direct: false };
      var isARotation = this.isAnIsometry(direct);
      isARotation = (isARotation && direct.direct);

      if (isARotation && oRotationData)
      {
        oRotationData.angle = 0;
        oRotationData.vector = (oRotationData.vector.constructor == Vector3D) ? oRotationData.vector : new DSMath.Vector3D();
        this.getQuaternion().getRotationData(oRotationData);
      }

      return isARotation;
    }

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method add
    * @instance
    * @description
    * Adds a given matrix to <i>this</i> matrix.
    * @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be added.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
    * var m3 = m0.add(m1); // m3===m0 and m3=[8,8,8,8,8,8,8,8,8]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.add = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);
      
      var c = this.coef;
      var m = iM.coef;

      for (var i = 0; i < 9; i++)
      {
        c[i] += m[i];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method sub
    * @instance
    * @description
    * Subtracts a given Matrix3x3 to <i>this</i> matrix.
    * @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be subtracted.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
    * var m3 = m0.sub(m1); // m3===m0 and m3=[-8,-6,-4,-2, 0 , 2, 4, 6, 8]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.sub = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);

      var c = this.coef;
      var m = iM.coef;

      for (var i = 0; i < 9; i++)
      {
        c[i] -= m[i];
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method multiply
    * @instance
    * @description
    * Multiplies a given Matrix3x3 to <i>this</i> matrix.
    * @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be multiplied.
    * @param {Boolean} [iLeft=false] false if the multiplication is made on the right of <i>this</i>, true otherwise.
    * @example
    * var s0 = new DSMath.Matrix3x3();
    * s0.makeDiagonal(1,2,3);
    * var r0 = new DSMath.Matrix3x3();
    * r0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var m = r0.multiply(s0); // m===r0 and m=[0,-2,0, 1,0,0, 0,0,3]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.multiply = function (iM, iLeft)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(iLeft, false, Boolean);

      iLeft = iLeft || false;

      var c = this.coef;
      var m = iM.coef;
      var m00 = m[0]; var m01 = m[1]; var m02 = m[2];
      var m10 = m[3]; var m11 = m[4]; var m12 = m[5];
      var m20 = m[6]; var m21 = m[7]; var m22 = m[8];

      if (!iLeft)
      {
        for (var i = 0; i < 3; i++)
        {
          var idS = 3 * i;
          var t0 = c[idS];
          var t1 = c[idS + 1];
          var t2 = c[idS + 2];

          c[idS] = t0 * m00 + t1 * m10 + t2 * m20;
          c[idS + 1] = t0 * m01 + t1 * m11 + t2 * m21;
          c[idS + 2] = t0 * m02 + t1 * m12 + t2 * m22;
        }
      } else
      {
        for (var i = 0; i < 3; i++)
        {
          var t0 = c[i];
          var t1 = c[3 + i];
          var t2 = c[6 + i];

          c[i] = m00 * t0 + m01 * t1 + m02 * t2;
          c[3 + i] = m10 * t0 + m11 * t1 + m12 * t2;
          c[6 + i] = m20 * t0 + m21 * t1 + m22 * t2;
        }
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method multiplyScalar
    * @instance
    * @description
    * Multiplies each coefficient of <i>this</i> matrix by a scalar.
    * @param {Number} iS The scalar.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = m0.multiplyScalar(2); // m1===m0 and m1=[0,2,4,6,8,10,12,14,16]
    * @returns {DSMath.Matrix3x3} <i>this</i> modified matrix reference
    */
    Matrix3x3.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      var c = this.coef;

      c[0] *= iS; c[1] *= iS; c[2] *= iS;
      c[3] *= iS; c[4] *= iS; c[5] *= iS;
      c[6] *= iS; c[7] *= iS; c[8] *= iS;

      return this;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */
    /**
    * @public
    * @name identity
    * @type {DSMath.Matrix3x3}
    * @readonly
    * @memberOf DSMath.Matrix3x3
    * @description The identity matrix [1,0,0, 0,1,0, 0,0,1]
    */
    Object.defineProperty(Matrix3x3, "identity", {
      value: new Matrix3x3(1, 0, 0, 0, 1, 0, 0, 0, 1),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Matrix3x3.identity); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeRotation
    * @static
    * @description
    * Creates a matrix equals to the rotation by the angle around the axis given.
    * @param {DSMath.Vector3D} iAxis  The axis of the rotation.
    * @param {Number}                       iAngle The angle of the rotation
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0,1,0,0,0,0,1]
    * @returns {DSMath.Matrix3x3} The created matrix.
    */
    Matrix3x3.makeRotation = function (iAxis, iAngle)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');

      var result = new Matrix3x3();
      return result.makeRotation(iAxis, iAngle);
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeRotationFromEuler
    * @static
    * @description
    * Creates a matrix equals to the rotation combinaison defined from euler angles.
    * @param {Number[]} iE The array of euler angles ordered as the iEOrder provided.
    * @param {String} [iEOrder] The euler angle order (default ZXY).
    * @example
    * var m0 = DSMath.Matrix3x3.makeRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2]);
    * // m0=|0.5, 0.5, 1/&#8730;2|
    * //    |0.5, 0.5,-1/&#8730;2|
    * //    |-1/&#8730;2, 1/&#8730;2, 0|
    * @returns {DSMath.Matrix3x3} The created matrix.
    */
    Matrix3x3.makeRotationFromEuler = function (iEuler, iEulerOrder)
    {
      DSMath.TypeCheck(iEuler, true, ['number'], 3);
      DSMath.TypeCheck(iEulerOrder, false, String);

      var result = new Matrix3x3();
      return result.makeRotationFromEuler(iEuler, iEulerOrder);
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeDiagonal
    * @static
    * @description
    * Creates a diagonal matrix from the three given values.
    * @param {Number} iM00 The coef in row 0 column 0
    * @param {Number} iM11 The coef in row 1 column 1
    * @param {Number} iM22 The coef in row 2 column 2
    * @example
    * var m0 = DSMath.Matrix3x3.makeDiagonal(9,10,11); //m0=[9,0,0,0,10,0,0,0,11]
    * @returns {DSMath.Matrix3x3} The created matrix.
    */
    Matrix3x3.makeDiagonal = function (iM00, iM11, iM22)
    {
      DSMath.TypeCheck(iM00, true, 'number');
      DSMath.TypeCheck(iM11, true, 'number');
      DSMath.TypeCheck(iM22, true, 'number');

      var result = new Matrix3x3();
      return result.makeDiagonal(iM00, iM11, iM22);
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method makeRotation
    * @static
    * @description
    * Creates a scaling matrix from the scalar given.
    * @param {Number} iS The scale.
    * @example
    * var m0 = DSMath.Matrix3x3.makeScaling(3); // m0=[3,0,0, 0,3,0, 0,0,3]
    * @returns {DSMath.Matrix3x3} The created matrix.
    */
    Matrix3x3.makeScaling = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      var result = new Matrix3x3();
      return result.makeScaling(iS);
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method add
    * @static
    * @description
    * Adds two given matrix.
    * @param {DSMath.Matrix3x3} iM1  The matrix to add.
    * @param {DSMath.Matrix3x3} iM2  The matrix to add.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
    * var m3 = DSMath.Matrix3x3.add(m0,m1); // m3!==m0 and m3=[8,8,8,8,8,8,8,8,8]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.add = function (iM1, iM2, oM)
    {
      DSMath.TypeCheck(iM1, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(iM2, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? oM : new Matrix3x3();

      var c = oM.coef;
      var m1 = iM1.coef;
      var m2 = iM2.coef;

      for (var i = 0; i < 9; i++)
      {
        c[i] = m1[i] + m2[i];
      }

      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method sub
    * @static
    * @description
    * Substract two given matrix.
    * @param {DSMath.Matrix3x3} iM1 The matrix.
    * @param {DSMath.Matrix3x3} iM2 The matrix to substract from iM1.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
    * var m3 = DSMath.Matrix3x3.sub(m0, m1); // m3===m0 and m3=[-8,-6,-4,-2, 0 , 2, 4, 6, 8]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.sub = function (iM1, iM2, oM)
    {
      DSMath.TypeCheck(iM1, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(iM2, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? oM : new Matrix3x3();

      var c = oM.coef;
      var m1 = iM1.coef;
      var m2 = iM2.coef;

      for (var i = 0; i < 9; i++)
      {
        c[i] = m1[i] - m2[i];
      }

      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method multiply
    * @static
    * @description
    * Multiplies two given matrix.
    * @param {DSMath.Matrix3x3} iMLeft The matrix on the left of the multiplication.
    * @param {DSMath.Matrix3x3} iMRight The matrix on the right of the multiplication.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var s0 = new DSMath.Matrix3x3();
    * s0.makeDiagonal(1,2,3);
    * var r0 = new DSMath.Matrix3x3();
    * r0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var m = DSMath.Matrix3x3.multiply(r0,s0); // m!=r0 and m=[0,-2,0, 1,0,0, 0,0,3]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.multiply = function (iMLeft, iMRight, oM)
    {
      DSMath.TypeCheck(iMLeft, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(iMRight, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? (oM === iMRight) ? oM.multiply(iMLeft, true) : oM.copy(iMLeft).multiply(iMRight)
               : iMLeft.clone().multiply(iMRight);
      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Matrix3x3
    * @method multiplyScalar
    * @static
    * @description
    * Multiplies each coefficient of a given matrix by a scalar.
    * @param {DSMath.Matrix3x3} iM The matrix.
    * @param {Number} iS The scalar.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
    * var m1 = DSMath.Matrix3x3.multiplyScalar(m0,2); // m1!=m0 and m1=[0,2,4,6,8,10,12,14,16]
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Matrix3x3.multiplyScalar = function (iM, iS, oM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = (oM) ? oM.copy(iM) : iM.clone();
      return oM.multiplyScalar(iS);
    };

    DSMath.Matrix3x3 = Matrix3x3;

    return Matrix3x3;
  }
);
