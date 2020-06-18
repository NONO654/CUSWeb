	//-----------------------------------------------------------------
	//Function updateCountAndRefreshTreeLBC()
	//-----------------------------------------------------------------
	//
	//DESCRIPTION
	//	    This function updates All Parent object labels and refreshes the trees
	//
	//PARAMETERS
	//	    appDirectory (String)   - The appDirectory e.g.documentCentral
	//	    openerObj (String)      - the opener object from where current operation is performed
	//	    parentOIDs (String)     - The parent OID of the objects to be modified
	//RETURNS
	//	    (nothing)
	//-----------------------------------------------------------------
	//Changes done by PSA11 start(IR-506906-3DEXPERIENCER2018x)
	function updateCountAndRefreshTreeLBC(appDirectory,openerObj,parentOIDs)
	{
		updateCount(appDirectory,openerObj,parentOIDs);
		refreshTreeLBC();
	}
	
	/*
	 * This function is written separately, it consist the logic of updating all parent object labels 
	 * */
	function updateCount(appDirectory,openerObj,parentOIDs){
		var objectIds = getObjectsToBeModified(openerObj,parentOIDs);
		  var objectIdArray = Object.keys(objectIds);
		  for (var i = objectIdArray.length-1; i >= 0; i--) {
			  var updatedLabel = getUpdatedLabel(appDirectory,objectIdArray[i],openerObj);
			  
			  openerObj.changeObjectLabelInTree(objectIdArray[i], updatedLabel, true, false, false);
		  }
	}
	
	/*
	 * function refreshTreeLBC()
	 * This function refreshes the trees
	 * */
	function refreshTreeLBC(){
		try{
		  	if(getTopWindow().getWindowOpener()){
		  		var refreshFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
		  	}
		  	else{
		  		var refreshFrame = findFrame(getTopWindow(), "detailsDisplay");
		  	}
			  var refreshURL = refreshFrame.location.href;
			  refreshURL = refreshURL.replace("persist=true","persist=false");
			  refreshFrame.location.href = refreshURL;		  
		  } catch(e){
			  var refreshURL = getTopWindow().getWindowOpener().location.href;
			  refreshURL = refreshURL.replace("persist=true","persist=false");
			  getTopWindow().getWindowOpener().location.href = refreshURL;
		  }
	}
