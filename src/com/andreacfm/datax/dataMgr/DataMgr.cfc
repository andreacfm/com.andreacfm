<cfcomponent extends="_DataMgr">

<cffunction name="init" access="public" returntype="DataMgr" output="no" hint="I instantiate and return this object.">
	<cfargument name="datasource" type="string" required="no" default="#variables.DefaultDatasource#">
	<cfargument name="database" type="string" required="no">
	<cfargument name="username" type="string" required="no">
	<cfargument name="password" type="string" required="no">
	<cfargument name="SmartCache" type="boolean" default="false">
	<cfargument name="SpecialDateType" type="string" default="CF">
	<cfargument name="xmlPath" type="string" default="" />
	
	<cfset var me = 0>
	<cfset variables.datasource = arguments.datasource>
	<cfset variables.CFServer = Server.ColdFusion.ProductName>
	<cfset variables.CFVersion = ListFirst(Server.ColdFusion.ProductVersion)>
	<cfset variables.SpecialDateType = arguments.SpecialDateType>
	
	<cfif StructKeyExists(arguments,"username") AND StructKeyExists(arguments,"password")>
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
	</cfif>
	
	<cfif StructKeyExists(arguments,"defaultdatabase")>
		<cfset variables.defaultdatabase = arguments.defaultdatabase>
	</cfif>
	
	<cfset variables.SmartCache = arguments.SmartCache>
	
	<cfset variables.dbprops = getProps()>
	<cfset variables.tables = StructNew()><!--- Used to internally keep track of table fields used by DataMgr --->
	<cfset variables.tableprops = StructNew()><!--- Used to internally keep track of tables properties used by DataMgr --->
	<cfset setCacheDate()><!--- Used to internally keep track caching --->
	
	<!--- instructions for special processing decisions --->
	<cfset variables.nocomparetypes = "CF_SQL_LONGVARCHAR,CF_SQL_CLOB"><!--- Don't run comparisons against fields of these cf_datatypes for queries --->
	<cfset variables.dectypes = "CF_SQL_DECIMAL"><!--- Decimal types (shouldn't be rounded by DataMgr) --->
	<cfset variables.aggregates = "avg,count,max,min,sum">
	
	<!--- Information for logging --->
	<cfset variables.doLogging = false>
	<cfset variables.logtable = "datamgrLogs">
	
	<!--- Code to run only if not in a database adaptor already --->
	<cfif ListLast(getMetaData(this).name,".") EQ "DataMgr">
		<cfif NOT StructKeyExists(arguments,"database")>
			<cfset arguments.database = getDatabase()>
		</cfif>
		
		<!--- This will make sure that if a database is passed the component for that database is returned --->
		<cfif StructKeyExists(arguments,"database")>
			<cfif StructKeyExists(variables,"username") AND StructKeyExists(variables,"password")>
				<cfset me = CreateObject("component","DataMgr_#arguments.database#").init(datasource=arguments.datasource,username=arguments.username,password=arguments.password)>
			<cfelse>
				<cfset me = CreateObject("component","DataMgr_#arguments.database#").init(arguments.datasource)>
			</cfif>
		</cfif>
	<cfelse>
		<cfset me = this>
	</cfif>
	
	<cfif fileExists(expandPath(arguments.xmlPath))>
		<cffile action="read" file="#expandPath(arguments.xmlPath)#" variable="xml">
		<cfset me.loadXml(xml,true,true)/>
	</cfif>

	<cfreturn me>
</cffunction>

</cfcomponent>