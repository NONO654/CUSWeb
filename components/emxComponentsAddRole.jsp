<%--  emxComponentsAddRole.jsp   - The Person add Role processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddRole.jsp.rca 1.16.2.1 Tue Dec 23 06:16:24 2008 ds-arsingh Experimental $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
    boolean hasException = false;
	String fromPage = null;
	String keyPerson = null;
    try {
            /* Bug 356691 */
            if (!UICache.checkAccess(context, "command_CreatePersonActions")) {
                out.println("Denied");
                return;
            }
            
           com.matrixone.apps.common.Person personID = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                   DomainConstants.TYPE_PERSON);

           String objectId= emxGetParameter(request,"objectId");
           fromPage = (String) emxGetParameter(request,"fromPage");
           String strLanguage = request.getHeader("Accept-Language");

           if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
           {
               fromPage="";
           }

            keyPerson = emxGetParameter(request,"keyPerson");

           if(fromPage.equals("CreatePerson"))
           {
               String strRoleList = (String) formBean.getElementValue("roleList");
               if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strRoleList))
               {
                   strRoleList = "";
               }
               

               String[] sRoleList          = request.getParameterValues("emxTableRowId");

          if(sRoleList==null)
               {
                  %> 
                  
                  <script language="javascript">
                  		 alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.PleaseMakeASelection")%>");
                  	</script>
                  
                  		<%
                   return;
               }

               sRoleList        = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(sRoleList);
               
               for(int i=0; i<sRoleList.length; i++)
               {
                   strRoleList += sRoleList[i]+"|";
               }
               
               formBean.setElementValue("roleList",strRoleList);
          }

           else
           {

// Added for IR-023990V6R2011 Dated 04/12/2009 Begins.
           com.matrixone.apps.common.Person pContext = com.matrixone.apps.common.Person.getPerson(context);
           String strSelect = "to["+PropertyUtil.getSchemaProperty(context, "relationship_Employee")+"].from.id";
           String sContextCompanyId = pContext.getCompanyId(context);
           String sPersonCompanyId=new DomainObject(objectId).getInfo(context, strSelect);
            if(!(com.matrixone.apps.common.Company.isHostRep(context, pContext)) && !(sContextCompanyId.equals(sPersonCompanyId)))
            {
                out.println("Denied");
                return;
            }
// Added for IR-023990V6R2011 Dated 04/12/2009 Ends.

           StringList strRoleList = new StringList();          
           if(objectId != null) 
           {
               personID.setId(objectId);
                
               String[] sRoleList          = request.getParameterValues("emxTableRowId");
               
               sRoleList		= com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(sRoleList);
               // end the 312078
               // added for the bug no:-338629
			   for(int i=0; i<sRoleList.length; i++)
			   {
                   strRoleList.addElement(sRoleList[i]);
               }
               // end 338629
                
                personID.addRoles(context, strRoleList);
           }
            // START Bug 364050
           com.matrixone.apps.common.Person busLoggedPerson = com.matrixone.apps.common.Person.getPerson(context); 
           boolean isHostRep = com.matrixone.apps.common.Company.isHostRep(context, busLoggedPerson);
           String strCompanyRepresentative   = PropertyUtil.getSchemaProperty(context, "role_CompanyRepresentative");
           String strOrganizationManager     = PropertyUtil.getSchemaProperty(context, "role_OrganizationManager");


           if (!isHostRep && (strRoleList.contains(strCompanyRepresentative) || strRoleList.contains(strOrganizationManager) ) ) { 
           
           %>
                <script language="JavaScript">
                    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PeopleRoleSummary.RoleAlertMessage</emxUtil:i18nScript>");
                </script>
          <% 
           }                       
           
        }      
           // END Bug 364050  
    } catch (com.matrixone.apps.domain.util.FrameworkException ex) {
        ex.printStackTrace();
        hasException = true;
    }
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script>
<%
  if(!hasException && fromPage.equals("CreatePerson"))
  {
%>  var keyPerson = "<%=XSSUtil.encodeForJavaScript(context, keyPerson)%>";
	getTopWindow().getWindowOpener().document.location.href= "../components/emxComponentsPeopleRoleSummary.jsp?keyPerson="+keyPerson;
	getTopWindow().closeWindow();
<% } 
	else
	{ 
		%>
	getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
	getTopWindow().closeWindow();
<%
	}
%>

</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%> 
