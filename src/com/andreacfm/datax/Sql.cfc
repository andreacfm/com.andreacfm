<cfcomponent 
	output="false"
	name="Sql"
	extends="com.andreacfm.Object">

	<cfproperty name="orderby" type="string" />
	<cfproperty name="data" type="struct" />
	<cfproperty name="fieldlist" type="string" />
	<cfproperty name="maxrows" type="numeric" />
	<cfproperty name="filters" type="array" />
	<cfproperty name="advsql" type="struct" />
	<cfproperty name="alive" type="boolean" />

	<cfset variables.instance.alive = true />	
	<cfset variables.instance.query = queryNew('x')/>
	<cfset variables.instance.objectsRecordSet = createObject('java','java.util.ArrayList').init()/>
		
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
		
		<cfset variables.instance.cache = arguments.cache />
		
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
		
		<cfreturn this/>
	</cffunction>

	<!--- kill --->
	<cffunction name="kill" returntype="void" output="false" access="public">
		<cfset variables.instance.alive = false	 />	
	</cffunction>
	
	<!--- isCaching --->
	<cffunction name="isCaching" returntype="Boolean" output="false" access="public">
		<cfreturn variables.instance.cache />	
	</cffunction>	

	<!--- isAlive --->
	<cffunction name="isAlive" returntype="Boolean" output="false" access="public">
		<cfreturn variables.instance.alive />	
	</cffunction>	
	
    <!--- query--->
    <cffunction name="setquery" access="public" returntype="void">
		<cfargument name="query" type="Query" required="true"/>
		<cfset variables.instance.query = query />
	</cffunction> 

	<cffunction name="getquery" access="public" returntype="Query">
		<cfreturn variables.instance.query/>
	</cffunction>	

    <!--- objectsRecordset--->
    <cffunction name="setobjectsRecordset" access="public" returntype="void">
		<cfargument name="objectsRecordset" type="Array" required="true"/>
		<cfset variables.instance.objectsRecordset = objectsRecordset />
	</cffunction> 

	<cffunction name="getobjectsRecordset" access="public" returntype="Array">
		<cfreturn variables.instance.objectsRecordset/>
	</cffunction>

    <!--- cacheKey--->
    <cffunction name="setcacheKey" access="public" returntype="void">
		<cfargument name="cacheKey" type="com.andreacfm.datax.CacheKey" required="true"/>
		<cfset var d = arrayNew(1) />
		<cfif isCaching() and cacheKey.askSqlKey()>
			<cfset d = [getmethod(),getTable(),getSortedData(d),getfilters(),getfieldlist(),getadvsql(),getorderBy()] />
			<cfset cacheKey.setData(d) />
		</cfif>
		<cfset variables.instance.cacheKey = cacheKey />
	</cffunction> 
	<cffunction name="getcacheKey" access="public" returntype="com.andreacfm.datax.CacheKey">
		<cfreturn variables.instance.cacheKey/>
	</cffunction>
	
	<!---data--->
	<cffunction name="getdata" access="public" output="false" returntype="struct">
		<cfreturn variables.instance.data/>
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
		<cfset variables.instance.data = d/>
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
	

	<!---orderBy--->
	<cffunction name="getorderBy" access="public" output="false" returntype="string">
		<cfreturn variables.instance.orderBy/>
	</cffunction>
	<cffunction name="setorderBy" access="public" output="false" returntype="void">
		<cfargument name="orderBy" type="string" required="true"/>
		<cfset variables.instance.orderBy = arguments.orderBy/>
	</cffunction>

	<!---fieldlist--->
	<cffunction name="getfieldlist" access="public" output="false" returntype="string">
		<cfreturn variables.instance.fieldlist/>
	</cffunction>
	<cffunction name="setfieldlist" access="public" output="false" returntype="void">
		<cfargument name="fieldlist" type="string" required="true"/>
		<cfset variables.instance.fieldlist = arguments.fieldlist/>
	</cffunction>

	<!---maxrows--->
	<cffunction name="getmaxrows" access="public" output="false" returntype="numeric">
		<cfreturn variables.instance.maxrows/>
	</cffunction>
	<cffunction name="setmaxrows" access="public" output="false" returntype="void">
		<cfargument name="maxrows" type="numeric" required="true"/>
		<cfset variables.instance.maxrows = arguments.maxrows/>
	</cffunction>

	<!---filters--->
	<cffunction name="getfilters" access="public" output="false" returntype="array">
		<cfreturn variables.instance.filters/>
	</cffunction>
	<cffunction name="setfilters" access="public" output="false" returntype="void">
		<cfargument name="filters" type="array" required="true"/>
		<cfset variables.instance.filters = arguments.filters/>
	</cffunction>

	<!---advsql--->
	<cffunction name="getadvsql" access="public" output="false" returntype="struct">
		<cfreturn variables.instance.advsql/>
	</cffunction>
	<cffunction name="setadvsql" access="public" output="false" returntype="void">
		<cfargument name="advsql" type="struct" required="true"/>
		<cfset variables.instance.advsql = arguments.advsql/>
	</cffunction>

    <!--- method--->
    <cffunction name="setmethod" access="public" returntype="void">
		<cfargument name="method" type="String" required="true"/>
		<cfset variables.instance.method = method />
	</cffunction> 
	<cffunction name="getmethod" access="public" returntype="String">
		<cfreturn variables.instance.method/>
	</cffunction>

    <!--- table--->
   	<cffunction name="settable" access="public" returntype="void">
		<cfargument name="table" type="String" required="true"/>
		<cfset variables.instance.table = table />
	</cffunction> 
	<cffunction name="gettable" access="public" returntype="String">
		<cfreturn variables.instance.table/>
	</cffunction>

</cfcomponent>
