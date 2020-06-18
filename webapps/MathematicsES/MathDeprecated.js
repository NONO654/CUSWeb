
define('MathematicsES/MathDeprecated',['MathematicsES/MathNameSpace'       ,
                                       'MathematicsES/MathAxisJSImpl'      ,
                                       'MathematicsES/MathLineJSImpl'      ,
                                       'MathematicsES/MathMat3x3JSImpl'    ,
                                       'MathematicsES/MathPlaneJSImpl'     ,
                                       'MathematicsES/MathPointJSImpl'     ,
                                       'MathematicsES/MathQuaternionJSImpl',
                                       'MathematicsES/MathVector2DJSImpl'  ,
                                       'MathematicsES/MathVector3DJSImpl'  ,
                                       'MathematicsES/MathCircleJSImpl'    ,
                                       'MathematicsES/TransformationJSImpl'], function (DSMath) {
  'use strict';

// ============================================================ //
//                     VECTOR2D METHODS                         //
// ============================================================ //
/**
* @private
* @deprecated R419
* @memberof DSMath.Vector2D
* @method addVectorToVector
* @instance
* @description Adds two 2D vectors. The input vector is modified.
* @param {DSMath.Vector2D} v The vector to add.
* @example 
* var v0 = new DSMath.Vector2D(1,2);
* var v1 = new DSMath.Vector2D(4,5);
* var v2 = v1.addVectorToVector(v0); // v2===v1 is true.
* @returns {DSMath.Vector2D} this modified vector reference.
*/
DSMath.Vector2D.prototype.addVectorToVector = function (v) {
   return this.add(v);
};

/**
* @private
* @deprecated R419
* @memberof DSMath.Vector2D
* @method subVectorFromVector
* @instance
* @description Sub two 2D vectors. The input vector is modified.
* @param {DSMath.Vector2D} v The vector to sub.
* @example 
* var v0 = new DSMath.Vector3D(1,2);
* var v1 = new DSMath.Vector3D(4,5);
* var v2 = v1.subVectorFromVector(v0); // v2===v1 is true.
* @returns {DSMath.Vector2D} this modified vector reference.
*/
DSMath.Vector2D.prototype.subVectorFromVector = function (v) {
   return this.sub(v);
};

/**
* @private
* @deprecated R419
* @memberof DSMath.Vector2D
* @method cross2D
* @instance
* @description Computes the cross product of two vectors.
* @param {DSMath.Vector2D} iV The Vector3D to be cross-multiplied by <i>this</i>.
* @example
* var v0 = DSMath.Vector2D.xVect;
* var v1 = DSMath.Vector2D.yVect;
* var crossProd = v0.cross2D(v1); // crossProd=1.0
* @returns {Number } The cross product of <i>this</i> and iV.
*/
DSMath.Vector2D.prototype.cross2D = function (iV) {
    var c_out = this.x*iV.y -this.y*iV.x;
    return c_out;
};


/**
* @private
* @deprecated R419
* @see DSMath.Vector2D#multiplyScalar
* @memberof DSMath.Vector2D
* @method multiplyVector
* @instance
* @description Multiplies a 2D vector by a scalar.
* @param {Number} s The scalar.
* @example
* var v0 = new DSMath.Vector2D(1.0, 0);
* var v1 = v0.multiplyVector(10.0); // v0===v1 and v0=(10,0)
* @returns {DSMath.Vector2D} this modified vector reference
*/
DSMath.Vector2D.prototype.multiplyVector = function (s) {
    return this.multiplyScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector2D#divideScalar
* @memberof DSMath.Vector2D
* @method divideVector
* @instance
* @description Divide a 2D vector by a scalar.
* @param {Number} s The scalar.
* @example
* var v0 = new DSMath.Vector2D(1.0, 0);
* var v1 = v0.divideVector(10.0); // v0===v1 and v0=(0.1,0)
* @returns {DSMath.Vector2D}
*/
DSMath.Vector2D.prototype.divideVector = function (s) {
   return this.divideScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector2D#isEqual
* @memberof DSMath.Vector2D
* @method vectEquals
* @instance
* @description Compares two vectors for equality.
* @param {DSMath.Vector2D} iV Vector2D to be compared with <i>this</i>.
* @param {Number} [iTol] The comparaison accuracy. If not given, strict comparaison is performed.
* @example
* var v1 = new DSMath.Vector2D(1.0011,0);
* var v2 = new DSMath.Vector2D(1.0001,0);
* var vX = DSMath.Vector2D.xVect;
* var boolV1VX = v1.vectEquals(vX, 0.001); // boolV1VX = FALSE;
* var boolV2VX = v2.vectEquals(vX, 0.001); // boolV2VX = TRUE;
* @returns {Number} true if the vectors have equal coordinates at the given tolerance, false otherwise.
*/
DSMath.Vector2D.prototype.vectEquals = function (v, d) {
   return this.isEqual(v, d);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector2D#set
* @memberof DSMath.Vector2D
* @method setCoord
* @instance
* @description Assigns new coordinates values to a 2D vector.
* @param {Number} iX Value for the x coordinate.
* @param {Number} iY Value for the y coordinate.
* @example
* var v0 = new DSMath.Vector2D();
* v0.setCoord(1.0, 2.0);
* @returns {DSMath.Vector2D }
*/
DSMath.Vector2D.prototype.setCoord = function (a, b) {
   this.x = a;
   this.y = b;
   return this;
};


// --------------------------- STATIC -------------------------------------- 
/**
* @private
* @deprecated R419
* @description Normalizes a 2D vector.
* @memberof DSMath
* @method normalize2D
* @instance
* @example
* var v1 = new DSMath.Vector2D();
* v1.setCoord(0.5, 0.1);
* DSMath.normalize2D(v1);
* @returns {DSMath.Vector2D}
*/
DSMath.normalize2D = function (v, v_out) {
   v_out = (arguments.length<2)? v.clone() : v_out.copy(v);
   return v_out.normalize();
};

/**
* @private
* @deprecated
* @description Adds two 2D vectors.
* @param {DSMath.Vector2D} v1 The first vector.
* @param {DSMath.Vector2D} v2 The second vector.
* @memberof DSMath
* @method addVectorToVector2D
* @instance
* @example
* var v0 = new DSMath.Vector2D(1,2);
* var v1 = new DSMath.Vector2D(3,4);
* var v0Plusv1 = DSMath.addVectorToVector2D(v0, v1);
* @returns {DSMath.Vector2D}
*/
DSMath.addVectorToVector2D = function (v1, v2, v_out) {
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.add(v2);
};

/**
* @private
* @deprecated
* @description Substracts a 2D vector from a 2D vector and returns a new vector.
* @param {DSMath.Vector2D} v1 The first vector.
* @param {DSMath.Vector2D} v2 The second vector.
* @memberof DSMath
* @method subVectorFromVector2D
* @instance
* @example
* var v0 = new DSMath.Vector2D(1,2);
* var v1 = new DSMath.Vector2D(3,4);
* var v0Minusv1 = DSMath.subVectorFromVector2D(v0, v1);
* @returns {DSMath.Vector2D}
*/
DSMath.subVectorFromVector2D = function (v1, v2, v_out) {
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.sub(v2);
};


/**
* @private
* @deprecated
* @description Computes the dot product of two Vector2D
* @param {DSMath.Vector2D} v1 The first vector.
* @param {DSMath.Vector2D} v2 The second vector.
* @memberof DSMath
* @method dot2D
* @instance
* @example
* var v0 = new DSMath.Vector2D(1,2);
* var v1 = new DSMath.Vector2D(3,4);
* var crossProd = DSMath.dot2D(v0, v1);
* @returns {Number } The dot product of v1 and v2.
*/
DSMath.dot2D = function (v1, v2, d_out) {
    var d_out = v1.x * v2.x + v1.y * v2.y ;
    return d_out;
};

/**
* @private
* @deprecated R419
* @description Reverses the direction of a 2D vector and returns a new vector.
* @param {DSMath.Vector2D} v1 The vector to be reversed.
* @memberof DSMath
* @method negate2D
* @instance
* @example
* var v0 = DSMath.Vector2D.xVect;
* var v1 = DSMath.negate2D(v0); // v1!==v0 and v1=(-1,0).
* @returns {DSMath.Vector2D}
*/
DSMath.negate2D = function (v1, v_out) {
    if (arguments.length < 2) v_out = new DSMath.Vector2D();
    v_out.x = -v1.x;
    v_out.y = -v1.y;
    return v_out;
};

/**
* @private
* @deprecated R419
* @description Multiplies a 2D vector by a scalar.
* @param {DSMath.Vector2D} v1 vector to be multiplied.
* @param {Number} s The scalar.
* @memberof DSMath
* @method multiplyVector2D
* @instance
* @example
* var v0 = DSMath.Vector2D.xVect;
* var v1 = DSMath.multiplyVector2D(v0, 10.0); // v0=(1,0) and v1=(10,0)
* @returns {DSMath.Vector2D}
*/
DSMath.multiplyVector2D = function (v1, s, v_out) {
    if (arguments.length < 3) v_out = new DSMath.Vector2D();
    v_out.x = v1.x * s;
    v_out.y = v1.y * s;
    return v_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector2D#divideScalar
* @description Divides a Vector2D by a scalar.
* @param {DSMath.Vector2D} v1 vector to be divided.
* @param {Number} s The scalar.
* @memberof DSMath
* @method divideVector2D
* @instance
* @example
* var v0 = DSMath.Vector2D.xVect;
* var v1 = DSMath.divideVector2D(v0, 0.5); // v0=(1,0) and v1=(2,0)
* @returns {DSMath.Vector2D}
*/
DSMath.divideVector2D = function (v1, s, v_out) {
    if (arguments.length < 3) v_out = new DSMath.Vector2D();
    v_out.x = v1.x / s;
    v_out.y = v1.y / s;
    return v_out;
};

// ============================================================ //
//                     VECTOR3D METHODS                         //
// ============================================================ //
/**
* @private
* @deprecated R419
* @memberof DSMath.Vector3D
* @method addVectorToVector
* @instance
* @description Add iV vector to this vector.
* @param {DSMath.Vector3D} iV The vector to add.
* @example
* var v0 = new DSMath.Vector3D(1,2,3);
* var v1 = new DSMath.Vector3D(4,5,6);
* var v2 = v1.addVectorToVector(v0); // v2===v1 is true.
* @returns {DSMath.Vector3D} this modified vector reference.
*/
DSMath.Vector3D.prototype.addVectorToVector = function (iV) {
   return this.add(iV);
};

/**
* @private
* @deprecated R419
* @memberof DSMath.Vector3D
* @method subVectorFromVector
* @instance
* @description Substracts two 3D vectors. The input vector is modified.
* @param {DSMath.Vector3D} v The vector to be substracted.
* @example
* var v0 = new DSMath.Vector3D(1,2,3);
* var v1 = new DSMath.Vector3D(4,5,6);
* var v2 = v0.subVectorFromVector(v1); // v2===v0 is true and v2=v0-v1=(-3,-3,-3);
* @returns {DSMath.Vector3D}
*/
DSMath.Vector3D.prototype.subVectorFromVector = function (v) {
   return this.sub(v);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#multiplyScalar
* @memberof DSMath.Vector3D
* @method multiplyVector
* @instance
* @description Multiplies a 3D vector by a scalar.
* @param {Number} s The scalar.
* @example
* var v1 = new DSMath.Vector3D(1,2,3);
* var v2 = v1.multiplyVector(2); // v1=v2=(2,4,6);
* @returns {DSMath.Vector3D} 
*/
DSMath.Vector3D.prototype.multiplyVector = function (s) {
   return this.multiplyScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#divideScalar
* @memberof DSMath.Vector3D
* @method divideVector
* @instance
* @description Divide a 3D vector by a scalar.
* @param {Number} s The scalar.
* @example
* var v1 = new DSMath.Vector3D(1,0,0);
* var v2 = v1.divideVector(2); // v1===v2 and v1=(0.5,0,0);
* @returns {DSMath.Vector3D} 
*/
DSMath.Vector3D.prototype.divideVector = function (s) {
   return this.divideScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#set
* @memberof DSMath.Vector3D
* @method setCoord
* @instance
* @description Assigns new coordinates values to a 3D vector.
* @param {Number} a Value for the x coordinate.
* @param {Number} b Value for the y coordinate.
* @param {Number} c Value for the z coordinate.
* @example
* var v0 = new DSMath.Vector3D();
* v0.setCoord(1.0, 2.0, 3.0);
* @returns {DSMath.Vector3D }
*/
DSMath.Vector3D.prototype.setCoord = function (a, b, c) {
    this.x = a;
    this.y = b;
    this.z = c;
};


// --------------------------- STATIC -------------------------------------- 
/**
* @private
* @deprecated R419
* @description Normalizes a 3D vector.
* @memberof DSMath
* @method normalize
* @instance
* @example
* var v1 = new DSMath.Vector3D();
* v1.setCoord(0.5, 0.1, 0.0);
* DSMath.normalize(v1);
* @returns {DSMath.Vector3D} 
*/
DSMath.normalize = function (v, v_out) {
   v_out = (arguments.length<2)? v.clone() : v_out.copy(v);
   return v_out.normalize();
};

/**
* @private
* @deprecated R419
* @description Adds two 3D vectors.
* @param {DSMath.Vector3D} v1 The first vector.
* @param {DSMath.Vector3D} v2 The second vector.
* @memberof DSMath
* @method addVectorToVector
* @instance
* @example
* var v0 = new DSMath.Vector3D(1,2,3);
* var v1 = new DSMath.Vector3D(4,5,6);
* var v2 = DSMath.addVectorToVector(v0, v1); // v2!=v0 and v2=v0+v1=(5,7,9);
* @returns {DSMath.Vector3D} 
*/
DSMath.addVectorToVector = function (v1, v2, v_out) {
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.add(v2);
};

/**
* @private
* @deprecated R419
* @description Substracts a 3D vector from a 3D vector and returns a new vector.
* @param {DSMath.Vector3D} v1 The first vector.
* @param {DSMath.Vector3D} v2 The vector to be substracted.
* @memberof DSMath
* @method subVectorFromVector
* @instance
* @example
* var v0 = new DSMath.Vector3D(1,2,3);
* var v1 = new DSMath.Vector3D(4,5,6);
* var v2 = DSMath.subVectorFromVector(v0, v1); // v2!=v1 and v2=v0-v1=(-3,-3,-3);
* @returns {DSMath.Vector3D} 
*/
DSMath.subVectorFromVector = function (v1, v2, v_out) {
   /*
   * Keep old code to avoid KO from studio who calls this method with v1={x,y,z} instead of a vector...
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.sub(v2);
   */
   if(arguments.length<3) v_out = new DSMath.Vector3D();
   v_out.x = v1.x - v2.x;
   v_out.y = v1.y - v2.y;
   v_out.z = v1.z - v2.z;

   return v_out;
};

/**
* @private
* @deprecated R419
* @description Reverses the direction of a 3D vector and returns a new vector. 
* @param {DSMath.Vector3D} v1 The vector to be reversed.
* @memberof DSMath
* @method negate
* @instance
* @example
* var v1 = DSMath.Vector3D.xVect;
* var v2 = DSMath.negate(v1); // v1 = (1, 0, 0) and  v2=(-1, 0, 0)
* @returns {DSMath.Vector3D}
*/
DSMath.negate = function (v1, v_out) {
/*
 Keep old code to avoid KO from studio who calls this method with v1={x,y,z} instead of a vector...
   v_out = (arguments.length<2)? v1.clone() : v_out.copy(v1);
   return v_out.negate();
*/
   if(arguments.length<2)
      v_out = new DSMath.Vector3D(v1.x, v1.y, v1.z);

   v_out.x *= -1;
   v_out.y *= -1;
   v_out.z *= -1;
   return v_out;
};

/**
* @private
* @deprecated R419
* @description Multiplies a 3D vector by a scalar.
* @param {DSMath.Vector3D} v1 vector to be multiplied.
* @param {Number} s The scalar.
* @memberof DSMath
* @method multiplyVector
* @instance
* @example
* var v1 = new DSMath.Vector3D(1,2,3);
* var v2 = DSMath.multiplyVector(v1, 2); // v2=(2,4,6);
* @returns {DSMath.Vector3D} 
*/
DSMath.multiplyVector = function (v1, s, v_out) {
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.multiplyScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#divideScalar
* @description Divides a Vector3D by a scalar.
* @param {DSMath.Vector3D} v1 vector to be divided.
* @param {Number} s The scalar.
* @memberof DSMath
* @method divideVector
* @instance
* @example
* var v1 = DSMath.Vector3D.xVect;
* var v2 = DSMath.divideVector(v1, 2); // v2=(0.5,0,0);
* @returns {DSMath.Vector3D}
*/
DSMath.divideVector = function (v1, s, v_out) {
   v_out = (arguments.length<3)? v1.clone() : v_out.copy(v1);
   return v_out.divideScalar(s);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#cross
* @description Computes the cross product of two vectors.
* @param {DSMath.Vector3D} v1 First vector.
* @param {DSMath.Vector3D} v2 Second vector.
* @memberof DSMath
* @method cross
* @instance
* @example
* var v1 = DSMath.Vector3D.xVect.clone(); // v1=(1,0,0)
* var v2 = DSMath.Vector3D.yVect.clone(); // v2=(0,1,0)
* var v3 = DSMath.Vector3D.cross(v1, v2); // v3=(0,0,1)
* @returns {DSMath.Vector3D } The cross product of v1 and v2.
*/
DSMath.cross = function (v1, v2, v_out) {
   /*
   * Keep old code to avoid KO from studio who calls this method with v1={x,y,z} instead of a vector...
   v_out = (arguments.length < 3)? v1.clone() : v_out.copy(v1);
   return v_out.cross(v2);
   */

   if(arguments.length<3) v_out = new DSMath.Vector3D();
   v_out.x = v1.y*v2.z - v1.z*v2.y;
   v_out.y = v1.z*v2.x - v1.x*v2.z;
   v_out.z = v1.x*v2.y - v1.y*v2.x;
   return v_out;
};

// ============================================================ //
//                       POINT METHODS                          //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Point#add
* @description Adds a point to this.
* @param {DSMath.Point} iP The point.
* @memberof DSMath.Point
* @method addPointToPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var p2 = p0.addPointToPoint(p1); // p2===p0 and p2=(2,3,3) and p1=(1,1,0).
* @returns { DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.addPointToPoint = function (iP) {
   return this.add(iP);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#addVector
* @memberof DSMath.Point
* @method addVectorToPoint
* @instance
* @description Adds a vector to this point.
* @param {DSMath.Vector3D} iV The vector.
* @example
* var p0 = new DSMath.Point(1,2,3);
* var v0 = new DSMath.Vector3D(1,1,0);
* var p1 = p0.addVector(v0); // p0===p1 and p1=(2,3,3)
* @returns {DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.addVectorToPoint = function (iV) {
   return this.addVector(iV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#sub
* @description Substracts a given point from this.
* @param {DSMath.Point} iP The Point.
* @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
* @memberof DSMath.Point
* @method subPointFromPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var v0 = p0.subPointFromPoint(p1); // p0=(1,2,3) and p1=(1,1,0) and v0=(0,1,3).
* @returns { DSMath.Vector3D } The reference of the operation result.
*/
DSMath.Point.prototype.subPointFromPoint = function (iP, oV) {
   oV = oV || new DSMath.Vector3D();
   return this.sub(iP, oV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#subVector
* @memberof DSMath.Point
* @method subVectorFromPoint
* @instance
* @description Substracts a vector from a point and modifies the input point.
* @param {DSMath.Vector3D} iV The vector.
* @example
* var p0 = new DSMath.Point(1,2,3);
* var v0 = new DSMath.Vector3D(1,1,0);
* var p1 = p0.subVector(v0); // p0===p1 and p1=(0,1,3);
* @returns {DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.subVectorFromPoint = function (iV) {
   return this.subVector(iV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#sub
* @description Create a vector by substracting a point from this.
* @param {DSMath.Point} iP The Point.
* @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
* @memberof DSMath.Point
* @method vectorFromPoints
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var v0 = p0.vectorFromPoints(p1); // p0=(1,2,3) and p1=(1,1,0) and v0=(0,1,3).
* @returns { DSMath.Vector3D } The reference of the operation result.
*/
DSMath.Point.prototype.vectorFromPoints = function (iP, oV) {
   oV = oV || new DSMath.Vector3D();
   return this.sub(iP, oV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#squareDistanceTo
* @description Returns the square distance between <tt>this</tt> point and another point.
* @param {DSMath.Point} iP The Point.
* @memberof DSMath.Point
* @method ptPtSquareDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var sqDist = p0.ptPtSquareDistanceTo(p1); // sqDist=10
* @returns { Number } The square distance between this and the given point.
*/
DSMath.Point.prototype.ptPtSquareDistanceTo = function (iP) {
   return this.squareDistanceTo(iP);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#distanceTo
* @description Returns the distance between <tt>this</tt> point and another point.
* @param {DSMath.Point} iP The Point.
* @memberof DSMath.Point
* @method ptPtDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var sqDist = p0.ptPtDistanceTo(p1); // sqDist=&#8730;10
* @returns { Number } The distance between this and the given point.
*/
DSMath.Point.prototype.ptPtDistanceTo = function (iP) {
   return this.distanceTo(iP);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#distanceToPointArray
* @description Returns the min distance between this point and an array of points.
* @param {DSMath.Point | Array} iAPts The array of points.
* @memberof DSMath.Point
* @method ptPtsDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var p2 = new DSMath.Point(0,1,1);
* var tabOfPoints = [p0, p1, p2];
* var pRef = new DSMath.Point(1,1,1);
* var dist = pRef.ptPtsDistanceTo(tabOfPoints); // dist=1
* @returns { Number } The min distance between the given point and the array of points.
*/
DSMath.Point.prototype.ptPtsDistanceTo = function (iAPts) {
   return this.distanceToPointArray(iAPts);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#multiplyScalar
* @description Multiplies this point by a scalar.
* @param {Number} iS The scalar.
* @memberof DSMath.Point
* @method multiplyPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var s = 2;
* var p1 = p0.multiplyPoint(s); // p0===p1 and p1=(2,4,6) and s=2
* @returns { DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.multiplyPoint = function (iS) {
   return this.multiplyScalar(iS);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#divideScalar
* @description Divides this point by a scalar.
* @param {Number} iS The scalar.
* @memberof DSMath.Point
* @method dividePoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var s = 2;
* var p1 = p0.dividePoint(s); // p0===p1 and p1=(0.5,1,1.5) and s=2
* @returns { DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.dividePoint = function (iS) {
   return this.divideScalar(iS);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#set
* @memberof DSMath.Point
* @method setCoord
* @instance
* @description Assigns new coordinates values to this point.
* @param {Number} iX Value for the x coordinate.
* @param {Number} iY Value for the y coordinate.
* @param {Number} iZ Value for the z coordinate.
* @example
* var v0 = new DSMath.Point(); // v0=(0,0,0)
* v0.setCoord(1.0, 2.0, 3.0);   // v0=(1,2,3)
* @returns {DSMath.Point } this modified point reference.
*/
DSMath.Point.prototype.setCoord = function (iX, iY, iZ) {
   return this.set(iX, iY, iZ);
};

// --------------------------- STATIC --------------------------------------

/**
* @private
* @deprecated R419
* @see DSMath.Point#add
* @description Adds two points.
* @param {DSMath.Point} iP1 The first point.
* @param {DSMath.Point} iP2 The second point.
* @memberof DSMath
* @method addPointToPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var p2 = DSMath.addPointToPoint(p0, p1); // p0=(1,2,3) and p1=(1,1,0) and p2=(2,3,3).
* @returns { DSMath.Point } The reference of the operation result.
*/
DSMath.addPointToPoint = function (iP1, iP2, oP) {
   oP = (arguments.length<3)? iP1.clone() : oP.copy(iP1);
   return oP.add(iP2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#addVector
* @description Adds a vector to a point and returns a new point.
* @param {DSMath.Point} iP The point to be translated.
* @param {DSMath.Vector3D} iV The vector.
* @memberof DSMath
* @method addVectorToPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var v0 = new DSMath.Vector3D(1,1,0);
* var p1 = DSMath.addVectorToPoint(p0, v0); // p0=(1,2,3) and p1=(2,3,3)
* @returns { DSMath.Point } The reference of the operation result.
*/
DSMath.addVectorToPoint = function (p, v, p_out) {
   if (arguments.length < 3) p_out = new DSMath.Point();
   p_out.x = p.x + v.x;
   p_out.y = p.y + v.y;
   p_out.z = p.z + v.z;
   return p_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#sub
* @description Substracts two points.
* @param {DSMath.Point} iP1 The first point.
* @param {DSMath.Point} iP2 The second point.
* @memberof DSMath
* @method subPointFromPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var v0 = DSMath.subPointFromPoint(p0, p1); // p0=(1,2,3) and p1=(1,1,0) and v0=(0,1,3).
* @returns { DSMath.Vector3D } The reference of the operation result.
*/
DSMath.subPointFromPoint = function (iP1, iP2, oV) {
   oV = oV || new DSMath.Vector3D();
   return iP1.sub(iP2, oV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#subVector
* @description Substracts a vector from a point and returns a new point.
* @param {DSMath.Point} iP The point to be translated.
* @param {DSMath.Vector3D} iV The vector.
* @memberof DSMath
* @method subVectorFromPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var v0 = new DSMath.Vector3D(1,1,0);
* var p1 = DSMath.subVectorFromPoint(p0, v0); // p0=(1,2,3) and p1=(0,1,3)
* @returns { DSMath.Point } The reference of the operation result.
*/
DSMath.subVectorFromPoint = function (p, v, p_out) {
   if (arguments.length < 3) p_out = new DSMath.Point();
   p_out.x = p.x - v.x;
   p_out.y = p.y - v.y;
   p_out.z = p.z - v.z;
   return p_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#sub
* @description Create a vector from two points.
* @param {DSMath.Point} iP1 The first point.
* @param {DSMath.Point} iP2 The second point.
* @memberof DSMath
* @method vectorFromPoints
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var v0 = DSMath.vectorFromPoints(p0, p1); // p0=(1,2,3) and p1=(1,1,0) and v0=(0,1,3).
* @returns { DSMath.Vector3D } The reference of the operation result.
*/
DSMath.vectorFromPoints = function (iP1, iP2, oV) {
   oV = oV || new DSMath.Vector3D();
   return iP1.sub(iP2, oV);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#squareDistanceTo
* @description Returns the square distance between two points.
* @param {DSMath.Point} iP1 The first Point.
* @param {DSMath.Point} iP2 The second Point.
* @memberof DSMath
* @method ptPtSquareDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var sqDist = DSMath.ptPtSquareDistanceTo(p0, p1); // sqDist=10
* @returns { Number } The square distance between the two points.
*/
DSMath.ptPtSquareDistanceTo = function (iP1, iP2) {
   return iP1.squareDistanceTo(iP2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#distanceTo
* @description Returns the distance between two points.
* @param {DSMath.Point} iP1 The first Point.
* @param {DSMath.Point} iP2 The second Point.
* @memberof DSMath
* @method ptPtDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var sqDist = DSMath.ptPtDistanceTo(p0, p1); // sqDist=&#8730;10
* @returns { Number } The distance between the two points.
*/
DSMath.ptPtDistanceTo = function (iP1, iP2) {
   return iP1.distanceTo(iP2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#distanceToPointArray
* @description Returns the min distance between a point and an array of points.
* @param {DSMath.Point} iP The Point.
* @param {DSMath.Point | Array} iAPts The array of points.
* @memberof DSMath
* @method ptPtsDistanceTo
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var p1 = new DSMath.Point(1,1,0);
* var p2 = new DSMath.Point(0,1,1);
* var tabOfPoints = [p0, p1, p2];
* var pRef = new DSMath.Point(1,1,1);
* var dist = DSMath.ptPtsDistanceTo(pRef, tabOfPoints); // dist=1
* @returns { Number } The min distance between the given point and the array of points.
*/
DSMath.ptPtsDistanceTo = function (p1, aP, d_out) {
   var i = 0;
   var d_out = 0.;
   var nbPt = aP.length;
   var dist = (p1.x - aP[0].x) * (p1.x - aP[0].x)
         + (p1.y - aP[0].y) * (p1.y - aP[0].y)
        + (p1.z - aP[0].z) * (p1.z - aP[0].z);
   for (i = 1; i < nbPt; i++) {
      d_out = (p1.x - aP[i].x) * (p1.x - aP[i].x)
      + (p1.y - aP[i].y) * (p1.y - aP[i].y)
     + (p1.z - aP[i].z) * (p1.z - aP[i].z);
      if (d_out < dist) { dist = d_out; var index = i; }
   }
   d_out = Math.sqrt(dist);
   return d_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#multiplyScalar
* @description Multiplies a point by a scalar.
* @param {DSMath.Point} iP The point.
* @param {Number} iS The scalar.
* @memberof DSMath
* @method multiplyPoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var s = 2;
* var p1 = DSMath.multiplyPoint(p0, s); // p0=(1,2,3) and s=2 and p1=(2,4,6);
* @returns { DSMath.Point } The reference of the operation result.
*/
DSMath.multiplyPoint = function (iP, iS, oP) {
   oP = (arguments.length<3)? iP.clone() : oP.copy(iP);
   return oP.multiplyScalar(iS);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#divideScalar
* @description Divides a point by a scalar.
* @param {DSMath.Point} iP The point.
* @param {Number} iS The scalar.
* @memberof DSMath
* @method dividePoint
* @instance
* @example
* var p0 = new DSMath.Point(1,2,3);
* var s = 2;
* var p1 = DSMath.dividePoint(p0, s); // p0=(1,2,3) and s=2 and p1=(0.5,1,1.5);
* @returns { DSMath.Point } The reference of the operation result.
*/
DSMath.dividePoint = function (iP, iS, oP) {
   oP = (arguments.length<3)? iP.clone() : oP.copy(iP);
   return oP.divideScalar(iS);
};

// ============================================================ //
//                     Matrix3x3 METHODS                        //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#setFromArray
* @memberof DSMath.Matrix3x3
* @method setCoef
* @instance
* @description
* Assigns new coefficients to this matrix. The coefficients are duplicated.
* @param {Number[]} iCoef Array of size 9 containing the new matrix coefficients.
* @example
* var m0 = new DSMath.Matrix3x3();
* var newCoef = [0,1,2,3,4,5,6,7,8];
* var m1 = m0.setCoef(newCoef); // m0===m1 and m0.coef==newCoef but m0.coef!==newCoef.
* @returns {DSMath.Matrix3x3} this modified matrix reference.
*/
DSMath.Matrix3x3.prototype.setCoef = function (iCoef) {
   this.coef = [iCoef[0], iCoef[1], iCoef[2], iCoef[3], iCoef[4], iCoef[5], iCoef[6], iCoef[7], iCoef[8]];
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#getArray
* @memberof DSMath.Matrix3x3
* @method getCoef
* @instance
* @description
* Retrieve a copy of the matrix coefficients into an array of size 9.
* @param {Number[]} [oCoef] Reference of the operation result (avoid allocation).
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var coef = m0.getCoef(); // coef==m0.coef but coef!==m0.coef
* @returns {Number[]} The reference of the operation result
*/
DSMath.Matrix3x3.prototype.getCoef = function (oCoef) {
   oCoef = oCoef || new Array(9);
   return this.getArray(0,oCoef);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#makeRotation
* @memberof DSMath.Matrix3x3
* @method setRotation
* @instance
* @description
* Sets the matrix coef to represent the rotation specified by an axis and angle.
* @param {DSMath.Vector3D} iAxis The axis of the rotation.
* @param {Number} iAngle The angle of the rotation
* @example
* var m0 = new DSMath.Matrix3x3();
* m0.setRotation(new DSMath.Vector3D(0,0,1), Math.PI/2); // m0=[0,-1,0,1,0,0,0,0,1]
*/
DSMath.Matrix3x3.prototype.setRotation = function (v, d) {
   var vNorm = v.normalize();
   var x = vNorm.x;
   var y = vNorm.y;
   var z = vNorm.z;
   var x2 = x * x;
   var y2 = y * y;
   var z2 = z * z
   var xy = x * y;
   var xz = x * z;
   var yz = y * z;
   var sina = Math.sin(d);
   var cosa = Math.cos(d);
   var b11 = x2 + (y2 + z2) * cosa;
   var b12 = xy - xy * cosa - z * sina;
   var b13 = xz - xz * cosa + y * sina;
   var b21 = xy - xy * cosa + z * sina;
   var b22 = y2 + (x2 + z2) * cosa;
   var b23 = yz - yz * cosa - x * sina;
   var b31 = xz - xz * cosa - y * sina;
   var b32 = yz - yz * cosa + x * sina;
   var b33 = z2 + (x2 + y2) * cosa;
   var c1 = [b11, b12, b13, b21, b22, b23, b31, b32, b33];
   this.coef = c1;
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#makeDiagonal
* @memberof DSMath.Matrix3x3
* @method diagonalMatrix
* @instance
* @description
* Sets <i>this</i> matrix diagonal coefs (other are setted to 0).
* @param {Number} iM00 The coef in row 0 column 0
* @param {Number} iM11 The coef in row 1 column 1
* @param {Number} iM22 The coef in row 2 column 2
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = m0.diagonalMatrix(9,10,11); // m1===m0 and m1=[9,0,0,0,10,0,0,0,11]
*/
DSMath.Matrix3x3.prototype.diagonalMatrix = function (iM00, iM11, iM22) {
   var val = [iM00, 0, 0, 0, iM11, 0, 0, 0, iM22];
   this.coef = val;
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#makeScaling
* @memberof DSMath.Matrix3x3
* @method scalarMatrix
* @instance
* @description
* <i>this</i> matrix becomes a scaling matrix of the scale given.
* @param {Number} iS The scale.
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = m0.scalarMatrix(3); // m1===m0 and m1=[3,0,0, 0,3,0, 0,0,3]
*/
DSMath.Matrix3x3.prototype.scalarMatrix = function (iS) {
   var val = [iS, 0, 0, 0, iS, 0, 0, 0, iS];
   this.coef= val;
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#add
* @memberof DSMath.Matrix3x3
* @method addMatrixToMatrix
* @instance
* @description
* Adds a given Matrix3x3 to <i>this</i> matrix.
* @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be added.
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
* var m3 = m0.addMatrixToMatrix(m1); // m3===m0 and m3=[8,8,8,8,8,8,8,8,8]
* @returns {DSMath.Matrix3x3} this modified matrix reference
*/
DSMath.Matrix3x3.prototype.addMatrixToMatrix = function (iM) {
   return this.add(iM);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#sub
* @memberof DSMath.Matrix3x3
* @method subMatrixFromMatrix
* @instance
* @description
* Substracts a given Matrix3x3 to <i>this</i> matrix.
* @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be substracted.
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
* var m3 = m0.subMatrixFromMatrix(m1); // m3===m0 and m3=[-8,-6,-4,-2, 0 , 2, 4, 6, 8]
* @returns {DSMath.Matrix3x3} this modified matrix reference
*/
DSMath.Matrix3x3.prototype.subMatrixFromMatrix = function (iM) {
   return this.sub(iM);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#multiply
* @memberof DSMath.Matrix3x3
* @method multiplyMatrixByMatrix
* @instance
* @description
* Multiplies a given Matrix3x3 to <i>this</i> matrix.
* @param {DSMath.Matrix3x3} iM The matrix <i>this</i> is to be multiplied.
* @example
* var s0 = new DSMath.Matrix3x3();
* s0.makeDiagonal(1,2,3);
* var r0 = new DSMath.Matrix3x3();
* r0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
* var m = r0.multiplyMatrixByMatrix(s0); // m===r0 and m=[0,-2,0, 1,0,0, 0,0,3]
* @returns {DSMath.Matrix3x3} this modified matrix reference
*/
DSMath.Matrix3x3.prototype.multiplyMatrixByMatrix = function (iM) {
   return DSMath.multiplyMatrixByMatrix(this, iM, this);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#multiplyScalar
* @memberof DSMath.Matrix3x3
* @method multiplyMatrix
* @instance
* @description
* Multiplies each coefficient of <i>this</i> matrix by a scalar.
* @param {Number} iS The scalar.
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = m0.multiplyMatrix(2); // m1===m0 and m1=[0,2,4,6,8,10,12,14,16]
* @returns {DSMath.Matrix3x3} this modified matrix reference
*/
DSMath.Matrix3x3.prototype.multiplyMatrix = function (iS) {
   return this.multiplyScalar(iS);
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#applyMatrix3x3
* @memberof DSMath.Matrix3x3
* @method multiplyMatrixByVector
* @instance
* @description
* Multiplies a vector by <i>this</i> matrix.
* @param {DSMath.Vector3D} iV The vector.
* @example
* var m0 = new DSMath.Matrix3x3(0,-1,0, 1,0,0, 0,0,1);
* var v0 = new DSMath.Vector3D(1,1,0);
* var v1 = m0.multiplyMatrixByVector(v0); // v1!=v0 and v1=(-1,1,0)
* @returns {DSMath.Vector3D} The new transformed Vector3D.
*/
DSMath.Matrix3x3.prototype.multiplyMatrixByVector = function (iV) {
   return iV.clone().applyMatrix3x3(this);
};

/**
* @private
* @deprecated R419
* @memberof DSMath.Matrix3x3
* @method computeMatrixType
* @instance
* @description
* The convention for the matrix type is the following :
* <br>
* 3 for the identity
* <br>
* 2 and -2 for the scalings
* <br>
* 1 and -1 for the isometries
* <br>
* 0 otherwise
* @example
* var m0 = new DSMath.Matrix3x3();
* m0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // m0=[0,-1,0, 1,0,0, 0,0,1]
* var m0Type = m0.computeMatrixType(); // m0Type=1 (direct isometry).
* @returns {Number} The matrix type.
*/
DSMath.Matrix3x3.prototype.computeMatrixType = function () {
   // Compute type
   var EpsgRelative          = DSMath.defaultTolerances.epsgForRelativeTest;
   var SquareEpsilonRelative = DSMath.defaultTolerances.epsilonForSquareRelativeTest;

   var v1 = this.getFirstColumn();
   var v2 = this.getSecondColumn();
   var v3 = this.getThirdColumn();

   // Norm test
   var n1 = v1.norm();
   var n2 = v2.norm();
   var n3 = v3.norm();

   // Orhogonality tests
   var dotv1v2 = v1.dot(v2);
   if (Math.abs(dotv1v2) > EpsgRelative * n1 * n2) return 0;

   var dotv1v3 = v1.dot(v3);
   if (Math.abs(dotv1v3) > EpsgRelative * n1 * n3) return 0;

   var dotv2v3 = v2.dot(v3);
   if (Math.abs(dotv2v3) > EpsgRelative * n2 * n3) return 0;

   var det = this.determinant();
   if (det * det < SquareEpsilonRelative) return 0;

   if (Math.abs(n1 - 1.) < EpsgRelative &&
       Math.abs(n2 - 1.) < EpsgRelative &&
       Math.abs(n3 - 1.) < EpsgRelative) {
      if (det > 0.) return 1;
      return -1;
   }
   var n = Math.pow(Math.abs(det), 1. / 3.);
   if (Math.abs(n1 / n - 1.) > EpsgRelative) return 0;
   if (Math.abs(n2 / n - 1.) > EpsgRelative) return 0;
   if (Math.abs(n3 / n - 1.) > EpsgRelative) return 0;
   if (det > 0.) return 2;
   return -2;
};

// --------------------------- STATIC --------------------------------------
/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#add
* @memberof DSMath
* @method addMatrixToMatrix
* @instance
* @description
* Adds two given Matrix3x3.
* @param {DSMath.Matrix3x3} iM1 The matrix to add.
* @param {DSMath.Matrix3x3} iM2 The matrix to add.
* @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
* var m3 = DSMath.addMatrixToMatrix(m0,m1); // m3!==m0 and m3=[8,8,8,8,8,8,8,8,8]
* @returns {DSMath.Matrix3x3} The reference of the operation result.
*/
DSMath.addMatrixToMatrix = function (iM1, iM2, oM) {
   oM = (arguments.length<3)? iM1.clone() : oM.copy(iM1);
   return oM.add(iM2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#add
* @memberof DSMath
* @method subMatrixFromMatrix
* @instance
* @description
* Substracts two given Matrix3x3.
* @param {DSMath.Matrix3x3} iM1 The matrix.
* @param {DSMath.Matrix3x3} iM2 The matrix to substract from iM1.
* @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = new DSMath.Matrix3x3(8,7,6,5,4,3,2,1,0);
* var m3 = DSMath.subMatrixFromMatrix(m0, m1); // m3===m0 and m3=[-8,-6,-4,-2, 0 , 2, 4, 6, 8]
* @returns {DSMath.Matrix3x3} The reference of the operation result.
*/
DSMath.subMatrixFromMatrix = function (iM1, iM2, oM) {
   oM = (arguments.length<3)? iM1.clone() : oM.copy(iM1);
   return oM.sub(iM2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#multiply
* @memberof DSMath
* @method multiply
* @instance
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
* var m = DSMath.multiplyMatrixByMatrix(r0,s0); // m!=r0 and m=[0,-2,0, 1,0,0, 0,0,3]
* @returns {DSMath.Matrix3x3} The reference of the operation result.
*/
DSMath.multiplyMatrixByMatrix = function (m1, m2, m_out) {
   var m_outa11 = 0; var m_outa21 = 0; var m_outa31 = 0;
   var m_outa12 = 0; var m_outa22 = 0; var m_outa32 = 0;
   var m_outa13 = 0; var m_outa23 = 0; var m_outa33 = 0;

   if (arguments.length < 3) m_out = new DSMath.Matrix3x3();
   var m1Coef = m1.getCoef();
   var m2Coef = m2.getCoef();
   var m1a11 = m1Coef[0]; var m1a12 = m1Coef[1]; var m1a13 = m1Coef[2];
   var m1a21 = m1Coef[3]; var m1a22 = m1Coef[4]; var m1a23 = m1Coef[5];
   var m1a31 = m1Coef[6]; var m1a32 = m1Coef[7]; var m1a33 = m1Coef[8];

   var m2a11 = m2Coef[0]; var m2a12 = m2Coef[1]; var m2a13 = m2Coef[2];
   var m2a21 = m2Coef[3]; var m2a22 = m2Coef[4]; var m2a23 = m2Coef[5];
   var m2a31 = m2Coef[6]; var m2a32 = m2Coef[7]; var m2a33 = m2Coef[8];

   m_outa11 = m1a11 * m2a11 + m1a12 * m2a21 + m1a13 * m2a31;
   m_outa12 = m1a11 * m2a12 + m1a12 * m2a22 + m1a13 * m2a32;
   m_outa13 = m1a11 * m2a13 + m1a12 * m2a23 + m1a13 * m2a33;

   m_outa21 = m1a21 * m2a11 + m1a22 * m2a21 + m1a23 * m2a31;
   m_outa22 = m1a21 * m2a12 + m1a22 * m2a22 + m1a23 * m2a32;
   m_outa23 = m1a21 * m2a13 + m1a22 * m2a23 + m1a23 * m2a33;

   m_outa31 = m1a31 * m2a11 + m1a32 * m2a21 + m1a33 * m2a31;
   m_outa32 = m1a31 * m2a12 + m1a32 * m2a22 + m1a33 * m2a32;
   m_outa33 = m1a31 * m2a13 + m1a32 * m2a23 + m1a33 * m2a33;

   m_out.coef = [m_outa11, m_outa12, m_outa13,
                 m_outa21, m_outa22, m_outa23,
                 m_outa31, m_outa32, m_outa33];
   return m_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#multiplyScalar
* @memberof DSMath
* @method multiplyMatrix
* @instance
* @description
* Multiplies each coefficient of a given matrix by a scalar.
* @param {DSMath.Matrix3x3} iM The matrix.
* @param {Number} iS The scalar.
* @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
* @example
* var m0 = new DSMath.Matrix3x3(0,1,2,3,4,5,6,7,8);
* var m1 = DSMath.multiplyMatrix(m0,2); // m1!=m0 and m1=[0,2,4,6,8,10,12,14,16]
* @returns {DSMath.Matrix3x3} The reference of the operation result.
*/
DSMath.multiplyMatrix = function (iM, iS, oM) {
   oM = (arguments.length<3)? iM.clone() : oM.copy(iM);
   return oM.multiplyScalar(iS);
};


/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#applyMatrix3x3
* @memberof DSMath
* @method multiplyMatrixByVector
* @instance
* @description
* Multiplies a vector by a given matrix.
* @param {DSMath.Matrix3x3} iM The matrix.
* @param {DSMath.Vector3D} iV The vector.
* @example
* var m0 = new DSMath.Matrix3x3(0,-1,0, 1,0,0, 0,0,1);
* var v0 = new DSMath.Vector3D(1,1,0);
* var v1 = DSMath.multiplyMatrixByVector(m0,v0); // v1!=v0 and v1=(-1,1,0)
* @returns {DSMath.Vector3D} The new transformed Vector3D.
*/
DSMath.multiplyMatrixByVector = function (iM, iV, oV) {
   var result = iM.multiplyMatrixByVector(iV);
   if(arguments.length>=3){
      oV.copy(result);
   }
   return result;
};

// ============================================================ //
//                  TRANSFORMATION METHODS                      //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Transformation#setRotationFromEuler
* @memberof DSMath.Transformation
* @method setEuler
* @instance
* @description
* <i>this</i> transformation matrix becomes a rotation equals to rotation combinaison defined from euler angles.
* @param {Number[]} iE The array of euler angles.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2]);
* // t0.matrix=|0.5, 0.5, 1/&#8730;2|
* //           |0.5, 0.5,-1/&#8730;2|
* //           |-1/&#8730;2, -1/&#8730;2, 0|
*/
DSMath.Transformation.prototype.setEuler = function (v) {
   var CosX = Math.cos(v[1]); var SinX = Math.sin(v[1]);
   var CosY = Math.cos(v[2]); var SinY = Math.sin(v[2]);
   var CosZ = Math.cos(v[0]); var SinZ = Math.sin(v[0]);

   var A11 = CosY * CosZ - (SinX * SinY * SinZ); var A12 = -CosX * SinZ; var A13 = CosZ * SinY + (CosY * SinX * SinZ);
   var A21 = CosZ * SinX * SinY + (CosY * SinZ); var A22 = CosX * CosZ; var A23 = SinY * SinZ - (CosY * CosZ * SinX);
   var A31 = -CosX * SinY; var A32 = SinX; var A33 = CosX * CosY;

   var newCoef = [A11, A12, A13,
                  A21, A22, A23,
                  A31, A32, A33];

   this.matrix.coef = newCoef;
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#multiplyByEuler
* @memberof DSMath.Transformation
* @method setEulerRotation
* @instance
* @description
* Applies a rotation to the transformation.
* @param {Number[]} iE The array of euler angles.
* @example
* var t0 = new DSMath.Transformation();
* t0.matrix.makeDiagonal(1,2,3);
* var t1 = t0.setEulerRotation([Math.PI/2,0,0]); // t1===t0 and t0.matrix=[0,-1,0, 2,0,0, 0,0,3].
* @returns {DSMath.Transformation} this modified transformation reference
*/
DSMath.Transformation.prototype.setEulerRotation = function (iE) {
   return this.multiplyByEuler(iE);
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#setFromArray
* @memberof DSMath.Transformation
* @method setCoefficients
* @instance
* @description
* Modifies the transformation vector and matrix by specifying a set of 12 coefficients.
* <br>
* Warning: The matrix values are specified by column:
* <pre>
* [ iC[0], iC[3], iC[6],
*   iC[1], iC[4], iC[7],
*   iC[2], iC[5], iC[8] ];
* </pre>
* define the matrix.
* <br>
* iC[9], iC[10], iC[11] define the vector.
* @param {Number[]} iCoef The array of 12 coefficients.
* @example
* var t0 = new DSMath.Transformation();
* var t1 = t0.setCoefficients([1,2,3,4,5,6,7,8,9, 10,11,12]); // t1===t0 and t1.matrix=[1,2,3,4,5,6,7,8,9] and t1.vector=[10,11,12]
*/
DSMath.Transformation.prototype.setCoefficients = function (aCoefs) {
   // aCoefs not implemented for dim = 16
   var aCoefsTranspose = [aCoefs[0], aCoefs[3], aCoefs[6],
                          aCoefs[1], aCoefs[4], aCoefs[7],
                          aCoefs[2], aCoefs[5], aCoefs[8]];
   this.matrix.coef = aCoefsTranspose;
   this.vector.setCoord(aCoefs[9], aCoefs[10], aCoefs[11]);
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#getArray
* @memberof DSMath.Transformation
* @method getCoefficients
* @instance
* @description
* Retrieves the transformation data, vector and matrix under the form of an array of 12 values.
* <br>
* Warning: The matrix values are specified by column:
* <pre>
* [ iC[0], iC[3], iC[6],
*   iC[1], iC[4], iC[7],
*   iC[2], iC[5], iC[8] ];
* </pre>
* define the matrix.
* <br>
* iC[9], iC[10], iC[11] define the vector.
* @param {Number[]} iCoef The array of 12 coefficients.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]);
* t0.vector.set(1,2,3);
* var t0Coef = t0.getCoefficients(); //t0Coef=[0,1,0, -1,0,0, 0,0,1, 1,2,3]
* @returns { Number[] } oCoef An array of 12 coefficients.
*/
DSMath.Transformation.prototype.getCoefficients = function () {
   return this.getArray();
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#multiply
* @memberof DSMath.Transformation
* @method multiplyTransfo
* @instance
* @description
* Compose <i>this</i> transformation with another one given.
* @param {DSMath.Transformation} iT The other transformation <i>this</i> is to be multiplied by.
* @param {Boolean} [iLeft=false] false if the composition is made on the right of <i>this</i>, true otherwise.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI,0,0]).setVector(1,2,3);
* var t1 = new DSMath.Transformation();
* t1.matrix.makeDiagonal(4,5,6);
* var t2 = t0.multiplyTransfo(t1); // t2===t0 and
* //t2.matrix=| 0,-5, 0|
* //          | 4, 0, 0|
* //          | 0, 0, 6|
* //t2.vector=[ 1, 2, 3]
* @returns {DSMath.Transformation} this modified transformation reference.
*/
DSMath.Transformation.prototype.multiplyTransfo = function (iTRight, iLeft) {
   iLeft = iLeft || false;
   return this.multiply(iTRight, iLeft);
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#multiplyByScaling
* @memberof DSMath.Transformation
* @method setScaling
* @instance
* @description
* Sets a scaling transformation.
* <br>
* The scaling transformation is defined by three parameters: the scale ratio, a point and a value indicating
* whether the transformation is a scaling.
* @param {{center: DSMath.Point, scale: number, isScaling: number}} obj The object defining the scaling. 
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]);
* var scaling = {center: new DSMath.Point(0,1,0),
*                scale: 2,
*                isScaling: 1};
* var t1 = t0.setScaling(scaling);
* //t1.matrix=| 0,-2, 0|
* //          | 2, 0, 0|
* //          | 0, 0, 2|
* //t1.vector=[0, -1, 0]
* @returns {DSMath.Transformation} this modified transformation reference.
*/
DSMath.Transformation.prototype.setScaling = function (obj) {
   var scaleMat = new DSMath.Transformation();
   scaleMat.matrix.makeScaling(obj.scale);

   obj.center.sub(DSMath.Point.origin, scaleMat.vector)
   scaleMat.vector.multiplyScalar(1. - obj.scale);

   this.multiplyTransfo(scaleMat);
   return this;
};

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#isARotation
* @memberof DSMath.Transformation
* @method isRotation
* @instance
* @description
* Determines whether <i>this</i> transformation is only a rotation transformation and a translation.
* <br>
* The transformation is only a rotation if its matrix is a direct isometry.
* @example
* var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
* var m1 = new DSMath.Matrix3x3(0,-1,0, 1,0,0, 0,0,1);
*
* var t0 = new DSMath.Transformation(m0).setVector(1,2,3);
* var t1 = new DSMath.Transformation(m1).setVector(1,2,3);
*
* var t0IsARotation = t0.isRotation(); // t0IsARotation==false
* var t1IsARotation = t1.isRotation(); // t1IsARotation==true 
* @returns {DSMath.Transformation} this modified transformation reference.
*/
DSMath.Transformation.prototype.isRotation = function () {
   // tres approximatif
   // calculs avec le solveur seront fait ultérieurement
   var boolRoot = false;
   // ni rotation, ni translation
   var margin = Math.pow(10, -15);
   // if det = 1 rotation or translation
   if (Math.abs(this.matrix.determinant() - 1.) <= margin) {
      if (this.isIdentity()) {
         boolRoot = false;
      }
      else {
         boolRoot = true;
      }
   }
   return boolRoot;
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#applyTransformation
* @memberof DSMath.Transformation
* @method applyToPoint
* @instance
* @description
* Applies <i>this</i> transformation to a point.
* @param { DSMath.Point } iP The point which the transformation is applied to.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
* var p0 = new DSMath.Point(1,1,1);
* var p1 = t0.applyToPoint(p0); //p1!=p0 and p1=(0,3,4);
* @returns {DSMath.Point} The transformed point.
*/
DSMath.Transformation.prototype.applyToPoint = function (iP, oP) {
   var p_out = (arguments.length < 2) ? new DSMath.Point() : oP;
   var coefs = this.matrix.coef;
   p_out.x = coefs[0] * iP.x + coefs[1] * iP.y + coefs[2] * iP.z + this.vector.x;
   p_out.y = coefs[3] * iP.x + coefs[4] * iP.y + coefs[5] * iP.z + this.vector.y;
   p_out.z = coefs[6] * iP.x + coefs[7] * iP.y + coefs[8] * iP.z + this.vector.z;
   return p_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Vector3D#applyTransformation
* @memberof DSMath.Transformation
* @method applyToVector
* @instance
* @description
* Applies <i>this</i> transformation to a Vector3D.
* @param { DSMath.Vector3D } iV The vector which the transformation is applied to.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
* var v0 = new DSMath.Vector3D(1,1,1);
* var v1 = t0.applyToVector(v0); //v1!=v0 and v1=(-1,1,1);
* @returns {DSMath.Vector3D} The transformed vector.
*/
DSMath.Transformation.prototype.applyToVector = function (iV, oV) {
   var v_out = (arguments.length < 2) ? new DSMath.Vector3D() : oV;
   var coefs = this.matrix.coef;
   v_out.x = coefs[0] * iV.x + coefs[1] * iV.y + coefs[2] * iV.z;
   v_out.y = coefs[3] * iV.x + coefs[4] * iV.y + coefs[5] * iV.z;
   v_out.z = coefs[6] * iV.x + coefs[7] * iV.y + coefs[8] * iV.z;
   return v_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Line#applyTransformation
* @memberof DSMath.Transformation
* @method applyToLine
* @instance
* @description
* Applies <i>this</i> transformation to a Line.
* @param { DSMath.Line } iL The line which the transformation is applied to.
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
* var l0 = new DSMath.Line().set(1,1,1, 0,1,0);
* var l1 = t0.applyToLine(l0); // l1.origin=(-1,1,1) l1.direction=(-1,0,0)
* @returns {DSMath.Line} The transformed line.
*/
DSMath.Transformation.prototype.applyToLine = function (iL, oL) {
   var result = (arguments.length < 2) ? new DSMath.Line() : oL;
   this.applyToPoint(iL.origin, result.origin);
   this.applyToVector(iL.direction, result.direction);
   return result;
};

/**
* @private
* @deprecated R419
* @see DSMath.Axis#applyTransformation
* @memberof DSMath.Transformation
* @method applyToAxis
* @instance
* @description
* Applies <i>this</i> transformation to a Line.
* @param { DSMath.Axis } iAxis The axis which the transformation is applied to.
* @example
* var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1));
* var a0 = new DSMath.Axis().setOrigin(1,2,3);
* var a1 = t0.applyToAxis(a0);  // a1!=a0 and a1.origin=(0,1,3)
* var dir = a1.getDirections(); //dir[0]=(0,1,0) and dir[1]=(-1,0,0) and dir[2]=(0,0,1)
* @returns {DSMath.Line} The transformed line.
*/
DSMath.Transformation.prototype.applyToAxis = function (iA, oA) {
   oA = (arguments.length < 2) ? iA.clone() : oA.copy(iA);
   return oA.applyTransformation(this);
};

/** @nodoc */
DSMath.Transformation.prototype.computeInverse = function () {
   var tInv = new DSMath.Transformation();
   this.matrix.getInverse(tInv.matrix);

   tInv.vector.copy(this.vector);
   tInv.vector.applyMatrix3x3(tInv.matrix).negate();
   return tInv;
};

// --------------------------- STATIC --------------------------------------

/**
* @private
* @deprecated R419
* @see DSMath.Transformation#multiply
* @memberof DSMath
* @method multiplyTransfo
* @instance
* @description
* Composition of two transformations.
* @param {DSMath.Transformation} iTLeft The transformation on the left of the composition.
* @param {DSMath.Transformation} iTRight The transformation on the right of the composition.
* @param {DSMath.Transformation} [oT] Reference of the operation result (avoid allocation);
* @example
* var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI,0,0]).setVector(1,2,3);
* var t1 = new DSMath.Transformation();
* t1.matrix.makeDiagonal(4,5,6);
* var t2 = DSMath.multiplyTransfo(t1,t0); // t2!=t0 and
* //t2.matrix=| 0,-4, 0|
* //          | 5, 0, 0|
* //          | 0, 0, 6|
* //t2.vector=[4, 10 ,18]
* @returns {DSMath.Transformation} The reference of the operation result.
*/
DSMath.multiplyTransfo = function (iTLeft, iTRight, oT) {
   oT = (arguments.length < 3) ? iTLeft.clone() : oT.copy(iTLeft);
   return oT.multiply(iTRight);
};

// ============================================================ //
//                    QUATERNION METHODS                        //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#setFromArray
* @memberof DSMath.Quaternion
* @method setQuatCoord
* @instance
* @description
* Assigns new coordinate values to a quaternion.
* <br>
* @param {Number | Array} val Array of coordinates:
* <ul>
* <li> val = [s, (x, y, z)] according to the mathematical convention</li>
* <li> val = [(x, y, z), s] according to the game convention </li>
* </ul>
* @param {Number} convention 
* <ul>
* <li> 1 for the mathematical convention. The coordinates are expressed under the form [s, (x, y, z)]</li>
* <li> 0 for the game convention. The coordinates are expressed under the form [(x, y, z), s]</li>
* </ul>
* @example
* var q1 = new DSMath.Quaternion();
* var newCoef = [0.1, 0.3, 0.4, 0.8];
* q1.setQuatCoord(newCoef, 1);
* @returns {DSMath.Quaternion } this modified quaternion reference.
*/
DSMath.Quaternion.prototype.setQuatCoord = function (val, convention) {
   return this.setFromArray(val ,convention);
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#getArray
* @memberof DSMath.Quaternion
* @method getQuatCoord
* @instance
* @description
* Retrieves the data of a quaternion.
* @param {Number} convention 
* <ul>
* <li> 1 for the mathematical convention. The coordinates are expressed under the form [s, (x, y, z)]</li>
* <li> 0 for the game convention. The coordinates are expressed under the form [(x, y, z), s]</li>
* </ul>
* @example
* var q0 = new DSMath.Quaternion();
* var arrayOfCoord = q0.getQuatCoord(1);
* @returns { Number | Array } The quaternion data.
*/
DSMath.Quaternion.prototype.getQuatCoord = function (convention) {
   return this.getArray(convention)
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#getScalar
* @memberof DSMath.Quaternion
* @method getScalar
* @instance
* @description Retrieves the scalar of a quaternion.
* @example
* var q1 = new DSMath.Quaternion();
* var scalarQ1 = q1.getScalar() // scalarQ1=1
* @returns { Number } The scalar of the quaternion.
*/
DSMath.Quaternion.prototype.getScalar = function() {
   return this.s;
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#setScalar
* @memberof DSMath.Quaternion
* @method setScalar
* @instance
* @description Assigns a new value to the scalar of a quaternion.
* @example
* var q1 = new DSMath.Quaternion();
* q1.setScalar(2.);
* @returns { Number } The scalar of the quaternion.
*/
DSMath.Quaternion.prototype.setScalar = function (scalar) {
   this.s = scalar;
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#makeRotation
* @memberof DSMath.Quaternion
* @method setRotationData
* @instance
* @description Sets a rotation under the form of an angle and a vector.
* @example
* var q1 = new DSMath.Quaternion();
* var v1 = new DSMath.Vector3D();
* v1.x = 1.1;
* v1.y = 2.2;
* v1.z = 3.3;
* var rotData = { angle: Math.PI / 4, vector: v1 };
* q1.setRotationData(rotData);
* @returns { DSMath.Quaternion } this modified quaternion reference.
*/
DSMath.Quaternion.prototype.setRotationData = function (rotData) {
   this.s = Math.cos(rotData.angle / 2);
   this.x = rotData.vector.x * Math.sin(rotData.angle / 2);
   this.y = rotData.vector.y * Math.sin(rotData.angle / 2);
   this.z = rotData.vector.z * Math.sin(rotData.angle / 2);
   return this;
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#length
* @memberof DSMath.Quaternion
* @method length
* @instance
* @description Computes the length of a quaternion.
* @example
* var q1 = new DSMath.Quaternion(2.5,0,0,0);
* var qlength = q1.length();
* @returns { Number } The quaternion length.
*/
DSMath.Quaternion.prototype.length = function () {
   return this.norm();
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#getMatrix
* @memberof DSMath.Quaternion
* @method quaternionToRotMatrix
* @instance
* @description
* Computes the rotation matrix from a quaternion q = [ s, x, y, z ].
* <br>
* If this is not a unit quaternion, the computation will used its normalized form.
* @example
* var q0 = new DSMath.Quaternion();
* var axis = new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0);
* q0.makeRotation(axis, Math.PI/2.0);
* var Mq0 = q0.quaternionToRotMatrix();
* // Mq0 = | 0, -1,  0|
* //       | 1,  0,  0|
* //       | 0,  0,  1|
* @returns {DSMath.Matrix3x3} The reference of the operation result.
*/
DSMath.Quaternion.prototype.quaternionToRotMatrix = function () {
   return this.getMatrix();
};

/**
* @private
* @deprecated R419
* @see DSMath.Matrix3x3#getQuaternion
* @memberof DSMath.Quaternion
* @method rotMatrixToQuaternion
* @instance
* @description
* Computes a unit quaternion q = [ s, x, y, z ] associated with the rotation matrix.
* <br>
* WARNING : No test is done to check that the matrix is a rotation.
* @param {DSMath.Matrix3x3} m Rotation matrix.
* @example
* var q0 = new DSMath.Quaternion();
* var m0 = new DSMath.Matrix3x3();
* q0.rotMatrixToQuaternion(m0);
* @return {DSMath.Quaternion} this modified quaternion reference.
*/
DSMath.Quaternion.prototype.rotMatrixToQuaternion = function (m) {
   return m.getQuaternion(this);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#applyQuaternion
* @memberof DSMath.Quaternion
* @method rotate
* @instance
* @description
* Rotates a point p = (p1, p2, p3)  by a quaternion.
* @param {DSMath.Point} iP The point to be rotated.
* @example
* var p0 = new DSMath.Point(1,1,0);
* var q0 = new DSMath.Quaternion();
* q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
* var pT = q0.rotate(p0); // pT=(-1,1,0);
* @returns {DSMath.Point} The rotated point.
*/
DSMath.Quaternion.prototype.rotate = function (p) {
   var sqNorm = this.squareNorm();
   var qpoint = new DSMath.Quaternion(0, p.x, p.y, p.z);

   var result = DSMath.multiplyQuatByQuat(this, qpoint);
   var conjQ = DSMath.conjugate(this);
   result.multiplyQuatByQuat(conjQ);

   result.divideScalar(sqNorm);

   var point = new DSMath.Point();
   point.setCoord(result.x, result.y, result.z);

   return point;
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#multiply
* @memberof DSMath.Quaternion
* @method multiplyQuatByQuat
* @instance
* @description
* Multiplies <i>this</i> quaternion by another quaternion.
*<br>
* The multiplication is not commutative.
* @param {DSMath.Quaternion} iQ The quaternion <i>this</i> is to be multiplied by.
* @example
* var q0 = new DSMath.Quaternion();
* q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
* var q1 = new DSMath.Quaternion();
* q1.makeRotation(DSMath.Vector3D.xVect, Math.PI);
* var q2 = q0.multiplyQuatByQuat(q1); // q2===q0 and q2=(s=0,x=1/&#8730;2,y=1/&#8730;2,z=0)
* @returns {DSMath.Quaternion} this modified quaternion reference
*/
DSMath.Quaternion.prototype.multiplyQuatByQuat = function (iQ) {

   var s = this.s;
   var x = this.x;
   var y = this.y;
   var z = this.z;

   var qs = iQ.s;
   var qx = iQ.x;
   var qy = iQ.y;
   var qz = iQ.z;

   this.s = s*qs - x*qx - y*qy - z*qz;
   this.x = s*qx + x*qs + y*qz - z*qy;
   this.y = s*qy - x*qz + y*qs + z*qx;
   this.z = s*qz + x*qy - y*qx + z*qs;

   return this;
};

// --------------------------- STATIC --------------------------------------

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#multiply
* @memberof DSMath
* @method multiplyQuatByQuat
* @instance
* @description
* Multiplies two quaternions.
* <br>
* The multiplication is not commutative.
* @param {DSMath.Quaternion} iQ1 The first quaternion.
* @param {DSMath.Quaternion} iQ2 The second quaternion.
* @example
* var q0 = new DSMath.Quaternion();
* q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
* var q1 = new DSMath.Quaternion();
* q1.makeRotation(DSMath.Vector3D.xVect, Math.PI);
* var q2 = DSMath.multiplyQuatByQuat(q0, q1); // q2!==q0 and q2=(s=0,x=1/&#8730;2,y=1/&#8730;2,z=0)
* @returns {DSMath.Quaternion} The new quaternion.
*/
DSMath.multiplyQuatByQuat = function (iQ1, iQ2, oQ) {
   oQ = (arguments.length < 3)? iQ1.clone() : oQ.copy(iQ1);
   return oQ.multiplyQuatByQuat(iQ2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Quaternion#conjugate
* @memberof DSMath
* @method conjugate
* @instance
* @description
* Calculates the conjugate of a quaternion.
* <pre>
* q_conj = [ s, -x, -y, -z ]
* </pre>
* @param {DSMath.Quaternion} iQ The quaternion to conjugate.
* @param {DSMath.Quaternion} [oQ] Reference of the operation result (avoid allocation).
* @example
* var q0 = new DSMath.Quaternion(1,2,3,4);
* var q1 = DSMath.conjugate(q0); // q1!==q0 and q1=(s=1,x=-2,y=-3,z=-4)
* @returns {DSMath.Quaternion} The reference of the operation result.
*/
DSMath.conjugate = function (iQ, oQ) {
   oQ = (oQ)? oQ.copy(iQ) : iQ.clone();
   return oQ.conjugate();
};

// ============================================================ //
//                       LINE METHODS                           //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Line#setOrigin
* @see DSMath.Line#setDirection
* @memberof DSMath.Line
* @method setOriginAndVector
* @instance
* @description
* Assigns a new origin and a new direction to the line.
* @param {DSMath.Point } iO
* @param {DSMath.Vector3D } iD
* @example
* var line = new DSMath.Line(DSMath.Point.origin, DSMath.Vector3D.zVect);
* line.setOriginAndVector(new DSMath.Point(1,1,1), DSMath.Vector3D.xVect);
*/
DSMath.Line.prototype.setOriginAndVector = function(iO, iD) {
   this.origin = iO;
   this.direction = iD;
};

/**
* @private
* @deprecated R419
* @see DSMath.Line#squareDistanceToPoint
* @memberof DSMath.Line
* @method lnPtSquareDistanceTo
* @instance
* @description
* Returns the square distance between <i>this</i> line and the given point.
* @param {DSMath.Point} iP The point.
* @example
* var p0 = new DSMath.Point(-Math.SQRT2, Math.SQRT2, 0);
* var l0 = new DSMath.Line().setDirection(Math.SQRT1_2, Math.SQRT1_2, 0);
* var sqDist = l0.lnPtSquareDistanceTo(p0); // sqDist=4;
* @return {Number} The square distance between <i>this</i> line and the point given.
*/
DSMath.Line.prototype.lnPtSquareDistanceTo = function (iP) {
   return this.squareDistanceToPoint(iP);
};

/**
* @private
* @deprecated R419
* @see DSMath.Line#distanceToPoint
* @memberof DSMath.Line
* @method lnPtDistanceTo
* @instance
* @description
* Returns the distance between <i>this</i> line and the given point.
* @param {DSMath.Point} iP The point.
* @example
* var p0 = new DSMath.Point(-Math.SQRT2, Math.SQRT2, 0);
* var l0 = new DSMath.Line().setDirection(Math.SQRT1_2, Math.SQRT1_2, 0);
* var dist = l0.lnPtDistanceTo(p0); // dist=2;
* @return {Number} The distance between <i>this</i> line and the point given.
*/
DSMath.Line.prototype.lnPtDistanceTo = function (iP) {
   return this.distanceToPoint(iP);
};

/**
* @private
* @deprecated R419
* @see DSMath.Line#distanceToLine
* @memberof DSMath.Line
* @method lnLnDistanceTo
* @instance
* @description
* Returns the distance between <i>this</i> line and another line.
* @param {DSMath.Line} l2 The second line.
* @return {{dist: Number, param1: Number, param2: Number, diag: Number}} An object with three properties:
* <ul>
* <li><tt>dist</tt> which is the distance between the two lines.
* <li><tt>param1</tt> which is the parameter of the point achieving the computed distance on <i>this</i> line.
* <li><tt>param2</tt> which is the parameter of the point achieving the computed distance on the line specified in argument.
* <li><tt>diag</tt> which is a parameter indicating whether the distance can be computed.
  If the lines are identical (<tt>diag</tt> = 2) or parallel (<tt>diag</tt> = 0),  <tt>param1</tt> as well as <tt>param1</tt> are null. 
* </ul>
* The precision used to compute the parallelism is <span style="text-decorationverline;">(10<sup>-15</sup>)</span>.
* @example
* var l0 = new DSMath.Line().setDirection(1,1,0);
* var l1 = new DSMath.Line().set(1,1,2, 1,-1,0);
* var oD = {param1:0, param2:0};
* var distL0L1 = l0.lnLnDistanceTo(l1,oD); // distL0L1=2 and oD.param1=1, oD.param2=0
*/
DSMath.Line.prototype.lnLnDistanceTo = function (l2) {
    var d_out = { dist: 0, param1: 0, param2: 0, diag: 1 };
    var vLine2 = l2.direction;
    var oLine2 = l2.origin;
    this.direction.normalize();

    var oThis = this.origin;
    var vThis = this.direction;


    var dProduct = vLine2.dot(vThis);
    //dop("dProduct", dProduct); // scalaire
    var vO1O2 = this.origin.sub(l2.origin);
    if (Math.abs(Math.abs(dProduct - 1.)) < Math.pow(10, -15)) {
        d_out.dist = (DSMath.Vector3D.cross(vLine2, l2.direction)).norm();
        if (d_out.dist < Math.pow(10, -15)) { d_out.diag = 2; }
        else { d_out.diag = 0; }
    }

    d_out.param1 = vO1O2.dot(vLine2) - dProduct * (vO1O2.dot(vThis)) / ((1 - dProduct * dProduct) * l2.scale);
    d_out.param2 = dProduct * (vO1O2.dot(vLine2)) - vO1O2.dot(vThis) / ((1 - dProduct * dProduct) * this.scale);

    var vVect = DSMath.Vector3D.cross(vLine2, vThis);
    var norVect = vVect.norm();
    if (norVect > 0.) { d_out.dist = Math.abs(vO1O2.dot(vVect) / norVect); }
    else { d_out.dist = (DSMath.Vector3D.cross(vO1O2, vLine2)).norm(); }
    d_out.diag = 1;

    return d_out;
};

/**
* @private
* @deprecated R419
* @see DSMath.Line#intersectLine
* @memberof DSMath.Line
* @method lnLnIntersect
* @instance
* @description
* Intersects a portion of <i>this</i> line with a portion of the specified line.
* @param {DSMath.Line} iLine The second line.
* @param {Number} iStartThis Start parameter defining the segment of <i>this</i> line to be intersected.
* @param {Number} iEndThis End parameter defining the segment of <i>this</i> line to be intersected.
* @param {Number} iStartLine Start parameter defining the segment of the specified line to be intersected.
* @param {Number} iEndLine End parameter defining the segment of specified line to be intersected.
* @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
* @return {IntersectionLineData} The intersection result.
* @example
* var l0 = new DSMath.Line().setDirection(1,1,0);
* var l1 = new DSMath.Line().setOrigin(0,1,1).setDirection(-1,0,1);
* var intl0l1 = l0.lnLnIntersect(l1, -1, 1, -1, 1); // intl0l1.diag=1, intl0l1.param1=1, intL0l1.param2=-1;
*/
DSMath.Line.prototype.lnLnIntersect = function (line1, dStart1, dEnd1, dStart2, dEnd2, dTol) {
// CODE INCORRECT (param inversé + diag=1) Convergence to Line.intersectLine(...);
    var p_out = { param1: 0, param2: 0, diag: 0 };
    var uv = line1.direction.dot(this.direction);
    var uv2 = uv * uv;
    var det = uv2 - 1.;
    // numerical precision
    if (Math.abs(det) > Math.pow(10,-15)) {
        var vO1O2 = DSMath.vectorFromPoints(this.origin, line1.origin);
        var O1O2u = vO1O2.dot(line1.direction);
        var O1O2v = vO1O2.dot(this.direction);
        var lambda1 = (O1O2v * uv - O1O2u) / det;
        var lambda2 = (O1O2v - O1O2u * uv) / det;

        if (lambda1 < dStart1 * line1.scale) { lambda1 = dStart1 * line1.scale; }
        else if (lambda1 > dEnd1 * line1.scale) { lambda1 = dEnd1 * line1.scale; }

        if (lambda2 < dStart2 * this.scale) { lambda2 = dStart2 * this.scale; }
        else if (lambda2 > dEnd2 * this.scale) { lambda2 = dEnd2 * this.scale; }

        var P1 = DSMath.addVectorToPoint(line1.origin, DSMath.multiplyVector(line1.direction, lambda1));
        var P2 = DSMath.addVectorToPoint(this.origin, DSMath.multiplyVector(this.direction, lambda2));
        if (P1.ptPtSquareDistanceTo(P2) < dTol * dTol) {
            p_out.param1 = lambda1 / line1.scale;
            p_out.param2 = lambda2 / this.scale;
            p_out.diag = 0; // there is an intersection    
        }
        p_out.diag = 1; // no intersection    
    }
    return p_out;
};

// --------------------------- STATIC --------------------------------------


// ============================================================ //
//                       PLANE METHODS                          //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Plane#getDirections
* @memberof DSMath.Plane
* @method getVectors
* @instance
* @description
* Retrieves a copy of the plane directions.
* @param {DSMath.Vector3D[]} [oA] The reference of the operator result (avoid allocation).
* @example
* var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
* var dir = pl0.getVectors();
* @returns {DSMath.Vector3D[]} Reference of the operation result - The array of orthonormalized direction ([first direction, second direction]).
*/
DSMath.Plane.prototype.getVectors = function(oA){
   oA = oA || new Array(new DSMath.Vector3D(), new DSMath.Vector3D());
   return this.getDirections(oA);
};

/**
* @private
* @deprecated R419
* @see DSMath.Plane#makeFromPoints
* @memberof DSMath.Plane
* @method set3Points
* @instance
* @description
* Defines <i>this</i> plane from three points.
* @param {DSMath.Point} iO The origin of the plane.
* @param {DSMath.Point} iP1 The point which iP1-iO represents the first plane direction.
* @param {DSMath.Point} iP2 The point which iP2-iO represents the second plane direction.
* @example
* var p0 = new DSMath.Point(1,1,1);
* var p1 = new DSMath.Point(2,2,1);
* var p2 = new DSMath.Point(0,1,1);
* var pl0 = new DSMath.Plane().set3Points(p0,p1,p2); // pl0.origin = p0
* var dir = pl0.getDirections(); // dir[0] = (1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0);
* @returns {DSMath.Plane} this modified plane reference.
*/
DSMath.Plane.prototype.set3Points = function (iO, iP1, iP2){
   return this.makeFromPoints(iO,iP1,iP2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Plane#setOrigin
* @see DSMath.Plane#setVectors
* @memberof DSMath.Plane
* @method setPointAndVectors
* @instance
* @description
* Defines a plane from one point and two directions.
* @param {DSMath.Point} p1 The first point.
* @param {DSMath.Vector3D} v1 The first vector.
* @param {DSMath.Vector3D} v2 The second vector.
* @example
* var pl0 = new DSMath.Plane();
* pl0.setPointAndVectors(DSMath.Point.origin, DSMath.Vector3D.yVect, DSMath.Vector3D.zVect);
*/
DSMath.Plane.prototype.setPointAndVectors = function (p1, v1, v2) {
   this.setOrigin(p1).setVectors(v1,v2);
};

/**
* @private
* @deprecated R419
* @see DSMath.Plane#setOrigin
* @see DSMath.Plane#setNormal
* @memberof DSMath.Plane
* @method setOriginAndNormal
* @instance
* @description
* Defines a plane from one point and a normal vector.
* @param {DSMath.Point} iO The new plane origin.
* @param {DSMath.Vector3D} iN The new plane normal.
* @example
* var p0 = new DSMath.Point(1,1,1);
* var n0 = new DSMath.Vector3D(1,1,0);
* var pl0 = new DSMath.Plane();
* pl0.setOriginAndNormal(p0,n0); // pl0.origin==p0
* var dir = pl0.getDirections(); // dir[0]=(1/&#8730;2
*/
DSMath.Plane.prototype.setOriginAndNormal = function (iO, iN) {
   this.setOrigin(iO).setNormal(iN);
};

/**
* @private
* @deprecated R419
* @see DSMath.Point#projectOnPlane
* @memberof DSMath.Plane
* @method projectPointToPlane
* @description
* Projects a point onto a plane.
* @param {DSMath.Point} iP The point to be projected.
* @example
* var pl0 = new DSMath.Plane().setOrigin(1,0,0).setVectors(1,1,0, 1,0,1);
* var p0 = new DSMath.Point(0,0,0);
* var p1 = pl0.projectPointToPlane(p0); //p1===p0 and p1=((1+&#8730;3)/&#8730;6, 0, 0)
* @returns { DSMath.Point } The new projected point.
*/
DSMath.Plane.prototype.projectPointToPlane = function (iP) {
   return iP.clone().projectOnPlane(this);
};

/**
* @private
* @deprecated R419
* @see DSMath.Plane#intersectLine
* @memberof DSMath.Plane
* @method intersectLineAndPlane
* @description
* Computes the intersection of a line and <i>this</i> plane.
* @param {DSMath.Line} iL The line to be intersected with <i>this</i> plane.
* @example
* var pl0 = new DSMath.Plane();
* var l0 = new DSMath.Line().setOrigin(0,1,1).setDirection(1,0,-1);
* var l1 = new DSMath.Line().setOrigin(0,1,1).setDirection(1,0,0);
* var l2 = new DSMath.Line().setOrigin(0,0,0).setDirection(1,0,0);
* var intl0pl0 = pl0.intersectLineAndPlane(l0); // intl0pl0={paramOnLine=1,param1OnPlane=1,param2OnPlane=1,diagnosis=1}
* var intl1pl0 = pl0.intersectLineAndPlane(l1); // intl1pl0={paramOnLine=0,param1OnPlane=0,param2OnPlane=0,diagnosis=0}
* var intl2pl0 = pl0.intersectLineAndPlane(l2); // intl2pl0={paramOnLine=0,param1OnPlane=0,param2OnPlane=0,diagnosis=2}
* @returns { IntersectionLinePlaneData } The intersection result.
*/
DSMath.Plane.prototype.intersectLineAndPlane = function (l) {
    var obj_out = { paramOnline: 0, param1OnPlane: 0, param2OnPlane: 0, diagnosis: -1 };
    var lOrigin = l.origin;
    var lDir = l.direction;
    var vect = this.getDirectionsNotCloned();
    var ix = vect[0].x;
    var iy = vect[0].y;
    var iz = vect[0].z;

    var jx = vect[1].x;
    var jy = vect[1].y;
    var jz = vect[1].z;

    //vector
    var kx = lDir.x;
    var ky = lDir.y;
    var kz = lDir.z;
    // line origin
    var ox = lOrigin.x;
    var oy = lOrigin.y;
    var oz = lOrigin.z;
    // plane origin
    var xPlnOri = this.origin.x;
    var yPlnOri = this.origin.y;
    var zPlnOri = this.origin.z;

    xPlnOri = ox - xPlnOri;
    yPlnOri = oy - yPlnOri;
    zPlnOri = oz - zPlnOri;

    var a = jy * kz - jz * ky;
    var b = jx * kz - jz * kx;
    var c = jx * ky - jy * kx;
    var det = ix * a - iy * b + iz * c;

    if (Math.abs(det) >= DSMath.defaultTolerances.epsilonForRelativeTest) {
        det = 1. / det;
        obj_out.param1OnPlane = (xPlnOri * a - yPlnOri * b + zPlnOri * c) * det;
        obj_out.param2OnPlane = (ix * (yPlnOri * kz - zPlnOri * ky) - iy * (xPlnOri * kz - zPlnOri * kx) + iz * (xPlnOri * ky - yPlnOri * kx)) * det;
        obj_out.paramOnLine = -(ix * (jy * zPlnOri - jz * yPlnOri) - iy * (jx * zPlnOri - jz * xPlnOri) + iz * (jx * yPlnOri - jy * xPlnOri)) * det;
        obj_out.paramOnLine = obj_out.paramOnLine / l.scale;
    }
    else {
        // The plane and the line are parallel
        obj_out.paramOnLine = 0.;
        obj_out.param1OnPlane = 0.;
        obj_out.param2OnPlane = 0.;
        // Calculate the distance
        var V = new DSMath.Vector3D();
        V.x = xPlnOri;
        V.y = yPlnOri;
        V.z = zPlnOri;
        var vC = DSMath.Vector3D.cross(vect[0], vect[1]);
        if (Math.abs(V.dot(vC)) < 1e-13) {
            obj_out.diagnosis = 2;  // line relies on the plane
        }
        else { obj_out.diagnosis = 0; } // no solution
    }
    obj_out.diagnosis = 1; // intersection point

    return obj_out;
};

// --------------------------- STATIC --------------------------------------

// ============================================================ //
//                         AXIS METHODS                         //
// ============================================================ //
/**
* @private
* @deprecated R419
* @see DSMath.Axis#getDirections
* @memberof DSMath.Axis
* @method getVectors
* @description
* Retrieves the directions of an axis.
* @param {DSMath.Vector3D[]} [oD] Reference of the operation result (avoid allocation).
* @example
* var m0 = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
* var a0 = new DSMath.Axis().setOrigin(1,2,3).setVectorsFromMatrix(m0); // a0.origin=(1,2,3)
* var dir = a0.getVectors(); //dir[0]=(0,1,0) and dir[1]=(-1,0,0) and dir[2]=(0,0,1)
* @returns {DSMath.Vector3D[]} The reference of the operation result - The three cloned directions.
*/
DSMath.Axis.prototype.getVectors = function (oD) {
   return this.getDirections((oD)? oD : undefined);
}

// --------------------------- STATIC --------------------------------------

   return DSMath;
});

