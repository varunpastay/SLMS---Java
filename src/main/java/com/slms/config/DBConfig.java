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

            String url  = env("DB_URL",      props.getProperty("jdbcUrl"));
            String user = env("DB_USER",     props.getProperty("dataSource.user"));
            String pass = env("DB_PASSWORD", props.getProperty("dataSource.password"));

            System.out.println("[DBConfig] DB_URL=" + url);
            System.out.println("[DBConfig] DB_USER=" + user);
            System.out.println("[DBConfig] DB_PASSWORD=" + (pass != null ? "***set***" : "NULL"));

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setJdbcUrl(url);
            config.setUsername(user);
            config.setPassword(pass);
            config.setMaximumPoolSize(5);
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);

            dataSource = new HikariDataSource(config);
            System.out.println("[DBConfig] Connection pool initialized successfully");
        } catch (Exception e) {
            System.out.println("[DBConfig] FATAL: " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace(System.out);
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
