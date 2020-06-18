<%--  emxEngineeringMyViewPreference.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%><html>
    <%@include file="../emxUIFramesetUtil.inc"%>
  <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
    <%@include file = "../emxTagLibInclude.inc"%>


  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
        type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
      function doLoad() {
          if (document.forms[0].elements.length > 0) {
            var objElement = document.forms[0].elements[0];
                                                                  
            if (objElement.focus) objElement.focus();
            if (objElement.select) objElement.select();
          }
        }
    </script>
  </head>
  <%    
        String accLanguage  = request.getHeader("Accept-Language");
	//Multitenant
	//String NofDaysLable   = i18nNow.getI18nString("emxEngineeringCentral.EngView.LastModified", "emxEngineeringCentralStringResource",accLanguage);//PropertyUtil.getProperty("emxEngineeringCentral.MyView.DefaultNoOfDays");
	String NofDaysLable   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EngView.LastModified");
        String maxdays   = FrameworkProperties.getProperty(context, "emxEngineeringCentral.MyView.MaxNoOfDays");//i18nNow.getI18nString("emxEngineeringCentral.MyView.MaxNoOfDays", "emxEngineeringCentralStringResource",accLanguage);
        
        String NumOfDays = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_MyViewPreference");
        if( (NumOfDays == null) || (NumOfDays.equals("null")) || (NumOfDays.equals(""))) {
        	NumOfDays = FrameworkProperties.getProperty(context, "emxEngineeringCentral.MyView.DefaultNoOfDays");
        }
        
        String[] messageValues = new String[1];
        messageValues[0] = maxdays; //i18nNow.getI18nString("emxEngineeringCentral.MyView.MaxNoOfDays", "emxEngineeringCentralStringResource",accLanguage);; // this should be read from the preference setting
        String STR_SEARCHTERMS_INVAIDMESSAGE = MessageUtil.getMessage(context,null,
                                         "emxEngineeringCentral.FormComponent.MustEnterAValidNumericValueFor",
                                         messageValues,null,
                                         request.getLocale(),"emxEngineeringCentralStringResource");


  %>
  <script language="JavaScript" type="text/javascript">
  function validationRoutine(){
    var theForm = document.forms[0];
    var theField = theForm["NumberOfDays"];
    //XSSOK
    var error="<%=STR_SEARCHTERMS_INVAIDMESSAGE%>";
  //XSSOK
    var maxday="<%=maxdays%>";
    if(isNaN(theField.value)){
        alert(error);
        return false;
    }
    
    if(theField.value == "" || parseInt(theField.value) <=0 || parseInt(theField.value) > parseInt(maxday)) {
    	 alert(error);
    	 return false;
    }
    
    return true;
  }

  </script>
  <body onload="doLoad() ,turnOffProgress()">
    <form method="post" action="emxEngineeringMyViewPreferenceProcessing.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2"
             width="100%">
       
        <tr>
                <td width="150" class="label">
                		<!-- XSSOK -->
                        <%=NofDaysLable%>
                </td>
                <td class="inputField">
                        <input type="text" name="NumberOfDays" id="NumberOfDays" value="<xss:encodeForHTMLAttribute><%=NumOfDays%></xss:encodeForHTMLAttribute>" />
                </td>
        </tr>
      </table>
    </form>
  </body>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>

