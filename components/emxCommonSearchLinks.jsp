<%-- emxCommonSearchLinks.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonSearchLinks.jsp.rca 1.11 Wed Oct 22 16:18:48 2008 przemek Experimental przemek $
--%>

<!-- The includes -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<!-- The page directives -->
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.common.Search"%>

<%
/* Modified by <Infosys> On <26th MAY 2003>
   For the following Bug
   <Proper display of Error Message when the operation fails>
   Fixed as Follows:
   <The corrresponding Errors are caught and added to Session>
*/
%>


<!-- The Declarations -->
<%!
private static final String TARGET_LOCATION = "\"searchPane\"";
private static final String COMMAND_LABEL = "COMMAND_LABEL";
private static final String COMMAND_HREF = "COMMAND_HREF";
private static final String MENU_COMMAND_LIST = "menuCommandList";

%>


<!-- The processing -->
<%
try
{
String strMode = emxGetParameter(request, Search.REQ_PARAM_MODE);
String strSuiteKey = emxGetParameter(request, Search.REQ_PARAM_SUITE_KEY);
String strCommandIndex = emxGetParameter(request, "commandIndex");
String I18NResourceBundle = "emxComponentsStringResource";

String strTabLabel = i18nNow.getI18nString("emxComponents."+strSuiteKey+".Search.Name",I18NResourceBundle,acceptLanguage);
List menuCommandList = (List)session.getAttribute(MENU_COMMAND_LIST);
session.removeAttribute(MENU_COMMAND_LIST);

String strAcceptLanguage = request.getHeader("Accept-Language");
%>



<script language="javascript">
  //**********************************************
  // Function to construct the menu object
  //**********************************************
  function buildNavBar() {
    //reference to object manager
    var objSP = getTopWindow().localSearchPane;
    objSP.displayFrame = self.name;
<%
  if(strMode.equalsIgnoreCase(Search.GLOBAL_SEARCH)){
%>
    objSP.addTab("<%=XSSUtil.encodeForJavaScript(context, strTabLabel)%>");
<%
  } else {
%>
    objSP.addTab();
<%
  }
%>

<%
	String menuStringResFileId = null;
	String strLabel = null;
	String subMenuSuite = null;
	String strLabelKey = null;
	String strCmdName = null;
	HashMap hmCommand = null;

  for (int i=0; i<menuCommandList.size(); i++) {
    Map map = (Map)menuCommandList.get(i);
    strLabelKey = (String)map.get(COMMAND_LABEL);
    strCmdName = (String)map.get("COMMAND_NAME");
	hmCommand = UICache.getCommand(context, strCmdName);
    subMenuSuite = UIToolbar.getSetting(hmCommand, "Registered Suite");

    if ( (subMenuSuite != null) && subMenuSuite.trim().length() > 0 )
	{
		menuStringResFileId = UINavigatorUtil.getStringResourceFileId(context, subMenuSuite.trim());
	}else
	{
		menuStringResFileId = "emxComponentsStringResource";
	}

	strLabel = i18nNow.getI18nString(strLabelKey, menuStringResFileId, acceptLanguage);
	if(strLabel == null || "".equals(strLabel))
	{
		strLabel = strLabelKey;
	}
    String strHRefTemp = (String)map.get(COMMAND_HREF);    
   
    //going through each param in the strHRefTemp to find and remove 
    //duplicate param name
    HashMap paramMap = new HashMap();
    int indexOfQuery    = strHRefTemp.indexOf("?");
    String sURL         = strHRefTemp.substring(0, indexOfQuery);
    String sParam       = strHRefTemp.substring(indexOfQuery+1);
    
    //new HRef with no duplicated param name
    StringBuffer strHRef = new StringBuffer(sURL);
    
    StringTokenizer paramToken = new StringTokenizer(sParam,"&");
    int index=0;
    int paramCount = 0;
    if(paramToken.countTokens() > 0)
    {
       strHRef.append("?");
    }
    
    while(paramToken.hasMoreTokens()) {
         String sParameter = (String)paramToken.nextToken();
         index = sParameter.indexOf("=");
         
         // get param name/value 
         if(index>0)
         {
            String paramName  = sParameter.substring(0,index);
            String paramValue = sParameter.substring(index+1);
            //only add a new param if it does not exist
            if(!paramMap.containsKey((String)paramName))
            {
               paramMap.put(paramName, paramValue);
               
               if(paramCount > 0)
               {
                  strHRef.append("&");
               }
            
               strHRef.append(XSSUtil.encodeForURL(context, paramName));
               strHRef.append("=");
               strHRef.append(XSSUtil.encodeForURL(context, paramValue));
               paramCount++;               
            }   
          
         }
    }
    
    //reset paramMap
    paramMap = null;
    
%>//XSSOK
objSP.tabs[0].addLink("<%=strLabel%>", "<%=strHRef.toString()%>", <%=TARGET_LOCATION%>);
<%
  }
%>
objSP.selectedID="0_<%=XSSUtil.encodeForJavaScript(context, strCommandIndex)%>";
    objSP.draw();
  }
</script>


<emxUtil:localize id="i18nId" bundle="<%=XSSUtil.encodeForHTML(context, FRAMEWORK_BUNDLE)%>"
        locale='<%=XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language"))%>'/>

<html>
  <body onload="buildNavBar()">
    <emxUtil:i18nScript localize="i18nId">emxNavigator.UIMenuBar.Loading</emxUtil:i18nScript>
  </body>
</html>

<%
} // End of try
catch(Exception ex) {
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
