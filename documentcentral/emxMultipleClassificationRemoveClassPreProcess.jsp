<%-- emxMultipleClassificationRemoveClassPreProcess.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMultipleClassificationRemoveClassPreProcess.jsp.rca 1.3.3.2 Wed Oct 22 16:02:39 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";

    String strLanguage = request.getHeader("Accept-Language");

    String strMode              = emxGetParameter(request, "Mode");
    boolean isModeMove          = "Move".equalsIgnoreCase(strMode);
    boolean isModeRemove        = "Remove".equalsIgnoreCase(strMode);
    boolean showPopup           = false;
    String strObjectId          = null;
    String strOldParentId       = null; 
    String strNewParentId       = null;
    String emxTableRowIds[]     = (String[]) emxGetParameterValues(request, "emxTableRowId");
    emxTableRowIds              = getTableRowIDsArray(emxTableRowIds);
    if (isModeMove) {
        strObjectId    = emxGetParameter(request, "objectId");
        strOldParentId = emxGetParameter(request, "oldParentObjectId");
        strNewParentId = emxGetParameter(request, "parentObjectId");
        if(emxTableRowIds != null && emxTableRowIds.length > 0) {
        	strNewParentId = emxTableRowIds[0];
        }
    } else {
        
       
        if(emxTableRowIds != null && emxTableRowIds.length > 0) {
            strObjectId = emxTableRowIds[0];
        }
        strOldParentId          = emxGetParameter(request, "objectId");
    }
    com.matrixone.apps.classification.Classification objClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, strObjectId, "Classification");

    // The old parent object need not be a Classification; it could be a Libraries, in which
    // case it would not contribute any attribute groups that might be lost on move/remove
    DomainObject objOldParent = DomainObject.newInstance (context, strOldParentId, "Classification");
    if (objOldParent instanceof com.matrixone.apps.classification.Classification) {
        StringList lostAttrs = new StringList();
        if (isModeMove) {
            // attribute loss = attributes(oldparent) - attributes(newparent) - attributes(self, direct)
            com.matrixone.apps.classification.Classification objOldParentCls = (com.matrixone.apps.classification.Classification)objOldParent;
            StringList oldParentAttrs = objOldParentCls.getClassificationAttributes(context, true, true);
            StringList ownDirectAttrs = objClassification.getClassificationAttributes(context, false, true);
            lostAttrs.addAll(oldParentAttrs);
            lostAttrs.removeAll(ownDirectAttrs);
            DomainObject objNewParent = DomainObject.newInstance (context, strNewParentId, "Classification");
            if (objNewParent instanceof com.matrixone.apps.classification.Classification) {
                StringList newParentAttrs = ((com.matrixone.apps.classification.Classification)objNewParent).getClassificationAttributes(context, true, true);
                lostAttrs.removeAll(newParentAttrs);
            }
        } else if (isModeRemove) {
            // attribute loss = attributes(self,inherited)
            lostAttrs.addAll(objClassification.getClassificationAttributes(context, true, false));
        }
        showPopup = !lostAttrs.isEmpty();
    }
%>

<%
    //Accumulate all the parameters
    StringBuffer sbufAppendParameters = new StringBuffer(256);
    sbufAppendParameters.append("suiteKey=");
    sbufAppendParameters.append(emxGetParameter(request, "suiteKey"));
    sbufAppendParameters.append("&Mode=");
    sbufAppendParameters.append(strMode);
    sbufAppendParameters.append("&oldParentObjectId=");
    sbufAppendParameters.append(strOldParentId);
    sbufAppendParameters.append("&parentObjectId=");
    sbufAppendParameters.append(strNewParentId);
    sbufAppendParameters.append("&emxTableRowId=");
    sbufAppendParameters.append(emxGetParameter(request,"emxTableRowId"));
    sbufAppendParameters.append("&objectId=");
    sbufAppendParameters.append(strObjectId);
%>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>

<%
    //
    // Form a page url to which this page should be submitted
    // If both the conditions are satisfied then  show the popup window else
    // go to the process page directly.
    String strForwardPageUrl = "";
    if (showPopup)
    {

        strForwardPageUrl = "emxMultipleClassificationRemoveClassFS.jsp";
        if (sbufAppendParameters.length() > 0)
        {
            strForwardPageUrl = strForwardPageUrl + "?" + sbufAppendParameters.toString();
        }

%>
		<script language="javascript">
		var _div = $('<div/>', {
		    id: 'newLoad',
		    name: 'newLoad'
			});
		
			
			 _div.css({
				"position": "absolute",
				"top": "0",
				"z-index": "1000",
				"width": "100%",
				"height": "80%",
				"padding": "10%",
				"background-color": "rgba(229, 229, 229, 0.59)"
				});
		var _body = $(getTopWindow().document.body);
		_body.append(_div);
		
		var _load = $('<iframe>', {
			  		 id:  'myFrame',
			  		 name: 'myFrame'
			  		 }).css("border","solid 2px #005686");
		_div.append(_load);
		</script>

		<form name="formForward" method="post" target = "myFrame" action="<%=XSSUtil.encodeForHTML(context,strForwardPageUrl)%>">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
        <script language="javascript">
        <!--
            <%-- showModalDialog("<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>", "600", "500", false); --%>
            document.formForward.submit();
        //-->
        </script>
        </form>
<%
    }//if !
    else
    {
        if (isModeRemove)
        {
            strForwardPageUrl = "emxMultipleClassificationRemoveClassProcess.jsp";
            if (sbufAppendParameters.length() > 0)
            {
                strForwardPageUrl = strForwardPageUrl + "?" + sbufAppendParameters.toString();
            }

            //
            // Show removal confirmation dialog and if user agrees to remove then only proceed to
            // process page.
            //
            String strConfirmationMessage;
            if (showPopup) {
                strConfirmationMessage = EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.RemoveClassification.ConfirmMessage");
            } else {
                strConfirmationMessage = EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.Remove.ConfirmMsg");
            }
%>
		    <form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTML(context,strForwardPageUrl)%>">
		    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
            <script language="javascript">
                var isToBeContinued = window.confirm("<xss:encodeForJavaScript><%=strConfirmationMessage%></xss:encodeForJavaScript>");
				if (isToBeContinued)
                {
                    <%-- window.location.href = "<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>"; --%>
                    document.formForward.submit();
                }
            </script>
			</form>
<%
        }
        else
        {
            strForwardPageUrl = "emxMultipleClassificationMoveClassificationProcess.jsp?"+sbufAppendParameters.toString(); 
%>            
			<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTML(context,strForwardPageUrl)%>">
			<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
            <script>

                <%-- window.location.href = "<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>"; --%>          
                document.formForward.submit();
            </script>
            </form>
<%
        }
    }//else !
%>

