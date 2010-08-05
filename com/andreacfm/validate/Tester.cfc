<cfcomponent 
	output="false" 
	hint="Class provide validation support. All methods return boolean">

	<cffunction name="init" returntype="com.andreacfm.validate.Tester">
		<cfreturn this />
	</cffunction>	

<!---	Exists	( a getter method must be present ))--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="exists" output="false" returntype="boolean">
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="property" required="true" type="string" />			
		<cfscript>
			var prop = evaluate("obj.get#property#()");
			if(isSimpleValue(prop) and not len(prop)){
				return false;
			}			
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!--- numeric ( a getter method must be present ))--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="numeric" output="false" returntype="boolean">
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="property" required="true" type="string" />			
		<cfscript>
			var prop = evaluate("obj.get#property#()");
			if(not isNumeric(prop)){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!--- islen ( a getter method must be present ))--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="islen" output="false" returntype="boolean">
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="len" required="true" type="numeric" />			
		<cfscript>
			var prop = evaluate("obj.get#property#()");
			if(not len(trim(prop)) eq arguments.len){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---maxLength--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="maxLength" output="false" returntype="boolean">
		<cfargument name="str" required="true" type="string" />
		<cfargument name="length" required="true" type="numeric" />		
		
		<cfscript>
			if(len(arguments.str) gt arguments.length){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
<!---email--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="isEmail" output="false" returntype="boolean">
		<cfargument name="str" required="true" type="string" />
		
		<cfscript>
			if(not isValid('Email',arguments.str)){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
<!---url--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="url" output="false" returntype="boolean">
		<cfargument name="str" required="true" type="string" />
		
		<cfscript>
			if(not isValid('Url',arguments.str)){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---	isValidCreditCard	--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="isValidCreditCard" output="false" returntype="boolean">
		<cfargument name="type" required="true" type="string" />
		<cfargument name="number" required="true" type="string" />	
		
		<cfset var cr = structNew() />
		<cfset cr['Visa'] = '^4[0-9]{12}(?:[0-9]{3})?$' />
		<cfset cr['Mastercard'] = '^5[1-5][0-9]{14}$' />
		<cfset cr['AmEx'] = '^3[47][0-9]{13}$' />
		<cfset cr['Discover'] = '^6(?:011|5[0-9]{2})[0-9]{12}$' />
		<cfset cr['Diners'] = '^3(?:0[0-5]|[68][0-9])[0-9]{11}$' />
		
		<cfif refind(cr[arguments.type],arguments.number) eq 0>
			<cfreturn false />
		</cfif>
		
		<cfreturn true/>	
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!--- insertPk ( a getter method must be present ))--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="insertPk" output="false" returntype="boolean">
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="property" required="true" type="string" />			
		<cfscript>
			var prop = evaluate("obj.get#property#()");
			if(not len(prop) or not isNumeric(prop) or prop neq 0){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!--- updatePk ( a getter method must be present ))--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="updatePk" output="false" returntype="boolean">
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="property" required="true" type="string" />			
		<cfscript>
			var prop = evaluate("obj.get#property#()");
			if(not len(prop) or not isNumeric(prop) or prop eq 0){
				return false;
			}
			return true;
		</cfscript>

	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

</cfcomponent>
