package com.slms.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBConfig {

    private static final HikariDataSource dataSource;

    static {
        try (InputStream in = DBConfig.class.getResourceAsStream("/db.properties")) {
            Properties props = new Properties();
            props.load(in);

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setJdbcUrl(props.getProperty("jdbcUrl"));
            config.setUsername(props.getProperty("dataSource.user"));
            config.setPassword(props.getProperty("dataSource.password"));
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("minimumIdle", "2")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("connectionTimeout", "30000")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("idleTimeout", "600000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("maxLifetime", "1800000")));

            dataSource = new HikariDataSource(config);
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    private DBConfig() {}
}
