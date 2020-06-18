
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../components/emxComponentsFramesetUtil.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
  //create frameset object
  framesetObject fs = new framesetObject();
  
  // Specify URL to come in middle of frameset
  String contentURL ="emxPLMOnlineAdminAccessDisplayContent.jsp";
  
  String PageHeading = "Select the Accesses";
  String HelpMarker = "emxhelpmecreate";
  //init frameset
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  String roleList = "role_GlobalUser";

//(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
//create footer links
fs.createFooterLink("Done","submitAccesses()",roleList,false,true,"emxUIButtonDone.gif",0);
fs.createFooterLink("Cancel","parent.window.close()",roleList,false,true,"emxUIButtonCancel.gif",0);
  
 
fs.writePage(out);
%>
