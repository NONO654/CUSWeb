<%--
  emxProgramGUIPopupSelect.jsp
  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramGUIPopupSelect.jsp.rca 1.9 Wed Oct 22 15:49:36 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file="emxProgramNoCache.inc" %>


<%
  String busId = (String) emxGetParameter(request, "busId");
  String attrName = (String) emxGetParameter(request, "attrName");
  String methodName = (String) emxGetParameter(request, "methodName");
  String selectedValue = (String) emxGetParameter(request, "selectedValue");
  String optionListProcName = (String) emxGetParameter(request, "optionList");
  String valueListProcName = (String) emxGetParameter(request, "valueList");
  String tableTitle = (String) emxGetParameter(request, "tableTitle");
  String returnOptionStr = (String) emxGetParameter(request, "returnOption");

  i18nNow i18nnow = new i18nNow();
  String propertyFile   = "emxProgramCentralStringResource";
  String language       = request.getHeader("Accept-Language");
  String tableI18nTitle = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		  tableTitle, language);
%>

<html>

<style type="text/css">
A {text-decoration:none;font-weight:bold;color:#336699}
A.activeday {text-decoration:none;font-weight:bold;color:#ffffff}
</style>



<script language="JavaScript">

  <!-- Begin
  TITLE_NAME_BGCOLOR="#336699";
  TITLE_NAME_FONT_SIZE="4";
  TITLE_NAME_FONT_COLOR="white";


  BUS_ID = "<%= busId %>"; //XSSOK
  ATTR_NAME = "<%= attrName %>";//XSSOK
  METHOD_NAME = "<%= methodName %>";//XSSOK
  SELECTED_OPTION = "<%= selectedValue %>";//XSSOK
  OPTIONS_ProcName = "<%= optionListProcName %>";//XSSOK
  VALUES_ProcName = "<%= valueListProcName %>";//XSSOK
  TABLE_TITLE = "<%= tableI18nTitle %>";

  // Decide if the returning result should be the option or the value
  returnOptionStr = "<%= returnOptionStr %>";//XSSOK
  RETURN_OPTION = false;
  if (returnOptionStr == "true") {
    RETURN_OPTION = true;
  }

  // get the option and value list. There are two ways to call this:
  // 1) JS function on the calling page
  // 2) Bar delimited parameter list
  if (OPTIONS_ProcName.indexOf('|') == -1) {

    //Call the methods on the getWindowOpener() page to get the option and value arrays
    OPTIONS = eval("getWindowOpener()." + OPTIONS_ProcName + "();");
    VALUES = eval("getWindowOpener()." + VALUES_ProcName + "();");

  } else {

    // The variables are provided in a pipe separated list
    OPTIONS = OPTIONS_ProcName.split('|');
    VALUES = VALUES_ProcName.split('|');
  }

  var linkcount=0;

  document.write("<table border=\"2\" bgcolor=\"white\" width=\"180\" ");
  document.write("bordercolor=\"black\"><font color=\"black\" face=\"arial, helvetica, sans-serif, swiss, verdana\">");
  document.write("<tr><td bgcolor='"+TITLE_NAME_BGCOLOR+"'><font color=\""+TITLE_NAME_FONT_COLOR+"\" size="+TITLE_NAME_FONT_SIZE+" face=\"arial, helvetica, sans-serif, swiss, verdana\"><center><strong>" + TABLE_TITLE + "</strong></center></font></td></tr>");


  for (var i=0; i < OPTIONS.length; i++) {      

    theOption = OPTIONS[i];
    theValue = VALUES[i];

    document.write("<tr><td>");
    document.write("<font face='arial, helvetica, sans-serif, swiss, verdana'>")
    document.write("<center>");    

    if (theOption==SELECTED_OPTION) {
      document.write("<b>");
      document.write(theOption);
      document.write("</b>");
    } else {
  
      if (RETURN_OPTION == true) {
        document.write("<a href=\"javascript:setVal('" +  theOption + "','" +  theValue + "')\">")
      } else {
        document.write("<a href=\"javascript:setVal('" +  theValue + "')\">")
      }

      document.write(theOption);
      document.write("</a>")
    }
  
    document.write("</center>");
    document.write("</font>")  
    document.write("</td></tr>");

  }

  document.write("</table></p>");

    function setVal(value) {
      changeValueCmd = "getWindowOpener()." + METHOD_NAME + "(BUS_ID, ATTR_NAME, value);";
      eval(changeValueCmd);
      window.closeWindow();
    }

    function setVal(option,value) {
      changeValueCmd = "getWindowOpener()." + METHOD_NAME + "(BUS_ID, ATTR_NAME, option, value);";
      eval(changeValueCmd);
      window.closeWindow();
    }

  // End -->
</script>

</html>
