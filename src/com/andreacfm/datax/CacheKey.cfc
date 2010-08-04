<cfcomponent 
	extends="com.andreacfm.Object">

	<cfset variables.hasKey = false />
	
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.CacheKey">
		<cfargument name="data" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="askSqlKey" type="boolean" required="false" default="true" />
		<cfset setData(data) />
		<cfset setaskSqlKey(askSqlKey) />
		<cfreturn this/>
	</cffunction>	

	<!--- hasKey --->
	<cffunction name="hasKey" returntype="Boolean" output="false" access="public">
		<cfreturn variables.hasKey />
	</cffunction>

    <!--- key--->
   	<cffunction name="setkey" access="public" returntype="void">
		<cfargument name="key" type="String" required="true"/>
		<cfset variables.key = key />
		<cfset variables.hasKey = true />
	</cffunction> 

	<cffunction name="getkey" access="public" returntype="String">
		<cfreturn variables.key/>
	</cffunction>
	
    <!--- data--->
    <cffunction name="setData" access="public" returntype="void">
		<cfargument name="data" type="Array" required="true"/>
		
		<cfset variables.data = arguments.data />
		
		<cfif not arrayisempty(variables.data)>		

			<cfset variables.key = hash(serializejson(data)) />
			<cfset variables.hasKey = true />
			
		</cfif>
		
	</cffunction> 

	<cffunction name="getData" access="public" returntype="Array">
		<cfreturn variables.data/>
	</cffunction>

   	<!--- askSqlKey--->
    <cffunction name="setaskSqlKey" access="public" returntype="void">
		<cfargument name="askSqlKey" type="Boolean" required="true"/>
		<cfset variables.askSqlKey = askSqlKey />
	</cffunction> 

	<cffunction name="askSqlKey" access="public" returntype="Boolean">
		<cfreturn variables.askSqlKey/>
	</cffunction>	

	
</cfcomponent>