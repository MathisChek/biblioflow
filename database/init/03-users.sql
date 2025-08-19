-- Création des utilisateurs PostgreSQL pour l'application

-- Utilisateur pour l'application (mode production)
DO $$
BEGIN
    -- Créer l'utilisateur s'il n'existe pas
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'biblioflow_user') THEN
        CREATE USER biblioflow_user WITH ENCRYPTED PASSWORD 'secure_app_password_2024';
    END IF;
END
$$;

-- Utilisateur en lecture seule pour les rapports/analytics
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'biblioflow_readonly') THEN
        CREATE USER biblioflow_readonly WITH ENCRYPTED PASSWORD 'readonly_password_2024';
    END IF;
END
$$;

-- Permissions pour l'utilisateur de l'application
GRANT CONNECT ON DATABASE biblioflow_dev TO biblioflow_user;
GRANT USAGE ON SCHEMA public TO biblioflow_user;
GRANT CREATE ON SCHEMA public TO biblioflow_user;

-- Permissions sur les tables existantes (maintenant qu'elles existent)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO biblioflow_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO biblioflow_user;

-- Permissions sur les futures tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO biblioflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO biblioflow_user;

-- Permissions lecture seule
GRANT CONNECT ON DATABASE biblioflow_dev TO biblioflow_readonly;
GRANT USAGE ON SCHEMA public TO biblioflow_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO biblioflow_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO biblioflow_readonly;

-- Permissions spécifiques sur chaque table (explicite)
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO biblioflow_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON books TO biblioflow_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON loans TO biblioflow_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON reservations TO biblioflow_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON audit_logs TO biblioflow_user;

-- Permissions sur les séquences
GRANT USAGE, SELECT ON users_id_seq TO biblioflow_user;
GRANT USAGE, SELECT ON books_id_seq TO biblioflow_user;
GRANT USAGE, SELECT ON loans_id_seq TO biblioflow_user;
GRANT USAGE, SELECT ON reservations_id_seq TO biblioflow_user;
GRANT USAGE, SELECT ON audit_logs_id_seq TO biblioflow_user;

-- Permissions lecture seule
GRANT SELECT ON ALL TABLES IN SCHEMA public TO biblioflow_readonly;

-- Commentaires pour documentation
COMMENT ON ROLE biblioflow_user IS 'Utilisateur principal pour l application BiblioFlow';
COMMENT ON ROLE biblioflow_readonly IS 'Utilisateur en lecture seule pour les rapports et analytics';

-- Afficher les utilisateurs créés
SELECT
    rolname as username,
    rolcanlogin as can_login,
    rolcreatedb as can_create_db,
    rolsuper as is_superuser
FROM pg_roles
WHERE rolname LIKE 'biblioflow_%'
ORDER BY rolname;
