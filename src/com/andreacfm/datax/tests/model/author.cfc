<cfcomponent
	extends="com.andreacfm.datax.Model">
	
	<cfproperty name="authorId" type="numeric" />
	<cfproperty name="authorName" type="string" />
	<cfproperty name="createOn" type="date" />
	<cfproperty name="sort" type="numeric" />
	
	<cfproperty name="bookList" type="string" />
	<cfproperty name="bookarray" type="array" />

	<cfscript>
	this.loaded = {};
	
	variables.instance['authorId'] = 0;
	variables.instance['authorName'] = "";
	
	
	
	variables.instance['bookList'] = "";
	variables.instance['bookarray'] = createObject('java','java.util.ArrayList').init();
	
	</cfscript>
	
	<!--- Constructor --->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.Model">	
		<cfargument name="dao" required="true" type="com.andreacfm.datax.Dao"/>
		<cfargument name="validator" required="false" type="com.andreacfm.validate.Validator" default="#createObject('component','com.andreacfm.validate.Validator').init()#"/>		

		<cfscript>
			super.init(arguments.dao,arguments.validator);			
			return this;		
		</cfscript>
	
	</cffunction>
	
	<!-------------------------------------- Public -------------------------------------------------->

	
	<cffunction name="getauthorId" output="false" returntype="numeric" >
		<cfscript>	
		return variables.authorId;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorId" output="false" returntype="void" >
		<cfargument name="authorId" type="numeric" required="true"/>
		<cfscript>	
		variables.authorId = arguments.authorId;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getauthorName" output="false" returntype="string" >
		<cfscript>	
		return variables.authorName;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorName" output="false" returntype="void" >
		<cfargument name="authorName" type="string" required="true"/>
		<cfscript>	
		variables.authorName = arguments.authorName;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getcreateOn" output="false" returntype="date" >
		<cfscript>	
		return variables.createOn;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setcreateOn" output="false" returntype="void" >
		<cfargument name="createOn" type="date" required="true"/>
		<cfscript>	
		variables.createOn = arguments.createOn;
		</cfscript>
	</cffunction>	


	
	<cffunction name="getsort" output="false" returntype="numeric" >
		<cfscript>	
		return variables.sort;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setsort" output="false" returntype="void" >
		<cfargument name="sort" type="numeric" required="true"/>
		<cfscript>	
		variables.sort = arguments.sort;
		</cfscript>
	</cffunction>	


<!-------------------------------------- Composite -------------------------------------------------->

	<!--- bookList --->
	<cffunction name="getbookList" output="false" returntype="string" >
		<cfscript>	
		return variables.bookList;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookList" output="false" returntype="void" >
		<cfargument name="bookList" type="string" required="true"/>
		<cfscript>
		variables.bookList = arguments.bookList;		
		</cfscript>
	</cffunction>	
	
	<!--- bookarray --->	
	<cffunction name="getbookarray" output="false" returntype="any" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			if(listlen(variables.bookList) and not structKeyExists(this['loaded'],'bookarray') or arguments.refresh){
				list = getbookList();
				advsql.where = "bookId IN (#list#)";
				setbookarray(getBeanFactory().getBean('dsManager').getService('bookService').read( data = arguments.data, filters = arguments.filters, advsql = advsql));
				this['loaded']['bookarray'] = 'loaded';
			};
			if(arguments.pop){
				return variables.bookarray[1];
			}
			return variables.bookarray;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookarray" output="false" returntype="void" >
		<cfargument name="bookarray" type="array" required="true"/>
		<cfscript>	
		variables.bookarray = arguments.bookarray;
		</cfscript>
	</cffunction>	



</cfcomponent>
