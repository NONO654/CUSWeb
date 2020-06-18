/*PRIVATE*/ var PLUGIN_NAME = "ENOVIA 3DLive Examine Plugin";
/*PRIVATE*/ var PLUGIN_REGISTRY_NAME = "DassaultSystemes.ENOVIA3DLiveExaminePlugin";
/*PRIVATE*/ var PLUGIN_CLSID = "CE2C283B-21CA-472B-B1D4-322F27274AC2";
/*PRIVATE*/ var PLUGIN_MIME_TYPE = "application/x-enovia-3dliveexamine";
/*PRIVATE*/ var PLUGIN_ARCHIVE = "ENOVIA3DLiveExaminePlugin";
/*PRIVATE*/ var PLUGIN_VERSION = "ENOVIA3DLiveExamineVersion.txt";

// A message to be displayed
/*PRIVATE*/ var VIEWER_MESSAGE = "";

/*PRIVATE*/ var SMARTEAM_MODE = false;

// A map to identify objects parameters
/*PRIVATE*/ var ID2PARAMS = new Object();

// A flag which tells if Firefox is running on Windows x64
var isFirefoxRunningOn64 = false;

// Check if the browser is running on MacOS
// @return true if the browser runs on MacOS
/*PRIVATE*/ function isRunningOnMacOS()
{
	return (navigator.platform == "MacIntel");
}

// Check if the browser is a GECKO browser
// @return true if the browser is a GECKO browser
/*PRIVATE*/ function isGecko()
{
	if ( isIEex() == true)
		return false;
	else if(navigator.product == "Gecko")
		return true;
	else
		return false;
}

// Check if the browser is a 64bits GECKO browser
// @return true if the browser is a 64bits GECKO browser
/*PRIVATE*/ function isGecko64()
{
	var ua = navigator.userAgent.toLowerCase();
	return (isGecko() && (ua.indexOf("x64") != -1 || ua.indexOf("win64") != -1));
}

// Check if the browser is a 32bits GECKO browser running on a 64bits OS
// @return true if the browser is a 32bits GECKO browser running on 64bits OS
/*PRIVATE*/ function isGecko32on64()
{
	var ua = navigator.userAgent.toLowerCase();
	return (isGecko() && (ua.indexOf("wow64") != -1 || isFirefoxRunningOn64));
}

// Check if the browser is Internet Explorer
// @return true if the browser is Internet Explorer
/*PRIVATE*/ function isIEex()
{
    if (navigator.appName == 'Microsoft Internet Explorer') {
		return true;
    }
    else if (navigator.appName == 'Netscape') {
        // Internet Explorer 11 now returns "Netscape" as appName, seems like we have to check for "Trident/" now
        var ua = navigator.userAgent;
        var re  = new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})");
        if (re.exec(ua) != null) {
            return true;
        }
    }
                
    return false;
}


// Check if the browser is Internet Explorer 64bits
// @return true if the browser is Internet Explorer 64bits
/*PRIVATE*/ function isIEex64()
{
	var ua = navigator.userAgent.toLowerCase();
	return (isIEex() && (ua.indexOf("x64") != -1 || ua.indexOf("win64") != -1));
}

// Check if the browser is Internet Explorer 32bits running on a 64bits OS
// @return true if the browser is Internet Explorer 32bits running on 64bits OS
/*PRIVATE*/ function isIEex32on64()
{
	var ua = navigator.userAgent.toLowerCase();
	return (isIEex() && ua.indexOf("wow64") != -1);
}

// Create XMLHttpRequest object
// @return an XMLHttpRequest object
/*PRIVATE*/ function getXHR()
{
	var xhr=null;
	if (isGecko())
	{
		// Gecko browser case
		xhr = new XMLHttpRequest();
	}
	else
	{
		// Internet Explorer case
		try
		{
			xhr = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch(e1)
		{
			try
			{
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e2)
			{
				xhr = null;
			}
		}
	}
	return xhr;
}

// Convert XML forbidden chars
// @param url the url to encode
// @return the encoded url
/*PRIVATE*/ function encodeUrl(url)
{
	var encodedUrl = "";
	for(var i=0; i<url.length; i++)
	{
		if (url.charAt(i) == '&')
			encodedUrl += "&amp;";
		else if (url.charAt(i) == '<')
			encodedUrl += "&lt;";
		else if (url.charAt(i) == '>')
			encodedUrl += "&gt;";
		else
			encodedUrl += url.charAt(i);
	}
	return encodedUrl;
}

// Check if update is needed (Gecko only)
// @param currentVersion the current plugin version
// @param requestedVersion the request plugin version
// @return true if an update is needed
/*PRIVATE*/ function isUpdateNeeded(currentVersion, requestedVersion)
{
	var curNums = currentVersion.split(".");
	var reqNums = requestedVersion.split(".");
	if (curNums.length != reqNums.length)
		return true;
	// Windows installation behavior has changed, we need to handle old behavior correctly
	if (!isRunningOnMacOS() && curNums.length >= 1 && parseInt(curNums[1]) <= 211 && parseInt(reqNums[1]) >= 212)
	{
		var message = "This page requires " + PLUGIN_NAME + " to be upgraded,\n";
		message += "please uninstall it from Add-ons/Extensions panel and restart your browser.\n";
		alert(message);
		throw message; // allow to abort everything
	}
	for(var i=0; i<curNums.length; i++)
	{
		if (parseInt(curNums[i]) < parseInt(reqNums[i]))
			return true;
		if (parseInt(curNums[i]) > parseInt(reqNums[i]))
			return false;
	}
	return false;
}

// Get the requested version
// @param serverUrl the url of the server from which files are available
// @return the requested version
/*PRIVATE*/ function getRequestedVersion(serverUrl)
{
	var requestedVersion = "";
	try
	{
		var xhr = getXHR();
		if (isRunningOnMacOS())
			xhr.open("GET", serverUrl + "/osx/" + PLUGIN_VERSION, false);
		else if (isIEex64() || isGecko64())
			xhr.open("GET", serverUrl + "/x64/" + PLUGIN_VERSION, false);
		else
			xhr.open("GET", serverUrl + "/x86/" + PLUGIN_VERSION, false);
		xhr.send(null);
		requestedVersion = xhr.responseText;
		if (requestedVersion == "")
			throw "Invalid version";
	}
	catch(e)
	{
		VIEWER_MESSAGE = PLUGIN_NAME + " Error : Unable to get the expected version.";
	}
	return requestedVersion;
}

// Get the parameters of a viewer
// @param viewerId the id of the viewer
function getViewerParams(viewerId)
{
	var params = ID2PARAMS[viewerId];
	if (params == undefined)
	{
		params = new Object();
		ID2PARAMS[viewerId] = params;

		if (window.addEventListener)
			window.addEventListener('beforeunload', onWindowCloseViewerCB, false);
		else if (window.attachEvent)
			window.attachEvent('onbeforeunload', onWindowCloseViewerCB);
	}
	return params;
}

// Create a viewer instance
// @param viewerId the id of the viewer to create
function createViewerInstance(viewerId)
{
	var params = getViewerParams(viewerId);

	var containerId = params["CONTAINER_ID"];
	var requestedVersion = params["REQUESTED_VERSION"];
	var serverUrl = params["SERVER_URL"];
	var documentUrl = params["DOCUMENT_URL"];
	var useScripting = params["USE_SCRIPTING"];

	var useViewerCustomization = params["USE_VIEWER_CUSTOMIZATION"];
	var usePrintBanner = params["USE_PRINT_BANNER"];

	var containerObject = document.getElementById(containerId);

	// PLMSetupUrl
	var PLMSetupUrl = serverUrl + "/x86/msi";
	if (isRunningOnMacOS())
		PLMSetupUrl = serverUrl + "/osx/pkg";
	else if (isIEex64() || isIEex32on64() || isGecko64() || isGecko32on64())
		PLMSetupUrl = serverUrl + "/x64/msi";

	// param PLMProperties
	var value = "";
	value += "<?xml version='1.0' encoding='utf-8'?>";
	value += "<PLMProperties>";
	value += "<PLMVersion type='version'>" + requestedVersion + "</PLMVersion>";
	value += "<PLMSetupUrl type='relative'>" + encodeUrl(PLMSetupUrl) + "</PLMSetupUrl>";
	value += "<DocumentFile type='relative'>" + encodeUrl(documentUrl) + "</DocumentFile>";
	if (useViewerCustomization)
	{
		value += "<PLMViewerCustomizationUrl type='relative'>" + params["VIEWER_CUSTOMIZATION_URL"] + "</PLMViewerCustomizationUrl>";
		value += "<PLMViewerCustomizationUID>" + params["VIEWER_CUSTOMIZATION_UID"] + "</PLMViewerCustomizationUID>";
	}
	if (usePrintBanner)
	{
		value += "<PLMPrintBannerPosition>" + params["PRINT_BANNER_POSITION"] + "</PLMPrintBannerPosition>";
		value += "<PLMPrintBannerSize>" + params["PRINT_BANNER_SIZE"] + "</PLMPrintBannerSize>";
		value += "<PLMPrintBannerText>" + params["PRINT_BANNER_TEXT"] + "</PLMPrintBannerText>";
		value += "<PLMPrintBannerLogo type='relative'>" + encodeUrl(params["PRINT_BANNER_LOGO"]) + "</PLMPrintBannerLogo>";
	}
	value += "</PLMProperties>";

	var param = document.createElement("param");
	param.name = "PLMProperties";
	param.value = value;

	if (isGecko())
	{
		// Firefox case
		var viewerObject = document.createElement("object");
		viewerObject.id = viewerId;
		viewerObject.width = "100%";
		viewerObject.height = "100%";

		if (VIEWER_MESSAGE != "")
			viewerObject.appendChild(document.createTextNode(VIEWER_MESSAGE));
		else
		{
			viewerObject.appendChild(param);
			viewerObject.type = PLUGIN_MIME_TYPE;
		}
		containerObject.appendChild(viewerObject);
	}
	else
	{
		// Internet Explorer case
		if (VIEWER_MESSAGE != "")
			containerObject.appendChild(document.createTextNode(VIEWER_MESSAGE));
		else {

		    // In IE, resizing the window doesn't change the height of the object, 
		    // so setting all of the object's parents' height to 100%
		    var htm = document.getElementsByTagName("html")[0].style.height = "100%";
		    var bod = document.getElementsByTagName("body")[0].style.height = "100%";

		    var objectNode = document.createElement("object");
		    if (SMARTEAM_MODE === true) {
		      containerObject.setAttribute("style", "height:100%");
		    }
		    else {
		      try {
		        containerObject.style.height = "100%";
		      } catch (e) {
		        containerObject.setAttribute("style", "height:100%");
		      }
		    }
		    objectNode.appendChild(param);
		    objectNode.setAttribute("id", viewerId);
		    // IR-411639-3DEXPERIENCER2016x
		    objectNode.setAttribute("style", "width:100%;height:100%;");
		    objectNode.setAttribute("width", "100%");
		    objectNode.setAttribute("height", "100%");
		    objectNode.setAttribute("classid", "clsid:" + PLUGIN_CLSID)
		    containerObject.appendChild(objectNode);

		}
	}

	if (VIEWER_MESSAGE == "")
	{
		if (useScripting)
			createScriptingBehavior(containerObject, viewerId);
		else
		{
			// We always activate at least a little piece of scripting
			// It lets us use PropagateStatus
			var scriptEvent = document.createElement("script");
			scriptEvent.type = "text/javascript";
			if (isGecko())
			{
				scriptEvent.text = "function " + viewerId + "_OnEvent(EventCategory, EventName, EventSender, EventParameters) { onViewerReadyEvent('" + viewerId + "', EventCategory, EventName, EventSender, EventParameters); }";
			}
			else
			{
				scriptEvent.text = "function " + viewerId + "::OnEvent(EventCategory, EventName, EventSender, EventParameters) { onViewerReadyEvent('" + viewerId + "', EventCategory, EventName, EventSender, EventParameters); }";
			}
			containerObject.appendChild(scriptEvent);
		}
	}
}

// Callback method on viewer ready event to handle minimal scripting behavior
// @param viewerId the id of the viewer who is scripted
// @param eventCategory the event category
// @param eventName the event name
// @param eventSender the event sender
// @param eventParameters the event parameters
/*PRIVATE*/ function onViewerReadyEvent(viewerId, eventCategory, eventName, eventSender, eventParameters)
{
	if (eventCategory == "Application" && eventName == "Ready")
	{
		var params = getViewerParams(viewerId);
		params["EWVIA"] = eventSender;
	}
}

// Get the EWVIA object associated to a viewer
// @param viewerId the id of the viewer
/*PRIVATE*/ function getEWVIAObject(viewerId)
{
	var params = getViewerParams(viewerId);
	var paramEWVIA = params["EWVIA"];
	if (paramEWVIA == undefined && mapEWVIA != undefined)
		paramEWVIA = mapEWVIA[viewerId];
	return paramEWVIA;
}

// Compute the plugin package url
// @param serverUrl the url of the server which provides installation packages
// @param requestedVersion the requested version of the plugin
function getPluginPackageUrl(serverUrl, requestedVersion)
{
	if (isGecko())
		return ""; // no more XPI file
	else
	{
		// CAB version numbers are separated with ',' not '.'
		var versionNums = requestedVersion.split(".");
		var cabVersion = "";
		for(var i=0; i<versionNums.length; i++)
		{
			if (i != 0)
				cabVersion += ",";
			cabVersion += versionNums[i];
		}

		if (isIEex64())
			return serverUrl + "/x64/cab/" + PLUGIN_ARCHIVE + ".cab#version=" + cabVersion;
		else
			return serverUrl + "/x86/cab/" + PLUGIN_ARCHIVE + ".cab#version=" + cabVersion;
	}
}

// Check if the plugin is installed
// @return true if the plugin is installed
function isPluginAvailable()
{
	var isInstalled = false;
	if (isGecko())
	{
		if (navigator.mimeTypes[PLUGIN_MIME_TYPE])
			isInstalled = true;
	}
	// On IE, we always say that the plugin is unavailable to make it automatically installed when needed
	return isInstalled;
}

// Install the plugin
// @param viewerId the id of the viewer
function installPlugin(viewerId)
{
	var params = getViewerParams(viewerId);
	if (isGecko())
	{
		var containerId = params["CONTAINER_ID"];
		var serverUrl = params["SERVER_URL"];

		var containerObject = document.getElementById(containerId);
		containerObject.style.backgroundColor = "#BFDBFF";

		var infoTable = document.createElement("table");
		infoTable.style.width = "100%";
		infoTable.style.height = "100%";
		infoTable.id = "table_" + viewerId;
		var infoColumn = document.createElement("tr");
		var infoRow = document.createElement("td");
		infoRow.align = "center";
		infoRow.appendChild(document.createTextNode("Please download and deploy the following installation package."));
		infoRow.appendChild(document.createElement("br"));
		infoRow.appendChild(document.createElement("br"));
		infoRow.appendChild(document.createTextNode("Once done, you can click on refresh icon."));
		infoRow.appendChild(document.createElement("br"));
		infoRow.appendChild(document.createElement("br"));

		var linkInstall = document.createElement("a");
		var imgInstall = document.createElement("img");
		var imgArrow = document.createElement("img");
		var imgRefresh = document.createElement("img");
		if (isRunningOnMacOS())
		{
			linkInstall.href = serverUrl + "/osx/pkg/" + PLUGIN_ARCHIVE + ".pkg";
			imgInstall.src = serverUrl + "/osx/img/Install_Package.png";
			imgArrow.src = serverUrl + "/osx/img/Install_Arrow.png";
			imgRefresh.src = serverUrl + "/osx/img/Install_Refresh.png";
		}
		else if (isGecko64())
		{
			linkInstall.href = serverUrl + "/x64/msi/" + PLUGIN_ARCHIVE + ".msi";
			imgInstall.src = serverUrl + "/x64/img/Install_Package.png";
			imgArrow.src = serverUrl + "/x64/img/Install_Arrow.png";
			imgRefresh.src = serverUrl + "/x64/img/Install_Refresh.png";
		}
		else // Gecko 32 or Gecko 32 on 64
		{
			linkInstall.href = serverUrl + "/x86/msi/" + PLUGIN_ARCHIVE + ".msi";
			imgInstall.src = serverUrl + "/x86/img/Install_Package.png";
			imgArrow.src = serverUrl + "/x86/img/Install_Arrow.png";
			imgRefresh.src = serverUrl + "/x86/img/Install_Refresh.png";
		}
		imgInstall.title = "Installation Package";
		linkInstall.appendChild(imgInstall);
		infoRow.appendChild(linkInstall);

		infoRow.appendChild(imgArrow);

		var linkRefresh = document.createElement("a");
		linkRefresh.href = "javascript:onPluginRefresh(\"" + viewerId + "\");"
		imgRefresh.title = "Refresh";
		linkRefresh.appendChild(imgRefresh);
		infoRow.appendChild(linkRefresh);

		infoColumn.appendChild(infoRow);
		infoTable.appendChild(infoColumn);
		containerObject.appendChild(infoTable);
	}
	else
	{
		var divPluginInstall = document.getElementById("DIV_PLUGIN_INSTALL");
		if (divPluginInstall == undefined)
		{
			divPluginInstall = document.createElement("div");
			divPluginInstall.id = "DIV_PLUGIN_INSTALL";
			divPluginInstall.style.visibility = "hidden";
			divPluginInstall.style.position = "absolute";
			divPluginInstall.innerHTML = "<object id='OBJECT_PLUGIN_INSTALL' style='visibility: hidden;' classid='clsid:" + PLUGIN_CLSID + "' codebase='" + params["PLUGIN_PACKAGE_URL"] + "'></object>";
			document.body.appendChild(divPluginInstall);
			// Here we use innerHTML, otherwise the codebase attribute is not taken into account...
		}
		var objectPluginInstall = document.getElementById("OBJECT_PLUGIN_INSTALL");
		try
		{
			var pluginVersion = objectPluginInstall.GetPluginVersion();
			document.body.removeChild(divPluginInstall);
			createViewerInstance(viewerId);
		}
		catch(e)
		{
			setTimeout("installPlugin(\"" + viewerId + "\")", 500);
		}
	}
}

// Called when the plugin installation has finished (Firefox and MacOS)
/*PRIVATE*/ function onPluginRefresh(viewerId)
{
	// Destroy the content of the plugin container
	var params = getViewerParams(viewerId);
	var containerId = params["CONTAINER_ID"];
	var containerObject = document.getElementById(containerId);
	var tableObject = document.getElementById("table_" + viewerId);
	containerObject.removeChild(tableObject);
	containerObject.style.backgroundColor = "#FFFFFF";

	navigator.plugins.refresh();

	checkPluginVersion(viewerId);
}

// Check the plugin version
// @param viewerId the id of the viewer
/*PRIVATE*/ function checkPluginVersion(viewerId)
{
	var params = getViewerParams(viewerId);

	if (isGecko())
	{
		var divPluginCheck = document.getElementById("DIV_PLUGIN_CHECK");
		var objectPluginCheck = document.getElementById("OBJECT_PLUGIN_CHECK");
		if (divPluginCheck == undefined)
		{
			divPluginCheck = document.createElement("div");
			divPluginCheck.id = "DIV_PLUGIN_CHECK";
			divPluginCheck.style.visibility = "hidden";
			divPluginCheck.style.position = "absolute";

			objectPluginCheck = document.createElement("object");
			objectPluginCheck.id = "OBJECT_PLUGIN_CHECK";
			objectPluginCheck.type = PLUGIN_MIME_TYPE;
			objectPluginCheck.style.visibility = "hidden";

			divPluginCheck.appendChild(objectPluginCheck);
			document.body.appendChild(divPluginCheck);
		}

		if (objectPluginCheck.GetPluginVersion == undefined || (! isRunningOnMacOS() && objectPluginCheck.IsRunning32on64 == undefined))
		{
			setTimeout("checkPluginVersion(\"" + viewerId + "\")", 500);
		}
		else
		{
		    if (!isRunningOnMacOS())
		     isFirefoxRunningOn64 = objectPluginCheck.IsRunning32on64();
			var currentVersion = objectPluginCheck.GetPluginVersion();
			document.body.removeChild(divPluginCheck);

			var requestedVersion = params["REQUESTED_VERSION"];
			if (requestedVersion != "")
			{
				if (isUpdateNeeded(currentVersion, requestedVersion))
					installPlugin(viewerId);
				else
					createViewerInstance(viewerId);
			}
			else
				createViewerInstance(viewerId);
		}
	}
	else
	{
		// In case of IE, we install the plugin with the correct version
		installPlugin(viewerId);
	}
}

// Apply a customization on a viewer (must be called before creating the viewer itself)
// @param viewerId the id of the viewer for which the customization is applied
// @param custoZipUrl the url of the ZIP file containing the customization
// @param custoUidUrl the url of the file containing the UID of the ZIP file
function setViewerCustomization(viewerId, custoZipUrl, custoUidUrl)
{
	var params = getViewerParams(viewerId);

	var zipUid = "";
	try
	{
		var xhr = getXHR();
		xhr.open("GET", custoUidUrl, false);
		xhr.send(null);
		if (xhr.status == 200)
			zipUid = xhr.responseText;
	}
	catch(e)
	{
		zipUid = "";
	}

	if (zipUid != "")
	{
		params["USE_VIEWER_CUSTOMIZATION"] = true;
		params["VIEWER_CUSTOMIZATION_URL"] = custoZipUrl;
		params["VIEWER_CUSTOMIZATION_UID"] = zipUid;
	}
}

// Setup a print banner on a viewer (must be called before creating the viewer itself)
// @param viewerId the id of the viewer for which the print banner is setup
// @param bannerPosition the banner position ("LEFT", "TOP", "RIGHT", "BOTTOM")
// @param bannerSize the banner size
// @param bannerText the banner text
// @param bannerLogo the banner logo
function setPrintBanner(viewerId, bannerPosition, bannerSize, bannerText, bannerLogo)
{
	var params = getViewerParams(viewerId);
	params["USE_PRINT_BANNER"] = true;
	params["PRINT_BANNER_POSITION"] = bannerPosition;
	params["PRINT_BANNER_SIZE"] = bannerSize;
	params["PRINT_BANNER_TEXT"] = bannerText;
	params["PRINT_BANNER_LOGO"] = bannerLogo;
}

// Create a main viewer in the browser
// @param containerId the id of the container which will contains the viewer object
// @param viewerId the id of the viewer to be created
// @param serverUrl the url of the server which provides installation packages
// @param documentUrl the url of the document to load in the viewer
// @param isSmarTeam true/false; true for viewer created in Smarteam.
function createViewer(containerId, viewerId, serverUrl, documentUrl, isSmarTeam)
{
  if (isSmarTeam) {
    SMARTEAM_MODE = isSmarTeam;
  }
  else {
    SMARTEAM_MODE = false;
  }
  var params = getViewerParams(viewerId);
	params["CONTAINER_ID"] = containerId;
	params["SERVER_URL"] = serverUrl;
	params["DOCUMENT_URL"] = documentUrl;
	params["REQUESTED_VERSION"] = getRequestedVersion(params["SERVER_URL"]);
	params["PLUGIN_PACKAGE_URL"] = getPluginPackageUrl(params["SERVER_URL"], params["REQUESTED_VERSION"]);

	if (! params["USE_VIEWER_CUSTOMIZATION"])
		setViewerCustomization(viewerId, serverUrl + "/ENOVIA3DLiveExamineCusto.zip", serverUrl + "/ENOVIA3DLiveExamineCusto.uid");

	if (! isPluginAvailable())
		installPlugin(viewerId);
	else
		checkPluginVersion(viewerId);
}

// Destroy a main viewer in the browser
// @param containerId the id of the container which contains the viewer object
// @param viewerId the id of the viewer to be destroyed
function destroyViewer(containerId, viewerId)
{
	var pluginInstance = containerId.getElementById(viewerId);
	if (pluginInstance != undefined)
	{
		var objEWVIA = getEWVIAObject(viewerId);

		var remove = true;
		if (objEWVIA != undefined)
		{
			var status = objEWVIA.ActiveEditor.PropagateStatus;
			if (status)
			{
				var message = 'Some modifications will be lost, are you sure you want to leave?';
				if (! confirm(message))
					remove = false;
			}
		}
		if (remove)
			containerId.removeChild(pluginInstance);
	}
}

// Called when the window is being closed
/*PRIVATE*/
function onWindowCloseViewerCB(evt)
{
	var propagateAlert = false;
	for(id in ID2PARAMS)
	{
		var objEWVIA = getEWVIAObject(id);
		if (objEWVIA != undefined)
		{
			var status = objEWVIA.ActiveEditor.PropagateStatus;
			if (status)
				propagateAlert = true;
		}
	}
	if (propagateAlert)
	{
		var message = 'Some modifications will be lost, are you sure you want to leave?';
		var userLang = navigator.language || navigator.userLanguage;
		if(userLang && userLang.indexOf && userLang.indexOf("fr") == 0){
			message = "Des modifications risquent d'être perdues, êtes-vous sûr de vouloir quitter?";
		}
		if (typeof evt == 'undefined')
			evt = window.event;
		if (evt)
			evt.returnValue = message;
		return message;
	}
}
