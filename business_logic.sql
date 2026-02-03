-- AUTOMATED BUSINESS LOGIC (TRIGGERS)

DELIMITER //

-- 1. SOLVENCY CHECK & FUND FREEZING
-- Before a booking is created, ensures the user has enough balance.
-- If yes, moves funds to 'Frozen Balance'. If no, blocks the transaction.
CREATE TRIGGER congela_fondi_prenotazione
BEFORE INSERT ON Prenotazione
FOR EACH ROW
BEGIN
    DECLARE v_costo_unitario DECIMAL(10,2);
    DECLARE v_costo_totale DECIMAL(10,2);
    DECLARE v_saldo_attuale DECIMAL(10,2);

    -- Get trip cost
    SELECT Contributo INTO v_costo_unitario FROM Viaggio WHERE id_viaggio = NEW.id_viaggio;
    SET v_costo_totale = v_costo_unitario * NEW.Num_posti;

    -- Check user balance
    SELECT Saldo_disponibile INTO v_saldo_attuale FROM Wallet WHERE id_utente = NEW.id_passeggero;

    IF v_saldo_attuale < v_costo_totale THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Insufficient funds in Wallet.';
    ELSE
        -- Move funds to frozen status (ACID compliance)
        UPDATE Wallet
        SET Saldo_disponibile = Saldo_disponibile - v_costo_totale,
            Saldo_congelato = Saldo_congelato + v_costo_totale
        WHERE id_utente = NEW.id_passeggero;
    END IF;
END //

-- 2. SMART SEAT ALLOCATION (The Core Optimization)
-- Updates the 'Occupied Seats' counter on specific route segments only when reservation is confirmed.
CREATE TRIGGER aggiorna_posti_segmenti
AFTER UPDATE ON Prenotazione
FOR EACH ROW
BEGIN
    -- Case: Booking Confirmed -> Occupy Seats
    IF OLD.Stato != 'Confermata' AND NEW.Stato = 'Confermata' THEN
        UPDATE Segmento_viaggio S
        INNER JOIN Riferimento_Prenotazione RP ON S.id_segmento = RP.id_segmento
        SET S.Conta_posti_occupati = S.Conta_posti_occupati + NEW.Num_posti
        WHERE RP.id_prenotazione = NEW.id_prenotazione;
    END IF;

    -- Case: Booking Cancelled -> Free Seats
    IF OLD.Stato = 'Confermata' AND NEW.Stato = 'Rifiutata' THEN
        UPDATE Segmento_viaggio S
        INNER JOIN Riferimento_Prenotazione RP ON S.id_segmento = RP.id_segmento
        SET S.Conta_posti_occupati = S.Conta_posti_occupati - NEW.Num_posti
        WHERE RP.id_prenotazione = NEW.id_prenotazione;
    END IF;
END //

DELIMITER ;
