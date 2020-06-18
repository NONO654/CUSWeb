// (c) Dassault Systemes, 2007, 2008
//
//  Utility to return xml string to structure browser


   /***
    * @author ve4
    * @since 2014x
    * Maximizes/minimizes steps explorer page.
    */
    function resizeStep()
    {
    	try
    	{
    		/*var stepsTable = sbFindFrame(getTopWindow(),"StepsTable");
    		
    		var oldrow = localStorage.getItem("stepSelected");
    		
    		var selectedornot = jQuery('tr[id^="'+oldrow+'"]', 
    				         [stepsTable.document.body]).attr("class");
    		
    		// see if the step is highlighted.
    		if(  "root-node even mx_rowSelected" !== selectedornot &&
    			 "root-node mx_altRow even mx_rowSelected" !== selectedornot
    	      )
    			return;*/
    		
    		var maxstep = 
    			      "../simulationcentral/images/smaIconMaximize.gif";
    		var minstep = 
    			      "../simulationcentral/images/smaIconMinimize.gif";
    		
    		var detailsDisplay = sbFindFrame(getTopWindow(),"detailsDisplay");
    		
    		var title = jQuery('span[id^="StepResizeSpan"]', 
    				   [detailsDisplay.document.body]).attr('title');
    		
    		if("Minimize Step Explorer" === title)
    		{
    			// decrease div style
    			jQuery('div[id^="stepsDetails"]', 
    					[detailsDisplay.document.body]).css('left','0px');
    			jQuery('div[id^="StepResize"]', 
    					[detailsDisplay.document.body]).css('left','0px');

    			// change button style
    			jQuery('span[id^="StepResizeSpan"]', 
    					[detailsDisplay.document.body]).
    					attr('title','Maximize Step Explorer');
    			jQuery('span[id^="StepResizeSpan"]', 
    					[detailsDisplay.document.body]).
    					find("#StepResizeImage").attr("src",maxstep);
    			// change content style to fill page
    			jQuery('div[id^="stepsDetails"]', 
    					[detailsDisplay.document.body]).css('width',"100%");
    		}
    		if("Maximize Step Explorer" === title)
    		{
    			// increase div styles
    			jQuery('div[id^="stepsDetails"]', 
    					[detailsDisplay.document.body]).css('left','230px');
    			jQuery('div[id^="StepResize"]', 
    					[detailsDisplay.document.body]).css('left','230px');
    			
    			// change button styles
    			jQuery('span[id^="StepResizeSpan"]', 
    					[detailsDisplay.document.body]).
    					attr('title','Minimize Step Explorer');
    			jQuery('span[id^="StepResizeSpan"]', 
    					[detailsDisplay.document.body]).
    					find("#StepResizeImage").attr("src",minstep);
    			
    			// adjust content page WRT to details display
    			var len = detailsDisplay.window.innerWidth-230;
        		jQuery('div[id^="stepsDetails"]', 
    					[detailsDisplay.document.body]).css('width',len+"px");
    		}

    	}
    	catch(e)
        {
        	console.log("ERROE"+e);
        }
    }
    
    /***
     * @author ve4
     * @since 2014x
     * Initializes Steps page by setting style properties and cleanup!
     */
    function initSteps()
    {
    	try
        {
    		
    		// resize the steps details page to fit browser!
    		var detailsDisplay = sbFindFrame(getTopWindow(),"detailsDisplay");
    		
    		// add even to listen for changes in details dispay size
    		$(window).resize(function() {
    			resizeStepsDetails();
    			});
    		
    		var len = detailsDisplay.window.innerWidth-230;
    		jQuery('div[id^="stepsDetails"]', 
					[detailsDisplay.document.body]).css('width',len+"px");
    		
        }
        catch(e)
        {
        	//probably no selection. ignore.
        	console.log("ERROE"+e);
        }
    }
    
    /***
     * @author ve4
     * Resize steps content on browser/detailsDisplay changes
     */
    function resizeStepsDetails()
    {
    	try
        {
    		var detailsDisplay = sbFindFrame(getTopWindow(),"detailsDisplay");
    		var title = jQuery('span[id^="StepResizeSpan"]', 
 				   [detailsDisplay.document.body]).attr('title');
    		
    		// this alredy fits the page well. no resize.
    		if("Maximize Step Explorer" === title)
    			return;
    		
    		// resize the steps details page to fit browser!
    		var len = detailsDisplay.window.innerWidth-230;
    		jQuery('div[id^="stepsDetails"]', 
					[detailsDisplay.document.body]).css('width',len+"px");
    		
    		// remove old storage values! 
    		highLightStepRow(localStorage.getItem("stepSelected"));
    		
        }
        catch(e)
        {
        	//probably no selection. ignore.
        	console.log("ERROE"+e);
        }
    }
    
    
    /***
     * highlights selection in Steps Table
     * @param stepRow
     */
    function highLightStepRow(stepRow)
    {
    	try
        {
    		var steTR = sbFindFrame(getTopWindow(),"StepsTable");
    		var oldrow = localStorage.getItem("stepSelected");
    		
    		var selectedornot = jQuery('tr[id^="'+oldrow+'"]', 
			         [steTR.document.body]).attr("class");
    		
    		// remove previous selection
    		jQuery('tr[id^="'+oldrow+'"]', [steTR.document.body]).
            							removeClass("even mx_rowSelected");

    		
    		// find the row and highlight it by changing class attribute
    		jQuery('tr[id^="'+stepRow+'"]', [steTR.document.body]).
    		                          addClass("even mx_rowSelected");
    		
    		// remember current 
    		localStorage.setItem("stepSelected",stepRow);
    		
        }
        catch(e)
        {
        	//probably no selection. ignore.
        	console.log("ERROE"+e);
        }
    }
    

    // Finds a frame in a browser window of a specific name
    // Copied from function findFrame in emxUIConstants.js
    // Copied so that we don't have to ask the JSP that includes this
    // js file to also have to include emxUIConstants.js
    function sbFindFrame(objWindow, strName)
    {
        if (strName == "_top") return getTopWindow();
        else if (strName == "_self") return self;
        else if (strName == "_parent") return parent;
        else
        {
            try
            {
                for (var i=0; i<objWindow.frames.length; i++)
                {
                      if (objWindow.frames[i].name == strName)
                          return objWindow.frames[i];
                }

                for (var i=0; i<objWindow.frames.length; i++)
                {
                    var objFrame = 
                        sbFindFrame(objWindow.frames[i], strName);
                    if ( objFrame != null ) return objFrame;
                }
            }
            catch(e)
            {
                if(e.description.search(/Denied/i) == -1)
                {
                    alert(e.description);
                }
            }
        }
        return null;
    }


    // Finds the specified frame, and verifies that it is a 
    // structure browser frame.
    function findSBFrame(objWindow, strName)
    {
        var sbFrame = sbFindFrame(objWindow, strName);
        if ( sbFrame != null )
        {
            // Verify this is a structure browser
            if ( sbFrame.emxEditableTable )
            {
                return sbFrame;
            }
        }
        return null;
    }


    // Wrapper function to add one or more entities to an existing 
    // entity in a structure browser.  This function finds the structure
    // browser frame and then calls a special SB function to add the 
    // entities.
    // rowId = SB row id to add to = relId|objId|parentId|rowId
    // sXML = SB defined XML string that defines the rows to add
    //        (see dev guide for formatting)
    // closeTop - True/False - Does this function close the top window?
    // refreshFrame - the frame that contains the structure browser.
    function sbAddToSelected(rowId, sXML, closeTop, refreshFrame)
    {
        if ( ! refreshFrame )
            refreshFrame = "detailsDisplay";
            
        // Find structure browser frame
        var topFrame = getTopWindow();
        if ( getTopWindow().getWindowOpener() )
            topFrame = getTopWindow().getWindowOpener().getTopWindow();

        var frame = findSBFrame(topFrame, refreshFrame);

        if ( frame != null )
        {
            var checkedBoxes = frame.getCheckedCheckboxes();

            // Uncheck checked boxes.
            frame.clearAllCheckedItems();

            // Check correct checkbox.
            frame.FreezePaneregister(rowId);

            // Add entity    
            frame.emxEditableTable.addToSelected(sXML);

            frame.FreezePaneunregister(rowId);
            for (var checkedRowId in checkedBoxes)
            {
                frame.FreezePaneregister(checkedRowId);
            }
            // addToSelected() does a rebuildView(), thus changing
            // the displayed checked boxes. So need to rebuildView()
            // again to show the correct checked boxes.
            frame.rebuildView();
        }

        if ( closeTop && getTopWindow().getWindowOpener() )
            getTopWindow().closeWindow();
    }


    // After calling sbAddToSelected(), calls refreshRows().
    function sbAddToSelectedWithRefresh(rowId, sXML, closeTop, refreshFrame)
    {
        if ( ! refreshFrame )
            refreshFrame = "detailsDisplay";
            
        // Find structure browser frame
        var topFrame = getTopWindow();
        if ( getTopWindow().getWindowOpener() )
            topFrame = getTopWindow().getWindowOpener().getTopWindow();

        var frame = findSBFrame(topFrame, refreshFrame);

        if ( frame != null )
        {
            sbAddToSelected(rowId, sXML, false, refreshFrame);
            frame.refreshRows();
        }

        if ( closeTop && getTopWindow().getWindowOpener() )
            getTopWindow().closeWindow();;
    }
    
 // Wrapper function to add one or more entities to an existing
    // entity in a structure browser. This function finds the structure
    // browser frame and then calls a special SB function to add the
    // entities.
   // parentIds = Array of SB row ids to add to= relId|objId|parentId|rowId

    // sXML = SB defined XML string that defines the rows to add
    // (see dev guide for formatting)
    // closeTop - True/False - Does this function close the top window?
   // refreshFrame - the frame that contains the 142 structure browser.
   function sbAddToSelectedMultipleRows(parentIds, sXML, closeTop, refreshFrame)
    {
	   if ( ! refreshFrame )
		   refreshFrame = "detailsDisplay";
	   		var topFrame = getTopWindow();
	   if ( getTopWindow().getWindowOpener() )
		   topFrame = getTopWindow().getWindowOpener().getTopWindow();

    var frame = findSBFrame(topFrame, refreshFrame);
    if ( frame != null )
    {
    	var checkedBoxes = frame.getCheckedCheckboxes();
    	// Uncheck checked boxes.
    	frame.clearAllCheckedItems();
    	for(var i=0;i<parentIds.length;i++){
    		frame.FreezePaneregister(parentIds[i]);
    }
    	
    frame.emxEditableTable.addToSelected(sXML);
    	
    for(var i=0;i<parentIds.length;i++){
    	frame.FreezePaneunregister(parentIds[i]);
    }
   
    for (var checkedRowId in checkedBoxes)
    {
    	frame.FreezePaneregister(checkedRowId);
    }
    
    frame.rebuildView();
    frame.refreshRows();
    }
    if ( closeTop && getTopWindow().getWindowOpener() )
    	getTopWindow().closeWindow();;
    }


    // Wrapper function to uncheck entities in a structure browser.
    // Used to unselect entities that cannot be deleted
    // rowId = SB row id = relId|objId|parentId|0,0
    // rebuildView = true/false - tells SB to rebuild itself
    // lookupFrame will be null or contain the name of a frame to find
    function sbUncheckRow(rowId, rebuildView, lookupFrame)
    {
        // Find structure browser frame
        var frame = null;
        if (lookupFrame == null)
            lookupFrame = "detailsDisplay";
        if ( getTopWindow().getWindowOpener() )
            frame = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),lookupFrame);
        else
            frame = sbFindFrame(getTopWindow(),lookupFrame);

        if ( frame != null )
        {
            frame.FreezePaneunregister(rowId);

            if ( rebuildView )
                frame.rebuildView();
        }
    }


    // The default timeout for sbExpandItems
    var DEFAULT_TIMEOUT = 250;

    // The default number of retries for sbExpandItems
    var DEFAULT_NUMBER_OF_RETRIES = 20;


    // ---
    // Expands the elements in the structure browser based on the
    // specified list of Object IDs
    //
    // lineageOids - A comma-delimited list of OIDs or an array of OIDs
    //   (in order from top of tree down) to expand.
    // frame - The frame in which the toggle() function lives.  If
    //   unspecified this.frames[1] will be used.
    // selectLastObject - If not set to false or 'false', causes the
    //   expand to select the last item in the list by clicking on
    //   its link.
    // timeout - The timeout in milliseconds to wait before retrying a
    //   failed expand.  If unspecified the DEFAULT_TIMEOUT will be
    //   used.
    // numberOfRetries - The number of times to attempt to expand each
    //   level of the tree before giving up.  If unspecified the
    //   DEFAULT_NUMBER_OF_RETRIES will be used.
    // callbackFnRef - Reference to function that serves as callback
    //   (on successful termination of invocation).  All arguments
    //   that come after this argument will be passed back to the
    //   callback function.
    var CALLBACK_IND = 6;
    var FIRST_CALLBACK_ARG_IND = CALLBACK_IND + 1;
    function sbExpandItems(lineageOids, frame, selectLastObject, expandLastObject,
                           timeout, numberOfRetries, callbackFnRef)
    {
        // nothing to expand
        if (lineageOids == null)
        {
            return;
        }

        var oids;

        // allow array of OIDs
        if (lineageOids instanceof Array)
        {
            oids = lineageOids;
        }
        // split strings on comma
        else
        {
            oids = lineageOids.split(',');
        }

        // remove all trailing blank oids
        while (oids.length > 0 &&
               (oids[oids.length - 1] == null ||
                oids[oids.length - 1] == ''))
        {
            if (selectLastObject == null)
            {
                // assume we don't want to select last item
                selectLastObject = false;
            }

            if (expandLastObject == null)
            {
                // assume we do want to expand last item
                expandLastObject = true;
            }

            oids.pop();
        }

        // use default frame if unspecified
        if (frame == null)
        {
            frame = this.frames[1];
        }

        // select last item in list by default
        if (selectLastObject == null)
        {
            selectLastObject = true;
        }

        // do not expand last item in list by default
        if (expandLastObject == null)
        {
            expandLastObject = false;
        }

        // use default timeout if unspecified
        if (timeout == null)
        {
            timeout = DEFAULT_TIMEOUT;
        }

        // use default number of retries if unspecified
        if (numberOfRetries == null)
        {
            numberOfRetries = DEFAULT_NUMBER_OF_RETRIES;
        }

        var callback;
        var callbackArguments;
        if (callbackFnRef != null)
        {
            callback = callbackFnRef;
            callbackArguments = new Array();
            
            var numArgs = arguments.length - FIRST_CALLBACK_ARG_IND;
            for (var i = 0; i < numArgs; ++i)
            {
                callbackArguments[i] =
                    arguments[i + FIRST_CALLBACK_ARG_IND];
            }
        }
        else
        {
            callback = null;
            callbackArguments = null;
        }

        // expand the tree
        expandTreeAfterTimeout(oids, 0, frame, frame.document, selectLastObject, expandLastObject,
                               timeout, numberOfRetries, numberOfRetries,
                               callback, callbackArguments);
    }


    // ---
    // Helper function for sbExpandItems.
    //
    // Convenience function that calls expandTree after the specified
    // delay time.
    function expandTreeAfterTimeout(oids, oidInd, frame, parentNode, selectLastObject, expandLastObject,
                                    timeout, totalRetries, retriesLeft,
                                    callback, callbackArguments)
    {
        setTimeout(
            function()
            {
                try
                {
                    expandTree(oids, oidInd, frame, parentNode, selectLastObject, expandLastObject,
                               timeout, totalRetries, retriesLeft,
                               callback, callbackArguments);
                }
                catch (ignore)
                {
                    // If the frame goes away (e.g. user clicks the
                    // Search tab) before expand is done we will get
                    // an error.  In this case we need to eat the
                    // error and quit trying to expand.
                }
            },
            timeout);
    }


    // ---
    // Helper function for sbExpandItems.
    //
    // Recursively expands the SB tree nodes with the specified OIDs.
    function expandTree(oids, oidInd, frame, parentNode, selectLastObject, expandLastObject,
                        timeout, totalRetries, retriesLeft,
                        callback, callbackArguments)
    {
        // check for the SB progress popup
        if (isProgressTurnedOn())
        {
            // if it's up try again but don't count it as a retry
            expandTreeAfterTimeout(oids, oidInd, frame, parentNode, selectLastObject, expandLastObject,
                                   timeout, totalRetries, retriesLeft,
                                   callback, callbackArguments);
            return;
        }

        // get the object ID
        var objectId = oids[oidInd];

        if (objectId == null || objectId.length == 0)
        {
            // no last item => just quit
            return;
        }

        // look for the div for this OID
        var objectDiv = getObjectDiv(frame.document, objectId);

        // div not found
        if (objectDiv == null)
        {
            // got retries?
            if (retriesLeft != 0)
            {
                // try it again with one fewer retry left
                expandTreeAfterTimeout(oids, oidInd, frame, parentNode, selectLastObject, expandLastObject,
                                       timeout, totalRetries, retriesLeft - 1,
                                       callback, callbackArguments);
            }
            else if (oidInd != 0)
            {
                // out of retries => call again with the last successful OID
                // NOTE: This will cause the select last and expand last
                // functionality to take effect on the last OID found
                expandTreeAfterTimeout(new Array(oids[oidInd - 1]), 0, frame, parentNode, selectLastObject, expandLastObject,
                                       0, 0, 0,
                                       callback, callbackArguments);
            }

            // bail out of this invocation
            return;
        }

        // don't expand the last OID in the list
        // (this is supposed to be the guy to select)
        var isLastOid = (oidInd == oids.length - 1);

        // search for the toggle id for the object
        var toggleId = getToggleId(objectDiv);

        if (!isLastOid ||
            expandLastObject == true ||
            (expandLastObject.toLowerCase &&
             expandLastObject.toLowerCase() == 'true'))
        {
            var image = frame.document.getElementById('img_' + toggleId);
            if (image != null)
            {
                if (image.src.indexOf('images/utilTreeLineNodeOpenSB.gif') != -1)
                {
                    // already expanded => do nothing
                }
                else //if (image.src.indexOf('images/utilTreeLineNodeClosedSB.gif') != -1)
                {
                    // success => toggle the tree node
                    frame.toggle(toggleId);
                }
            }
        }

        if (!isLastOid)
        {
            // move on to the next OID in the list
            expandTreeAfterTimeout(oids, oidInd + 1, frame, objectDiv, selectLastObject, expandLastObject,
                                   timeout, totalRetries, totalRetries,
                                   callback, callbackArguments);
        }
        else
        {
            // check for indicator to not click link
            if (selectLastObject != false &&
                (selectLastObject.toLowerCase == null || selectLastObject.toLowerCase() != 'false'))
            {
                var objectLink = getObjectLink(objectDiv);

                if (objectLink != null)
                {
                    // last item => click the link
                    objectLink.onclick();
                }
            }

            // if there is a callback call it now
            if (callback != null)
            {
                // make sure we have an arguments array
                if (callbackArguments == null)
                {
                    callbackArguments = new Array();
                }

                // add relation ID
                callbackArguments[callbackArguments.length] =
                    getRelationId(objectDiv);

                // add object ID
                callbackArguments[callbackArguments.length] = objectId;

                // add parent OID
                callbackArguments[callbackArguments.length] =
                    getObjectId(parentNode);

                // add UI toggle ID
                callbackArguments[callbackArguments.length] =
                    getToggleId(objectDiv);

                // make the callback
                callback.apply(null, callbackArguments);
            }
        }
    }


    // ---
    // Checks to see if the M1 SB progress popup is displayed.
    // Returns true if displayed and false if not.
    function isProgressTurnedOn()
    {
        var progressDiv = parent.frames[0].document.
               getElementById('imgProgressDiv');

        if (progressDiv != null)
        {
            return progressDic.style.visibility == 'visible';
        }

        return false;
    }


    // ---
    // Returns the toggle ID for the object specified by object ID
    function getToggleId(objectDiv)
    {
        // if found return the id (this will be the toggle ID)
        if (objectDiv != null && objectDiv.id != null)
        {
            return objectDiv.id;
        }

        // if not found return null
        return null;
    }


    // ---
    // Returns the anchor for the specified OID
    function getObjectLink(node)
    {
        return getNodeByNameAndObjectId(node, 'a', getObjectId(node));
    }


    // ---
    // Returns the DIV for the specified OID
    function getObjectDiv(node, objectId)
    {
        // is this a DIV?
        return getNodeByNameAndObjectId(node, 'div', objectId);
    }


    // ---
    // Returns the node with specified node name for the specified OID
    function getNodeByNameAndObjectId(node, elementName, objectId)
    {
        // is this a node with the correct name?
        if ((elementName == null && node.nodeName == null) ||
            (node.nodeName != null && node.nodeName.toLowerCase() == elementName))
        {
            // look for an OID in the node
            var nodeObjectId = getObjectId(node);

            // if the OID matches, this is the correct node
            if (nodeObjectId == objectId)
            {
                return node;
            }
        }

        // get the children
        var children = node.childNodes;

        // count the children
        var numChildren = (children != null) ? children.length : 0;

        // iterate over the children
        for (var i = 0; i < numChildren; ++i)
        {
            // search under this child for the DIV
            var div = getNodeByNameAndObjectId(
                children[i], elementName, objectId);

            // if found return it
            if (div != null)
            {
                return div;
            }
        }

        // not found under the specified node
        return null;
    }


    // ---
    // Return returns the OID from the specified object DIV
    function getObjectId(node)
    {
        // look for an OID in the node
        var nodeObjectId;

        if (node.o != null)
        {
            nodeObjectId = node.o;
        }
        else if (node.getAttribute != null)
        {
            nodeObjectId = node.getAttribute('o');
        }
        else
        {
            nodeObjectId = null;
        }

        return nodeObjectId;
    }


    // ---
    //
    function getRelationId(node)
    {
        // look for an OID in the node
        var nodeRelationId;

        if (node.r != null)
        {
            nodeRelationId = node.r;
        }
        else if (node.getAttribute != null)
        {
            nodeRelationId = node.getAttribute('r');
        }
        else
        {
            nodeRelationId = null;
        }

        return nodeRelationId;
    }


    // The following code opens the home page browse tab to 
    // show the newly instantiated entity.  There are 3 places 
    // to instantiate an entity, in the browse tab itself, in
    // the search tab or in the global search results page.
    // If the user is not on the home page, then the home page
    // is opened to the browse tab.  If in the search tab, then
    // just the TOC is updated (so the whole page doesn't 
    // flash).  If in the browse tab, then we must open the
    // browse tab to the default folder and then do an
    // addToSelected call.  This takes care of adding the
    // new entity to the structure browser whether or not the
    // default folder is visible and/or if it has previously
    // been opened.
    function openInHomePage(objectId)
    {
        // href when SLM home page is not shown    
        var hrefPage = "../simulationcentral/smaHomeFS.jsp" + 
                       "?objectId=" + objectId +
                       "&suiteKey=SimulationCentral";

        // href when browse tab is not shown (search tab is open)
        // Or when copying, revising or save as template when user
        // does not have write access to parent folder
        var hrefTOC = "../simulationcentral/smaHomeTOCFS.jsp" + 
                       "?objectId=" + objectId +
                       "&suiteKey=SimulationCentral";
        
        // Find TOCContent frame, if not found then we're not on
        // the home page.
        // Used if instantiating from search page (or popup window)
        var frameTOCContent = null;
        if ( getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow() && getTopWindow().getWindowOpener().getTopWindow().getWindowOpener() )
            frameTOCContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOCContent");
        
        // Normal instantiation 
        if ( frameTOCContent == null && getTopWindow().getWindowOpener() )
            frameTOCContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOCContent");
            
        if ( frameTOCContent == null )
            frameTOCContent = sbFindFrame(getTopWindow(), "smaHomeTOCContent");
            
        if ( frameTOCContent != null )
        {
            // Determine if the browse tab is not opened, if so
            // then we need to just reload the TOC frame
                
//          BECAUSE emxTableEditProcess (which calls this file
//          via a jsp:include statement) BLINDLY DOES A PAGE
//          RELOAD, WE CAN'T BE FANCY AND USE THE NIFTY FUCNTION
//          THAT USES THE CURRENT FRAME AND JUST TOGGLES THE 
//          PLUS/MINUS TOGGLES TO OPEN THE NEW ENTITY.  BUMMER!!!
//          THIS IS WHY THE FOLLOWING IF STATEMENT IS COMMENTED
//          if ( frameTOCContent.document.location.href.indexOf("emxIndentedTable.jsp") == -1 )
//          {
                    var frameTOC = null;
                    if ( getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow() && getTopWindow().getWindowOpener().getTopWindow().getWindowOpener() )
                        frameTOC = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOC");
            
                    // Normal instantiation 
                    if ( frameTOC == null && getTopWindow().getWindowOpener() )
                        frameTOC = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOC");
                
                    if ( frameTOC == null )
                        frameTOC = sbFindFrame(getTopWindow(), "smaHomeTOC");
                
                    frameTOC.document.location.href = hrefTOC;
//          }
//                
//          // If we get here, then the browse tab is being
//          // displayed.  We need to open the tab to the default
//          // folder and then add the new entity to the structure
//          // browser at that point.
//          KEEP THIS AROUND UNTIL AFTER M1 CHANGES 
//          emxTableEditProcess.jsp TO CHECK A URL PARAMETER
//          TO SEE HOW TO REFRESH THE PAGE INSTEAD OF JUST
//          RELOADING IT.
//          else
//          {
//                    var frameListHidden = findFrame(frameTOCContent, "listHidden");
//                    if ( frameListHidden != null )
//                        frameListHidden.location.href = "../simulationcentral/smaHomeOpenInBrowseTab.jsp?objectId=<%=objectId%>&relId=<%=relId %>";
//          }
        }
        else
        {
             // Used if instantiating from search page
            var frameContent = null;
            if ( getTopWindow().getWindowOpener().getTopWindow().getWindowOpener() )
                frameContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow(), "content");
         
            // Normal instantiation 
            if ( frameContent == null && getTopWindow().getWindowOpener() )
                frameContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");

             // Should never get here but if the above doesn't work...
            if ( frameContent == null )
                frameContent = sbFindFrame(getTopWindow(), "content");

            frameContent.document.location.href = hrefPage;
        }
    }

