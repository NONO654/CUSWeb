<%@ page contentType="text/javascript"%>
<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.servlet.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*, 
				   com.matrixone.apps.domain.*, 
				   java.util.*, 
				   java.io.*, 
				   java.net.URLEncoder, 
				   java.util.*,
				   com.matrixone.jsystem.util.*"
				   errorPage="../../common/emxNavigatorErrorPage.jsp"%>
<%@include file = "../../common/emxNavigatorBaseInclude.inc"%>

<%@ page import="java.io.*,javax.servlet.*,javax.servlet.http.*"%>
<%@ page import="com.dassault_systemes.catrgn.otscript.i18nSupport.impl.GwtI18nSupport"%>

<%out.print(GwtI18nSupport.makeJsSystEnvDictionary());%>
