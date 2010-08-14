<!---<cfset sOpenBDQuery = StructNew()>
<cfif variables.SmartCache>
	<cfset sOpenBDQuery["cachedafter"] = "#variables.CacheDate#">
</cfif>--->
<cfif StructKeyExists(variables,"username") AND StructKeyExists(variables,"password")>
	<cfif isDefined("aSQL")>
		<cfquery name="qQuery" datasource="#variables.datasource#" preservesinglequotes="true" username="#variables.username#" password="#variables.password#"><cfloop index="i" from="1" to="#ArrayLen(aSQL)#" step="1"><cfif IsSimpleValue(aSQL[i])><cfset temp = aSQL[i]>#Trim(temp)#<cfelseif IsStruct(aSQL[i])><cfset aSQL[i] = queryparam(argumentCollection=aSQL[i])><cfswitch expression="#aSQL[i].cfsqltype#"><cfcase value="CF_SQL_BIT">#getBooleanSqlValue(aSQL[i].value)#</cfcase><cfcase value="CF_SQL_DATE,CF_SQL_DATETIME">#CreateODBCDateTime(aSQL[i].value)#</cfcase><cfdefaultcase><!--- <cfif ListFindNoCase(variables.dectypes,aSQL[i].cfsqltype)>#Val(aSQL[i].value)#<cfelse> ---><cfqueryparam value="#aSQL[i].value#" cfsqltype="#aSQL[i].cfsqltype#" maxlength="#aSQL[i].maxlength#" scale="#aSQL[i].scale#" null="#aSQL[i].null#" list="#aSQL[i].list#" separator="#aSQL[i].separator#"><!--- </cfif> ---></cfdefaultcase></cfswitch></cfif> </cfloop></cfquery>
	<cfelse>
		<cfquery name="qQuery" datasource="#variables.datasource#" preservesinglequotes="true" username="#variables.username#" password="#variables.password#">#Trim(arguments.sql)#</cfquery>
	</cfif>
<cfelse>
	<cfif isDefined("aSQL")>
		<cfquery name="qQuery" datasource="#variables.datasource#" preservesinglequotes="true"><cfloop index="i" from="1" to="#ArrayLen(aSQL)#" step="1"><cfif IsSimpleValue(aSQL[i])><cfset temp = aSQL[i]>#Trim(temp)#<cfelseif IsStruct(aSQL[i])><cfset aSQL[i] = queryparam(argumentCollection=aSQL[i])><cfswitch expression="#aSQL[i].cfsqltype#"><cfcase value="CF_SQL_BIT">#getBooleanSqlValue(aSQL[i].value)#</cfcase><cfcase value="CF_SQL_DATE,CF_SQL_DATETIME">#CreateODBCDateTime(aSQL[i].value)#</cfcase><cfdefaultcase><!--- <cfif ListFindNoCase(variables.dectypes,aSQL[i].cfsqltype)>#Val(aSQL[i].value)#<cfelse> ---><cfqueryparam value="#aSQL[i].value#" cfsqltype="#aSQL[i].cfsqltype#" maxlength="#aSQL[i].maxlength#" scale="#aSQL[i].scale#" null="#aSQL[i].null#" list="#aSQL[i].list#" separator="#aSQL[i].separator#"><!--- </cfif> ---></cfdefaultcase></cfswitch></cfif> </cfloop></cfquery>
	<cfelse>
		<cfquery name="qQuery" datasource="#variables.datasource#" preservesinglequotes="true">#Trim(arguments.sql)#</cfquery>
	</cfif>
</cfif>
