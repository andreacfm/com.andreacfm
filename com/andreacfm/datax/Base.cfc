<cfcomponent output="false">
	
	<!---getObjectId--->
	<cffunction name="getObjectId" returntype="string" output="false" hint="Return the identityHashCode of the java object underling the cfc ">
		<cfreturn createObject("java", "java.lang.System").identityHashCode(this)/>
	</cffunction>

	<!---	populate	--->
	<cffunction name="populate" output="false" returntype="void" hint="Support method to populate the bean from a passed struct of values">
		<cfargument name="collection" required="false" default="#structNew()#" type="struct" />

		<cfscript>
			for(item in arguments.collection){
				if(structKeyExists(this,"set#item#")){
					evaluate( "set#item#( arguments.collection['#item#'])" );
				}
			}
		</cfscript>

	</cffunction>

	<!---getMemento--->
	<cffunction name="getMemento" output="false" returntype="any">
		<cfset var properties = getMetadata(this).properties>
		<cfset var result = {}>
		<cfloop array="#properties#" index="prop">
			<cfset result["#prop.name#"] = evaluate("get#prop.name#()")>
		</cfloop>
		<cfreturn result />
	</cffunction>


</cfcomponent>