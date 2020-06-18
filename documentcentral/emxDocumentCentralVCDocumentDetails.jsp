<%--  emxDocumentCentralVCDocumentDetails.jsp   -
    This page queries the required data from database to display
    the required properties for Generic Document

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "";
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc"%>
<%
  Document document = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
  String objectId = emxGetParameter(request, "objectId");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  document.setId(objectId);

  SelectList selectList = new SelectList(30);
  
  selectList.add("id");
  selectList.add("vcfile");
  selectList.add("vcfolder");
  selectList.add("vcfile.store");
  selectList.add("vcfolder.store");
  selectList.add("vcfolder.vcpath");
  selectList.add("vcfile.path");
  selectList.add("vcfile.specifier");
  selectList.add("vcfolder.config");
  selectList.add("vcfile.vcname");
  selectList.add("vcfile.exists");
  selectList.add("vcfile.locked");
  selectList.add("vcfolder.vcfile.author");
  selectList.add("vcfile.comment");
  selectList.add("vcfolder.comment");
  selectList.add("vcfile.checkinstatus");
  selectList.add("vcfolder.checkinstatus");

  Map mapDocumentInfo = document.getInfo(context,selectList);
  String store = PropertyUtil.getSchemaProperty (context,"store_STORE");

  String server = "";
  String path = "";
  String selector="";
  String vcfilename="";
  String author="";
  String versionid="";
  String locked = "";
  String vcExists = "";
  String vcComment = "";
  String vcCheckinStatus ="";

  String vcfile = (String)mapDocumentInfo.get("vcfile");
  String vcfolder = (String)mapDocumentInfo.get("vcfolder");
  if( "true".equalsIgnoreCase(vcfile) )
  {
      server = (String)mapDocumentInfo.get("vcfile[1].store");
      String tmpPath = (String)mapDocumentInfo.get("vcfile[1].path");
      int index = tmpPath.lastIndexOf('/');
      if (index < 0)
        path = java.io.File.separator;
      else
        path = tmpPath.substring(0, index);
      vcfilename = tmpPath.substring(index + 1);
      selector=(String)mapDocumentInfo.get("vcfile[1].specifier");
      if (path.equals(vcfilename))
        path = java.io.File.separator;
      locked = (String)mapDocumentInfo.get("vcfile[1].locked");
      vcExists=(String)mapDocumentInfo.get("vcfile[1].exists");
      vcComment=(String)mapDocumentInfo.get("vcfile[1].comment");
      vcCheckinStatus =(String)mapDocumentInfo.get("vcfile[1].checkinstatus");  

      if( "true".equalsIgnoreCase(vcExists) ){
       SelectList innerSelectList = new SelectList();
       innerSelectList.add("vcfile.author");
       innerSelectList.add("vcfile.versionid");
       Map mapFileInfo = document.getInfo(context,innerSelectList);
       author=(String)mapFileInfo.get("vcfile[1].author");
       versionid=(String)mapFileInfo.get("vcfile[1].versionid");
     }
  }
  else if( "true".equalsIgnoreCase(vcfolder) )
  {
      server = (String)mapDocumentInfo.get("vcfolder[1].store");
      path = (String)mapDocumentInfo.get("vcfolder[1].vcpath");
      selector=(String)mapDocumentInfo.get("vcfolder[1].config");
      author=(String)mapDocumentInfo.get("vcfolder[1].vcfile.author");
      vcComment=(String)mapDocumentInfo.get("vcfolder[1].comment");
      vcCheckinStatus =(String)mapDocumentInfo.get("vcfolder[1].checkinstatus");  
  }
   
  if ((server == null) || (server.equals(store)))
    server = "";
  if ((vcComment == null) || ("null".equals(vcComment)))
    vcComment = "";
  if ((locked == null) || ("null".equals(locked)))
    locked = "";
  if(vcCheckinStatus == null || "null".equals(vcCheckinStatus)) {
      vcCheckinStatus = "";
  }


   if( "true".equalsIgnoreCase(vcfile) || "true".equalsIgnoreCase(vcfolder) )
    {
%>

      <tr>
      <td width="10%" class="labelrequired"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.Selector</emxUtil:i18n>&nbsp;
      <td class="inputField"><input type="text" name="selector" size="25" value="<xss:encodeForHTMLAttribute><%=selector%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="oldselector" size="25" value="<xss:encodeForHTMLAttribute><%=selector%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isVCFile" size="25" value="<xss:encodeForHTMLAttribute><%=vcfile%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isVCFolder" size="25" value="<xss:encodeForHTMLAttribute><%=vcfolder%></xss:encodeForHTMLAttribute>" />

      </td></tr>
     <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.Server</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=server%></xss:encodeForHTML></td></tr>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.Path</emxUtil:i18n>&nbsp;
      <td class="inputField"><xss:encodeForHTML><%=path%></xss:encodeForHTML></td></td></tr>

 <%
    if( "true".equalsIgnoreCase(vcfile))
    {
%>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.VCfileName</emxUtil:i18n>&nbsp;
      <td class="inputField"><xss:encodeForHTML><%=vcfilename%></xss:encodeForHTML></td></tr>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.VersionId</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=versionid%></xss:encodeForHTML></td></tr>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.Locked</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=locked%></xss:encodeForHTML></td></tr>
        <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.CommonDocument.Author</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=author%></xss:encodeForHTML></td></tr>
          <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Comments</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=vcComment%></xss:encodeForHTML></td></tr>
<%
    }
%>
 <%
   if( "true".equalsIgnoreCase(vcfolder))
    {
%>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.VCDocument.CheckinStatus</emxUtil:i18n>&nbsp;
          </td><td colspan="1" class="field"><xss:encodeForHTML><%=vcCheckinStatus%></xss:encodeForHTML></td></tr>
<%
      }
%>
<%
  }
%>   

