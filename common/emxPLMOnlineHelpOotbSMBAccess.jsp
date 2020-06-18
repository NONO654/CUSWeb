<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>Accesses</title>
<!--meta name="Microsoft Theme" content="network 1011"-->
<link rel="stylesheet" type="text/css" href="styles/emxUIHelp.css">
</head>

<body>
<div class="h1">
<img src="images/iconAccesses.gif" width="24" height="24">
</div>
<h1>Out of the Box SMB Accesses</h1>
<h2>Definition</h2>
<p>SMB (Small&nbsp; Medium Business) out-of-the-box accesses are delivered during installation.<br>
There is information delivered for each Access category : <span class="keyword">Policies, Rules, Commands</span> and <span class="keyword">Masks</span>.</p>
<p>Some basic <span class="keyword">Projects</span> and <span class="keyword">Roles</span> are also delivered.</p>

<h3>Projects</h3>
<img class="h3" src="images/iconProject.gif" width="24" height="24">
<p>2 basic projects are delivered:<br>
<b>Design</b> and <b>Standard</b></p>
<p>Security principle for <b>Design</b> and <b>Standard</b> project is any 
member of a team having a given role and a given project is having the same 
right for any of the granted operation.</p>
<p>There is:</p>
<ul>
	<li>no Lock/Unlock capability</li>
	<li>no Ownership Transfer required for authoring in a Team Engineering. 
	</li>
</ul>
<p>Any one declared as a user (named) would be able to Access 3DLive data of any 
company's project, given the fact those data fit some additional maturity 
criteria. </p>
<h3>Roles</h3>
<img class="h3" src="images/iconRole.gif" width="24" height="24">The following table lists the SMB 
Roles:<br>
&nbsp;<table border="1" width="100%" id="table3" cellspacing="0" cellpadding="1">
	<tr>
		<th width="242">Role name</th>
		<th>... has access to</th>
	</tr>
	<tr>
		<td width="242"><img src="images/iconRoleViewer.gif">Viewer</td>
		<td>released data of either current design project or any standard 
		project</td>
	</tr>
	<tr>
		<td width="242"><img src="images/iconRoleReviewer.gif">Reviewer</td>
		<td>frozen data of current project, and manage any review data</td>
	</tr>
	<tr>
		<td width="242"><img src="images/iconRoleDesigner.gif">Designer</td>
		<td>any kind of CAD data</td>
	</tr>
	<tr>
		<td width="242"><img src="images/iconRoleDesignLeader.gif">Design Leader</td>
		<td>releasing or obsoleting data, and trashing frozen data</td>
	</tr>
	<tr>
		<td width="242"><img src="images/iconRoleTeamLeader.gif">Team Leader</td>
		<td>administrate project, roles and people. May be some other 
		administration roles like deleting any kind of data</td>
	</tr>
	</table>

<p>&nbsp;</p>
<h3>Policies</h3>
<img class="h3" src="images/iconPolicies.gif">
The following table lists the SMB Policies and the object type they are 
controlling:<table border="1" width="100%" id="table2" cellspacing="0" cellpadding="1">
	<tr>
		<th width="242">Policy name</th>
		<th>... is securing access to following types</th>
	</tr>
	<tr>
		<td width="242">VPLM_SMB</td>
		<td>All References (PLMReference)</td>
	</tr>
	<tr>
		<td width="242">VPLM_SMB_DOCUMENT</td>
		<td>Document references (PLMDMTDocument)</td>
	</tr>
	<tr>
		<td width="242">VPLM_ActionPolicy</td>
		<td>PLMDesignAction,PLMDocumentationAction,PLMMaintenanceAction and 
		PLMManufacturingAction</td>
	</tr>
	<tr>
		<td width="242">VPLM_SignoffActionPolicy</td>
		<td>PLMSignoffAction</td>
	</tr>
	<tr>
		<td width="242">VPLM_SMB_PORT_CX</td>
		<td>VPLM connections and ports</td>
	</tr>
	<tr>
		<td width="242">VPLM_UNSECURED_CX</td>
		<td>unsecured VPLM connections</td>
	</tr>
	<tr>
		<td width="242">VPLM_SR</td>
		<td>VPLM internal semantic relationships (none is secured)</td>
	</tr>
</table>
<h3>Rules</h3>
<img class="h3" src="images/iconRules.gif">
<p>VPLM_SMB_INSTANCE is the only rule delivered, and is securing access to any type of PLM Instance.</p>
<h3>Command</h3>
<img class="h3" src="images/iconCommands.gif">
<p>The following table lists the standard VPLM Commands checked in CATIA:</p>
<table border="1" width="100%" id="table1" cellspacing="0" cellpadding="1">
	<tr>
		<th width="242">Command name</th>
		<th>... is securing</th>
	</tr>
	<tr>
		<td width="242">EXPORT</td>
		<td>Export data to a briefcase</td>
	</tr>
	<tr>
		<td width="242">IMPORT</td>
		<td>Import data from a briefcase</td>
	</tr>
	<tr>
		<td width="242">SAVE</td>
		<td>Save data in PLM Server</td>
	</tr>
	<tr>
		<td width="242">DATABASEDETACH</td>
		<td>VPLM Detach command</td>
	</tr>
	<tr>
		<td width="242">Duplicate</td>
		<td>VPLM Duplicate command</td>
	</tr>
	<tr>
		<td width="242">DuplicateUsingDistantData</td>
		<td>VPLM Duplicate command</td>
	</tr>
	<tr>
		<td width="242">NewVersionUsingDistantData</td>
		<td>VPLM New Version command</td>
	</tr>
</table>
<h3>Mask</h3>
<img class="h3" src="images/iconMasks.gif">
<p>The only mask delivered with SMB installation is the public mask, named DEFAULT.<br>
&nbsp;</p>
<h2>Detailed information</h2>
<p>The lifecycle specification is as follows:</p>
<p>
<center><img border="0" src="images/helpOotbSMBMaturity.gif" width="575" height="451"></center></p>
<p>Policy for authorers (designer, team &amp; design leaders):</p>
<p>
<img border="0" src="images/helpOotbSMBPolicyAuthorers.gif" width="960" height="720"></p>
<p>Policy for experimenters (viewer &amp; reviewer):</p>
<p>
<img border="0" src="images/helpOotbSMBPolicyExperimenters.gif" width="821" height="622"></p>
<h2>Related information</h2>
<ul class="related">
	<li><a href="helpAccesses.jsp">Accesses</a></li>
	<li><a href="helpProjects.jsp">Project</a></li>
	<li><a href="helpRoles.jsp">Roles</a></li>
</ul>

<p>&nbsp;</p>
</body>

</html>
