# OjekHub - Phase 1: Problem and Goal

## Problem Statement

### The Core Problem

**Farmers and warehouse operators in Rejang Lebong face a labor discovery bottleneck.** They frequently need multiple workers (motorcycle drivers for transport, daily laborers for harvest/loading) but currently rely on personal networks and word-of-mouth to find them.

This creates three pain points:

| Stakeholder                        | Pain Point                                                       |
| ---------------------------------- | ---------------------------------------------------------------- |
| **Employers** (Farmers/Warehouses) | Cannot find enough workers quickly; limited to personal contacts |
| **Workers** (Drivers/Laborers)     | Miss job opportunities they never hear about; income instability |
| **Local Economy**                  | Inefficient labor allocation; underemployment despite demand     |

### Why This Matters

In rural agricultural regions like Rejang Lebong:

- Harvest seasons create **sudden, high-volume labor demand**
- Workers are often available but **disconnected from opportunities**
- No existing digital infrastructure bridges this gap
- Personal connection-based hiring creates **unfair access** to work

---

## Product Goal

> **Create a free, simple mobile application that connects job demand (farmers/warehouses) with worker supply (drivers/laborers) through a transparent queue system.**

### Why a Simple Connection + Queue System is Enough

| Reason                         | Explanation                                                                  |
| ------------------------------ | ---------------------------------------------------------------------------- |
| **Low digital literacy**       | Rural users need dead-simple UX; complex features create friction            |
| **Trust through transparency** | A visible queue shows workers they're being treated fairly                   |
| **No verification overhead**   | No complex verification = faster adoption = network effects                  |
| **Free = adoption**            | Monetization can come later; initial goal is usage & habit formation         |
| **MVP-first mindset**          | Prove the connection value before adding task tracking, payments, or ratings |

### What OjekHub Does (MVP Scope)

```
┌─────────────────┐         ┌─────────────────┐
│   EMPLOYER      │         │     WORKER      │
│  (Farmer/       │         │   (Driver/      │
│   Warehouse)    │         │    Laborer)     │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │  Posts Job Request        │  Registers & Enters Queue
         │  (type, location, count)  │  (type, availability)
         │                           │
         └───────────┬───────────────┘
                     │
              ┌──────▼──────┐
              │  OJEKHUB    │
              │  (Matching) │
              └──────┬──────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
   Workers get notified    Employer sees available
   of matching jobs        workers in their area
```

### What OjekHub Does NOT Do (Explicit Non-Scope)

- ❌ Track task progress or completion
- ❌ Handle payments or transactions
- ❌ Verify worker identity/credentials
- ❌ Provide ratings or reviews
- ❌ Guarantee job completion

---

## Assumptions and Risks

### Core Assumptions

| #   | Assumption                                                  | How to Validate                  |
| --- | ----------------------------------------------------------- | -------------------------------- |
| A1  | Farmers/warehouses regularly need workers they can't find   | User interviews pre-launch       |
| A2  | Workers have smartphones with internet access               | Survey during onboarding         |
| A3  | A queue system feels fair to workers                        | Beta user feedback               |
| A4  | Users will adopt a free app if it's simple enough           | Track downloads vs. active users |
| A5  | Word-of-mouth will drive adoption in tight-knit communities | Referral tracking                |

### Risks and Mitigations

| Risk                                      | Severity | Mitigation                                              |
| ----------------------------------------- | -------- | ------------------------------------------------------- |
| **Low smartphone penetration**            | High     | Support feature phones via SMS in v2                    |
| **Workers don't check app regularly**     | Medium   | Push notifications for job matches                      |
| **Employers don't trust unknown workers** | Medium   | Show worker's area/availability; trust builds over time |
| **No-shows after connection**             | Medium   | Accept this for MVP; add reputation system later        |
| **Network effects take too long**         | High     | Focus on one kecamatan first to build density           |

---

## MVP Success Indicators

### Primary Metrics (Must Track)

| Metric                     | Target (3 months post-launch)       | Why It Matters             |
| -------------------------- | ----------------------------------- | -------------------------- |
| **Registered Workers**     | 200+                                | Supply side of marketplace |
| **Registered Employers**   | 50+                                 | Demand side of marketplace |
| **Jobs Posted**            | 100+ total                          | Proof of demand            |
| **Successful Connections** | 60%+ of jobs get ≥1 worker response | Core value delivery        |

### Secondary Metrics (Nice to Track)

| Metric                     | Purpose                   |
| -------------------------- | ------------------------- |
| **Time to First Response** | Measure connection speed  |
| **Repeat Usage**           | Habit formation indicator |
| **Referral Rate**          | Organic growth potential  |

### Qualitative Success Criteria

- [ ] Employers report finding workers **faster than before**
- [ ] Workers report **hearing about more jobs** than through personal networks
- [ ] Users describe the app as **"simple"** or **"easy to use"**

---

## Summary

| Element                  | Definition                                                              |
| ------------------------ | ----------------------------------------------------------------------- |
| **Problem**              | Labor discovery bottleneck in Rejang Lebong's agricultural sector       |
| **Solution**             | Free mobile app connecting employers with workers via transparent queue |
| **Why Simple is Enough** | Low digital literacy + adoption-first strategy + MVP validation         |
| **Key Assumption**       | Both supply and demand exist but are disconnected                       |
| **Success Metric**       | 60%+ job posts receive worker responses within 3 months                 |
