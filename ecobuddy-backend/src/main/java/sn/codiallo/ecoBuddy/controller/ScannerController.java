package sn.codiallo.ecoBuddy.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import sn.codiallo.ecoBuddy.dto.ScanRequest;
import sn.codiallo.ecoBuddy.dto.ScanResponse;
import sn.codiallo.ecoBuddy.dto.ObjectScanRequest;
import sn.codiallo.ecoBuddy.dto.ObjectScanResponse;
import sn.codiallo.ecoBuddy.model.EcoObject;
import sn.codiallo.ecoBuddy.service.ScannerService;

import java.util.List;

@RestController
@RequestMapping("/scanner")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class ScannerController {

    private final ScannerService scannerService;

    @PostMapping("/object")
    public ResponseEntity<?> scanObject(@Valid @RequestBody ObjectScanRequest request) {
        try {
            String username = getCurrentUsername();
            // Pour AR Scanner : utiliser la méthode simple qui renvoie ScanResponse
            String objectLabel = request.getObjectLabel() != null ? request.getObjectLabel() : "unknown_object";
            ScanResponse response = scannerService.scanObjectForAR(objectLabel, username, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
    
    @PostMapping("/object/legacy")
    public ResponseEntity<?> scanObjectLegacy(@Valid @RequestBody ScanRequest request) {
        try {
            String username = getCurrentUsername();
            ScanResponse response = scannerService.scanObject(request.getName(), username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/scan")
    public ResponseEntity<?> scanGeneric(@RequestBody Object request) {
        try {
            String username = getCurrentUsername();
            // Use default object scan for compatibility
            ScanResponse response = scannerService.scanObject("unknown_object", username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @GetMapping("/history")
    public ResponseEntity<?> getScanHistory() {
        try {
            String username = getCurrentUsername();
            // Return empty list for now - implement scan history in service layer later
            return ResponseEntity.ok(List.of());
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveScanResult(@RequestBody Object scanResult) {
        try {
            String username = getCurrentUsername();
            // For now, just return success - implement save logic later
            return ResponseEntity.ok(new SuccessResponse("Scan result saved successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @PostMapping("/share")
    public ResponseEntity<?> shareScanResult(@RequestBody Object shareRequest) {
        try {
            String username = getCurrentUsername();
            // For now, just return success - implement share logic later
            return ResponseEntity.ok(new SuccessResponse("Scan result shared successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @GetMapping("/objects")
    public ResponseEntity<?> getAllEcoObjects() {
        try {
            List<EcoObject> objects = scannerService.getAllEcoObjects();
            return ResponseEntity.ok(objects);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @GetMapping("/objects/search")
    public ResponseEntity<?> searchEcoObjects(@RequestParam String keyword) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse("Keyword is required"));
            }
            
            List<EcoObject> objects = scannerService.searchEcoObjects(keyword.trim());
            return ResponseEntity.ok(objects);
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
}