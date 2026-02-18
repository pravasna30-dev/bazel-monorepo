package com.example.library;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class UserServiceTest {

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService();
    }

    @Test
    void findByIdReturnsExistingUser() {
        User user = userService.findById(1L);
        assertNotNull(user);
        assertEquals(1L, user.getId());
        assertEquals("john.doe@example.com", user.getEmail());
    }

    @Test
    void findByIdReturnsNullForMissing() {
        User user = userService.findById(999L);
        assertNull(user);
    }

    @Test
    void findAllReturnsAllUsers() {
        assertEquals(2, userService.findAll().size());
    }

    @Test
    void createUserAddsNewUser() {
        User user = userService.createUser("test@example.com", "Test User");
        assertNotNull(user);
        assertNotNull(user.getId());
        assertEquals("test@example.com", user.getEmail());
    }
}
