<cfcomponent output="false" name="Sql" accessors="true" extends="com.andreacfm.datax.Base">

	<cfproperty name="method" type="string" />
	<cfproperty name="table" type="string" />
	<cfproperty name="orderby" type="string" />
	<cfproperty name="data" type="struct" />
	<cfproperty name="fieldlist" type="string" />
	<cfproperty name="maxrows" type="numeric" />
	<cfproperty name="filters" type="array" />
	<cfproperty name="advsql" type="struct" />
	<cfproperty name="alive" type="boolean" />
	<cfproperty name="cache" type="boolean" />
	<cfproperty name="offset" type="numeric">
	<cfproperty name="key" type="any">
	<cfproperty name="relatedtables" type="string">
	

	<cfset variables.alive = true />	
	<cfset variables.query = queryNew('x')/>
	<cfset variables.objectsRecordSet = createObject('java','java.util.ArrayList').init()/>
	
	<!--- TODO 
	Offset
	--->
		
	<!---Constructor--->
	<cffunction name="init" returntype="com.andreacfm.datax.Sql">
		<cfargument name="data" type="struct" required="false" default="#structNew()#"/>
		<cfargument name="method" type="string" required="false" default=""/>
		<cfargument name="table" type="string" required="false" default=""/>		
		<cfargument name="orderBy" required="false" default="" />
		<cfargument name="maxrows" required="false" type="numeric" default="1000000" />
		<cfargument name="fieldlist" required="false" default="" />
		<cfargument name="advSql" required="false"  type="struct" default="#structNew()#"/>
		<cfargument name="filters" required="false" type="array" default="#arrayNew(1)#"/>
		<cfargument name="cache" required="false" type="boolean" default="false" />
		<cfargument name="key" required="false" type="any" default=""/>
		<cfargument name="offset" required="false" type="numeric" default="0" />
		<cfargument name="relatedtables" required="false" type="string" default="" />
		
		<cfset setcache(arguments.cache) />

		<cfset setData(data) />
		<cfset setMethod(method) />
		<cfset setTable(table) />
		<cfset setorderBy(orderBy) />
		<cfset setmaxrows(maxrows) />
		<cfset setfieldlist(fieldlist) />
		<cfset setadvsql(advSql) />
		<cfset setfilters(filters) />
		<cfset setOffset(offset)>
		<cfset setRelatedTables(relatedtables)>
		
		<!--- keys maust be the latest to be generated --->
		<cfset setkey(key) />
		
		<cfreturn this/>
	</cffunction>

	<!--- kill --->
	<cffunction name="kill" returntype="void" output="false" access="public">
		<cfset variables.alive = false	 />	
	</cffunction>
	
	<!--- isCaching --->
	<cffunction name="isCaching" returntype="Boolean" output="false" access="public">
		<cfreturn variables.cache />	
	</cffunction>	

	<!--- isAlive --->
	<cffunction name="isAlive" returntype="Boolean" output="false" access="public">
		<cfreturn variables.alive />	
	</cffunction>	
	
	
	<!--- result--->
	<cffunction name="setresult" access="public" returntype="void">
		<cfargument name="result" type="any" required="true"/>
		<cfset variables.result = result />
	</cffunction> 
	<cffunction name="getresult" access="public" returntype="any">
		<cfreturn variables.result/>
	</cffunction>

    <!--- key--->
    <cffunction name="setkey" access="public" returntype="void">
		<cfargument name="key" type="any" required="true"/>
		<cfset var d = arrayNew(1) />
		
		<cfif isCaching()>
			<cfif len(arguments.key)>
				<cfset variables.key = arguments.key>
			<cfelse>
				<cfset var rel = rereplacenocase(getRelatedTables(),',','_','All')>
				<cfset rel = rereplacenocase(rel,"'",'','All')>				
				<cfset d = [getmethod(),getTable(),getSortedData(d),getfilters(),getfieldlist(),getadvsql(),getorderBy(),getmaxRows(),getoffset()] />
				<cfset variables.key = trim(rel & '_' & hash(serializejson(d))) />
			</cfif>
		</cfif>

	</cffunction> 
	
	<!---data--->
	<cffunction name="getdata" access="public" output="false" returntype="struct">
		<cfreturn variables.data/>
	</cffunction>
	<cffunction name="setdata" access="public" output="false" returntype="void">
		<cfargument name="data" type="struct" required="true"/>
		<!--- any manipulation on data do not reflect on passed object --->
		<cfset var d = duplicate(data) />
		<!--- remove complex values --->
		<cfloop collection="#d#" item="key">
			<cfif not isSimpleValue(d[key])>
				<cfset structdelete(d,key) />
			</cfif>		
		</cfloop>
		<cfset variables.data = d/>
	</cffunction>
	<cffunction name="getSortedData" access="public" output="false" returntype="array">
		<cfset var d = getdata() />
		<cfset var arr = structsort(d) /> 
		<cfset var result = [] />
		<cfloop array="#arr#" index="item">
			<cfset result.add(d[item]) />
		</cfloop>
		<cfreturn result/>
	</cffunction>
	
</cfcomponent>
