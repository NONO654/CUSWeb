/* @quickreview SD4 6/4/2014 remove unused parameters from exml, and set saveToDB=false*/
/* @quickreview SD4 6/2/2014 support https enovia behind a reverse proxy*/
/* @fullreview  SD4 1/31/2014 refactor code during mweb creation*/
//=================================================================================
/**
 * smaAdviseLaunchHelper 
 */
//=================================================================================

//=================================================================================
/**
 * 
 */
//=================================================================================
var AdviseLoadOps = { loadinContentsFrame : 
    function(url) {
        var conFrame = null;
        try{
            conFrame = findFrame(getTopWindow(),"content");
        } catch(e) {
            console.error(e);
            //ignore and carry on
        }
        if(conFrame === null) {
            conFrame = window;
        }
        conFrame.location.href = url;
    }
};

// This is to avoid the failure callback being called
// in the "tryToLaunchAdviseClient" function when servant fails.
var JOB_CANCELLED = false,
	UTILS;

//=======================================================================
/**
 * Set the station name to the RA Splash screen. The name is displayed
 * only when the station is automatically selected. Not displayed when 
 * Configure and Run is used to set affinity. 
 */
//=======================================================================
function setStationNameToSplash(adviseLaunchInfo){
	if(typeof adviseLaunchInfo.stationName !== 'undefined' &&
        adviseLaunchInfo.stationName !== null &&
            adviseLaunchInfo.stationName.length > 0){
        return adviseLaunchInfo.stationName;
    }
    return null;
}

//=======================================================================
/**
 * Set message in the RA Spalsh screen. Station name is optional
 */
//=======================================================================
function showLoadingMessage(messageText, stationName) {
    removeLoadingMessage();
    var msg = messageText;
    if(typeof stationName !== 'undefined' && stationName !== null 
        && stationName.length > 0){
        msg += '<br>Station: ' + stationName;
    }
    $simjq(".sim-ui-splash-progressmessage").html(msg);
}

//=======================================================================
/**
 * removeLoadingMessage
 */
//=======================================================================
function removeLoadingMessage() {
    $simjq(".sim-ui-blocking-background").remove();
    $simjq(".sim-ui-blocking-message").remove();
}

//=================================================================================
/**
 * initiateLoad
 */
//=================================================================================
function initiateLoad(url,action,referrer) {
    // ignore action for now
    sessionStorage.adviseReferrer = sessionStorage.adviseReferrer||referrer||document.referrer;
    AdviseLoadOps.loadinContentsFrame(url);
}

//=================================================================================
/**
 * Returns a url object that can be used to extract the host, domain, protocol.
 * Since IE doesnt support the URL object, uses a href element instead.
 */
//=================================================================================
function getURLObject(url){
    try {
        return new URL(url);
    }
    catch(ex){
        var urlElem = document.createElement('a');
        urlElem.href = url;
        return urlElem;
    }
}

//=================================================================================
/**
 * Function to detect the browser name and version
 */
//=================================================================================
function whichBrowser(){
    var ua=navigator.userAgent,
        tem,
        M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
    
    if(/trident/i.test(M[1])){
        tem=/\brv[ :]+(\d+)/g.exec(ua) || [];
        return {
            name:'IE',
            version:(tem[1]||'')
        };
    }
    
    if(M[1]==='Chrome'){
        tem=ua.match(/\bOPR\/(\d+)/);
        if(tem!=null){
            return {
                name:'Opera',
                version:tem[1]
            };
        }
    }
    
    M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
    
    if((tem=ua.match(/version\/(\d+)/i))!=null) {
        M.splice(1,1,tem[1]);
    }
    
    return {
      name: M[0],
      version: M[1]
    };
}

//=======================================================================
/**
 * Utility function to encode urls
 */
//=======================================================================
function htmlUnescape(value) {
    return String(value).replace(/&quot;/g, '"')
                            .replace(/&#39;/g, "'")
                            .replace(/&lt;/g, '<')
                            .replace(/&gt;/g, '>')
                            .replace(/&amp;/g, '&');
}

//=================================================================================
/**
 * RA Launch Error Handler.
 * Shows the error popup with the appropriate message and callbacks and sends the 
 * user back to the RA Landing page.
 */
//=================================================================================
function adviseGoBack (error, trace, launchComplete){
    if(sessionStorage.adviseReferrer && sessionStorage.adviseReferrer.length>0) {
        console.log("Entered RA from: " + sessionStorage.adviseReferrer);
        delete sessionStorage.adviseReferrer;
    }

    createLaunchPopOver({
        'message': error,
        'trace': trace,
        'close-callback': returnToRALanding
    });
}

//=================================================================================
/**
 * Global jquery 
 */
//=================================================================================
if(typeof jQuery!=='undefined' && typeof $simjq=='undefined') {
    $simjq = jQuery.noConflict();
}

//=================================================================================
/**
 * AdviseLaunchInfo
 */
//=================================================================================
function AdviseLaunchInfo(caseID, ticketURL, eedURL, eedTicket, encodedJobXML,
    runInfo, localIP, mcsUrl, runAsStr, proxyServer, currentUser, userSelectedStation) {
    
    /**
     * This block checks to see if the mcs url
     * that we get back from launch info is correct
     */
    
    var hostUrlObj = getURLObject(document.URL);
    
    if (typeof encodedJobXML !== 'undefined' &&
            encodedJobXML !== null &&
            encodedJobXML.length > 0){
        var jobXML = htmlUnescape(encodedJobXML),
            mcsUri = (jobXML.split('<AppUrl>')[1]).split('</AppUrl>')[0];
        
        // Check if we are in https and appurl is http
        if(document.URL.indexOf('https') === 0 &&
                mcsUri.indexOf('https') < 0){
            
            // Build the new AppUrl
            var mcsUrlObj = getURLObject(mcsUri);
            var newAppUrl = hostUrlObj['protocol'] + '//' + hostUrlObj['hostname'] +
                                + (hostUrlObj['port'].length > 0 ? '/' + hostUrlObj['port'] : '')
                                    + mcsUrlObj['pathname'];
            
            // Replace the old http appUrl in job xml
            encodedJobXML = encodedJobXML.replace(mcsUri, newAppUrl);
            
            // Also set the new app url as the mcsUrl
            mcsUrl = newAppUrl;
        }
    }
    
    // Repeat this for the ticket url too
    if(document.URL.indexOf('https') === 0 &&
            ticketURL.indexOf('https') < 0){
        
        var ticketURLObj = getURLObject(ticketURL);
        
        ticketURL = hostUrlObj['protocol'] + '//' + hostUrlObj['hostname']
                    + (hostUrlObj['port'].length > 0 ? '/' + hostUrlObj['port'] : '')
                    + ticketURLObj['pathname'] + ticketURLObj['search'];
        
    }
    
    // Save the mcs url in localstorage
    localStorage['RA_MCS_URL'] = mcsUrl;
    
    this.caseID = caseID;
    this.eedURL = eedURL;
    this.ticketURL = ticketURL;
    this.eedTicket = eedTicket;
    this.encodedJobXML = encodedJobXML;
    this.eedPublicKey = null;
    this.resourceCredentials = null;
    this.servantURL = null;
    this.runInfo = htmlUnescape(runInfo);
    this.localStationName = null;
    this.stationName = null;
    this.stationIP = null;
    if(!localIP || (localIP && localIP ==='')){
        this.localIP = null;
    } else {
        this.localIP = localIP.trim();
    }
    this.stationList = null;
    this.runAs = false;
    if(runAsStr && runAsStr==='true'){
        this.runAs = true;
    }
    this.proxyServer = proxyServer;
    this.token = eedTicket;
    this.currentUser = currentUser;
    this.userSelectedStation = userSelectedStation || '';
    this.secureStation = false;
    this.stationAccess = "";
    
    if (typeof mcsUrl === 'undefined' ||
            mcsUrl === null ||
            mcsUrl.length === 0 ||
            mcsUrl.indexOf('http') !== 0){
        this.mcsUrl = '';
    } else {
        this.mcsUrl = mcsUrl;
    }
    
    // Name to be displayed in the station
    // ballon inside the RA page.
    this.stationDisplayName = '';
    this.isSecureStation = false;
    // Object contains the COS server's
    // version details
    this.cosMetaData = {};
}

//=================================================================================
/**
 * Alert Message
 */
//=================================================================================
function alertMessage(messageText, func, delay) {
    $simjq('.sim-ui-advise-alert-message-text').text(messageText);
    if (messageText.length < 25) {
        $simjq('.sim-ui-advise-alert-message-text').css('line-height', '4rem');
    } else if (messageText.length < 50) {
        $simjq('.sim-ui-advise-alert-message-text').css('line-height', '2rem');
    } else if (messageText.length < 75) {
        $simjq('.sim-ui-advise-alert-message-text').css('line-height', '1.33rem');
    } else {
        $simjq('.sim-ui-advise-alert-message-text').css('line-height', '1.0rem');
    }
    $simjq('.sim-ui-advise-alert-message').css('opacity', 1.0).show();
    if (!delay) {
        delay = 5000;
    }
    $simjq('.sim-ui-advise-alert-message').animate({ opacity : 0.0 }, delay, function() {
        $simjq('.sim-ui-advise-alert-message').hide();
        if (func) {
            func();
        }
    });
}

//=================================================================================
/** 
 * @param {Object} messageKey
 * @param {Object} suffix
 * @param {Object} cb
 */
//=================================================================================
function showTranslatedMessage(messageKey,suffix,cb){
    require(['DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'],function(NLSUtils){
        var output = NLSUtils.translate(messageKey);
        console.log(output);
        cb(output + suffix);
    });
};

//=================================================================================
/**
 * errorInCaseFunction
 */
//=================================================================================
function errorInCaseFunction() {
    $simjq('body').html('');
    var msg = adviseLaunchInfo.translator.translate('LAUNCH_NO_DATASET') + '<br/>'
                adviseLaunchInfo.translator.translate('LAUNCH_CANCEL');
    adviseGoBack(msg);
}

//=================================================================================
/**
 * Delete the local storage entry for the case that was run earlier.
 * This would cause a new servant to be spawned.
 */
//=================================================================================
function resetRunningServant(caseID) {
    delete localStorage['smaAnalyticsCase' + caseID];
}

//=================================================================================
/**
 * Check if this user has access to run a job in some station.
 */
//=================================================================================
function isAllowedUser(adviseLaunchInfo, stationInfo){
    if(typeof adviseLaunchInfo.currentUser === 'undefined' ||
            adviseLaunchInfo.currentUser === null){
        return false;
    }
    var users = stationInfo.GeneralInfo['@allowedUsers'] || '';
    if(users.length === 0){
        return true;
    }
    var userList = users.split(',');
    for(var i=0; i<userList.length; i++){
        if(userList[i] === adviseLaunchInfo.currentUser){
            return true;
        }
    }
    return false;
}

//=================================================================================
/**
 * Code to get the list of stations.
 * Gets only the stations that the user has access to. This includes both 
 * private stations and public station. 
 * If "Run As" is selected, returns only the list of run as
 * enabled stations.
 * List of allowed parameters to the Query service
 *      @QueryParam("ActiveOnly") @DefaultValue("False") Boolean onlyActive,
 *      @QueryParam("OS") String OS, //Any, Windows or UNIX
 *      @QueryParam("OSName") String OSName, //Any, Linux or Windows_7
 *      @QueryParam("OSVersion") String OSVersion, //6.1
 *      @QueryParam("AllowedUser") String allowedUser,
 *      @QueryParam("ApplicationName") String applicationName,
 *      @QueryParam("ApplicationVersion") String applicationVersion,
 *      @QueryParam("DRMMode") String drmMode,
 *      @QueryParam("SubmittingHost") @DefaultValue("False") Boolean localhost
 * 
 * No need to worry about SSL issues from EED, since we has already done that
 * for pubkey. 
 */
//=================================================================================
function getMyStations(params){
    
    var def = jQuery.Deferred();

    var noStations = function(){
        var msg = adviseLaunchInfo.translator.translate('LAUNCH_NO_STATIONS') + '<br/>' +
                    adviseLaunchInfo.translator.translate('LAUNCH_CHECK_ALLOWED_USER') + '<br/>' +
                    adviseLaunchInfo.translator.translate('LAUNCH_OR') + ' ' +
                    adviseLaunchInfo.translator.translate('LAUNCH_START_STATION');
                    
        adviseGoBack(msg);
    };
    
    if (params['eedUrl'] && params['eedUrl'].length === 0){
        def.reject();
        noStations();
    }
    
    var payload = { 'ActiveOnly':true },
        eedUrl = params['eedUrl'] + '/admin/station/query',
        runAsOnly = false;
        
    if (typeof params['currentUser'] && params['currentUser'].length > 0)
        payload['AllowedUser'] = params['currentUser'];
    
    if (typeof params['runAs'] && params['runAs'] === true)
        runAsOnly = true;
        
    jQuery.ajax({
        url: eedUrl,
        data: payload,
        type: 'GET',
        beforeSend: function(request){
            request.setRequestHeader('Accept', 'application/json');
        },
        success: function(response){
        	
        	var stationList = [];
            try {
            	stationList = response['StationList']['Station'];
            } catch (e) {
            	stationList = [];
			}
			
            if(!jQuery.isArray(stationList)) {
                stationList = [stationList];
            }
            
            if (stationList.length === 0){
                def.reject('');
                noStations();
            }
            
            var i = stationList.length;
            while (i--){
                if(runAsOnly){
                    // Possible values 
                    // "enabled", "disabled", "unsecured",
                    // Null, empty, or "default"  - use COS Server setting
                    var runAsValue  = (stationList[i]['GeneralInfo']['@disableRunAs'] || '').toUpperCase(),
                        isRunAsStation = false;
                    if (runAsValue.length === 0)
                        isRunAsStation = true;
                    else if (runAsValue === 'DEFAULT' || 
                        runAsValue === 'ENABLED')
                        isRunAsStation = true;
                    else if(runAsValue === 'DISABLED' ||
                        runAsValue === 'UNSECURED')
                        isRunAsStation = false;
                    // remove stations where run as is disabled
                    if(! isRunAsStation)
                        stationList.splice(i, 1);
                }               
            }
            
            def.resolve(stationList.length > 0 ? stationList : []);
        },
        error: function(err){
            noStations();
            def.reject();
        }
    });
    
    return def.promise();
}

//=======================================================================
/**
 * Checks the Run As status of EED, and returns a promise with a true or
 * false value. Use this in addition to the getMyStations reponse to get
 * only the Run As stations. 
 */
//=======================================================================
function getEEDRunAsStatus(eedUrl, eedTicket , translator){
    var deferred = $simjq.Deferred();
    
    $simjq.ajax({
        url: eedUrl + '/admin/runAsEnabled',
        type: 'GET',
        beforeSend : function(request) {
            request.setRequestHeader("EEDTicket", eedTicket);
        }
    }).done(function(data){
        deferred.resolve((data === 'true' || data === true || data === '1' || data === 1) ? true : false);
        return;
    }).fail(function(err){
        
        // Unable to communicate with EED
        // Failure of this function would kick
        // us back to RA Landing
        handleEEDCommFailure(
                eedUrl,
                function(){
                    $simjq.when(getEEDRunAsStatus(eedUrl, eedTicket, translator)).then(
                        function(){
                    deferred.resolve(true);
                        }
                    );
                },
				translator); 
    });
    return deferred.promise();
}

//=======================================================================
/**
 * Cancel the current analytics case job. 
 */
//=======================================================================
function cancelJob(adviseLaunchInfo, errorMsg) {

	if (JOB_CANCELLED) return;
    JOB_CANCELLED = true;
    var jobIdTxt = adviseLaunchInfo.jobID;
    var eedURL = adviseLaunchInfo.eedURL;
    var eedTicket = adviseLaunchInfo.eedTicket;
    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_STOPPING'),
        setStationNameToSplash(adviseLaunchInfo));
    var eedURLCancelJob = eedURL + "/execution/" + jobIdTxt + "/cancel";
    
    if (! errorMsg) errorMsg = '';
    // Clear the local storage entries to prevent assumption
    // of a existing servant during relaunch
    resetRunningServant(adviseLaunchInfo.caseID);
    
    jQuery.support.cors = true;
    
    jQuery.ajax({ url : eedURLCancelJob,
    type : "PUT",
    contentType : "text/plain",
    beforeSend : function(request) {
        request.setRequestHeader("EEDTicket", eedTicket);
        request.setRequestHeader("Credentials", "");
    },
    success : function(returndata, status, xhr) {
        adviseGoBack( adviseLaunchInfo.translator.translate('LAUNCH_TERMINATED') + '<br/>' + errorMsg);
    },
    error : function(jqXHR, textStatus, err) {
        showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_TERMINATED'), setStationNameToSplash(adviseLaunchInfo));
        adviseGoBack(adviseLaunchInfo.translator.translate('LAUNCH_TERMINATED') + '<br/>' + err);
    } });
}

//=======================================================================
/**
 * Not in use.. 
 */
//=======================================================================
function startJobLogHeartbeat(jobIdTxt) {
    return;
    /*
     * var jobLogLoop = setInterval(function(){ refreshJobLog(jobIdTxt,
     * jobLogLoop); }, 2000);
     */
}

//=======================================================================
/**
 * Not in use.
 */
//=======================================================================
function refreshJobLog(jobIdTxt, eedURL, eedTicket, timer) {

    var eedURLMonitor = eedURL + "/job/" + jobIdTxt + "/monitor";

    jQuery.support.cors = true;

    jQuery.ajax({ url : eedURLMonitor,
    data : { 'Topic' : "ResultsServantURL",
    'TimeStamp' : 0 },
    type : "GET",
    beforeSend : function(request) {
        request.setRequestHeader("EEDTicket", eedTicket);
        request.setRequestHeader("Credentials", "");

    },
    /* dataType : "application/xml", */
    success : function(returndata, status, xhr) {
        console.log(returndata);
        $simjq(".sim-ui-advise-job-log").text($simjq(returndata).text());
    },
    error : function(jqXHR, textStatus, errorThrown) {
        var text = $simjq(".sim-ui-advise-job-log").text();
        text = text + "\n\r" + errorThrown;
        $simjq(".sim-ui-advise-job-log").text(text);
    } });
}

//=======================================================================
/**
 * RA Save Case functionality
 * Add the 'Save Analytics Case' link to the Top Bar in the web app and 
 * defines its click event.
 */
//=======================================================================
function saveRICase() {

	showTranslatedMessage('LAUNCH_SAVE_LABEL', '',
		function(message){
		
			var saveOption = window.parent.$('.global.share ul')
	        						.append('<li id="sim-ui-toolbar-save" data-icon="save">' +
	        								'<a href="javascript:void(0)"><label>'+
	        								message +'</label></li>')
	        								.children('#sim-ui-toolbar-save').last();
			if (saveOption) {
				
				saveOption.bind('click', function(e) {
					if (!e) {
						e = window.event;
					}
					if ((typeof e.eventID === 'undefined' || e.eventID === 'undefined' || e.eventID === '')) {
						e.eventID = $simjq(this).attr('data-icon');
					}
					var rawidget = window.frames['widgetframe'];
					var raProxy = rawidget.proxy || rawidget.contentWindow.proxy;
					if(typeof raProxy !== 'undefined') {
						raProxy.propagateEvent(e);
					}
				});
			}
			
			$simjq(document).on('unload', function() {
				window.parent.$('#sim-ui-toolbar-save').remove();
			});
			
	});
}

//===============================================================
/**
 * Code to position a popup window in the center of the
 * screen. This code also accounts for dual screens.
 */
//===============================================================
function centerPopupWnd(w, h){
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left,
        dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top,
        width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? 
                document.documentElement.clientWidth : screen.width,
        height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ?
                document.documentElement.clientHeight : screen.height,
        left = ((width / 2) - (w / 2)) + dualScreenLeft,
        top = ((height / 2) - (h / 2)) + dualScreenTop;

    return { 'top': top, 'left': left };
};

//===============================================================
/**
 * Return to the RA Landing Page
 * Assumes that the MCS url is saved to the local storage 
 */
//===============================================================
function returnToRALanding(){
    var mcsUrl = localStorage['RA_MCS_URL'],
        wNd = getTopWindow() || window;
    if (mcsUrl){
        wNd.location.href = mcsUrl + '/common/emxNavigator.jsp?appName=SIMREII_AP' +
                            '&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource' +
                            '&SuiteDirectory=simulationcentral';
    } else {
        wNd.location.href = '../common/emxNavigator.jsp?appName=SIMREII_AP' +
                            '&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource' +
                            '&SuiteDirectory=simulationcentral';
    }
}

//===============================================================
/**
 * Open a popup window and position it to the center of the
 * screen. Requires a url, width and height for the window
 */
//===============================================================
function openPopUp (url, w, h){
    var posn = centerPopupWnd(w, h);
    var wNd = getTopWindow() || window,
        options = 'WIDTH=' + w +
                    ',HEIGHT=' + h + 
                    ',top=' + posn.top +
                    ',left=' + posn.left +
                    ',scrollbars=yes' +
                    ',menubar=no' +
                    ',resizable=yes' +
                    ',directories=no',
        popUp = wNd.open(url, '', options);
    
    if(typeof popUp === 'undefined' ||
        popUp === null){
        alert(adviseLaunchInfo.translator.translate('LAUNCH_DISABLE_POPUP_BLOCKER'));
    }
    if(popUp){
        popUp.onload = function(){
            if(! popUp.innerHeight > 0){
                // Popup blocked
                alert(adviseLaunchInfo.translator.translate('LAUNCH_DISABLE_POPUP_BLOCKER'));
            }
        }
    }
    return popUp;
};

//===============================================================
/**
 * Checks if the url is reachable, repeats itself for 2 mins.
 * Returns a promise 
 */
//===============================================================
function urlCheckAlive(data){
    
    var url = data['url'],
        params = data['params'],
        timeOut = data['timeout'] || null,
        caseId = data['caseid'],
        rType = data['type'] || 'GET',
        crossDomain = data['crossDomain'] || null;
    
    var checkDeferred = $simjq.Deferred(),
        start = new Date().getTime(),
        urlAlive = false;
    
    (function pollUrl(){
        
        console.log('Polling ' + url);
        
        var payload = {
            type: rType,
            url: url,
            data: params
        };
        if(timeOut)
            payload['timeout'] = timeOut;
        if(crossDomain)
            payload['crossDomain'] = crossDomain;
        $simjq.ajax(payload).done(
            function(response){
                console.log('Ping to ' + url + ' was successful');
                urlAlive = true;
                checkDeferred.resolve(response);
                return;
            }
        ).fail(
            function(err){
                
                console.log('Poll failed');

                if(new Date().getTime() - start > timeOut){
                    console.log('Unable to reach ' + url);
                    urlAlive = false;
                    checkDeferred.reject(urlAlive);
                    return;
                } else {
                    setTimeout(pollUrl, 1000);
                }
            }
        );  
    }()); 
    
    return checkDeferred.promise();
};

//===============================================================
/**
 * Checks if the url is valid
 */
//===============================================================
function isValidURL(url){
    
    if(typeof url === 'undefined' ||
            url === null)
        return false;
    
    if(url.indexOf('http:') !== 0 &&
        url.indexOf('https:') !== 0)
        return false;
    
    return true;
};

//===============================================================
/**
 * Checks if the url is a https one. If the call to the https
 * url fails, prompt for root certifcate installation.
 */
//===============================================================
function isCertCheckNeeded(url){
    if(typeof url === 'undefined' ||
            url === null)
        return false;
    
    var urlObj = getURLObject(url);
    if (urlObj['protocol'] === 'https:')
        return true;
    
    return false;
};

//===============================================================
/**
 * If the host is https and url is http then check for mixed 
 * content can be prompted
 */
//===============================================================
function isMixedContent(url){
    if(typeof url === 'undefined' ||
            url === null)
        return false;
    
    var urlObj = getURLObject(url); 
    if (urlObj['protocol'] === 'http:' &&
            window.location.protocol === 'https:')
        return true;
    
    return false;
};

//========================================================================
/**
 * This function handles relaunch of a case when necessary. Checks
 * localstorage for 'smaAnalytics_MC_Interruption' to confirm relaunch.
 * Once relaunched remove the localstorage entry to prevent re-relaunches.
 */
//========================================================================
function relaunchAnalyticsCase(){
    
    console.warn('Running relaunch code');
    var locStore = localStorage['smaAnalytics_MC_Interruption'];
    if (typeof locStore !== 'undefined' && 
            locStore !== null &&
            locStore.length > 0){
        //readyFunction({}, true);
        return locStore;
    } else {
        return '';
    }
}

//========================================================================
/**
 * Create a popover that displays status and error messages with 
 * with appropriate actions. Takes a message, a trace, labels and callbacks
 * for the ok and cancel button. Also takes a boolean for the option
 * 'confirm-mode' which decides to show both 'Ok' and 'Cancel' button
 * or just the 'Cancel' button.
 */
//========================================================================
function createLaunchPopOver (options){
    
    if (typeof options === 'undefined' ||
            options === null){
        return;
    }
    
    var message = options['message'],
        trace = options['trace'],
        isConfirm = options['confirm-mode'] || false,
        okLabel = options['ok-label'] || 'Ok',
        okCallBack = options['ok-callback'],
        closeLabel = options['close-label'] || 'Close',
        closeCallBack = options['close-callback'],
        header = options['header'] || 'Results Analytics';
    
    var raSplash = document.querySelector('.sim-ui-advise-splash-background') || null;
    
    document.querySelector('.sim-ui-errpop-header').textContent = header;
    
    if(isConfirm)
        document.querySelector('#sim-ui-errpop-ok').classList.remove('sim-ui-errpop-noshow');
    else
        document.querySelector('#sim-ui-errpop-ok').classList.add('sim-ui-errpop-noshow');
    if (okLabel.length > 0)
        $simjq('#sim-ui-errpop-ok').text(okLabel);
    if (okLabel.length > 0)
        $simjq('#sim-ui-errpop-close').text(closeLabel);
    if (typeof message !== 'undefined' &&
            message !== null &&
            message.length > 0){
        $simjq('#sim-ui-errpop-msgcard').html(message);
    }
    else {
        if(typeof closeCallBack === 'function')
            closeCallBack();
        return;
    }
    if (typeof trace !== 'undefined' &&
            trace !== null &&
            trace.length > 0){
        $simjq('#sim-ui-errpop-tracecard').text(trace);
    }
    
    $simjq('#sim-ui-errpop-close,#sim-ui-errpop-ok').bind('click',
        function(){
            var id = $simjq(this).attr('id');
            if(id === 'sim-ui-errpop-ok'){
                if(typeof okCallBack === 'function')
                    okCallBack();
            }
            if(id === 'sim-ui-errpop-close'){
                if(typeof closeCallBack === 'function')
                    closeCallBack();
            }
            document.querySelector('.sim-ui-errpop-veil').classList.add('sim-ui-errpop-noshow');
            if(raSplash)
                raSplash.classList.remove('sim-ui-errpop-noshow');
            return;
    });

    if(raSplash)
        raSplash.classList.add('sim-ui-errpop-noshow');
    document.querySelector('.sim-ui-errpop-veil').classList.remove('sim-ui-errpop-noshow');
}

//========================================================================
/**
 * Unable to connect to EED. This might be due to the untrusted SSL
 * certificate. 
 */
//========================================================================
function handleEEDCommFailure(eedURL, successCallBack, translator){
	if (typeof adviseLaunchInfo !== 'undefined'){
		translator = adviseLaunchInfo.translator;
	}
    
    var message = translator.translate('LAUNCH_EED_COMM_FAILURE') + '<br/>',
        acceptCert = false;

    if (eedURL.indexOf('https') === 0){
        message += translator.translate('LAUNCH_EED_ACCEPT_CERT') + '<br/>' +
                    translator.translate('LAUNCH_OR') + ' ' +  translator.translate('LAUNCH_CANCEL');
        acceptCert = true;
    } else{
        message += translator.translate('LAUNCH_CANCEL');
    }

    createLaunchPopOver({
        'message': message,
        'confirm-mode': acceptCert,
        'ok-callback': function(){
            // open a new window to accept the SSL cert
            var eedPingWnd = openPopUp( eedURL+'/Ping', 500, 500);
            
            $simjq
                .when(
                    urlCheckAlive({
                        'url': eedURL+'/Ping',
                        'timeout': 120000
                    })
                )
                .then(
                    function(alive){
                        if(typeof eedPingWnd !== 'undefined' &&
                                eedPingWnd !== null)
                            eedPingWnd.close();
                            
                            successCallBack();
                    },
                    function(){
                        if(typeof eedPingWnd !== 'undefined' &&
                                eedPingWnd !== null)
                            eedPingWnd.close();
                        
                        createLaunchPopOver({
                            'message': translator.translate('LAUNCH_EED_COMM_FAILURE') + '<br/>' 
                                        + translator.translate('LAUNCH_EED_COMM_FAILURE'),
                            'close-callback': returnToRALanding
                        });
                    }
                );
        },
        'close-callback': returnToRALanding
    });
}

//========================================================================
/**
 * Check if we have a https servant or a servant behind a proxy whose
 * SSL certificate isn't verified
 */
//========================================================================
function handleServantPingFailure(servantUrl, adviseLaunchInfo){
    
    var failureHandlerDeferred = $simjq.Deferred();
    
    if(servantUrl.indexOf('https:') === 0){
        
        handleHTTPSServant(servantUrl + 'ping', adviseLaunchInfo,
            function(response){
                failureHandlerDeferred.resolve(response);
                return;
            }
        );
    }
    
    if (isMixedContent(servantUrl)){
        
        handleMixedContentServant(servantUrl,
                adviseLaunchInfo['caseID'], adviseLaunchInfo);
        
        failureHandlerDeferred.reject();
        
    } else {
    
    	// failure to get into the above if statements denotes that
        // we are using http session and the servant has failed
        var message = adviseLaunchInfo.translator.translate('LAUNCH_UNREACHABLE_SERVANT') + '<br/>' 
    					+ adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_URL') + 
    					adviseLaunchInfo.servantURL + '<br/>';
        
        createLaunchPopOver({
            'message': message,
            'ok-callback': function(){
            	 resetRunningServant(adviseLaunchInfo.caseID);
            	 returnToRALanding();
            }
        });

    }
        
    return failureHandlerDeferred.promise();
}

//========================================================================
/**
 * Pings the servant and returns a promise
 * Failure doesnt resolve the promise. It kicks the user back to the
 * launch.
 */
//========================================================================
function pingServant(servantUrl, adviseLaunchInfo){
    
    var pingDeferred = $simjq.Deferred();
    
    $simjq.ajax({
        url: servantUrl + 'ping',
        crossDomain: true,
        data: {
                'caseID': adviseLaunchInfo.caseID,
                '_t': Date.now()
            },
		success : function(token){
			pingDeferred.resolve(token);
		},
		error : function(){
			/* handleServantPingFailure(servantUrl, adviseLaunchInfo)
				.then(function(response){
					pingDeferred.resolve(response);
				}); */
			pingDeferred.reject();
        }
    });
    
    return pingDeferred.promise();
}

//========================================================================
/**
 * Checks if the servant can be pinged. In case of ping failure checks
 * for ssl certificate and mixed content issues.
 * Also works for multiple servant urls, when in multiple NIC scenarios.
 */
//========================================================================
function checkServantURLValidity(adviseLaunchInfo){
    
    var servantUrl = adviseLaunchInfo['servantURL'],
        mcsUrl = adviseLaunchInfo['mcsUrl'],
        proxyUrl = adviseLaunchInfo['proxyServer'],
        caseID = adviseLaunchInfo['caseID'],
        probableMixedContent = false,
        browsr = {},
        servantDeferred = $simjq.Deferred();
    
    if (! isValidURL(servantUrl)){      
        showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_BAD_SERVANT_URL'));
        
        
        // Invalid servant url. So servant stop
        // isn't gonna work
        cancelJob(adviseLaunchInfo, 
                adviseLaunchInfo.translator.translate('LAUNCH_BAD_SERVANT_URL') + ' = "' + servantUrl + '"'  );
        return;
    }
    
    // Check if there is a possibility of mixed content
    probableMixedContent = isMixedContent(servantUrl);
    
    // Check the browser being used.
    // We might need to handle mixed content
    // based on the browser being used
    if(probableMixedContent){
        browsr = whichBrowser();
    } else {
        browsr = {
                'name' : '',
                'version' : '' 
            };
    }
    
    switch (browsr.name.toLowerCase()){
    
    case 'chrome':
        
        // Chrome doesnt provide errors when mixed content
        // is encountered. So run a timer and on timeout
        // call the failure handler.
        pingServant(servantUrl, adviseLaunchInfo)
        .then(
            function(token){
                window.clearTimeout(chrTOut);
                servantDeferred.resolve(token);
            },
            function(){
                window.clearTimeout(chrTOut);
                servantDeferred.reject();
            }
        );

        var chrTOut = window.setTimeout(function(){
            
            //alert('Chrome ping failure handler');
            console.warn('Chrome ignored the ping request probably due to mixed content');
            console.warn('Calling ping failure handler');
            
            handleServantPingFailure(servantUrl, adviseLaunchInfo);
            /*window.clearTimeout(chrTOut);*/
            
        }, 7000);

        break;
    
    default:
        
        pingServant(servantUrl, adviseLaunchInfo)
        .then(
            function(token){
                servantDeferred.resolve(token);
            },
            function(){
                servantDeferred.resolve('');
            }
        );
        
        break;
    }
    return servantDeferred.promise();
}

// This flag checks to see if the
// failure check is done and to stop
// executing cancel again
var mcCheckDone = false;
//===============================================================
/**
 * Warn the user for mixed content. Once the mixed content is 
 * allowed restart the launch automatically.
 * The cue for restart is to check localstorage for 
 * 'smaAnalytics_MC_Interruption'. 
 * If user enables mixed content, then the page auto refreshes,
 * looks and executes the onBeforeUnload event, which then
 * kicks off the relaunch. 
 */
//===============================================================
function handleMixedContentServant (url, caseId, adviseLaunchInfo)
{
	if (mcCheckDone) return;
	var message = adviseLaunchInfo.translator.translate('LAUNCH_UNREACHABLE_SERVANT') + '<br/>'
					+ adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_URL') + url + '<br/>'
                    + adviseLaunchInfo.translator.translate('LAUNCH_UNBLOCK_MC') + '<br/>' 
                    + adviseLaunchInfo.translator.translate('LAUNCH_OR') + ' ' 
                    + adviseLaunchInfo.translator.translate('LAUNCH_CANCEL');
   
    if(typeof caseId !== 'undefined' && caseId !== null && caseId.length > 0){
        localStorage['smaAnalytics_MC_Interruption'] = caseId;
        localStorage['smaAnalyticsCase' + caseId] = 
                            JSON.stringify({
                                'lastUpdateTime' : Date.now(),
                                'servantURL' : url,
                                'stationName' : adviseLaunchInfo.stationName,
                                'stationIP' : adviseLaunchInfo.stationIP });
    }
    
	mcCheckDone = true;
    createLaunchPopOver({
        'message': message,
        'close-callback': function(){
            localStorage.removeItem('smaAnalytics_MC_Interruption');
            cancelJob(adviseLaunchInfo, '');
        }
    });
};

//========================================================================
/**
 * Handles scenarios were the RA servant is in HTTPS mode and the 
 * certificate of the servant is not recognised by the browser.
 * Can be used in cases of
 * 1. Servant behind a https proxy, whose SSL certificate isn't verified
 * 2. HTTPS SERVANT
 */
//========================================================================
function handleHTTPSServant(servantURL, adviseLaunchInfo, successCallBack){
    
    var message = adviseLaunchInfo.translator.translate('LAUNCH_UNREACHABLE_SERVANT') + '<br/>' 
					+ adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_URL') +  adviseLaunchInfo.servantURL + '<br/>',
        acceptCert = false,
        that = this;

    if (servantURL.indexOf('https') === 0){
        message += adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_ACCEPT_CERT') + '<br/>' +
                    adviseLaunchInfo.translator.translate('LAUNCH_OR') + ' ' + adviseLaunchInfo.translator.translate('LAUNCH_CANCEL');
        acceptCert = true;
    } else{
        message += adviseLaunchInfo.translator.translate('LAUNCH_CANCEL');
    }
    
    createLaunchPopOver({
        'message': message,
        'confirm-mode': acceptCert,
        'ok-callback': function(){
            
            // open a new window to accept the SSL cert
            var servantPingWnd = openPopUp( servantURL, 500, 500);
            
            $simjq
                .when(
                    urlCheckAlive({
                        'url': servantURL, // the url is the complete ping url
                        'crossDomain': true,
                        'timeout': 60000,
                        'data': {
                                    'caseID': adviseLaunchInfo.caseID,
                                    '_t': Date.now()
                                }
                    })
                )
                .then(
                    function(token){
                        if(typeof servantPingWnd !== 'undefined' &&
                                servantPingWnd !== null)
                            servantPingWnd.close();
                            
                            successCallBack(token);
                    },
                    function(){
                        if(typeof servantPingWnd !== 'undefined' &&
                                servantPingWnd !== null)
                            servantPingWnd.close();
                        
                        createLaunchPopOver({
                                'message' : adviseLaunchInfo.translator.translate('LAUNCH_UNREACHABLE_SERVANT')  + '<br/>'
                                            + adviseLaunchInfo.translator.translate('LAUNCH_CANCEL'),
                                'close-callback': returnToRALanding
                        });
                    }
                );
        },
        'close-callback': cancelJob.bind(that, adviseLaunchInfo, '')
    });
}

//========================================================================
/**
 * Retrieve the servant url from the Advise Message. The message may be a
 * single http(s) url or a ";" separated list of urls due to the 
 * exitence of multiple NICs.
 * Its also possible to get one or more entries of the format
 * <servanthost>/<servantportmap>/Advise. In this case add every entry in
 * this msg to the proxy url. 
 * If multiple urls are used the first one to return a success for a ping 
 * is used.  
 */
//========================================================================
function deriveServantURL(adviseLaunchInfo, adviseMessage){
   
    if (typeof adviseMessage === 'undefined' ||
            adviseMessage === null ||
            adviseMessage.length === 0){
        
        showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_BAD_SERVANT_URL'));
        cancelJob(adviseLaunchInfo,
            adviseLaunchInfo.translator.translate('LAUNCH_NO_SERVANT_URL'));
        return;
    } else {
        if (adviseMessage.substr(adviseMessage.length - 1) !== '/')
            adviseMessage += '/';
    }
    
    // BB message is a servant url
    if ((adviseMessage.indexOf('http:') === 0) || (adviseMessage.indexOf('https:') === 0)){
        
        adviseLaunchInfo['servantURL'] = adviseMessage;
        return;
    } 
                
    // BB message isnt a url -deprecated
    if ((adviseMessage.indexOf('http:') < 0) && (adviseMessage.indexOf('https:') < 0)){
        
        // Check for existence or proxy
        if (typeof adviseLaunchInfo.proxyServer !== 'undefined'&&
            adviseLaunchInfo.proxyServer !== null){
            
            // Valid proxy url 
            if (adviseLaunchInfo.proxyServer.indexOf('http') === 0){
                
            	if (adviseLaunchInfo.proxyServer.slice(-1) !== '/' )
            		adviseLaunchInfo.proxyServer += '/';
                adviseLaunchInfo['servantURL'] = adviseLaunchInfo['proxyServer'] +
                                                    adviseMessage;
            }
            return;
        }
        else {
            
            // No proxy and BB msg isnt a url - failure
            showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_BAD_SERVANT_URL'));
            cancelJob(adviseLaunchInfo,
                adviseLaunchInfo.translator.translate('LAUNCH_BAD_SERVANT_URL') + ' = ' + adviseMessage + '".' );
            return;
        }
    }
}

//========================================================================
/**
 * pingPrivateStation
 * Sample Response:
 * 		<StationData name="nofsim-NOF" ip="172.25.54.42"
 * 			cosid="SampleCOSServer" user="test"/>
 */
//========================================================================
function pingPrivateStation(port, successCallback, failCallback) {
    
    var launcherURL = ["https://dslauncher.3ds.com:","/SMAExeStation-REST/station/info"];
    
    $simjq.ajax({
        url : launcherURL[0]+port+launcherURL[1],
        type : "get",
        success : function(data, status, xhr) {
            console.log("Success at port "+port+ ": data = "+data)
            successCallback(data);
        },
        error : function(jqXHR, textStatus, errorThrown) {
            console.log("Failed to locate a private station at port "+port)
            failCallback(textStatus);
        }
   });
}

//========================================================================
/**
 * isLocalStation
 * Send in the ip of a station to determine if that station is a local
 * station. A direct '===' doesnt suffice because, the
 * '/admin/station/query' service returns ipV4 and ipV6 ids in ',' 
 * separated list.
 * Returns a boolean
 */
//========================================================================
function isLocalStation(stationIp, adviseLaunchInfo){
	try {
		var ipArr = stationIp.split(',');
		
		if (ipArr.indexOf(adviseLaunchInfo.localIP) > -1)
			return true;
		else
			return false;
		
	} catch(ex){
		return false;
	}
}

//========================================================================
/**
 * getCOSConfigurations
 * Returns the Compute Orchestration Server configurations and
 * version info
 */
//========================================================================
function getCOSConfigurations(adviseLaunchInfo){
	
	var deferred = $simjq.Deferred();
	
	jQuery.ajax({
		url: adviseLaunchInfo['eedURL'] + '/admin',
        type: 'GET',
        beforeSend: function(request){
            request.setRequestHeader('Accept', 'application/json');
        },
        success: function(response){

        	try {
        		adviseLaunchInfo['cosMetaData']['major'] = parseFloat(response.SystemInfo['@major']);
        		adviseLaunchInfo['cosMetaData']['minor'] = parseFloat(response.SystemInfo['@minor']);
        		adviseLaunchInfo['cosMetaData']['fixPack'] = parseFloat(response.SystemInfo['@fix']);
        		
        		jQuery.ajax({
                    url: '../resources/eepservices/cos/configurations',
                    type: 'GET',
                    beforeSend: function(request){
                        request.setRequestHeader('Accept', 'application/json');
                    },
                    success: function(data){
						var responseList = data.COSConfiguration || data.configurations;
                		for (var i in responseList){
                			var cosConfig = responseList[i];
		        			if (cosConfig['isDefault']){
		        				adviseLaunchInfo['eedID'] = cosConfig['id'];
		        	        	adviseLaunchInfo['eedURL'] = cosConfig['fullCosUrl'];
		        	        	adviseLaunchInfo['proxyServer'] = cosConfig['proxyServerUrl'];
		        	        	break;
		        			}
		            	}
		        		deferred.resolve();
                    },
                    error: function(req, err){
                    	console.warn(err);
                    	deferred.resolve();
                    }
            	});
        	} catch(err){
        		console.warn(err);
        		deferred.resolve();
        	}
        },
        error: function(req, err){
        	console.warn(err);
        	deferred.resolve();
        }
	});
	
	return deferred.promise();
}

//========================================================================
/**
 * RESULTS ANALYTICS LAUNCH SEQUENCE -START
 */
//========================================================================

//========================================================================
/**
 * 1. getRunningServant:
 * Check localStorage for any alive servants. Ping the found servant.
 * If it is alive leave it to the user to use it or kill 
 * it and start a new on.
 * Else start initiate the process to start a servant 
 */
//========================================================================
function getRunningServant(caseID, adviseLaunchInfo) {
    
    var def = jQuery.Deferred(),
        clearStg = function(){
            delete localStorage['smaAnalyticsCase' + caseID];
            def.resolve(null);
        };

    if (typeof (Storage) !== 'undefined') {
        
        var currTime = Date.now();
        var previousSessionString = localStorage['smaAnalyticsCase' + caseID];
        
        if (previousSessionString && previousSessionString.length > 5) {
            
            var previousSession = JSON.parse(previousSessionString);
            var prevTime = previousSession.lastUpdateTime;
            var servantURL = previousSession.servantURL;
            adviseLaunchInfo['servantURL'] = servantURL;
            adviseLaunchInfo['caseID'] = caseID;
            
            $simjq.when(checkServantURLValidity(adviseLaunchInfo))
                .then(function(token){
                    
					if (typeof token !== 'undefined' && token !== null && token.length > 0){
                    createLaunchPopOver({
                        'message': adviseLaunchInfo.translator.translate('LAUNCH_EXISTING_SERVANT') ,
                        'header': adviseLaunchInfo.translator.translate('LAUNCH_RA_HEADER_EXS_SERVANT'),
                        'confirm-mode': true,
                        'close-label': adviseLaunchInfo.translator.translate('Cancel') ,
                        'ok-callback': function(){
                            def.resolve({
                                'servantURL': servantURL,
                                'stationName': previousSession.stationName,
                                'stationIP' : previousSession.stationIP,
                                'token' : token });
                        }.bind(this),
                        
                        'close-callback': function(){
                            
                            var promise = jQuery.ajax({ url:servantURL + 'stop',
                                crossDomain: true,
                                data: { 't': Date.now() }
                            })
                            .done(clearStg)
                            .fail(function(){
                                console.error('Attempt to stop the running servant failed.');
                                clearStg();
                            });
                        }.bind(this)
                    });
					} else {
						clearStg();
					}
                }.bind(this));
        } else {
            clearStg();
        }
    } else {
        def.resolve(null);
    }
    return def;
}

//========================================================================
/**
 * 2. startServant:
 * No existing servants were found, start a new servant.
 * Get the EED public key. If the request fails the problem might be 
 * due to the EED certificate issue. 
 */
//========================================================================
function startServant(adviseLaunchInfo) {
    
    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_GET_PUBKEY'));
    
    var eedTicket = adviseLaunchInfo.eedTicket,
        eedURL = adviseLaunchInfo.eedURL,
        pubKey = "",
        pubKeyUrl = eedURL + '/execution/pubkey',
        that = this;
            
   // FIXME : verify the noServant code
    adviseLaunchInfo.noServant = localStorage.getItem('noServant') === null? false : true;   
    if(adviseLaunchInfo.noServant){
        startApp(adviseLaunchInfo);
        return;
    }
    
    $simjq.when(getCOSConfigurations(adviseLaunchInfo)).then(
    	function(){
    		
    		jQuery.support.cors = true;
    	    jQuery.ajax({
    	        url : pubKeyUrl,
    	        type : "GET",
    	        beforeSend : function(request) {
    	            request.setRequestHeader("EEDTicket", eedTicket);
    	            request.setRequestHeader("Credentials", "");
    	        },
    	        contentType : "text/plain",
    	        success : function(returndata, status, xhr) {
    	            console.log(returndata);
    	            
    	            pubKey = $simjq(returndata).find("KeyRep").text().trim();
    	            
    	            // Store decoded key to use as sp-encryption component
    	            adviseLaunchInfo.eedPublicKeyDecoded = pubKey;
    	            
    	            pubKey = encodeURIComponent(pubKey);
    	            adviseLaunchInfo.eedPublicKey = pubKey;
    	            
    	            getEncryptedCredentials(adviseLaunchInfo);
    	        },
    	        error : function(jqXHR, textStatus, errorThrown) {
    	            handleEEDCommFailure(
    	                eedURL,
    	                startServant.bind(that, adviseLaunchInfo),
    					adviseLaunchInfo.translator);
    	        }
    	    });
        },
        function(error){
        	
        	createLaunchPopOver({
                'message': translator.translate('LAUNCH_EED_COMM_FAILURE') + '<br/>' 
                            + error,
                'close-callback': returnToRALanding
            });
        	
        });
}

//========================================================================
/**
 * 3. getEncryptedCredentials 
 * Get the login ticket from the server. Send it to the sp-encryption
 * component to get the credentials
 * Else send to smaAdviseEncryptedCredentials jsp to get the credentials.
 */
//========================================================================
function getEncryptedCredentials(adviseLaunchInfo) {
    
    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_GET_CREDENTIALS'));
    
    var pubKey = adviseLaunchInfo.eedPublicKey,
        ticketURL = adviseLaunchInfo.ticketURL;
        
    jQuery.ajax({ url : ticketURL,
            type : "GET",
            cache : false,
            success : function(returndata, status, xhr) {
                var urlL = "../simulationcentral/smaAdviseEncryptedCredentials.jsp?pubKey=" + pubKey;
                var myData;
                try {
                    try {
                        myData = String(returndata.documentElement.childNodes[1].textContent);
                    } catch (error) {
                        var myData1 = String(returndata);
                        var sMyData1 = myData1.split('\n');
                        var ticketStr = sMyData1[0].split("ticket=");
                        myData = ticketStr[1];
                        adviseLaunchInfo.loginTicket = myData;
                    }
                } catch (error) {
                    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_GET_CRED_ERROR'));
                    adviseGoBack(
                        adviseLaunchInfo.translator.translate('LAUNCH_GET_LT_ERROR') + '<br\>' + error 
                    );
                }
                
                if(adviseLaunchInfo.runAs) {
                    
                    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_ENC_CREDENTIALS'));
                    
                    pubKey = adviseLaunchInfo.eedPublicKeyDecoded;
                    pubKey = pubKey.replace(/(\r\n|\n|\r)/gm,'');
                    
                    var encryptor = document.getElementById('encryptor');
                    if (encryptor.encryptCredentials) {
                         waitForPolymerAndEncrpytCredentials(adviseLaunchInfo);
                    } else {
                        /*window.addEventListener('polymer-ready', function(){*/
                    	window.addEventListener('WebComponentsReady', function(){
                            waitForPolymerAndEncrpytCredentials(adviseLaunchInfo);
                        });
                        console.log('Waiting for Polymer to be ready..')
                    }
                    
                } else {
                
                    jQuery.ajax({ url : urlL,
                        type : "POST",
                        data : { 'loginTicket' : adviseLaunchInfo.loginTicket },
                        dataType : "text",
                        success : function(returndata, status, xhr) {
                            returndata = emxUICore.trim(returndata);
                            adviseLaunchInfo.resourceCredentials = returndata;
                            
                            if (adviseLaunchInfo.userSelectedStation.length > 0 && 
                            		adviseLaunchInfo.userSelectedStation !== '{localhost}'){
                            	
                            	// If the user chose to set affinity to a regular station.
                            	checkLocalStationAndLaunch(adviseLaunchInfo);
                            	
                            }
                            else{
                            
                            	// If the user set affinity to {localhost} or no affinity was set
                                // try to submit to localhost
                            	checkPrivateStationAndLaunch(adviseLaunchInfo);
                            	
                            }
                        },
                        error : function(jqXHR, textStatus, errorThrown) {
                            showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_ENC_CREDENTIALS_ERROR'));
                            adviseGoBack(
                                adviseLaunchInfo.translator.translate('LAUNCH_ENC_CREDENTIALS_ERROR') + '<br\>' + errorThrown 
                            );
                        }
                    });
                }
            }
    });
}

//========================================================================
/**
 * Uses the sp-encryption component to encrypt credentials
 * @param {Object} adviseLaunchInfo
 */
//========================================================================
function waitForPolymerAndEncrpytCredentials(adviseLaunchInfo){
    
    var pubKey = adviseLaunchInfo.eedPublicKey;
    var ticketURL = adviseLaunchInfo.ticketURL;
    
    pubKey = adviseLaunchInfo.eedPublicKeyDecoded;
    pubKey = pubKey.replace(/(\r\n|\n|\r)/gm,'');
    
    var encryptor = document.getElementById('encryptor');
    
    // Encrypt credentials with a specific RSA key (key is optional)
    var cryptedCredentials = encryptor.encryptCredentials(
        {
            // OS
            domainName:window.sessionStorage.domainName || '',
            windowsUser: window.sessionStorage.windowsUser || '',
            windowsPass: window.sessionStorage.windowsPass || '',

            // X
            linuxUser: window.sessionStorage.linuxUser || '',
            linuxPass: window.sessionStorage.linuxPass || '',

            // IsightV5
            isightV5User: '',
            isightV5Password: '',

            // SSO
            loginTicket: adviseLaunchInfo.loginTicket
        },
        pubKey
    );
    adviseLaunchInfo.resourceCredentials = cryptedCredentials;
    
    // Run As is not supported by Secure Stations.
    //checkPrivateStationAndLaunch(adviseLaunchInfo);
    checkLocalStationAndLaunch(adviseLaunchInfo);
}

//========================================================================
/**
 * 4. checkPrivateStationAndLaunch
 * Check if the connected COS server is => R418 FixPack 3. Else fall back
 * finding local station or any other available station.
 * Check to see if there is a private station running in the local machine. 
 * --> !toolate = the job is yet to be submitted
 * --> Identify if the process flow has localhost defined.
 * --> Get Local Host Station Information, by making the 
 * 		'SMAExeStation-REST/station/info' call.
 * --> Sample Response :
 * 		<StationData name="nofsim-NOF" ip="172.25.54.42"
 * 			cosid="SampleCOSServer" user="test"/>
 * --> Check if the name of the user who submitted the job matches with 
 * 		the station user.
 * --> Check if the name of the COS server id (cosid) the station 
 * 		connected to matches with the COS server id the client is 
 * 		submitting the job to.
 * --> Modify the RunInfo to provide StationName as the 
 * 		submissionHost attribute.
 * --> Call runWorkFlow/runJob webservice.
 * --> Pass the COS jobid to the station, so that the station can claim.
 * 		Use the same (successful) port number to connect to the station.
 * 
 * There is a possibility that the local secure station cannot process 
 * your job, so once the checks fail in the function, ensure that we dont
 * go the same local station again in "checkLocalStationAndLaunch".
 */
//========================================================================
function checkPrivateStationAndLaunch(adviseLaunchInfo){
    
	// Verify if this setup can support a Secure Station.
	// Else fall back to finding other stations
	var secStationEligible = false;
	try {
		if ((adviseLaunchInfo['cosMetaData']['major'] > 6) ||
			(adviseLaunchInfo['cosMetaData']['major'] === 6 && (adviseLaunchInfo['cosMetaData']['minor'] > 418)) ||
			(adviseLaunchInfo['cosMetaData']['major'] === 6 && (adviseLaunchInfo['cosMetaData']['minor'] === 418) &&
				adviseLaunchInfo['cosMetaData']['fixPack'] >= 3))
			secStationEligible = true;
	} catch(ex){
		secStationEligible = false;
	}
	
	if (! secStationEligible){
		checkLocalStationAndLaunch(adviseLaunchInfo);
		return;
	}
	
    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_CHECK_PRIVATE_STATION'));
    
    var ports = [35125,45341,55447],
        successPort = -1,
        data = null,
        tooLate = false,
        deferreds = [new jQuery.Deferred(), new jQuery.Deferred(), new jQuery.Deferred()];
        
    ports.forEach(function(port, index, array){
        pingPrivateStation(port, function(_data) {
        	
        	adviseLaunchInfo['isSecureStation'] = true;
            
            var stationData = _data.getElementsByTagName('StationData');
            if(stationData) {
                stationData = stationData[0];

				// Check if this station is connected to the right 
				// MCS server
				var stationMCS = getURLObject(stationData.getAttribute('spaceurl')),
					myMCS = getURLObject(adviseLaunchInfo.mcsUrl);
				if (stationMCS.hostname === myMCS.hostname && 
						stationMCS.port === myMCS.port && 
						stationMCS.pathname.replace(/\//g, '') === myMCS.pathname.replace(/\//g, '')){
            	var stationCOS = stationData.getAttribute('cosid'),
            		stationUser = stationData.getAttribute('user');
            	//Check COS Server & User
            	if (stationCOS === adviseLaunchInfo['eedID'] &&
            			stationUser === adviseLaunchInfo['currentUser']){
            		var stationIP = stationData.getAttribute('ip'),
	                	stationName = stationData.getAttribute('name');
                
	                // Used to set the station name to the balloon 
	                // inside RA
	                adviseLaunchInfo.stationDisplayName = stationName;
	                
	                adviseLaunchInfo.runInfo = "<RunInfo logLevel=\"Debug\" submissionHost=\""+stationName+"\"></RunInfo>";
	                adviseLaunchInfo.stationName = stationName;
	                adviseLaunchInfo.proxyServer = "https://dslauncher.3ds.com:"+port+"/SMAExeStation-REST/servant";
	                adviseLaunchInfo.secureStation = true;
	                adviseLaunchInfo.stationAccess = "https://dslauncher.3ds.com:"+port+"/SMAExeStation-REST/station";
	
	                successPort = port;
	                
	                // Skip the local station etc and go directly to launch?
	                if(!tooLate) {
	                    tooLate = true;
	                    makeRunAdviseJob(adviseLaunchInfo);
						}
		            }
                }
            }
            deferreds[index].resolve();   
        },
        function(_data){
            deferreds[index].resolve();
        }); 
    });
    
    var continueExecution = function(){
    	tooLate = true;
    	if (adviseLaunchInfo.userSelectedStation !== '{localhost}'){
    		checkLocalStationAndLaunch(adviseLaunchInfo);	
    	}
    	else{
    		// If the user specifically set affinity to {localhost}, dont submit that job
    		// to a regular station. Security reasons!!
    		showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_FAIL_NO_LOCHOST'));
			adviseGoBack(
				adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_EXEC_ERROR') + '<br\>' +
				adviseLaunchInfo.translator.translate('LAUNCH_FAIL_NO_LOCHOST')
			);
    	}
    };
    
    jQuery.when(deferreds[0], deferreds[1], deferreds[2]).done(
        function() {
            console.log("All pings to secure private stations are complete.");
            console.log("Success port: "+successPort);
            console.log("data: "+ data);
            
            if(successPort<0 && !tooLate) continueExecution();
        });
    
    // If secure private station takes too long, then continue
    window.setTimeout(function(){
        if(!tooLate) continueExecution();
    }, 5000);
}

//========================================================================
/**
 * 5. checkLocalStationAndLaunch 
 * Get the stations that the user has access to, and if a local station 
 * is found, set the affinity to that station.
 * Triggers makeRunAdviseJob that executes the job in the station and
 * starts a servant.
 * 
 * Sample output of a stationlist
 * {
 *  "StationList":
 *    {
 *      Station": [
 *       {
 *        "@name": "akula5sim",
 *        "@status": "Running",
 *        "GeneralInfo": {
 *        "@allowedUsers": "ZGV",
 *        "@hostIP": "172.17.67.103",
 *        "@drmMode": "fiper",
 *        "@useCount": "0",
 *        "@os": "WINDOWS",
 *        "@osName": "WINDOWS_7",
 *        "@osVersion": "6.1"
 *       }
 *      }]
 *    }
 * }
 */
//========================================================================
function checkLocalStationAndLaunch(adviseLaunchInfo){
    
    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_CHECK_LOCAL_SERVANT'));
    
    var eedURL = adviseLaunchInfo.eedURL,
        eedTicket = adviseLaunchInfo.eedTicket;
        
    getMyStations({
        'eedUrl': eedURL,
        'currentUser': adviseLaunchInfo.currentUser,
        'runAs': adviseLaunchInfo.runAs
    }).then(
        function(stationList) {
            
            var affinitySetByUser = (adviseLaunchInfo.userSelectedStation.length > 0) ? true : false;
            
            if(adviseLaunchInfo.localIP !== null &&
                stationList !==null && stationList.length > 0){
                adviseLaunchInfo.stationList = stationList;
                
                for(var k=0; k<stationList.length;k++) {
                    
                    var stationInfo = stationList[k];
                    if(stationInfo && stationInfo['@name'] && stationInfo['@name'].length > 0 && stationInfo.GeneralInfo 
                            && stationInfo.GeneralInfo['@hostIP'] && stationInfo.GeneralInfo['@hostIP'].length > 3) {
                        var stationName = stationInfo['@name'];
                        var stationIP = stationInfo.GeneralInfo['@hostIP'].trim();
                        if(affinitySetByUser){
                            if(stationName === adviseLaunchInfo.userSelectedStation){
                                adviseLaunchInfo.stationName = stationName;
                                adviseLaunchInfo.stationIP = stationIP;
                                adviseLaunchInfo.stationDisplayName = stationName;
                                break;
                            }
                        }
                        else {
                        	// If we are here, then either the local station is not a
                        	// secure station or the local station is a secure station
                        	// that isnt accessible.
                        	if (isLocalStation(stationIP, adviseLaunchInfo) &&
                        			!adviseLaunchInfo['isSecureStation']) {
                                adviseLaunchInfo.localStationName = stationName;
                                adviseLaunchInfo.stationName = stationName;
                                adviseLaunchInfo.stationIP = stationIP;
                                adviseLaunchInfo.stationDisplayName = stationName;
                                break;
                            }
                        }
                    }
                }
            }
            
            makeRunAdviseJob(adviseLaunchInfo);
        }, // End of success callback
        function(err){
            console.warn(err);
            makeRunAdviseJob(adviseLaunchInfo);
        }
    );
}

//========================================================================
/**
 * 6. makeRunAdviseJob
 * Create the modelXML and executes the Analytics Case job in the station.
 * Unless a user selects a particular station from 'Configure And Run', 
 * priority is given to the secure local station. Else no affinity is set.
 * If a secure station is used, submits a request to the station, with the
 * job id to be claimed.  
 */
//========================================================================
function makeRunAdviseJob(adviseLaunchInfo) {
    
    var resourceCredentials = adviseLaunchInfo.resourceCredentials,
        eedURL = adviseLaunchInfo.eedURL,
        eedTicket = adviseLaunchInfo.eedTicket,
        decodeJobXML = htmlUnescape(adviseLaunchInfo.encodedJobXML),
        runInfo = adviseLaunchInfo.runInfo,
        affinity = null;
    
    if(typeof adviseLaunchInfo.stationName !== 'undefined' && adviseLaunchInfo.stationName !== null
            && adviseLaunchInfo.stationName !== ''){
        affinity = adviseLaunchInfo.stationName;
    } else if (typeof adviseLaunchInfo.localStationName !== 'undefined' && adviseLaunchInfo.localStationName !== null
            && adviseLaunchInfo.localStationName !== ''){
        affinity = adviseLaunchInfo.localStationName;
    }
    
    decodeJobXML = unescape(encodeURIComponent(decodeJobXML));
    // Private Secure station takes precedence
    if(adviseLaunchInfo.secureStation) {
    	// Set the affinity to localHost
        affinity = "{localhost}";
        // Set the HasLocalHost value to AppData
        var appDataXML = UTILS.loadXml(decodeJobXML);
        var lHostNode = appDataXML.getElementsByTagName('Application')[0].appendChild(
        		appDataXML.createElement('HasLocalHost'));
        lHostNode.appendChild(appDataXML.createTextNode('true'));
        decodeJobXML = UTILS.xmlToString(appDataXML);
    }

    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_START_SERVANT'),
        setStationNameToSplash(adviseLaunchInfo));
                                                                                            
    var proxyServerURL = adviseLaunchInfo.proxyServer;
    if(typeof proxyServerURL === 'undefined' || proxyServerURL === null){
        proxyServerURL = '';
    }
    if(proxyServerURL.indexOf('http') !== 0){
        proxyServerURL = '';
    }
    
    var modelxml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                    + "<fiper_Model version=\"6.216.0\" majorFormat=\"1\" timestamp=\"6/5/14\" rootComponentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
                    + "<Properties modelId=\"6a53ba4c-811e-11e2-ae82-e9ce6b18c519\" modelName=\"AdviseServant\" modelVersion=\"6.216.0\" />"
                    + "<Component id=\"812da46e-811e-11e2-ae82-e9ce6b18c519\" name=\"AdviseServant\" type=\"com.dassault_systemes.smacomponent.adviseservant\">";

        // client
        modelxml += "<Variable type=\"com.engineous.datatype.String\" id=\"bb27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"host\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"host\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
                    + "<Value><![CDATA["+window.location.protocol+'//'+window.location.host+"]]></Value>"
                    + "</Variable>";

        // csrf
        modelxml += "<Variable type=\"com.engineous.datatype.String\" id=\"bc27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"token\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"token\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
                    + "<Value><![CDATA["+adviseLaunchInfo.token+"]]></Value>"
                    + "</Variable>";
        
    
    // if a local station was found or if user chose a station, assign affinity to the AdviseServant component
    if(affinity){
        modelxml = modelxml
                + "<Variable id=\"812da46e-811e-11e2-ae82-e9ce6b18c519:affinities\" name=\"affinities\" role=\"Property\" structure=\"Aggregate\" mode=\"Local\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">" 
                + "<Variable type=\"com.engineous.datatype.String\" typeWrittenVersion=\"2.0.0\" id=\"812da46e-811e-11e2-ae82-e9ce6b18c519:Host\" name=\"Host\" role=\"Property\" structure=\"Scalar\" mode=\"Local\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519:affinities\">"
                + "<Value>"+affinity+"</Value>"
                + "</Variable>"
                + "</Variable>";
    }
    
    /**
     * This variable sets tells the servant if the data should be 
     * saved and read in Essentials format.
     */
    try {
    	var essOn = false;
    	if (localStorage.getItem('_ESSENTIALS_MODE_ON_') === true) {
    		essOn = true;	
    	}
    	modelxml += "<Variable type=\"com.engineous.datatype.Bool\" id=\"be27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"_ESSENTIALS_MODE_ON_\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"_ESSENTIALS_MODE_ON_\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
			+ "<Value>" + essOn + "</Value>"
			+ "</Variable>";
    } catch(ex){}
    
    modelxml = modelxml 
                + "</Component>"
                + "<Component id=\"6a5a22ed-811e-11e2-ae82-e9ce6b18c519\" name=\"Task1\" type=\"com.dassault_systemes.sma.adapter.Task\">" + "</Component>" + "</fiper_Model>";
                
    // sd4: used to be "/execution/run/workflow"
    var eedRunUrl = eedURL + '/execution/run';
    
    jQuery.support.cors = true;
    jQuery.ajax({ 
        url : eedRunUrl,
        type : "POST",
        beforeSend : function(request) {
            request.setRequestHeader("EEDTicket", eedTicket);
            request.setRequestHeader("Credentials", "");

           
           request.setRequestHeader("RunInfo", runInfo);
            

            request.setRequestHeader("ApplicationData", decodeJobXML);
            resourceCredentials = resourceCredentials.trim();

            request.setRequestHeader("ResourceCredentials", resourceCredentials);
        },
        data : modelxml,
        contentType : "text/plain",
        success : function(returndata, status, xhr) {
            var jobIdTxt = $simjq(returndata).find("JobID").text().trim();
            adviseLaunchInfo.jobID = jobIdTxt;
            
            if(adviseLaunchInfo.secureStation) {
                
                showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_NOTIFY_SEC_STATION'));
                
                jQuery.ajax({
                    url: adviseLaunchInfo.stationAccess+"/claim?jobids="+jobIdTxt,
                    type: "POST",
                    cache:false,
                    success: function (returndata, status, xhr) {
                        waitForServantStartup(adviseLaunchInfo);
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        console.error(textStatus);
                        console.error(errorThrown);
                        //waitForServantStartup(adviseLaunchInfo);
						showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_EXEC_ERROR'));
						adviseGoBack(
								adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_EXEC_ERROR') + '<br\>' + err
						);
                    }
                });
            } else {
                waitForServantStartup(adviseLaunchInfo);
            }
        },
        error : function(jqXHR, textStatus, err) {
            showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_EXEC_ERROR'));
            adviseGoBack(
                    adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_EXEC_ERROR') + '<br\>' + err
                );
        }
    });
}

//========================================================================
/**
 * waitForServantStartup
 * This creates a waiting loop, with a 2sec interval (2000ms)
 */
//========================================================================
function waitForServantStartup(adviseLaunchInfo) {
    var waitLoop = setInterval(function() {
        monitorBulletinBoard(adviseLaunchInfo, waitLoop);
    }, 2000);
}

//========================================================================
/**
 * monitorBulletinBoard
 * This function is called from the waiting loop above with a 2 sec 
 * interval (2000ms).
 */
//========================================================================
function monitorBulletinBoard(adviseLaunchInfo, waitLoop) {
    
    var mcsUrl = adviseLaunchInfo['mcsUrl'],
        launchInfoUrl = '../resources/slmservices/advise/getAnalyticsLaunchInfo?caseID='+adviseLaunchInfo.caseID;
    
    if(mcsUrl.length > 0){
        launchInfoUrl + '&mcsURI=' + encodeURIComponent(mcsUrl)
    }
    
    jQuery.ajax({ url : launchInfoUrl,
          cache: false,
         }) 
        .done(function(newLaunchInfo) {
            if(!jQuery.isEmptyObject(newLaunchInfo)){
            	adviseLaunchInfo.eedTicket = newLaunchInfo.eedTicket;
            }
            tryTolaunchAdviseClient(adviseLaunchInfo, waitLoop);
        })
        .fail(function() {
            tryTolaunchAdviseClient(adviseLaunchInfo, waitLoop);
        }
    );
}

//========================================================================
/**
 * monitorForError
 * Checks for any error or status messages from the servant.
 * if the msg is a status, its displayed on the splash screen
 */
//========================================================================
function monitorForError(url, ticket){
    jQuery.ajax({ url : url,
        data : { 'Topic' : "ResultsServantError",
        'TimeStamp' : 0 },
        type : "GET",
        beforeSend : function(request) {
            request.setRequestHeader("EEDTicket", ticket);
            request.setRequestHeader("Credentials", "");

        },
        success : function(returndata, status, xhr) {
            var errorThrown = returndata.getElementsByTagName('Message');
            
            if(errorThrown.length > 0){
                
                // check if this is a error message
                // or if its a status message
                var msg = errorThrown[errorThrown.length - 1].textContent;
                try {
                    var msgObj = JSON.parse(msg);
                    if (typeof msgObj.operation !== 'undefined' && 
                           msgObj.operation !== null){
                         switch(msgObj.operation){
                             case 'PLMBATCH':
                                 showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_PLMBATCH_EXEC') +
                                                     msgObj.current + '/' + msgObj.max,
                                                     setStationNameToSplash(adviseLaunchInfo));
                                 break;
                             default:
                                 adviseGoBack(msg);
                         }  
                    } else {
                        adviseGoBack(msg);
                    }
                } catch(ex){
                    adviseGoBack(msg);    
                }
            }
        }
    });
}

// Counter of wait loops and limit
var launchCount = 0; // checking every 2 sec so,
var launchLimit = 60; // 60 => 2 minutes
// Message topic that we expect from the EED bulletin board
var messageTopic = "ResultsServantDowloadingFile"; // next will be "ResultsServantURL"
var jobRunning = false;

//========================================================================
/**
 * 7. tryTolaunchAdviseClient
 * This function tries to read bulletin board messages and launch Advise 
 * after file hasFocus been downloaded onto the servant.
 * Cancels the job after waiting for a while.
 */
//========================================================================
function tryTolaunchAdviseClient(adviseLaunchInfo, timer) {
    
    var jobIdTxt = adviseLaunchInfo.jobID;
    var eedURL = adviseLaunchInfo.eedURL;
    var eedTicket = adviseLaunchInfo.eedTicket;
    
    launchCount++;
    if (launchCount > launchLimit) {
        // sd4 - IR-297707-3DEXPERIENCER2015x - adding a confirmation message 
        // to wait longer in order to allow downloading a large file
        createLaunchPopOver({
            'message': adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_TIMER_XTND'),
            'confirm-mode': true,
            'ok-callback': function(){
                launchCount = 0;
                launchLimit = 150; // 5 minutes
                return;
            },
            'close-callback': function(){
                clearInterval(timer);
                showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_TIMER_XTND'),
                    setStationNameToSplash(adviseLaunchInfo));
                cancelJob(adviseLaunchInfo, adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_TIMEOUT'));
            }
        });
    }
    
    // Configure AJAX call to the EED for reading bulletin board messages
    var eedURLMonitor = eedURL + "/job/" + jobIdTxt + "/monitor";
    
    jQuery.support.cors = true;
    
    monitorForError(eedURLMonitor, eedTicket);
    
    // AJAX call to read EED bulletin board
    jQuery.ajax({
        url : eedURLMonitor,
        data : { 'Topic' : messageTopic,
                 'TimeStamp' : 0 },
        type : "GET",
        beforeSend : function(request) {
            request.setRequestHeader("EEDTicket", eedTicket);
            request.setRequestHeader("Credentials", "");
        },
        success : function(returndata, status, xhr){
            
            var adviseMessage = $simjq(returndata).find("Message").text() || '';
            // sd4 - I keep getting this error when i try to launch 
            var localTopic = $simjq(returndata).find("MessageList").attr("topic");
            if(localTopic && localTopic.length>4) {
            	localTopic = localTopic.trim();
            }
            if (adviseMessage.length > 4) {
                // First message topic that we expect - before downloading the data
                // file on the servant (done by component BEFORE launching advise servant
                if (localTopic == "ResultsServantDowloadingFile") {
                    
                    showLoadingMessage(adviseLaunchInfo.translator.translate(adviseMessage) + "...",
                        setStationNameToSplash(adviseLaunchInfo));
                        
                    // Next message topic that we expect - URL for advise - posted
                    // after Advise servant is fully functional
                    messageTopic = "ResultsServantURL";
                    
                    // Reset the timout to 30 mins - in case of downloading a very
                    // large file over a slow network
                    launchCount = 0;
                    launchLimit = 900;
                    jobRunning = true;
                }
                else {
	                clearInterval(timer);
	                
	                // Retrieve the servant url(s)
	                deriveServantURL(adviseLaunchInfo, adviseMessage);
	                
	                if ((adviseLaunchInfo['stationDisplayName']).length === 0){
	
	                	// The display name would be empty only if
	                	// affinity is not set and the station is not
	                	// a secure station.
	                	
	                	var servantIP = '';
	                	if (adviseMessage.indexOf('http') === 0){
	                		// Unproxified url
	                		var parser = document.createElement('a');
	                        parser.href = adviseMessage;
	                        servantIP = parser.hostname;
	                	} else {
	                		// Proxy exists, and the message format is
	                		// 192.178.106.25/8090/Advise
	                		servantIP = adviseMessage.split('/')[0];
	                	}
	                	if (servantIP.length > 0){
	                		for(var i=0; i<adviseLaunchInfo.stationList.length; i++) {
	                    		var stationInfo = adviseLaunchInfo.stationList[i];
	                    		if (servantIP ===
	                    			stationInfo.GeneralInfo['@hostIP'].trim()){
	                    			adviseLaunchInfo.stationIP = servantIP;
	                    			adviseLaunchInfo.stationName = stationInfo['@name'];
	                    			adviseLaunchInfo.stationDisplayName = stationInfo['@name'];
	                    		}
	                    	}
	                		
	                		if ((adviseLaunchInfo['stationDisplayName']).length === 0){
	                			adviseLaunchInfo.stationDisplayName = window.location.host
	                		}
	                	}
	                }
	            
	                //startJobLogHeartbeat(jobIdTxt);
	                
	                var startWaitTimer = setInterval(function() {
	                    clearInterval(startWaitTimer);
	                    removeLoadingMessage();
	                    // FIXME: Why is the servant url set here ?
	                    // adviseLaunchInfo.servantURL = adviseMessage + '/';
	                    startApp(adviseLaunchInfo);
	                }, 2000);
                }
      } else {
          
          var messageElem = $simjq(returndata).find("MonitoringMessages");
          var status = messageElem.attr("status");
          if (status == "Running" && !jobRunning) {
              // Reset the wait timer for the Executor to post the message
              showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_WAIT_FOR_SERVANT'),
                setStationNameToSplash(adviseLaunchInfo));
                
              launchCount = 0;
              jobRunning = true;
          } else if (status == "Done") {
              clearInterval(timer);
              
              // We don't need this message when the job is cancelled.
              if (! JOB_CANCELLED){
                  var errorThrown = adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_ERROR');
                  showLoadingMessage(errorThrown, setStationNameToSplash(adviseLaunchInfo));
                  adviseGoBack(errorThrown);
              }
          }
       }
    }, // End of success callback
    error: function(jqXHR, textStatus, errorThrown){
        showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_STATUS_ERROR'));
        adviseGoBack(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_STATUS_ERROR') + '<br/>' +
            adviseLaunchInfo.translator.translate('LAUNCH_BB_ERROR'));
        return;
    }
    });
}

//========================================================================
/**
 *  startApp
 *  This is the last step in the launch.
 *  Check the servant for validity, mixed content and certificate.
 *  The servant is up and running, so load the Results Analytics
 *  HTML
 */
//========================================================================
function startApp(adviseLaunchInfo) {
    
    $simjq.when(checkServantURLValidity(adviseLaunchInfo))
        .then(function(token){
			if (token.length > 0){
            
            if(!adviseLaunchInfo.noServant){
                showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_READING_DATA'),
                    setStationNameToSplash(adviseLaunchInfo));
            }
            else{
                showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_LOAD_LITE'));
            }
            
            $simjq('#widgetframe').attr('src', "../webapps/SMAAnalyticsUI/smaResultsAnalyticsLaunched.html").load(function(){
                var widgetWindow = window.frames['widgetframe'];
                if(!widgetWindow.setServantFromParent) {
                    widgetWindow = widgetWindow.contentWindow; // needed for FF
                }
                if(widgetWindow.setServantFromParent) {
                    $simjq('.embeddedWidget').show();
                    if(!adviseLaunchInfo.noServant){
                        widgetWindow.setServantFromParent(adviseLaunchInfo);
                    }
                } else {
                    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_PAGE_LOAD_ERROR'));
                    adviseGoBack(adviseLaunchInfo.translator.translate('LAUNCH_PAGE_LOAD_ERROR'));
                }
            });
				
			} else {
				adviseGoBack(adviseLaunchInfo.translator.translate('LAUNCH_SERVANT_ERROR'));
			}

        });
}

//===============================================================
/**
 * Called by SMARunAdviseJob.jsp to initiate the case launch
 */
//===============================================================
function readyFunction(adviseLaunchInfo, relaunch) {
    require(['UWA/Utils','DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils','DS/TopBarProxy/TopBarProxy'],function(UWAUtils, NLSUtils, TopBarProxy){
         var topBarProxy = new TopBarProxy({'id':'CommandProvider1'});
         //TopBar.MainMenuBar.setActiveMenuProviders("ra-app");
         topBarProxy.activate();
         topBarProxy.setContent({
                            share: [
                                    /*{'label': 'Share...', 'onExecute': callback},*/ // Yet to be implemented
                                    {label: NLSUtils.translate('Save Analytics Case'), onExecute: function(){
                                        console.log('Save Analytics Case Called from 3DSpace');
                                        var widgetWindow = window.frames['widgetframe'];
                                        if(!widgetWindow.setServantFromParent) {
                                                widgetWindow = widgetWindow.contentWindow; // needed for FF
                                        }
                                        widgetWindow.postMessage('TRIGGER_RA_SAVE', window.location.origin);
                                    }}]
                            });

        
        // This might be a relaunch. Stop re-relaunching again.
        localStorage.removeItem('smaAnalytics_MC_Interruption');
    
        adviseLaunchInfo.translator = NLSUtils;
        UTILS = UWAUtils;
        
        removeLoadingMessage();
        $simjq('.sim-ui-advise-alert-message').hide();
        $simjq('.sim-ui-splash-tutorial-link').html('<a>' + adviseLaunchInfo.translator.translate('LAUNCH_START_TUT') + '</a>');
        $simjq('.sim-ui-splash-tutorial-link').show();
        
        // show splash screen
        $simjq('.sim-ui-splash-progressbar').progressbar({ value : false });
        // start everything
        showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_CHECK_SERVANT'));
        
        $simjq.when(getRunningServant(adviseLaunchInfo.caseID, adviseLaunchInfo)).then(
            function(data){
                var runningServant = data;
                
                if (runningServant !== null) {
                    
                    showLoadingMessage(adviseLaunchInfo.translator.translate('LAUNCH_CONNECT_TO_XSERVANT'));
                    
                    adviseLaunchInfo.servantURL = runningServant.servantURL;
                    adviseLaunchInfo.stationName = runningServant.stationName;
                    adviseLaunchInfo.stationIP = runningServant.stationIP;
                    adviseLaunchInfo.token = runningServant.token;
                    adviseLaunchInfo.stationDisplayName = runningServant.stationName;
                    
                    // Found a servant. Load HTML
                    startApp(adviseLaunchInfo);
                } else {
                    
                    adviseLaunchInfo.servantURL = null;
                    
                    $simjq('.sim-ui-launch-cancel').click(function() {
                        cancelJob(adviseLaunchInfo);
                    });
                    
                    // Start a new servant 
                    startServant(adviseLaunchInfo);
                }
                
                if (localStorage.getItem('smaResultsAnalyticsHideTutorial') !== 'true') {
                    helpClickEvent('', '');
                }
            }
        );
    });
}

//========================================================================
/**
 * RESULTS ANALYTICS LAUNCH SEQUENCE -END
 */
//========================================================================

