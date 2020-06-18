<%-- @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. --%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%-- @quickreview LX6      15:04:03 : IR-362439-3DEXPERIENCER2016x Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement. --%>

<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
    // check if change has been submitted or just refresh mode
    // Get language
    String prefStructureDisplay = emxGetParameter(request, "prefStructureDisplay");
	String selectedSpecListFilter = emxGetParameter(request, "selectedSpecListFilter");
	String selectedReqListFilter = emxGetParameter(request, "selectedReqListFilter");
	String selectedSpecFilter = emxGetParameter(request, "selectedSpecFilter");
	String selectedReqFilter = emxGetParameter(request, "selectedReqFilter");
	String selectedSpecTable = emxGetParameter(request, "selectedSpecTable");
	String selectedReqTable = emxGetParameter(request, "selectedReqTable");
	String selectedExpandFilter = emxGetParameter(request, "emxExpandFilter");
	String expandSubrequirements = emxGetParameter(request, "SubRequirements");
	String expandTestCases = emxGetParameter(request, "TestCases");
	String expandParameters = emxGetParameter(request, "Parameters");
	
	String ExpandTypes="none";
	boolean isSpecStructureDisplayChanged = false;
		if(prefStructureDisplay == null)
        {
			prefStructureDisplay="";
        }
		if(selectedSpecListFilter == null)
	    {
			selectedSpecListFilter="";
	    }
		if(selectedReqListFilter == null)
	    {
			selectedReqListFilter="";
	    }
		if(selectedSpecFilter == null)
	    {
			selectedSpecFilter="";
	    }
		if(selectedReqFilter == null)
	    {
			selectedReqFilter="";
	    }
		if(selectedSpecTable == null)
	    {
			selectedSpecTable="";
	    }
		if(selectedReqTable == null)
	    {
			selectedReqTable="";
	    }
		if(selectedExpandFilter == null)
	    {
			selectedExpandFilter="All";
	    }
		if(expandSubrequirements!=null){
			ExpandTypes = expandSubrequirements;
		}
		if(expandTestCases!=null){
			if(ExpandTypes.equalsIgnoreCase("none")){
				ExpandTypes = expandTestCases;
			}else{
				ExpandTypes += ","+expandTestCases;
			}
		}
		if(expandParameters!=null){
			if(ExpandTypes.equalsIgnoreCase("none")){
				ExpandTypes = expandParameters;
			}else{
				ExpandTypes += ","+expandParameters;
			}
		}
	
    // if change has been submitted then process the change
        try
        {
            ContextUtil.startTransaction(context, true);
            if(RequirementsUtil.isSCEUsed(context, new String[]{})){
	            if(prefStructureDisplay !=null)
	            {
	            	String structuredisplay = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_StructureDisplay"); //PersonUtil.getRuleDisplay(context);
	            	if(!prefStructureDisplay.equalsIgnoreCase(structuredisplay)){
	            		isSpecStructureDisplayChanged=true;
	            	}           	            	
	            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_StructureDisplay", prefStructureDisplay.trim());
	            }
            }
            if(selectedSpecListFilter !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultSpecListFilter", selectedSpecListFilter.trim());
            }
            if(selectedReqListFilter !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqListFilter", selectedReqListFilter.trim());
            }
            if(selectedSpecTable !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultSpecTable", selectedSpecTable.trim());
            }
            if(selectedReqTable !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqTable", selectedReqTable.trim());
            }
            if(selectedExpandFilter !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandFilter", selectedExpandFilter.trim());
            }
            if(ExpandTypes !=null)
            {
            	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandTypes", ExpandTypes.trim());
            }
         
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("prefStructureDisplay:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
%>

<script type="text/javascript" language="javascript">
//START : LX6 IR-362439-3DEXPERIENCER2016x Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement
getTopWindow().getWindowOpener().preferencesModified = true;
getTopWindow().getWindowOpener().expandFilterTypes = "<%=ExpandTypes%>";
getTopWindow().getWindowOpener().RMTExpandFilter = "<%=selectedExpandFilter%>";
if(getTopWindow().getWindowOpener().setRequestSetting!=null){
	getTopWindow().getWindowOpener().setRequestSetting("RMTCustomTypes","<%=ExpandTypes%>");	
}
//END : LX6 IR-362439-3DEXPERIENCER2016x Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement
function findFrame(objWindow, strName) {
	  var objFrame = objWindow.frames[strName];
	  if (!objFrame) {
	    for (var i=0; i < objWindow.frames.length && !objFrame; i++)
	      objFrame = findFrame(objWindow.frames[i], strName);
	  }
	  
	  return objFrame;
	}
        if(<%=isSpecStructureDisplayChanged%>==true){
	  //KIE1 ZUD TSK447636 
        	var frame = findFrame(getTopWindow().getWindowOpener(), "detailsDisplay");
        	if(frame!=null){
	        	var arguments = frame.location.href.split("&");
	        	var id = null;
	        	var menu=null;
	        	var suiteKey=null;
	        	for(var i=0;i<arguments.length;i++){
					if(arguments[i].indexOf("objectId")>=0){
						id = arguments[i].split("=")[1];
					}        
					 if(arguments[i].indexOf("menu")>=0){
						menu = arguments[i].split("=")[1];
					}     
					if(arguments[i].indexOf("suiteKey")>=0){
						suiteKey = arguments[i].split("=")[1];
					}    
	        	}
	        	if(suiteKey=="Requirements"&id!=null&&(frame.location.href.indexOf("emxIndentedTable.jsp")>=0||frame.location.href.indexOf("RichTextEditorLayout.jsp")>=0)){
	            	var href = null;
	            	if(frame.location.href.indexOf("common/emxIndentedTable.jsp")>=0){
	            		href = frame.location.href.replace("common/emxIndentedTable.jsp", "requirements/StructureDisplay.jsp").split("?")[0];
	            	}else{
	            		href = frame.location.href.replace("requirements/RichTextEditorLayout.jsp", "requirements/StructureDisplay.jsp").split("?")[0];
	            	}
	            	href+="?objectId="+id+"&suiteKey="+suiteKey+"&StringResourceFileId=emxRequirementsStringResource&emxSuiteDirectory=requirements&SuiteDirectory=requirements";
	            	href+="&menu="+menu;
	            	frame.location.href = href;
	        	}
        	}
        	
        	//update detailsDisplay
        	//update parent window
        }
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

