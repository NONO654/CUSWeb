<%--
   C3DStartJoinAutoVueMeeting.jsp
   
   This file is nothing but old emxComponentsStartJoinAutoVueMeeting.jsp file.
   It has renamed and modified and it will be entry point in C3D side Meeting Support handling.

   Copyright (c) 1992-1998 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsStartJoinCimmetryMeeting.jsp.rca 1.1 Wed Nov 26 11:34:04 2008 ds-lmanukonda Experimental $
   
   --------------------------------------------------------------------------------------------------
	Sr. 	Date				By				Description
--------------------------------------------------------------------------------------------------
	1. 		???					???		Created
	2.		11 July 2016		MAL3	Checked in Files not getting opened as the file exists in major version and not in the active version.
--------------------------------------------------------------------------------------------------
--%>

<%@include file = "../../emxUICommonAppInclude.inc"%>
<%@include file = "../../components/eServiceUtil.inc"%>
<%@include file = "../../components/emxComponentsUtil.inc"%>

<%@page import="matrix.util.* "%>
<%@page import="matrix.db.* "%>
<%@page import="java.util.* "%>

<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>

<script language=javascript>

function joinMeeting(meetingKey,meetingId,meetingURL) {
  meetingURL +='&action=JoinRTC';
  meetingURL +='&CSI_ClbAction=JOIN';
  meetingURL +='&CSI_ClbSessionID=' + meetingId;
  //alert("***Meeting URL for Join Meeting: " + meetingURL);
  document.location.href = meetingURL;
}

function StartMeetingWithSingleDocument(meetingURL, meetingID)
{
	meetingURL +='&action=StartRTC';	
	meetingURL +='&CSI_ClbAction=INIT';
	meetingURL +='&CSI_ClbSessionID=' + meetingID;
	document.location.href = meetingURL;
}

function ShowAttachmentSelectionPage(meetingURL, meetingID, pageHeader)
{
	//var pageHeader = "Select a document to start 3D Visual Meeting in AutoVue.";
	var jspcall = 
	"./../../common/C3DMeetingAttachmentsSelectionPage.jsp?program=emxCommonDocumentUI:getDocuments&parentRelName=relationship_MeetingAttachments&table=C3DAPPDocumentSummary&selection=single&sortColumnName=Name&sortDirection=ascending&header=" + pageHeader + "&toolbar=null&topActionbar=null&emxSuiteDirectory=components&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=" + meetingID  + "&parentOID=" + meetingID + "&meetingID=" + meetingID + "&meetingURL=" + meetingURL;

	window.location.href = jspcall;
}

</script>
<%
try 
{
 String m_Lang = request.getHeader("Accept-Language");
 String I18NResourceBundle = "c3dIntegrationStringResource";

 String strPageHeaderText = i18nStringNowUtil("c3dIntegration.3dVisualMeeting.AttachmentSelectionHeaderText", I18NResourceBundle, m_Lang);

 String strMeetingId = emxGetParameter(request, "meetingId");
 String strAction    = emxGetParameter(request, "strAction");
 String strMeetingType = emxGetParameter(request, "meetingType");
 String errorMessage = emxGetParameter(request,"errorMessage");
 String status       = emxGetParameter(request,"status");
 String fromPage     = emxGetParameter(request,"fromPage");

 int	attachmentsCount = 0;
 boolean bUpdateMtngStatus=false;

 BusinessObject busPerson = JSPUtil.getPerson(context, session);

 String strPersonId = busPerson.getObjectId();
 
 if(status == null || "null".equals(status))
 {
   status = "";
 }
 
 if(fromPage == null || "null".equals(fromPage))
 {
   fromPage = "";
 }

  DomainObject meetingObject = DomainObject.newInstance(context, strMeetingId);
  StringList selectTypeStmts = new StringList();
  selectTypeStmts.add(DomainObject.SELECT_ID);
  StringList selectRelStmts  = new StringList();
  Pattern typePattern = new Pattern("*");
  Pattern relPattern = new Pattern("Meeting Attachments");
  MapList attachmentList = meetingObject.getRelatedObjects(context,
          relPattern.getPattern(),  //String relPattern
          typePattern.getPattern(), //String typePattern
          selectTypeStmts,          //StringList objectSelects,
          selectRelStmts,                     //StringList relationshipSelects,
          false,                    //boolean getTo,
          true,                     //boolean getFrom,
          (short)1,                 //short recurseToLevel,
          "",                       //String objectWhere,
          "",                       //String relationshipWhere,
		  0);						//int limit : Number of objects to be returned. 0 is for all.
//[xlv:DeprecationChange]:START
//Removed following parameters from function call and add limit to indicate no. of objects being returned.
		  // null,                     //Pattern includeType,
         // null,                     //Pattern includeRelationship,
         // null);                  // Deprication
//[xlv:DeprecationChange]:END

  StringList objectSelects = new StringList();
  String SELECT_ACTIVE_VERSION_ID = "from[Active Version].to.id";
  String SELECT_ACTIVE_VERSION_FILENAME = "from[Active Version].to.format.file.name";	//[2]
  objectSelects.add(DomainObject.SELECT_CURRENT);
  Map attrMap = meetingObject.getInfo(context,objectSelects);
  String currentState = (String)attrMap.get(DomainObject.SELECT_CURRENT);

  String baseURL = Framework.getFullClientSideURL(request,response,"");

  String strMeetingURL = baseURL + "/servlet/" + "C3DControllerServlet?";

  if(strAction.equals("StartMeeting"))
  {
	System.out.println("[C3D:StartJoinAVMeeting]:Action: Start Meeting.");

	System.out.println("[C3D:StartJoinAVMeeting]: No. of Attachments:" + attachmentList.size()); 
	
	if(1 == attachmentList.size())
	{
		System.out.println("[C3D:StartJoinAVMeeting]: Only single attachment present.");
		
		Map attachedFileMap = (Map)attachmentList.get(0);
		String attachedFileObjectId = (String)attachedFileMap.get(DomainObject.SELECT_ID);
		System.out.println("[C3D:StartJoinAVMeeting]: Opening Bus ID: " + attachedFileObjectId);
		DomainObject meetingFileObject = DomainObject.newInstance(context, attachedFileObjectId);
		objectSelects = new StringList();
		objectSelects.add(CommonDocument.SELECT_MOVE_FILES_TO_VERSION);
		objectSelects.add(SELECT_ACTIVE_VERSION_ID);
		attrMap = meetingFileObject.getInfo(context, objectSelects);
		boolean moveFilesToVersion = Boolean.parseBoolean((String) attrMap.get(CommonDocument.SELECT_MOVE_FILES_TO_VERSION));
		
		if (moveFilesToVersion)
		{				
			StringList tmpList = (StringList)attrMap.get(SELECT_ACTIVE_VERSION_ID);
			String attachedFileObjectIdMinor = (String) tmpList.elementAt(0);
			System.out.println("[C3D:StartJoinAVMeeting]: Bus ID of doc to be opened: " + attachedFileObjectIdMinor);
			//[2]: START
			String minorFileName  = (String)attrMap.get(SELECT_ACTIVE_VERSION_FILENAME);									
			if(minorFileName != null && !minorFileName.isEmpty())	
				attachedFileObjectId = attachedFileObjectIdMinor;
			else
				System.out.println("[C3D:StartJoinAVMeeting]: File Not present in Minor");
			//[2]: END
		}

		BusinessObject attachedObject = new BusinessObject(attachedFileObjectId);
		attachedObject.open(context);

		strMeetingURL += "&id=" + attachedObject.getObjectId();
		
		FormatList formats =attachedObject.getFormats(context);

		for (int i= 0; i< formats.size(); i++)
		{
			String format = ((matrix.db.Format)formats.get(i)).getName();

			FileList list = attachedObject.getFiles(context,format);
			for (int j = 0; j < list.size(); j++)
			{
			   matrix.db.File file = (matrix.db.File)list.get(j);
			   strMeetingURL += "&format=" + format;
			   strMeetingURL += "&filename=" + file.getName();
			   System.out.println("[C3D:StartJoinAVMeeting]: Attachment to be opened: " + file.getName() +" Format: " + format + " BusID: " + attachedObject.getObjectId() );
			   
			   //break after first format information is available.
			   i = formats.size(); //to break outer for loop.
			   break;
			}
		}
		attachedObject.close(context);
		%>
		<script language=Javascript>
		   StartMeetingWithSingleDocument('<%=strMeetingURL%>','<%=strMeetingId%>');
		</script>
		<%
			bUpdateMtngStatus = true;
		}
		else if(1 < attachmentList.size())
		{
		%>
		<script language=Javascript>
			//Launch a Meeting attachements page from which user will be able to select one attachement and start meeting.
			ShowAttachmentSelectionPage('<%=strMeetingURL%>','<%=strMeetingId%>', '<%=strPageHeaderText%>');
		</script>
		<%
			bUpdateMtngStatus = true;
		}
		else if(attachmentList.size() <= 0)
		{
			System.out.println("[C3D:StartJoinAVMeeting]: Meeting object does not have any attachment!");
			//strMeetingURL += "&id=" + "&format=" + "&filename=" ;
			//try to show an alert about no documents present in meeting.
			String sNoAttachmentErr = i18nStringNowUtil("c3dIntegration.3dVisualMeeting.NoAttachmentsError", I18NResourceBundle, m_Lang);
			%>
			<script language="javascript"> 			 
			//IR-263506V6R2014x: single quote in french language strings causing issue.
			//so used double quotes.
			alert("<%=sNoAttachmentErr%>");
			window.close();
			</script>
			<%
		}

		//code to update meeting status.
		//[IR-253689V6R2014x]Moved promotion of meeting to InProgress in side StartRTCApplet.
		//If we changes status here and later if meeting is not started then its status!
		/*
		try
		{
		   ContextUtil.startTransaction(context, true);
		   if (bUpdateMtngStatus == true && null != currentState && "Scheduled".equals(currentState))
		   {
			  BusinessObject busMeetingObj = new BusinessObject(strMeetingId);
			  busMeetingObj.open(context);
			  busMeetingObj.promote(context);
			  busMeetingObj.close(context);
		   }
		   ContextUtil.commitTransaction(context);
		}
		catch (Exception e)
		{
		   System.out.println(e.toString());
		}*/
		
	}

	//Join Meeting Processing.
	String strMeetingKeyAttr =  Framework.getPropertyValue( session, "attribute_MeetingKey" );
	BusinessObject busMeeting = new BusinessObject(strMeetingId);
	String strMeetingKey = getAttribute(context, session, busMeeting, strMeetingKeyAttr);
	 
	if (strAction.equals("JoinMeeting") )
	{
		System.out.println("[C3D:StartJoinAVMeeting]:Action: Join Meeting.");
		if((errorMessage == null || "".equals(errorMessage) || "null".equals(errorMessage)) && fromPage.equals("")) 
		{
%>
		 <script language=Javascript>
		   joinMeeting('<%=strMeetingKey%>','<%=strMeetingId%>','<%=strMeetingURL%>')
		 </script>
<%
		} 
		else 
		{
		   session.setAttribute("error.message", errorMessage);
		}
	}
}
catch (Exception ex)
{
  ex.printStackTrace();
}
%>

