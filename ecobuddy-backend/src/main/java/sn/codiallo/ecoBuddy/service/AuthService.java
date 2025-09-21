package sn.codiallo.ecoBuddy.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import sn.codiallo.ecoBuddy.config.JwtUtil;
import sn.codiallo.ecoBuddy.dto.AuthResponse;
import sn.codiallo.ecoBuddy.dto.LoginRequest;
import sn.codiallo.ecoBuddy.dto.SignupRequest;
import sn.codiallo.ecoBuddy.dto.UpdateProfileRequest;
import sn.codiallo.ecoBuddy.dto.UpdateLocationRequest;
import sn.codiallo.ecoBuddy.dto.StoryHistoryResponse;
import sn.codiallo.ecoBuddy.model.Role;
import sn.codiallo.ecoBuddy.model.User;
import sn.codiallo.ecoBuddy.model.StoryHistory;
import sn.codiallo.ecoBuddy.repository.UserRepository;
import sn.codiallo.ecoBuddy.repository.StoryHistoryRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final StoryHistoryRepository storyHistoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username is already taken!");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email is already in use!");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.USER);
        user.setPoints(0);
        user.setAge(request.getAge());

        User savedUser = userRepository.save(user);
        String token = jwtUtil.generateToken(savedUser);

        // For new users, narrative history is empty
        return new AuthResponse(token, savedUser, List.of());
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = jwtUtil.generateToken(user);

        // Load a user's narrative history
        List<StoryHistory> storyHistories = storyHistoryRepository.findByUserOrderByCompletedAtDesc(user);
        List<StoryHistoryResponse> historyResponses = storyHistories.stream()
                .map(StoryHistoryResponse::new)
                .toList();

        return new AuthResponse(token, user, historyResponses);
    }

    public AuthResponse updateProfile(String currentUsername, UpdateProfileRequest request) {
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Vérifier si le nouveau nom d'utilisateur est déjà pris (sauf si c'est le même)
        if (!user.getUsername().equals(request.getUsername()) &&
            userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username is already taken!");
        }

        // Vérifier si le nouvel email est déjà pris (sauf si c'est le même)
        if (!user.getEmail().equals(request.getEmail()) &&
            userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email is already in use!");
        }

        // Mettre à jour les informations
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());

        User updatedUser = userRepository.save(user);

        // Générer un nouveau token avec les nouvelles informations
        String newToken = jwtUtil.generateToken(updatedUser);

        // Load user's narrative history
        List<StoryHistory> storyHistories = storyHistoryRepository.findByUserOrderByCompletedAtDesc(updatedUser);
        List<StoryHistoryResponse> historyResponses = storyHistories.stream()
                .map(StoryHistoryResponse::new)
                .toList();

        return new AuthResponse(newToken, updatedUser, historyResponses);
    }

    public AuthResponse updateLocation(String currentUsername, UpdateLocationRequest request) {
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Mettre à jour les informations de localisation
        user.setCity(request.getCity());
        user.setCountry(request.getCountry());
        user.setRegion(request.getRegion());
        user.setLatitude(request.getLatitude());
        user.setLongitude(request.getLongitude());
        user.setIsLocationCompleted(true);

        User updatedUser = userRepository.save(user);

        // Générer un nouveau token avec les nouvelles informations
        String newToken = jwtUtil.generateToken(updatedUser);

        // Load user's narrative history
        List<StoryHistory> storyHistories = storyHistoryRepository.findByUserOrderByCompletedAtDesc(updatedUser);
        List<StoryHistoryResponse> historyResponses = storyHistories.stream()
                .map(StoryHistoryResponse::new)
                .toList();

        return new AuthResponse(newToken, updatedUser, historyResponses);
    }

    public boolean isLocationCompleted(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return user.getIsLocationCompleted() != null && user.getIsLocationCompleted();
    }
}