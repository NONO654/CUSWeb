<%--  MCADMessageFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%

  MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
  Context context								= integSessionData.getClonedContext(session);

  String messageHeader		= emxGetParameter(request, "messageHeader");
  String messageContent		= emxGetParameter(request, "message");
  String refresh			= emxGetParameter(request, "refresh");
  String instanceName		= emxGetParameter(request, "instanceName");
  String instanceRefresh	= emxGetParameter(request, "instanceRefresh");
  String objectID			= emxGetParameter(request, "objectID");
  String refreshmode		= emxGetParameter(request, "refreshmode");

  if(messageHeader != null)
	{
	messageHeader   = MCADUrlUtil.hexDecode(messageHeader);
	session.setAttribute("mcadintegration.messageHeader", messageHeader);
	}
  if(messageContent != null)
	session.setAttribute("mcadintegration.message", messageContent);
%>

<html>
<head>

<% 
	if("true".equalsIgnoreCase(refresh)) 
	{
%>


<script language="JavaScript">

	var refreshmode = "<%=XSSUtil.encodeForJavaScript(context,refreshmode)%>";

	var integrationFrame = getIntegrationFrame(this);

	if(integrationFrame != null)
	{

		var refreshFrame	= integrationFrame.getActiveRefreshFrame();

		if(refreshFrame != null)
		{
			var objForm			= refreshFrame.document.forms['emxTableForm'];

			var commandName = (objForm && objForm.commandName) ? objForm.commandName.value : "";

			if (refreshFrame && commandName!="Navigate") // not refreshing navigate page
			{
				var refreshFrameURL	= refreshFrame.location.href;

				if(refreshFrame.name == "content")
				{
					if(refreshmode != null && refreshmode == "replace")
					{
						var refreshFrameURL = "../common/emxTree.jsp?";
						refreshFrameURL += "targetLocation=" + refreshFrame.name;
						refreshFrameURL += "&relId=null";
						refreshFrameURL += "&parentOID=<%=XSSUtil.encodeForURL(context,objectID)%>";
						refreshFrameURL += "&objectId=<%=XSSUtil.encodeForURL(context,objectID)%>";
						refreshFrameURL += "&jsTreeID=null";
					}

					//alert("refreshFrameURL=" + refreshFrameURL);
					refreshFrame.location.href = refreshFrameURL; //using refreshFrame.reload() causes a bug on FireFox
				}
				else if(refreshFrame.name == "structure_browser") //refreshing the Full Search
				{	
					var searchHiddenForm	= null;
					var searchForm			= null;

					if(null != refreshFrame.parent && typeof refreshFrame.parent != "undefined")
					{
						searchHiddenForm	= refreshFrame.parent.document.forms['full_search_hidden'];
						searchForm			= refreshFrame.parent.document.forms['full_search'];
					}

					if(null != searchHiddenForm && typeof searchHiddenForm != "undefined" && null != searchHiddenForm.action && searchHiddenForm.action != "")
						searchHiddenForm.submit();
					else if(null != searchForm && typeof searchForm != "undefined" && null != searchForm.action && searchForm.action != "")
						searchForm.submit();
					else
						refreshFrame.location.href = refreshFrame.location.href;
				}
				else
				{
					refreshFrame.location.reload();
				}

			}
			else
			{
				//refresh navigate page
				refreshFrame.parent.reloadNavigateTable('<%=XSSUtil.encodeForURL(context,objectID)%>');
			}
		}
		else
		{
			targetFrame =top.opener.top.findFrame(top.opener.top,"searchContent");
			
			if(targetFrame)
			{					
				targetFrame.refreshSearchResultPage();
			}
			else
			{
				targetFrame =top.opener.top.findFrame(top.opener.top,"detailsDisplay");
				
				if(targetFrame)
				{					 
					targetFrame.location.href = targetFrame.location.href;
				}					
			}
		}
	}

</script>
<% 
	}
%>


</head>
<frameset rows="65,*,65" frameborder="no">
	<frame src="MCADGenericHeaderPage.jsp" name="headerFrame" scrolling=no>
	<frame src="MCADMessageContent.jsp?isContentHtml=true" name="contentFrame">
	<frame src="MCADGenericFooterPage.jsp?buttonName=Close" name="footerFrame" scrolling=no>
</frameset>
<html>
