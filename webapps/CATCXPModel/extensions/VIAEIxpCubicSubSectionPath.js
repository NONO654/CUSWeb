
define('DS/CATCXPModel/extensions/VIAEIxpCubicSubSectionPath',
[
	'UWA/Core',
    'MathematicsES/MathsDef',
],

function (
    UWA,
    DSMath
    ) {
    'use strict';

    var VIAEIxpCubicSubSectionPath = UWA.Class.extend(
	{
	    init: function (iPt1, iPt2, iTgt1, iTgt2) {
	        this._Pt1 = iPt1;
	        this._Pt2 = iPt2;
	        this._Tgt1 = iTgt1;
	        this._Tgt2 = iTgt2;

	        this._approximationNbSamplePt = 20;

	        this._length = 0;
	        this._l = [];

	        this._updateData();
	    },

	    getLength:function(){
	        return this._length;
	    },

	    getValueFromLengthRatio: function (iTotalLengthRatio) {
	        var param = this._getParametrizationFromLengthRatio(iTotalLengthRatio);

	        if (param >= 0 && param <= 1) {
	            return this._Pt1.clone().multiplyScalar(1 - 3 * Math.pow(param, 2) + 2 * Math.pow(param, 3)).addVectorToVector(
                     this._Pt2.clone().multiplyScalar(3 * Math.pow(param, 2) - 2 * Math.pow(param, 3))).addVectorToVector(
                     this._Tgt1.clone().multiplyScalar(param - 2 * Math.pow(param, 2) + Math.pow(param, 3))).addVectorToVector(
                     this._Tgt2.clone().multiplyScalar(Math.pow(param, 3) - Math.pow(param, 2)));
	        }
	    },

	    _getParametrizationFromLengthRatio: function (oLengthRatio) {
	        var param = -1;
	        var seachrLength = oLengthRatio * this._length;

	        if (this._l.length>=this._approximationNbSamplePt)
	        {
	            var i=0;
	            if(seachrLength>=this._l[this._approximationNbSamplePt/2]){
	                i = this._approximationNbSamplePt/2;
	            }

	            while(seachrLength>=this._l[i] && i<this._approximationNbSamplePt - 1){
	                i++;
	            }
	            i--;

	            var delta_l = (this._l[i+1]-this._l[i]);
	            if (delta_l!==0)
	            {
	                var normedLength = (seachrLength -this._l[i])/delta_l;
	                if (this._P1 && this._P2 && this._P3 && this._P4 && i>=0 && i<(this._approximationNbSamplePt-1))
	                {
	                    param = this._P1[i] * Math.pow(normedLength, 3) + this._P2[i] * Math.pow(normedLength, 2) + this._P3[i] * normedLength + this._P4[i];
	                }
	            }
	        }
	        return param;
	    },

	    _updateData: function () {
	        var sizeP = this._approximationNbSamplePt-1;
	        this._P1 = this._initArray(sizeP);
	        this._P2 = this._initArray(sizeP);
	        this._P3 = this._initArray(sizeP);
	        this._P4 = this._initArray(sizeP);
           
	        var Ax = 2.0 * this._Pt1.x + 1.0 * this._Tgt1.x - 2.0 * this._Pt2.x + 1.0 * this._Tgt2.x;
	        var Bx = -3.0 * this._Pt1.x - 2.0 * this._Tgt1.x + 3.0 * this._Pt2.x - 1.0 * this._Tgt2.x;
	        var Cx = 1.0 * this._Tgt1.x;
	        var Dx = 1.0 * this._Pt1.x;

	        var Ay = 2.0 * this._Pt1.y + 1.0 * this._Tgt1.y - 2.0 * this._Pt2.y + 1.0 * this._Tgt2.y;
	        var By = -3.0 * this._Pt1.y - 2.0 * this._Tgt1.y + 3.0 * this._Pt2.y - 1.0 * this._Tgt2.y;
	        var Cy = 1.0 * this._Tgt1.y;
	        var Dy = 1.0 * this._Pt1.y;

	        var Az = 2.0 * this._Pt1.z + 1.0 * this._Tgt1.z - 2.0 * this._Pt2.z + 1.0 * this._Tgt2.z;
	        var Bz = -3.0 * this._Pt1.z - 2.0 * this._Tgt1.z + 3.0 * this._Pt2.z - 1.0 * this._Tgt2.z;
	        var Cz = 1.0 * this._Tgt1.z;
	        var Dz = 1.0 * this._Pt1.z;



	        var a = 9.0 * (Math.pow(Ax, 2) + Math.pow(Ay, 2) + Math.pow(Az, 2));
	        var b = 12.0 * (Ax * Bx + Ay * By + Az * Bz);
	        var c = 6.0 * (Ax * Cx + Ay * Cy + Az * Cz) + 4.0 * (Math.pow(Bx, 2) + Math.pow(By, 2) + Math.pow(Bz, 2));
	        var d = 4.0 * (Bx * Cx + By * Cy + Bz * Cz);
	        var e = Math.pow(Cx, 2) + Math.pow(Cy, 2) + Math.pow(Cz, 2);


	        var delta_t = 1.0 / (this._approximationNbSamplePt - 1);
	
	        var t = this._initArray(this._approximationNbSamplePt);
	        var V = this._initArray(this._approximationNbSamplePt);
	        var dV = this._initArray(this._approximationNbSamplePt);

	        for (var i = 0; i < this._approximationNbSamplePt; i++) {
	            var t_i = i * delta_t;
	            t[i] = t_i;
	            V[i] = 0.;
                dV[i] = 0.;

	            var f_i = a * Math.pow(t_i, 4) + b * Math.pow(t_i, 3) + c * Math.pow(t_i, 2) + d * t_i + e;
	            if (f_i >= 0) {
	                V[i] = Math.sqrt(f_i);
	                if (V[i] !== 0) {
	                    dV[i] = (4.0 * a * Math.pow(t_i, 3) + 3.0 * b * Math.pow(t_i, 2) + 2.0 * c * t_i + d) / (2.0 * V[i]);
	                }
	            }

	            if (i===0) {
	                this._l.push(0.);
	            }
	            else
	            {
	                var c1 = delta_t*(dV[i] + dV[i-1]) + 2.0*(V[i-1]-V[i]);
	                var c2 = 3.0*(V[i]-V[i-1]) - delta_t*(2.0*dV[i-1] + dV[i]);
	                var c3 = dV[i-1]*delta_t;
	                var c4 = V[i-1];

	                var l_i = delta_t*((c1/4.0) + (c2/3.0) + (c3/2.0) + c4);
	                var l_i_prev = this._l[this._l.length - 1];
	                this._l.push(l_i_prev + l_i);

	                if (V[i-1]!==0 && V[i]!==0)
	                {
	                    this._P1[i-1] = 2.0*t[i-1] + (l_i/V[i-1]) - 2.0*t[i] + (1.0/V[i])*l_i;
	                    this._P2[i-1] = -3.0*t[i-1] - 2.0*(l_i/V[i-1]) + 3.0*t[i] - (l_i/V[i]);
	                    this._P3[i-1] = (l_i/V[i-1]);
	                    this._P4[i-1] = t[i-1];
	                }
	            }
	        }
	        this._length = this._l[this._approximationNbSamplePt - 1];
	    },

	    _initArray: function (iSize) {
	        var array = [];
	        for (var i = 0; i < iSize; i++) {
	            array.push(0);
	        }
	        return array;
	    },



	});

    return VIAEIxpCubicSubSectionPath;
});
