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
	<cfproperty name="offset" type="numeric">
	<cfproperty name="cacheKey" type="com.andreacfm.datax.CacheKey">
	

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
		<cfargument name="CacheKey" required="false" type="com.andreacfm.datax.CacheKey" default="#createObject('component','com.andreacfm.datax.CacheKey').init()#"/>
		<cfargument name="offset" required="false" type="numeric" default="0" />
		
		<cfset variables.cache = arguments.cache />
		
		<cfset setData(data) />
		<!--- for caching keys --->
		<cfset setMethod(method) />
		<cfset setTable(table) />
		<cfset setorderBy(orderBy) />
		<cfset setmaxrows(maxrows) />
		<cfset setfieldlist(fieldlist) />
		<cfset setadvsql(advSql) />
		<cfset setfilters(filters) />
		<cfset setcacheKey(CacheKey) />
		<cfset setOffset(offset)>
		
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
	
    <!--- query--->
    <cffunction name="setquery" access="public" returntype="void">
		<cfargument name="query" type="Query" required="true"/>
		<cfset variables.query = query />
	</cffunction> 
	<cffunction name="getquery" access="public" returntype="Query">
		<cfreturn variables.query/>
	</cffunction>	

    <!--- objectsRecordset--->
    <cffunction name="setobjectsRecordset" access="public" returntype="void">
		<cfargument name="objectsRecordset" type="Array" required="true"/>
		<cfset variables.objectsRecordset = objectsRecordset />
	</cffunction> 
	<cffunction name="getobjectsRecordset" access="public" returntype="Array">
		<cfreturn variables.objectsRecordset/>
	</cffunction>

    <!--- cacheKey--->
    <cffunction name="setcacheKey" access="public" returntype="void">
		<cfargument name="cacheKey" type="com.andreacfm.datax.CacheKey" required="true"/>
		<cfset var d = arrayNew(1) />
		<cfif isCaching() and cacheKey.askSqlKey()>
			<cfset d = [getmethod(),getTable(),getSortedData(d),getfilters(),getfieldlist(),getadvsql(),getorderBy(),getmaxRows(),getoffset()] />
			<cfset cacheKey.setData(d) />
		</cfif>
		<cfset variables.cacheKey = cacheKey />
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
