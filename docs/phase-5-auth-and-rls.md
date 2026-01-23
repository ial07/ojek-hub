# OjekHub - Phase 5: Authentication and Access Control

## Authentication Flow

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Supa as Supabase Auth
    participant Google as Google OAuth
    participant API as NestJS API
    participant DB as Supabase DB

    App->>Supa: signInWithOAuth(google)
    Supa->>Google: Redirect to Google
    Google->>Supa: OAuth callback + tokens
    Supa->>App: Session + JWT

    App->>API: Request + Bearer JWT
    API->>Supa: Verify JWT
    Supa->>API: User claims
    API->>DB: Query with user context
    DB->>API: Results (filtered by RLS)
    API->>App: Response
```

---

## Login Flow (Step-by-Step)

### First-Time User

| Step | Action                  | Result                      |
| ---- | ----------------------- | --------------------------- |
| 1    | Tap "Login with Google" | Supabase OAuth popup        |
| 2    | Select Google account   | Supabase creates user       |
| 3    | Check if profile exists | No → Show role selection    |
| 4    | Select role             | farmer / warehouse / worker |
| 5    | If worker → Select type | ojek / daily                |
| 6    | Fill profile form       | Name, phone, location       |
| 7    | Submit profile          | INSERT into `users` table   |
| 8    | Redirect to dashboard   | Based on role               |

### Returning User

| Step | Action           | Result                    |
| ---- | ---------------- | ------------------------- |
| 1    | Open app         | Check stored session      |
| 2    | Session valid?   | Yes → Go to dashboard     |
| 3    | Session expired? | Auto-refresh via Supabase |
| 4    | No session?      | Show login screen         |

---

## Role and Worker Type Selection

### Flutter Onboarding Flow

```mermaid
flowchart TD
    A[Google Sign-In Success] --> B{Profile exists?}
    B -->|Yes| C[Go to Dashboard]
    B -->|No| D[Role Selection Screen]
    D --> E{Selected Role}
    E -->|Farmer| F[Profile Form]
    E -->|Warehouse| F
    E -->|Worker| G[Worker Type Selection]
    G --> H{Selected Type}
    H -->|Ojek| F
    H -->|Daily| F
    F --> I[Submit Profile]
    I --> C
```

### Selection Rules

| Rule                     | Enforcement                            |
| ------------------------ | -------------------------------------- |
| Role is permanent        | No edit endpoint; requires new account |
| Worker type is permanent | Same as above                          |
| All fields required      | Form validation                        |
| Phone must be valid      | Regex: starts with 08 or +62           |

---

## Authorization Rules

### Role-Based Access Matrix

| Endpoint                   | Farmer   | Warehouse | Worker   |
| -------------------------- | -------- | --------- | -------- |
| `GET /users/me`            | ✅       | ✅        | ✅       |
| `PUT /users/me`            | ✅       | ✅        | ✅       |
| `POST /orders`             | ✅       | ✅        | ❌       |
| `GET /orders` (own)        | ✅       | ✅        | ❌       |
| `GET /orders` (by type)    | ❌       | ❌        | ✅       |
| `DELETE /orders/:id`       | ✅ (own) | ✅ (own)  | ❌       |
| `POST /orders/:id/queue`   | ❌       | ❌        | ✅       |
| `DELETE /orders/:id/queue` | ❌       | ❌        | ✅ (own) |
| `GET /orders/:id/queue`    | ✅ (own) | ✅ (own)  | ❌       |

### Access Rules Summary

| Rule                                | Description                                                |
| ----------------------------------- | ---------------------------------------------------------- |
| **Employers see own orders**        | `WHERE employer_id = auth.uid()`                           |
| **Workers see matching jobs**       | `WHERE worker_type = user.worker_type AND status = 'open'` |
| **One queue entry per order**       | UNIQUE constraint + check before insert                    |
| **Only order owner can view queue** | `WHERE order.employer_id = auth.uid()`                     |

---

## NestJS JWT Validation

### Auth Guard Implementation

```typescript
// auth.guard.ts
@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  constructor(private supabase: SupabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) throw new UnauthorizedException();

    const {
      data: { user },
      error,
    } = await this.supabase.auth.getUser(token);

    if (error || !user) throw new UnauthorizedException();

    request.user = user;
    return true;
  }
}
```

### Role Guard Implementation

```typescript
// role.guard.ts
@Injectable()
export class RoleGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!roles) return true;

    const request = context.switchToHttp().getRequest();
    const userRole = request.user.role;

    return roles.includes(userRole);
  }
}

// Usage
@Roles('farmer', 'warehouse')
@Post('orders')
createOrder() { ... }
```

---

## Supabase Row Level Security (RLS)

### Enable RLS

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_config ENABLE ROW LEVEL SECURITY;
```

### Users Policies

```sql
-- Users can read own profile
CREATE POLICY "users_select_own" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update own profile
CREATE POLICY "users_update_own" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert own profile (onboarding)
CREATE POLICY "users_insert_own" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);
```

### Orders Policies

```sql
-- Employers can create orders
CREATE POLICY "orders_insert_employer" ON orders
    FOR INSERT WITH CHECK (
        auth.uid() = employer_id AND
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('farmer', 'warehouse'))
    );

-- Employers see own orders
CREATE POLICY "orders_select_employer" ON orders
    FOR SELECT USING (
        employer_id = auth.uid()
    );

-- Workers see open orders matching their type
CREATE POLICY "orders_select_worker" ON orders
    FOR SELECT USING (
        status = 'open' AND
        worker_type = (SELECT worker_type FROM users WHERE id = auth.uid())
    );

-- Employers can close own orders
CREATE POLICY "orders_update_employer" ON orders
    FOR UPDATE USING (employer_id = auth.uid());

-- Employers can delete own orders
CREATE POLICY "orders_delete_employer" ON orders
    FOR DELETE USING (employer_id = auth.uid());
```

### Order Queue Policies

```sql
-- Workers can join queue (one per order)
CREATE POLICY "queue_insert_worker" ON order_queue
    FOR INSERT WITH CHECK (
        auth.uid() = worker_id AND
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'worker')
    );

-- Workers see own queue entries
CREATE POLICY "queue_select_worker" ON order_queue
    FOR SELECT USING (worker_id = auth.uid());

-- Employers see queue for own orders
CREATE POLICY "queue_select_employer" ON order_queue
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM orders WHERE id = order_id AND employer_id = auth.uid())
    );

-- Workers can leave queue
CREATE POLICY "queue_delete_worker" ON order_queue
    FOR DELETE USING (worker_id = auth.uid());
```

### Pricing Config Policies

```sql
-- Everyone can read pricing
CREATE POLICY "pricing_select_all" ON pricing_config
    FOR SELECT USING (true);
```

---

## Security Summary

| Layer              | Mechanism                    |
| ------------------ | ---------------------------- |
| **Authentication** | Supabase Auth + Google OAuth |
| **Session**        | Supabase JWT (auto-refresh)  |
| **API Protection** | NestJS Guard validates JWT   |
| **Authorization**  | Role-based guards in NestJS  |
| **Data Access**    | Supabase RLS policies        |
