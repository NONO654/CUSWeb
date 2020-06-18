<%--  emxPrefEmailNotifications.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefEmailNotifications.jsp.rca 1.12 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no">
    <meta http-equiv="pragma" content="no-cache">
    <script type="text/javascript" src="scripts/emxUIConstants.js" ></SCRIPT>
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
  <body onload="doLoad(), turnOffProgress()">
	<form method="post"
		onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose();"
		action="emxPrefEmailNotificationsProcess.jsp">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
  	    	<td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Preferences.EmailNotification.Frequency</emxUtil:i18n>
          </td>
          <td class="inputField">
            <table border="0">
<%
    boolean isContextPushed = false;
	try {
        ContextUtil.startTransaction(context, false);
        
        // Get user preference
    	String notificationFrequency = PersonUtil.getEmailNotificationsPreference(context);
        
	    if (notificationFrequency == null || notificationFrequency.length() == 0) {
	    	notificationFrequency = "Default";
	    }
            	
        //need to push and pop context to get spools
        ContextUtil.pushContext(context);
        isContextPushed = true;

    	// Get frequency choices, based on active notification spools
    	StringList selects = new StringList(1);
    	selects.add(DomainConstants.SELECT_NAME);
    	
    	String typeStr = PropertyUtil.getSchemaProperty(context, "type_NotificationSpool");
    	String whereExp = FrameworkUtil.getWhereExpressionForMql(context,"attribute[Enable For Preference]==TRUE",typeStr);
    	MapList spools = DomainObject.findObjects(context, typeStr, "*", "*", "*", "*", whereExp, false, selects);
    	
    	// add known values to the frequency list
    	String [] frequencies = new String[spools.size() + 2];
    	int j = 0;
    	frequencies[j++] = "Default";
    	frequencies[j++] = "Immediately";
    	
    	// add active spool names to the frequency list
    	for (int i = 0; i < spools.size(); i++) {
    		frequencies[j++] = (String) ((Map) spools.get(i)).get(DomainConstants.SELECT_NAME);		
    	}
    	
    	String labelKey;
    	
    	// for each frequency choice, look up label and create radiobutton
    	for (int i = 0; i < frequencies.length; i++) {

    		// localize the frequency label
	        labelKey = "emxFramework.Preferences.EmailNotification." + frequencies[i].replace(' ', '_');

	        // if frequency is equal to stored user preference then mark it as "checked"
	        String checked = notificationFrequency.equalsIgnoreCase(frequencies[i]) ? " checked" : "";
%>
              <tr>
                <td>
											<!-- //XSSOK --> <input type="radio" name="frequency"
											id="frequency" value="<%=frequencies[i]%>" <%=checked%> /> <!-- //XSSOK -->
                  &nbsp;<emxUtil:i18n localize="i18nId"><%=labelKey%></emxUtil:i18n>
                </td>
              </tr>
<%
	    }
								if (isContextPushed) {
									ContextUtil.popContext(context);
									isContextPushed = false;
								}
%>
            </table>
          </td>
        </tr>
			<tr>
				<td width="150" class="label">
            		<emxUtil:i18n localize="i18nId">emxFramework.Preferences.Language</emxUtil:i18n>
          		</td>
          		<td class="inputField">
            		<SELECT name="language" id="language">
			<%		
						//ContextUtil.startTransaction(context, false);
						// Get Language choices
						ArrayList languageChoices = PersonUtil.getLanguageChoices(context);
			
						// Get Language preference set for logged in user
						String languageDefault = PersonUtil.getLanguage(context);
			
						// for each Language choice
						for (int i = 0; i < languageChoices.size(); i++)
						{
							// get choice
						    String choice = (String)languageChoices.get(i);
						
						    // translate the choice
						    String choicePropKey = "emxFramework.Preferences.Language." + choice.replace(' ', '_');
						    String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
						
						    // if translation not found then show choice.
						    if (choicePropValue == null || choicePropValue.equals(choicePropKey))
						    {
						        choicePropValue = choice;
						    }
						
						    // if choice is equal to default then
						    // mark it selected
						    if (choice.equals(languageDefault))
						    {
			%>
							  <OPTION value="<%=XSSUtil.encodeForHTMLAttribute(context,(String)choice)%>" selected>
				                <!-- //XSSOK -->
				                <%=choicePropValue%>
				              </OPTION>
<%
    }
        					else
        					{
			%>
								<OPTION value="<%=XSSUtil.encodeForHTMLAttribute(context,(String)choice)%>" >
					                <!-- //XSSOK -->
					                <%=choicePropValue%>
					            </OPTION>
			<%
        					}
						}
			%>
					</SELECT>
				</td>
			</tr>
			<%
				} catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
            emxNavErrorObject.addMessage("emxPrefEmailNotifications:" + ex.toString().trim());
        }
    }
    finally {
        ContextUtil.commitTransaction(context);
        
        //pop context only if it was pushed
        if (isContextPushed) {
            ContextUtil.popContext(context);
        }
    }
%>
      </table>
    </form>
  </body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>


