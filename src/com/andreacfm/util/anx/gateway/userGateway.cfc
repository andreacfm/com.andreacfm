<cfcomponent 
	output="false" 
	name="User Gateway" 
	extends="cfops.data.gateway">

<!---read return array of beans OVERRIDE--->	
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="read" output="false" returntype="array">
		<cfargument name="sql" required="true" type="com.andreacfm.core.sql"/>

			<cfset var converter = getConverter() />
			<cfset var anxObj = getFacade().getObject('anxUser') />
			<cfset var result = arrayNew(1) />
			<cfset var arr = "" />
			<cfset var qRead = "" />
			<cfset var data = arguments.sql.getData()>
			<cfset var userList = data.userList />
			

			<cfloop list="#userList#" index="i">			
				<cfset qRead = anxObj.get(i)/>
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
		
</cfcomponent>
