# Backend Test Scenarios

## Test Categories

### Unit Tests
Test từng service riêng lẻ với mock dependencies (PrismaService, JwtService, FirebaseService).

### E2E Tests
Test luồng hoàn chỉnh từ HTTP request đến database (future).

---

## Auth Module

### AuthService.socialLogin

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid Firebase token - new user | Valid idToken | Create user, return JWT + isNewUser=true |
| 2 | Valid Firebase token - existing user | Valid idToken | Return JWT + isNewUser=false |
| 3 | Invalid Firebase token | Invalid idToken | Throw UnauthorizedException |
| 4 | Firebase service unavailable | Any token | Throw InternalServerErrorException |

### AuthService.getMe

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid user ID | Existing userId | Return UserDto with house info |
| 2 | User not found | Non-existent userId | Throw UnauthorizedException |

### AuthService.logout

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid logout | userId | Clear FCM token, return success message |

---

## Users Module

### UsersService.updateProfile

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Update displayName only | {displayName: "New Name"} | Updated user |
| 2 | Update avatarId only | {avatarId: 5} | Updated user |
| 3 | Update both fields | {displayName, avatarId} | Updated user |
| 4 | Invalid avatarId (>20) | {avatarId: 25} | Validation error |

### UsersService.getUserById

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Same house | currentUser in houseA, targetUser in houseA | Return OtherUserDto |
| 2 | Different house | currentUser in houseA, targetUser in houseB | Throw ForbiddenException |
| 3 | User not in house | currentUser has no house | Throw ForbiddenException |
| 4 | Target user not found | Non-existent targetUserId | Throw NotFoundException |

---

## Houses Module

### HousesService.create

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | User without house | {name: "My House"} | Create house, user becomes member |
| 2 | User already in house | {name: "New House"} | Throw ConflictException (ALREADY_IN_HOUSE) |

### HousesService.join

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid invite code, space available | Valid inviteCode | Join house, return HouseDto |
| 2 | Invalid invite code | "invalid123" | Throw NotFoundException (INVALID_INVITE) |
| 3 | House is full (4 members) | Valid inviteCode | Throw ConflictException (HOUSE_FULL) |
| 4 | User already in another house | Valid inviteCode | Throw ConflictException (ALREADY_IN_HOUSE) |

### HousesService.leave

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Not last member | userId | Remove from house, reset wallet |
| 2 | Last member | userId | Delete house and all data |
| 3 | User not in house | userId with no house | Throw NotFoundException |

---

## Activities Module

### ActivitiesService.create

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid activity, no bonus | magicWipe=80% | Points = basePoints × 1.0 |
| 2 | Valid activity, with bonus | magicWipe=95% | Points = basePoints × 1.1 |
| 3 | User not in house | Any input | Throw ForbiddenException |
| 4 | Invalid duration (<60s) | duration=30 | Validation error |

### ActivitiesService.getLeaderboard

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Current week | No week param | Rankings for current week |
| 2 | Specific week | week="2025-W51" | Rankings for that week |
| 3 | User not in house | Any input | Throw ForbiddenException |

---

## Rewards Module

### RewardsService.create

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid reward | {title, cost, icon} | Created RewardDto |
| 2 | User not in house | Any input | Throw ForbiddenException |
| 3 | Cost < 100 | {cost: 50} | Validation error |

### RewardsService.redeem

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Sufficient balance | User has 2000, reward costs 1000 | Deduct points, create redemption |
| 2 | Insufficient balance | User has 500, reward costs 1000 | Throw BadRequestException (INSUFFICIENT_BALANCE) |
| 3 | Reward not found | Non-existent rewardId | Throw NotFoundException |
| 4 | Reward not active | Deleted reward | Throw NotFoundException |

### RewardsService.update/remove

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Creator updates | Creator userId | Updated reward |
| 2 | House owner updates | House owner userId | Updated reward |
| 3 | Other member updates | Other member userId | Throw ForbiddenException |

---

## Redemptions Module

### RedemptionsService.markAsUsed

| # | Scenario | Input | Expected Output |
|---|----------|-------|-----------------|
| 1 | Valid - same house member | userId in house | Update status to USED |
| 2 | Already used | Already USED status | Throw BadRequestException |
| 3 | Different house | userId not in house | Throw ForbiddenException |
| 4 | Not found | Non-existent redemptionId | Throw NotFoundException |
