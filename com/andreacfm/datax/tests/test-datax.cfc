<cfcomponent displayname="core-bean" extends="mxunit.framework.TestCase">

	<cffunction name="setUp">
		<cfset variables.beanfactory = CreateObject('component','com.andreacfm.util.beanutils.DynamicXmlBeanFactory').init()/>
		<cfset variables.beanfactory.loadBeansFromDynamicXmlFile('/com/andreacfm/datax/tests/config/coldspring.xml.cfm') />
		<cfset variables.beanfactory.getBean('EventManager').getLogger().setOut('console')>		
	</cffunction>
	
	<cffunction name="teardown">
		<cfscript>
		var dm = variables.beanfactory.getBean('dataMgr');
		dm.removeTable('book_author');		
		dm.removeTable('book');
		dm.removeTable('author');
		</cfscript>
	</cffunction>
	
	<cffunction name="testDataMgr" returntype="void" hint="test dataMgr bean creation">
		<cfset var dataMgr = variables.beanfactory.getBean('dataMgr') />
		<cfset assertTrue(isInstanceOf(dataMgr,'com.andreacfm.datax.dataMgr.dataMgr'),"Data mgr not loaded correctly")>		
	</cffunction>

	<cffunction name="testgetBeanFromDbFactory" returntype="void" hint="get bean instances from dbFactory">
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var bookbean = dbFactory.getBean('book') />	
		<cfset var authorbean = dbFactory.getBean('author') />
		
		<cfset assertTrue(isInstanceOf(bookbean,'com.andreacfm.datax.Model'),"book bean is not of class databean")>
		
		<!--- dao and validator for book bean are decorator object --->
		<cfset assertTrue(isInstanceOf(bookbean.getDao(),'com.andreacfm.datax.tests.model.bookDao'),"book bean dao/decorator has not been proeprly created")>
		<cfset assertTrue(isInstanceOf(bookbean.getValidator(),'com.andreacfm.datax.tests.model.bookValidator'),"book bean validator/decorator has not been proeprly created")>		
		
		<!--- dao and validator for author bean are core object --->	
		<cfset assertTrue(isInstanceOf(authorbean.getDao(),'com.andreacfm.datax.Dao'),"Core dao has not been properly geerated")>
		<cfset assertTrue(isInstanceOf(authorbean.getValidator(),'com.andreacfm.validate.Validator'),"Core validator has not been properly geerated")>				
		
	</cffunction>
	
	<cffunction name="testDataServiceManager" returntype="void" hint="Check the object returned by the dsmanager in base of the differents configuration">
		<cfset var dsM = variables.beanfactory.getbean('dsManager') />
		<cfset var bookService = dsM.getService('bookService') />
		<cfset var authorService = dsM.getService('authorService') />
		
		<!--- bookService has a decorator --->
		<cfset assertTrue(isInstanceOf(bookService,'com.andreacfm.datax.tests.model.bookservicedecorator'),'The dataService object returned is not of class cfops.tests.model.bookservicedecorator!') />			
		<!--- bookgateway has a decorator --->
		<cfset assertTrue(isInstanceOf(bookService.getGateway(),'com.andreacfm.datax.tests.model.bookgateway'),'The gateway/decorator is not loaded correctly.')>	

		<!--- authorService has a decorator --->
		<cfset assertTrue(isInstanceOf(bookService,'com.andreacfm.datax.DataService'),'The dataService object returned is not of class cfops.system.data.dataservice!') />			
		<!--- authorgateway is default object --->
		<cfset assertTrue(isInstanceOf(authorService.getGateway(),'com.andreacfm.datax.Gateway'),'The gateway is not loaded correctly.')>	
	
	</cffunction>
	
	<cffunction name="testinsert" returntype="void" hint="Test insert operation">
		<cfset var bookService = variables.beanfactory.getBean('dsManager').getService('bookService') />
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var book = dbFactory.getBean('book') />
		
		<cfset dm = variables.beanfactory.getBean('dataMgr') />
		
		<cftransaction action="begin"> 
			<cftry>
				<!--- craete --->
				<cfset book.setBookName('newBook') />
				<cfset result = book.create() />
				
				<cfset assertTrue(result.getStatus() and isNumeric(result.getData()),'Inserting data failed!') />
				
				<cfcatch type="any">
					<cftransaction action="rollback"/>
				</cfcatch>			
			
			</cftry>

			<cftransaction action="rollback"/>			
		</cftransaction>
			
	</cffunction>		
	
	<cffunction name="testupdate" returntype="void" hint="Test update operation">
		<cfset var bookService = variables.beanfactory.getBean('dsManager').getService('bookService') />
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var book = dbFactory.getBean('book') />
		<cfset var newBook = "" />
		<cfset var result = "" />
		
		<cftransaction action="begin"> 
			<cftry>
				<!--- craete --->
				<cfset book.setBookName('newBook') />
				<cfset result = book.create() />
	
				<!--- update --->
				<cfset book.setBookName('testName') />
				<cfset book.setBookId(result.getData()) />
				<cfset book.update() />
				
				<!--- reload --->
				<cfset newBook = bookService.readById(result.getData(),true) />
							
				<cfset assertTrue(newbook.getBookId() eq result.getData() and newbook.getBookName() eq 'testName','Updating data failed!') />
			
				<cfcatch type="any">
					<cftransaction action="rollback"/>
				</cfcatch>			
			
			</cftry>

			<cftransaction action="rollback"/>
		</cftransaction>
			
	</cffunction>		
	
	<cffunction name="testdelete" returntype="void" hint="Test delete operations">
		<cfset var bookService = variables.beanfactory.getBean('dsManager').getService('bookService') />
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var book = dbFactory.getBean('book') />
		<cfset var result =  ""/>	
		<cfset var q = "" />
		
		<cftransaction action="begin">
	
			<cftry>	
				<!--- craete --->
				<cfset book.setBookName('newBook') />
				<cfset result = book.create() />
							
				<!--- update the bean --->
				<cfset book.setBookId(result.getData()) />
				
				<!--- delete --->
				<cfset book.delete() />
				
				<!--- try to reload --->
				<cfset q = bookService.listById(result.getData()) />
				
				<cfset assertTrue(q.recordcount eq 0,'Deleting data failed.') />
	
				<cfcatch type="any">
					<cftransaction action="rollback"/>
				</cfcatch>			
			
			</cftry>
					
			<cftransaction action="rollback"/>
		</cftransaction>
			
	</cffunction>		

	<cffunction name="testMakeBeans" returntype="void" hint="test the physical bean generation">
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var book = "" />
		<cfset var author = "" />
		<!--- make one bean --->
		<cfset dbFactory.makeBean('author') />
		<!--- make all the beans --->
		<cfset dbFactory.makeBeans() />
		<cfset book = dbfactory.getbean('book') />
		<cfset author = dbfactory.getbean('author') />

		<cfset assertTrue(isInstanceOf(book,'com.andreacfm.datax.tests.model.book'),"Making book bean failed.") />
		<cfset assertTrue(isInstanceOf(author,'com.andreacfm.datax.tests.model.author'),"Making author bean failed.") />
			
	</cffunction>

	<cffunction name="testlazyLoading" returntype="void" hint="test the ability to load composite data only on demand">
		<cfset var bookService = variables.beanfactory.getBean('dsManager').getService('bookService') />
		<cfset var dbfactory = variables.beanfactory.getbean('dbFactory') />
		<cfset var authors = "" />
		<cfset var authorsHash = "" />
		<cfset var reauthors = "" />
		<cfset var reauthorsHash = "" />
		<cfset var author = "" />
		<cfset var book = "" />
		<cfset var result = "" />

		<cftransaction action="begin">
			
			<cftry>
				
				<!--- make all the beans --->
				<cfset dbFactory.makeBeans() />
		
				<cfset var author = dbFactory.getBean('author') />
				<cfset var book = dbFactory.getBean('book') />
				
				<!--- set some data --->
				<cfset author.setAuthorName('Author A')/>
				<cfset result = author.create() />
				<cfset book.setBookName('book A') />
				<cfset book.setAuthorList(result.getData()) />
				<cfset result = book.create() />
				
				<cfset book = bookService.readById(result.getData(),true) />
				
				<!--- load check must be empty --->
				<cfset assertTrue(structIsEmpty(book.getLoad()),"Check load struct is not empty or is not a struct") />
				
				<!--- load a lazy relation --->
				<cfset authors = book.getAuthorArray() />
		
				<!--- refresh the load Check var--->
				<cfset loadCheck = book.getLoad() />
				
				<cfset assertTrue(not structIsEmpty(loadCheck),"LoadCheck has not been updated from the loading operation. Still empty") />
				<cfset assertTrue(structKeyExists(loadCheck,'authorarray'),"Loadcheck do not show the right label") />
				
				<!--- control that data is not loaded again if no refresh is called --->
				<cfset authorsHash = createObject("java", "java.lang.System").identityHashCode(authors) />
				<cfset reauthors = book.getAuthorArray() />
				<cfset reAuthorsHash = createObject("java", "java.lang.System").identityHashCode(reauthors) />
				
				<cfset assertTrue(authorsHash eq reAuthorsHash,"Array has been reloaded and not cached properly") />
				
				<!--- check data are refreshed --->
				<cfset reauthors = book.getAuthorArray(refresh = true) />
				<cfset reAuthorsHash = createObject("java", "java.lang.System").identityHashCode(reauthors) />
		
				<cfset assertTrue(authorsHash neq reAuthorsHash,"Data has not been refreshed properly") />

				<cfcatch type="any">
					<cftransaction action="rollback"/>
				</cfcatch>			
			
			</cftry>

			<cftransaction action="rollback"/>
		</cftransaction>
			
	</cffunction>
			
</cfcomponent>