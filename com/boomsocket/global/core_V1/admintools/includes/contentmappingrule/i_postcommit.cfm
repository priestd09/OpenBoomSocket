<!--- i_postcommit.cfm --->
<!--- set rule name--->
<!--- inserting or updating --->
<cfif NOT isDefined("deleteinstance")>
	<cfif isDefined("instanceid")>
		<cfset thisid=instanceid>
	<cfelse>
		<cfset thisid=insertid>
	</cfif>
	<!--- set name = firstname + lastname --->
	<cfset thisMasterFormobjectid = ListFirst(Trim(form.masterFormobjectid),'~')>
	<cfset thisAssociateFormobjectid = ListFirst(Trim(form.associateFormobjectid),'~')>	
	<cfset forminstanceObj = CreateObject('component','#application.CFCpath#.formInstance')>
	<cfset q_masterFormObject = forminstanceObj.getToolInfo(toolid=thisMasterFormobjectid)>
	<cfset q_associateFormObject = forminstanceObj.getToolInfo(toolid=thisAssociateFormobjectid)>	
	<cfset thisname = q_masterFormObject.formobjectname & ' Has ' & q_associateFormObject.formobjectname>
		
	<cfquery name="q_updateRule" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		UPDATE contentmappingrule
		SET contentmappingrulename = '#thisname#' 
		WHERE contentmappingruleid = #thisid#
	</cfquery>

	<!--- create reverse rule if applicable --->
	<cfif isDefined('FORM.createReverse') AND Trim(FORM.createReverse)>
		<!--- check to see if reverse rule already exists --->
		<cfset mappingObj = createobject("component","#APPLICATION.sitemapping#.components.contentmapping")>
		<cfset thisMasterFormobjectid = ListFirst(Trim(form.associateFormobjectid),'~')>
		<cfset thisAssociateFormobjectid = ListFirst(Trim(form.masterFormobjectid),'~')>	
		<cfset ruleExists = mappingObj.RuleExists(masterFormobjectid=thisMasterFormobjectid,associateFormobjectid=thisAssociateFormobjectid)>
		<!--- if doesn't exists, add --->
		<cfif NOT ruleExists>
			<cfset form.masterformobjectid = thisMasterFormobjectid>
			<cfset form.associateformobjectid = thisAssociateFormobjectid>
			<cfset form.contentmappingrulename = q_associateFormObject.formobjectname & ' Has ' & q_masterFormObject.formobjectname>
			<cfmodule name="#application.customTagPath#.dbaction" 
				action="INSERT" 
				tablename="#trim(form.tablename)#"  
				datasource="#application.datasource#" 
				assignidfield="#q_getform.datatable#id">
		</cfif>
	</cfif>
<cfelse>
	<!---delete mappings for this rule--->
	<cfquery name="q_deleteMappings" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		DELETE FROM contentmapping
		WHERE contentmappingruleid IN (#deleteinstance#)
	</cfquery>
</cfif>

