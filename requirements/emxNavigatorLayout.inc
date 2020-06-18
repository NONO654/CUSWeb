<%--  emxNavigatorLayout.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorInclude.inc.rca 1.22 Tue Oct 28 18:55:05 2008 przemek Experimental przemek $
--%>

 <%@page import="com.matrixone.apps.framework.ui.UIComponent"%>
 <script type="text/javascript" src="../common/scripts/emxBreadcrumbs.js"></script>
 <script type="text/javascript" src="../common/scripts/emxQuery.js"></script>
 <script type="text/javascript" src="../plugins/libs/jquerystorage/jquery.storageapi.js"></script>
 <% if(UINavigatorUtil.isMobile(context)){%>
 		<link rel="stylesheet" type="text/css" href="../common/mobile/styles/emxUIMobile.css">
 	<%}%>
 <script type="text/javascript">
 this.personContextId = "<%=XSSUtil.encodeForJavaScript(context,PersonUtil.getPersonObject(context).getObjectId())%>";
	
     </script>

 <%
 String strClipboardName 		= EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
 String strClipboardDescription 	= EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.Description");

 // Validating if the System Generated Collection exists or not
 boolean bflagExists = SetUtil.exists(context,strClipboardName);

 if(!bflagExists)
 {

 	try
 	{
 	   String strResult = MqlUtil.mqlCommand(context,"add set $1 property description value $2 nothidden",strClipboardName,strClipboardDescription);
 	}
 	catch(Exception e)
 	{
 	    throw e;
 	}
}

 String callerPage = (String)request.getAttribute("callerPage");
 String integrationsSrc = (String)request.getAttribute("integrationsSource");
 ServletContext servletContext  = getServletConfig().getServletContext();
 InputStream inputStream = (integrationsSrc != null) ? servletContext.getResourceAsStream(integrationsSrc.replace("../", "/")) : null;
 
 boolean uiAutomation = UIComponent.getUIAutomationStatus(context);
 %>
<div id="pageContentDiv">
    <iframe frameborder="0" id="content" name="content" width="100%" height="100%"></iframe>
    <iframe class="hidden-frame applet-support" id="hiddenFrame" name="hiddenFrame"></iframe>
<%if("home".equals(callerPage)) { %>
	<%if(inputStream != null){%>
    	<iframe class="hidden-frame applet-support" id="integrationsFrame" name="integrationsFrame" src="<%=integrationsSrc%>"></iframe>
    <%}else{%>
    	<iframe class="hidden-frame applet-support" id="integrationsFrame" name="integrationsFrame"></iframe>
    <%}%>
    <iframe class="hidden-frame applet-support" id="appletFrame" name="appletFrame"></iframe>
    <%}%>
</div>
<!-- 
<div id="pageStatusBar">
       <div class="breadcrumbs" id="breadcrumbs">
       	 	<%if(uiAutomation){ %>
       			<div id="breadcrumbs_leftbutton" data-aid="bc-btn-left" class="buttons previous disabled">
		        	<a href="javascript:;" class="btn left"></a>
		    	</div>
		    	<div id="bccontainer" class="breadcrumbs-container">
		    		<ul id="bcul">
		    		</ul>
		    	</div>
		    	<div id="breadcrumbs_rightbutton" data-aid="bc-btn-right" class="buttons next disabled">
		        	<a href="javascript:;" class="btn right"></a> 
		    	</div>
       		<%}else{ %>
		    <div id="breadcrumbs_leftbutton" class="buttons previous disabled">
		        <a href="javascript:;" class="btn left"></a>
		    </div>
		    <div id="bccontainer" class="breadcrumbs-container">
		    <ul id="bcul">
		    </ul>
		    </div>
		    <div id="breadcrumbs_rightbutton" class="buttons next disabled">
		        <a href="javascript:;" class="btn right"></a> 
		    </div>
       		<%} %>
       </div>
       <div id="mx_objectCount" class="object-count"></div>
</div>
 -->
<!-- overlay layer -->
<div id="layerOverlay" class="content-mask" style="display:none;"></div><!-- /layerOverlay -->
<div id="layerOverlayRight" class="toolbar-mask group-right" style="display:none;"></div><!-- /layerOverlay -->
<div id="layerOverlayLeft" class="toolbar-mask group-left" style="display:none;"></div><!-- /layerOverlay -->

<!-- genericwindowshade -->
      <div id="genericwindowshade" class="windowshade">
            <div class="windowshade-body">
                  <iframe frameborder="0" allowtransparency="true" name="genericWindowShadeFrame" id="genericWindowHhadeFrame"  src="about:blank"></iframe>
            </div>
            <div class="windowshade-foot">
                  <table>
                        <tr>
                              <td class="functions">
                                    <table>
                                          <tr>
                                                <td></td>
                                                <td></td>
                                          </tr>
                                    </table>
                              </td>
                              <td class="buttons">
                                    <table>
                                          <tbody>
                                                <tr>
                                                      <td><a onclick="getTopWindow().closeWindowShadeDialog(true)" href="#"><img border="0" align="absmiddle" src="images/buttonDialogCancel.gif" /></a></td>
                                                </tr>
                                          </tbody>
                                    </table>
                              </td>
                        </tr>
                  </table>
            </div><!-- /.genericwindowshade-foot -->
      </div><!-- /.genericwindowshade -->

<!-- windowshade -->
      <div id="windowshade" class="windowshade search">
            <div class="windowshade-body">
                  <iframe frameborder="0" allowtransparency="true" name="windowShadeFrame" id="windowShadeFrame"  src="about:blank"></iframe>
            </div>
            <div class="windowshade-foot">
                  <table>
                        <tr>
                              <td class="functions">
                                    <table>
                                          <tr>
                                                <td></td>
                                                <td></td>
                                          </tr>
                                    </table>
                              </td>
                              <td class="buttons">
                                    <table>
                                          <tbody>
                                                <tr>
                                                      <td><a onclick="getTopWindow().closeWindowShadeDialog()" href="#"><img border="0" align="absmiddle" src="images/buttonDialogCancel.gif" /></a></td>
                                                </tr>
                                          </tbody>
                                    </table>
                              </td>
                        </tr>
                  </table>
            </div><!-- /.windowshade-foot -->
      </div><!-- /.windowshade -->

<script>
var bclist = bclist ? bclist : new emxBreadCrumbList();
var bculmousedown = false;
 
jQuery(".btn.left").mousedown( function (){
	if(jQuery("#breadcrumbs_leftbutton").hasClass("disabled"))
		return;
    bculmousedown = true;
    animate("left");
});

jQuery(".btn.left").mouseup( function (){
	if(jQuery("#breadcrumbs_leftbutton").hasClass("disabled"))
		return;
    bculmousedown = false;
    jQuery("#bcul").stop();
    paintButtons();
});

jQuery(".btn.left").mouseout( function (){
	if(jQuery("#breadcrumbs_leftbutton").hasClass("disabled"))
		return;
    bculmousedown = false;
    jQuery("#bcul").stop();
    paintButtons();
});

jQuery(".btn.right").mousedown( function (){
	if(jQuery("#breadcrumbs_rightbutton").hasClass("disabled"))
		return;
    bculmousedown = true;
    animate("right");
});

jQuery(".btn.right").mouseup( function (){
	if(jQuery("#breadcrumbs_rightbutton").hasClass("disabled"))
		return;
    bculmousedown = false;
    jQuery("#bcul").stop();
    paintButtons();
});

jQuery(".btn.right").mouseout( function (){
	if(jQuery("#breadcrumbs_rightbutton").hasClass("disabled"))
		return;
    bculmousedown = false;
    jQuery("#bcul").stop();
    paintButtons();
});

function paintButtons(){
    var bcul = jQuery("#bcul");
    var bc = getTopWindow().bclist.getFirstBC();
    if(bc != null) {
       	if(bcul[0].offsetLeft < 0){ 	  
              jQuery("#breadcrumbs_leftbutton").removeClass("disabled");
        } else {
              jQuery("#breadcrumbs_leftbutton").addClass("disabled");
         }
    } else {
        jQuery("#breadcrumbs_leftbutton").addClass("disabled");
    }
    if((bcul[0].offsetLeft + bcul[0].offsetWidth) < jQuery('#mx_objectCount')[0].offsetLeft){
         if(jQuery('#mx_objectCount')[0].offsetLeft - (bcul[0].offsetLeft + bcul[0].offsetWidth) <= 40){
        	 	jQuery("#breadcrumbs_rightbutton").removeClass("disabled");
         }else{
       			jQuery("#breadcrumbs_rightbutton").addClass("disabled");
         }
    } else {
        jQuery("#breadcrumbs_rightbutton").removeClass("disabled");
    }
}

function animate(direction){
    var bcul = jQuery("#bcul");
    var bcj = jQuery("#liemxbc" + 0);
    if(direction == "left") {
        var bc = getTopWindow().bclist.getFirstBC();
        if(bc != null) {        	
            if(bcul[0].offsetLeft < 0 ){
            	moveUL = (bcul[0].offsetLeft + 40) + "px";
            	if(bcul[0].offsetLeft + 40 >0){
            		moveUL = 0 + "px";
            	}
            	bcul.animate({left: moveUL}, (40 - bcul[0].offsetLeft)*1, function() {
                    if(bculmousedown)
                        animate("left");
                });
            }
        }
    } else {
    		if(((bcul[0].offsetLeft + bcul[0].offsetWidth) > jQuery('#mx_objectCount')[0].offsetLeft)){
    		moveUL = (bcul[0].offsetLeft - 40) + "px";
    		bcul.animate({left: moveUL}, -(bcul.position().left +  bcj.position().left), function() {
    	    if(bculmousedown)
                    animate("right");
            });    	
    	}else if ((jQuery('#mx_objectCount')[0].offsetLeft - (bcul[0].offsetLeft + bcul[0].offsetWidth) )  < 40) {
    		moveUL = bcul[0].offsetLeft+ (bcul[0].offsetLeft + bcul[0].offsetWidth +5) -jQuery('#mx_objectCount')[0].offsetLeft + "px";
    		bcul.animate({left: moveUL}, (bcul.position().left +  bcj.position().left), function() {
                if(bculmousedown)
                    animate("right");
            });
    	}
    }
}

</script>
