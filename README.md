# HomeHub - Outstanding Tasks & Roadmap (TODO.md)

This document tracks completed features and pending tasks for the **HomeHub** real estate app (Flutter frontend + Go backend).

---

## 🟢 Completed So Far ([x])

### Frontend (Flutter)

- [x] **Core Architecture**: `MultiProvider` state management (`AppThemeProvider`, `PropertyProvider`, `BookingProvider`, `UserProvider`, `ChatProvider`).
- [x] **Design System**: Light & Dark mode themes (`AppTheme`), custom glassmorphism (`GlassContainer`), badge chips, and custom icons.
- [x] **Authentication Flow**: Login, Register, Onboarding, and Splash screens with strict navigation auth guards.
- [x] **Property Search & Filtering**: Multi-criteria property filter drawer (city, LGA, price range, property type, bedrooms) with list and map views.
- [x] **Property & City Views**: Detailed property listing screen with image carousels, landlord info, amenity badges, and city stats screen.
- [x] **User Profile Management**: Edit profile screen, photo avatar selector (`image_picker`), profile completeness progress bar, password updates, and email OTP verification modal.
- [x] **Inspection & Booking UI**: Inspection modal for scheduling property viewings and Bookings tab screen.
- [x] **e-Sign & Escrow UI Modal**: Step-by-step modal for signing digital tenancy agreements and reviewing escrow terms.
- [x] **Local Fallbacks**: Integration with live API endpoints. Rich local `MockData` seeds the Bookings and Chat providers; note that `PropertyProvider` does **not** currently fall back to mock data on API failure (see High Priority TODOs).

### Backend (Go / Fiber API)

- [x] **JWT Authentication**: Login, Register, Logout, Token Refresh, and Auth middleware (access token 1h, refresh 30d; accepts `Authorization` header, `access` cookie, and `?token=` query for mobile/WS).
- [x] **User Management**: Public/protected user profile routes, avatar upload (Cloudinary), and account deactivation.
- [x] **Listings API**: Public search & filtering by location/type, location stats, public stats, landlord stats, image upload endpoints, and lead interaction tracking (`POST /listings/:id/interact` → VIEW / WHATSAPP_CLICK).
- [x] **Chat API & WebSockets**: Conversation routes, message retrieval, mark as read, unread count, and Fiber WebSocket hub (`/api/messages/ws`) with typing indicators and in-app phone/social-link content filtering.
- [x] **Bookmarks & Admin**: Toggle bookmarks, admin stats, user status/role management, verify listings, and toggle featured property flags.
- [x] **Google OAuth Verification**: Real Google ID-token verification against Google's tokeninfo API implemented in [`google_verify.go`](file:///home/chrisdev/Desktop/homehub-app/backend/utils/google_verify.go) (validates `aud` + `email_verified`).
- [x] **Email OTP Delivery**: 6-digit OTP (crypto/rand) for email verification and password reset, delivered via Resend → Brevo → SMTP fallback ([`email.go`](file:///home/chrisdev/Desktop/homehub-app/backend/utils/email.go)). ⚠️ Falls back to logging only when no provider is configured, and currently logs the OTP to stdout in plaintext (remove before production).

---

## 🟡 High Priority TODOs ([ ])

### 1. Frontend Integration & Enhancements (Flutter)

- [ ] **Live API Integration for Landlord Property Creation**:
  - Connect [`AddPropertyModal`](file:///home/chrisdev/Desktop/homehub-app/lib/widgets/add_property_modal.dart) directly to `POST /api/listings` and `POST /api/listings/upload-images` instead of local state mutation only. Currently builds an in-memory `Property` with a hardcoded Unsplash placeholder image and never POSTs.
- [x] **Live Bookmarks / Favorites Persistence**:
  - Wired [`PropertyProvider.toggleFavorite`](file:///home/chrisdev/Desktop/homehub-app/lib/providers/property_provider.dart) to `POST /api/listings/bookmark/:id` (optimistic flip + revert on failure, reconciles with the server's `bookmarked` flag). Saved state loaded via `GET /api/listings/bookmark/all` in `fetchBookmarksFromApi()`, triggered after listings load (returning users) and after login.
- [ ] **Live Chat / Messaging Integration (currently 100% mock)**:
  - [`ChatProvider`](file:///home/chrisdev/Desktop/homehub-app/lib/providers/chat_provider.dart) is entirely local — it seeds from `MockData` and replies with a scripted keyword bot (`_simulateAgentResponse`). The backend + web app already have full realtime chat. Wire the REST endpoints (`GET/POST /api/messages/conversations`, `/conversations/:id`, `/conversations/:id/read`, `/messages/unread-count`) **and** the live WebSocket listener (`/api/messages/ws`, token via `?token=`) for push messages, typing indicators, and read receipts. **← highest-value parity gap.**
- [ ] **Live API Integration for Bookings**:
  - Connect [`BookingProvider`](file:///home/chrisdev/Desktop/homehub-app/lib/providers/booking_provider.dart) to real backend REST endpoints for creating and updating inspection bookings. NOTE: these endpoints do not exist on the backend yet (see §2) — backend work is a prerequisite.
- [ ] **Lead Interaction Tracking**:
  - Call `POST /api/listings/:id/interact` from [`PropertyDetailScreen`](file:///home/chrisdev/Desktop/homehub-app/lib/screens/property_detail_screen.dart) on property view and on "Chat/Contact on WhatsApp" taps (VIEW / WHATSAPP_CLICK) to feed landlord lead stats. Web already does this; mobile does not.
- [ ] **Landlord Dashboard (mobile)**:
  - Add a landlord property-management surface backed by `GET /api/listings/landlord` and `GET /api/listings/landlord/stats` (parity with the web landlord dashboard). Not present in the Flutter app.
- [ ] **Admin Surfaces (mobile, optional)**:
  - The backend exposes admin stats, user management, listing verification and feature-toggle (`/api/admin/*`); no mobile screens consume these. Decide whether admin stays web-only.
- [ ] **Google Sign-In Integration**:
  - Integrate native Google Sign-In SDK on Android & iOS to send idTokens to backend `POST /api/auth/google`. Backend verification is already complete.
- [ ] **Extract an API/Service Layer**:
  - There is no `services/` or repository abstraction — `http` calls are inlined in `user_provider.dart` and `property_provider.dart`, and `baseUrl` is duplicated across both providers **and** [`property_model.dart`](file:///home/chrisdev/Desktop/homehub-app/lib/models/property_model.dart). Centralize into a single API client with shared auth headers + 401-refresh handling.
- [ ] **Environment Configuration**:
  - Replace the hardcoded/triplicated `baseUrl` (`https://rentalhub-api-0kuk.onrender.com/api`) with `.env` / `String.fromEnvironment` configuration for switching between Local (`localhost:8080`), Staging, and Production API URLs.
- [ ] **Fix Misleading Offline Fallback**:
  - On API failure `PropertyProvider` sets `_apiError` and shows a "cached listings" message but actually renders an **empty** list — it never falls back to `MockData`. Either implement a real local cache/`MockData` fallback or correct the messaging.
- [ ] **Persist Theme Preference**:
  - `AppThemeProvider` defaults to light and does not persist the user's dark-mode choice to `shared_preferences`, so it resets on every launch.

### 2. Backend Features & Endpoints (Go API)

- [ ] **Inspection Bookings Controller**:
  - Implement `/api/bookings` endpoints (Create booking, list tenant bookings, list landlord bookings, update booking status: confirmed/cancelled). No booking model, route, or controller exists yet — this blocks the mobile bookings integration in §1.
- [x] **Google Auth Token Verification** _(already implemented)_:
  - Real Google ID-token validation against Google's tokeninfo API is complete in `GoogleAuth` / [`google_verify.go`](file:///home/chrisdev/Desktop/homehub-app/backend/utils/google_verify.go).
- [x] **Email OTP Delivery** _(already implemented)_:
  - Email OTP delivery works via Resend → Brevo → SMTP fallback in [`email.go`](file:///home/chrisdev/Desktop/homehub-app/backend/utils/email.go). Remaining hardening: remove the plaintext OTP stdout log and ensure a provider is configured in production.
- [ ] **SMS OTP Delivery (Nigeria)**:
  - There is currently **no SMS/phone OTP** channel — delivery is email-only. Integrate an SMS provider (e.g. Termii, Twilio) for phone verification, which is expected for the Nigerian market.
- [ ] **Landlord Stats — real metrics**:
  - `GetLandlordStats` returns hardcoded stubs: `totalViews: 0` and `occupancyRate: 0` ([`landlord_controller.go:67-68`](file:///home/chrisdev/Desktop/homehub-app/backend/controllers/landlord_controller.go)). Implement real view tracking (aggregate from `LeadLog`) and occupancy/rental-status tracking.
- [ ] **Role Model Consistency**:
  - Register accepts arbitrary `type` and creates a landlord profile for `agent` OR `landlord`, but landlord routes gate on role `agent` only, and Google-created users default to `user`. Reconcile the tenant/agent/landlord/admin role vocabulary across register, middleware, and route guards.
- [ ] **Remove Unused NextAuth/Prisma Carryover Models**:
  - `Account`, `Session`, and `VerificationToken` are migrated but referenced by no Go handler. Drop them (or document why they're retained).
- [ ] **Lease & Escrow Data Persistence**:
  - Add GORM models and controllers for persisting signed lease agreements and escrow payment records. `Properties.lease_term` is a bare string today; there is no Lease/Tenancy model tying a tenant to a property.

### 3. Payment Gateway & Escrow Integration

- [ ] **Paystack / Flutterwave Integration**:
  - Integrate Paystack API for collecting security deposits and rent into escrow accounts directly from the app.
- [ ] **Payment Verification Webhooks**:
  - Add backend webhook listener (`POST /api/payments/webhook`) to handle payment success/failure notifications asynchronously.

---

## 🔵 Medium & Low Priority TODOs

### 4. Push Notifications & User Experience

- [ ] **Firebase Cloud Messaging (FCM)**:
  - Add FCM support for mobile push notifications (new chat messages, inspection booking updates, lease status changes).
- [ ] **Offline Caching & State Persistence**:
  - Cache property search queries and user bookmarks locally via Hive or SQLite for full offline browsing.

### 5. Mobile & Platform Release Configuration

- [ ] **Android Package Configuration**:
  - Update `applicationId` in `android/app/build.gradle.kts` and configure release signing configs.
- [ ] **iOS Permissions & Provisioning**:
  - Add `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSLocationWhenInUseUsageDescription` keys in `ios/Runner/Info.plist`.
- [ ] **App Store Assets & Icons**:
  - Replace default Flutter app icon and splash screens with branded HomeHub assets.

### 6. Testing, CI/CD & Deployment

- [ ] **Flutter Widget & Integration Tests**:
  - Add automated widget tests for key screens (`HomeScreen`, `PropertyDetailScreen`, `LoginScreen`).
- [ ] **Go API Unit & Integration Tests**:
  - Expand test suites under `backend/tests` covering auth, listing creation, and chat endpoints.
- [ ] **CI/CD Pipeline**:
  - Setup GitHub Actions workflow for linting, building Flutter APKs/web bundles, and running Go tests on PRs.
