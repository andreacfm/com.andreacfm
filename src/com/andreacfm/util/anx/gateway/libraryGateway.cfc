<cfcomponent 
	output="false" 
	name="Library Gateway" 
	extends="cfops.data.gateway">

<!---constructor OVERRIDE--->		
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.data.gateway">	
		<cfargument name="dataSettingsBean" required="true" type="com.andreacfm.core.datasettingsbean">
		<cfargument name="converter" required="true" type="com.andreacfm.core.object" />
			
			<cfset variables.table = arguments.dataSettingsBean.getTable() />
			<cfset variables.skipFields = arguments.dataSettingsBean.getskipFields() />
			<cfset variables.beanClass = arguments.dataSettingsBean.getbeanClass() />
			<cfset variables.defaultOrderBy = arguments.dataSettingsBean.getdefaultOrderBy() />						
			<cfset variables.converter = arguments.converter />
			
		<cfreturn this/>		
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------------------->
	<cffunction name="getJsonChildren" access="private" returntype="array">
		<cfargument name="arr" required="true" type="array"/>
	
		<cfreturn arr />
	</cffunction>
<!----------------------------------------------------------------------------------------------->

<!---read return array of beans OVERRIDE--->	
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="read" output="false" returntype="array">
		<cfargument name="sql" required="true" type="com.andreacfm.core.sql"/>

			<cfset var converter = getConverter() />
			<cfset var anlibrary = getFacade().getObject('anxlibrary') />
			<cfset var result = arrayNew(1) />
			<cfset var arr = "" />
			<cfset var qRead = "" />
			<cfset var data = arguments.sql.getData()>
			<cfset var libraryList = data.libraryList />
			
			<cfloop list="#libraryList#" index="i">			
				<cfset qRead = anlibrary.get( i )/>
				<!---convert into struct--->
				<cfset arr = converter.queryToGenericBean( qRead , getBean()) />
				<!--- add to output only if a record was found--->
				<cfif not arrayIsEmpty(arr)>
					<!---append to the array --->
					<cfset arrayAppend(result,arr[1]) />
				</cfif>	
			</cfloop>

			<cfreturn result />
		
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---list return query OVERRIDE--->
<!--------------------------------------------------------------------------------------------------------------------->			
	<cffunction name="list" output="false" returntype="query">
		<cfthrow message="Use ancontent.cfc for querying content table" />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---json return array os struct in json format OVERRIDE--->			
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="json" output="false" returntype="string">
		<cfthrow message="Use ancontent.cfc for querying content table"/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

		
</cfcomponent>
