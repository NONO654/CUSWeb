
<%--  MultiObjectSelect.jsp  

Intermediate JSP to update the ContainedInSpecification field by the object name of the selected SpecificationObject

--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview KIE1 ZUD 17:06:30 : IR-476057-3DEXPERIENCER2018x - R419-STP:On traceabiliy window "Add Target Specification" search is KO.
     @quickreview KIE1 ZUD 17:06:30 : IR-510444-3DEXPERIENCER2018x - R419-STP: Replacing Requirement added as Candidate requirement of Model Or Product KO.
--%>
<!-- Include directives -->
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<!-- Page directives -->
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page
	import="com.matrixone.apps.domain.util.i18nNow,com.matrixone.apps.domain.util.FrameworkUtil,matrix.util.StringList"%>
	<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="indentedTableBean"
	class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<%
try
{
	// ++KIE1 changed to get parameter values
	String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
	String[] strFrameName = emxGetParameterValues(request, "frameName");
	String[] strFormName = emxGetParameterValues(request, "formName");
	String[] strFieldNameDisplay = emxGetParameterValues(request, "fieldNameDisplay");
	String[] strFieldNameActual = emxGetParameterValues(request, "fieldNameActual");
	String[] strShowRevision = emxGetParameterValues(request, "ShowRevision");
	String[] strMode = emxGetParameterValues(request, "mode");
	// --KIE1 changed to get parameter values
	
	String strTableRowId = "";
	String strObjname = "";
	String strfinalObjectNames = "";
	String strfinalObjectid = "";
	
	String languageStr = request.getHeader("Accept-Language");
	
	// To check whether only Requirement & Specification is selected or not
	
	if ((emxTableRowId == null) || (emxTableRowId.equals("null")) || (emxTableRowId.equals("")))
	{
		String strRetMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.PleaseSelectitem"); 
		throw new FrameworkException(strRetMsg);
	} else
	{
		String strObjectId = "";

		for (int i = 0; i < emxTableRowId.length; i++)
		{
			strTableRowId = emxTableRowId[i];
			StringList objectIdList = FrameworkUtil.split(strTableRowId, "|");
			if (objectIdList.size() == 3)
			{
				strTableRowId = (String) objectIdList.get(0);

			} else if(objectIdList.size() == 4)
			{
				strTableRowId = (String) objectIdList.get(1);
			}
			DomainObject domObj = new DomainObject(strTableRowId);
			Map objMap = new HashMap();
			StringList selectList = new StringList();
			selectList.addElement(DomainConstants.SELECT_TYPE);
			selectList.addElement(DomainConstants.SELECT_REVISION);
			objMap = domObj.getInfo(context, selectList);
			// Start:IR-027034V6R2011
			String thisType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
			String errorMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.error.RequirementOrChapter"); 
			
			if(strMode!= null && strMode[0].equals("forTraceability"))
				{
			 		if(thisType.equalsIgnoreCase("Comment") || thisType.equalsIgnoreCase("Requirement Specification"))
					{
					    throw new Exception(errorMsg);
					}
				}
			//End:IR-027034V6R2011
			if (((strShowRevision != null) && (!strShowRevision[0].equalsIgnoreCase("")) && !("null".equalsIgnoreCase(strShowRevision[0]))) && (strShowRevision[0].equalsIgnoreCase("true")))
			{
				//This is to get obj name & rev.
				strObjname = FrameworkUtil.getObjectNameWithRevision(context, strTableRowId);
			} else
			{
				//This has to be read from the bean method.
				strObjname = FrameworkUtil.getObjectName(context, strTableRowId);
			}
			if (!"".equals(strObjname) && !"null".equals(strObjname))
			{
				if ("".equals(strfinalObjectNames) || "null".equals(strfinalObjectNames))
				{
					strfinalObjectNames = strObjname;
					strfinalObjectid = strTableRowId;
				} else
				{
					strfinalObjectNames = strfinalObjectNames + "," + strObjname;
					strfinalObjectid = strfinalObjectid + "," + strTableRowId;
				}
			}
			if("emxTableRowId".equalsIgnoreCase(strFieldNameActual[0]))
			{
				strfinalObjectid = emxTableRowId[i];
			}
		}
	}

%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
function setAndRefresh() {
  var txtTypeDisplay;
  var txtTypeActual;
  var txtContainedInType;
  var txtContainedInRev;
    //KIE1 ZUD TSK447636 
  var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<xss:encodeForJavaScript><%=strFrameName[0]%></xss:encodeForJavaScript>");
  var specdiv = getTopWindow().getWindowOpener().document.getElementById("spec");
  
  if(targetFrame !=null){
	txtTypeDisplay=targetFrame.document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameDisplay[0]%></xss:encodeForJavaScript>;
	txtTypeActual=targetFrame.document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameActual[0]%></xss:encodeForJavaScript>;
  }else{
    //KIE1 ZUD TSK447636 
	var searchContentFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
	if(searchContentFrame !=null){
		txtTypeDisplay=searchContentFrame.document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameDisplay[0]%></xss:encodeForJavaScript>;
		txtTypeActual=searchContentFrame.document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameActual[0]%></xss:encodeForJavaScript>;
	} else {
	  //KIE1 ZUD TSK447636 
		txtTypeDisplay = getTopWindow().getWindowOpener().document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameDisplay[0]%></xss:encodeForJavaScript>;
		txtTypeActual = getTopWindow().getWindowOpener().document.<xss:encodeForJavaScript><%=strFormName[0]%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=strFieldNameActual[0]%></xss:encodeForJavaScript>;
   }
 }
 txtTypeDisplay.value = "<xss:encodeForJavaScript><%=strfinalObjectNames%></xss:encodeForJavaScript>";
 txtTypeActual.value = "<xss:encodeForJavaScript><%=strfinalObjectid%></xss:encodeForJavaScript>";
  var txtshowTypeDisplay = txtTypeDisplay.value;
  var fieldActualName = "<xss:encodeForJavaScript><%=strFieldNameActual[0]%></xss:encodeForJavaScript>";

  if(specdiv) //IR-026378V6R2011
  {
	  if(fieldActualName != null && fieldActualName == "baseline" && txtshowTypeDisplay.indexOf(",") > 1)
	  {
	  	specdiv.style.visibility="hidden";
	  }
	  else
	  {
	  	
		  specdiv.style.visibility="visible";
		  if(fieldActualName == "baseline"){
		    //KIE1 ZUD TSK447636 
			  getTopWindow().getWindowOpener().document.getElementsByName("chapreqId")[0].value = "";
			  getTopWindow().getWindowOpener().document.getElementsByName("chapreq")[0].value = "";  
		  }
		  
	  }
  }
    //KIE1 ZUD TSK447636 
 getTopWindow().closeWindow();
}
</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>
<%
} // End of try
catch (Exception ex)
{
	session.putValue("error.message", ex.getMessage());
} // End of catch

%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
