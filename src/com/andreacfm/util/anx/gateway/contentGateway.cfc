<cfcomponent 
	output="false" 
	name="Content Gateway" 
	extends="cfops.data.gateway">

<!---constructor OVERRIDE--->		
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.data.gateway">	
		<cfargument name="dataSettingsBean" required="true" type="com.andreacfm.core.datasettingsbean">
		<cfargument name="converter" required="true" type="com.andreacfm.core.object" />

			<cfset variables.instance.table = arguments.dataSettingsBean.getTable() />
			<cfset variables.instance.skipFields = arguments.dataSettingsBean.getskipFields() />
			<cfset variables.instance.beanClass = arguments.dataSettingsBean.getbeanClass() />
			<cfset variables.instance.defaultOrderBy = arguments.dataSettingsBean.getdefaultOrderBy() />						
			<cfset variables.instance.converter = arguments.converter />
			
		<cfreturn this/>		
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---read return array of beans OVERRIDE--->	
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="read" output="false" returntype="array">
		<cfargument name="sql" required="true" type="com.andreacfm.core.sql"/>

			<cfset var converter = getConverter() />
			<cfset var ancontent = getFacade().getObject('ancontent') />
			<cfset var result = arrayNew(1) />
			<cfset var arr = "" />
			<cfset var qRead = "" />
			<cfset var data = arguments.sql.getData()>
			<cfset var contentList = data.contentList />
			
			<cfif not structkeyExists(data,"language")>
				<cfset data.language = "" />
			</cfif>	

			<cfloop list="#contentList#" index="i">			
				<cfset qRead = ancontent.pageContent( tnodeid = 0 , cContentid = i , language = data.language )/>
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
