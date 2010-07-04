<cfcomponent
 output="false"
 name="DatsService" 
 hint="Data Service Class"
 extends="com.andreacfm.Object">

	<!---	constructor	--->		
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.datax.DataService">	
		<cfargument name="gateway" required="true" type="com.andreacfm.datax.Gateway" />

		<cfset variables.instance.gateway = arguments.gateway />

	<cfreturn this/>	
	</cffunction>

	<!-----------------------------------------  PUBLIC   ---------------------------------------------------------------->

	<!---	gateway	--->
	<cffunction name="getgateway" access="public" output="false" returntype="com.andreacfm.datax.Gateway">
		<cfreturn variables.instance.gateway/>
	</cffunction>

	<!---	read	--->
	<cffunction name="read"  access="public" returntype="any" output="false">
		<cfargument name="data" type="struct" required="false" default="#structNew()#"/>	
		<cfargument name="orderBy" required="false" default="" />
		<cfargument name="maxrows" required="false" type="numeric" default="1000000" />
		<cfargument name="fieldlist" required="false" default="" />
		<cfargument name="advSql" required="false"  type="struct" default="#structNew()#"/>
		<cfargument name="filters" required="false" type="array" default="#arrayNew(1)#"/>
		<cfargument name="skipFields" required="false" type="string" default=""/>
		<cfargument name="pop" required="false" type="boolean" default="false"/>
		<cfargument name="cache" required="false" type="boolean" default="false"/>
		<!--- read method --->		
		<cfargument name="method" required="false" type="string" default="read"/>		

		<cfset var result = getData(argumentCollection=arguments) />
		
		<cfif arguments.pop>
			<cfreturn result[1] /> 
		</cfif>
		
		<cfreturn result />
		
	</cffunction>	

	<!---	list	--->
	<cffunction name="list" access="public" returntype="query" output="false">
		<cfargument name="data" type="struct" required="false" default="#structNew()#"/>	
		<cfargument name="orderBy" required="false" default="" />
		<cfargument name="maxrows" required="false" type="numeric" default="1000000" />
		<cfargument name="fieldlist" required="false" default="" />
		<cfargument name="advSql" required="false"  type="struct" default="#structNew()#"/>
		<cfargument name="filters" required="false" type="array" default="#arrayNew(1)#"/>
		<cfargument name="skipFields" required="false" type="string" default=""/>
		<cfargument name="cache" required="false" type="boolean" default="false"/>		
		<!--- read method --->		
		<cfargument name="method" required="false" type="string" default="list"/>		

		<cfset var result = getData(argumentCollection=arguments) />
		
		<cfreturn result />
		
	</cffunction>	

	<!---	getCount	--->
	<cffunction name="getCount" output="false" returntype="numeric">
		<cfscript>
			var result = list();		
			return result.recordcount;
		</cfscript>
	</cffunction>

	<!--- 	readById 	--->
	<cffunction name="readById" output="false" returntype="any">
		<cfargument name="id" required="true" type="numeric">
		<cfargument name="pop" required="false" type="boolean" default="true">
		<cfargument name="cache" required="false" type="boolean" default="false">
		<cfscript>
		var data = {};
		var result = "";
		data[getGateway().getPk()] = arguments.id;
		result = read(data = data, cache = cache);
		if(arraylen(result) neq 1){
			throw('The object with id #arguments.id# was not found','com.andreacfm.datax.error.recordNotFound');
		}
		if(arguments.pop){
			result = result[1];
		}
		return result;	
		</cfscript>
	</cffunction>

	<!---	listById	--->
	<cffunction name="listById" output="false" returntype="query">
		<cfargument name="id" required="true" type="numeric">
		<cfargument name="cache" required="false" type="boolean" default="false"/>
		<cfscript>
		var data = {};
		var result = "";
		data[getGateway().getPk()] = arguments.id;	
		result = list(data = data, cache = cache );
		return result;	
		</cfscript>
	</cffunction>

	<!---	getAll	--->
	<cffunction name="getAll" output="false" returntype="query">
		<cfscript>
			var result = list(skipfields = getgateway().getSkipfields());
			return result;
		</cfscript>
	</cffunction>


	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->

	<!---	getSql	--->
	<cffunction name="getSql" access="private" output="false" returntype="com.andreacfm.datax.Sql">
		
		<cfset var sqlObj = ""/>
		
		<!--- add table for caching --->
		<cfset arguments.table = getGateway().getTable() />
		<!--- default cachekey // ask for key to sql --->
		<cfif arguments.cache and not structkeyexists(arguments,'cacheKey')>
			<cfset arguments.cacheKey = createObject('component','com.andreacfm.datax.CacheKey').init() />
		</cfif>

		<cfset sqlObj = createObject("component","com.andreacfm.datax.Sql").init(argumentCollection=arguments) />

		<cfreturn sqlObj/>
	</cffunction>

	<!--- getData --->
	<cffunction name="getData" output="false" returntype="any" access="private">		
		<cfset var sql = ""/>
		<cfset var gateway = getgateway()/>
		<cfset var result = "" />
		<cfset var fields = "" />
		<cfset var i = "" />
		<cfset var columnIndex = "" />

		<cfif listLen(arguments.skipFields,',') gt 0 >
			<cfset fields = getGateway().getDataMgr().getFieldList(getgateway().getTable()) />
			<cfloop list="#arguments.skipFields#" index="i">
				<cfset columnIndex = listFindNoCase(fields,i,',') />
				<cfif columnIndex neq 0>
					<cfset fields = listDeleteAt(fields,columnIndex) />
				</cfif>	
			</cfloop>
			<cfset arguments.args.fieldlist = fields />
		</cfif>

		<cfset sql = getSql(argumentCollection=arguments) />
		
		<cfif arguments.method eq 'list'>
			<cfset result = gateway.list(sql) />
		<cfelseif arguments.method eq 'read'>
			<cfset result = gateway.read(sql) />	
		</cfif>
		
		<cfreturn result />
	
	</cffunction>

  </cfcomponent>