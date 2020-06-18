<%--
  RuleDialogValidationUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityUtil.jsp 1.19.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.BooleanOptionCompatibility"%>
<%@page import="com.matrixone.apps.configuration.ConfigurableRulesUtil"%> 
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page	import="matrix.util.StringList"%>
<%@page	import="java.util.StringTokenizer"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.matrixone.apps.configuration.MarketingPreference"%>
<%@page import="com.matrixone.apps.configuration.InclusionRule"%>
<%@page import="com.matrixone.apps.configuration.RuleProcess"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;
try
 {
  //gets the mode passed
  String strMode = emxGetParameter(request, "mode");
  StringList cfSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
  StringList coSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
  if(strMode.equals("ValidateExpression"))
  {
  try
	{
		ArrayList lstLeftExpression = new ArrayList();
		ArrayList lstRightExpression = new ArrayList();
		
		String strLeftExpression = emxGetParameter(request,"lstLeftExpression");
		String strRightExpression = emxGetParameter(request,"lstRightExpression");
        
        if(strLeftExpression!= null && strLeftExpression.length()!=0)
        {    
            StringTokenizer stSel = new StringTokenizer(strLeftExpression,",",false);
            String strFtrSelLstId = null;
            while (stSel.hasMoreElements())
            {
                 strFtrSelLstId=(String)stSel.nextElement();
                 lstLeftExpression.add(strFtrSelLstId);
            }
        }
        boolean bLeftExpValid  = ConfigurableRulesUtil.validateExpression(context ,lstLeftExpression ,'"');
        
        if(strRightExpression!= null && strRightExpression.length()!=0)
        {    
            StringTokenizer stSel = new StringTokenizer(strRightExpression,",",false);
            String strFtrSelLstId = null;
            while (stSel.hasMoreElements())
            {
                 strFtrSelLstId=(String)stSel.nextElement();
                 lstRightExpression.add(strFtrSelLstId);
            }
        }
        
        boolean bRightExpValid  = ConfigurableRulesUtil.validateExpression(context ,lstRightExpression ,'"');

		out.println("LeftExpression=");
		out.println(bLeftExpValid);
		out.println(",");
		out.println("RightExpression=");
		out.println(bRightExpValid);
		out.println(";");

	}
	catch(Exception exp )
	{
	   System.out.println(exp.getMessage());
	}
  }else if(strMode.equals("getParentObjectID")){
      String strRelId = emxGetParameter(request,"relPhyID");
      strRelId=strRelId.substring(1);
      DomainRelationship domRel = new DomainRelationship(strRelId);
      StringBuffer sb = new StringBuffer();
      sb.append("from.physicalid");
      StringList relSel = new StringList(sb.toString());
      Map ht = domRel.getRelationshipData(context, relSel);
      String parentPhyID="";
      if (!(((StringList) ht.get(relSel.get(0))).isEmpty())){
    	  parentPhyID = (String) ((StringList) ht.get(relSel.get(0))).get(0);
      }
      out.println("parentPhyID=");
      out.println("B"+parentPhyID);
      out.println(";");
  }else if(strMode.equals("getChildObjectID")){
      String strRelId = emxGetParameter(request,"relPhyID");
      strRelId=strRelId.substring(1);
      DomainRelationship domRel = new DomainRelationship(strRelId);
      StringBuffer sb = new StringBuffer();
      sb.append("to.physicalid");
      StringList relSel = new StringList(sb.toString());
      Map ht = domRel.getRelationshipData(context, relSel);
      String childPhyID="";
      if (!(((StringList) ht.get(relSel.get(0))).isEmpty())){
    	  childPhyID = (String) ((StringList) ht.get(relSel.get(0))).get(0);
      }
      out.println("childPhyID=");
      out.println("B"+childPhyID);
      out.println(";");
  }else if(strMode.equals("getParentObjectIDBCR")){
      String strRelId = emxGetParameter(request,"relPhyID");
      strRelId=strRelId.substring(1);
      DomainRelationship domRel = new DomainRelationship(strRelId);
      StringBuffer sb = new StringBuffer();
      sb.append("from.physicalid");
      StringList relSel = new StringList(sb.toString());
      relSel.add("from.type");
      Map ht = domRel.getRelationshipData(context, relSel);
      String parentPhyID="";
      String parentType="";
      if (!(((StringList) ht.get(relSel.get(0))).isEmpty())){
    	  parentPhyID = (String) ((StringList) ht.get(relSel.get(0))).get(0);
    	  parentType = (String) ((StringList) ht.get("from.type")).get(0);
      }
      boolean isCFCOType=false;
      if(parentType!=null &&  (cfSubTypes.contains(parentType) ||coSubTypes.contains(parentType)))
    	  isCFCOType=true;
      out.println("parentPhyID=");
      out.println("B"+parentPhyID);
      out.println(",");
      out.println("isCFCOType=");
      out.println(isCFCOType);
      out.println(";");
  }else if(strMode.equals("getChildObjectIDBCR")){
      String strRelId = emxGetParameter(request,"relPhyID");
      strRelId=strRelId.substring(1);
      DomainRelationship domRel = new DomainRelationship(strRelId);
      StringBuffer sb = new StringBuffer();
      sb.append("to.physicalid");
      StringList relSel = new StringList(sb.toString());
      relSel.add("to.type");
      Map ht = domRel.getRelationshipData(context, relSel);
      String childPhyID="";
      String childType="";
      if (!(((StringList) ht.get(relSel.get(0))).isEmpty())){
    	  childPhyID = (String) ((StringList) ht.get(relSel.get(0))).get(0);
    	  childType = (String) ((StringList) ht.get("to.type")).get(0);
      }
      boolean isCFCOType=false;
      if(childType!=null &&  (cfSubTypes.contains(childType) ||coSubTypes.contains(childType)))
    	  isCFCOType=true;
      out.println("childPhyID=");
      out.println("B"+childPhyID);
      out.println(",");
      out.println("isCFCOType=");
      out.println(isCFCOType);
      out.println(";");
  }
  else if(strMode.equals("ValidatePCRExpression"))
  {
	  try
	    {
	        String strLeftExpression = emxGetParameter(request,"strLeftExpression");
	        String strRightExpression = emxGetParameter(request,"strRightExpression");
	        boolean bExpSame  = BooleanOptionCompatibility.validatePCRExpression(strLeftExpression ,strRightExpression);
	        out.println("bExpSame=");
	        out.println(bExpSame);
	        out.println(";");

	    }
	    catch(Exception exp )
	    {
	       System.out.println(exp.getMessage());
	    }
	  }else if(strMode.equals("getExpressionBCR")){
	      String leftExp = emxGetParameter(request,"leftExp");
	      String rightExp = emxGetParameter(request,"rightExp");
	      String compType = emxGetParameter(request,"compType");
	      String bcrExp  = BooleanOptionCompatibility.getBCRI18Expression(context,leftExp ,rightExp,compType);
	      out.println("bcrExp=");
	      out.println(bcrExp);
	      out.println("#");
	  }else if(strMode.equals("getExpressionMPR")){
          String leftExp = emxGetParameter(request,"leftExp");
          String rightExp = emxGetParameter(request,"rightExp");
          String mprExp  = MarketingPreference.getMPRI18Expression(context,leftExp ,rightExp);
          out.println("mprExp=");
          out.println(mprExp);
          out.println("#");
      }else if(strMode.equals("getExpressionPCR")){
          String leftExp = emxGetParameter(request,"leftExp");
          String rightExp = emxGetParameter(request,"rightExp");
          String compType = emxGetParameter(request,"compType");
          String pcrExp  = BooleanOptionCompatibility.getPCRI18Expression(context,leftExp ,rightExp,compType);
          out.println("pcrExp=");
          out.println(pcrExp);
          out.println("#");
      }else if(strMode.equals("getExpressionIR")){
          String leftExp = emxGetParameter(request,"leftExp");
          String rightExp = emxGetParameter(request,"rightExp");
          String compType = emxGetParameter(request,"compType");
          String irExp  = InclusionRule.getIRI18Expression(context,leftExp ,rightExp,compType);
          out.println("irExp=");
          out.println(irExp);
          out.println("#");
      }else if(strMode.equals("isDuplicateName")){
          String type = emxGetParameter(request,"type");
          String name = emxGetParameter(request,"name");
          String revision = emxGetParameter(request,"revision");
          boolean qrExp  = RuleProcess.isRuleNameDuplicate(context,type ,name,revision);
          out.println("isDup=");
          out.println(qrExp);
          out.println("#");
      }else if(strMode.equals("checkBadNameChar")){
    	  String strBadChars  = EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars");
          out.println("BNCSTART");
          out.println(strBadChars);
          out.println("BNCEND");
      }
 }
 catch (Exception e)
 {
    bFlag=true;
    session.putValue("error.message", e.getMessage());
 }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    if (bFlag)
    {
%>
    <!--Javascript to bring back to the previous page-->
    <script language="javascript" type="text/javaScript">
      history.back();
    </script>
<%
    }
%>
