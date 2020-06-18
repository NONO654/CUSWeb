<%--  
	PLCParEvolutionCurvePrefProcess.jsp
	Copyright (c) 1992-2018 Dassault Systemes.
--%>

<%--
@Quickreview KIE1 ZUD 15/11/2016: IR-484274-3DEXPERIENCER2018x-R4190-FUN055836: Unselection of preferences for Test Execution Is KO once it is selected.
 --%>

<%@page import="com.matrixone.apps.domain.util.MqlUtil"%><html>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
String ParEvolutionWithTitle = (String)emxGetParameter(request,"ParEvolutionWithTitle");
String ParEvolutionWithEndDate = (String)emxGetParameter(request,"ParEvolutionWithEndDate");


if(ParEvolutionWithTitle == null)
{
	ParEvolutionWithTitle="false";
}
if(ParEvolutionWithEndDate == null)
{
	ParEvolutionWithEndDate="false";
}

	try{	
			ContextUtil.startTransaction(context, true);
			
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedEvolutionCurveTypeTitle", ParEvolutionWithTitle.trim());
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedEvolutionCurveTypeActualEndDate", ParEvolutionWithEndDate.trim());
		}
	catch (Exception ex) {
	    ContextUtil.abortTransaction(context);
	
	    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
	    {
	        emxNavErrorObject.addMessage("prefParameterEvolutionCurve:" + ex.toString().trim());
	    }
	}
	finally
{
    ContextUtil.commitTransaction(context);
}

%><%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
