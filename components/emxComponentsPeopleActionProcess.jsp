<%--  emxComponentsPeopleActionProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleActionProcess.jsp.rca 1.6 Wed Oct 22 16:18:30 2008 przemek Experimental przemek $
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />
<HTML>
	<head>
		<script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	</head>
	<body>
	</body>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String action = emxGetParameter(request,"action");
  //  Added for 297703 
  MapList mapList=new MapList();
  StringList stList=new StringList();
  String sOwner1="";
  String personName="";
  String sType="";
  String sName="";
  String sRev="";
  String sOwner="";
  boolean status = false;
// End for 297703 

  if(objectId != null )
  {
	  if("SwitchUser".equals(action)){	
		  String licensedHours = emxGetParameter(request,"licensedHours");
		  try {  
			  status = true;
	          DomainObject domObject = new DomainObject(objectId);
	          domObject.open(context);
	          //String sLicensedHours = domObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_LICENSED_HOURS+"]");
	          String sLicensedHours = "0".equals(licensedHours) ? "40" : "0";
	          domObject.setAttributeValue(context,DomainObject.ATTRIBUTE_LICENSED_HOURS, sLicensedHours);         
	          domObject.close(context);
	     }catch(Exception Ex) {
	        session.putValue("error.message", Ex.toString());
	     }		  
	  }else{	  
      		try
		      {  
		          String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_PERSON, "state_Active");
		          DomainObject domObject = new DomainObject(objectId);
		          domObject.open(context);
		          String sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);
		          String subject = "";
		          String message = "";
		
		          if(sState.equals(stateActive))
		          {
		              try
		              {
		               %>
		                  <script language="Javascript">
		                	var removeLicenses;
		                	var strUrl;
		                	var answer = confirm ("<emxUtil:i18n localize="i18nId">emxComponents.Common.Licensing.InactiveUserConfirmation</emxUtil:i18n>");
		                	if (answer) {
		                		removeLicenses = "true";
		                	}else {
		                		removeLicenses = "false";
		                	}
		                	strUrl = "../components/emxComponentsPeopleDeactivatePostProcess.jsp?checkBoxIds=<%=XSSUtil.encodeForURL(context, objectId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&initSource=<%=XSSUtil.encodeForURL(context, initSource)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&removeLicenses="+removeLicenses;
		                	strUrl += "&fromPage=pageSummary";
		                	submitWithCSRF(strUrl, window);
		                  </script>
		<%                   
		              }
		              catch (MatrixException me)
		              {
		                  session.setAttribute("error.message", me.getMessage());
		              }
		          }
		          else
		          {
		              try
		              {
		                  subject = "emxFramework.ProgramObject.ActivateNotice";
		                  message = "emxFramework.ProgramObject.ActivateMessage";
		                  domObject.promote(context);
		                  status = true;
		              }
		              catch (MatrixException me)
		              {
		                  session.setAttribute("error.message", me.getMessage());
		              }
		          }
		
		          //  Added for 297703 to get all the related objects of selected member list
		          if(status)
		          {
		             sOwner1=domObject.getInfo(context,DomainConstants.SELECT_OWNER);
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
		
		                  sName=domObj.getInfo(context,DomainConstants.SELECT_NAME);
		                  sRev=domObj.getInfo(context,DomainConstants.SELECT_REVISION);
		
		             
		             
		                   String[] arguments = new String[20];
		                   arguments[0]  = sOwner;
		                   arguments[1]  = subject;
		                   arguments[2]  = "0";
		                   arguments[3]  = message;
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
		                 
		                   //When person is deactivated/activated 
						   //sending notification mail to all the users whcih are connected to objects
						   
		                    int strMsg=(int)JPO.invoke(context,
		                                               "emxMailUtilBase",
		                                                null,
		                                               "sendNotificationToUser",
		                                               arguments);
		               }
		          }
			// End for 297703 
		         domObject.close(context);
		          
		     }catch(Exception Ex)
		     {
		        session.putValue("error.message", Ex.toString());
		     }
  		}
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
    //reload only when person is activated. In case of deactivation, post process will handle the refresh mechanism
   <%if(status){%>
      parent.document.location.href=parent.document.location.href;
   <%}%>
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
</HTML>

