<%--
  emxRMTGetData.jsp

  performs server transaction

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
  @quickreview LX6 13:05:22 IR-231926V6R2014  STP: In SCE editing of Priority, Difficulty and Classification attributes of Requirement is KO.
  @quickreview KIE1 ZUD 05:10:17 IR-454317-3DEXPERIENCER2018x  R419-STP: Tool-tip of Requirement Specification doesnt shows proper Name of object
 --%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.requirements.RequirementsConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>

<%
    boolean bFlag = false;
    String xml = "<mxRoot>";
    try {
        String strRelId = emxGetParameter(request, "SeqOrderRelsList");
        String strObject = emxGetParameter(request, "TypeOfObject");

        //START:LX6 IR-231926V6R2014
        String strIcon = emxGetParameter(request, "getIcon");
        String strClassificationType = emxGetParameter(request, "getClassification");
        //END:LX6 IR-231926V6R2014

        StringBuffer value = new StringBuffer();
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
        
        if (strRelId != null && strRelId.length() > 0) {
            String[] relIdsList = strRelId.split("[,]");
            for (int i = 0; i < relIdsList.length; i++) {

                Relationship relObject = DomainRelationship.newInstance(context, relIdsList[i]);
                Attribute seqAttrib = relObject.getAttributeValues(context,
                        RequirementsUtil.getSequenceOrderAttribute(context));
                value.append(seqAttrib.getValue()).append(".");
            }
            value.delete(value.length() - 1, value.length());
            xml += "<seqOrder>" + value + "</seqOrder>";

        }
        if (strObject != null && strObject.length() > 0) {
            DomainObject selectObject = DomainObject.newInstance(context, strObject);
            String type = selectObject.getInfo(context, DomainConstants.SELECT_TYPE);
            String name = selectObject.getInfo(context, DomainConstants.SELECT_NAME);
            type = type.replace(" ","_");
            String toolTip = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Type."+type);
            xml += "<objectType>" + name + "</objectType>";

            StringBuffer sbRelSelect = new StringBuffer();
            sbRelSelect = sbRelSelect.append(ReqSchemaUtil.getSubRequirementRelationship(context))
                    .append(",").append(ReqSchemaUtil.getDerivedRequirementRelationship(context))
                    .append(",").append(ReqSchemaUtil.getSpecStructureRelationship(context))
                    .append(",").append(ReqSchemaUtil.getChapterType(context));
            StringList lstObjSelects = new StringList();
            lstObjSelects.add(DomainConstants.SELECT_NAME);
            boolean bGetTo = true;
            boolean bGetFrom = false;
            short maxSearch = 10;
            short sRecursionLevel = maxSearch;

            DomainObject domObj = DomainObject.newInstance(context, strObject);
            MapList mapParentObjects = domObj.getRelatedObjects(context, sbRelSelect.toString(),
                    DomainConstants.QUERY_WILDCARD, lstObjSelects, null, bGetTo, bGetFrom, sRecursionLevel,
                    null, null, maxSearch);

            int countName = 0;
            for (int i = mapParentObjects.size() - 1; i >= 0; i--) {
                Map mapN = (Map) mapParentObjects.get(i);
                String strObjName = (String) mapN.get(DomainConstants.SELECT_NAME);

                xml += "<objectName_" + countName + ">" + XSSUtil.encodeForHTML(context, strObjName) + "</objectName_" + countName + ">";
                countName += 1;
            }
        }

        //START:LX6 IR-231926V6R2014
        if (strIcon != null && strIcon.length() > 0) {
            String ressource = "emxRequirements.Icon." + strIcon;
            String iconPath = EnoviaResourceBundle.getProperty(context, ressource);
            xml += "<iconPath>" + iconPath + "</iconPath>";
        }
        if (strClassificationType != null && strClassificationType.length() > 0) {
            String ressource = "emxRequirements.TextStyle." + strClassificationType;
            String Classification = EnoviaResourceBundle.getProperty(context, ressource);
            xml += "<classType>" + Classification + "</classType>";
        }
        //END:LX6 IR-231926V6R2014
    } catch (Exception e) {
        // NOP
    } finally {
        xml += "</mxRoot>";
        out.write(xml);
    }
%>

