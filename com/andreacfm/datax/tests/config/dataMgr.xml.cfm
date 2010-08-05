<?xml version="1.0" encoding="UTF-8"?>
<tables xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.bryantwebconsulting.com/cfcs/DataMgr_25.xsd">
    
    <table name="book" introspect="true">
		<field ColumnName="bookid" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
		<field ColumnName="bookname" CF_DataType="CF_SQL_VARCHAR" />

        <field ColumnName="createon" special="CreationDate" CF_DataType="CF_SQL_DATE"/>
		<field ColumnName="updateon" special="LastUpdatedDate" CF_DataType="CF_SQL_DATE"/>
        <field ColumnName="sort" special="Sorter" CF_DataType="CF_SQL_INTEGER"/>        

        <field ColumnName="authorList">
            <relation          
                type="list"          
                table="author"          
                field="authorId"          
                join-table="book_author"
            />
        </field>
    </table> 
	
	<table name="book_author">
		<field ColumnName="book_author_id" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true"/>
		<field ColumnName="bookid" CF_DataType="CF_SQL_INTEGER" />
		<field ColumnName="authorid" CF_DataType="CF_SQL_INTEGER"/>		
	</table>
    
    <table name="author" introspect="true">
		<field ColumnName="authorid" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
		<field ColumnName="authorname" CF_DataType="CF_SQL_VARCHAR" />

        <field ColumnName="createon" special="CreationDate" CF_DataType="CF_SQL_DATE"/>
		<field ColumnName="updateon" special="LastUpdatedDate" CF_DataType="CF_SQL_DATE"/>
        <field ColumnName="sort" special="Sorter" CF_DataType="CF_SQL_INTEGER"/>        

        <field ColumnName="bookList">
            <relation          
                type="list"          
                table="book"          
                field="bookId"          
                join-table="book_author"          
            />
        </field>
    </table>
    
</tables>