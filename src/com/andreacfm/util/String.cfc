<cfcomponent 
	output="false" 
	name="string">

<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="cfops.core.object">
		<cfargument name="str" required="false">
		<cfreturn this />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
	<cffunction name="abbreviate" output="false" returntype="string" access="public">
		<cfargument name="string" required="true" type="string">
		<cfargument name="len" required="true" type="numeric">
			
		<cfscript>
			var newString = REReplace(arguments.string, "<[^>]*>", " ", "ALL");
			var lastSpace = 0;
			newString = REReplace(newString, " \s*", " ", "ALL");
			if (len(newString) gt arguments.len) {
				newString = left(newString, len-2);
				lastSpace = find(" ", reverse(newString));
				lastSpace = len(newString) - lastSpace;
				newString = left(newString, lastSpace) & "  &##8230;";
			}
				
		</cfscript>
		
		<cfreturn newString />
		
	</cffunction>

</cfcomponent>
