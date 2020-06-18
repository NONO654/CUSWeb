<%@page import="com.matrixone.apps.framework.lifecycle.LifeCycleUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "matrix.db.ClientTask"%>
<%@page import = "matrix.db.ClientTaskList"%>
<%@page import = "matrix.db.ClientTaskItr"%>
<%@page import = "matrix.db.JPO"%>

<%	

	String sOID 			= emxGetParameter(request, "objectId");
	String sAction 			= emxGetParameter(request, "action");	
	String sLanguage 		= request.getHeader("Accept-Language");
	BusinessObject bObject 	= new BusinessObject(sOID);
	String timeZone=(String)session.getAttribute("timeZone");
	
	String initargs[] = {};
	HashMap paramsJPO = new HashMap();
	paramsJPO.put("objectId",sOID);		
	paramsJPO.put("language",(String)sLanguage);
	String msg = "";
	if("refreshHeader".equals(sAction)){
		try{
		String documentDropRelationship = emxGetParameter(request, "documentDropRelationship");
		String documentCommand = emxGetParameter(request, "documentCommand");
		String sMCSURL = emxGetParameter(request, "MCSURL");	
		String showStatesInHeader = emxGetParameter(request, "showStatesInHeader");
		String showDescriptionInHeader = emxGetParameter(request, "showDescriptionInHeader");
		String imageDropRelationship = emxGetParameter(request, "imageDropRelationship");
	 	String imageManagerToolbar = emxGetParameter(request, "imageManagerToolbar");
		String imageUploadCommand = emxGetParameter(request, "imageUploadCommand");
		
		paramsJPO.put("MCSURL", sMCSURL);
		paramsJPO.put("documentDropRelationship", documentDropRelationship);
		paramsJPO.put("documentCommand", documentCommand);
		paramsJPO.put("showStatesInHeader", showStatesInHeader);
		paramsJPO.put("showDescriptionInHeader", showDescriptionInHeader);
		paramsJPO.put("imageDropRelationship", imageDropRelationship);
		paramsJPO.put("timeZone", timeZone);
 		paramsJPO.put("imageManagerToolbar", imageManagerToolbar);
		paramsJPO.put("imageUploadCommand", imageUploadCommand); 
		StringBuilder sbHeaderContents	= (StringBuilder)JPO.invoke(context, "emxExtendedHeader", initargs, "getHeaderContents", JPO.packArgs (paramsJPO), StringBuilder.class);
		%>
		<%=sbHeaderContents%>
		<%		
		}catch(Exception e){
			e.printStackTrace();
		}
	}else{
		%>
<html>
	<script type="text/javascript" src="scripts/emxUICore.js"></script>
	<script type="text/javascript">
		function completeClick() {
			if(parent.clickOnExtHdState && parent.clickOnExtHdState == true) {
				parent.clickOnExtHdState = false;
			}
		}
		<%
		try{
            String strKindOfPLMEntity = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_PLMEntity") +"]";
            String sIsVPLMEntity  = (String)new DomainObject(sOID).getInfo(context,strKindOfPLMEntity);
            if("TRUE".equalsIgnoreCase(sIsVPLMEntity)){
				throw new Exception("emxFramework.Type.PLMEntity.Engineering");
            }

			if("promote".equals(sAction)) {	
				msg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed", "emxFrameworkStringResource",request.getHeader(	"Accept-Language"));
				bObject.promote(context);
			} else if("demote".equals(sAction)) {
				msg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.DemotionFailed", "emxFrameworkStringResource",request.getHeader("Accept-Language"));
				bObject.demote(context);
			}
			paramsJPO.put("content"		, "status"	);
			paramsJPO.put("timezone",(String)session.getAttribute("timeZone"));
			DomainObject dObject    = new DomainObject(sOID);
	        Access  access = dObject.getAccessMask(context);
	        boolean readAccessFlag=access.hasReadAccess();
	      	String[] aResult=new String[2];
			if(readAccessFlag) {
			 aResult = (String[])JPO.invoke(context, "emxExtendedHeader", initargs, "genHeaderFromJSP", JPO.packArgs (paramsJPO), String[].class);		
	        } else {
	        	%>
	        	 var contentFrame = getTopWindow().findFrame(getTopWindow(),"content");
	             if(contentFrame) {
	            	 contentFrame.document.location.href = "emxTreeNoDisplay.jsp";
	             }
	        <%
	        }
			
			%>	
			getTopWindow().deletePageCache();
			parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href = parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href.replace("persist=true", "persist=false");	
			parent.getTopWindow().jQuery(parent.getTopWindow().document).find('#extendedHeaderStatus').html("<%= XSSUtil.encodeForJavaScript(context, aResult[0])%>");
			parent.getTopWindow().jQuery(parent.getTopWindow().document).find('#extendedHeaderModified').html("<%= XSSUtil.encodeForJavaScript(context, aResult[4])%>");
			parent.getTopWindow().jQuery(getTopWindow().document).find('#headerDropZone').css('display',"<%= XSSUtil.encodeForHTML(context, aResult[1])%>");
			completeClick();
<%		
		}
	catch (Exception e) {
		
		StringBuilder sbMessages	= new StringBuilder();
		String errorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",new Locale(sLanguage),"emxFramework.LifeCycle.OperationFailed");
		String sMessages="";
		if(e.getMessage().contains("Cannot promote - all requirements not satisfied")){
			errorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",new Locale(sLanguage),"emxFramework.LifeCycle.PromotionFailed.ErrorMessage");
		}else if(e.getMessage().contains("emxFramework.Type.PLMEntity.Engineering")){
			errorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",new Locale(sLanguage),"emxFramework.Type.PLMEntity.Engineering");
		}else{
			LifeCycleUtil.reorganizeClientTaskMessages(context, msg);
			ClientTaskList listNotices 	= context.getClientTasks();	
			ClientTaskItr itrNotices 	= new ClientTaskItr(listNotices);
			int iReason=-1;
			String warningHeader = EnoviaResourceBundle.getProperty(context, null, "emxFramework.MessageHeader.Warning", context.getLocale());
			String noticeHeader = EnoviaResourceBundle.getProperty(context, null, "emxFramework.MessageHeader.Notice", context.getLocale());
			String errorHeader = EnoviaResourceBundle.getProperty(context, null, "emxFramework.MessageHeader.Error", context.getLocale());

			while (itrNotices.next()) {
				ClientTask clientTaskMessage =  itrNotices.obj();
				iReason = clientTaskMessage.getReason();
				String emxMessage = (String)clientTaskMessage.getTaskData();
		 		if(emxMessage.contains("Warning #1501905")){
			        continue;
			     }
				String sHeaderText= null;
				switch (iReason) {
					case 3 : sHeaderText = noticeHeader; break;
					case 4 : sHeaderText = warningHeader; break;
					case 5 : sHeaderText = errorHeader; break;
					default: sHeaderText = null;
				}
				StringBuffer sbMsg = new StringBuffer();
				for (int emxi = 0; emxi < emxMessage.length(); emxi++) {
					char ch = emxMessage.charAt(emxi);
					Character CH = new Character(ch);
					int hashCode = CH.hashCode();
					if (hashCode == 10 && emxi < emxMessage.length()-1) {  // hashcode: 10 -check for carriage return
					  sbMsg  = sbMsg.append("\\n");
					}else{
						sbMsg  = sbMsg.append(ch);
					}
				}
				if(sbMessages.length() <= 0) {
					sbMessages.append(sHeaderText+":").append("\\n\\r").append(sbMsg);
				} else {
					sbMessages.append("\\n\\r").append(sHeaderText+":").append("\\n\\r").append(sbMsg);
				}
			
				if((sbMessages.toString()).isEmpty()){
					int errCode = 0;
					ErrorMessage mxErrMsg = new ErrorMessage(e.getMessage()); 

					if (mxErrMsg != null)
						errCode = mxErrMsg.getErrorCode();

					if (errCode == 5000001){
						String sErrorMsg = mxErrMsg.getMessage();
						int pos = sErrorMsg.indexOf("#5000001:");
						if (pos > -1){
							sErrorMsg = sErrorMsg.substring(pos+9).trim();
							sbMessages.append(sErrorMsg);
						}
					}
				}
			}
			sMessages=sbMessages.toString();
			errorMsg = sMessages;
				if("promote".equals(sAction)) {
						String stringPromotionMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed","emxFrameworkStringResource",request.getHeader("Accept-Language"));
						if(!errorMsg.contains(stringPromotionMsg)){
							errorMsg = stringPromotionMsg + errorMsg;
						}
					} else if("demote".equals(sAction)) {
						String stringDemotionMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.DemotionFailed","emxFrameworkStringResource",request.getHeader("Accept-Language"));
						if(!errorMsg.contains(stringDemotionMsg)){
							errorMsg = stringDemotionMsg + errorMsg;
						}
					}
		}
		errorMsg = errorMsg.replace("\"", "\\\"");
		errorMsg =errorMsg.replaceAll("[\\n\\r]+", "\\\\n");	
		context.clearClientTasks();
		
%>
		alert("<%=errorMsg%>");
		completeClick();
	<% } %>
	</script>	
</html>
<% } %>
