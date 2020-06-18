<%--  emxJSValidation.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxJSValidation.jsp.rca 1.1.5.4 Wed Oct 22 15:48:43 2008 przemek Experimental przemek $";
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%
out.clear();
response.setContentType("text/javascript;");
%>
    //define bad chars for use in validation
    var STR_BAD_CHARS = "";
    var STR_NAME_BAD_CHARS = "";
    var STR_FILE_NAME_BAD_CHARS = "";
<%
    String emxBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.BadChars");
    String emxNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
    String emxFileNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.FileNameBadChars");

    if ((emxBadChars != null) || ("".equals(emxBadChars)))
    {
    	emxBadChars = emxBadChars.trim();
%>
        <!-- //XSSOK -->
        STR_BAD_CHARS = "<%= emxBadChars %>";
<%
    }

    if ((emxNameBadChars != null) || ("".equals(emxNameBadChars)))
    {
    	emxNameBadChars = emxNameBadChars.trim();
%>
        <!-- //XSSOK -->
        STR_NAME_BAD_CHARS = "<%= emxNameBadChars %>";
<%
    }

    if ((emxFileNameBadChars != null) || ("".equals(emxFileNameBadChars)))
    {
    	emxFileNameBadChars = emxFileNameBadChars.trim();
%>
        <!-- //XSSOK -->
        STR_FILE_NAME_BAD_CHARS = "<%= emxFileNameBadChars %>";
<%
    }
%>
	//code added to check if STR_BAD_CHARS is not empty then only split
  	var ARR_BAD_CHARS = "";
  	if (STR_BAD_CHARS != "")
  	{
  		ARR_BAD_CHARS = STR_BAD_CHARS.split(" ");
  	}

  	//code added to check if STR_NAME_BAD_CHARS is not empty then only split
  	var ARR_NAME_BAD_CHARS = "";
  	if (STR_NAME_BAD_CHARS != "")
  	{
  		ARR_NAME_BAD_CHARS = STR_NAME_BAD_CHARS.split(" ");
  	}

  	//code added to check if STR_FILE_NAME_BAD_CHARS is not empty then only split
  	var ARR_FILE_NAME_BAD_CHARS = "";
  	if (STR_FILE_NAME_BAD_CHARS != "")
  	{
  		ARR_FILE_NAME_BAD_CHARS = STR_FILE_NAME_BAD_CHARS.split(" ");
  	}

    // The following variables are retained here to support some of the legacy pages referring to them
    // These variable to be removed
    // Start of obsolete variables
    var badChars = STR_BAD_CHARS;
    var nameBadChars = ARR_NAME_BAD_CHARS;
    var restrictedBadChars = STR_BAD_CHARS;
    var commonIllegalCharacters = STR_BAD_CHARS;
    // End of obsolete variables

    var preferredDecimalSymbol = "<xss:encodeForJavaScript><%=new Character(PersonUtil.getDecimalSymbol(context))%></xss:encodeForJavaScript>";
    var hasDigitSeparator = "<xss:encodeForJavaScript><%=FrameworkUtil.hasDigitSeparator(context)%></xss:encodeForJavaScript>";


