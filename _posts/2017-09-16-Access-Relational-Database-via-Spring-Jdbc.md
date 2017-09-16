---
layout: post
title: Access Relational Database via Spring Jdbc
author: Ray Cai
date: September 16, 2017
---

## Abstract
Explain how to access rational database via [spring-jdbc](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/jdbc.html).

## Who NOT JPA?
Data model is not **normalized**, or only satisfy low **normal form**.

## Pooling Database Connection
* Only use `javax.sql.DataSource` as the interface of database connection pool. **MUST NOT** use any other interface. Almost all database connection library is providing `DataSource`.
* Only use existed database connection pool implementation, open sourced and commercial. Do not invent wheel again.

## Obtaining/Releasing Resources
Database related resources (Connection, Statement, ResultSet), are linking to actual resources located on database management system. For increasing resource utilization, it MUST release resource promptly.

Java 7 has introduced the try-with-resources statement, it will automatically close resources which declared in with clause when left try block.
```java
final String sql = "SELECT * FROM DUAL WHERE ID =?";
try(Connection conn = dataSource.getConnection();
    PreparedStatement pstmt = conn.prepareStatement(sql)){
    pstmt.setLong(1,id);
    try(ResultSet resultSet = pstmt.executeQuery()){
        while(resultSet.next()){
            ...
        }
    }
}
```
`spring-jdbc` offers template class to simplify resources obtaining and releasing. `spring-jdbc` primarily offers:
```java
org.springframework.jdbc.core.JdbcTemplate
org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate
```

`org.springframework.jdbc.core.JdbcTemplate` will handle resources (Connection,Statement,ResultSet) obtaining and releasing.

```
org.springframework.jdbc.core.JdbcTemplate.execute(StatementCallback<T> action)
```
```java
	@Override
	public <T> T execute(StatementCallback<T> action) throws DataAccessException {
		Assert.notNull(action, "Callback object must not be null");

		Connection con = DataSourceUtils.getConnection(getDataSource());
		Statement stmt = null;
		try {
			Connection conToUse = con;
			if (this.nativeJdbcExtractor != null &&
					this.nativeJdbcExtractor.isNativeConnectionNecessaryForNativeStatements()) {
				conToUse = this.nativeJdbcExtractor.getNativeConnection(con);
			}
			stmt = conToUse.createStatement();
			applyStatementSettings(stmt);
			Statement stmtToUse = stmt;
			if (this.nativeJdbcExtractor != null) {
				stmtToUse = this.nativeJdbcExtractor.getNativeStatement(stmt);
			}
			T result = action.doInStatement(stmtToUse);
			handleWarnings(stmt);
			return result;
		}
		catch (SQLException ex) {
			// Release Connection early, to avoid potential connection pool deadlock
			// in the case when the exception translator hasn't been initialized yet.
			JdbcUtils.closeStatement(stmt);
			stmt = null;
			DataSourceUtils.releaseConnection(con, getDataSource());
			con = null;
			throw getExceptionTranslator().translate("StatementCallback", getSql(action), ex);
		}
		finally {
			JdbcUtils.closeStatement(stmt);
			DataSourceUtils.releaseConnection(con, getDataSource());
		}
	}
```

`NamedParameterJdbcTemplate` is extended from JdbcTemplate, therefore it will handle resources obtaining/releasing automatically too.

### Populating Placeholder of PreparedStatement

`JdbcTemplate` supports SQL statement with question mark `?` as placeholder, and populate these placeholder by index. Over time, SQL statement will be changed, amount and order of placeholder will be changed. Developer has to adjust all placeholder population code once placeholder order changed.
`NamedParameterJdbcTemplate` support SQL statement with placeholder likes `:name`. Compared to `JdbcTemplate`, because it is addressing target placeholder by name, therefore one placeholder changed would not impact all placeholder population code. It avoids extra code changes when change SQL statement, especially when SQL statement contains a lot of placeholder.

## Fetch ResultSet

**Doing more than relation object mapping lead to chaos.**

`RowMapper` is designed to only map relation model to object.
```java
public interface RowMapper<T> {

	/**
	 * Implementations must implement this method to map each row of data
	 * in the ResultSet. This method should not call {@code next()} on
	 * the ResultSet; it is only supposed to map values of the current row.
	 * @param rs the ResultSet to map (pre-initialized for the current row)
	 * @param rowNum the number of the current row
	 * @return the result object for the current row
	 * @throws SQLException if a SQLException is encountered getting
	 * column values (that is, there's no need to catch SQLException)
	 */
	T mapRow(ResultSet rs, int rowNum) throws SQLException;

}
```

## Reference
1. [Database Normalization](https://en.wikipedia.org/wiki/Database_normalization)

## More Reading