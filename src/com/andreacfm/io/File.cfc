<cfcomponent 
	name="file" 
	output="false" 
	extends="com.andreacfm.Object">

	<cfproperty name="hasLoadedChildren" type="boolean"/>
	<cfproperty name="children" type="array"/>
	<cfproperty name="regex" type="string"/>
	<cfproperty name="type" type="string"/>
	
	<cfscript>
		// private
		variables.instance['children'] = arrayNew(1);
		//public
		variables.instance['hasLoadedChildren'] = false;
		variables.instance['regex'] = "";
		variables.instance['childrenType'] = "all";
	</cfscript>
	
<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.io.File">
		<cfargument name="path" required="false" type="string" default="/" hint="absolute path" />
		<cfargument name="relPath" required="false" type="string" default="/" hint="url passed to the instance struct // do nto include last '/' for directories' " />

		<cfscript>
			
			variables['javaObj'] = createObject('java','java.io.File').init(JavaCast('String',arguments.path));
			
			variables.instance['url'] = arguments.relPath;
						
			setInstance();
			return this;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!-------------------------------------------     PUBLIC     ---------------------------------------------------------->
<!--- getJavaObj  // is not laoded ininstance to be skipped from remote transformations --->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getJavaObj" access="public" output="false" returntype="any">
		<cfreturn variables['javaObj'] />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getUrl--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.instance['url'] />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getAbsolutePath--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getAbsolutePath" access="public" output="false" returntype="string">
		<cfreturn getJavaObj().getAbsolutePath()/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getChildren  //  lazyloading of an array of files in the directory --->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getChildren" output="false" returntype="array">
		<cfargument name="refresh" type="boolean" required="false" default="false" />
		
		<cfscript>
			if(isDirectory()){

				if( hasLoadedChildren() eq false or arguments.refresh) {				
			
					setChildren(getRegex(),getchildrentype());
					setHasLoadedChildren(true);
					
					return variables.children;
			
				}else{
			
					return variables.children;
				}			
			
			}else{
			
				throw('The method cannot be called if the object instance represent a file.');
			
			}			
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---canRead--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="canRead" output="false" returntype="boolean">
		<cfreturn getJavaObj().canRead() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---canWrite--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="canWrite" output="false" returntype="boolean">
		<cfreturn getJavaObj().canWrite() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---isFile--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="isFile" output="false" returntype="boolean">
		<cfreturn getJavaObj().isFile() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---isDirectory--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="isDirectory" output="false" returntype="boolean">
		<cfreturn getJavaObj().isDirectory() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---isAbsolute--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="isAbsolute" output="false" returntype="boolean">
		<cfreturn getJavaObj().isAbsolute() />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---hasLoadedChildren--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="hasLoadedChildren" access="public" output="false" returntype="boolean">
		<cfreturn variables.instance['hasLoadedChildren']/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---regex--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getregex" access="public" output="false" returntype="string">
		<cfreturn variables.instance['regex']/>
	</cffunction>
	<cffunction name="setregex" access="public" output="false" returntype="void">
		<cfargument name="regex" type="string" required="true"/>
		<cfset variables.instance['regex']= arguments.regex/>
	</cffunction>	
<!--------------------------------------------------------------------------------------------------------------------->

<!---getchildrenType--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getChildrenType" access="public" output="false" returntype="string">
		<cfreturn variables.instance['childrenType']/>
	</cffunction>
	<cffunction name="setchildrenType" access="public" output="false" returntype="void">
		<cfargument name="childrenType" type="string" required="true"/>
		<cfset variables.instance['childrenType'] = arguments.childrenType/>
	</cffunction>	
<!--------------------------------------------------------------------------------------------------------------------->

<!---gettype--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfscript>
			var result = "";			
			if(isDirectory()){
				result = 'dir';
			}else if(isFile()){
				result = 'file';
			}
			return result;
		</cfscript>
	</cffunction>	
<!--------------------------------------------------------------------------------------------------------------------->

<!---getName--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfscript>
			var result = getJavaObj().getName();			
			return result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getName--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getSize" access="public" output="false" returntype="numeric">
		<cfscript>
			var result = getJavaObj().length();			
			return result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getMIme--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getMime" access="public" output="false" returntype="string">
		<cfscript>
			var result = "";
			if(listlen(getName(),'.') gt 1){
				result = listLast(getName(),'.');	
			}	
			return result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->


<!-------------------------------------------     PRIVATE      -------------------------------------------------------->
<!---setChildren--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setChildren" access="private" output="false" returntype="any">

		<cfset var q = queryNew('') />
		<cfset var result = createObject('java','java.util.ArrayList').init() />
		<cfset var obj = "" />
		<cfset var href = getUrl()/>
		<cfset var newUrl = "" />
		<cfset var i = "" />
		
		<cfdirectory action="list" directory="#getAbsolutePath()#" name="q" filter="#getregex()#" type="#getchildrenType()#"/>
		
		<cfscript>
			
			for( i = 1 ; i <= q.recordcount; i++ ){
				newUrl = href & q.name[i];				
				if(q.type[i] == 'dir'){
					newUrl = newUrl & '/'; 
				}
				obj = createObject('component','com.andreacfm.io.File').init(q.directory[i] & '/' & q.name[i],newUrl);
				result.add(obj);
			
			}
			
			variables.instance['children'] = result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---setInstance--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setInstance" output="false" returntype="void">
		<cfscript>
			variables.instance['name'] = getName();
			variables.instance['size'] = getSize();
			variables.instance['type'] = getType();
			variables.instance['mime'] = getMime();
			variables.instance['absPath'] = getAbsolutePath();
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---sethasLoadedChildren--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="sethasLoadedChildren" access="private" output="false" returntype="void">
		<cfargument name="hasLoadedChildren" type="boolean" required="true"/>
		<cfset variables.instance['hasLoadedChildren'] = arguments.hasLoadedChildren/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

</cfcomponent>