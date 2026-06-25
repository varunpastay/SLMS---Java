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
        try {
            Properties props = new Properties();
            InputStream in = DBConfig.class.getResourceAsStream("/db.properties");
            if (in != null) { props.load(in); in.close(); }

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setJdbcUrl(env("DB_URL", props.getProperty("jdbcUrl")));
            config.setUsername(env("DB_USER", props.getProperty("dataSource.user")));
            config.setPassword(env("DB_PASSWORD", props.getProperty("dataSource.password")));
            config.setMaximumPoolSize(Integer.parseInt(env("DB_POOL_MAX", props.getProperty("maximumPoolSize", "5"))));
            config.setMinimumIdle(Integer.parseInt(env("DB_POOL_MIN", props.getProperty("minimumIdle", "1"))));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("connectionTimeout", "30000")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("idleTimeout", "600000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("maxLifetime", "1800000")));

            dataSource = new HikariDataSource(config);
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private static String env(String key, String fallback) {
        String val = System.getenv(key);
        return (val != null && !val.isEmpty()) ? val : fallback;
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    private DBConfig() {}
}
