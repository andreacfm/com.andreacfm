<cfcomponent 
	output="false" 
	name="LibraryService" 
	extends="cfops.data.dataService">


<!---makeComposite--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="makeComposite" output="false" returntype="array">
		<cfargument name="objArray" required="true" type="array">
		
		<cfset var result = arguments.objArray />

		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---	
	filterByType
	@ arr : array / default : arrayNew(1)( array of library object to filter )
	@ filter : string / default : img ( folder name to filter 'img' or 'ass')
	@ return array with the object matching the type passed
--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="filterByType" output="false" returntype="array">
		<cfargument name="arr" required="false" type="array" default="arrayNew(1)"/>
		<cfargument name="filter" required="false" type="string" default="img"/>
		<cfscript>
			var result = createObject('component','org.coldquery.coldquery').init(arguments.arr).$("function f(obj){return obj.getFolder() == '#arguments.filter#';}").getItems(); 
			return result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->



</cfcomponent>


