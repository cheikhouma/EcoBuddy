package sn.codiallo.ecoBuddy.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import sn.codiallo.ecoBuddy.dto.ChallengeCompleteRequest;
import sn.codiallo.ecoBuddy.dto.ChallengeCompleteResponse;
import sn.codiallo.ecoBuddy.dto.ChallengeResponse;
import sn.codiallo.ecoBuddy.service.ChallengeService;

import java.util.List;

@RestController
@RequestMapping("/challenges")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class ChallengeController {

    private final ChallengeService challengeService;

    @GetMapping
    public ResponseEntity<?> getAllChallenges() {
        try {
            String username = getCurrentUsername();
            List<ChallengeResponse> challenges = challengeService.getAllChallenges(username);
            return ResponseEntity.ok(challenges);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/complete")
    public ResponseEntity<?> completeChallenge(@Valid @RequestBody ChallengeCompleteRequest request) {
        try {
            String username = getCurrentUsername();
            ChallengeCompleteResponse response = challengeService.completeChallenge(
                    request.getChallengeId(), username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/progress")
    public ResponseEntity<?> updateChallengeProgress(@RequestBody ProgressRequest request) {
        try {
            String username = getCurrentUsername();
            // For now, just return success - implement progress logic later
            return ResponseEntity.ok(new SuccessResponse("Challenge progress updated successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @GetMapping("/completed")
    public ResponseEntity<?> getCompletedChallenges() {
        try {
            String username = getCurrentUsername();
            List<ChallengeResponse> completedChallenges = challengeService.getUserCompletedChallenges(username);
            return ResponseEntity.ok(completedChallenges);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    private String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("User not authenticated");
        }
        return authentication.getName();
    }

    public static class ErrorResponse {
        private String error;

        public ErrorResponse(String error) {
            this.error = error;
        }

        public String getError() {
            return error;
        }

        public void setError(String error) {
            this.error = error;
        }
    }

    public static class SuccessResponse {
        private String message;

        public SuccessResponse(String message) {
            this.message = message;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }

    public static class ProgressRequest {
        private String challengeId;

        public String getChallengeId() {
            return challengeId;
        }

        public void setChallengeId(String challengeId) {
            this.challengeId = challengeId;
        }
    }
}