(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.dataprovider !== 'undefined') {
        return;
    }

    var dataProviderPrototype = { is: 'ra-dataprovider' };

    dataProviderPrototype.createdCallback = function() {
        this.requests = {};
        this.serverURL = 'localhost';
        this.token = 'notoken';
        this.userId = '';
        this.requestProcessor = function() {};
    };

    dataProviderPrototype.setRequestProcessor = function(func) {
        this.requestProcessor = func;
    };

    dataProviderPrototype.setServerURL = function(url, token, userId) {
        this.serverURL = url;
        this.token = token;
        this.userId = userId;
    };

    dataProviderPrototype.makeHTTPRequest = function(url, callback) {
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState === 4 && request.status === 200) {
                // TODO: Parse data before calling callback
                var response = request.responseText;

                if (typeof callback === 'function') {
                    callback(response);
                }
            }
        };

        // The request headers are set in this method
        request.open('GET', url, true); // This makes an asynchronous xmlHTTPRequest
        // to the specified url.
        this.requestProcessor(request);
        request.send(null);

        // return deferred
    };

    dataProviderPrototype.makeHTTPPostRequest = function(url, data, callback) {
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState === 4 && request.status === 200) {
                // TODO: Parse data before calling callback
                var response = request.responseText;

                if (typeof callback === 'function') {
                    callback(response);
                }
            }
        };

      
        request.open('POST', url, true); // This makes an asynchronous xmlHTTPRequest
        // to the specified url.
              
        request.setRequestHeader(
                                'X-CSRFToken',
                                 this.token
                            );
                            
        request.setRequestHeader(
                                'ra-from-user',
                                this.userId 
                            );                            
                            
        request.send(data);
    };

    dataProviderPrototype.getPostURL = function(
        requestName,
        data,
        chart,
        uniqueId
    ) {
        data = data || {}; // Give empty object if no data.

        var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest';
            
        // Ideally commandName should also be ib dataString but due to a bug in servant code
        // SMAHttpRequest::readParameters we have to put in query
              
        var dataString = 'supportName='+requestName;
        
        if (chart && chart.chartId && chart.chartId.length) {
            var chartId = chart.chartId;
            dataString +=  '&chartId=' + chartId;
        }
        if (uniqueId && uniqueId.length) {
            dataString+= '&uniqueId=' + uniqueId;
        }
        
        var valueString;
        var dataKeys = Object.keys(data);
        if (typeof data !== 'undefined') {
            for (var key in data) {
                if (data.hasOwnProperty(key)) {
                    valueString =
                        typeof data[key] === 'string'
                            ? encodeURIComponent(data[key])
                            : encodeURIComponent(JSON.stringify(data[key]));

                    dataString += '&' + key + '=' + valueString;
                }
            }
        }
        
        return { 'url': url, 'dataString': dataString } ;
    };
    
    dataProviderPrototype.getURL = function(
        requestName,
        data,
        chart,
        uniqueId
    ) {
        data = data || {}; // Give empty object if no data.

        var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=' +
            requestName;
        url = this.appendRequestIDs(url, chart, uniqueId);
        var dataString;
        var dataKeys = Object.keys(data);
        if (typeof data !== 'undefined') {
            for (var key in data) {
                if (data.hasOwnProperty(key)) {
                    dataString =
                        typeof data[key] === 'string'
                            ? encodeURIComponent(data[key])
                            : encodeURIComponent(JSON.stringify(data[key]));

                    url += '&' + key + '=' + dataString;
                }
            }
        }

        return url;
    };

    dataProviderPrototype.appendRequestIDs = function(url, chart, uniqueId) {
        if (chart && chart.chartId && chart.chartId.length) {
            var chartId = chart.chartId;
            url += '&chartId=' + chartId;
        }
        if (uniqueId && uniqueId.length) {
            url += '&uniqueId=' + uniqueId;
        }
        return url;
    };
    dataProviderPrototype.getResourceAsUrl = function(
        supportId,
        resourceId,
        callback,
        chart,
        uniqueId
    ) {
        var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=getResource&supportId=' +
            supportId +
            '&resourceId=' +
            resourceId;
        url = this.appendRequestIDs(url, chart, uniqueId);
        if (typeof callback === 'function') {
            callback(url);
        }

        // return deferred
    };

    dataProviderPrototype.getResource = function(
        supportId,
        resourceId,
        callback,
        chart,
        uniqueId
    ) {
        var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=getResource&supportId=' +
            supportId +
            '&resourceId=' +
            resourceId;
        url = this.appendRequestIDs(url, chart, uniqueId);
        return this.makeHTTPRequest(url, callback);
    };

    dataProviderPrototype.executeGenerateApproximations = function(inputIdList, outputIdList, callback){
     
          
     var settings = {'polyOrder': '2', 'enableTermSelection': 'false'} ;
     var approxId =  '_' + Math.random().toString(36).substr(2, 9);
     
     var data= 'displayName='+ approxId + '&type=rsm&settings=' + JSON.stringify(settings);
     
     data += '&inputIdList=' + JSON.stringify(inputIdList);
     data += '&outputIdList=' + JSON.stringify(outputIdList);
     
     
     
     
     var url =
            this.serverURL +
            'executeCommand?commandGroup=approximation&commandName=getApproximationCoefficientsForPareto';
        this.makeHTTPPostRequest(url, data, callback);
    
    }
    
    dataProviderPrototype.getParametersData = function(datasetId, parameterIdList, callback){     
          

     
     var data= 'paramIDs=' + parameterIdList.join(","); 
     
     data += '&datasetId=' + datasetId;
     
     var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=getColumnsAsJson';
        this.makeHTTPPostRequest(url, data, callback);
    
    }
    
    dataProviderPrototype.setSelectionPoints = function(datasetId, rowIds, callback){     

     
     var data= '';
     var supportFunction = 'setSelectionPoints';
     if(rowIds.length !== 0){
        data = 'rowIDs=' + rowIds.join(",") +'&'; 
     }else{
        supportFunction = 'unsetAllSelectionPoints';
     }
     
     
     data += 'datasetId=' + datasetId;
     
     var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=' + supportFunction;
        this.makeHTTPPostRequest(url, data, callback);
    
    }
    
     dataProviderPrototype.getSelectionFlagColumn = function(datasetId, callback){     

     var data = 'datasetId=' + datasetId;
     
     var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=getSelectionFlagColumn';
        this.makeHTTPPostRequest(url, data, callback);
    
    }
    
    
    dataProviderPrototype.registerSupport = function(
        requestName,
        requestCallback
    ) {
        this.requests[requestName] = requestCallback;
    };

    dataProviderPrototype.setDefaultRequest = function(fn) {
        this.defaultRequest = fn;
    };

    dataProviderPrototype.defaultRequest = function(
        requestName,
        data,
        callback,
        chart,
        uniqueId
    ) {
        if (typeof data === 'function') {
            callback = data;
            data = {};
        }
        if (typeof callback !== 'function') {
            callback = function() {};
        }
        data = data || {};

        var url = this.getURL(requestName, data, chart, uniqueId);
        this.makeHTTPRequest(url, callback);
    };

    dataProviderPrototype.executeSupport = function(
        requestName,
        data,
        callback,
        chart,
        uniqueId
    ) {
        if (typeof data === 'function') {
            callback = data;
            data = {};
        }
        if (typeof callback !== 'function') {
            callback = function() {};
        }
        data = data || {};

        var request = this.requests[requestName];
        if (typeof request === 'function') {
            return request.call(this, data, callback);
        } else {
            this.defaultRequest(requestName, data, callback, chart, uniqueId);
        }
    };

    dataProviderPrototype.executePostSupport = function(
        requestName,
        data,
        callback
    ) {
        if (typeof data === 'function') {
            callback = data;
            data = {};
        }
        if (typeof callback !== 'function') {
            callback = function() {};
        }
        data = data || {};
        // This doesn't work with registered supports for now.
        var request = this.requests[requestName];
        if (typeof request === 'function') {
            return request.call(this, data, callback);
        } else {
            ///////////////////
            var url =
                this.serverURL +
                'executeCommand?supportName=getResource&supportId=' +
                requestName;

            var request = new XMLHttpRequest();
            request.onreadystatechange = function() {
                if (request.readyState === 4 && request.status === 200) {
                    // TODO: Parse data before calling callback
                    var response = request.responseText;

                    if (typeof callback === 'function') {
                        callback(response);
                    }
                }
            };

            request.open('POST', url, true); // This makes an asynchronous
            // xmlHTTPRequest to the specified url.
            request.setRequestHeader(
                'Content-type',
                'appliocation/x-www-form-urlencoded'
            );
            request.send(JSON.stringify(data));
        }
    };
    // ====================================================================
    // Creates form and downloads file
    // ====================================================================
    dataProviderPrototype.downloadFile = function(requestName, payload, chart, uniqueKey) {
    	var url =
            this.serverURL +
            'executeCommand?commandName=executeSupportRequest&supportName=' +
            requestName;
    	url = this.appendRequestIDs(url, chart, uniqueKey);
    	
        if (!Date.now) {
            Date.now = function() {
                return new Date().getTime();
            };
        }
        // do we need a URL argument to force new report generation?
        if (url.indexOf('&_t=') < 0 && url.indexOf('&') > 0) {
            if (url.indexOf('&') !== url.length - 1) {
                url = url + '&';
            }
            url = url + '_t=' + Date.now();
        }

        var downloadForm =
            document.getElementById('fileDownloadForm') ||
            document.createElement('form');
        downloadForm.id = 'fileDownloadForm';
        downloadForm.action = url;
        downloadForm.style.display = 'none';
        downloadForm.method = 'post';
        downloadForm.setAttribute('target', 'downloadFrame');
        
        // cannot set headers on forms, so send it in the payload
        
        var _payload = {
                payload: payload || '',
                'ra-from-user': this.userId,
                'X-CSRFToken': this.token || 'notoken'
            };
        
        var payloadInput = document.createElement('input');
        payloadInput.setAttribute('type', 'hidden');
        payloadInput.setAttribute('name', 'payload');
        payloadInput.value = JSON.stringify(_payload);
        downloadForm.appendChild(payloadInput);
        // send with a payload to the server (preferably in the form of
        // json)
       
        for (var p in payload||{}) {
        	if(payload.hasOwnProperty(p)) {
        	       var dataInput = document.createElement('input');
        	       dataInput.setAttribute('type', 'hidden');
        	       dataInput.setAttribute('name', p);
        	       dataInput.value = JSON.stringify(payload[p]);
        	       downloadForm.appendChild(dataInput);
        	}
        }

        document.body.appendChild(downloadForm);
        if(document.getElementById('downloadFrame') === null) {
        	var targetFrame = document.createElement('iframe');
        	targetFrame.id = 'downloadFrame';
        	document.body.appendChild(targetFrame);
        }
        window.isDownloadLink = true;
        downloadForm.submit();
        downloadForm.remove();
    }

    dataProviderPrototype.getRequestURL = function() {};

    Polymer(dataProviderPrototype);
    GLOBAL.DS.RAComponents.dataprovider = dataProviderPrototype;
})(this);
