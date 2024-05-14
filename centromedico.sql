-- ---------------------------------------------------------------------------------------
-- FUNDAMENTOS DE BASE DE DADOS
-- 	Schema atendimento_centro_medico	
--
-- autor: Francisco Pedro Morais Gonçalves
-- https://github.com/fgonca
-- ---------------------------------------------------------------------------------------

CREATE DATABASE centro_medico DEFAULT CHARACTER SET utf8mb4;
USE centro_medico;

CREATE TABLE pessoa (
  numero INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NOT NULL,
  bi VARCHAR(45) NULL UNIQUE,
  sexo ENUM('Fem', 'Masc') NOT NULL,
  data_nasc DATE NOT NULL,
  morada VARCHAR(45) NULL,
  tipo ENUM('paciente', 'recepcionista', 'medico', 'gerente') NOT NULL,
  grupo_sanguineo VARCHAR(3) NULL,
  alergias VARCHAR(100) NULL,
  num_ordem VARCHAR(45) NULL UNIQUE,
  PRIMARY KEY (numero)
)ENGINE = InnoDB;

CREATE TABLE especialidade (
  id INT NOT NULL PRIMARY KEY  AUTO_INCREMENT,
  especialidade VARCHAR(45) NOT NULL UNIQUE
)ENGINE = InnoDB;

CREATE TABLE medico_especialidade (
  medico INT NOT NULL,
  especialidade INT NOT NULL,
  PRIMARY KEY (medico, especialidade),
  FOREIGN KEY (medico) REFERENCES Pessoa (numero),
  FOREIGN KEY (especialidade) REFERENCES especialidade (id)
)ENGINE = InnoDB;

CREATE TABLE consulta (
  medico INT NOT NULL,
  dia DATE NOT NULL,
  hora ENUM('08:00','08:15','08:30','08:45',
  '09:00','09:15','09:30','09:45', 
  '10:00','10:15','10:30','10:45',
  '11:00','11:15','11:30','11:45',
  '12:00','12:15','12:30','12:45',
  '13:00','13:15','13:30','13:45',
  '14:00','14:15','14:30','14:45',
  '15:00','15:15','15:30','15:45',
  '16:00','16:15','16:30','16:45',
  '17:00','17:15','17:30','17:45',
  '18:00','18:15','18:30','18:45'),
  estado ENUM('Não atendida', 'Atendida', 'Cancelada') NOT NULL DEFAULT 'Não atendida',
  paciente_presente ENUM('Sim', 'Não') NOT NULL DEFAULT 'Não',
  paciente INT NOT NULL,
  especialidade INT NOT NULL,
  PRIMARY KEY (medico, dia, hora),
  FOREIGN KEY (paciente) REFERENCES pessoa (numero),
  FOREIGN KEY (medico, especialidade) 
	REFERENCES medico_especialidade (medico, especialidade)
)ENGINE = InnoDB;

CREATE TABLE usuario (
  id INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NOT NULL UNIQUE,
  senha VARCHAR(45) NOT NULL,
  pessoa INT NOT NULL,
  papel ENUM('paciente', 'recepcionista', 'medico', 'gerente') NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (pessoa) REFERENCES pessoa(numero)
)ENGINE = InnoDB;

#Criar uma vista para ver médico especialidade
CREATE VIEW vista_medico_especialidade AS
SELECT pessoa.numero AS numero_medico, pessoa.nome AS medico, 
	especialidade.id AS id_especialidade, especialidade.especialidade
FROM pessoa
JOIN medico_especialidade
JOIN especialidade
ON medico_especialidade.medico= pessoa.numero
AND medico_especialidade.especialidade= especialidade.id
ORDER BY pessoa.nome;

# Criar uma vista para consultas
CREATE VIEW vista_consulta AS
SELECT 
consulta.dia,
consulta.hora,
consulta.estado, 
consulta.paciente_presente,
especialidade.especialidade,
p.numero AS numero_paciente, 
p.nome AS nome_paciente,
p.bi AS bi_paciente,
p.sexo AS sexo_paciente,
p.data_nasc AS data_nasc_paciente,
m.numero AS numero_medico, 
m.nome AS nome_medico,
m.sexo AS sexo_medico,
m.num_ordem
FROM consulta
JOIN pessoa p
JOIN pessoa m
JOIN medico_especialidade
JOIN especialidade
ON consulta.especialidade= medico_especialidade.especialidade
AND consulta.paciente= p.numero
AND consulta.medico= medico_especialidade.medico
AND medico_especialidade.medico= m.numero
AND medico_especialidade.especialidade= especialidade.id
ORDER BY consulta.dia AND consulta.hora;

-- ---------------------------------------------------------------------------------------

#Inserir 3 médicos
INSERT INTO pessoa (nome, bi, sexo, data_nasc, morada, tipo, num_ordem) 
VALUES ('Kiene', 'BI01','Masc','2001-01-01','Luanda','medico','OM01'),
('Muene', 'BI02','Fem','2002-02-02','Luanda','medico','OM02'),
('Weza', 'BI03','Masc','2003-03-03','Luanda','medico','OM03');

#Inserir 6 pacientes
INSERT INTO pessoa (nome, bi, sexo, data_nasc, morada, tipo, grupo_sanguineo, alergias) 
VALUES ('Ngola', 'BI11','Masc','2011-11-11','Luanda','paciente','O+', ''),
('Ekwikwi', 'BI12','Masc','2012-12-12','Luanda','paciente','A+', ''),
('Lweji', 'BI13','Fem','2013-13-13','Luanda','paciente','B+', 'Pólen'),
('Mandume', 'BI14','Masc','2014-14-14','Luanda','paciente','B+', ''),
('Njinga', 'BI15','Fem','2015-15-15','Luanda','paciente','A+', 'Pó'),
('Lukeni', 'BI16','Masc','2016-16-16','Luanda','paciente','B+', 'Pó');

#Inserir gerente e recepcionista
INSERT INTO pessoa (nome, bi, sexo, data_nasc, morada, tipo) 
VALUES ('Lemba', 'BI21', 'Fem', '2004-04-04', 'Luanda', 'recepcionista'),
('Marcos', 'BI22', 'Masc', '2005-05-05', 'Luanda', 'gerente');

#Inserir especialidades
INSERT INTO especialidade (especialidade) VALUES('Doenças tropicais'),('Estomatologia'), 
	('Ortopedia');

#Definir especialidade dos médicos
INSERT INTO medico_especialidade VALUES(1,1), (1,3), (2,2), (3,2);

-- ---------------------------------------------------------------------------------------
#Consultar médicos
SELECT * FROM pessoa WHERE tipo="medico";

#Consultar pacientes
SELECT * FROM pessoa WHERE tipo="paciente";

#Consultar recepcionista
SELECT * FROM pessoa WHERE tipo="recepcionista";

#Consultar gerentes
SELECT * FROM pessoa WHERE tipo="gerente";

#Tentar incluir um médico com um num_ordem existente
INSERT INTO pessoa (nome, bi, sexo, data_nasc, morada, tipo, num_ordem) 
VALUES ('Daniela', 'BI04','Fem','2004-04-04','Luanda','Médico','OM03');

#Tentar incluir um paciente com um bi existente
INSERT INTO pessoa (nome, bi, sexo, data_nasc, morada, tipo, grupo_sanguineo, alergias) 
VALUES ('Xavier', 'BI11','Masc','2011-11-12','Luanda','Paciente','O-', 'Leite');

#Tentar colocar um médico com a mesma especialidade mais do que uma vez
INSERT INTO medico_especialidade VALUES(1,1);

#Ver médico especialidade
SELECT * FROM vista_medico_especialidade;

-- ---------------------------------------------------------------------------------------
# Inserir 3 consultas
INSERT INTO consulta (dia, hora, paciente, medico, especialidade) 
VALUES ('2024-01-01','10:00', '4','1','1'),
('2024-01-01','10:30', '5','1','1'),
('2024-01-01','11:30', '4','2','2');

# Tentar marcar uma consulta num horário já marcado
INSERT INTO consulta (dia, hora, paciente, medico, especialidade) 
VALUES ('2024-01-01','11:30', '5','2','2');

# Tentar inserir uma consulta duma especialidade que o médico não tem
INSERT INTO consulta (dia, hora, paciente, medico, especialidade) 
VALUES ('2024-01-01','08:00', '5','2','1');

# Ver consultas
SELECT * FROM consulta;

# Ver consultas com detalhes
SELECT * FROM vista_consulta;



