/**
* Functions used in the results analytics help and its calling pages.
*/

/*@quickreview qw8 8/01/2014 fixed showTutorials function */

if(typeof jQuery!=='undefined' && typeof $simjq=='undefined') {
	$simjq = jQuery.noConflict();
}

/**
* Launches tutorial pages in a new window
*/
function showTutorials(tutorialType) {
	if (tutorialType !== '') { //Changed from (! tutorialType === ''), which always evaluates to false.
		var smaAdvHelpJSPPath = '../simulationcentral/smaResultsAnalyticsHelp/' + 'ResultsAnalytics' + tutorialType + '.html';
		helpClickEvent(tutorialType, smaAdvHelpJSPPath);
	}
}

/** 
* Shows the help splash popover.
*/
function showHelpSplash() {
			
	var tutPrefix = '../webapps/SMAAnalyticsUI/assets/tutorial/2015x-Page-', tutSuffix='.png',  tutIndex = 0, numTut = 14;

	if (localStorage.getItem('smaResultsAnalyticsHideTutorial') === 'true'){
		$simjq('.sim-ui-advise-tutorial-dontShow')
			.append('<div class="sim-ui-advise-tutorial-boxFill">');
	}

	$simjq('.sim-ui-advise-tutorial-image')
		.css('background-image','url(\''+tutPrefix+(tutIndex+1)+tutSuffix +'\')');
	$simjq('.sim-ui-advise-tutorial-close').click(function(){
		parent.hideHelp();
	});

	$simjq('.sim-ui-advise-tutorial-next').click(function(){
		tutIndex = (parseInt(tutIndex,10)+1)%parseInt(numTut,10);
		var img = new Image();
		img.onload = function() {
			$simjq('.sim-ui-advise-tutorial-image')
				.css('background-image','url(\''+tutPrefix+(tutIndex+1)+tutSuffix +'\')');
		};
	img.src = tutPrefix+(tutIndex+1)+tutSuffix;

	if(tutIndex === 0){
		$simjq('.sim-ui-advise-tutorial-dontShow').show();
	} else {
		$simjq('.sim-ui-advise-tutorial-dontShow').hide();
	}
	});

	$simjq('.sim-ui-advise-tutorial-dontShow')
	.click(function(){
		if(localStorage.getItem('smaResultsAnalyticsHideTutorial') === 'true'){
			localStorage.setItem('smaResultsAnalyticsHideTutorial', 'false');
			
			$simjq('.sim-ui-advise-tutorial-dontShow').empty();
		} else {
			localStorage.setItem('smaResultsAnalyticsHideTutorial', 'true');
			
			$simjq('.sim-ui-advise-tutorial-dontShow')
				.append('<div class="sim-ui-advise-tutorial-boxFill">');
		}
	});

	$simjq('.sim-ui-advise-tutorial-prev').click(function(){
	tutIndex = tutIndex-1;
		if(tutIndex<0){
			tutIndex = numTut -1;
		}
		var img = new Image();
		var loadFunc = function() {
			$simjq('.sim-ui-advise-tutorial-image')
				.css('background-image','url(\"'+tutPrefix+(tutIndex+1)+tutSuffix +'\")');
		};
		img.onerror = loadFunc;
		img.onload = loadFunc;
		img.src = tutPrefix+(tutIndex+1)+tutSuffix;

		if(tutIndex === 0){
			$simjq('.sim-ui-advise-tutorial-dontShow').show();
			console.log(tutIndex);
		} else {
			$simjq('.sim-ui-advise-tutorial-dontShow').hide();
			console.log(tutIndex);
		}
	});					
}

/**
* Main calling function
*/
function launchHelp(tutorialTopic) {
	if (tutorialTopic === null || tutorialTopic === ''){
		showHelpSplash();
	}
	else{
		showTutorials(tutorialTopic);
	}
}

/**
 * Launching and closing tutorial windows
 */
var tutorialWindow = new function () {
	this.openedWindows = {};
	
	this.open = function(instanceName) {
		var strWindowFeatures = "toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no,width=" +
			(screen.width/2) + ",height=" + screen.height/2 + ",top=" +
			(screen.height/4)  +  ",left=" + (screen.width/4);
		
		var handle = window.open(Array.prototype.splice.call(arguments,1), instanceName, strWindowFeatures);
		this.openedWindows[instanceName] = handle;
		return handle;
	};
	
    this.closeAll = function() {
        for(var dialog in this.openedWindows)
            this.openedWindows[dialog].close();
    };
};

/**
* Help click callback.
* if the help splash has already  been created show it else create it.
*/

function helpClickEvent(tutorialTopic, smaAdvHelpJSPPath) {
	if (tutorialTopic === null || tutorialTopic === ''){
		//Show Popover
		var helpFrame = document.querySelector('#tutorialFrame');
		var helpDiv = document.querySelector('#adviseHelpDiv');
		
		// throw out the old iframe if it exists 
		// (this fixes an IE11 bug that prevents you from just modifying the src attribute
		// of the iframe)
		if(helpFrame !== null){
			helpDiv.removeChild(helpFrame);
		}	
		// recreate the iframe and append it to it's parent
		helpFrame = document.createElement('iframe');
		helpFrame.setAttribute('id','tutorialFrame');
		helpFrame.setAttribute('src',smaAdvHelpJSPPath === "" ? "../simulationcentral/smaAdviseHelp.jsp" : smaAdvHelpJSPPath);
		helpFrame.classList.add('sim-ui-portal-help-frame');
		helpDiv.appendChild(helpFrame);
		
		// since closing the div hides it, we need to show it
		$simjq(helpDiv).show();
		
		// some css that needs to be set ...
		$simjq(helpDiv).css({
			width: "922px",
			height: "540px",
			visibility: "visible",
			"z-index": 200000
		});
		$simjq(helpDiv).css("top", Math.max(0, (($simjq(window).height() - $simjq(helpDiv).height()) / 2) + $simjq(window).scrollTop()) + "px");
		$simjq(helpDiv).css("left", Math.max(0, (($simjq(window).width() - $simjq(helpDiv).width()) / 2) + $simjq(window).scrollLeft()) + "px");
		$simjq(helpFrame).css("visibility", "visible");
	}
	else {
	//Launch a new window with the requested help tutorial
		tutorialWindow.open(tutorialTopic, smaAdvHelpJSPPath);
	}
	return;
}



function addContextualDocsLinkToGlobalToolBar(){
	try{
		var labelTextContent = 'Results Analytics Documentation...';
        var docLinks = {
			'preview': 'SimResaUserMap/resa-c-Case-Annotating.htm',
			'define': 'SimResaUserMap/resa-m-Define-sb.htm',
			'explore': 'SimResaUserMap/resa-m-Explore-sb.htm',
			'predict': 'SimResaUserMap/resa-c-Predict-Approximate.htm',
			'compare': 'SimResaUserMap/resa-c-Compare.htm',
			'collaborate': 'SimResaUserMap/resa-c-Collaborate.htm',
			'recommend': 'SimResaUserMap/resa-c-Recommend.htm'
		};
		
		var onClickHandler = function(links){
			// assuming the windowRef has the emxUIConstants.js file included ...
			try{
                var currentMarker = null;
                // get current marker
                [].forEach.call(document.querySelectorAll('iframe'), function (e){
                    if(e.contentWindow.document.querySelector('.sim-ui-navigator-marker-current') != null)
                        currentMarker = e.contentWindow.document.querySelector('.sim-ui-navigator-marker-current');
                });
				var langOnlineStr = 'English'; //emxUIConstants.STR_HELP_ONLINE_LANGUAGE;
                var helpURL = "http://help.3ds.com/HelpDS.aspx?P=11&L=";
                if(typeof window.emxUIConstants != "undefined")
                    var helpURL = window.emxUIConstants.HELP_URL;
				var currentPageURL = 'SimResaUserMap/resa-c-Case.htm';
				// http://help.3ds.com/HelpDS.aspx?P=11&L='+langOnlineStr+'&V=2016x&F=' + currentPageURL + '&contextscope=cloud
				if(currentMarker !== null){
					// we're in RA ...
					var currentPage = currentMarker.parentNode.getAttribute('page-name').toLowerCase();
					
					// as of now: Dec 5th 2014, there is only an English translation, I'm hoping this is taken care of by the people who set this constant ...
					currentPageURL = links[currentPage];
					//var linksrc = helpURL + '/'+langOnlineStr+'/DSDoc.htm?show=' + this.docLinks[currentPage];
				}
				if(location.protocol === 'https:' && helpURL.substring(0, 5) === 'http:'){
					helpURL = 'https:' + helpURL.substring(5);
				}
				var linksrc = helpURL + '/'+langOnlineStr+'/DSDoc.htm?show=' + currentPageURL;
				var request = new XMLHttpRequest();  
				request.open('GET', linksrc, true);
				request.onreadystatechange = function(){
				    if (request.readyState === 4){
				        if (request.status === 404 || request.status === 0) {
							window.open('http://help.3ds.com/HelpDS.aspx?P=11&L='+langOnlineStr+'&V=2017x&F=' + currentPageURL + '&contextscope=cloud','smaAdviseDocs');
				        }else{
							window.open(linksrc,'smaAdviseDocs');
				        }
				    }
				};
				request.send();
				//window.open(linksrc,'smaAdviseDocs');
			}catch(e){
				console.error(e);
			}
		};
		
		// add the link to the page
        // w.document.querySelector('.global.help ul').appendChild(newLi);
        // create an instance of TopBar proxy and provide it 3DSpace id 
        // as that is already added to currently active menu providers
        // FIXME: replace this with a more permanent fix for 17x based on UX recommendation
        //window.topBarProxyforRA.setContent({help: []});
//        topBarProxyforRA.setContent({
//                            help: [
//                                    /*{'label': 'Share...', 'onExecute': callback},*/ // Yet to be implemented
//                                    {label: labelTextContent, onExecute: function(){onClickHandler(docLinks);}}]
//                                });

        return {label: labelTextContent, onExecute: function(){onClickHandler(docLinks);}};
		
	}catch(e){
		console.log(e);
	}
	return;
}
function removeDocumentationLink(){
	var w = null;
	try{
		w = window.getTopWindow();
		var lis = w.document.querySelectorAll('.sim-ui-toolbar-advise-contextualhelp');
		if(lis.length > 0){
			[].forEach.call(lis,function(li){
				li.parentNode.removeChild(li);
			});
		}
	}catch(e){
		console.error(e);
		// ignore and continue
	}
}

/**
* Add help option to the global toolbar.
* Creates a tutorial frame in the calling page and appends all the help images to it. 
*/
function addHelpLinkToGlobalToolBar(tutorialTopic,smaAdvHelpJSPPath) {
	try{
        if(typeof window.getTopWindow().topBarProxyLoadedforRA == "undefined") {
            window.getTopWindow().topBarProxyLoadedforRA = true;
            return;
            
        };
        require(['UWA/Utils','DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils','DS/TopBarProxy/TopBarProxy'],function(UWAUtils, NLSUtils, TopBarProxy){
		if(window.getTopWindow().$('#sim-ui-toolbar-help')) {
			window.getTopWindow().$('#sim-ui-toolbar-help').remove();
		}
        var topBarProxyforRA = new TopBarProxy({'id':'CommandProvider1'});
		var raContextMenu = addContextualDocsLinkToGlobalToolBar();
		var helpDiv = document.createElement('div');
		helpDiv.setAttribute('id','adviseHelpDiv');
		helpDiv.classList.add('sim-ui-portal-help-container');
		document.querySelector('body').appendChild(helpDiv);
	
		//bury it - shouldnt mess with the custom contexts from the divs abv	
		$simjq(helpDiv).css({
				'width': '0px',
				'height': '0px',
				'z-index': 0
			});
        topBarProxyforRA.activate();
        topBarProxyforRA.setContent({
                            help: [
                                    /*{'label': 'Share...', 'onExecute': callback},*/ // Yet to be implemented
                                    {label: 'Results Analytics Tutorial...', onExecute: function (){
                                     helpClickEvent(tutorialTopic, smaAdvHelpJSPPath); 
                                    }}, raContextMenu]
                                });

        window.getTopWindow().topBarProxyforRA = topBarProxyforRA;
        window.getTopWindow().topBarProxyLoadedforRA = true;
        });
        
        
	} catch (e) {
		console.error(e);
		//ignore and carry on; you are probably on the 3dd
	}
}

function removeAdviseHelp() {
	try{
		window.getTopWindow().$('#sim-ui-toolbar-help').remove();
		console.log('closing all windows opened for help');
		tutorialWindow.closeAll();
	} catch(e){
		console.error(e);
		// ignore and continue
	}
}

//Do not remove/rename this func. Called from another iframe.
function hideHelp() {
	$simjq('#adviseHelpDiv').hide();
}
function removeAdviseSaveButton(){
	try{
		window.getTopWindow().$('#sim-ui-toolbar-save').remove();
	}catch(e){
		console.error(e);
		// ignore and continue;
	}
}
function removeGlobalLinks() {
	if(!window.isDownloadLink){
		window.globalLinksRemoved = true;
		removeAdviseSaveButton();
		removeAdviseHelp();
		removeDocumentationLink();
		return;
	}
	window.isDownloadLink = false;
}
function removeGlobalLinksTryAgain(){
	if(!window.globalLinksRemoved){
		return removeGlobalLinks();
	}
}
