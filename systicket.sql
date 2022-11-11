PRAGMA foreign_keys = ON;

CREATE TABLE Status (
        id   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        seq  INTEGER NOT NULL,
        name VARCHAR(48) NOT NULL
);

CREATE TABLE Ticket (
        id            INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title         VARCHAR(255),
        description   TEXT,
        status        INTEGER  NOT NULL DEFAULT (1) REFERENCES Status(id),
        assigned_user INTEGER REFERENCES User(id)
);

CREATE TABLE Reply (
        id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        message     TEXT
);

CREATE TABLE Ticket_Reply (
        id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ticket_id  INTEGER REFERENCES Ticket(id) ON DELETE CASCADE ON UPDATE CASCADE,
        reply_id   INTEGER REFERENCES Reply(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE User (
        id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name        VARCHAR(48)
);

---
--- Create the users
---
INSERT INTO User VALUES (1, "Alice");
INSERT INTO User VALUES (2, "Bob");
INSERT INTO User VALUES (3, "Charlie");

---
--- Create the statuses
---
INSERT INTO Status VALUES (1, 10, "New");
INSERT INTO Status VALUES (2, 20, "In progress");
INSERT INTO Status VALUES (3, 30, "QA");
INSERT INTO Status VALUES (4, 40, "Done");
INSERT INTO Status VALUES (5, 50, "Won't Fix");

-- 
-- Insert some tickets
-- 
INSERT INTO Ticket VALUES (1, "Test 1", "Desc 1", 1, 1);
INSERT INTO Ticket VALUES (2, "Test 2", "Desc 2", 1, 2);
INSERT INTO Ticket VALUES (3, "Test 3", "Desc 3", 1, null);
