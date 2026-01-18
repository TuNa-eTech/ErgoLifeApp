# Onboarding Flow - Updated Architecture

## Flow Diagram

```mermaid
flowchart TD
    Start([User Logs In]) --> Check{needsOnboarding?}
    Check -->|Yes houseId=null| Step1[Step 1: Avatar + Name]
    Check -->|No| Home[Home Screen]
    
    Step1 --> SignOut[🚪 Sign Out Button]
    SignOut --> Confirm{Confirm?}
    Confirm -->|Yes| Login[Login Screen]
    Confirm -->|No| Step1
    
    Step1 --> Input{Name Valid?}
    Input -->|No| Error1[Show Error]
    Error1 --> Step1
    
    Input -->|Yes| UpdateProfile[📡 API: Update Profile]
    UpdateProfile -->|Success| Step2[Step 2: Choose Journey]
    UpdateProfile -->|Error| Error2[Show Error + Retry]
    Error2 --> Step1
    UpdateProfile -->|Timeout 30s| Timeout1[Timeout Error]
    Timeout1 --> Step1
    
    Step2 --> Back[◀️ Back Button]
    Back --> Step1
    
    Step2 --> Choice{User Choice?}
    
    Choice -->|Personal Space| Solo[📡 API: Create Solo House]
    Solo -->|Success| Success1[✅ Success Dialog]
    Solo -->|Error| Error3[Show Error]
    Solo -->|Timeout| Timeout2[Timeout Error]
    Error3 --> Step2
    Timeout2 --> Step2
    Success1 --> Home
    
    Choice -->|Family Arena| Arena[Bottom Sheet: House Name]
    Arena --> ValidArena{Name Valid?}
    ValidArena -->|Yes| CreateArena[📡 API: Create Arena]
    ValidArena -->|No| Arena
    CreateArena -->|Success| Success2[✅ Success Dialog]
    CreateArena -->|Error| Error4[Show Error]
    CreateArena -->|Timeout| Timeout3[Timeout Error]
    Error4 --> Step2
    Timeout3 --> Step2
    Success2 --> Home
    
    Choice -->|Join House| Join[Dialog: Enter Code]
    Join --> ValidCode{Code Valid?}
    ValidCode -->|No| JoinError[Invalid Format Error]
    JoinError --> Join
    ValidCode -->|Yes 6 chars A-Z0-9| JoinHouse[📡 API: Join House]
    JoinHouse -->|Success| Success3[✅ Success Dialog]
    JoinHouse -->|Error| Error5[Show Error]
    JoinHouse -->|Timeout| Timeout4[Timeout Error]
    Error5 --> Step2
    Timeout4 --> Step2
    Success3 --> Home
    
    style Start fill:#e1f5e1
    style Home fill:#e1f5e1
    style Login fill:#ffe1e1
    style Step1 fill:#e1f0ff
    style Step2 fill:#e1f0ff
    style UpdateProfile fill:#fff4e1
    style Solo fill:#fff4e1
    style CreateArena fill:#fff4e1
    style JoinHouse fill:#fff4e1
    style Success1 fill:#d4edda
    style Success2 fill:#d4edda
    style Success3 fill:#d4edda
    style Error1 fill:#f8d7da
    style Error2 fill:#f8d7da
    style Error3 fill:#f8d7da
    style Error4 fill:#f8d7da
    style Error5 fill:#f8d7da
    style JoinError fill:#f8d7da
    style Timeout1 fill:#fff3cd
    style Timeout2 fill:#fff3cd
    style Timeout3 fill:#fff3cd
    style Timeout4 fill:#fff3cd
```

## API Call Sequence

### Before Improvements
```
Solo Path:
└─ PUT /users/me (profile)
└─ POST /houses (create)

Arena Path:
└─ PUT /users/me (profile) ← DUPLICATE
└─ POST /houses (create)

Join Path:
└─ PUT /users/me (profile) ← DUPLICATE
└─ POST /houses/join (join)
```

### After Improvements
```
Step 1 → Step 2:
└─ PUT /users/me (profile) ← ONCE

Solo Path:
└─ POST /houses (create)

Arena Path:
└─ POST /houses (create)

Join Path:
└─ POST /houses/join (join)
```

**Result:** 33% fewer API calls! 🎉

## State Flow

```mermaid
stateDiagram-v2
    [*] --> OnboardingInitial
    OnboardingInitial --> OnboardingLoading : UpdateProfile event
    OnboardingLoading --> OnboardingProfileUpdated : Profile updated
    OnboardingLoading --> OnboardingError : Profile update failed
    OnboardingLoading --> OnboardingError : Timeout (30s)
    
    OnboardingProfileUpdated --> OnboardingLoading : House event
    OnboardingLoading --> OnboardingSuccess : House created/joined
    OnboardingLoading --> OnboardingError : House operation failed
    OnboardingLoading --> OnboardingError : Timeout (30s)
    
    OnboardingError --> OnboardingLoading : User retries
    OnboardingSuccess --> [*] : Navigate to Home
    
    style OnboardingProfileUpdated fill:#d4edda
    style OnboardingSuccess fill:#d4edda
    style OnboardingError fill:#f8d7da
```

## Event Flow

```mermaid
sequenceDiagram
    participant UI as Onboarding Screen
    participant Bloc as OnboardingBloc
    participant UserRepo as UserRepository
    participant HouseRepo as HouseRepository
    
    Note over UI: Step 1: User fills name
    UI->>UI: Tap "Continue"
    UI->>Bloc: UpdateProfile(name, avatarId)
    Bloc->>UserRepo: updateProfile(name, avatarId)
    UserRepo-->>Bloc: Success / Error
    alt Success
        Bloc->>UI: OnboardingProfileUpdated
        UI->>UI: Navigate to Step 2
    else Error
        Bloc->>UI: OnboardingError(message)
        UI->>UI: Show error snackbar
    else Timeout
        Bloc->>UI: OnboardingError("Timeout...")
        UI->>UI: Show timeout message
    end
    
    Note over UI: Step 2: User chooses option
    alt Solo House
        UI->>Bloc: CreateSoloHouse(houseName)
    else Arena House
        UI->>Bloc: CreateArenaHouse(houseName)
    else Join House
        UI->>Bloc: JoinHouse(code)
    end
    
    alt Create House
        Bloc->>HouseRepo: createHouse(name)
    else Join House
        Bloc->>HouseRepo: joinHouse(code)
    end
    
    HouseRepo-->>Bloc: Success / Error
    alt Success
        Bloc->>UI: OnboardingSuccess(message)
        UI->>UI: Show success dialog
        UI->>UI: Navigate to Home (1.5s)
    else Error
        Bloc->>UI: OnboardingError(message)
        UI->>UI: Show error snackbar
    end
```

## Validation Flow

### Join Code Validation
```mermaid
flowchart LR
    Input[User Types] --> Check{Length = 6?}
    Check -->|No| Invalid1[Invalid]
    Check -->|Yes| Regex{Match A-Z0-9?}
    Regex -->|No| Invalid2[Invalid]
    Regex -->|Yes| Valid[✓ Valid]
    
    Invalid1 --> Disable[Disable Join Button]
    Invalid2 --> Disable
    Valid --> Enable[Enable Join Button]
    Valid --> Icon[Show ✓ Icon]
    Invalid2 --> Error[Show Error Text]
    
    style Valid fill:#d4edda
    style Enable fill:#d4edda
    style Icon fill:#d4edda
    style Invalid1 fill:#f8d7da
    style Invalid2 fill:#f8d7da
    style Disable fill:#f8d7da
    style Error fill:#f8d7da
```

### Name Validation
```
Input → Trim → Empty? → Invalid
                  ↓
                Not Empty → Valid → Enable Continue
```

## UI Component Tree

```
OnboardingScreen
├── BlocProvider (OnboardingBloc)
├── BlocConsumer
│   ├── Listener
│   │   ├── OnboardingProfileUpdated → Navigate to Step 2
│   │   ├── OnboardingSuccess → Success Dialog
│   │   └── OnboardingError → Error SnackBar
│   └── Builder
│       └── Scaffold
│           └── SafeArea
│               └── Stack
│                   ├── Column
│                   │   ├── Header Row
│                   │   │   ├── Sign Out / Back Button ← NEW
│                   │   │   ├── Step Indicators
│                   │   │   └── Step Counter
│                   │   ├── PageView (2 pages)
│                   │   │   ├── Page 1: Avatar + Name
│                   │   │   │   ├── Avatar Carousel
│                   │   │   │   ├── Name Input
│                   │   │   │   └── Skip Avatar Button ← NEW
│                   │   │   └── Page 2: Create Space
│                   │   │       ├── Personal Space Card
│                   │   │       ├── Divider
│                   │   │       ├── Family Arena Card
│                   │   │       └── Join Code Button
│                   │   └── Footer Space
│                   └── Positioned (Footer Button Step 1)
│                       └── Continue Button
└── Dialogs/Sheets
    ├── Sign Out Confirmation ← NEW
    ├── Arena Bottom Sheet
    ├── Join Code Dialog (Enhanced) ← IMPROVED
    └── Success Dialog
```

## Feature Matrix

| Feature | Step 1 | Step 2 |
|---------|--------|--------|
| **Navigation** | Sign Out, Continue | Back, Solo, Arena, Join |
| **Validation** | Name required | House name / code required |
| **API Calls** | Update Profile | Create/Join House |
| **Skip Option** | ✅ Skip Avatar | N/A |
| **Timeout** | ✅ 30s | ✅ 30s |
| **Error Recovery** | ✅ Retry | ✅ Retry |
| **Loading State** | ✅ Spinner | ✅ Spinner + Overlay |

## Error Scenarios

| Scenario | Timeout | Retry | Error Message |
|----------|---------|-------|---------------|
| **Network Timeout** | 30s | ✅ Yes | "Request timed out. Please check..." |
| **Invalid Join Code** | N/A | ✅ Yes | "Code must be 6 characters (A-Z, 0-9)" |
| **Profile Update Failed** | 30s | ✅ Yes | Failure message from API |
| **House Create Failed** | 30s | ✅ Yes | Failure message from API |
| **Already Has House (409)** | 30s | N/A | Treated as success |
| **Empty Name** | N/A | N/A | "Vui lòng nhập tên hiển thị" |
| **Profile Not Updated** | N/A | N/A | "Please complete your profile first" |

---

**Legend:**
- 🚪 Sign Out Button (NEW)
- ◀️ Back Button
- 📡 API Call (with timeout)
- ✅ Success
- ❌ Error

**Color Coding:**
- 🟢 Green: Success states
- 🔵 Blue: Main flow
- 🟡 Yellow: Timeout/Warning
- 🔴 Red: Error states
