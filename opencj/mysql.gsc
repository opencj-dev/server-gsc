#include openCJ\util;

onInit()
{
	level.database = [];
	level.database["host"] = getCvar("db_host");
	level.database["user"] = getCvar("db_user");;
	level.database["pass"] = getCvar("db_pass");
	level.database["port"] = int(getCvar("db_port"));
	level.database["name"] = getCvar("db_base") + getCvar("codversion");
	//printf("Got db info: " + level.database["host"] + "," + level.database["user"] + "," + "<censored>" + "," + level.database["port"] + "," + level.database["name"] + "\n");

	level.mySQL = mysql_reuse_connection();
	if(!isDefined(level.mySQL))
	{
		level.mySQL = mysql_init();
		ret = mysql_real_connect(level.mySQL, level.database["host"], level.database["user"], level.database["pass"], level.database["name"], level.database["port"]);
		if(!ret)
		{
			printf("errno=" + mysql_errno(level.mySQL) + " error= " + mysql_error(level.mySQL) + "\n");
			mysql_close(level.mySQL);
			return;
		}
	}
	thread _asyncMySQL();
}

_asyncMySQL()
{
	mysql_async_initializer(level.database["host"], level.database["user"], level.database["pass"], level.database["name"], level.database["port"], 4);
	while(true)
	{
		list = mysql_async_getdone_list();
		for(i = 0; i < list.size; i++)
		{
			result = mysql_async_getresult_and_free(list[i]);
			rows = _getRowsAndFree(result);
			level notify("mysqlQueryDone" + list[i], rows);
		}
		wait 0.05;
	}
}

mysqlSyncQuery(query)
{
	//printf("mysql: " + level.mySQL + "\n");
	//printf("Doing query: "  + query + "\n");
	ret = mysql_query(level.mySQL, query);
	if(!ret)
	{
		result = mysql_store_result(level.mySQL);
		//printf("got result: " + result + "\n");
		rows = _getRowsAndFree(result);
		return rows;
	}
	return undefined;
}

_getRowsAndFree(result)
{
	//printf("starting getrowsandfree\n");
	rows = [];
	if(!isDefined(result) || result == 0)
		return rows;
	//printf("getting rowcount for result " + result + " \n");
	rowcount = mysql_num_rows(result);
	//printf("rowcount: " + rowcount + "\n");
	for(i = 0; i < rowcount; i++)
	{
		//printf("getting a row\n");
		row = mysql_fetch_row(result);
		rows[rows.size] = row;
	}
	//printf("done getting rows, freeing now\n");
	mysql_free_result(result);
	//printf("freeing done\n");
	return rows;
}

mysqlAsyncQuery(query)
{
	if(isPlayer(self))
		self endon("disconnect");
	//printf("Adding async query: " + query + "\n");
	id = mysql_async_create_query(query);
	level waittill("mysqlQueryDone" + id, rows);
	return rows;
}

mysqlAsyncQueryNosave(query)
{
	if(isPlayer(self))
		self endon("disconnect");
	//printf("Adding async query nosave: " + query + "\n");
	id = mysql_async_create_query_nosave(query);
	level waittill("mysqlQueryDone" + id);
}

escapeString(string)
{
	return mysql_real_escape_string(level.mysql, string);
}
