package com.slms.util;

import org.mindrot.jbcrypt.BCrypt;

public class HashGen {
    public static void main(String[] args) {
        String password = args.length > 0 ? args[0] : "Admin@123";
        String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
        System.out.println("Hash for [" + password + "]:");
        System.out.println(hash);
        System.out.println("Verified: " + BCrypt.checkpw(password, hash));
    }
}
