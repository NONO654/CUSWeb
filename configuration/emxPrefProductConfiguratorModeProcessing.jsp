<%--  emxPrefProductConfiguratorModeProcessing.jsp   - The Product Configurator Mode Preference Processing Page

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
   static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/emxPrefProductConfiguratorModeProcessing.jsp 1.2.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%
    // check if change has been submitted or just refresh mode
    // Get language
    String prefProductConfiguratorMode = emxGetParameter(request, "prefProductConfiguratorMode");
		if( ("".equals(prefProductConfiguratorMode)) )
        {
		    prefProductConfiguratorMode="";
        }
    // if change has been submitted then process the change
        try
        {
              if(prefProductConfiguratorMode !=null)
                PersonUtil.setProductConfiguratorModePreference(context,prefProductConfiguratorMode.trim());
        }
        catch (Exception ex) {
            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxprefProductConfiguratorMode:" + ex.toString().trim());
            }
        }
        
%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

