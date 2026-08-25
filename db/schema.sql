CREATE TABLE IF NOT EXISTS pacotes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  tempo VARCHAR(60) NOT NULL,
  categoria ENUM('horas', 'dias', 'semanal') NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  perfil_mikrotik VARCHAR(80) NOT NULL,
  ordem INT NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vouchers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pacote_id INT NOT NULL,
  codigo_voucher VARCHAR(80) NOT NULL,
  senha_voucher VARCHAR(80) NOT NULL,
  telefone_cliente VARCHAR(20) NULL,
  mac_cliente VARCHAR(80) NULL,
  ip_cliente VARCHAR(80) NULL,
  link_origem VARCHAR(255) NULL,
  payment_provider VARCHAR(30) NULL,
  status ENUM('disponivel', 'pendente', 'pago', 'usado', 'cancelado') NOT NULL DEFAULT 'disponivel',
  status_mensagem VARCHAR(255) NULL,
  transacao_id VARCHAR(80) NULL,
  mikrotik_user_id VARCHAR(80) NULL,
  mikrotik_synced_at DATETIME NULL,
  mikrotik_error VARCHAR(255) NULL,
  mikrotik_login_at DATETIME NULL,
  mikrotik_login_message VARCHAR(255) NULL,
  reservado_em DATETIME NULL,
  pago_em DATETIME NULL,
  usado_em DATETIME NULL,
  data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_codigo_voucher (codigo_voucher),
  UNIQUE KEY uk_transacao_id (transacao_id),
  INDEX idx_vouchers_status_pacote (pacote_id, status),
  CONSTRAINT fk_vouchers_pacotes FOREIGN KEY (pacote_id) REFERENCES pacotes(id)
);

CREATE TABLE IF NOT EXISTS payment_events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  provider VARCHAR(30) NULL,
  reference VARCHAR(80) NULL,
  status VARCHAR(80) NULL,
  payload JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_payment_events_reference (reference)
);

INSERT INTO pacotes (id, nome, tempo, categoria, preco, perfil_mikrotik, ordem, ativo) VALUES
  (1, 'Matinal', '2 Horas', 'horas', 5.00, 'Matinal', 1, 1),
  (2, 'Expediente', '5 Horas', 'horas', 10.00, 'Expediente', 2, 1),
  (3, 'Dia a Dia', '1 Dia', 'dias', 20.00, 'Dia_a_Dia', 3, 1),
  (4, 'Fim de Semana', '3 Dias', 'dias', 60.00, 'Fim_de_Semana', 4, 1),
  (5, 'Toda Semana', '1 Semana', 'semanal', 100.00, 'Toda_Semana', 5, 1),
  (6, 'Super Net', '4 Semanas', 'semanal', 550.00, 'Super_Net', 6, 1)
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  tempo = VALUES(tempo),
  categoria = VALUES(categoria),
  preco = VALUES(preco),
  perfil_mikrotik = VALUES(perfil_mikrotik),
  ordem = VALUES(ordem),
  ativo = VALUES(ativo);

INSERT IGNORE INTO vouchers (pacote_id, codigo_voucher, senha_voucher, status) VALUES
  (1, 'VCH10001', '2101', 'disponivel'),
  (1, 'VCH10002', '2102', 'disponivel'),
  (1, 'VCH10003', '2103', 'disponivel'),
  (2, 'VCH20001', '2201', 'disponivel'),
  (2, 'VCH20002', '2202', 'disponivel'),
  (2, 'VCH20003', '2203', 'disponivel'),
  (3, 'VCH30001', '2301', 'disponivel'),
  (3, 'VCH30002', '2302', 'disponivel'),
  (4, 'VCH40001', '2401', 'disponivel'),
  (4, 'VCH40002', '2402', 'disponivel'),
  (5, 'VCH50001', '2501', 'disponivel'),
  (5, 'VCH50002', '2502', 'disponivel'),
  (6, 'VCH60001', '2601', 'disponivel'),
  (6, 'VCH60002', '2602', 'disponivel');
