<%@ page import="java.util.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="matrix.db.Context" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileUtils" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.IconList" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.AttrValueWeight" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.AttrRangeWeight" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProfile" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProfileCheckInstance" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProcessingGroup" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMFilteringCheck" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileException" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.ImportConfigList" %>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.Type" %>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>

<%
String language = context.getSession().getLanguage();
String errorminpositive = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorMinPositive"));
String errorpositive = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorPositive"));
String errormininteger = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorMinInteger"));
String errorvalidationinteger = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorValidationInteger"));
String errorminempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorMinEmpty"));
String errorlabelempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorLabelEmpty"));
String errorinteger = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorInteger"));
String errorminunique = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorMinUnique"));
String errorunique = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorUnique"));
String errorvalueempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorValueEmpty"));
String errordecremempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorDecremEmpty"));
String errorvalidationempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorValidationEmpty"));
String errordecremseparator = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorDecremSeparator"));
String errordecremmax = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorDecremMax"));
String errorimportweight= ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Import.ErrorWeight"));
String errorimportpg = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Import.ErrorPG"));
String errorminparam = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Parameter.ErrorMin"));
String errormaxparam = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Parameter.ErrorMax"));
String errorpgempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.ProcessingGroup.ErrorEmpty"));
String errorpgunique = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.ProcessingGroup.ErrorUnique"));
String errorscempty = ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.StopCondition.ErrorEmpty"));
String errorscinteger= ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.StopCondition.ErrorInteger"));
String errorscpositive= ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.StopCondition.ErrorPositive"));
String errorpgsupprlast= ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.PG.ErrorSupprLast"));
String errorvalidationinferior= ProfileUtils.parseNLS(context, EnoviaResourceBundle.getProperty(context,ProfileConstants.resourcesFile, new Locale(language),"emxProfile.Weight.ErrorValidationInferior"));
String colorList = "";
java.util.List<ProfileConstants.IconList> listIcon = java.util.Arrays.asList(ProfileConstants.IconList.values());
for(int i = 0; i<listIcon.size()-1; i++){
	colorList = colorList + "\""+listIcon.get(i)+"\",";
}
colorList = colorList + "\""+listIcon.get(listIcon.size()-1)+"\"";
PLMProfile profile;
PLMProfileCheckInstance instance;
MapList filtersList = new MapList();
int defaultWeightId = -1;
AttrValueWeight defaultWeight = null;
int defaultvalueid = -1;
int defaultvalueidp = -1;
String validation = "";
String validationvalue = "";
String filterName = "";
String objectId = emxGetParameter(request,"objectId");
if(null != objectId && !objectId.isEmpty()){
	String objectType = ProfileUtils.getType(context, objectId);
	if(ProfileUtils.isTypeKindOf(context, objectType, Type.PLMProfile)){
		profile = PLMProfile.openProfile(context,objectId);
		if(profile.isOpen()){
			validation = profile.getValidationType(context);
			validationvalue = profile.getValueValidation(context);
			String modela = profile.getWeightManager(context).getModelAssessment(context);
			defaultWeightId = profile.getWeightManager(context).getDefaultWeight(context);
			if(defaultWeightId > 0)
				defaultWeight = profile.getWeightManager(context).getValueWeight(context, defaultWeightId);
			if(defaultWeight == null){
				defaultvalueidp = 0;
				defaultvalueid = 0;
			}else{
				if(modela.equals(ProfileConstants.PERCENTAGE)){
					defaultvalueidp = defaultWeightId;
					defaultvalueid = 0;
				}else{
					defaultvalueid = defaultWeightId;
					defaultvalueidp = 0;
				}
			}
		}
	}
	if(ProfileUtils.isTypeKindOf(context, objectType, Type.PLMProfileCheckInstance)){
		instance = PLMProfileCheckInstance.getInstance(context, objectId);
		if(instance != null){
			filtersList = instance.getAttachedFilters(context);
		}
	}
}
String defaultList = "";
String prefix = "";
for(ImportConfigList i:ImportConfigList.values()) {
	String importItem = i.getImportItem();
	defaultList += prefix;
	prefix = ProfileConstants.objectSeparator;
	defaultList += importItem;
}
String usedSeverities = ProfileUtils.getUsedSeverities(context,objectId);
%>

<script language="javascript">
var objectId = '<%=objectId%>';
var colorList = [<%=colorList%>];
var usedSeverities = [<%=usedSeverities%>];
var severitiesids = [];
var option;
var id=0;
var idp=0;
var mode='<%=ProfileConstants.SUM%>';
var suite='<%=ProfileConstants.suite%>';
var idvalue=0;
var idvaluep=0;
var defaultvalue=<%=defaultvalueid%>;
var defaultvaluep=<%=defaultvalueidp%>;
var idPG = 0;
var instanciatePG = [];
var defaultList='<%=defaultList%>';
var validation='<%=validation%>';
var validationvalue='<%=validationvalue%>';
var newseverity = -1;

var errorminpositive = '<%=errorminpositive%>';
var errorpositive = '<%=errorpositive%>';
var errormininteger = '<%=errormininteger%>';
var errorinteger = '<%=errorinteger%>';
var errorminunique = '<%=errorminunique%>';
var errorunique = '<%=errorunique%>';
var errorminempty = '<%=errorminempty%>';
var errorlabelempty = '<%=errorlabelempty%>';
var errorvalueempty = '<%=errorvalueempty%>';
var errordecremmax = '<%=errordecremmax%>';
var errordecremseparator = '<%=errordecremseparator%>';
var errordecremempty = '<%=errordecremempty%>';
var errorimportweight = '<%=errorimportweight%>';
var errorimportpg = '<%=errorimportpg%>';
var errorvalidationempty = '<%=errorvalidationempty%>';
var errorvalidationinteger = '<%=errorvalidationinteger%>';
var errorvalidationinferior = '<%=errorvalidationinferior%>';

var errorminparam = '<%=errorminparam%>';
var errormaxparam = '<%=errormaxparam%>';

var errorpgempty = '<%=errorpgempty%>';
var errorpgunique = '<%=errorpgunique%>';
var errorpgsupprlast = '<%=errorpgsupprlast%>';

var errorscempty = '<%=errorscempty%>';
var errorscinteger = '<%=errorscinteger%>';
var errorscpositive = '<%=errorscpositive%>';

function initDefaultWeight(){
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('#valueweightdefault').val(defaultvaluep);
	}else{*/
		$('#valueweightdefault').val(defaultvalue);
	//}
}

function onChangeAssessmentModel(){
	removeAllRangeWeight();
	removeAllValueWeight();
	removeAllAssessmentValidation();
	onChangeAddRangeWeight();
	onChangeAddValueWeight();
	onChangeAssessmentValidation();
	/*if(mode == '<%=ProfileConstants.MAX%>'){
		for(var i = 0; i < id; i++){
			$('#'+i+'.tab').removeAttr('hidden');
		}
		for(var i = 0; i < idvalue; i++){
			$('#valueWeight'+i+'.tab').removeAttr('hidden');
		}
		$('.decrem').css('display', 'none');
		$('.valueVW').css('display', 'table-cell');
	}*/
	//if(mode == '<%=ProfileConstants.SUM%>'){
		for(var i = 0; i < id; i++){
			$('#'+i+'.tab').removeAttr('hidden');
		}
		for(var i = 0; i < idvalue; i++){
			$('#valueWeight'+i+'.tab').removeAttr('hidden');
		}
		$('.decrem').css('display', 'none');
		$('.valueVW').css('display', 'table-cell');
	//}
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		for(var i = 0; i < idp; i++){
			$('#percentage'+i+'.tab').removeAttr('hidden');
		}
		for(var i = 0; i < idvaluep; i++){
			$('#valueWeightp'+i+'.tab').removeAttr('hidden');
		}
		$('.decrem').css('display', 'table-cell');
		$('.valueVW').css('display', 'none');
	}*/
}
function onChangeActionModeChoice(){
	//mode = $('#modelAssessment').val();
	//$('#modelAssementChoice').val(mode);
	$('#commentRangeWeight').val('');
	$('#commentValueWeight').val('');
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('#nbrrange').val(idp-1);
		$('#valueweightdefault').val(defaultvaluep);
	}else{*/
		$('#nbrrange').val(id-1);
		$('#valueweightdefault').val(defaultvalue);
	//}
	onChangeAssessmentModel();
	onKeyUpValidationValue();
}
function removeAllRangeWeight(){
	for(var i = 0; i < id; i++){
		$('#'+i+'.tab').attr('hidden', 'hidden');
	}
	for(var i = 0; i < idp; i++){
		$('#percentage'+i+'.tab').attr('hidden', 'hidden');
	}
}
function setSortWeight(){
	if($('#configSortWeight').attr('checked')){
		$('#configSortWeight').val('true');
	}else{
		$('#configSortWeight').val('false');
	}
}
function setDefaultValue(){
	var booldefault = $('#configDefaultValue').val();
	$('#configDefaultValueChoice').val(booldefault);
	if(booldefault == 'yes'){
		$('#minAdd').attr('disabled','disabled');
		$('#labelAdd').attr('disabled','disabled');
		$('#colorAdd').attr('disabled','disabled');
		$('#valueAdd').attr('disabled','disabled');
		$('#descAdd').attr('disabled','disabled');
		$('input.defaultWeight').each(function(){
			$(this).attr('disabled','disabled');
		});
		$('img.delRangeWeight').hide();
		$('img.delRangeWeightp').hide();
		$('img.delValue').hide();
		$('img.delValuep').hide();
		/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
			$('input.minp').attr('disabled','disabled');
			$('input.labelp').attr('disabled','disabled');
			$('select.colorp').attr('disabled','disabled');
			$('input.valuep').attr('disabled','disabled');
			$('input.descp').attr('disabled','disabled');
			$('input.decremp').attr('disabled','disabled');
			$('#decremAdd').attr('disabled','disabled');
		}else{*/
			$('input.min').attr('disabled','disabled');
			$('input.labell').attr('disabled','disabled');
			$('select.color').attr('disabled','disabled');
			$('input.value').attr('disabled','disabled');
			$('input.desc').attr('disabled','disabled');
		//}
		//$('#configDefaultValue').val('true');
	}else{
		$('#minAdd').removeAttr('disabled');
		$('#labelAdd').removeAttr('disabled');
		$('#colorAdd').removeAttr('disabled');
		$('#valueAdd').removeAttr('disabled');
		$('#descAdd').removeAttr('disabled');
		$('input.defaultWeight').each(function(){
			$(this).removeAttr('disabled');
		});
		$('img.delRangeWeight').show();
		$('img.delRangeWeight:first').hide();
		$('img.delRangeWeight:last').hide();
		$('img.delRangeWeightp').show();
		$('img.delRangeWeightp:first').hide();
		$('img.delRangeWeightp:last').hide();
		$('img.delValue').show();
		$.each(usedSeverities, function(index, value) {
			$('#delValue'+severitiesids.indexOf(value)).hide();
		});
		$('img.delValue:first').hide();
		$('img.delValue:last').hide();
		$('img.delValuep').show();
		$.each(usedSeverities, function(index, value) {
			$('#delValuep'+severitiesids.indexOf(value)).hide();
		});
		$('img.delValuep:first').hide();
		$('img.delValuep:last').hide();
		/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
			$('input.minp').removeAttr('disabled');
			$('input.minp:first').attr('disabled','disabled');
			$('input.labelp').removeAttr('disabled');
			$('select.colorp').removeAttr('disabled');
			$('input.descp').removeAttr('disabled');
			$('input.decremp').removeAttr('disabled');
			$('#decremAdd').removeAttr('disabled');
		}else{*/
			$('input.min').removeAttr('disabled');
			$('input.min:last').attr('disabled','disabled');
			$('input.labell').removeAttr('disabled');
			$('select.color').removeAttr('disabled');
			$('input.value').removeAttr('disabled');
			$('input.value:last').attr('disabled','disabled');
			$('input.desc').removeAttr('disabled');
		//}
	}
}
function onChangeAddRangeWeight(){
	$('#maxAdd').val('');
	$('#minAdd').val('');
	$('#labelAdd').val('');
	$('#commentAddRangeWeight').val('');
	$('#addRangeWeight.addRW').remove();
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('#RangeWeightAdd').append('<tr id="addRangeWeight" class="addRW"><td style="text-align:center;"><input id="minAdd" name="minAdd" type="text" style="width:33px;height:18px;" onkeyup="onChangeActionMinAdd()"/> %</td>'
				+ '<td style="text-align:center;"><input id="maxAdd" name="maxAdd" type="text" style="width:33px;height:18px;" disabled="disabled"/> %</td>'
				+ '<td style="text-align:center;"><input id="labelAdd" name="labelAdd" type="text" style="width:100px;height:18px;" onkeyup="onChangeActionMinAdd()"/></td>'
				+ '<td style="text-align:center;"><img class="iconRangeWAdd" id="iconRangeWAdd" name="iconRangeWAdd" height="22" width="22"/></td>'
				+ '<td style="text-align:center;"><select id="colorAdd" style="width:122px;height:20px;" onchange="onChangeActionColorAdd()"></select></td>'
				+ '<td><img src="../common/images/buttonDialogAdd.gif" class="addPG" onclick="onAddRangeWeightEdit();"/></td></tr>');
	}else{*/
		$('#RangeWeightAdd').append('<tr id="addRangeWeight" class="addRW"><td style="text-align:center;"><input id="minAdd" name="minAdd" type="text" style="width:50px;height:18px;" onkeyup="onChangeActionMinAdd()"/></td>'
				+ '<td style="text-align:center;"><input id="maxAdd" name="maxAdd" type="text" style="width:50px;height:18px;" disabled="disabled"/></td>'
				+ '<td style="text-align:center;"><input id="labelAdd" name="labelAdd" type="text" style="width:100px;height:18px;" onkeyup="onChangeActionMinAdd()"/></td>'
				+ '<td style="text-align:center;"><img class="iconRangeWAdd" id="iconRangeWAdd" name="iconRangeWAdd" height="22" width="22"/></td>'
				+ '<td style="text-align:center;"><select id="colorAdd" style="width:122px;height:20px;" onchange="onChangeActionColorAdd()"></select></td>'
				+ '<td><img src="../common/images/buttonDialogAdd.gif" class="addPG" onclick="onAddRangeWeightEdit();"/></td></tr>');
	//}
	addOption();
	onChangeActionColorAdd();
	setDefaultValue();
}
function OptionsList(){
	$.each(colorList, function(index, value) {
		option += "<option id='"+value+"'>"+value+"</option>";
	});
}
function addOption(){
	$.each(colorList, function(index, value) {
		$('#colorAdd').append(new Option(value, value, true, true));
	});
	$('#colorAdd').get(0).selectedIndex = 0;
}
function onChangeActionMinAdd(){
	$('#commentAddRangeWeight').val('');
	var minValue = $('#minAdd').val();
	$('#maxAdd').val('');
	if(minValue != '')
	{
		if(isNaN(parseInt(minValue))){
			$('#commentAddRangeWeight').val(errormininteger);
		}else{
			if(parseInt(minValue) < 0){
				$('#commentAddRangeWeight').val(errorminpositive);
			}else{
				// no test for SUMUP and MAX
				/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
					if(parseInt(minValue) > 99)
						$('#commentAddRangeWeight').val('min value must be below '+parseInt(maximum+1));
				}else{*/
					var exists = 0;
					/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
						$('input.minp').each(function(){
							if(parseInt($(this).val()) == parseInt(minValue)){
								exists = 1;
							}
						});
					}else{*/
						$('input.min').each(function(){
							if(parseInt($(this).val()) == parseInt(minValue)){
								exists = 1;
							}
						});
					//}
					if(parseInt(exists) == 1){
						$('#commentAddRangeWeight').val(errorminunique);
					}else{
						/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
							var max = <%=AttrRangeWeight.rangeWeightMaxPercentage%>;;
							$('input.minp').each(function(){
								var minp = $(this).val();
								if(parseInt(minp, 10) < parseInt(max, 10)){
									if(parseInt(minp, 10) > parseInt(minValue, 10)){
										max = minp;
									}
								}
							});
							$('#maxAdd').val(max-1);
						}else{*/
							var max = 'max';
							//<%=AttrRangeWeight.rangeWeightMax%>;
							$('input.min').each(function(){
								var min = $(this).val();
								if(max == 'max'){
									if(parseInt(min, 10) > parseInt(minValue, 10)){
										max = min;
									}
								}
								else if(parseInt(min, 10) < parseInt(max, 10)){
									if(parseInt(min, 10) > parseInt(minValue, 10)){
										max = min;
									}
								}
							});
							$('#maxAdd').val(max-1);
						//}
					}
				//}
			}
		}
	}
}
function onChangeActionColorAdd(){
	var colorValue = $('#colorAdd').val();
	$('#iconRangeWAdd').attr('src','../'+suite+'/images/I_Object_'+colorValue+'.png');
}
function addLineRangeWeightEdit(){
	$('#RangeWeightEdit').append(
				'<tr id="'+id+'" class="tab" style="height:24px;display:table-row;">'
			+		'<td>'+Min(id)+'</td>'
			+		'<td>'+Max(id)+'</td>'
			+		'<td>'+Label(id)+'</td>'
			+		'<td>'+displayIcon(id)+'</td>'
			+		'<td>'+Color(id)+'</td>'
			+		'<td>'+deleteElement(id)+'</td>'
			+	'</tr>');
	$('#nbrrange').val(id);
	id++;
}
function addLineRangeWeightEditp(){
	$('#RangeWeightEdit').append(
				'<tr id="percentage'+idp+'" class="tab" style="height:24px;display:table-row;">'
			+		'<td>'+MinP(idp)+'</td>'
			+		'<td>'+MaxP(idp)+'</td>'
			+		'<td>'+LabelP(idp)+'</td>'
			+		'<td>'+displayIconp(idp)+'</td>'
			+		'<td>'+ColorP(idp)+'</td>'
			+		'<td>'+deleteElementP(idp)+'</td>'
			+	'</tr>');
	$('#nbrrange').val(idp);
	idp++;
}
function addDataRangeWeightEdit(min, max, label, color){
	addLineRangeWeightEdit();
	$('#min'+(id-1)).val(min);
	$('#max'+(id-1)).val(max);
	$('#labell'+(id-1)).val(label);
	$('#color'+(id-1)).val(color);
	onChangeActionTypeRangeWeightEdit(id-1,0);
}
function addDataRangeWeightEditp(min, max, label, color){
	addLineRangeWeightEditp();
	$('#minp'+(idp-1)).val(min);
	$('#maxp'+(idp-1)).val(max);
	$('#labelp'+(idp-1)).val(label);
	$('#colorp'+(idp-1)).val(color);
	onChangeActionTypeRangeWeightEdit(idp-1,0);
}
function onAddRangeWeightEdit(){
	if($('#commentAddRangeWeight').val() == ''){
		if($('#minAdd').val() != ''){
			if($('#labelAdd').val() != ''){
				//if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
				//	addDataRangeWeightEditp($('#minAdd').val(), $('#maxAdd').val(), $('#labelAdd').val(), $('#colorAdd').val());
				//}else{
					addDataRangeWeightEdit($('#minAdd').val(), $('#maxAdd').val(), $('#labelAdd').val(), $('#colorAdd').val());
				//}
				$('#minAdd').val('');
				$('#maxAdd').val('');
				$('#labelAdd').val('');
				refreshRangeWeight(-1);
			}else{
				$('#commentAddRangeWeight').val('Missing label value');
			}
		}else{
			$('#commentAddRangeWeight').val('Missing min value');
		}
	}
}
function Min(id){
	return '<input id="min'+id+'" name="min'+id+'" type="text" style="width:50px;height:18px;" class="min" onkeyup="onChangeActionTypeRangeWeightEdit('+id+',1)"/>';
}
function Max(id){
	return '<input id="max'+id+'" name="max'+id+'" type="text" style="width:50px;height:18px;" class="max" disabled="disabled"/>';
}
function Label(id){
	console.log(id);
	return '<input id="labell'+id+'" name="labell'+id+'" type="text" style="width:100px;height:18px;" class="labell" onkeyup="onChangeActionTypeRangeWeightEdit('+id+',0)"/>';
}
function Color(id){
	var tmp = '';
	tmp+='<select id="color'+id+'" name="color'+id+'" style="width:122px;height:20px;" class="color" onchange="onChangeActionTypeRangeWeightEdit('+id+',0)">';
	tmp+=option;
	tmp+='</select>';
	return tmp;
}
function displayIcon(id){
	return '<img class="iconRangeW" id="iconRangeW'+id+'" name="iconRangeW'+id+'" height="22" width="22"/>';
}
function deleteElement(id){
	return '<img src="../common/images/buttonDialogCancel.gif" class="delRangeWeight" onclick="onDelete('+id+')"/>';
} 
function MinP(id){
	return '<input id="minp'+id+'" name="minp'+id+'" type="text" style="width:33px;height:18px;" class="minp" onkeyup="onChangeActionTypeRangeWeightEdit('+id+',1)"/> %';
}
function MaxP(id){
	return '<input id="maxp'+id+'" name="maxp'+id+'" type="text" style="width:33px;height:18px;" class="maxp" disabled="disabled"/> %';
}
function LabelP(id){
	return '<input id="labelp'+id+'" name="labelp'+id+'" type="text" style="width:100px;height:18px;" class="labelp" onkeyup="onChangeActionTypeRangeWeightEdit('+id+',0)"/>';
}
function ColorP(id){
	var tmp = '';
	tmp+='<select id="colorp'+id+'" name="colorp'+id+'" style="width:122px;height:20px;" class="colorp" onchange="onChangeActionTypeRangeWeightEdit('+id+',0)">';
	tmp+=option;
	tmp+='</select>';
	return tmp;
}
function displayIconp(id){
	return '<img class="iconRangeWp" id="iconRangeWp'+id+'" name="iconRangeWp'+id+'" height="22" width="22"/>';
}
function deleteElementP(id){
	return '<img src="../common/images/buttonDialogCancel.gif" class="delRangeWeightp" onclick="onDeletep('+id+')"/>';
} 
function onChangeActionTypeRangeWeightEdit(id,focus){
	$('#commentRangeWeight').val('');
	var colorValue;
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		colorValue = $('#colorp'+id).val();
		$('#iconRangeWp'+id).attr('src','../'+suite+'/images/I_Object_'+colorValue+'.png');
		$('img.delRangeWeightp').show();
		$('img.delRangeWeightp:first').hide();
		$('img.delRangeWeightp:last').hide();
		$('input.minp').removeAttr('disabled');
		$('input.minp:first').attr('disabled','disabled');
		if($('#minp'+id).val() == ''){
			$('#commentRangeWeight').val(errorminempty);
		}else{
			if($('#labelp'+id).val() == ''){
				$('#commentRangeWeight').val(errorlabelempty);
			}else{
				if(parseInt($('#minp'+id).val()) < 0){
					$('#commentRangeWeight').val(errorminpositive);
				}else{
					if(isNaN(parseInt($('#minp'+id).val()))){
						$('#commentRangeWeight').val(errormininteger);
					}else{
						var exists = 0;
						$('input.minp').each(function(){
							var idmin = $(this).attr('id');
							var length = idmin.length;
							idmin = idmin.substring(4,length);
							if(idmin != id){
								if(parseInt($(this).val()) == parseInt($('#minp'+id).val())){
									exists = 1;
								}
							}
						});
						if(parseInt(exists) == 1){
							$('#commentRangeWeight').val(errorminunique);
						}else{
							if(focus)
								refreshRangeWeight(id);
							else
								refreshRangeWeight(-1);
						}
					}
				}
			}
		}
	}else{*/
		colorValue = $('#color'+id).val();
		$('#iconRangeW'+id).attr('src','../'+suite+'/images/I_Object_'+colorValue+'.png');
		$('img.delRangeWeight').show();
		$('img.delRangeWeight:first').hide();
		$('img.delRangeWeight:last').hide();
		$('input.min').removeAttr('disabled');
		$('input.min:last').attr('disabled','disabled');
		if($('#min'+id).val() == ""){
			$('#commentRangeWeight').val(errorminempty);
		}else{
			if($('#labell'+id).val() == ""){
				$('#commentRangeWeight').val(errorlabelempty);
			}else{
				if(parseInt($('#min'+id).val()) < 0){
					$('#commentRangeWeight').val(errorminpositive);
				}else{
					if(isNaN(parseInt($('#min'+id).val()))){
						$('#commentRangeWeight').val(errormininteger);
					}else{
						var exists = 0;
						$('input.min').each(function(){
							var idmin = $(this).attr('id');
							var length = idmin.length;
							idmin = idmin.substring(3,length);
							if(idmin != id){
								if(parseInt($(this).val()) == parseInt($('#min'+id).val())){
									exists = 1;
								}
							}
						});
						if(parseInt(exists) == 1){
							$('#commentRangeWeight').val(errorminunique);
						}else{
							if(focus)
								refreshRangeWeight(id);
							else
								refreshRangeWeight(-1);
						}
					}
				}
			}
		}
	//}
}
function onDelete(idline){
	var idsuppr = id-1;
	for(var i = idline; i<idsuppr; i++){
		var j = i+1;
		$('#min'+i).val($('#min'+j).val());
		$('#max'+i).val($('#max'+j).val());
		$('#labell'+i).val($('#labell'+j).val());
		$('#color'+i).val($('#color'+j).val());
		$('#iconRangeW'+i).attr('src','../'+suite+'/images/I_Object_'+$('#colorp'+j).val()+'.png');
	}
	$('#'+idsuppr+'.tab').remove();
	id--;
	$('img.delRangeWeight').show();
	$('img.delRangeWeight:first').hide();
	$('img.delRangeWeight:last').hide();
	$('input.min:last').attr('disabled','disabled');
	$('#nbrrange').val(id-1);
	refreshRangeWeight(-1);
}
function onDeletep(idline){
	var idsuppr = idp-1;
	for(var i = idline; i<idsuppr; i++){
		var j = i+1;
		$('#minp'+i).val($('#minp'+j).val());
		$('#maxp'+i).val($('#maxp'+j).val());
		$('#labelp'+i).val($('#labelp'+j).val());
		$('#colorp'+i).val($('#colorp'+j).val());
		$('#iconRangeWp'+i).attr('src','../'+suite+'/images/I_Object_'+$('#colorp'+j).val()+'.png');
	}
	$('#percentage'+idsuppr+'.tab').remove();
	idp--;
	$('img.delRangeWeightp').show();
	$('img.delRangeWeightp:first').hide();
	$('img.delRangeWeightp:last').hide();
	$('input.minp:first').attr('disabled','disabled');
	$('#nbrrange').val(idp-1);
	refreshRangeWeight(-1);
}
function refreshRangeWeight(idfocus){
	$('#commentRangeWeight').val('');
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('input.minp').each(function(){
			var min=$(this).val();
			var idmin = $(this).attr('id');
			var length = idmin.length;
			idmin = idmin.substring(4,length);
			var max = parseInt('<%=AttrRangeWeight.rangeWeightMaxPercentage%>');
			$('input.minp').each(function(){
				var value = $(this).val();
				if(parseInt(value) < parseInt(max)){
					if(parseInt(value) > parseInt(min)){
						max = value;
					}
				}
			});
			$('#maxp'+idmin).val(max-1);
		});
		var sortRangeWeight = [];
		var rangeWeightList = [];
		var idFocusList = [];
		for(var i = 0; i<idp; i++){
			if(!isNaN(parseInt(parseInt($('#minp'+i).val()))))
				//stocke valeur du min et l'id de l'input
				rangeWeightList.push(parseInt($('#minp'+i).val())+":"+i);
		}
		for(var i = 0; i<rangeWeightList.length; i++){
			var tmp = rangeWeightList[i];
			var position = tmp.indexOf(':',0);
			var min = tmp.substring(0,position);
			var idmin = tmp.substring(position+1,tmp.length);
			var idlist = -1;
			for(var j = i; j<rangeWeightList.length; j++){
				tmp = rangeWeightList[j];
				position = tmp.indexOf(':',0);
				if(parseInt(tmp.substring(0,position)) < parseInt(min)){
					min = tmp.substring(0,position);
					idmin = tmp.substring(position+1,tmp.length);
					idlist = j;
				}
			}
			tmp = rangeWeightList[i];
			position = tmp.indexOf(':',0);
			if(parseInt(tmp.substring(0,position)) != parseInt(min)){
				rangeWeightList[idlist] = rangeWeightList[i];
				rangeWeightList[i] = min+":"+idmin;
			}
		}
		for(var i = 0; i<rangeWeightList.length; i++){
			var tmp = rangeWeightList[i];
			var position = tmp.indexOf(':',0);
			var min = tmp.substring(0,position);
			var idmin = tmp.substring(position+1,tmp.length);
			idFocusList.push(parseInt(idmax));
			sortRangeWeight.push(i+":"+min+":"+$('#maxp'+idmin).val()+":"+$('#labelp'+idmin).val()+":"+$('#colorp'+idmin).val());
		}
		for(var i = 0; i<sortRangeWeight.length; i++){
			var data = sortRangeWeight[i];
			var position = data.indexOf(':',0);
			var iddata = data.substring(0,position);
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#minp'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#maxp'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#labelp'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.length;
			$('#colorp'+iddata).val(data.substring(0,position));
			$('#iconRangeWp'+iddata).attr('src','../'+suite+'/images/I_Object_'+data.substring(0,position)+'.png');
		}
		if(parseInt(idfocus) != -1){
			var index = idFocusList.indexOf(idfocus);
			$('#min'+index).focus();
		}
	}else{*/
		$('input.min').each(function(){
			var min=$(this).val();
			
			var idmin = $(this).attr('id');
			var length = idmin.length;
			idmin = idmin.substring(3,length);
			var max = 'max';
			//parseInt('<%=AttrRangeWeight.rangeWeightMax%>');
			$('input.min').each(function(){
				var value = $(this).val();
				if(max == 'max'){
					if(parseInt(value) > parseInt(min)){
						max = value;
					}
				}else if(parseInt(value) < parseInt(max)){
					if(parseInt(value) > parseInt(min)){
						max = value;
					}
				}
			});
			if(max == 'max')
				$('#max'+idmin).val(max);
			else
				$('#max'+idmin).val(max-1);
		});
		var sortRangeWeight = [];
		var rangeWeightList = [];
		var idFocusList = [];
		for(var i = 0; i<id; i++){
			if(!isNaN(parseInt(parseInt($('#min'+i).val()))))
				//stocke valeur du min et l'id de l'input
				rangeWeightList.push(parseInt($('#min'+i).val())+":"+i);
		}
		for(var i = 0; i<rangeWeightList.length; i++){
			var tmp = rangeWeightList[i];
			var position = tmp.indexOf(':',0);
			var max = tmp.substring(0,position);
			var idmax = tmp.substring(position+1,tmp.length);
			var idlist = -1;
			for(var j = i; j<rangeWeightList.length; j++){
				tmp = rangeWeightList[j];
				position = tmp.indexOf(':',0);
				if(parseInt(tmp.substring(0,position)) > parseInt(max)){
					max = tmp.substring(0,position);
					idmax = tmp.substring(position+1,tmp.length);
					idlist = j;
				}
			}
			tmp = rangeWeightList[i];
			position = tmp.indexOf(':',0);
			if(parseInt(tmp.substring(0,position)) != parseInt(max)){
				rangeWeightList[idlist] = rangeWeightList[i];
				rangeWeightList[i] = max+":"+idmax;
			}
		}
		for(var i = 0; i<rangeWeightList.length; i++){
			var tmp = rangeWeightList[i];
			var position = tmp.indexOf(':',0);
			var max = tmp.substring(0,position);
			var idmax = tmp.substring(position+1,tmp.length);
			idFocusList.push(parseInt(idmax));
			sortRangeWeight.push(i+":"+max+":"+$('#max'+idmax).val()+":"+$('#labell'+idmax).val()+":"+$('#color'+idmax).val());
		}
		for(var i = 0; i<sortRangeWeight.length; i++){
			var data = sortRangeWeight[i];
			var position = data.indexOf(':',0);
			var iddata = data.substring(0,position);
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#min'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#max'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.indexOf(':',0);
			$('#labell'+iddata).val(data.substring(0,position));
			data = data.substring(position+1,data.length);
			position = data.length;
			$('#color'+iddata).val(data.substring(0,position));
			$('#iconRangeW'+iddata).attr('src','../'+suite+'/images/I_Object_'+data.substring(0,position)+'.png');
		}
		if(parseInt(idfocus) != -1){
			var index = idFocusList.indexOf(idfocus);
			$('#min'+index).focus();
		}
	//}
}
function addLineValueWEdit(){
	$('#ValueWeightEdit').append(
			'<tr id=\"valueWeight'+idvalue+'\" class=\"tab\" style=\"height:24px;display:table-row;\">'
		+		'<td>'+Value(idvalue)+'</td>'
		+		'<td>'+Desc(idvalue)+'</td>'
		+		'<td>'+DefaultWeight(idvalue)+'</td>'
		+		'<td></td>'
		+		'<td>'+deleteElementValueW(idvalue)+'</td>'
		+	'</tr>');
	$('#nbrvalueweight').val(idvalue);
	idvalue++;
}
function addLineValueWEditp(){
	$('#ValueWeightEdit').append(
			'<tr id=\"valueWeightp'+idvaluep+'\" class=\"tab\" style=\"height:24px;display:table-row;\">'
		+		'<td>'+Decrementationp(idvaluep)+'</td>'
		+		'<td>'+Descp(idvaluep)+'</td>'
		+		'<td>'+DefaultWeightp(idvaluep)+'</td>'
		+		'<td></td>'
		+		'<td>'+deleteElementValueWp(idvaluep)+'</td>'
		+	'</tr>');
	$('#nbrvalueweight').val(idvaluep);
	idvaluep++;
}
function addDataValueWEdit(value, desc){
	addLineValueWEdit();
	$('#value'+(idvalue-1)).val(value);
	$('#desc'+(idvalue-1)).val(desc);
	$('#defaultWeight'+(idvalue-1)).val(value);
	if((idvalue-1) == defaultvalue){
		$('#defaultWeight'+(idvalue-1)).attr('checked', 'checked');
		$('#valueweightdefault').val((idvalue-1));
	}
	onChangeActionTypeValueWEdit(idvalue-1,0);
}
function addDataValueWEditp(value, desc, decrem){
	addLineValueWEditp();
	$('#descp'+(idvaluep-1)).val(desc);
	$('#decremp'+(idvaluep-1)).val(decrem);
	$('#defaultWeightp'+(idvaluep-1)).val(value);
	if((idvaluep-1) == defaultvaluep){
		$('#defaultWeightp'+(idvaluep-1)).attr('checked', 'checked');
		$('#valueweightdefault').val((idvaluep-1));
	}
	onChangeActionTypeValueWEdit(idvaluep-1,0);
}
function Value(id){
	return '<input id="value'+id+'" name="value'+id+'" type="text" style="width:50px;height:18px;" class="value" onkeyup="onChangeActionTypeValueWEdit('+id+',1)"/>';
}
function Desc(id){
	return '<input id="desc'+id+'" name="desc'+id+'" type="text" style="width:100px;height:18px" class="desc"/>';
}
function DefaultWeight(id){
	return '<center><input type="radio" class="defaultWeight" id="defaultWeight'+id+'" onclick="onChangeDefaultWeight('+id+')" name="defaultWeight"></center>';
}
function deleteElementValueW(id){
	return '<img src="../common/images/buttonDialogCancel.gif" id="delValue'+id+'" name="delValue'+id+'" class="delValue" onclick="onDeleteValueW('+id+')"/>';
}
function Descp(id){
	return '<input id="descp'+id+'" name="descp'+id+'" type="text" style="width:100px;height:18px" class="descp"/>';
}
function DefaultWeightp(id){
	return '<center><input type="radio" class="defaultWeight" id="defaultWeightp'+id+'" onclick="onChangeDefaultWeight('+id+')" name="defaultWeightp"></center>';
}
function Decrementationp(id){
	return '<input id="decremp'+id+'" name="decremp'+id+'" type="text" style="width:100px;height:18px" class="decremp" onkeyup="onChangeActionTypeValueWEdit('+id+',2)"/>';
}
function deleteElementValueWp(id){
	return '<img src="../common/images/buttonDialogCancel.gif" class="delValuep" onclick="onDeleteValueWp('+id+')"/>';
}
function onChangeDefaultWeight(id){
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		defaultvaluep = id;
	}
	else{*/
		defaultvalue = id;
	//}
	$('#valueweightdefault').val(id);
}
function removeAllValueWeight(){
	for(var i = 0; i < idvalue; i++){
		$('#valueWeight'+i+'.tab').attr('hidden', 'hidden');
	}
	for(var i = 0; i < idvaluep; i++){
		$('#valueWeightp'+i+'.tab').attr('hidden', 'hidden');
	}
}
function onChangeAddValueWeight(){
	$('#valueAdd').val('');
	$('#descAdd').val('');
	$('#decremAdd').val('');
	$('#commentAddValueWeight').val('');
	$('#addValueWeight.addVW').remove();
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('#ValueWeightAdd').append('<tr id="addValueWeight" class="addVW"><td style="text-align:center;"><input id="decremAdd" name="decremAdd" type="text" style="width:100px;height:18px;" onkeyup="onChangeActionValueAdd()"/></td>'
				+ '<td style="text-align:center;"><input id="descAdd" name="descAdd" type="text" style="width:100px;height:18px;" onkeyup="onChangeActionValueAdd()"/></td>'
				+ '<td><img src="../common/images/buttonDialogAdd.gif" class="addPG" onclick="onAddValueWeightEdit();"/></td></tr>');
	}else{*/
		$('#ValueWeightAdd').append('<tr id="addValueWeight" class="addVW"><td style="text-align:center;"><input id="valueAdd" name="valueAdd" type="text" style="width:50px;height:18px;" onkeyup="onChangeActionValueAdd()"/></td>'
				+ '<td style="text-align:center;"><input id="descAdd" name="descAdd" type="text" style="width:100px;height:18px;" onkeyup="onChangeActionValueAdd()"/></td>'
				+ '<td><img src="../common/images/buttonDialogAdd.gif" class="addPG" onclick="onAddValueWeightEdit();"/></td></tr>');
	//}
	onChangeActionColorAdd();
	setDefaultValue();
}
function onChangeActionValueAdd(){
	$('#commentAddValueWeight').val('');
	/*if(mode != '<%=ProfileConstants.PERCENTAGE%>'){
		var valValue = $('#valueAdd').val();
		if(valValue != '')
		{
			if(isNaN(parseInt(valValue))){
				$('#commentAddValueWeight').val(errorinteger);
			}else{
				if(parseInt(valValue) < 0){
					$('#commentAddValueWeight').val(errorpositive);
				}else{
					var maximum = 998;
					if(parseInt(valValue) > parseInt(maximum)){
						$('#commentAddValueWeight').val('min value must be below '+parseInt(maximum+1));
					}else{
						var exists = 0;
							if($('input.value') == ""){
								$('#commentAddValueWeight').val(errorvalueempty);
							}else{
								$('input.value').each(function(){
									if(parseInt($(this).val()) == parseInt(valValue)){
										exists = 1;
									}
								});
							}
						if(parseInt(exists) == 1){
							$('#commentAddValueWeight').val(errorunique);
						}
					}
				}
			}
		}
	}*/
	if($('#commentAddValueWeight').val() == ''){
		var decrem = $('#decremAdd').val();
		if(decrem.indexOf("<%=ProfileConstants.typeSeparator%>") != -1){
			while(decrem.indexOf("<%=ProfileConstants.typeSeparator%>") != -1){
				var position = decrem.indexOf('<%=ProfileConstants.typeSeparator%>',0);
				var valuedecrem = decrem.substring(0,position);
				if(isNaN(parseInt(valuedecrem))){
					$('#commentAddValueWeight').val(errordecremseparator);
				}else{
					if(parseInt(valuedecrem) > 100){
						$('#commentAddValueWeight').val(errordecremmax);
					}else{
						decrem = decrem.substring(position+1,decrem.length);
					}
				}
			}
			if(isNaN(parseInt(decrem))){
				$('#commentAddValueWeight').val(errordecremseparator);
			}else{
				if(parseInt(decrem) > 100){
					$('#commentAddValueWeight').val(errordecremmax);
				}else{
					$('#onChangeActionValueAdd').val('');
					refreshValueWeight(-1,0);
				}
			}
		}else{
			if(isNaN(parseInt(decrem))){
				$('#commentAddValueWeight').val(errordecremseparator);
			}else{
				if(parseInt(decrem) > 100){
					$('#commentAddValueWeight').val(errordecremmax);
				}else{
					$('#commentAddValueWeight').val('');
					refreshValueWeight(-1,0);
				}
			}
		}
	}
}
function onAddValueWeightEdit(){
	if($('#commentAddValueWeight').val() == ''){
		if($('#valueAdd').val() != ''){
			if($('#descAdd').val() != ''){
				if($('#decremAdd').val() != ''){
					/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
						addDataValueWEditp($('#valueAdd').val(), $('#descAdd').val(), $('#decremAdd').val());
						newseverity = $('#valueAdd').val();
					}else{*/
						addDataValueWEdit($('#valueAdd').val(), $('#descAdd').val());
						newseverity = $('#valueAdd').val();
					//}
					$('#valueAdd').val('');
					$('#descAdd').val('');
					$('#decremAdd').val('');
					refreshValueWeight(-1,0);
				}else{
					$('#commentAddValueWeight').val('Missing decrementation value');
				}
			}else{
				$('#commentAddValueWeight').val('Missing label value');
			}
		}else{
			$('#commentAddValueWeight').val('Missing value');
		}
	}
}
function refreshValueWeight(idfocus, focus){
	console.log('mode '+mode);
	$('#commentValueWeight').val('');
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('input.decremp').each(function(){
			var decrem = $(this).val();
			var firstdecrem;
			var iddecrem = $(this).attr('id');
			var length = iddecrem.length;
			iddecrem = iddecrem.substring(7,length);
			var idexchange = -1;
			var desc = $('#descp'+iddecrem).val();
			var dweight = $('#defaultWeightp'+iddecrem).val();
			if(newseverity != -1 && newseverity == val){
				severityid = idmin;
				var tmp = [];
				for(var i = 0; i < severitiesids.length; i++){
					if(severityid == i){
						tmp.push('new');
						tmp.push(severitiesids[i]);
					}
					else
						tmp.push(severitiesids[i]);
				}
				severitiesids = tmp;
				$('#severitiesids').val(severitiesids);
				$('img.delValuep').show();
				$.each(usedSeverities, function(index, value) {
					$('#delValuep'+severitiesids.indexOf(value)).hide();
				});
				$('img.delValuep:first').hide();
				$('img.delValuep:last').hide();
			}
			if(decrem.indexOf("<%=ProfileConstants.typeSeparator%>") != -1){
				var position = decrem.indexOf('<%=ProfileConstants.typeSeparator%>');
				firstdecrem = decrem.substring(0,position);
			}else{
				firstdecrem = decrem;
			}
			for(var i = parseInt(iddecrem); i<parseInt(idvaluep); i++){
				if(parseInt(firstdecrem) < parseInt($('#decremp'+i).val())){
					idexchange = i;
				}
			}
			//console.log("idfocus "+idfocus+" iddecrem "+iddecrem+" idexchange "+idexchange);
			if((parseInt(iddecrem) == parseInt(idfocus)) && (parseInt(idfocus) != -1) && (parseInt(iddecrem) != -1) && (parseInt(idexchange) != -1)){
				idfocus = idexchange;
				//console.log("newidfocus "+idfocus);
			}else if((parseInt(idexchange) == parseInt(idfocus)) && (parseInt(idfocus) != -1) && (parseInt(iddecrem) != -1) && (parseInt(idexchange) != -1)){
				idfocus = iddecrem;
				//console.log("newidfocus "+idfocus);
			}
			if(parseInt(idexchange) != -1){
				$('#descp'+iddecrem).val($('#descp'+idexchange).val());
				$('#defaultWeightp'+iddecrem).val($('#defaultWeightp'+idexchange).val());
				$('#decremp'+iddecrem).val($('#decremp'+idexchange).val());
				$('#descp'+idexchange).val(desc);
				$('#defaultWeightp'+idexchange).val(dweight);
				$('#decremp'+idexchange).val(decrem);
				if($('#defaultWeightp'+iddecrem).attr('checked')){
					$('#defaultWeightp'+idexchange).attr('checked', 'checked');
					//console.log('check'+idexchange);
				}else if($('#defaultWeightp'+idexchange).attr('checked')){
					$('#defaultWeightp'+iddecrem).attr('checked', 'checked');
				}
				if(severitiesids.length == idvaluep){
						var tmp = severitiesids[i];
						severitiesids[i] = severitiesids[idmin];
						severitiesids[idmin] = tmp;
						$('#severitiesids').val(severitiesids);
						$('img.delValuep').show();
						$.each(usedSeverities, function(index, value) {
							$('#delValuep'+severitiesids.indexOf(value)).hide();
						});
						$('img.delValuep:first').hide();
						$('img.delValuep:last').hide();
					}
			}
		});
	}else{*/
		var severityid = -1;
		$('input.value').each(function(){
			var val = $(this).val();
			var idmin = $(this).attr('id');
			var length = idmin.length;
			idmin = idmin.substring(5,length);
			var desc = $('#desc'+idmin).val();
			var dweight = $('#defaultWeight'+idmin).val();
			if(newseverity != -1 && newseverity == val){
				severityid = idmin;
				var tmp = [];
				for(var i = 0; i < severitiesids.length; i++){
					if(severityid == i){
						tmp.push('new');
						tmp.push(severitiesids[i]);
					}
					else
						tmp.push(severitiesids[i]);
				}
				severitiesids = tmp;
				$('#severitiesids').val(severitiesids);
				$('img.delValue').show();
				$.each(usedSeverities, function(index, value) {
					$('#delValue'+severitiesids.indexOf(value)).hide();
				});
				$('img.delValue:first').hide();
				$('img.delValue:last').hide();
			}
			for(var i = parseInt(idmin); i < parseInt(idvalue); i++){
				if(parseInt($('#value'+i).val()) > parseInt(val)){
					$('#value'+idmin).val($('#value'+i).val());
					$('#desc'+idmin).val($('#desc'+i).val());
					$('#defaultWeight'+idmin).val($('#defaultWeight'+i).val());
					$('#value'+i).val(val);
					$('#desc'+i).val(desc);
					$('#defaultWeight'+i).val(dweight);
					if(severitiesids.length == idvalue){
						var tmp = severitiesids[i];
						severitiesids[i] = severitiesids[idmin];
						severitiesids[idmin] = tmp;
						$('#severitiesids').val(severitiesids);
						$('img.delValue').show();
						$.each(usedSeverities, function(index, value) {
							$('#delValue'+severitiesids.indexOf(value)).hide();
						});
						$('img.delValue:first').hide();
						$('img.delValue:last').hide();
					}
					if(parseInt(idmin) == parseInt(idfocus)){
						idfocus = i;
					}
					idmin = i;
					if($('#defaultWeightp'+idmin).attr('checked')){
						$('#defaultWeightp'+i).attr('checked', 'checked');
					}else if($('#defaultWeightp'+i).attr('checked')){
						$('#defaultWeightp'+idmin).attr('checked', 'checked');
					}
				}
			}
			
		});
	//}
	if(parseInt(idfocus) > 0){
		if(parseInt(focus) == 1){
			$('#value'+idfocus).focus();
		}else{
			$('#decremp'+idfocus).focus();
		}
	}
	newseverity = -1;
}
function onChangeActionTypeValueWEdit(id,focus){
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		$('img.delValuep').show();
		$.each(usedSeverities, function(index, value) {
			$('#delValuep'+severitiesids.indexOf(value)).hide();
		});
		$('img.delValuep:first').hide();
		$('img.delValuep:last').hide();
		if($('#descp'+id).val() == ''){
			$('#commentValueWeight').val(errorlabelempty);
		}else{
			if($('#decremp'+id).val() == ''){
				$('#commentValueWeight').val(errordecremempty);
			}else{
				var decrem = $('#decremp'+id).val();
				if(decrem.indexOf("<%=ProfileConstants.typeSeparator%>") != -1){
					while(decrem.indexOf("<%=ProfileConstants.typeSeparator%>") != -1){
						var position = decrem.indexOf('<%=ProfileConstants.typeSeparator%>',0);
						var valuedecrem = decrem.substring(0,position);
						if(isNaN(parseInt(valuedecrem))){
							$('#commentValueWeight').val(errordecremseparator);
						}else{
							if(parseInt(valuedecrem) > 100){
								$('#commentValueWeight').val(errordecremmax);
							}else{
								decrem = decrem.substring(position+1,decrem.length);
							}
						}
					}
					if(isNaN(parseInt(decrem))){
						$('#commentValueWeight').val(errordecremseparator);
					}else{
						if(parseInt(decrem) > 100){
							$('#commentValueWeight').val(errordecremmax);
						}else{
							$('#commentValueWeight').val('');
							refreshValueWeight(id, focus);
						}
					}
				}else{
					if(isNaN(parseInt(decrem))){
						$('#commentValueWeight').val(errordecremseparator);
					}else{
						if(parseInt(decrem) > 100){
							$('#commentValueWeight').val(errordecremmax);
						}else{
							$('#commentValueWeight').val('');
							refreshValueWeight(id, focus);
						}
					}
				}
			}
		}
	}else{*/
		if($('#value'+id).val() != ''){;
			$('#defaultWeight'+(id)).val($('#value'+id).val());
		}
		$('img.delValue').show();
		$.each(usedSeverities, function(index, value) {
			$('#delValue'+severitiesids.indexOf(value)).hide();
		});
		$('img.delValue:first').hide();
		$('img.delValue:last').hide();
		$('input.value').removeAttr('disabled');
		$('input.value:last').attr('disabled','disabled');
		if($('#value'+id).val() == ''){
			$('#commentValueWeight').val(errorvalueempty);
		}else{
			if($('#desc'+id).val() == ''){
				$('#commentValueWeight').val(errorlabelempty);
			}else{
				if($('#decrem'+id).val() == ''){
					$('#commentValueWeight').val(errordecremempty);
				}else{
					if(parseInt($('#value'+id).val()) < 0){
						$('#commentValueWeight').val(errorpositive);
					}else{
						if(isNaN(parseInt($('#value'+id).val()))){
							$('#commentValueWeight').val(errorinteger);
						}else{
							var exists = 0;
							$('input.value').each(function(){
								var idmin = $(this).attr('id');
								var length = idmin.length;
								idmin = idmin.substring(5,length);
								if(idmin != id){
									if(parseInt($(this).val()) == parseInt($('#value'+id).val())){
										exists = 1;
									}
								}
							});
							if(parseInt(exists) == 1){
								$('#commentValueWeight').val(errorunique);
							}else{
								$('#commentValueWeight').val('');
								refreshValueWeight(id, focus);
							}
						}
					}
				}
			}
		}
	//}
}
function onDeleteValueW(idline){
	if(defaultvalue == idline){
		$('#valueweightdefault').val('0');
		$('#defaultWeight0').attr('checked','checked');
		defaultvalue = 0;
	}
	var idsuppr = idvalue-1;
	for(var i = idline; i<idsuppr; i++){
		var j = i+1;
		$('#value'+i).val($('#value'+j).val());
		$('#desc'+i).val($('#desc'+j).val());
	}
	$('#valueWeight'+idsuppr+'.tab').remove();
	idvalue--;
	$('img.delValue').show();
	severitiesids.splice(idline,1);
	$('#severitiesids').val(severitiesids);
	$.each(usedSeverities, function(index, value) {
		$('#delValue'+severitiesids.indexOf(value)).hide();
	});
	$('img.delValue:first').hide();
	$('img.delValue:last').hide();
	$('input.value:last').attr('disabled','disabled');
	$('#nbrvalueweight').val(idvalue-1);
	
	refreshValueWeight(-1,0);
}
function onDeleteValueWp(idline){
	if(defaultvaluep == idline){
		$('#valueweightdefault').val('0');
		$('#defaultWeightp0').attr('checked','checked');
		defaultvaluep = 0;
	}
	var idsuppr = idvaluep-1;
	for(var i = idline; i<idsuppr; i++){
		var j = i+1;
		$('#decremp'+i).val($('#value'+j).val());
		$('#descp'+i).val($('#desc'+j).val());
	}
	$('#valueWeightp'+idsuppr+'.tab').remove();
	idvaluep--;
	$('img.delValuep').show();
	severitiesids.splice(idline,1);
	$('#severitiesids').val(severitiesids);
	$.each(usedSeverities, function(index, value) {
		$('#delValuep'+severitiesids.indexOf(value)).hide();
	});
	$('img.delValuep:first').hide();
	$('img.delValuep:last').hide();
	$('#nbrvalueweight').val(idvaluep-1);
	refreshValueWeight(-1,0);
}

function addDataPGEdit(title, value){
	$('#selectPG').append(new Option(title, value, true, true));
	onChangeSelectedPG();
	onChangePGEdit();
}

function TitleView(id, title){
	return '<input id="title'+id+'" name="title'+id+'" type="text" style="width:100px;height:18px;" value="'+title+'" disabled="disabled"/>';
}

function ValuePGView(id, value){
	return '<input id="valuePG'+id+'" name="valuePG'+id+'" type="text" style="width:30px;height:18px;" value="'+value+'" disabled="disabled"/>';
}

function onAddPGEdit(){
	onClickPGAdd();
	if($('#commentAddPG').val() == ""){
		var title = $('#titlePG').val();
		if(title != ""){
			$('#selectPG').append(new Option(title, title, true, true));
			$('#titlePG').val('');
		}
		onChangeSelectedPG();
		onChangePGEdit();
	}
}

function onClickClearPGComment(){
	$('#commentAddPG').val('');
}

function onUpPGEdit(){
	$('#selectPG option:selected').insertBefore($('#selectPG option:selected').prev());
	onChangePGEdit();
}

function onDownPGEdit(){
	$('#selectPG option:selected').insertAfter($('#selectPG option:selected').next());
	onChangePGEdit();
}

function onDeletePGEdit(){
	var del = $('#selectPG option:selected').prevAll().size();
	var val = $('#selectPG option:selected').val();
	if($('#selectPG option').length == 1){
		alert(errorpgsupprlast);
	}else if((jQuery.inArray(val, instanciatePG) != ""))
	{
		$('#selectPG option:selected').remove();
	}
	$('#selectPG').val($('#selectPG option:first').val());
	$('#updateTitlePG').val($('#selectPG option:first').text());
	onChangePGEdit();
}

function onChangeSelectedPG(){
	$('#updateTitlePG').val($('#selectPG option:selected').text());
	if((jQuery.inArray($('#selectPG option:selected').val(), instanciatePG) > -1)){
		$('img.deletePG').hide();
	}
	else{
		$('img.deletePG').show();
	}
	if($('#selectPG option:selected').prevAll().size() == 0)
		$('img.deletePG').hide();
	onChangePGEdit();
}

function onUpdatePGEdit(){
	$('#commentValueWeight').val('');
	if('' != $('#updateTitlePG').val()){
		$('#selectPG option:selected').text($('#updateTitlePG').val());
		onChangePGEdit();
	}else{
		$('#commentValueWeight').val(errorpgempty);
	}
}

function onChangePGEdit(){
	var values = '';
	$("#selectPG>option").each(function() {
		if((jQuery.inArray($(this).val(), instanciatePG) > -1)){
			$(this).css('color','red');
		}
		else{
			$(this).css('color','black');
		}
		if($(this).text() == $(this).val()){
			if(values == ''){
				values = $(this).text() + ':' + 'NEW' + $(this).val() +'NEW';
			}
			else{
				values += ',' + $(this).text() + ':' + 'NEW' + $(this).val() + 'NEW';
			}
		}else{
			if(values == ''){
				values = $(this).text() + ':' + $(this).val();
			}
			else{
				values += ',' + $(this).text() + ':' + $(this).val();
			}
		}
	});	
	if((jQuery.inArray($('#selectPG option:selected').val(), instanciatePG) > -1)){
		$('img.deletePG').hide();
	}
	else{
		$('img.deletePG').show();
	}
	$('#listPG').val(values);
}

function displayImportList(){
	$('#attrImportList').val(defaultList);
	$('input[needImportationMethod=true][type=checkbox]').click(function(){
		if(!$(this).is(':checked')) {
			$(this).removeAttr("checked");
			var size = $('input[needImportationMethod=true][checked=checked]').length;
			if(size ==0 ) {
				$("input[type=radio]").attr('disabled', 'disabled');
			}
		} else {
			$(this).attr('checked', 'checked');
			var size = $('input[needImportationMethod=true][checked=checked]').length;
			if(size == 0 ) {
				$("input[type=radio]").attr('disabled', 'disabled');
			}
			$("input[type=radio]").removeAttr("disabled");
		}
	});
	onCheckedImportOptions();
}

function onCheckedImportOptions(){
	var errorImport = '';
	$('#commentImportWeight').val('');
	if($('#IMPORT_WEIGHTRANGE').attr('checked') || $('#IMPORT_WEIGHTVALUE').attr('checked')){
		if(!$('#IMPORT_MODELASSESSMENT').attr('checked')){
			errorImport = errorImport + errorimportweight + "\n";
			$('#IMPORT_MODELASSESSMENT').attr('checked','checked');
		}
	}
	//if($('#IMPORT_PLMPROFILECHECKINSTANCE').attr('checked')){
	//	if(!$('#IMPORT_PLMPROCESSINGGROUP').attr('checked')){
	//		errorImport = errorImport + errorimportpg;
	//	}
	//}
	$('#commentImportWeight').val(errorImport);
	var attr = '';
	var prefix = '';
	$('input[type=checkbox]').each(function() {
		if($(this).is(':checked')) {
			attr += prefix;
			prefix = '<%=ProfileConstants.objectSeparator%>';
			attr += $(this).attr('id');
		}
	});
	$('#attrImportList').val(attr);
}

function onClickPGAdd(){
	$('#commentAddPG').val("");
	var name = $('#titlePG').val();
	if(name == ''){
		$('#commentAddPG').val(errorpgempty);
	}else{
		$("#selectPG option").each(function(){
			if((name == $(this).text()) || (name == ($(this).text()+' ')))
				$('#commentAddPG').val(errorpgunique);
		});
	}
}

function onChangeActionValidationChoice(){
	$('#commentValidationValue').val('');
	validation = $('#assessmentValidation').val();
	$('#assementValidationChoice').val(validation);
	if(validation == '<%=ProfileConstants.AUTOMATIC%>'){
		/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
			$('#validationMinp').removeAttr('hidden');
			$('#validationLabelp').removeAttr('hidden');
		}else{*/
			$('#validationMin').removeAttr('hidden');
			$('#validationLabel').removeAttr('hidden');
		//}
		onKeyUpValidationValue();
	}else{
		$('#validationMin').attr('hidden', 'hidden');
		$('#validationLabel').attr('hidden', 'hidden');
		$('#validationMinp').attr('hidden', 'hidden');
		$('#validationLabelp').attr('hidden', 'hidden');
	}
}

function onKeyUpValidationValue(){
	$('#commentValidationValue').val('');
	if(validation == '<%=ProfileConstants.AUTOMATIC%>'){
		var val;
		var minimum;
		/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
			val = $('#validationMinp').val();
			minimum = <%=AttrRangeWeight.rangeWeightMinPercentage%>;
		}else{*/
			val = $('#validationMin').val();
			minimum = <%=AttrRangeWeight.rangeWeightMin%>;
		//}
		
		if(val == ''){
			$('#commentValidationValue').val(errorvalidationempty);
		}else{
			if(isNaN(parseInt(val))){
				$('#commentValidationValue').val(errorvalidationinteger);
			}else{
				if(parseInt(val) <= parseInt(minimum)){
					$('#commentValidationValue').val(errorpositive);
				}//else{
					/*if(mode == '<%=ProfileConstants.PERCENTAGE%>' && parseInt(val) > 100){
						$('#commentValidationValue').val(errorvalidationinferior);
					}*/
				//}
			}
		}
	}
}

var nbline = 0;
function addLineAttributes(){
	var nbr = parseInt(attributesList.length);
	var filterName = '';
	var filterOID = '';
	$.each(attributesList, function(index, value) {
		nbline++;
		<%
		for(int j = 0; j<filtersList.size(); j++){
			String filterid = (String) ((Map) filtersList.get(j)).get(DomainConstants.SELECT_ID);
			String[] variableFilter = PLMFilteringCheck.getInstance(context, filterid).getVariables(context);%>
			if(value == '<%=variableFilter[0]%>'){
			<%
				PLMFilteringCheck selectedFilter = PLMFilteringCheck.getInstance(context, filterid);%>
				filterName = '<%=selectedFilter.getName(context)%>';
				filterOID = '<%=selectedFilter.getId(context)%>';
			}<%
		}
		%>
		var html = '<tr id="filtrage'+index+'" class="tab" style="height:24px">'
		+		'<td id="variablename'+index+'" name="variablename'+index+'" style="text-align:center;height:9px;outline:1px solid #468DC6;background:-webkit-linear-gradient(top, #7db9e8 0%,#2b88d9 50%,#207cca 51%,#4fa0e2 100%);">'+value+'</td>'
		+		'<td>'+addConnexion(index)+'</td>'
		+		'<td style="text-align:center;">'+addFilter(index, value, filterName, filterOID)+'</td>'
		+ '<td></td></tr>';

		$('#FiltrageEdit').append(html);
	});
}
function addFilter(idline, value, filterName, filterOID){
	return '<div id="filterdiv'+idline+'" name="filterdiv'+idline+'"><input id="filter'+idline+'" name="filter'+idline+'" value="'+filterName+'" type="text" style="width:150px;height:18px;" class="value" disabled="disabled"/><input id="filtervalue'+idline+'" name="filtervalue'+idline+'" value="'+filterName+'" type="hidden"/><input id="filterOID'+idline+'" name="filterOID'+idline+'" value="'+filterOID+'" type="hidden"/><input type="button" value="..." onclick="window.open(\'../common/emxIndentedTable.jsp?objectId='+objectId+'&header=Filters&inputvariable='+value+'&inputname=filter'+idline+'&inputvalue=filtervalue'+idline+'&inputOID=filterOID'+idline+'&showTabHeader=false&header=&mode=view&program=emxProfileBase:getFiltersListByVariable&selection=single&table=QCCFilterList&submitURL=../PLMProfile/emxProfileFilterChooser.jsp&customize=false&PrinterFriendly=false&Export=false&expandLevelFilter=false&findMxLink=false&objectCompare=false&showPageURLIcon=false&rowGrouping=true&multiColumnSort=false&massUpdate=false&showClipboard=false&showRMB=true&displayView=details&editLink=false&triggerValidation=false\',\'\',\'height=400,width=400\');"/> <img src="../common/images/buttonDialogCancel.gif" class="cancelFilter" onclick="onremovefilter('+idline+');"></div>';
}
function addGlobalFilter(idline){
	return '<div id="addglobalfilterdiv'+idline+'" name="addglobalfilterdiv'+idline+'"><img src="../common/images/buttonDialogAdd.gif" class="addFilter" onclick="onaddglobalfilter('+idline+');"/> Add a filter</div><div id="globalfilterdiv'+idline+'" name="globalfilterdiv'+idline+'"><input id="globalfilter'+idline+'" name="globalfilter'+idline+'" type="text" style="width:150px;height:18px;" class="value" disabled="disabled"/><input id="globalfiltervalue'+idline+'" name="globalfiltervalue'+idline+'" type="hidden"/><input id="globalfilterOID'+idline+'" name="globalfilterOID'+idline+'" type="hidden"/><input type="button" value="..." onclick="window.open(\'../common/emxIndentedTable.jsp?objectId='+objectId+'&header=Filters&inputname=globalfilter'+idline+'&inputvalue=globalfiltervalue'+idline+'&inputOID=globalfilterOID'+idline+'&showTabHeader=false&header=&mode=view&program=emxProfileBase:getAllFiltersList&selection=single&table=QCCFilterList&submitURL=../PLMProfile/emxProfileGlobalFilterChooser.jsp&customize=false&PrinterFriendly=false&Export=false&expandLevelFilter=false&findMxLink=false&objectCompare=false&showPageURLIcon=false&rowGrouping=true&multiColumnSort=false&massUpdate=false&showClipboard=false&showRMB=true&displayView=details&editLink=false&triggerValidation=false\',\'\',\'height=400,width=400\');"/> <img src="../common/images/buttonDialogCancel.gif" class="cancelFilter" onclick="onremoveglobalfilter('+idline+');"></div>';
}
function addConnexion(idline){
	return '<img src="../common/images/lifecycleHorizontalArrowW38.gif" class="addFilter"/>';
}
function onaddfilter(idline,idattribute){
	$('#filterdiv'+idline).show();
	$('#addfilterdiv'+idline).hide();
}
function onremovefilter(idline){
	$('#filter'+idline).val('');
	$('#filtervalue'+idline).val('');
	$('#filterOID'+idline).val('');
}
function onaddglobalfilter(idline,idattribute){
	$('#globalfilterdiv'+idline).show();
	$('#addglobalfilterdiv'+idline).hide();
}
function onremoveglobalfilter(idline){
	$('#globalfilterdiv'+idline).hide();
	$('#addglobalfilterdiv'+idline).show();
}
function initUIFilter(){
	for(var i = 0; i < nbline; i++){
		$('#globalfilterdiv'+i).hide();
	}
}
function removeAllAssessmentValidation(){
	$('#validationMin').attr('hidden', 'hidden');
	$('#validationLabel').attr('hidden', 'hidden');
	$('#validationMinp').attr('hidden', 'hidden');
	$('#validationLabelp').attr('hidden', 'hidden');
}

function onChangeAssessmentValidation(){
	$('#commentValidationValue').val('');
	/*if(mode == '<%=ProfileConstants.MAX%>'){
		if(validation == '<%=ProfileConstants.AUTOMATIC%>'){
			$('#validationMin').removeAttr('hidden');
			$('#validationLabel').removeAttr('hidden');
			$('#validationMinp').attr('hidden', 'hidden');
			$('#validationLabelp').attr('hidden', 'hidden');
		}else{
			$('#validationMin').attr('hidden', 'hidden');
			$('#validationLabel').attr('hidden', 'hidden');
			$('#validationMinp').attr('hidden', 'hidden');
			$('#validationLabelp').attr('hidden', 'hidden');
		}
	}*/
	if(mode == '<%=ProfileConstants.SUM%>'){
		if(validation == '<%=ProfileConstants.AUTOMATIC%>'){
			$('#validationMin').removeAttr('hidden');
			$('#validationLabel').removeAttr('hidden');
			$('#validationMinp').attr('hidden', 'hidden');
			$('#validationLabelp').attr('hidden', 'hidden');
		}else{
			$('#validationMin').attr('hidden', 'hidden');
			$('#validationLabel').attr('hidden', 'hidden');
			$('#validationMinp').attr('hidden', 'hidden');
			$('#validationLabelp').attr('hidden', 'hidden');
		}
	}
	/*if(mode == '<%=ProfileConstants.PERCENTAGE%>'){
		if(validation == '<%=ProfileConstants.AUTOMATIC%>'){
			$('#validationMinp').removeAttr('hidden');
			$('#validationLabelp').removeAttr('hidden');
			$('#validationMin').attr('hidden', 'hidden');
			$('#validationLabel').attr('hidden', 'hidden');
		}else{
			$('#validationMin').attr('hidden', 'hidden');
			$('#validationLabel').attr('hidden', 'hidden');
			$('#validationMinp').attr('hidden', 'hidden');
			$('#validationLabelp').attr('hidden', 'hidden');
		}
	}*/
}

function onChangeActionParamValue(idparam){
	$('#commentEditParam').val('');
	var error = '';
	var parammin = $('#parammin'+idparam).val();
	var parammax = $('#parammax'+idparam).val();
	if(parammin != ''){
		if(parseInt(parammin) > parseInt($('#paramvalue'+idparam).val())){
			$('#commentEditParam').val(errorminparam);
		}
	}
	if(parammax != ''){
		if(parseInt(parammax) < parseInt($('#paramvalue'+idparam).val())){
			$('#commentEditParam').val(errormaxparam);
		}
	}
}

function onChangeSelectedMultiValue(idmultivalue){
	$('#updatemultivalue'+idmultivalue).val($('#selectmultivalue'+idmultivalue+' option:selected').text());
	onClickMultiValueRefresh(idmultivalue);
}

function onClickMultiValueAdd(idmultivalue){
	var title = $('#addmultivalue'+idmultivalue).val();
	if(title != ""){
		$('#selectmultivalue'+idmultivalue).append(new Option(title, title, true, true));
		$('#addmultivalue'+idmultivalue).val('');
	}
	onChangeSelectedMultiValue();
}

function onClickMultiValueUpdate(idmultivalue){
	$('#selectmultivalue'+idmultivalue+' option:selected').text($('#updatemultivalue'+idmultivalue).val());
	$('#selectmultivalue'+idmultivalue+' option:selected').val($('#updatemultivalue'+idmultivalue).val());
	onClickMultiValueRefresh(idmultivalue);
}

function onClickMultiValueDelete(idmultivalue){
	var del = $('#selectmultivalue'+idmultivalue+' option:selected').prevAll().size();
	var val = $('#selectmultivalue'+idmultivalue+' option:selected').val();
	$('#selectmultivalue'+idmultivalue+' option:selected').remove();
	$('#selectmultivalue'+idmultivalue).val($('#selectmultivalue'+idmultivalue+' option:first').val());
	$('#updatemultivalue'+idmultivalue).val($('#selectmultivalue'+idmultivalue+' option:first').text());
	onClickMultiValueRefresh(idmultivalue);
}

function onClickMultiValueRefresh(idmultivalue){
	var values = '';
	$("#selectmultivalue"+idmultivalue+">option").each(function(index) {
		if(values == ''){
			values = index + ':' + $(this).val();
		}
		else{
			values = values + ';' + index + ':' + $(this).val();
		}
	});
	$('#parammultivalue'+idmultivalue).val(values);
}

function onChangeStopConditionCompareObject(){
	$('#stopcondqualityvalue').val($('#stopcondquality').text());
	$('#stopcondqualityOID').val($('#stopcondquality').val());
	refreshStopCondition();
}

function onChangeStopConditionQuantification(){
	var quantification = $('#stopcondquantification').val();
	$('#stopcondquantificationvalue').val(quantification);
	refreshStopCondition();
}

function onChangeStopConditionCompareValue(){
	var comparevalue = $('#stopcondqualitycompare').val();
	$('#stopcondqualitycomparevalue').val(comparevalue);
	refreshStopCondition();
}

function refreshStopCondition(){
	$('#commentstopcondqualitycompare').val('');
	var comment = '';
	if($('#stopcondquality').val() != '' || $('#stopcondquantification').val() != '' || $('#stopcondqualitycompare').val() != ''){
		if($('#stopcondquality').val() == '' || $('#stopcondquantification').val() == '' || $('#stopcondqualitycompare').val() == ''){
			comment = errorscempty + ' ';
		}
	}
	if(isNaN($('#stopcondqualitycompare').val())){
		comment = comment + errorscinteger;
	}else if($('#stopcondqualitycompare').val() < 0){
		comment = comment + errorscpositive;
	}
	$('#commentstopcondqualitycompare').val(comment);
}

function onremovestopcond(){
	$('#stopcondquality').val('');
	$('#stopcondqualityvalue').val('');
	$('#stopcondqualitycomparevalue').val('');
	$('#stopcondqualitycompare').val('');
	$('#commentstopcondqualitycompare').val('');
	$('#stopcondquantification').val('');
	$('#stopcondquantificationvalue').val('');
	$('#stopcondqualityOID').val('');
	refreshStopCondition();
}

function onremoveprecondition(){
	$('#precond').val('');
	$('#precondvalue').val('');
	$('#precondOID').val('');
}

</script>
