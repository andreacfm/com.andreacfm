<cfcomponent 
	extends="com.andreacfm.Object">

	<cfset variables.instance.hasKey = false />
	
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.CacheKey">
		<cfargument name="data" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="askSqlKey" type="boolean" required="false" default="true" />
		<cfset setData(data) />
		<cfset setaskSqlKey(askSqlKey) />
		<cfreturn this/>
	</cffunction>	

	<!--- hasKey --->
	<cffunction name="hasKey" returntype="Boolean" output="false" access="public">
		<cfreturn variables.instance.hasKey />
	</cffunction>

    <!--- key--->
   	<cffunction name="setkey" access="public" returntype="void">
		<cfargument name="key" type="String" required="true"/>
		<cfset variables.instance.key = key />
		<cfset variables.instance.hasKey = true />
	</cffunction> 

	<cffunction name="getkey" access="public" returntype="String">
		<cfreturn variables.instance.key/>
	</cffunction>
	
    <!--- data--->
    <cffunction name="setData" access="public" returntype="void">
		<cfargument name="data" type="Array" required="true"/>
		
		<cfset variables.instance.data = arguments.data />
		
		<cfif not arrayisempty(variables.instance.data)>		

			<cfset variables.instance.key = hash(serializejson(data)) />
			<cfset variables.instance.hasKey = true />
			
		</cfif>
		
	</cffunction> 

	<cffunction name="getData" access="public" returntype="Array">
		<cfreturn variables.instance.data/>
	</cffunction>

   	<!--- askSqlKey--->
    <cffunction name="setaskSqlKey" access="public" returntype="void">
		<cfargument name="askSqlKey" type="Boolean" required="true"/>
		<cfset variables.instance.askSqlKey = askSqlKey />
	</cffunction> 

	<cffunction name="askSqlKey" access="public" returntype="Boolean">
		<cfreturn variables.instance.askSqlKey/>
	</cffunction>	

	
</cfcomponent>