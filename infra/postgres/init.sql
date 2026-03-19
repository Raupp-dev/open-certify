-- Script de inicialização do banco de dados Open Certify
-- Este arquivo será executado automaticamente quando o container PostgreSQL for criado

-- Criação das tabelas principais do Open Certify

-- Tabela de usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    keycloak_id UUID UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    password_hash VARCHAR(255), -- Para autenticação local (desenvolvimento)
    role VARCHAR(50) NOT NULL CHECK (role IN ('aluno', 'avaliador', 'admin')),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de perfis de usuário (informações adicionais)
CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    phone_number VARCHAR(20),
    address TEXT,
    bio TEXT,
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de instituições
CREATE TABLE institutions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    website VARCHAR(255),
    logo_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de categorias de exames
CREATE TABLE exam_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de provas/exames
CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES exam_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0,
    min_score INTEGER DEFAULT 70,
    duration_minutes INTEGER DEFAULT 60,
    difficulty VARCHAR(50) DEFAULT 'Iniciante' CHECK (difficulty IN ('Iniciante', 'Intermediário', 'Avançado')),
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    tags TEXT[], -- Array de tags
    image_url VARCHAR(500),
    total_questions INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de questões
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    exam_id INTEGER REFERENCES exams(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('multiple_choice', 'essay', 'true_false')),
    text TEXT NOT NULL,
    options JSONB, -- Para questões de múltipla escolha
    correct_answer JSONB,
    points INTEGER DEFAULT 1,
    explanation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de tentativas de prova
CREATE TABLE exam_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    exam_id INTEGER REFERENCES exams(id) ON DELETE CASCADE,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    score INTEGER DEFAULT 0,
    max_score INTEGER DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'passed', 'failed', 'timeout')),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de respostas
CREATE TABLE answers (
    id SERIAL PRIMARY KEY,
    exam_attempt_id INTEGER REFERENCES exam_attempts(id) ON DELETE CASCADE,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    user_answer JSONB,
    is_correct BOOLEAN DEFAULT FALSE,
    points_earned INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0, -- em segundos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de certificados
CREATE TABLE certificates (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    exam_id INTEGER REFERENCES exams(id) ON DELETE CASCADE,
    exam_attempt_id INTEGER REFERENCES exam_attempts(id) ON DELETE CASCADE,
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiration_date TIMESTAMP,
    certificate_url VARCHAR(500),
    hash VARCHAR(64) NOT NULL, -- SHA-256
    is_valid BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de insígnias
CREATE TABLE badges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    criteria JSONB, -- Critérios para ganhar a insígnia
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de relacionamento usuário-insígnia
CREATE TABLE user_badges (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    badge_id INTEGER REFERENCES badges(id) ON DELETE CASCADE,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, badge_id)
);

-- Tabela de pedidos/compras
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded')),
    payment_method VARCHAR(50),
    payment_gateway VARCHAR(50),
    payment_gateway_id VARCHAR(255),
    payment_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de itens do pedido
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    exam_id INTEGER REFERENCES exams(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de sessões de prova (para controle de proctoring)
CREATE TABLE exam_sessions (
    id SERIAL PRIMARY KEY,
    exam_attempt_id INTEGER REFERENCES exam_attempts(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    browser_info JSONB,
    screen_recording_url VARCHAR(500),
    webcam_recording_url VARCHAR(500),
    violations JSONB, -- Registros de violações detectadas
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX idx_users_keycloak_id ON users(keycloak_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_institutions_user_id ON institutions(user_id);
CREATE INDEX idx_exams_institution_id ON exams(institution_id);
CREATE INDEX idx_exams_category_id ON exams(category_id);
CREATE INDEX idx_exams_status ON exams(status);
CREATE INDEX idx_questions_exam_id ON questions(exam_id);
CREATE INDEX idx_exam_attempts_user_id ON exam_attempts(user_id);
CREATE INDEX idx_exam_attempts_exam_id ON exam_attempts(exam_id);
CREATE INDEX idx_exam_attempts_status ON exam_attempts(status);
CREATE INDEX idx_answers_exam_attempt_id ON answers(exam_attempt_id);
CREATE INDEX idx_answers_question_id ON answers(question_id);
CREATE INDEX idx_certificates_user_id ON certificates(user_id);
CREATE INDEX idx_certificates_exam_id ON certificates(exam_id);
CREATE INDEX idx_certificates_number ON certificates(certificate_number);
CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge_id ON user_badges(badge_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_exam_id ON order_items(exam_id);
CREATE INDEX idx_exam_sessions_attempt_id ON exam_sessions(exam_attempt_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_institutions_updated_at BEFORE UPDATE ON institutions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exams_updated_at BEFORE UPDATE ON exams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exam_attempts_updated_at BEFORE UPDATE ON exam_attempts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_answers_updated_at BEFORE UPDATE ON answers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certificates_updated_at BEFORE UPDATE ON certificates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_badges_updated_at BEFORE UPDATE ON badges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exam_sessions_updated_at BEFORE UPDATE ON exam_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Inserção de dados iniciais

-- Categorias de exames
INSERT INTO exam_categories (name, description, icon) VALUES
('Tecnologia', 'Certificações em tecnologia da informação', 'code'),
('Negócios', 'Certificações em administração e negócios', 'briefcase'),
('Design', 'Certificações em design e criatividade', 'palette'),
('Marketing', 'Certificações em marketing digital', 'megaphone'),
('Ciência de Dados', 'Certificações em análise de dados e IA', 'bar-chart'),
('Idiomas', 'Certificações em idiomas estrangeiros', 'globe');

-- Insígnias padrão
INSERT INTO badges (name, description, image_url, criteria) VALUES
('Primeiro Certificado', 'Conquistou seu primeiro certificado na plataforma', '/badges/first-certificate.png', '{"type": "first_certificate"}'),
('Estudante Dedicado', 'Completou 5 certificações', '/badges/dedicated-student.png', '{"type": "certificate_count", "count": 5}'),
('Expert', 'Completou 10 certificações', '/badges/expert.png', '{"type": "certificate_count", "count": 10}'),
('Nota Máxima', 'Obteve 100% em uma prova', '/badges/perfect-score.png', '{"type": "perfect_score"}'),
('Velocista', 'Completou uma prova em menos de 50% do tempo', '/badges/speedster.png', '{"type": "fast_completion", "percentage": 50}');

-- Função para gerar número de certificado único
CREATE OR REPLACE FUNCTION generate_certificate_number()
RETURNS VARCHAR(100) AS $$
DECLARE
    cert_number VARCHAR(100);
    exists_check INTEGER;
BEGIN
    LOOP
        cert_number := 'OC-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
        SELECT COUNT(*) INTO exists_check FROM certificates WHERE certificate_number = cert_number;
        EXIT WHEN exists_check = 0;
    END LOOP;
    RETURN cert_number;
END;
$$ LANGUAGE plpgsql;

-- Função para gerar número de pedido único
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR(100) AS $$
DECLARE
    order_num VARCHAR(100);
    exists_check INTEGER;
BEGIN
    LOOP
        order_num := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 9999)::TEXT, 4, '0');
        SELECT COUNT(*) INTO exists_check FROM orders WHERE order_number = order_num;
        EXIT WHEN exists_check = 0;
    END LOOP;
    RETURN order_num;
END;
$$ LANGUAGE plpgsql;

-- Trigger para gerar número de certificado automaticamente
CREATE OR REPLACE FUNCTION set_certificate_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.certificate_number IS NULL THEN
        NEW.certificate_number := generate_certificate_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_certificate_number_trigger
    BEFORE INSERT ON certificates
    FOR EACH ROW
    EXECUTE FUNCTION set_certificate_number();

-- Trigger para gerar número de pedido automaticamente
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION set_order_number();

-- Views úteis

-- View para estatísticas de usuários
CREATE VIEW user_stats AS
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.role,
    COUNT(DISTINCT ea.id) as total_attempts,
    COUNT(DISTINCT CASE WHEN ea.status = 'passed' THEN ea.id END) as passed_attempts,
    COUNT(DISTINCT c.id) as total_certificates,
    COUNT(DISTINCT ub.badge_id) as total_badges,
    u.created_at
FROM users u
LEFT JOIN exam_attempts ea ON u.id = ea.user_id
LEFT JOIN certificates c ON u.id = c.user_id
LEFT JOIN user_badges ub ON u.id = ub.user_id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.role, u.created_at;

-- View para estatísticas de exames
CREATE VIEW exam_stats AS
SELECT 
    e.id,
    e.title,
    e.price,
    e.status,
    i.name as institution_name,
    ec.name as category_name,
    COUNT(DISTINCT ea.id) as total_attempts,
    COUNT(DISTINCT CASE WHEN ea.status = 'passed' THEN ea.user_id END) as passed_students,
    COUNT(DISTINCT c.id) as certificates_issued,
    AVG(CASE WHEN ea.status = 'completed' THEN ea.percentage END) as avg_score,
    e.created_at
FROM exams e
LEFT JOIN institutions i ON e.institution_id = i.id
LEFT JOIN exam_categories ec ON e.category_id = ec.id
LEFT JOIN exam_attempts ea ON e.id = ea.exam_id
LEFT JOIN certificates c ON e.id = c.exam_id
GROUP BY e.id, e.title, e.price, e.status, i.name, ec.name, e.created_at;

-- Comentários nas tabelas
COMMENT ON TABLE users IS 'Tabela principal de usuários do sistema';
COMMENT ON TABLE profiles IS 'Informações adicionais do perfil do usuário';
COMMENT ON TABLE institutions IS 'Instituições que criam e gerenciam exames';
COMMENT ON TABLE exam_categories IS 'Categorias para organizar os exames';
COMMENT ON TABLE exams IS 'Provas e certificações disponíveis na plataforma';
COMMENT ON TABLE questions IS 'Questões que compõem os exames';
COMMENT ON TABLE exam_attempts IS 'Tentativas de realização de exames pelos usuários';
COMMENT ON TABLE answers IS 'Respostas dos usuários às questões dos exames';
COMMENT ON TABLE certificates IS 'Certificados emitidos após aprovação em exames';
COMMENT ON TABLE badges IS 'Insígnias que podem ser conquistadas pelos usuários';
COMMENT ON TABLE user_badges IS 'Relacionamento entre usuários e insígnias conquistadas';
COMMENT ON TABLE orders IS 'Pedidos de compra de acesso a exames';
COMMENT ON TABLE order_items IS 'Itens individuais dos pedidos';
COMMENT ON TABLE exam_sessions IS 'Sessões de prova para controle de proctoring';

-- Finalização
SELECT 'Banco de dados Open Certify inicializado com sucesso!' as status;

