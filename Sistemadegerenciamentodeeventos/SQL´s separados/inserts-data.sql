-- Inserindo Categorias
INSERT INTO categorias (descricao) VALUES 
('Workshop'), ('Palestra'), ('Minicurso'), ('Congresso');

-- Inserindo Locais
INSERT INTO locais (nome, endereco, capacidade) VALUES 
('Auditório Principal', 'Bloco A, Térreo', 100),
('Laboratório de Informática 1', 'Bloco C, 1º Andar', 30),
('Sala de Conferências', 'Bloco B, 2º Andar', 50);

-- Inserindo Participantes
INSERT INTO participantes (nome, email, cpf) VALUES 
('João Silva', 'joao.silva@email.com', '111.111.111-11'),
('Maria Oliveira', 'maria.oliveira@email.com', '222.222.222-22'),
('Carlos Souza', 'carlos.souza@email.com', '333.333.333-33'),
('Ana Pereira', 'ana.pereira@email.com', '444.444.444-44');

-- Inserindo Eventos
INSERT INTO eventos (titulo, data_hora, status, fk_local, fk_categoria) VALUES 
('Introdução ao SQL', '2025-11-20 14:00:00', 'Agendado', 2, 1),
('Futuro da Inteligência Artificial', '2025-11-21 19:00:00', 'Agendado', 1, 2),
('Gestão Ágil de Projetos', '2025-11-22 08:00:00', 'Cancelado', 3, 1),
('Segurança da Informação', '2025-12-01 10:00:00', 'Agendado', 1, 2);

-- Inserindo Inscrições
INSERT INTO inscricoes (fk_evento, fk_participante) VALUES 
(2, 1), (4, 2), (1, 1), (1, 3), (3, 4);