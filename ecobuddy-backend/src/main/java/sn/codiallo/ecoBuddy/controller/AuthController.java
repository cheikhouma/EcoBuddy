package sn.codiallo.ecoBuddy.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import sn.codiallo.ecoBuddy.dto.AuthResponse;
import sn.codiallo.ecoBuddy.dto.LoginRequest;
import sn.codiallo.ecoBuddy.dto.SignupRequest;
import sn.codiallo.ecoBuddy.dto.UpdateProfileRequest;
import sn.codiallo.ecoBuddy.dto.UpdateLocationRequest;
import sn.codiallo.ecoBuddy.service.AuthService;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signupRequest) {
        try {
            AuthResponse response = authService.signup(signupRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse response = authService.login(loginRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new MessageResponse("Invalid username or password"));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@Valid @RequestBody UpdateProfileRequest updateRequest, 
                                          Authentication authentication) {
        try {
            String username = authentication.getName();
            AuthResponse response = authService.updateProfile(username, updateRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse(e.getMessage()));
        }
    }

    @PutMapping("/location")
    public ResponseEntity<?> updateLocation(@Valid @RequestBody UpdateLocationRequest locationRequest, 
                                           Authentication authentication) {
        try {
            String username = authentication.getName();
            AuthResponse response = authService.updateLocation(username, locationRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse(e.getMessage()));
        }
    }

    @GetMapping("/location-status")
    public ResponseEntity<?> getLocationStatus(Authentication authentication) {
        try {
            String username = authentication.getName();
            boolean isCompleted = authService.isLocationCompleted(username);
            return ResponseEntity.ok(new LocationStatusResponse(isCompleted));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse(e.getMessage()));
        }
    }

    public static class MessageResponse {
        private String message;

        public MessageResponse(String message) {
            this.message = message;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }

    public static class LocationStatusResponse {
        private boolean isLocationCompleted;

        public LocationStatusResponse(boolean isLocationCompleted) {
            this.isLocationCompleted = isLocationCompleted;
        }

        public boolean isLocationCompleted() {
            return isLocationCompleted;
        }

        public void setLocationCompleted(boolean locationCompleted) {
            isLocationCompleted = locationCompleted;
        }
    }
}