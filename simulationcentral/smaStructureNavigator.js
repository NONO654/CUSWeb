//(c) Dassault Systemes, 2013
//@Vineeth Kumar KE
//Utility JS file for Structure Navigator


//This function calls emxUITreeUtil function to
//update the entire Structure Navigator
//It is crucial to pass  object id of the object being
//created/deleted and its parent id.

var lastobjectid = "";

function refreshDetailsTable(oid,pid)
{
	if( getTopWindow().getWindowOpener()!=null)
		 getTopWindow().getWindowOpener().getTopWindow().addStructureTreeNode
	(             oid,                       
			pid,
			"", 
			"teamcentral", 
			true, 
			undefined,
			true
	);
	else
		 getTopWindow().addStructureTreeNode
		(       oid,                       
				pid,
				"", 
				"teamcentral", 
				true, 
				undefined,
				true
		);
}


/***
 * used for updating the count of number of folder objects
 * @param oid
 * @param pid
 */
function updateFolderCount(oid,pid)
{

    if (  getTopWindow().getWindowOpener() )
        frame = findFrame( getTopWindow().getWindowOpener().getTopWindow(),"hiddenFrame");
    else
        frame = findFrame( getTopWindow(),"hiddenFrame");

    if ( frame != null )
    {
        var outstring = "../simulationcentral/smaCreateContentAction.jsp?objectId=" + oid
            outstring += "&parentId="+pid

        
        frame.location.href = outstring
    }
}

/***
 * only to be used for workspace creation refresh action!
 * @param oid
 * @param pid
 */
function refreshDetailsTableNav(oid,pid)
{
	root =  getTopWindow().objStructureTree.getCurrentRoot();
	pid  =  getTopWindow().objectID;
	getTopWindow().addStructureTreeNode
	(       oid,                       
			pid,
			"", 
			"teamcentral", 
			true, 
			undefined,
			true
	);

}

function deleteNode(oid)
{
	getTopWindow().getWindowOpener().getTopWindow().deleteStructureNode
	(             oid,                       
			true
	);
}


/***
 * 
 * @param oid object id
 * @param pid parent id
 * @param wid workspace id
 */
function openInNewUI(url,list)
{
	try
	{
		var ddFrame            = getAbsoluteTopforNav();

		if(url != "")
			setComposePageIfNeeded(ddFrame,url);

		var objectsToOpenArray = list.split(",");
		var noofObjects        = objectsToOpenArray.length;
		var timeout            = 1000;
		var retries            = 20;

		expandWithTimeOut(ddFrame,objectsToOpenArray,timeout,retries);
		

	}
	catch(err)
	{
		console.log();
	}
}

/***
 * Expand while setting timeout
 */
function expandWithTimeOut(ddFrame,objectsToOpenArray,timeout,retries)
{
	setTimeout(
			function()
			{
				try
				{
					expandTree(ddFrame,objectsToOpenArray,timeout,retries);
				}
				catch (ignore)
				{

				}
			},
			timeout);

}

/***
 * try expanding!
 * @param ddFrame
 * @param objectsToOpenArray
 * @param timeout
 * @param retries
 */
function expandTree(ddFrame,objectsToOpenArray,timeout,retries)
{
	try
	{
		thisNode = ddFrame.objStructureTree.findNodeByObjectID(objectsToOpenArray[0]);
		if(retries===0)
		{
			setLastNode(ddFrame,lastobjectid);
			return;
		}

		else if(objectsToOpenArray.length === 0)
		{
			setLastNode(ddFrame,lastobjectid);
			return;
		}

		else if(thisNode === null) 
		{
			expandWithTimeOut(ddFrame,objectsToOpenArray,timeout,retries-1)
		}
		else
		{
			thisNode.expand();
			if(objectsToOpenArray.length === 1)
			 lastobjectid = objectsToOpenArray[0];
			delete objectsToOpenArray[0];
			objectsToOpenArray.splice(0,1);
			expandWithTimeOut(ddFrame,objectsToOpenArray,timeout,retries-1)			  
		}
	}
	catch(error)
	{
		if(retries!==0)
		expandWithTimeOut(ddFrame,objectsToOpenArray,timeout,retries-1)	
	}
}

/***
 * Highlighting the object on structure tree and opening up details display
 * @param ddFrame
 * @param id
 */
function setLastNode(ddFrame,id)
{
	thisNode = ddFrame.objStructureTree.findNodeByObjectID(id);
	ddFrame.objStructureTree.setSelectedNode(thisNode,false);
	thisNode.handleClick('node');
}

/***
 * load compose landing page if necessary
 * @param ddFrame
 * @param url
 */
function isComposeLoaded(ddFrame)
{
	return false;
}


/***
 * load compose landing page if necessary
 * @param ddFrame
 * @param url
 */
function setComposePageIfNeeded(ddFrame,url)
{
	try
	{
		var contentF = findFrame(ddFrame,'content');
		if(isComposeLoaded(ddFrame) && (url != "" || url != null))
		{
			// already loaded in view.bail out
			return;
		}
		else
		{
			//else load it
			contentF.location.href = url;
			return;
		}
	}
	catch(err)
	{
		//else load it
		contentF.location.href = url;
	}
}


/***
 * load compose landing page in a hidden frame. also clean up DOM after loading
 * @param ddFrame
 * @param url
 */
function refreshInComposeFrame(composeURL,refreshComposeCallback)
{
	try
	{
      getTopWindow().jQuery("#pageContentDiv").append("<iframe id=\"composeHiddenFrame\" " +
      		"class=\"hidden-frame\" name=\"composeHiddenFrame\"></iframe>");
      getTopWindow().jQuery("#composeHiddenFrame").attr('src', composeURL);
      getTopWindow().jQuery("#composeHiddenFrame").load(
    		  "dummy",
    		  {composeURL:composeURL},
    		  function () {eval(refreshComposeCallback);});
      getTopWindow().jQuery("#composeHiddenFrame").remove();
	}
	catch(err)
	{
		alert(err);
	}
}

/***
 * Refresh a particular node in Structure Navigator
 * @param child
 * @param parent
 */
function refreshNode(child,parent)
{
	// VE4 
	// really need to come back to this.
	// I am reverting to smaUITree temporarily until I find 
	// a elegant solution to this "Refresh This" conundrum.
	var SMANavigatorTree = new smaUITree();
	if("null"===parent)
      SMANavigatorTree.refreshNodeNoSelect(child);
	else
	  SMANavigatorTree.refreshNode(child);
}

/***
 * returns pop up
 */
function handleDialog(url)
{
	var topWindow =  getTopWindow();
	if (topWindow.getWindowOpener() != null)
	{
		topWindow = topWindow.getWindowOpener().getTopWindow();
	}
	showModalDialog.apply(
			topWindow,
			[url,
			 '600',
			 '600',
			 true]);


}

/***
 * 
 * @returns Active Browser frame
 */
function getAbsoluteTopforNav()
{
	// start with the current window's top reference
	var curTop =  getTopWindow();

	// climb as long as this window has an opener
	while (curTop.getWindowOpener() != null)
	{
		// get the getWindowOpener()'s top
		curTop = curTop.getWindowOpener().getTopWindow();
	}

	// return the topmost window
	return curTop;
}


/***
 * Object literal to hold compose navigation options
 */
var composeNavOps = {

			
		 GoToDefault               : '../common/images/iconBigBookmark.gif'
		                            , 
							
		 openComposeShorcut        : function()
		                                {
			                               getTopWindow().showSlideInDialog
			                              ('../simulationcentral/smaShortCuts.jsp?');
		                                },
		                              
		 exitComposeShorcut        : function()
										{
			                               getTopWindow().closeSlideInDialog();
									    },	
		 initGoTo                  : function()
										{
											console.log("intialiazing facets...");
											getTopWindow().closeSlideInDialog();
											listHid = findFrame( getTopWindow(),'hiddenFrame');
											listHid.location.href= "../simulationcentral/smaHomeUtil.jsp?"+
											"objectAction=goToDefaultFolder";
										},
										
	     initGoToHome             : function()
										{
											console.log("intialiazing facets...");
											getTopWindow().closeSlideInDialog();
											listHid = findFrame(getTopWindow(),'hiddenFrame');
											listHid.location.href= "../simulationcentral/smaHomeUtil.jsp?"+
											"objectAction=goToHomeFolder";
										}									    
};


/***
 * Object literal to hold Compose Navigator Cut paste operations
 */
var composeCutPasteOps = {

		Simulation          : "SimulationActivity",
		paste               :  function(child,parent,container)
								{
						          // cut the child
			                      getTopWindow().objStructureTree.deleteObject(child);
						          // cut the parent
			                      getTopWindow().objStructureTree.deleteObject(parent);
						          //add parent to show the "+" icon
			                      getTopWindow().addStructureTreeNode
									      	(       parent,                       
									      			container,
									      			"", 
									      			"teamcentral", 
									      			true, 
									      			undefined,
									      			true
									      	);
						          // find parent node(after waiting for it to show up!)
						          // and then voila! show the connected object
						          waitandExpandParent(parent,250,20);
								},
		cut               :  function(child)
								{
								  alert("Paste now to complete the operation!");								  
								}

};
/***
 * Paste in Structure Navigator
 * @param child
 * @param parent
 * @param container
 */
function pasteInNav(child,parent,container)
{
	composeCutPasteOps.paste(child, parent,container);
}
/***
 * 
 * @param child
 * @param parent
 */
function cutInNav(child,parent)
{
	composeCutPasteOps.cut(child);
}
/***
 * Timeout starter which runs a sleeper function to wait for the 
 * expand of "pastee" to happen and show the "pasted" object
 * @param parentNode
 * @param timeout
 * @param retries
 */
function waitandExpandParent(parent,timeout,retries)
{
	setTimeout(
			function()
			{
				try
				{
					expandAfterPaste(parent,timeout,retries)
				}
				catch (ignore)
				{

				}
			},
			timeout);

}

function expandAfterPaste(parent,timeout,retries)
{
	try
	{
		if(retries === 0)
			return;
		else
		{
			parentNode = getTopWindow().objStructureTree.findNodeByObjectID(parent);
			parentNode.expand();
		}

	}
	catch (e) {
		// this means the parent node isn't there yet!!!
		//try again :S
		waitandExpandParent(parent,timeout,retries-1)
	}

}


function initComposeShorCut()
{
	composeNavOps.openComposeShorcut();
}

function exitComposeShorCut()
{
	composeNavOps.exitComposeShorcut();
}

function goToDefault()
{
	composeNavOps.initGoTo();
}

function goToHome()
{
	composeNavOps.initGoToHome();
}
