<%-- emxMeetingProcess.jsp -- process page to promote, demote, Start, Join Meeting object
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

--%>
<%@page import="com.matrixone.apps.common.Meeting"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="emxComponentsUtil.inc"%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<head>
	<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
</head>
<body>
</body>
<%
    String ATTRIBUTE_MEETING_TYPE = PropertyUtil.getSchemaProperty(context,"attribute_MeetingType");
	String strObjectId = emxGetParameter(request, "objectId");
    String errorMsg = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Alert.UnsupportedMeetingType");

    String meetingType = "";

    if (strObjectId != null && !"".equals(strObjectId)) {
		DomainObject domObj = DomainObject.newInstance(context,
			strObjectId);
		if (DomainConstants.TYPE_MEETING.equals(domObj.getInfo(context,
			DomainConstants.SELECT_TYPE))) {
		    Meeting busMeeting = new Meeting(strObjectId);

		    StringList objsel = new StringList();
		    objsel.add("attribute["+ATTRIBUTE_MEETING_TYPE+"]");

		    Map busWSelectMeeting = busMeeting.getInfo(context, objsel);
		    meetingType = (String) busWSelectMeeting
			    .get("attribute["+ATTRIBUTE_MEETING_TYPE+"]");
		}
    }
%>
<script language="javascript">
	var meetingType = "<%=XSSUtil.encodeForJavaScript(context, meetingType)%>";
	var errorMsg = "<%=errorMsg%>";
	if("None"==meetingType){
		contentURL =  "../components/emxMeetingProcess.jsp?action=Promote&notification=Yes&sReturnPage=null&submitAction=refreshCaller&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";	
		submitWithCSRF(contentURL, window);
	}else if("3D Visual Meeting"==meetingType){
	 	var contentURL = "../components/emxMeetingProcess.jsp?action=StartMeeting&notification=Yes&sReturnPage=MeetingDetails&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&targetLocation=popup";
	 	showModalDialog(contentURL, "600", "500", false);
	}else{
	alert(errorMsg+" "+meetingType);
	}
</script>

