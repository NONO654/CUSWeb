<%--  ProductConfigurationOptionsConflict.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationFeaturesTableDialog.jsp 1.16.2.3.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";
 
--%>
<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>

<%-- Imports --%>
<%@ page import="com.matrixone.apps.configuration.IProductConfigurationFeature"%>
<%@ page import="com.matrixone.apps.configuration.PrdCfgRuleConflict"%>
<%@ page import="com.matrixone.apps.configuration.ProductConfiguration" %>
<%@ page import="com.matrixone.apps.configuration.Rule" %>
<%@ page import="java.util.Vector"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>
<%@ page import ="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%ProductConfiguration _pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
   String language = context.getSession().getLanguage();
   String KeyInRemoved =  EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.KeyInChanged",language);
  
  String i18nPCOptionConflict = i18nNow.getI18nString("emxProduct.Heading.PCOptionConflict",bundle,acceptLanguage);
  String i18nPCOptionAutoSelected = i18nNow.getI18nString("emxProduct.Heading.PCOptionAutoSelected",bundle,acceptLanguage);
  String i18nPCOptionConflictContext = i18nNow.getI18nString("emxProduct.Label.PCOptionConflictContext",bundle,acceptLanguage);
  String i18nPCOptionConflictRule = i18nNow.getI18nString("emxProduct.Label.PCOptionConflictRule",bundle,acceptLanguage);
  String i18nPCOptionConflictOwner = i18nNow.getI18nString("emxProduct.Label.PCOptionConflictOwner",bundle,acceptLanguage);
   if(_pConf != null)
   {
	   String id = emxGetParameter(request,"id");
	   String divId = emxGetParameter(request,"divId");
	   Vector conflictingRules = null;
	   Vector autoSelectingRules = null;
	   IProductConfigurationFeature pfeat = null;
	   if(id.equals("ruleextensionconflict"))
	   {
			   conflictingRules = _pConf.getRuleExtensionConflicts();
	   }else if(id.equals("inclusionruleviolation")){
           conflictingRules = _pConf.getInclusionRuleViolations();
	   }else
	   {
		    pfeat = (IProductConfigurationFeature)_pConf.getFeature(id).get(0);
		    if(pfeat != null)
		        {
		    	   conflictingRules = pfeat.getConflicts();
		    	   autoSelectingRules = pfeat.getAutoSelectRules();
		        }
	   }
	   if(conflictingRules.size() > 0)
		   {
			   Rule firstConflictingRule = (Rule)conflictingRules.elementAt(0);
			   if(firstConflictingRule != null)
			   {
				   PrdCfgRuleConflict conflict = new PrdCfgRuleConflict(firstConflictingRule, pfeat);
				   String ruleType=conflict.getI18ConflictRuleType(context);
				   
				   %>
				   <div id="mx_divLayerDialog" class="" style="">
				    <div id="mx_divLayerDialogHeader">
				        <table cellspacing="0" cellpadding="0" border="0">
				            <tbody>
				                <tr>
				                    <td class="title"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflict)%></td>
				                    <td class="buttons">
				                        <a class="button cancel" onclick="closeConflictDetailsDialog('<%=XSSUtil.encodeForJavaScript(context,divId)%>');"></a>
				                    </td>
				                </tr>
				            </tbody>
				        </table>
				    </div>
				    <div id="mx_divLayerDialogBody">
				        <table cellspacing="0" cellpadding="0" border="0">
				            <tbody>
				                <tr>
				                    <td>
				                        <p aligh="left"><%=XSSUtil.encodeForHTML(context,conflict.getTitleMessage(context))%></p>
				                    </td>
				                </tr>
				            </tbody>
				         </table>
				         <div class="mx_all_option_detail">
				          <div class="mx_option-detailcontext">
				            <table>
				                <tbody>
				                    <tr>
				                        <td>
				                            <img src="../common/images/iconStatusError.gif" />
				                        </td>
				                        <td>
				                            <span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,conflict.getErrorMessage(context))%></span>
				                        </td>
				                   </tr>			     
				                   <tr>
				                      <td class="mx_spacer-cell level-2"></td>    
				                     <td>
				                        <table>
				                          <tbody>
				                            <tr>
				                                <td><img src="../common/images/iconSmallBooleanCompatibilityRule.gif"/></td>
				                                <td><span class="mx-field-headName"><%=XSSUtil.encodeForHTML(context,ruleType+"- "+firstConflictingRule.getRuleName()) %></span></td>
				                           </tr>
				                       
				                           <%if(pfeat!=null){ %>
				                           <tr>
				                                <td></td>
				                                <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictContext) %></span></td>
				                          </tr>
				                          
				                          <tr>
				                                <td></td>
				                                <td><%DomainObject contextDom = DomainObject.newInstance(context, pfeat.getId());%>
				                                      <%=XSSUtil.encodeForHTML(context,contextDom.getName(context))%></td>
				                          </tr>
				                          <%}%>
				                            <tr>
				                                <td></td>
				                                <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictRule)%></span></td>
				                          </tr>
				                          <tr>
				                                <td></td>
				                                <td><%=XSSUtil.encodeForHTML(context,conflict.getRuleExpression(context))%></td>
				                          </tr>
				                           <tr>
				                                <td></td>
				                                <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictOwner)%></span></td>
				                          </tr>
				                          <tr>
				                                <td></td>
				                                <td><%=XSSUtil.encodeForHTML(context,firstConflictingRule.getRuleOwner())%></td>
				                          </tr>
				                        </tbody>
				                     </table>
				                   </td>
				                </tr>
				              </tbody>
				            </table>
				          </div>
				          <div class="mx_option-detail">
				            <table>
				                <tbody>
				                    <tr>    
				                        <td>
				                            <img src="../common/images/iconStatusError.gif" />
				                        </td>
				                        <td>
				                            <span class="mx_field-name"><%=XSSUtil.encodeForHTML(context,conflict.getErrorMessage(context))%></span>
				                        </td>
				                    </tr>
				                 </tbody>
				             </table>
				          </div>
				         </div>
				       </div>
				  </div>
				 <%	   }
			   }
	   else if(autoSelectingRules.size() > 0)
       {
       Rule firstConflictingRule = (Rule)autoSelectingRules.elementAt(0);
       if(firstConflictingRule != null)
       {
           PrdCfgRuleConflict conflict = new PrdCfgRuleConflict(firstConflictingRule, pfeat);
           String ruleType=conflict.getI18ConflictRuleType(context);
           
           %>
           <div id="mx_divLayerDialog" class="" style="">
            <div id="mx_divLayerDialogHeader">
                <table cellspacing="0" cellpadding="0" border="0">
                    <tbody>
                        <tr>
                            <td class="title"><%=XSSUtil.encodeForHTML(context,i18nPCOptionAutoSelected)%></td>
                            <td class="buttons">
                                <a class="button cancel" onclick="closeConflictDetailsDialog('<%=XSSUtil.encodeForJavaScript(context,divId)%>');"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div id="mx_divLayerDialogBody">
                <table cellspacing="0" cellpadding="0" border="0">
                    <tbody>
                        <tr>
                            <td>
                                <p aligh="left"><%=XSSUtil.encodeForHTML(context,conflict.getAutoSelectTitleMessage(context))%></p>
                            </td>
                        </tr>
                    </tbody>
                 </table>
                 <div class="mx_all_option_detail">
                  <div class="mx_option-detailcontext">
                    <table>
                        <tbody>
                            <tr>
                                <td>
                                    <img src="../common/images/iconStatusChanged.gif" />
                                </td>
                                <td>
                                    <span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,firstConflictingRule.getAutoSelectionMessage(context))%></span>
                                </td>
                           </tr>
                           <tr>
                             <td class="mx-spacer-cell level-1"></td>
                           </tr>
                           <tr>
                             <td class="mx_spacer-cell level-2"></td>
                             <td>
                                <table>
                                  <tbody>
                                    <tr>
                                        <td><img src="../common/images/iconSmallBooleanCompatibilityRule.gif"/></td>
                                        <td><span class="mx-field-headName"><%=XSSUtil.encodeForHTML(context,ruleType+"- "+firstConflictingRule.getRuleName()) %></span></td>
                                   </tr>
                                   <tr>
                                        <td class="mx-spacer-cell level-1"></td>
                                   </tr>
                                   <%if(pfeat!=null){ %>
                                   <tr>
                                        <td></td>
                                        <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictContext) %></span></td>
                                  </tr>
                                  
                                  <tr>
                                        <td></td>
                                        <td><%DomainObject contextDom = DomainObject.newInstance(context, pfeat.getId());%>
                                              <%=XSSUtil.encodeForHTML(context,contextDom.getName(context))%></td>
                                  </tr>
                                  <%}%>
                                    <tr>
                                        <td></td>
                                        <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictRule)%></span></td>
                                  </tr>
                                  <tr>
                                        <td></td>
                                        <td><%=XSSUtil.encodeForHTML(context,conflict.getRuleExpression(context))%></td>
                                  </tr>
                                   <tr>
                                        <td></td>
                                        <td><span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,i18nPCOptionConflictOwner)%></span></td>
                                  </tr>
                                  <tr>
                                        <td></td>
                                        <td><%=XSSUtil.encodeForHTML(context,firstConflictingRule.getRuleOwner())%></td>
                                  </tr>
                                </tbody>
                             </table>
                           </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                  <div class="mx_option-detail">
                    <table>
                        <tbody>
                            <tr>    
                                <td>
                                    <img src="../common/images/iconStatusChanged.gif" />
                                </td>
                                <td>
                                    <span class="mx_field-name"><%=XSSUtil.encodeForHTML(context,firstConflictingRule.getAutoSelectionMessage(context))%></span>
                                </td>
                            </tr>
                         </tbody>
                     </table>
                  </div>
                 </div>
               </div>
          </div>
         <%    }
       }
	   else{
				   //For Key-In Error
				   if(pfeat != null){
				   %>
				   <div id="mx_divLayerDialog" class="" style="">
				    <div id="mx_divLayerDialogHeader">
				        <table cellspacing="0" cellpadding="0" border="0">
				            <tbody>
				                <tr>
				                    <td class="title"><%=XSSUtil.encodeForHTML(context,KeyInRemoved)%></td>
				                    <td class="buttons">
				                        <a class="button cancel" onclick="closeConflictDetailsDialog('<%=XSSUtil.encodeForJavaScript(context,divId)%>');"></a>
				                    </td>
				                </tr>
				            </tbody>
				        </table>
				       </div> 
				        <div class="mx_all_option_detail">
	                      <div class="mx_option-detailcontext">
	                        <table>
	                            <tbody>
	                              <tr>
	                                 <td>
	                                    <img src="../common/images/iconStatusChanged.gif" />
	                                </td>
	                                <td>
	                                    <span class="mx_field-headName"><%=XSSUtil.encodeForHTML(context,_pConf.getKeyInStatusMessage(context,pfeat))%></span>
	                                </td>
	                            </tr>
	                            </tbody>
	                         </table>   
	                       </div>
	                    </div>
				     </div>
				 <% }
			   }
			   }
			   %>
            
