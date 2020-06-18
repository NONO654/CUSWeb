 <%--  
 	   @quickreview JX5 QYG 15:08:18  IR-393040-3DEXPERIENCER2016x : Buttions on Object Creation form Preforms improper operation in system finder. 
       @quickreview ZUD DJH 14:05:21 (IR-240841V6R2015 STP : While creating new decision on Requirement-Requirement  relationship, desciption field of Decision creation window does not accept space between the text )
       @quickreview T25 OEP 12:08:17 (IR-157167V6R2013x "ST: Unwanted message is displayed while creating decision from Create New Requirement form of Requirement.")
       @quickreview JX5 LX6 12:10:08 : IR-182368V6R2014 "STP:In CATIA, Close button is non functional on all RMT object creation form."
       @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
       are added under respective scriplet
  --%>
  <%-- @quickreview T25 OEP 12:12:10 -  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
  <%-- @quickreview T25 DJH 12:12:12 - Solved merge with Louis' code--%>
  <%-- @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included--%>
  <%-- @quickreview JX5 QYG 10 Apr 2013  IR-199296V6R2014 : In CATIA, unwanted confirmation message is displayed when user select Close button--%>
  
<%@page contentType="text/javascript; charset=UTF-8"%>
<%@ page import="com.matrixone.apps.framework.ui.*,java.text.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>  
<%@page import = "matrix.db.Context"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%
String languageStr = request.getHeader("Accept-Language");
Context context = Framework.getFrameContext(session);
%>

function changeLabels()
{

	//In CATIA we only have two buttons
	var nbOfButtons = $("button", "#divDialogButtons").size();
	
	$("button", "#divDialogButtons").each(function(index) {
	
		switch(nbOfButtons){
			case 2:
					switch(index){
					case 0: 
						$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.CreateAndClose")%></xss:encodeForJavaScript>");
						break;
					case 1:
						$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.Close")%></xss:encodeForJavaScript>");
				}
				break;
			case 3:
				switch(index){
					case 0: 
						$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.CreateAndClose")%></xss:encodeForJavaScript>");
						break;
					case 1: 
						$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.Create")%></xss:encodeForJavaScript>");
						break;
					case 2:
						$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.Close")%></xss:encodeForJavaScript>");
				}
				break;
		}
	
		
	});
}

function validateRevision(fieldName)
{
if(!fieldName){
    fieldName=this;
    }
    var fieldValue = fieldName.value;
    var fieldActualName = fieldName.name;
    if(fieldValue==""){
        return true;
    }
    var charArray = new Array(20);
    charArray = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,"emxFramework.CustomTable.NameBadChars")%></xss:encodeForJavaScript>";
    
     var charUsed = checkStringForChars(fieldValue,charArray,false);
     
      if(fieldValue.length>0 && charUsed.length >=1)
         {
          alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.RemoveInvalidChars")%></xss:encodeForJavaScript>" + "\t" + fieldActualName + "\n" + charArray );
          return false;
         }
    return true;
}

function checkStringForChars(strText, arrBadChars, blnReturnAll){
        var strBadChars = "";
        for (var i=0; i < arrBadChars.length; i++) {
                if (strText.indexOf(arrBadChars[i]) > -1) {
                        strBadChars += arrBadChars[i] + " ";
                }
        }
        if (strBadChars.length > 0) {
                if (blnReturnAll) {
                        return arrBadChars.join(" ");
                } else {
                        return strBadChars;
                }
        } else {
                return "";
        }
}

  
   // Start:IR:157167V6R2013x:T25
  //Review:OEP
  
function checkBadChars(fieldName)
{
if(!fieldName){
    fieldName=this;
    }
    var fieldValue = fieldName.value;
    var fieldActualName = fieldName.name;
    if(fieldValue==""){
        return true;
    }
         var charArray = new Array(20);
         charArray = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.BadChars")%></xss:encodeForJavaScript>";
	 // ++ ZUD FIX for IR IR-240841V6R2015 ++
          var ARR_SELECTOR_BAD_CHARS = "";
         if (charArray != "")
         {
             ARR_SELECTOR_BAD_CHARS = charArray.split(" ");
         }
          var charUsed = checkStringForChars(fieldValue,ARR_SELECTOR_BAD_CHARS,false);
	  // -- ZUD FIX for IR IR-240841V6R2015 --
          if(fieldValue.length>0 && charUsed.length >=1)
         {
          alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.InvalidChars") %></xss:encodeForJavaScript>" + "\n" + charArray );
          return false;
         }
    return true;
}
 //END:IR:157167V6R2013x:T25
  

emxUICore.addEventHandler(window, "load", changeLabels);
