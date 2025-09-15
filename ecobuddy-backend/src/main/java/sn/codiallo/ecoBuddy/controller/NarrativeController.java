package sn.codiallo.ecoBuddy.controller;

import jakarta.validation.Valid;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import sn.codiallo.ecoBuddy.dto.NarrativeChoiceRequest;
import sn.codiallo.ecoBuddy.dto.NarrativeChoiceResponse;
import sn.codiallo.ecoBuddy.dto.NarrativeStartResponse;
import sn.codiallo.ecoBuddy.service.NarrativeService;

@RestController
@RequestMapping("/narration")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class NarrativeController {

    private final NarrativeService narrativeService;

    @GetMapping("/start")
    public ResponseEntity<?> startNarrative() {
        try {
            String username = getCurrentUsername();
            NarrativeStartResponse response = narrativeService.startNarrative(username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(@Valid @RequestBody NarrativeChoiceRequest request) {
        try {
            String username = getCurrentUsername();
            NarrativeChoiceResponse response = narrativeService.processChoice(
                    request.getSessionId(),
                    request.getChoice(),
                    username
            );
            return ResponseEntity.ok(response);
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

    @Setter
    @Getter
    public static class ErrorResponse {
        private String error;

        public ErrorResponse(String error) {
            this.error = error;
        }

    }
}