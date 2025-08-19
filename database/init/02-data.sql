-- Données de test pour BiblioFlow

-- Utilisateurs de test
INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES
('admin@biblioflow.com', '$2b$10$CwTycUXWue0Thq9StjUM0uJ8oUBD1qDx8E5W1TRZ5M.PtUON85c52', 'Admin', 'System', 'admin'),
('librarian@biblioflow.com', '$2b$10$CwTycUXWue0Thq9StjUM0uJ8oUBD1qDx8E5W1TRZ5M.PtUON85c52', 'Marie', 'Dubois', 'librarian'),
('user@biblioflow.com', '$2b$10$CwTycUXWue0Thq9StjUM0uJ8oUBD1qDx8E5W1TRZ5M.PtUON85c52', 'Jean', 'Dupont', 'user'),
('alice@example.com', '$2b$10$CwTycUXWue0Thq9StjUM0uJ8oUBD1qDx8E5W1TRZ5M.PtUON85c52', 'Alice', 'Martin', 'user'),
('bob@example.com', '$2b$10$CwTycUXWue0Thq9StjUM0uJ8oUBD1qDx8E5W1TRZ5M.PtUON85c52', 'Bob', 'Johnson', 'user')
ON CONFLICT (email) DO NOTHING;

-- Livres de test avec diverses catégories
INSERT INTO books (title, author, isbn, description, category, publication_year, publisher, language, pages, location) VALUES
-- Fiction classique
('Le Seigneur des Anneaux', 'J.R.R. Tolkien', '978-0547928227', 'Un classique de la fantasy épique', 'Fantasy', 1954, 'Christian Bourgois', 'fr', 1216, 'A-01-001'),
('1984', 'George Orwell', '978-0451524935', 'Roman dystopique sur la surveillance de masse', 'Science-Fiction', 1949, 'Gallimard', 'fr', 368, 'A-01-002'),
('Harry Potter à l école des sorciers', 'J.K. Rowling', '978-2070518425', 'Premier tome de la saga Harry Potter', 'Fantasy', 1997, 'Gallimard Jeunesse', 'fr', 308, 'A-02-001'),
('Le Petit Prince', 'Antoine de Saint-Exupéry', '978-2070408504', 'Conte philosophique et poétique', 'Jeunesse', 1943, 'Gallimard', 'fr', 96, 'B-01-001'),

-- Science et Technologie
('Clean Code', 'Robert C. Martin', '978-0132350884', 'Guide des bonnes pratiques de programmation', 'Informatique', 2008, 'Prentice Hall', 'en', 464, 'C-01-001'),
('Design Patterns', 'Gang of Four', '978-0201633610', 'Patterns de conception en programmation orientée objet', 'Informatique', 1994, 'Addison-Wesley', 'en', 395, 'C-01-002'),
('The Pragmatic Programmer', 'Andrew Hunt', '978-0135957059', 'Guide pratique pour les développeurs', 'Informatique', 1999, 'Addison-Wesley', 'en', 352, 'C-01-003'),

-- Histoire et Biographie
('Sapiens', 'Yuval Noah Harari', '978-2226257017', 'Une brève histoire de l humanité', 'Histoire', 2011, 'Albin Michel', 'fr', 512, 'D-01-001'),
('Steve Jobs', 'Walter Isaacson', '978-2709638321', 'Biographie officielle de Steve Jobs', 'Biographie', 2011, 'JC Lattès', 'fr', 656, 'D-02-001'),

-- Sciences
('Une brève histoire du temps', 'Stephen Hawking', '978-2290349656', 'Introduction à la cosmologie moderne', 'Sciences', 1988, 'Flammarion', 'fr', 256, 'E-01-001'),
('Cosmos', 'Carl Sagan', '978-2757841761', 'Exploration de l univers et de notre place', 'Sciences', 1980, 'Points', 'fr', 512, 'E-01-002'),

-- Romans contemporains
('L Étranger', 'Albert Camus', '978-2070360024', 'Roman existentialiste emblématique', 'Littérature', 1942, 'Gallimard', 'fr', 144, 'F-01-001'),
('Cent ans de solitude', 'Gabriel García Márquez', '978-2757803695', 'Chef-d œuvre du réalisme magique', 'Littérature', 1967, 'Points', 'fr', 496, 'F-01-002'),

-- Livres non disponibles (empruntés)
('Dune', 'Frank Herbert', '978-2266320481', 'Épopée de science-fiction dans le désert', 'Science-Fiction', 1965, 'Pocket', 'fr', 928, 'A-03-001'),
('Foundation', 'Isaac Asimov', '978-0553293357', 'Cycle de Foundation, psychohistoire', 'Science-Fiction', 1951, 'Bantam', 'en', 244, 'A-03-002')
ON CONFLICT (isbn) DO NOTHING;

-- Marquer certains livres comme non disponibles
UPDATE books SET available = false WHERE isbn IN ('978-2266320481', '978-0553293357');

-- Emprunts actifs
INSERT INTO loans (user_id, book_id, due_date, status) VALUES
((SELECT id FROM users WHERE email = 'user@biblioflow.com'),
 (SELECT id FROM books WHERE isbn = '978-2266320481'),
 NOW() + INTERVAL '14 days', 'active'),
((SELECT id FROM users WHERE email = 'alice@example.com'),
 (SELECT id FROM books WHERE isbn = '978-0553293357'),
 NOW() + INTERVAL '7 days', 'active')
ON CONFLICT DO NOTHING;

-- Réservations
INSERT INTO reservations (user_id, book_id, expiry_date, status) VALUES
((SELECT id FROM users WHERE email = 'bob@example.com'),
 (SELECT id FROM books WHERE isbn = '978-2266320481'),
 NOW() + INTERVAL '3 days', 'pending')
ON CONFLICT DO NOTHING;

-- Logs d'audit de test
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details) VALUES
((SELECT id FROM users WHERE email = 'admin@biblioflow.com'), 'user_created', 'user', 1, '{"role": "admin"}'),
((SELECT id FROM users WHERE email = 'librarian@biblioflow.com'), 'book_added', 'book', 1, '{"title": "Le Seigneur des Anneaux"}'),
((SELECT id FROM users WHERE email = 'user@biblioflow.com'), 'book_borrowed', 'loan', 1, '{"book_title": "Dune", "due_date": "2024-02-15"}');

-- Statistiques de base
INSERT INTO audit_logs (action, details) VALUES
('system_initialized', '{"books_count": 14, "users_count": 5, "active_loans": 2}');
