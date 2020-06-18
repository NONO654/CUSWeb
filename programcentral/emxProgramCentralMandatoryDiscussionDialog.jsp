<%--  emxProgramCentralMandatoryDiscussionDialog.jsp

  Displays locations for a given company.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMandatoryDiscussionDialog.jsp.rca 1.16 Wed Oct 22 15:49:13 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK,"PROGRAM");

  String objectId = (String) emxGetParameter(request, "objectId");
  String fromPage = (String) emxGetParameter(request, "fromPage");
  String mode  = (String) emxGetParameter(request, "mode");
  task.setId(objectId);

  StringList busSelects = new StringList (2);
  busSelects.add(task.SELECT_ID);
  busSelects.add(task.SELECT_NAME);
  Map infoMap = task.getInfo(context, busSelects);
  

%>
<!--  
//Modified:19-May-2010:s4e:R210 PRG:WBSEnhancement
//Removed Name field as comments will be aplicable to multiple selected tasks 
 -->
<html>
  <body onLoad="document.MandatoryDiscussion.Description.focus()">
    <form name="MandatoryDiscussion" action="" method="post" onsubmit="submitForm();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%= fromPage %></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%= mode %></xss:encodeForHTMLAttribute>" />
      <table border="0" width="100%">
        
              <tr>
                <td width="20%" valign="top" align="left" class="labelRequired" nowrap="nowrap">
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Comments</emxUtil:i18n>
                </td>
                <td width="50%" nowrap class="field">
                  <textarea rows="5" cols="30" name="Description"></textarea>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
      <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
    </form>
  </body>
  
<!--  
End:19-May-2010:s4e:R210 PRG:WBSEnhancement 
 -->
 
  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
    function submitForm() {
      form = document.MandatoryDiscussion;
      if (form.Description.value == "" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ProjectTemplateDescription</emxUtil:i18nScript>");
        return;
      }
      form.action = "emxProgramCentralMandatoryDiscussionProcess.jsp";
      form.submit();
    }
  //Stop hiding here -->//]]>
  </script>

</html>

