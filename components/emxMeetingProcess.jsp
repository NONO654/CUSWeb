<%-- emxMeetingProcess.jsp -- process page to promote, demote, Start, Join Meeting object
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
Author: Louis M
  

--%>
<%@ page import="com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.util.PropertyUtil" %>
<%@page import="com.matrixone.apps.common.Meeting"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%><script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%@page import="java.util.HashMap"%><script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

 <script language="javascript">
 var startedMeetingIds = new Array();
  function getMeetingKey(mkKey)
  {
  var tempWebExURL;
  var strLocation = document.location.href;
          for( var index = 0; index < window.getWindowOpener().parent.frames[1].document.forms[0].elements.length; index++ ) {
              tempWebExURL = window.getWindowOpener().parent.frames[1].document.forms[0].elements[index].options[window.getWindowOpener().parent.frames[1].document.forms[0].elements[index].options.selectedIndex].value;
	          if(tempWebExURL!=null){
	          break;
	          }
          }
          if(mkKey==null || mkKey=="" || mkKey=="null") {    
          	strLocation = strLocation+"&meetingKey="+tempWebExURL;          
            window.parent.location.href=strLocation;
          }
          
          
  }
  
  </script>
<%
  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String strSuiteKey      = emxGetParameter(request,"suiteKey");
  String strObjectId      = emxGetParameter(request,"objectId");
  String strAction        = emxGetParameter(request, "action");
  String strNotification  = emxGetParameter(request, "notification");
  String strMK  		  = emxGetParameter(request, "meetingKey");
  String targetLocation         = emxGetParameter(request, "targetLocation");
  String sReturnPage      = null;
  
  //<Fix IR-009245>
  boolean refreshTree = false;
  String newMeetingId = "";
  //</Fix IR-009245>

  
  String stateInProgress  = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_MEETING, "state_InProgress");
  
  Meeting busMeeting = null;
  String strStatus = "";
  String meetingType = "";
  
  if(strObjectId != null && !"".equals(strObjectId)) {
      DomainObject domObj = DomainObject.newInstance(context,strObjectId);
      if(DomainConstants.TYPE_MEETING.equals(domObj.getInfo(context, DomainConstants.SELECT_TYPE))) {
          busMeeting = new Meeting(strObjectId);
          
          StringList objsel = new StringList();
          objsel.add(DomainObject.SELECT_OWNER);
          objsel.add(DomainObject.SELECT_CURRENT);
          objsel.add("attribute[Meeting Type]");
          
          Map busWSelectMeeting = busMeeting.getInfo(context , objsel);
          
          BusinessObject busOwnerPerson   = new BusinessObject(DomainConstants.TYPE_PERSON, (String)busWSelectMeeting.get(DomainObject.SELECT_OWNER),"-","");
          BusinessObject meetingHostOrganization = JSPUtil.getOrganization(context, session, busOwnerPerson);
          strStatus        = (String)busWSelectMeeting.get(DomainObject.SELECT_CURRENT);
          meetingType 	   = (String)busWSelectMeeting.get("attribute[Meeting Type]");
      }
  } else {
      busMeeting = new Meeting();
  }
   
  
  try{
      if("Promote".equals(strAction)){%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    	  <%    	  
		  //Action: Promote
          busMeeting.meetingPromoteInvoke(context, strObjectId, strSuiteKey, strAction, strNotification, jsTreeID);
	  %>
	  <script language="javascript">

 		window.parent.location.href=window.parent.location.href;
        if(getTopWindow().RefreshHeader){
			getTopWindow().RefreshHeader();
		}
		</script>
	  <%
      }else if("Demote".equals(strAction)){%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    	  <%
		//Action : Demote
          busMeeting.meetingDemoteInvoke(context, strObjectId, strSuiteKey, strAction, strNotification, jsTreeID);
          %>
    	  <script language="javascript">

     		window.parent.location.href=window.parent.location.href;
            if(getTopWindow().RefreshHeader){
				getTopWindow().RefreshHeader();
		    }
    		</script>
    	  <%
          
      } else if("Delete".equals(strAction)) {%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    	  <% 
			//Action : Delete Meetings
		  	HashMap globalErrorMap = new HashMap();
          	String meetingIds[] = emxGetParameterValues(request, "emxTableRowId");
          	StringList nonDeletedMeetingIds= new StringList();
          	String struiType =  emxGetParameter(request,"uiType");          	
          	String globalErrorMsg=null;          
          	
          	StringBuffer itemList = new StringBuffer();
            itemList.append("<mxRoot>");
            itemList.append("<action>remove</action>");
                                    
          	for(int j=0;j<meetingIds.length;j++) {
          		HashMap errorMap = new HashMap();
          		String errorMsg=null; 
        		StringList idList = FrameworkUtil.split(meetingIds[j], "|");
          	  	if(null != idList && idList.size() > 1 ) {
	         		DomainObject objDom=null;
	        	  	try {
	        		    objDom=DomainObject.newInstance(context,(String)idList.get(0));
	        		    
	        	  	} catch(Exception ex) {}
	              	if(null!=objDom && objDom.isKindOf(context,DomainConstants.TYPE_MEETING)) {
			        	String[] objectIds = {meetingIds[j]};
	          			busMeeting = new Meeting(strObjectId);
	          			errorMap = busMeeting.deleteMeetingInvoke(context, strObjectId, objectIds, strSuiteKey, strAction, strNotification, jsTreeID);
			          	errorMsg = (String)errorMap.get("Message");
			          	if(errorMsg==null){
			          		if(!struiType.equalsIgnoreCase("table")){
			  		              String item  =  "<item id='"+idList.get(2)+"'/>";
			  		              itemList.append(item);
			  		             }
			          	}else{
			          		nonDeletedMeetingIds.add(meetingIds[j]);
	  		             }
	              	} else {
	            	  	String locale = context.getLocale().getLanguage();            	  
	            	  	globalErrorMsg = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Meeting.DeleteOnlyMeetingObjects");
	              	}
          		}          
           } //End for
           if(globalErrorMsg==null && nonDeletedMeetingIds.size()>0){ 
        	   String[] objectIds = new String[nonDeletedMeetingIds.size()];  
        	   nonDeletedMeetingIds.toArray(objectIds);
        	   globalErrorMap = busMeeting.deleteMeetingInvoke(context, strObjectId, objectIds, strSuiteKey, strAction, strNotification, jsTreeID);
        	   globalErrorMsg = (String)globalErrorMap.get("Message");
           }
           if(!struiType.equalsIgnoreCase("table")){
          		itemList.append("</mxRoot>");  
           }
          %>
    	      <script language="JavaScript">
				if(!<%=globalErrorMsg == null%>) {
    	       		alert("<%=globalErrorMsg%>");//XSSOK
    	       		if(parent.removedeletedRows) {
    		   			var responseXML  = "<%=XSSUtil.encodeForJavaScript(context, itemList.toString())%>";
    	  	  			parent.removedeletedRows(responseXML);
    	  	   		} else{
    	    	       		window.parent.location.href=window.parent.location.href;
    	    	       	}
    	       	} else {
  	       	if(parent.removedeletedRows) {
	   			var responseXML  = "<%=XSSUtil.encodeForJavaScript(context, itemList.toString())%>";
  	  			parent.removedeletedRows(responseXML);
  	   		} else{
    	       		window.parent.location.href=window.parent.location.href;
    	       	}
  		}
    	      </script>
    	  <%
      }else if("StartMeeting".equals(strAction)){
		  //Action : Start Meeting
          if("None".equals(meetingType)){
              // Promote the Meeting to In Progress 
              // No need to open any dialog window
          }
          String strMeetingId = emxGetParameter(request, "objectId");
          request.setAttribute("meetingId",strMeetingId);
          String strReturnPage = emxGetParameter(request, "sReturnPage");
          if("3D Visual Meeting".equals(meetingType)){
             %>
              <script language="JavaScript">
              var sMeetingType ='<%= XSSUtil.encodeForJavaScript(context, meetingType)%>';
              var strMeetingId = '<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>';
              //var 3dVMurl = "../teamcentral/emxTeamStartJoinCimmetryMeeting.jsp?meetingId="+strMeetingId+"&strAction=StartMeeting&webExURL="+sWebExURL+"&meetingType="+sMeetingType;
              //var url3dVM = "../teamcentral/emxTeamStartJoinCimmetryMeeting.jsp?meetingId="+strMeetingId+"&strAction=StartMeeting&webExURL="+sWebExURL+"&meetingType="+sMeetingType;
              //<Fix IR-071535V6R2014x>
	      //var url3dVM = "emxComponentsStartJoinCimmetryMeeting.jsp?meetingId="+strMeetingId+"&strAction=StartMeeting&meetingType="+sMeetingType;
	      var url3dVM = "../integrations/c3d/C3DStartJoinAutoVueMeeting.jsp?meetingId="+strMeetingId+"&strAction=StartMeeting&meetingType="+sMeetingType;
	      //</Fix IR-071535V6R2014x>
               //emxShowModalDialog(url3dVM, 575, 575);
			    document.location.href = url3dVM;
               //window.parent.location.href=window.parent.location.href;
              </script>
             <%
             }
      }else if("JoinMeeting".equals(strAction)){
		  //Action : Join Meeting
          String strMeetingId = emxGetParameter(request, "objectId");
          String strReturnPage = emxGetParameter(request, "sReturnPage");
          //Join Meeting
          %>
           <script language="JavaScript">
          var sMeetingId = '<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>';
          backURL = parent.window.location.href;
    	  backURL = backURL.substring(0,backURL.lastIndexOf("/")+1);
    	  var tempWebExURL = "";
    	  var selectElement = null;
    	  </script>
		   <%
		   if("3D Visual Meeting".equals(meetingType)){
		   %>
		       <script language="JavaScript">
	              var sMeetingType ='<%=XSSUtil.encodeForJavaScript(context, meetingType)%>';
	              var strMeetingId = '<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>';
	              //<Fix IR-071535V6R2014x>
		      //var url3dVM = "emxComponentsStartJoinCimmetryMeeting.jsp?meetingId="+strMeetingId+"&strAction=JoinMeeting&meetingType="+sMeetingType;
		      var url3dVM = "../integrations/c3d/C3DStartJoinAutoVueMeeting.jsp?meetingId="+strMeetingId+"&strAction=JoinMeeting&meetingType="+sMeetingType;
	              //</Fix IR-071535V6R2014x>
		      // emxShowModalDialog(url3dVM, 575, 575);
				  document.location.href = url3dVM;
	              
	    		</script>
	           <%
			    	  
		   }else{
		       if("MeetingDetails".equals(strReturnPage)){
			    	  %>
			    	  <script language="JavaScript">
			    	  selectElement = findFrame(getTopWindow().getWindowOpener().parent, "formViewDisplay").document.getElementsByName("meetingKey")[0];
					  </script>
			    	  <%
			    	  }else if("MeetingSummary".equals(strReturnPage)){
			    	  %>
						   <script language="JavaScript">
			    	  selectElement = findFrame(getTopWindow().getWindowOpener().parent, "detailsDisplay").document.getElementsByName("meetingKey")[0];
					   </script>
			    	  <%
			    	  }else if("GlobalMeetingSummary".equals(strReturnPage)){
			           	%>
								   <script language="JavaScript">
			           	selectElement = findFrame(getTopWindow().getWindowOpener().parent, "content").document.getElementsByName("meetingKey")[0];
						 </script>
			           	<%
			           }
			           	%>
							<script language="JavaScript">
						
			             	var tempWebExURL = selectElement.options[selectElement.selectedIndex].value;
			             	if ( tempWebExURL != "" ) {
				        		webExURL = tempWebExURL;
				      		}
			    		 var url = "emxComponentsStartJoinMeeting.jsp?returnPage=MeetingDetails&meetingId="+ sMeetingId+"&strAction=JoinMeeting&webExURL="+webExURL+"&backURL="+ backURL+"&fromPage=joinMeeting&sReturnPage=<%=XSSUtil.encodeForURL(context, sReturnPage)%>";
			    			//emxShowModalDialog(url, 575, 575);
							document.location.href = url;
			    			</script>
			          <%
		       
		   }
      }else if("CloseMeeting".equals(strAction)){
					//Action : Close Meeting
          //startMeetingId
          String strMeetingId = emxGetParameter(request, "objectId");
          String startMeetingId     = (String)session.getAttribute("startMeetingId");
          String sMeetingSiteStatus = ((startMeetingId == null)||("null".equals(startMeetingId)))?"false":"true";
          %>
                    
          <form name="closeMeetingForm" method="post">
  		  	<input type="hidden" name="meetingId" value=""/>
  		  	<input type="hidden" name="projectId" value=""/>
  			<input type="hidden" name="returnPage" value="MeetingDetails"/>
  			<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
  			<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>"/>
  			<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=strSuiteKey%></xss:encodeForHTMLAttribute>"/>
		 </form>
		 <script language="JavaScript">
		 //XSSOK
		 var statusObject= '<%=(strStatus.equals(stateInProgress))%>';
		 //XSSOK
		 var jsMeetinSiteStatus = '<%=sMeetingSiteStatus%>';
		 var meetingId = '<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>';
		 var sMeetingtype = '<%=XSSUtil.encodeForJavaScript(context, meetingType)%>';
		  </script>
		  <%
			if("WebEx".equals(meetingType)){ 
			
		  %>
		  <script language="JavaScript">
		 if((jsMeetinSiteStatus == false) && (statusObject == true))
    		{
    		//document.closeMeetingForm.meetingId.value = meetingId;
      		//document.closeMeetingForm.action = "emxComponentsCloseMeeting.jsp";
      		//document.closeMeetingForm.submit();
      		submitWithCSRF("emxComponentsCloseMeeting.jsp?meetingId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&returnPage=MeetingDetails&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, strSuiteKey)%>", document);
      		window.parent.location.href=window.parent.location.href;
      		
      		
      		} else {
    				alert("<emxUtil:i18n localize="i18nId">emxComponents.Common.WebexMeetingProgressalert</emxUtil:i18n>");
    		}
		 </script>
          
        <%  
		  }else{
			
			%>
			 <script language="JavaScript">
				submitWithCSRF("emxComponentsCloseMeeting.jsp?meetingId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&returnPage=MeetingDetails&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, strSuiteKey)%>", document);
      		window.parent.location.href=window.parent.location.href;
				 </script>
				<%
		}
         
      }else if("DeleteAgendaItem".equals(strAction)){%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
		  <% //Action : Delete Agenda Items
		  //Added for Bug 370831
          if(!stateInProgress.equals(strStatus))
		  {
          String AgedaItem[] = emxGetParameterValues(request, "emxTableRowId");
          //deleteMeetingInvoke(Context context, String objectId, String[] meetingIds, String suiteKey, String action, String notification, String jsTreeID)
          busMeeting.deleteAgendaItemInvoke(context, strObjectId, AgedaItem, strSuiteKey, strAction, strNotification, jsTreeID);
         %>
    	  <script language="javascript">

     		window.parent.location.href=window.parent.location.href;
    		</script>
    	  <%
		  }else
		  {
		      String deleteInProgress = EnoviaResourceBundle.getProperty(context,"emxComponents.Meeting.AgendaItem.DeleteInProgress");
		      %>
	    	  <script language="javascript">
	    	 	alert("<%=deleteInProgress%>");
	    		</script>
	    	  <%
		  }
      }else if("CreateAgendaItem".equals(strAction)){%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
				<% // Action : Create Agenda Item
          busMeeting.createAgendaItemInvoke(context, strObjectId, strSuiteKey, strAction, strNotification, jsTreeID);
      }else if("CreateMeeting".equals(strAction)){%>
    	  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
		  <% // Action : Create Meeting 
          String userRole = null;
          String ErrorMsg = "";
          matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
          String strMeetingType = emxGetParameter(request, "MeetingType");
          String objectId = emxGetParameter(request, "objectId");
          String strMeetingId = emxGetParameter(request, "newObjectId");
          // Set Attributes on Meeting Object
          String strMeetingSubject           = emxGetParameter(request, "Subject");
          String strMeetingLocation       = emxGetParameter(request, "MeetingLocation");
          String strContext              = emxGetParameter(request, "Context");
          String strMeetingDate      = emxGetParameter(request, "MeetingDate");
          String strMeetingStartTime      = emxGetParameter(request, "StartTime");
          String strMeetingDuration       = emxGetParameter(request, "Duration");
          String strConferenceCallNumber    = emxGetParameter(request, "ConferenceCallNumber");
          String strOnlineMeetingInstructions    = emxGetParameter(request, "OnlineMeetingInstructions");
          String strMeetingDesc = emxGetParameter(request, "Description");
          strMeetingStartTime      = strMeetingStartTime.substring(strMeetingStartTime.indexOf("~")+1, strMeetingStartTime.length());
          double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();
          String strMeetingStartDateTime = eMatrixDateFormat.getFormattedInputDateTime(ctx,strMeetingDate,strMeetingStartTime,clientTZOffset,request.getLocale());
          AttributeType attrLocation						= new AttributeType(DomainObject.ATTRIBUTE_MEETING_LOCATION);
          AttributeType attrContext						= new AttributeType("Meeting Context");
    	  AttributeType attrMeetingType					= new AttributeType("Meeting Type");
    	  AttributeType attrMeetingTitle					= new AttributeType(DomainConstants.ATTRIBUTE_TITLE);
    	  AttributeType attrMeetingStartDateTime					= new AttributeType(DomainObject.ATTRIBUTE_MEETING_START_DATETIME);
    	  AttributeType attrStartTime						= new AttributeType(DomainObject.ATTRIBUTE_MEETING_LOCATION);
    	  AttributeType attrMeetingDuration				= new AttributeType(DomainObject.ATTRIBUTE_MEETING_DURATION);
    	  AttributeType attrConferenceCallNumber			= new AttributeType(DomainObject.ATTRIBUTE_CONFERENCE_CALL_NUMBER);
    	  AttributeType attrConferenceCallAccessCode		= new AttributeType(DomainObject.ATTRIBUTE_CONFERENCE_ACCESS_CODE);
    	  AttributeType attrOnlineMeetingProvider			= new AttributeType(DomainObject.ATTRIBUTE_MEETING_PROVIDER);
    	  AttributeType attrOnlineMeetingInstructions     = new AttributeType(DomainObject.ATTRIBUTE_MEETING_INSTRUCTIONS);
    	  AttributeType attrTypeOwner    				= new AttributeType(DomainObject.ATTRIBUTE_MEETING_OWNER);
    	  
    	  AttributeList attrListMeeting   = new AttributeList();
    	  
    	  if(strMeetingStartDateTime!=null && strMeetingStartDateTime.length()!=0 && !"".equals(strMeetingStartDateTime) )
   		  {
   		    	attrListMeeting.addElement(new Attribute(attrMeetingStartDateTime, strMeetingStartDateTime));
   		  }
   		  if(strMeetingLocation!=null && strMeetingLocation.length()!=0 && !"".equals(strMeetingLocation) )
   		  {
   		   		attrListMeeting.addElement(new Attribute(attrLocation, strMeetingLocation));
   		  }
   		  if(strMeetingType!=null && strMeetingType.length()!=0 && !"".equals(strMeetingType) )
   		  {
   				attrListMeeting.addElement(new Attribute(attrMeetingType, strMeetingType));
   		  }
   		  if(strMeetingSubject!=null && strMeetingSubject.length()!=0 && !"".equals(strMeetingSubject) )
   		  {
   				attrListMeeting.addElement(new Attribute(attrMeetingTitle, strMeetingSubject));
   		  }
   		  if(strMeetingDuration!=null && strMeetingDuration.length()!=0 && !"".equals(strMeetingDuration) )
   		  {
   				attrListMeeting.addElement(new Attribute(attrMeetingDuration, strMeetingDuration));
   		  }
   		  if(strConferenceCallNumber!=null && strConferenceCallNumber.length()!=0 && !"".equals(strConferenceCallNumber) )
   		  {
   				attrListMeeting.addElement(new Attribute(attrConferenceCallNumber, strConferenceCallNumber));
   		  }
   		  if(strOnlineMeetingInstructions!=null && strOnlineMeetingInstructions.length()!=0 && !"".equals(strOnlineMeetingInstructions) )
   		  {
   		  		attrListMeeting.addElement(new Attribute(attrOnlineMeetingInstructions, strOnlineMeetingInstructions));
   		  }
   		  com.matrixone.apps.common.Person busPerson=com.matrixone.apps.common.Person.getPerson(ctx);
   		  DomainObject contextObject = DomainObject.newInstance(ctx, objectId);
   		
   		 //The Context Object where Meeting is to be connected 
   		 // The Context can be Project, Issue etc..
   		
         DomainObject newMeetingObj       = DomainObject.newInstance(ctx, strMeetingId);
         //newMeetingObj.open(ctx);
         //String meetingName = newMeetingObj.getInfo(ctx,DomainConstants.SELECT_NAME);
         //System.out.println("meetingName :"+meetingName+ "   strMeetingId :" + strMeetingId);
         newMeetingObj.setAttributes(ctx, attrListMeeting);
         newMeetingObj.setDescription(ctx,strMeetingDesc);
         //newMeetingObj.close(ctx);
       
         AttributeList attrListMeetingAttendeesRel = new AttributeList();
         AttributeList attrListMeetingContextRel   = new AttributeList();
         attrListMeetingContextRel.addElement(new Attribute(attrTypeOwner, "Yes"));
         attrListMeetingAttendeesRel.addElement(new Attribute(attrTypeOwner, "Yes"));

         Relationship relAssignedMeetings = busPerson.connect(ctx,new RelationshipType(DomainObject.RELATIONSHIP_ASSIGNED_MEETINGS),true,newMeetingObj);
         Relationship relMeetingContext = null;

         try {
	         //If login person doesn't have fromconnect access on the Context object, Meeting object creation fails
	         //to over come this issue we are pushing the context before connecting meeting object with the context object.
			 //Modified:05-Apr-09:yox:R207:372441
             ContextUtil.pushContext(ctx, PropertyUtil.getSchemaProperty(ctx, "person_UserAgent"), null, ctx.getVault().getName());
         
    	     relMeetingContext   = contextObject.connect(ctx,new RelationshipType(DomainObject.RELATIONSHIP_MEETING_CONTEXT),true,newMeetingObj);
        	 relMeetingContext.setAttributes(ctx, attrListMeetingContextRel);
        	 relAssignedMeetings.setAttributes(ctx, attrListMeetingAttendeesRel);
			  //End:R207:372441
         } catch(Exception e){
             e.printStackTrace();
       	  	 throw e;
         } finally {
             ContextUtil.popContext(ctx);
         }
         //<Fix IR009245>
         refreshTree = true;
         newMeetingId = strMeetingId;
         //</Fix IR009245>
   }
      
  }catch(Exception e){
      //<Fix IR009245>
      refreshTree = false;
      //</Fix IR009245>
	  throw e;
  }
  
  %>
