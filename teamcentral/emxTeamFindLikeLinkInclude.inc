<%--  emxTeamFindLikeLinkInclude.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxTeamFindLikeLinkInclude.inc.rca 1.7 Wed Oct 22 16:06:43 2008 przemek Experimental przemek $"
--%>
<%
String sLinkname              = emxGetParameter(request,"page");
String sSearchType            = emxGetParameter(request,"searchType");

if(sLinkname == null){
  sLinkname = "";
} 
if(sSearchType == null){
  sSearchType = "";
}  


%>
<script language="Javascript" >
  function goToFindLike(){

    var loc = getTopWindow().location.href;
    getTopWindow().url = document.location.href;
    document.location = "emxTeamFindLikeDialog.jsp?ComboType=<%=objectSymbolicName%>&typeString=<%=objectI18NString%>&objectIcon=<%=objectIcon%>&page=<%=XSSUtil.encodeForURL(context,sLinkname)%>&searchType=<%=XSSUtil.encodeForURL(context,sSearchType)%>&returnSearchFrameset=" + escape(loc);
  }
</script>
&nbsp;<a href="javascript:goToFindLike()" ><img src="../common/images/utilSearchPlus.gif" border="0" align="absmiddle" ></a>&nbsp;<a href="javascript:goToFindLike()" ><%=i18nNow.getI18nString("emxTeamCentral.FindLike.More","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%></a>&nbsp;
