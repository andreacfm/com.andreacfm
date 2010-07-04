<cfcomponent 
	output="false" 
	name="anxUserService" 
	extends="cfops.data.dataService">


<!---makeComposite--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="makeComposite" output="false" returntype="array">
		<cfargument name="objArray" required="true" type="array">
		
		<cfset var result = arguments.objArray />

		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->


</cfcomponent>


