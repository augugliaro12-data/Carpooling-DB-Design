# Carpooling-DB-Design
Advanced Relational Database Architecture for a Mobility-as-a-Service platform. Features: 3NF Normalization, ACID Transactions via Triggers, and Optimized Segmentation Logic.
# Carpooling DB - Advanced Relational Architecture

## 📌 Project Overview
Design and implementation of a **high-performance relational database** for a Dynamic Carpooling Platform.
Unlike standard booking systems, this architecture handles **complex route segmentation**, allowing a single ride to be sold in disjointed segments (A->B, B->C) while maintaining data integrity and transactional security.

**Tech Stack:** SQL (MySQL/MariaDB), ER Modeling, Business Logic Optimization.

## 🚀 Key Engineering Features

### 1. Route Segmentation Logic
Instead of treating a ride as a monolith block, I implemented a **Segment-based architecture**.
- **Challenge:** A passenger booking a ride from Rome to Naples shouldn't block a seat for the Naples-Sicily leg.
- **Solution:** Introduced a `Segmento_Viaggio` entity that splits trips into atomic legs. A trigger automatically updates seat availability only on relevant segments upon booking.

### 2. Strategic Denormalization for Performance
Optimized for high-frequency operations (e.g., Trip Matching ~5,000 req/day) by introducing controlled redundancy:
- **`Conta_posti_occupati` in Segments:** Avoids expensive `COUNT()` aggregations during search queries.
- **`Rating_Recensione` in User Table:** Pre-calculated average to speed up user profiling.
- *Justification:* Trade-off analysis showed a 90% reduction in read-access cost for the critical "Matching Operation".

### 3. Financial Transaction Safety (ACID)
Implemented a **Double-Entry Wallet System** via Triggers to prevent fraud:
- Funds are "Frozen" (`Saldo_congelato`) upon booking.
- Funds are moved to the Driver's "Available Balance" only upon ride completion.
- Automated rollback triggers handle cancellations and refunds.

## 🛠 Database Schema
The system is normalized to **BCNF** (Boyce-Codd Normal Form), with documented exceptions for performance.

### Core Entities:
- **Utente:** Single entity for both Drivers and Passengers (Role agnostic).
- **Viaggio & Tappa:** Defines the route and timing.
- **Prenotazione & Segmento:** Manages seat allocation logic.
- **Wallet & Transazione:** Handles the financial ledger.

## ⚡ Automation (Stored Triggers)
The business logic is enforced directly at the database level:
- `congela_fondi_prenotazione`: Checks solvency before booking.
- `aggiorna_posti_segmenti`: Updates availability across specific trip legs.
- `aggiorna_solvibilita`: Automatically calculates user reliability score based on completion rate.

## 👨‍💻 Authors
- **Giulio Augugliaro** - *Database Architecture & Optimization Logic*
