<cfcomponent 
	output="false" 
	extends="cfops.io.file">

<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.io.file">
		<cfargument name="path" required="false" type="string" default="/" hint="relative or absolute path to the file or directory" />
		<cfargument name="url" required="false" type="string" default="/" hint="url passed to the instance struct // do nto include last '/' for directories' " />
		<cfargument name="id" required="false" type="numeric" default="0" />
		<cfargument name="metatype" required="false" type="string" default="library"/>
		
		<cfscript>
			setid(arguments.id);
			setMetaType(arguments.metaType);			
			super.init(arguments.path,arguments.url,arguments.id,arguments.metatype);
			setMeta();
			return this;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
<!---metaType--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getmetaType" access="public" output="false" returntype="string">
		<cfreturn variables.instance.metaType/>
	</cffunction>
	<cffunction name="setmetaType" access="public" output="false" returntype="void">
		<cfargument name="metaType" type="string" required="true"/>
		<cfset variables.instance.metaType = arguments.metaType/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---id--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getid" access="public" output="false" returntype="numeric">
		<cfreturn variables.instance.id/>
	</cffunction>
	<cffunction name="setid" access="public" output="false" returntype="void">
		<cfargument name="id" type="numeric" required="true"/>
		<cfset variables.instance.id = arguments.id/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
<!---meta--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getmeta" access="public" output="false" returntype="array">
		<cfreturn variables.instance.meta/>
	</cffunction>
	<cffunction name="setmeta" access="public" output="false" returntype="void">
		<cfargument name="filename" required="false" default="#getname()#" type="string" />
		<cfscript>
			var q = application.ancontent.getFileMetadata(getmetaType(),getId(),arguments.filename);
			var meta = createObject('component','com.andreacfm.util.converter').queryToArray(q);
			variables.instance.meta = meta;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
		
<!---setChildren /// Overrride--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="setChildren" access="private" output="false" returntype="any">
		<cfset var q = queryNew('') />
		<cfset var result = createObject('java','java.util.ArrayList').init() />
		<cfset var obj = "" />
		<cfset var url = getUrl()/>
		<cfset var newUrl = "" />
		
		<cfdirectory action="list" directory="#getAbsolutePath()#" name="q" filter="#getregex()#" type="#getchildrenType()#"/>

		<cfscript>			
			for( i = 1 ; i <= q.recordcount; i++ ){
				newUrl = url & q.name[i];				
				if(q.type[i] == 'dir'){
					newUrl = newUrl & '/'; 
				}
				obj = createObject('component','com.andreacfm.anx.io.anxfile').init(q.directory[i] & '\' & q.name[i],newUrl,getId(),getmetaType());
				obj.setMeta();	
				result.add(obj);
			}
			
			variables.instance['children'] = result;
		</cfscript>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
		

</cfcomponent>