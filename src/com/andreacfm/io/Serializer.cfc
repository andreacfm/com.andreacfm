<cfcomponent 
	output="no" 
	name="Serialize" 
	author="Cristian Costantini - 10-11-2007 - cristian@millemultimedia.it - required ColdFusion 8"
	extends="com.andreacfm.core.object">

<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="init" access="public" returntype="component" output="no">
		<cfargument name="destination" type="string" required="no" default="#ExpandPath('.')#" />
		<cfset variables.instance.destination = arguments.destination />
		<cfreturn this />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---serialize--->
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="serialize" access="public" returntype="void" output="no" >
		<cfargument name="value" type="any" required="yes" />
		<cfargument name="name" type="string" required="yes" hint="File name" />
		<cfscript>
		var fileOut = CreateObject( 'java' , 'java.io.FileOutputStream' );
		var objOut = CreateObject( 'java' , 'java.io.ObjectOutputStream' );
		
		fileOut.init( variables.instance.destination & arguments.name);
		
		objOut.init( fileOut );
		objOut.writeObject( arguments.value );
		objOut.close();
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---deserialize--->
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="deserialize" access="public" returntype="any" output="no" hint="Deserialize cfc">
		<cfargument name="name" type="string" required="yes" hint="File name" />
		<cfscript>
		var fileIn = CreateObject( 'java' , 'java.io.FileInputStream' );
		var objIn = CreateObject( 'java' , 'java.io.ObjectInputStream' );
		var result = "";
		
		fileIn.init( variables.instance.destination & arguments.name );
		
		objIn.init( fileIn );
		result = objIn.readObject();
		objIn.close();
		return result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---destination--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getdestination" access="public" output="false" returntype="string">
		<cfreturn variables.instance.destination/>
	</cffunction>
	<cffunction name="setdestination" access="public" output="false" returntype="void">
		<cfargument name="destination" type="string" required="true"/>
		<cfset variables.instance.destination = arguments.destination/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->


</cfcomponent>