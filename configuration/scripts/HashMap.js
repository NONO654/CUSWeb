
	function jsHashMap() {
	
		this.values = new Array;

		this.put = function(strKey, strValue) {
			// Check if the value for the key is already present
			for (var i = 0; i < this.values.length; i++) {
			
				var arrKeyValue = this.values[i];				
				if (arrKeyValue[0] == strKey) {
					arrKeyValue[1] = strValue;
					return;
				}
			}
			
			// Adding new value if not already present
			var arrKeyValue = new Array;
			arrKeyValue[arrKeyValue.length] = strKey;
			arrKeyValue[arrKeyValue.length] = strValue;

			this.values[this.values.length] = arrKeyValue;

		};

		this.get = function (strKey) {
			// Check if the value for the key is already present
			for (var i = 0; i < this.values.length; i++) {
				var arrKeyValue = this.values[i];
				if (arrKeyValue[0] == strKey) {
					return arrKeyValue[1];
				}
			}

			return null;
		};

		
		this.remove = function (strKey) {
			var arrNewValues = new Array;

			// Check if the value for the key is already present
			for (var i = 0; i < this.values.length; i++) {
				var arrKeyValue = this.values[i];
				if (arrKeyValue[0] != strKey) {
					arrNewValues[arrNewValues.length] = arrKeyValue;
				}
			}

			this.values = arrNewValues;
		};



		this.toString = function () {
			var strValues = "";

			// Check if the value for the key is already present
			for (var i = 0; i < this.values.length; i++) {
				var arrKeyValue = this.values[i];
				if (strValues != "") {
					strValues += ",";
				}
				strValues += "[" + arrKeyValue[0] + "=" + arrKeyValue[1] + "]";
			}

			return strValues;
		};
	}//~jsHashMap
//-->

