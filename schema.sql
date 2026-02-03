-- DATABASE SCHEMA SETUP

-- 1. UTENTE (User Entity with Denormalized Ratings)
CREATE TABLE Utente (
    id_utente CHAR(36) NOT NULL DEFAULT (UUID()),
    CF VARCHAR(16) NOT NULL,
    Nome VARCHAR(30) NOT NULL,
    Cognome VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Documento_validazione TINYINT(1),
    Saldo_wallet DECIMAL(4, 2) DEFAULT 0.00, -- Redundant for fast read
    Rating_recensione DECIMAL(2, 2) DEFAULT 0.00,
    Rating_solvibilita DECIMAL(3, 2) DEFAULT 100.00,
    PRIMARY KEY (id_utente),
    UNIQUE (Email),
    UNIQUE (CF)
) ENGINE=InnoDB;

-- 2. WALLET (Financial Ledger)
CREATE TABLE Wallet (
    id_wallet CHAR(36) NOT NULL DEFAULT (UUID()),
    id_utente CHAR(36) NOT NULL,
    Saldo_disponibile DECIMAL(4, 2) DEFAULT 0.00,
    Saldo_congelato DECIMAL(4, 2) DEFAULT 0.00,
    PRIMARY KEY (id_wallet),
    FOREIGN KEY (id_utente) REFERENCES Utente(id_utente) ON DELETE CASCADE,
    UNIQUE (id_utente)
) ENGINE=InnoDB;

-- 3. VEICOLO
CREATE TABLE Veicolo (
    targa VARCHAR(10) NOT NULL,
    marca VARCHAR(30),
    modello VARCHAR(30),
    capienza_posti INT,
    id_utente CHAR(36) NOT NULL,
    PRIMARY KEY (targa),
    FOREIGN KEY (id_utente) REFERENCES Utente(id_utente)
);

-- 4. VIAGGIO (Trip Definition)
CREATE TABLE Viaggio (
    id_viaggio CHAR(36) NOT NULL,
    id_driver CHAR(36) NOT NULL,
    Punto_partenza VARCHAR(50),
    Punto_arrivo VARCHAR(50),
    Data_ora DATETIME,
    Contributo DECIMAL(10,2),
    Posti_disponibili INT,
    Soglia_deviazione INT,
    PRIMARY KEY (id_viaggio),
    FOREIGN KEY (id_driver) REFERENCES Utente(id_utente)
);

-- 5. TAPPA (Intermediate Stops)
CREATE TABLE Tappa (
    id_tappa CHAR(36) NOT NULL,
    id_viaggio CHAR(36) NOT NULL,
    Nome_luogo VARCHAR(50),
    Orario_stimato DATETIME,
    PRIMARY KEY (id_tappa),
    FOREIGN KEY (id_viaggio) REFERENCES Viaggio(id_viaggio)
);

-- 6. SEGMENTO_VIAGGIO (Atomic Leg Optimization)
CREATE TABLE Segmento_viaggio (
    id_segmento CHAR(36) NOT NULL,
    id_viaggio CHAR(36) NOT NULL,
    id_tappa_inizio CHAR(36) NOT NULL,
    id_tappa_fine CHAR(36) NOT NULL,
    Conta_posti_occupati INT DEFAULT 0,
    PRIMARY KEY (id_segmento),
    FOREIGN KEY (id_viaggio) REFERENCES Viaggio(id_viaggio)
);

-- 7. PRENOTAZIONE
CREATE TABLE Prenotazione (
    id_prenotazione CHAR(36) NOT NULL,
    id_passeggero CHAR(36) NOT NULL,
    id_viaggio CHAR(36) NOT NULL,
    Stato ENUM('In Attesa', 'Confermata', 'Rifiutata', 'Completata'),
    Num_posti INT,
    PRIMARY KEY (id_prenotazione),
    FOREIGN KEY (id_passeggero) REFERENCES Utente(id_utente),
    FOREIGN KEY (id_viaggio) REFERENCES Viaggio(id_viaggio)
);

-- 8. RIFERIMENTO PRENOTAZIONE (Linking Bookings to Segments)
CREATE TABLE Riferimento_Prenotazione (
    id_prenotazione CHAR(36) NOT NULL,
    id_segmento CHAR(36) NOT NULL,
    PRIMARY KEY (id_prenotazione, id_segmento),
    FOREIGN KEY (id_prenotazione) REFERENCES Prenotazione(id_prenotazione),
    FOREIGN KEY (id_segmento) REFERENCES Segmento_viaggio(id_segmento)
);

-- 9. TRANSAZIONE (Financial Log)
CREATE TABLE Transazione (
    id_transazione CHAR(36) NOT NULL,
    id_prenotazione CHAR(36) NOT NULL,
    Tipo ENUM('Congelamento', 'Accredito', 'Rimborso'),
    Stato VARCHAR(20),
    Importo DECIMAL(10,2),
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_transazione),
    FOREIGN KEY (id_prenotazione) REFERENCES Prenotazione(id_prenotazione)
);
