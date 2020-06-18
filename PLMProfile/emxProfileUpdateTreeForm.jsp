<%-- emxProfileUpdateTreeForm.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProfileCheckInstance"%>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileUtils" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProcessingGroup" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.Type" %>
<%
	System.out.println("BEGIN emxProfileUpdateTreeForm.jsp");
	String objectId = emxGetParameter(request,"objectId");
	String profileId = null;
	System.out.println(":: "+objectId);
	if(objectId != null) {
		String objectType = ProfileUtils.getType(context, objectId);
		if(ProfileUtils.isTypeKindOf(context, objectType, Type.PLMProfileCheckInstance)){
			PLMProfileCheckInstance instanceCheck = PLMProfileCheckInstance.getInstance(context, objectId);
			if(instanceCheck != null) {
				profileId = instanceCheck.getProfile(context);
			}
		}
		if(ProfileUtils.isTypeKindOf(context, objectType, Type.PLMProfileProcessingGroup)){
			PLMProcessingGroup currentpg = PLMProcessingGroup.getInstance(context, objectId);
			if(currentpg != null){
				profileId = currentpg.getProfile(context);
			}
		}
		System.out.println(":: "+profileId);
		if(profileId != null) {%>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>
			<script language="javascript">
			  var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
			  
			  if(contentFrame) {
			   contentFrame.document.location.href = "emxTree.jsp?objectId=<%=profileId%>";
			  }
			  getTopWindow().refreshTablePage();
			  </script>
	<%	}
			
	}
	System.out.println("END emxProfileUpdateTreeForm.jsp");
  %>
