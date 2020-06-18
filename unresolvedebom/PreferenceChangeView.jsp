 <%--  PreferenceChangeView.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<HTML>
  <%@include file="../emxUIFramesetUtil.inc"%>
  <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no">
    <META http-equiv="pragma" content="no-cache">
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
    	type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
	     addStyleSheet("emxUIDefault");
	     addStyleSheet("emxUIForm");
	                               
	     function doLoad() {
	       if (document.forms[0].elements.length > 0) {
	         var objElement = document.forms[0].elements[0];
	                                                               
	         if (objElement.focus) objElement.focus();
	         if (objElement.select) objElement.select();
	       }
	     }
    </SCRIPT>
  </HEAD>
  
  <% 
  //Start for the IR-0539252011x
  String accLanguage  = request.getHeader("Accept-Language");
  String changeView   = i18nStringNowUtil("emxUnresolvedEBOM.Preferences.DefaultConfigurationView", "emxUnresolvedEBOMStringResource",accLanguage);
///End of the IR-0539252011x
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="ChangeViewProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
          <!-- XSSOK -->
            <%=changeView%>
          </TD>
          <TD class="inputField">
            <SELECT name="changeView" id="changeView">
<%
    try
    {
    	Locale Local = context.getLocale();
	    ContextUtil.startTransaction(context, false);
		String strChangeView = PropertyUtil.getAdminProperty(context, "person", context.getUser(), "preference_ChangeView");
	    //String strChangeViewFilter = FrameworkProperties.getProperty("emxUnresolvedEBOM.BOMPowerView.ChangeView");
	    
	    String propertyKey = "emxUnresolvedEBOM.BOMPowerView.ConfigView";
	    
    	propertyKey = "emxUnresolvedEBOM.UserPreferences.ConfigurationViewOptions";
    	
    	// Required for upgraded stack where user has stored user preferences already - start
   		if ( "Current".equals(strChangeView) ) {
   			strChangeView = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", new Locale("en-us"), "emxUnresolvedEBOM.BOM.Configuration.Official");
   		}
   		
   		else if ( "CurrentandPending".equals(strChangeView) || "".equals(strChangeView) || strChangeView == null || "null".equals(strChangeView) ) {
   			strChangeView = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", new Locale("en-us"), "emxUnresolvedEBOM.BOM.Configuration.Projected");
   		}
    	// Required for upgraded stack where user has stored user preferences already - end
	    
	    String strChangeViewFilter = EnoviaResourceBundle.getProperty(context, propertyKey);
	    
	    StringList strChangeViewList = FrameworkUtil.split(strChangeViewFilter, ",");
		for (int i = 0; i < strChangeViewList.size(); i++)
	    {
	        String strTemp = (String) strChangeViewList.get(i);

			String choice = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", Local, strTemp);
			String choice_en = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", new Locale("en-us"), strTemp);

			// if choice is equal to default then mark it selected
	        if (choice.equals(strChangeView))
	        {
%>
	              <OPTION value="<xss:encodeForHTMLAttribute><%=choice_en%></xss:encodeForHTMLAttribute>" selected>
	              <!-- XSSOK -->
	                <%=choice%>
	              </OPTION>
<%
	        }
	        else
	        {
%>
	              <OPTION value="<xss:encodeForHTMLAttribute><%=choice_en%></xss:encodeForHTMLAttribute>">
	              <!-- XSSOK -->
	                <%=choice%>
	              </OPTION>
<%
	        }
	    }
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
        }
    } 
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
            </SELECT>
          </TD>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>

