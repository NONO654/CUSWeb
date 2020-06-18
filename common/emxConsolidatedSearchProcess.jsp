
<%-- emxConsolidatedSearchProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxConsolidatedSearchProcess.jsp.rca 1.5.3.2 Wed Oct 22 15:48:25 2008 przemek Experimental przemek $
--%>
                 
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<%@include file = "emxUIConstantsInclude.inc"%>
</head>

<body>

<%

	//get request parameters
	String txtTypeActual   = emxGetParameter(request,"txtTypeActual");
	String containedInFlag = emxGetParameter(request, "containedInFlag");
	if (containedInFlag==null|| "null".equals(containedInFlag)||"".equals(containedInFlag))
	{
	    containedInFlag="true";
	}
	boolean blnSearch = true;
	//txtTypeActual.length() has to be less than 256 to store in PersonUtil
	if(txtTypeActual != null && !"".equals(txtTypeActual) && !"null".equals(txtTypeActual) && txtTypeActual.length() < 256)
	{
	    //save the last searched types from general search
	    try 
	    {
	        ContextUtil.startTransaction(context, true);
	        if("true".equals(containedInFlag)) {
	           PersonUtil.setLastContainedInSearchedTypePreference(context, txtTypeActual);
	        }else {
	            PersonUtil.setLastSearchedTypePreference(context, txtTypeActual);
	        }
	        ContextUtil.commitTransaction(context);
	
	    }
	    catch(Exception ex)
	    {
	        blnSearch = false;
	        ContextUtil.abortTransaction(context);
	        if(ex.toString() != null && (ex.toString().trim()).length()>0)
	        {
	            emxNavErrorObject.addMessage("emxSearch:" + ex.toString().trim());
	        }
	        
	    } finally {
	    	ContextUtil.commitTransaction(context);
	    }
	}


	 StringBuffer  buff = new StringBuffer();	
	 buff.append("&table="+XSSUtil.encodeForURL(context, emxGetParameter(request, "table")));
	 buff.append("&program="+XSSUtil.encodeForURL(context, emxGetParameter(request, "program"))); 
	 buff.append("&sortColumnName= ");
	 buff.append("&selection= ");
	 buff.append("&toolbar= ");
	 buff.append("&expandProgram= ");	
%>
<script language="JavaScript" type="text/javascript">	
	
	var searchResults = findFrame(getTopWindow(),"searchResults");
    var selectedIds   = "";    
      	 
    if(getTopWindow().retainedSearch)    {
        var selects = getTopWindow().retainedSearch.getSelectedOIDs();       
        selectedIds = selects;
        getTopWindow().retainedSearch.clear();         	
    }    
	
	var appendparam = parent.pageControl.getValuePair();
	//XSSOK
	var totalURL = "../common/emxIndentedTable.jsp?" + appendparam + "&" + "<%=buff.toString()%>" ;			
	
	if(searchResults){				
		getTopWindow().submitSearch(totalURL,selectedIds);
		getTopWindow().consolidatedSearch.showResults();
		getTopWindow().turnOnProgressTop();			
	} 
</script> 

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

