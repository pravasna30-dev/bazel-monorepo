package com.acme.arc.dep.test;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class LowOneMainTest {
    private final ByteArrayOutputStream outContent = new ByteArrayOutputStream();
    private final PrintStream originalOut = System.out;

    @BeforeEach
    public void setUpStreams() {
        System.setOut(new PrintStream(outContent));
    }

    @AfterEach
    public void restoreStreams() {
        System.setOut(originalOut);
    }

    @Test
    public void testSay() {
        LowOneMain.say();
        assertEquals("Low-level-1\n", outContent.toString());
    }

    @Test
    public void testMain() {
        LowOneMain.main(new String[]{});
        assertEquals("Low-level-1\n", outContent.toString());
    }
}

