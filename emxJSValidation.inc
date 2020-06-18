<%--  emxJSValidation.inc

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxJSValidation.inc.rca 1.33 Wed Oct 22 16:09:23 2008 przemek Experimental przemek $";
--%>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="Javascript">

    //define bad chars for use in validation
    var STR_BAD_CHARS = "";
    var STR_NAME_BAD_CHARS = "";
    var STR_FILE_NAME_BAD_CHARS = "";
    var STR_DELIMITER_BAD_CHARS = "";    
    var STR_FILE_NAME_BAD_CHARS_CHECKIN_DESC = "";
    
    
             
<%

    String emxBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.BadChars");
    String emxNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
    String emxFileNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.FileNameBadChars");
    String emxDelimiterBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.DelimiterBadChars");
    String emxFileNameBadCharsForChckinDesc = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.BadCharsForCheckinDesc");
    
   
    if ((emxBadChars != null) || ("".equals(emxBadChars)))
    {
    	emxBadChars = emxBadChars.trim();
%>    
        //XSSOK
        STR_BAD_CHARS = "<%= emxBadChars %>";
<%
    }

    if ((emxNameBadChars != null) || ("".equals(emxNameBadChars)))
    {
    	emxNameBadChars = emxNameBadChars.trim();
%>    
         //XSSOK 
        STR_NAME_BAD_CHARS = "<%= emxNameBadChars %>";
<%
    }

    if ((emxFileNameBadChars != null) || ("".equals(emxFileNameBadChars)))
    {
    	emxFileNameBadChars = emxFileNameBadChars.trim();
%>    
         //XSSOK 
        STR_FILE_NAME_BAD_CHARS = "<%= emxFileNameBadChars %>";
<%
    }
    
    if ((emxDelimiterBadChars != null) || ("".equals(emxDelimiterBadChars)))
    {
        emxDelimiterBadChars = emxDelimiterBadChars.trim();
%>    
         //XSSOK 
        STR_DELIMITER_BAD_CHARS = "<%= emxDelimiterBadChars %>";
<%
    }
 
    if ((emxFileNameBadCharsForChckinDesc != null) || ("".equals(emxFileNameBadCharsForChckinDesc)))
        {
        emxFileNameBadCharsForChckinDesc = emxFileNameBadCharsForChckinDesc.trim();
    %>
             //XSSOK 
            STR_FILE_NAME_BAD_CHARS_CHECKIN_DESC = "<%= emxFileNameBadCharsForChckinDesc %>";
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
  	
  	var ARR_FILE_NAME_BAD_CHARS_CHECKIN_DESC = "";
  		if (STR_FILE_NAME_BAD_CHARS_CHECKIN_DESC != "")
  	{
  		  ARR_FILE_NAME_BAD_CHARS_CHECKIN_DESC= STR_FILE_NAME_BAD_CHARS_CHECKIN_DESC.split(" ");
  	}
     
 
    // The following variables are retained here to support some of the legacy pages referring to them
    // These variable to be removed
    // Start of obsolete variables
    var badChars = STR_BAD_CHARS;
    var nameBadChars = ARR_NAME_BAD_CHARS;
    var restrictedBadChars = STR_BAD_CHARS;
    var commonIllegalCharacters = STR_BAD_CHARS;    
    // End of obsolete variables
    
    //XSSOK
    var preferredDecimalSymbol = "<%=PersonUtil.getDecimalSymbol(context)%>";
    //XSSOK
    var hasDigitSeparator = "<%=FrameworkUtil.hasDigitSeparator(context)%>";

</script>

