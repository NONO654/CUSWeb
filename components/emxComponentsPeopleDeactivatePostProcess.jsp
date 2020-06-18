<%--  emxComponentsPeopleDeactivatePostProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxComponentsPeopleDeactivatePostProcess.jsp.rca 1.1 Wed Dec 17 10:31:10 2008 ds-arsingh Experimental $
	
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%@ page import = "matrix.util.*,java.util.*,com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script language="Javascript" >

<%
String jsTreeID = emxGetParameter(request,"jsTreeID");
String objectId = emxGetParameter(request,"objectId");
String initSource = emxGetParameter(request,"initSource");
String suiteKey = emxGetParameter(request,"suiteKey");
String strRemoveLicenses = emxGetParameter(request,"removeLicenses");
String fromPage = emxGetParameter(request,"fromPage");
String checkBoxId = emxGetParameter(request,"checkBoxIds");
StringList slIds = FrameworkUtil.splitString(checkBoxId, ",");
boolean isLicenseError = false;
//String[] selectedPeople = new String[checkBoxId.length];

//Added for 297703
MapList mapList=new MapList();
StringList stList=new StringList();
String sOwner1="";
String personName="";
String sType="";
String sName="";
String sRev="";
String sOwner="";
//End for 297703 

String url = "";
String delId  ="";

if(slIds != null )
{
    try
    {  
        DomainObject domObject = null;
        String sState = null;
        String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_PERSON, "state_Active");
        StringTokenizer st = null;
        String sRelId = "";
        String sObjId = "";
        
        for (int i=0; i<slIds.size(); i++){
            String strEachCheckboxId = (String)slIds.get(i);
            if (strEachCheckboxId.indexOf("|") == -1){
                sObjId = strEachCheckboxId;
            }
            else {
            st = new StringTokenizer(strEachCheckboxId, "|");
            sRelId = st.nextToken();
            sObjId = st.nextToken();
            }

            domObject = new DomainObject(sObjId);
            sOwner1=domObject.getInfo(context,DomainConstants.SELECT_OWNER);
            domObject.open(context);
          
   		//Added for 297703 to get all the related objects of selected member list
            personName = domObject.getInfo(context,DomainConstants.SELECT_NAME);
            stList.addElement(DomainConstants.SELECT_ID);
            mapList=domObject.getRelatedObjects(context,
                                               "*",
                                               "*",
                                               stList,
                                               null,
                                               true,
                                               true,
                                               (short)1,
                                               "",
                                               null);

            Iterator itr=mapList.iterator();
            	
            while(itr.hasNext())
            {
                 Map map=(Map)itr.next();
                 String objectID=(String)map.get("id");
                 DomainObject domObj=new DomainObject(objectID);
 				  
 				  //Retrieving all the owner names of object ID
                 sOwner=domObj.getInfo(context,DomainConstants.SELECT_OWNER);
                 sType=domObj.getInfo(context,DomainConstants.SELECT_TYPE);

                 String typeRoute = PropertyUtil.getSchemaProperty(context, "type_Route");
                 
                 //send notification only if Route is Started
                 if(sType.equalsIgnoreCase(typeRoute))
                 {
                	 String routeStatus = domObj.getAttributeValue(context, DomainConstants.ATTRIBUTE_ROUTE_STATUS);
                	 if(!routeStatus.equalsIgnoreCase(domObj.STATE_STARTED))
                		 continue;
                 }

                 sName=domObj.getInfo(context,DomainConstants.SELECT_NAME);
                 sRev=domObj.getInfo(context,DomainConstants.SELECT_REVISION);

                  String[] arguments = new String[20];
                  arguments[0]  = sOwner;
                  arguments[1]  = "emxFramework.ProgramObject.DeactivateNotice";
                  arguments[2]  = "0";
                  arguments[3]  = "emxFramework.ProgramObject.DeactivateMessage";
                  arguments[4]  = "7";
                  arguments[5]  = "name";
                  arguments[6]  =  sOwner1;
                  arguments[7]  = "Type";
                  arguments[8]  = sType;
                  arguments[9]  = "Name";
                  arguments[10]  = sName;
                  arguments[11]  = "Rev";
                  arguments[12]  = sRev;
                  arguments[13]  = "PersonName";
                  arguments[14]  = personName;
                 
 				   //When person is deactivated 
 				   //sending notification mail to all the users whcih are connected to objects
                   int strMsg=(int)matrix.db.JPO.invoke(context,
                                              "emxMailUtilBase",
                                               null,
                                              "sendNotificationToUser",
                                              arguments);
              }
// End for 297703 
          
            sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);
            if(sState.equals(stateActive))
            {
                try
                {
                	StringList objectSelects= new StringList();
            		objectSelects.addElement(DomainConstants.SELECT_NAME);
            		objectSelects.addElement("attribute["+DomainObject.ATTRIBUTE_LICENSED_HOURS+"]");
            		Map personInfo = domObject.getInfo(context, objectSelects);
            		String strUserName = (String)personInfo.get(DomainConstants.SELECT_NAME);
            		String sLicensedHours = (String)personInfo.get("attribute["+DomainObject.ATTRIBUTE_LICENSED_HOURS+"]");
            		boolean isCasualUser = !"0".equals(sLicensedHours);
                    
                    String[] licenseList;
                    String[] licenseListToRelease;
                    try {
                        ContextUtil.pushContext(context);
                        ContextUtil.pushContext(context, strUserName, "", null);
                       	if(isCasualUser){
                       		Map<String, Integer> mapLicenses = LicenseUtil.getCasualLicenses(context, false);
                            licenseList = (String[]) mapLicenses.keySet().toArray(new String[]{});	
                       	}else{
                        licenseList = LicenseUtil.getLicenses(context, false);//exportting all the web application licenses for the current user
                    }
                    }
                    catch (Exception e){
                        throw new Exception (e);
                    }
                    finally {
                        ContextUtil.popContext(context);
                        ContextUtil.popContext(context);
                    }
                    
                    if (licenseList !=null && licenseList.length != 0){
						if ("true".equals(strRemoveLicenses)){
							//LicenseUtil.releaseLicenses(context, strUserName, licenseList, "LicServer");

       						try
       						{
	       						java.util.List info = LicenseUtil.getUserLicenseUsage(context,strUserName,null);
	       						licenseListToRelease = new String[info.size()];
	       						for( int k=0, len=info.size(); k<len; k++ ) {
	       	                   	 HashMap rowmap = (HashMap)info.get(k);
	       	                   	 String licTrigram = (String)   rowmap.get(LicenseUtil.INFO_LICENSE_NAME);
	       	                     licenseListToRelease[k] = licTrigram;
	       						}
	       						try
	       						{
			       					LicenseUtil.releaseLicenses(context, strUserName, licenseListToRelease, null);
			       				
	       						}
	       						catch(Exception e)
	       						{
	       							isLicenseError = true;
	       						}
       						}
       						catch(Exception exp)
       						{
       						    String strMsg = exp.getMessage();
       						    if(strMsg.indexOf("License not found") == -1)
       						    {
       						        throw new Exception(exp);
       						    }
       						}
							String strCommand;
       						for (int j = 0; j< licenseList.length; j++){
       							String strResult = "";
       							strCommand = "print product $1 select $2 dump $3";
       						    if(isCasualUser){
       						    	strResult = MqlUtil.mqlCommand(context, strCommand, true, licenseList[j], "casualhour["+ sLicensedHours +"].person", "|");
       						    }else{
       						    	strResult = MqlUtil.mqlCommand(context, strCommand, true, licenseList[j], "person", "|");     						    	
       						    }       						 	
       						 	if (strResult != null && !"".equals(strResult) && strResult.indexOf(strUserName) != -1){
       						 		strCommand = "modify product " + licenseList[j] + " remove person \"" + strUserName + "\""; 
       						    	MqlUtil.mqlCommand(context, strCommand, true);
       						 	}
       						}       						
       						
                        }
                    }
                    domObject.demote(context);
                }
                catch (MatrixException me)
                {
                    session.setAttribute("error.message", me.getMessage());
                }
            }
            domObject.close(context);
            if(isLicenseError) {
            %>
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.userLicenseErrorMessage</emxUtil:i18nScript>");           
        <% }
            
        }
    }catch(Exception Ex){
       session.putValue("error.message", Ex.getMessage());
    }
}

%>
</script>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">
if("<%=XSSUtil.encodeForJavaScript(context,fromPage)%>"=="pageSummary"){//XSSOK
	parent.document.location.href=parent.document.location.href;    
}else{
    getTopWindow().refreshTablePage();
}

</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

