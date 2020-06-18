<%--  smaRunAdviseJobAs.jsp - This page gets the credentials for launching RA
 * It will redirect to smaRunAdviseJob.jsp after storing the credentials in sessionStorage.
 * (c) Dassault Systemes, 2014
 *
 @quickreview SD4 6/10/2014 make page go back on cancel.
--%>
<%-- Common Includes --%>
<%------------------------------------------------------------------------------
	* The station will not run in 'run as' mode unless the EED has 'run as'
	* enabled. By default, the 'run as' behavior of the station follows the
	* 'run as' configuration of the EED server to which the station has been
	* connected. The "fiper.station.runas" seting in the 
	* SMAExeStation.properties file when set to 'disabled' forces the 
	* station to run with 'run as' disabled even though the EED has 
	* 'run as' enabled.
	* The possible settings for "fiper.station.runas" is 
	* "enabled", "disabled", "unsecured". (Case insensitive)
	* Null, empty, or "default" means use EED setting.
	* 
	* When filling the station dropdown, check the EED 'run as' status.
	* If it is 'false', then on checking the 'Run As' checkbox, show an alert
	* saying 'run as' wouldnt work.
	* If EED 'run as' status is true, then check every station object returned
	* in the Station 'query' web service response for the property '@disableRunAs'
	* and if it is Null, empty, "default" or "enabled", then list that staion
	* in the Station dropdown.
 ---------------------------------------------------------------------------------%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<%
	/*********************************************************************************
	This need not be a jsp; but in order to authenticate access, I am making it a JSP.
	*********************************************************************************/
		matrix.db.Context context2 = (matrix.db.Context) request
				.getAttribute("context");
		if (context2 != null)
			context = context2;
		
		String currentUser = context.getUser();
		
		// Get the 3DSpace/Server URL.
		String myAppsURL = "";
		try{
			myAppsURL = FrameworkUtil.getMyAppsURL(context, request,response);
		} catch (Exception ex){
			myAppsURL = "";
		}
	%>
	
	<script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
	<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
	<script type="text/javascript"	src="./smaAdviseLaunchHelper.js"></script>
	<link rel="stylesheet" type="text/css"	href="./styles/smaAdviseLaunchHelper.css" />
	
	<style>
	.button{
		border-width: 1px;
		border-style: solid;
		border-radius:3px;
		box-shadow: 2px 2px 3px #888888;
		width:6rem;
		cursor:pointer;
		background:lightblue;
		margin: 2px;
	}
	.run-as{
		display: none;
	}
	.run-as-input{
		width: 180px;
		height: 20px;
		margin: 2px;
	}
	#ra-show-runas{
		margin: 2px;
	}
	#ra-runas-stationselect{
	    height: 25px;
	    width: 185px;
	}
	</style>
</head>
<body style="display:table;position:absolute;height:100%;width:100%;margin:0;padding:0">
	<div style="display: table-cell;vertical-align: middle;">
	<table style="margin-left:auto;margin-right:auto;border-width: 1px;border-style: solid;box-shadow: 10px 10px 20px #888888;">
	<tr>
		<td align="center" colspan="2" style="background-color:#005686;color:white">Configure And Run</td>
	</tr>
	<tr>
		<td>Run Analytics As</td>
		<td>
			<input type="checkbox" id="ra-show-runas" />	
		</td>
	</tr>
	<tr>
		<td>Station</td>
		<td>
			<select id="ra-runas-stationselect" class="run-as-input">
				<option value=""></option>
			</select>
		</td>
	</tr>
	<tr class="run-as">
		<td>Domain name</td>
		<td><input class="run-as-input" type="text" name="domainname"></td>
	</tr>
	<tr class="run-as">
		<td>Windows user name</td>
		<td><input class="run-as-input" type="text" name="winuname"></td>
	</tr>
	<tr class="run-as">
		<td>Windows password</td>
		<td><input class="run-as-input" type="password" name="winpwd"></td>
	</tr>
	<tr class="run-as">
		<td>Linux user name</td>
		<td><input class="run-as-input" type="text" name="luname"></td>
	</tr>
	<tr class="run-as">
		<td>Linux password</td>
		<td><input class="run-as-input" type="password" name="lpwd"></td>
	</tr>
	<tr>
		<td align="center"><div class="button submit">Run Analytics</div></td>
		<td align="center"><div class="button cancel">Cancel</div></td>
	</tr>
	<tr></tr>
	</table>
	</div>
	
	<div class="sim-ui-errpop-veil sim-ui-errpop-noshow">
		<div class="sim-ui-errpop-dsfont sim-ui-errpop-base">
			<p class="sim-ui-errpop-header">Results Analytics Error</p>
			<div class="sim-ui-errpop-card" id="sim-ui-errpop-msgcard"></div>
			<div class="sim-ui-errpop-card sim-ui-errpop-noshow" id="sim-ui-errpop-tracecard"></div>
			<div id="sim-ui-errpop-buttons">
				<!--<button id="sim-ui-errpop-trace" class="sim-ui-errpop-noshow">Show Trace</button> -->
				<button id="sim-ui-errpop-ok" class="sim-ui-errpop-btn-primary sim-ui-errpop-noshow">Ok</button>
				<button id="sim-ui-errpop-close" class="sim-ui-errpop-btn-primary">Close</button>
			</div>
		</div>
	</div>
	
	<script type="text/javascript">
		var $simjq = jQuery.noConflict();
		function getParameter(url, key){
		  var regExp = new RegExp("[\\?&]"+key+"=([^&#]*)");
		  var val = regExp.exec(url);
		  if( val == null )
		    return null;
		  else
		    return val[1];
		}
		function validateInput(){
			
			var cred = {};
			cred.domainname = $simjq('input[name="domainname"]').val();
			cred.winuname = $simjq('input[name="winuname"]').val();
			cred.winpwd = $simjq('input[name="winpwd"]').val();
			cred.luname = $simjq('input[name="luname"]').val();
			cred.lpwd = $simjq('input[name="lpwd"]').val();
			var hasWinCred = false, hasLinuxCred = false;
			hasWinCred = cred.winuname && cred.winuname.length>0;
			hasLinuxCred = cred.luname && cred.luname.length>0;
			if(hasWinCred || hasLinuxCred) {
				console.log('some credential supplied');
		
				window.sessionStorage.domainName = cred.domainname;
				window.sessionStorage.windowsUser = cred.winuname;
				window.sessionStorage.windowsPass = cred.winpwd;
				window.sessionStorage.linuxUser = cred.luname ;
				window.sessionStorage.linuxPass = cred.lpwd;
				
				return cred;
			} else {
				console.log('no credential supplied');
				return false;
			}
		}
		
		$simjq(document).ready(function () {
			
			require(['DS/SMASLMAdviseNLS/smaAdviseNLSUtils'],function(NLSUtils){
				
				var translator = NLSUtils;
				
				var myAppsURL = "<%=myAppsURL%>";
				if (myAppsURL.length > 0){
					localStorage['RA_MCS_URL'] = myAppsURL;
				}
				
				var objectId = getParameter(window.location.href, 'objectId');
				if(!objectId){
					var rowId = getParameter(window.location.href, 'emxTableRowId');
					if(rowId) {
						rowId = rowId.substring(1);
						objectId = rowId.substring(0, rowId.indexOf('|'));
					}
				}
				if(!objectId || objectId.length < 4) {
					alert(translator.translate('LAUNCH_NOCASE'));
				}
				
				var eedUrl = '',
				eedRunAsStatus = false;
				
				var fillStationsDropDown = function(eedUrl, eedRunAsStatus){
					var stnDeferred = $simjq.Deferred(),
						runAs = false;
					if (eedRunAsStatus === true || eedRunAsStatus === 'true')
						runAs =  $simjq('#ra-show-runas').is(':checked');
				
					getMyStations({
						'eedUrl': eedUrl,
						'currentUser': "<%=currentUser%>",
						'runAs': runAs
					}).then(
							
						function(stationList){
							
							if(typeof stationList === 'string'){
								stationList = JSON.parse(stationList);
							}
							
							$simjq('#ra-runas-stationselect > option').remove();
							
							var selectElement = $simjq('#ra-runas-stationselect');

							if (! runAs){
								// Add an option for localhost execution
								// Run as is not supported in Secure stations
								selectElement.append($simjq('<option></option>')
									.attr('id', 'localhost-option')
									.attr('value', '{localhost}')
									.text('{localhost}'));	
							}
							
							if (!Array.isArray(stationList))
								stationList = [];

							$simjq.each(stationList, function(i, stationInfo){
								
								if(stationInfo && stationInfo['@name'] && stationInfo['@name'].length > 0 && stationInfo.GeneralInfo 
										&& stationInfo.GeneralInfo['@hostIP'] && stationInfo.GeneralInfo['@hostIP'].length > 3) {
									
									selectElement.append($simjq('<option></option>')
										.attr('value', stationInfo['@name'])
										.text(stationInfo['@name']));
								}
							});

							stnDeferred.resolve();
						},
						function(err){
							console.error('Error adding station names to select', err);
							stnDeferred.reject();
						}
					);
					return stnDeferred;
				};
			
			var mcsUrl = localStorage['RA_MCS_URL'];
			if (typeof mcsUrl !== 'undefined' && 
					mcsUrl !== null &&
					mcsUrl.length > 0)
				mcsUrl = '&mcsURI=' + encodeURIComponent(mcsUrl);
			else
				mcsUrl = '';
			
			var launchInfoUrl = '../resources/slmservices/advise/getAnalyticsLaunchInfo?caseID=' + objectId + mcsUrl,
				eedUrl = '',
				promise =
					$simjq.ajax
					({
						url: launchInfoUrl,
						type: 'json',
						cache: false,
						method: 'GET'
					}).done(function(data){
						eedUrl = data.eedURL;
						
						getEEDRunAsStatus(eedUrl, data.eedTicket, translator)
							.always(function(response){
								eedRunAsStatus = response;
								fillStationsDropDown(eedUrl, eedRunAsStatus);						
							});
					}).fail(function(error){
						createLaunchPopOver({
							'message': translator.translate('LAUNCH_NO_LAUNCHINFO') + '<br/>' +
										translator.translate('LAUNCH_CANCEL'),
							'close-callback': returnToRALanding
						});
					});
			
			$simjq('#ra-show-runas').change(function(event){
				var _this = this;
				if (! eedRunAsStatus && $simjq(_this).is(':checked')){
					event.preventDefault();
					_this.checked = false;
					alert(translator.translate('LAUNCH_EED_RUNAS_DISABLD'));
					return;
				}
				var showRunAsStationAlert = function(isRunAs){
					var station = $simjq('#ra-runas-stationselect').val();
					if (station.length > 0){
						if(isRunAs) {
							alert(translator.translate('LAUNCH_RUNAS_SEL'));
							$simjq('.run-as').show();
						}
						else {
							alert(translator.translate('LAUNCH_RUNAS_UNSEL'));
							$simjq('.run-as').hide();
						}
					}
					return;
				};
				
				fillStationsDropDown(eedUrl, eedRunAsStatus)
					.always(
						function(data){
							if($simjq(_this).is(':checked'))
								showRunAsStationAlert(true);
							else 
								showRunAsStationAlert(false);
						});
			});
			
			$simjq('.submit').click(function() {
				var cred = null;
				if($simjq('#ra-show-runas').is(':checked')){
					cred = validateInput();
				}
				var station = $simjq('#ra-runas-stationselect').val() || '';
				window.sessionStorage.setAffinityTo =  station;
				if(cred) {
					// tell the run jsp that it is a run as
					window.location.href = "./smaRunAdviseJob.jsp?runAs=true&setStation=true&objectId="+objectId;
				} else {
					// do regular launch
					window.location.href = "./smaRunAdviseJob.jsp?setStation=true&objectId="+objectId;
				}
			});
			
			$simjq('.cancel').click(function() {
				if($simjq('#ra-show-runas').is(':checked')){
				delete window.sessionStorage.domainName;
				delete window.sessionStorage.windowsUser;
				delete window.sessionStorage.windowsPass
				delete window.sessionStorage.linuxUser;
				delete window.sessionStorage.linuxPass;
				}
				var mcs = localStorage['RA_MCS_URL'];
				if (typeof mcs !== 'undefined' && mcs !== null){	
					var w = getTopWindow() || window;
					w.location.href = mcs + '/common/emxNavigator.jsp?appName=SIMREII_AP'
										+ '&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource'
										+ '&SuiteDirectory=simulationcentral';
				}
				else 
					window.history.back();
			});
	
		});

	});
	</script>

</body>


