define('DS/ENXDataGrid/URLUtils', [
], function(
) {
    var url = {};
	url.getParameter = function(param) {
		var href = document.location.href;
		var value = "";
		var queryString = href.split("?")[1];
		if (queryString) {
			var paramValue = queryString.split("&");
			if (paramValue) {
				for(var i = 0; i < paramValue.length; i++) {
					var paramName = paramValue[i].split("=");
					if (paramName[0] && paramName[0] == param) {
						value = paramName[1];
					}
				}
			}
		}
		
		return value;
	};

	url.getParameterNames = function() {
		var href = document.location.href;
		var value = new Array();
		var queryString = href.split("?")[1];
		if (queryString) {
			var paramValue = queryString.split("&");
			if (paramValue) {
				for(var i = 0; i < paramValue.length; i++) {
					var paramName = paramValue[i].split("=");
					if (paramName[0]) {
						value.push(paramName[0]);
					}
				}
			}
		}
		
		return value;
	};

	url.getQueryString = function() {
		var href = document.location.href;
		var value = "";
		var queryString = href.split("?")[1];
		if (queryString) {
			value = queryString;
		}
		
		return value;
	};
	
	url.getParametersMap = function(){
		var paramsMap = {};
		var queryString = this.getQueryString();
		if(queryString) {
			var paramValue = queryString.split("&");
			if(paramValue) {
				for(var i = 0; i < paramValue.length; i++) {
					var param = paramValue[i].split("=");
					paramsMap[param[0]] = param[1];
				}
			}
		}
		return paramsMap;
	};

	url.changeParamValue = function(param, newValue){
		var href = document.location.href;
		var value = "";
		var queryString = href.split("?")[1];
		if (queryString) {
			var paramValue = queryString.split("&");
			if (paramValue) {
				for(var i = 0; i < paramValue.length; i++) {
					var paramName = paramValue[i].split("=");
					if (paramName[0] && paramName[0] == param) {
						value = paramName[1];
					}
				}
			}
		}
		if (value.length > 0) {
			href = location.href.replace(param + "=" + value , param + "=" + newValue);
		} else {
			href = location.href + "&" + param + "=" + newValue;
		}
		
		return href;
	};

	return url;
});

