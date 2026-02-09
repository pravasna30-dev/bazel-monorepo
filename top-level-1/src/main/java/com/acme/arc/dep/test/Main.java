package com.acme.arc.dep.test;

public class Main {
    public static void main(String[] args) {
        say();
        LowOneMain.say();
    }

    public static void say() {
        System.out.println("Top-level-1");
    }
}

