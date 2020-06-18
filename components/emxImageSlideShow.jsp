  <%-- emxImageSlideShow.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxImageSlideShow.jsp.rca 1.4.2.1.2.7.2.5 Wed Oct 22 16:18:06 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxToolbarInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<script language="JavaScript" src="emxUIImageManager.js"></script>
<script language="javascript" src="ENOVIA3DLiveExamine.js"></script>

<%@include file = "emxImageManager.inc"%>

<title><%=XSSUtil.encodeForHTML(context, header)%></title>

<% 
	int icount=0, initialValue=0; 
	String strURL="";
	String strURL1="";
	String showAltPathDropDown="false";
	String categoryTreeName="";
	String url2="";
	String parentOID="";
	String strObjId="";
%>

<script language="JavaScript">

    var NewImg      = backImage;
    var ImgNum      = 0;
    var ImgLength   = NewImg.length - 1;
    var ImgCount    = ImgLength + 1;
    var delay       = 2000;
    var lock        = false;
    var i           = 0;
    var vImgSeqCnt  = 0;
    var labelOf     = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.Of</emxUtil:i18n>";
    var run;

    function loadImage()
    {
        i   = ImgCount;
        chgImg(1);
    }

    function chgImg(direction)
    {
        if (document.images)
        {
            ImgNum = ImgNum + direction;
            if (ImgNum > ImgLength)
            {
                ImgNum  = 0;
            }
            if (ImgNum < 0)
            {
                ImgNum  = ImgCount;
            }

            if (i==1 && direction == -1)
            {
                i   = <%=icount%>;
            }
            else if (i == ImgCount && direction != -1)
            {
                i   = 1;
            }
            else if (i == ImgCount && direction ==-1)
            {
                i   = i-1;
            }
            else
            {
                i   = i + direction;
            }
        }

        if(NewImg.length != 0)
        {
            var currImage           = NewImg[i-1];
            var divImage            = document.getElementById("divImage");
            var pluginFailMessage   = "<emxUtil:i18n localize="i18nId">emxComponents.3DVIAViewer.NotInstalled</emxUtil:i18n>";
            if(backImage[i-1].indexOf(".3dxml") != -1 || backImage[i-1].indexOf(".cgr") != -1)
            {
                 createViewer('divImage', 'viewer', '../components', currImage);
                 if (!is3DVIAInstalledOnServer("."))
                     alert(pluginFailMessage);

            }
            else
            {
                divImage.innerHTML  = "<img src='"+currImage+"' alt='' border='0' name='slideshow' id='product' />";
            }
        }
        if(vImgSeqCnt==0)
        {
            vImgSeqCnt = 1;
        }
        else
        {
            document.getElementById('ImageSeqCount').value  = i+' '+labelOf+' '+<%=icount%>;
        }
    }


    function auto()
    {
        if (lock == true)
        {
            lock    = false;
            window.clearInterval(run);
        }
        else if (lock == false)
        {
            lock    = true;
            run     = setInterval("chgImg(1)", delay);
        }
    }

    var mode            = true;
    var objMainToolbar  = null;
    objMainToolbar      = new emxUIToolbar(mode);

    objMainToolbar.setWidth(0.8);
    objMainToolbar.setMaxLabelChars(<%=defaultLength%>);

    function emxUIToolbarFormField()
    {
        this.html       = "";
        this.element    = null;
        return this;
    }

    emxUIToolbarFormField.prototype.init = function _init(objParent)
    {
        this.element            = document.createElement("td");
        this.element.className  = "toolbar-panel-input";
        this.element.innerHTML  = this.html;
        objParent.appendChild(this.element);
    }

    var filterSlideShow = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.SlideShow</emxUtil:i18n>";
    var filterFilmStrip = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.FilmStrip</emxUtil:i18n>";
    var lblFilter       = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.View</emxUtil:i18n>";

    objMenuBtn          = objMainToolbar.addItem(new emxUIToolbarFormField());
    //XSSOK
    objMenuBtn.html     = lblFilter+" <select name='interval' onchange='window.location=this.options[this.selectedIndex].value;'><option value='<%=strURL%>'>"+filterSlideShow+"</option><option value='<%=strURL1%>'>"+filterFilmStrip+"</option></select>";
    objMenuBtn          = objMainToolbar.addItem(new emxUIToolbarFormField());
    objMenuBtn.html     = "  <input name='SeqCount' id='ImageSeqCount' class='textInfo' type='text' READONLY value=\"<%=initialValue%> "+labelOf+" <%=icount%>\"/>";
<%
    String toggleValue  = showOutSideImages?"Yes":"No";
    if( !"FALSE".equalsIgnoreCase(showAltPathDropDown))
    {

%>
        var includeAltPath  = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.IncludeAltPath</emxUtil:i18n>";
        var excludeAltPath  = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.ExcludeAltPath</emxUtil:i18n>";
        var atlPathLbl      = "<emxUtil:i18n localize="i18nId">emxComponents.Image.Label.AltPath</emxUtil:i18n>";

        objAltMenuBtn       = objMainToolbar.addItem(new emxUIToolbarFormField());
        //XSSOK
        objAltMenuBtn.html  = atlPathLbl+'<select name="altPath" id="altPath"  onchange="checkAltPath()"><option value="<%=url2.toString()%>&toggleValue=Yes" <%="Yes".equalsIgnoreCase(toggleValue)?"Selected":"" %> >'+includeAltPath+'</option><option value="<%=url2.toString()%>&toggleValue=No" <%="No".equalsIgnoreCase(toggleValue)?"Selected":"" %>>'+excludeAltPath+'</option>';

        function checkAltPath()
        {
            document.ImageViewerForm.method ="post";
            document.ImageViewerForm.action =document.getElementById('altPath').value;
            document.ImageViewerForm.target ="imageHidden";
            document.ImageViewerForm.submit();
        }
<%
    }
%>

</script>

</head>

  <div id="pageHeadDiv">
    <table>
     <tr>
        <td class="page-title">
			<h2><%=XSSUtil.encodeForHTML(context, header)%></h2>
		</td>
      </tr>
    </table>

          <jsp:include page = "../common/emxToolbar.jsp" flush="true">
          		<jsp:param name="objectId" value="<%=objectId%>"/>
          		<jsp:param name="toolbar" value="APPSlideShowToolBar"/>
		        <jsp:param name="categoryTreeName" value="<%=categoryTreeName%>"/>
	            <jsp:param name="parentOID" value="<%=parentOID%>"/>
		        <jsp:param name="suiteKey" value="<%=suiteKey%>"/>
		        <jsp:param name="PrinterFriendly" value="false"/>
		        <jsp:param name="export" value="false"/>
		        <jsp:param name="helpMarker" value="<%=helpMarker%>"/>
		        <jsp:param name="isImageManager" value="true"/>
        </jsp:include>
      </div>

      <div id="divPageBody">
	      <div>
		      <iframe class="hidden-frame" name="imageHidden" src="../common/emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>  
	  		  <form name="ImageViewerForm" method="post" >
<%
			  if( !showHolderImages && (strObjId == null || "null".equals(strObjId) || "".equals(strObjId)) && !showOutSideImages) {
%>
			       <body>
			       		<BR/><BR/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Image.NoImageAssociated</emxUtil:i18n><BR/>
			       	</body>	
<%
    		  } else {
%>
			        <body class="slideshow" onload="loadImage();">
			        <input type="hidden" name=objectId value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
			        <input type="hidden" name=isPopup value="<xss:encodeForHTMLAttribute><%=isPopup%></xss:encodeForHTMLAttribute>" />
			        <input type="hidden" name=suiteKey value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
			        <input type="hidden" name=header value="<xss:encodeForHTMLAttribute><%=header%></xss:encodeForHTMLAttribute>" />

        			<div id="divImage">
        			</div>
        			</body>
<%
    		}
%>
			</form>
		</div>			
	 </div>
<%

    if("true".equalsIgnoreCase(isPopup) )
    {
%>
        <div id="divPageFoot">
                <table>
                    <tr>
                        <td align="right">
                            <table border="0" cellspacing="0">
                                <tr>
                                    <td><div id="CloseImage"><a href="javascript:getTopWindow().closeWindow()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxComponents.Button.Close</emxUtil:i18n>" /></a></div></td>
                                    <td><div id="CloseText"><a onClick="javascript:getTopWindow().closeWindow()" class="button"><emxUtil:i18n localize="i18nId">emxComponents.Button.Close</emxUtil:i18n></a></div></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
        </div>
<%
    }

%>
        <iframe class="hidden-frame" name="imageHidden" src="../common/emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>

</html>


