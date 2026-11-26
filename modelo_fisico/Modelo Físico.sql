CREATE TABLE [seguradora] (
  [id_seguradora] int IDENTITY(1,1),
  [nome] varchar(100),
  [cnpj] varchar(14),
  [telefone] varchar(15),
  [email] varchar(150),
  CONSTRAINT [ck_seguradora_cnpj] CHECK (len(cnpj) = 14 and cnpj not like '%[^0-9]%'),
  CONSTRAINT [ck_seguradora_telefone] CHECK (len(telefone) >= 10 and telefone not like '%[^0-9]%'),
  CONSTRAINT [ck_seguradora_email] CHECK (email like '%_@_%._%'),
  PRIMARY KEY ([id_seguradora])
)
GO

CREATE TABLE [plano_seguro] (
  [id_plano] int IDENTITY(1,1),
  [id_seguradora] int,
  [nome_plano] varchar(80),
  [descricao] varchar(200),
  [valor_mensal] decimal(10,2),
  [percentual_cobertura] decimal(5,2),
  CONSTRAINT [ck_plano_seguro_valor_mensal] CHECK (valor_mensal > 0),
  CONSTRAINT [ck_plano_seguro_percentual] CHECK (percentual_cobertura between 1 and 100),
  PRIMARY KEY ([id_plano])
)
GO

CREATE TABLE [cobertura] (
  [id_cobertura] int IDENTITY(1,1),
  [nome] varchar(80),
  [descricao] varchar(200),
  [limite_indenizacao] decimal(10,2),
  CONSTRAINT [ck_cobertura_limite] CHECK (limite_indenizacao > 0),
  PRIMARY KEY ([id_cobertura])
)
GO

CREATE TABLE [plano_cobertura] (
  [id_plano_cobertura] int IDENTITY(1,1),
  [id_plano] int,
  [id_cobertura] int,
  [valor_franquia] decimal(10,2) DEFAULT (0),
  [limite_indenizacao] decimal(10,2),
  CONSTRAINT [ck_plano_cobertura_franquia] CHECK (valor_franquia >= 0),
  CONSTRAINT [ck_plano_cobertura_limite] CHECK (limite_indenizacao > 0 and valor_franquia < limite_indenizacao),
  PRIMARY KEY ([id_plano_cobertura])
)
GO

CREATE TABLE [cliente] (
  [id_cliente] int IDENTITY(1,1),
  [nome] varchar(100),
  [cpf] varchar(11),
  [telefone] varchar(15),
  [email] varchar(150),
  [endereco] varchar(150),
  [data_nascimento] date,
  CONSTRAINT [ck_cliente_cpf] CHECK (len(cpf) = 11 and cpf not like '%[^0-9]%'),
  CONSTRAINT [ck_cliente_telefone] CHECK (len(telefone) >= 10 and telefone not like '%[^0-9]%'),
  CONSTRAINT [ck_cliente_email] CHECK (email like '%_@_%._%'),
  CONSTRAINT [ck_cliente_nascimento] CHECK (data_nascimento >= '1900-01-01'),
  PRIMARY KEY ([id_cliente])
)
GO

CREATE TABLE [celular] (
  [id_celular] int IDENTITY(1,1),
  [id_cliente] int,
  [marca] varchar(50),
  [modelo] varchar(80),
  [imei] varchar(15),
  [valor_aparelho] decimal(10,2),
  [data_compra] date,
  CONSTRAINT [ck_celular_imei] CHECK (len(imei) = 15 and imei not like '%[^0-9]%'),
  CONSTRAINT [ck_celular_valor] CHECK (valor_aparelho > 0),
  CONSTRAINT [ck_celular_data_compra] CHECK (data_compra >= '2000-01-01'),
  PRIMARY KEY ([id_celular])
)
GO

CREATE TABLE [contrato] (
  [id_contrato] int IDENTITY(1,1),
  [id_cliente] int,
  [id_celular] int,
  [id_plano] int,
  [numero_apolice] varchar(30),
  [data_inicio] date,
  [data_fim] date,
  [status] varchar(20) DEFAULT 'ATIVO',
  CONSTRAINT [ck_contrato_vigencia] CHECK (data_fim > data_inicio),
  CONSTRAINT [ck_contrato_status] CHECK (status in ('ATIVO','SUSPENSO','CANCELADO','ENCERRADO')),
  PRIMARY KEY ([id_contrato])
)
GO

CREATE TABLE [pagamento] (
  [id_pagamento] int IDENTITY(1,1),
  [id_contrato] int,
  [data_vencimento] date,
  [data_pagamento] date,
  [valor] decimal(10,2),
  [forma_pagamento] varchar(30),
  [status] varchar(20) DEFAULT 'PENDENTE',
  CONSTRAINT [ck_pagamento_valor] CHECK (valor > 0),
  CONSTRAINT [ck_pagamento_forma] CHECK (forma_pagamento in ('BOLETO','CARTAO','PIX','DEBITO')),
  CONSTRAINT [ck_pagamento_status] CHECK (status in ('PENDENTE','PAGO','CANCELADO')),
  CONSTRAINT [ck_pagamento_pago] CHECK ((status = 'PAGO' and data_pagamento is not null) or (status <> 'PAGO' and data_pagamento is null)),
  PRIMARY KEY ([id_pagamento])
)
GO

CREATE TABLE [tipo_sinistro] (
  [id_tipo_sinistro] int IDENTITY(1,1),
  [nome] varchar(50),
  [descricao] varchar(200),
  PRIMARY KEY ([id_tipo_sinistro])
)
GO

CREATE TABLE [sinistro] (
  [id_sinistro] int IDENTITY(1,1),
  [id_contrato] int,
  [id_tipo_sinistro] int,
  [numero_protocolo] varchar(30),
  [data_ocorrencia] date,
  [data_abertura] datetime DEFAULT (getdate()),
  [descricao] varchar(300),
  [valor_prejuizo] decimal(10,2),
  [status] varchar(30) DEFAULT 'ABERTO',
  CONSTRAINT [ck_sinistro_datas] CHECK (data_ocorrencia <= cast(data_abertura as date)),
  CONSTRAINT [ck_sinistro_prejuizo] CHECK (valor_prejuizo > 0),
  CONSTRAINT [ck_sinistro_status] CHECK (status in ('ABERTO','EM_ANALISE','APROVADO','NEGADO','INDENIZADO')),
  PRIMARY KEY ([id_sinistro])
)
GO

CREATE TABLE [analise_sinistro] (
  [id_analise] int IDENTITY(1,1),
  [id_sinistro] int,
  [data_analise] date DEFAULT (getdate()),
  [parecer] varchar(300),
  [resultado] varchar(30),
  [valor_aprovado] decimal(10,2),
  CONSTRAINT [ck_analise_resultado] CHECK (resultado in ('APROVADO','NEGADO','PENDENTE')),
  CONSTRAINT [ck_analise_valor] CHECK (valor_aprovado is null or (resultado = 'APROVADO' and valor_aprovado >= 0)),
  PRIMARY KEY ([id_analise])
)
GO

CREATE TABLE [reparo] (
  [id_reparo] int IDENTITY(1,1),
  [id_sinistro] int,
  [nome_assistencia] varchar(100),
  [data_entrada] date,
  [data_saida] date,
  [descricao_servico] varchar(300),
  [valor_reparo] decimal(10,2),
  CONSTRAINT [ck_reparo_datas] CHECK (data_saida is null or data_saida >= data_entrada),
  CONSTRAINT [ck_reparo_valor] CHECK (valor_reparo is null or valor_reparo >= 0),
  PRIMARY KEY ([id_reparo])
)
GO

CREATE TABLE [reclamacao] (
  [id_reclamacao] int IDENTITY(1,1),
  [id_cliente] int,
  [id_contrato] int,
  [data_reclamacao] date DEFAULT (getdate()),
  [data_analise] date,
  [descricao] varchar(300),
  [parecer] varchar(300),
  [resultado] varchar(30),
  [valor_aprovado] decimal(10,2),
  [status] varchar(30) DEFAULT 'ABERTA',
  CONSTRAINT [ck_reclamacao_resultado] CHECK (resultado is null or resultado in ('PROCEDENTE','IMPROCEDENTE')),
  CONSTRAINT [ck_reclamacao_analise] CHECK ((data_analise is null and parecer is null and resultado is null) or (data_analise is not null and parecer is not null and resultado is not null)),
  CONSTRAINT [ck_reclamacao_datas] CHECK (data_analise is null or data_analise >= data_reclamacao),
  CONSTRAINT [ck_reclamacao_valor] CHECK (valor_aprovado is null or (resultado = 'PROCEDENTE' and valor_aprovado >= 0)),
  CONSTRAINT [ck_reclamacao_status] CHECK (status is null or status in ('ABERTA','RESPONDIDA')),
  PRIMARY KEY ([id_reclamacao])
)
GO

CREATE UNIQUE INDEX [uq_seguradora_cnpj] ON [seguradora] ("cnpj")
GO

CREATE UNIQUE INDEX [uq_seguradora_email] ON [seguradora] ("email")
GO

CREATE UNIQUE INDEX [uq_plano_seguro_seguradora_nome] ON [plano_seguro] ("id_seguradora", "nome_plano")
GO

CREATE UNIQUE INDEX [uq_cobertura_nome] ON [cobertura] ("nome")
GO

CREATE UNIQUE INDEX [uq_plano_cobertura_plano_cobertura] ON [plano_cobertura] ("id_plano", "id_cobertura")
GO

CREATE UNIQUE INDEX [uq_cliente_cpf] ON [cliente] ("cpf")
GO

CREATE UNIQUE INDEX [uq_cliente_email] ON [cliente] ("email")
GO

CREATE UNIQUE INDEX [uq_celular_imei] ON [celular] ("imei")
GO

CREATE UNIQUE INDEX [uq_celular_id_celular_cliente] ON [celular] ("id_celular", "id_cliente")
GO

CREATE UNIQUE INDEX [uq_contrato_numero_apolice] ON [contrato] ("numero_apolice")
GO

CREATE UNIQUE INDEX [uq_contrato_id_contrato_cliente] ON [contrato] ("id_contrato", "id_cliente")
GO

CREATE UNIQUE INDEX [uq_pagamento_contrato_vencimento] ON [pagamento] ("id_contrato", "data_vencimento")
GO

CREATE UNIQUE INDEX [uq_tipo_sinistro_nome] ON [tipo_sinistro] ("nome")
GO

CREATE UNIQUE INDEX [uq_sinistro_protocolo] ON [sinistro] ("numero_protocolo")
GO

ALTER TABLE [plano_seguro] ADD CONSTRAINT [fk_plano_seguro_seguradora] FOREIGN KEY ([id_seguradora]) REFERENCES [seguradora] ([id_seguradora])
GO

ALTER TABLE [plano_cobertura] ADD CONSTRAINT [fk_plano_cobertura_plano_seguro] FOREIGN KEY ([id_plano]) REFERENCES [plano_seguro] ([id_plano])
GO

ALTER TABLE [plano_cobertura] ADD CONSTRAINT [fk_plano_cobertura_cobertura] FOREIGN KEY ([id_cobertura]) REFERENCES [cobertura] ([id_cobertura])
GO

ALTER TABLE [celular] ADD CONSTRAINT [fk_celular_cliente] FOREIGN KEY ([id_cliente]) REFERENCES [cliente] ([id_cliente])
GO

ALTER TABLE [contrato] ADD CONSTRAINT [fk_contrato_cliente] FOREIGN KEY ([id_cliente]) REFERENCES [cliente] ([id_cliente])
GO

ALTER TABLE [contrato] ADD CONSTRAINT [fk_contrato_celular] FOREIGN KEY ([id_celular]) REFERENCES [celular] ([id_celular])
GO

ALTER TABLE [contrato] ADD CONSTRAINT [fk_contrato_plano_seguro] FOREIGN KEY ([id_plano]) REFERENCES [plano_seguro] ([id_plano])
GO

ALTER TABLE [contrato] ADD CONSTRAINT [fk_contrato_celular_dono] FOREIGN KEY ([id_celular], [id_cliente]) REFERENCES [celular] ([id_celular], [id_cliente])
GO

ALTER TABLE [pagamento] ADD CONSTRAINT [fk_pagamento_contrato] FOREIGN KEY ([id_contrato]) REFERENCES [contrato] ([id_contrato])
GO

ALTER TABLE [sinistro] ADD CONSTRAINT [fk_sinistro_contrato] FOREIGN KEY ([id_contrato]) REFERENCES [contrato] ([id_contrato])
GO

ALTER TABLE [sinistro] ADD CONSTRAINT [fk_sinistro_tipo_sinistro] FOREIGN KEY ([id_tipo_sinistro]) REFERENCES [tipo_sinistro] ([id_tipo_sinistro])
GO

ALTER TABLE [analise_sinistro] ADD CONSTRAINT [fk_analise_sinistro_sinistro] FOREIGN KEY ([id_sinistro]) REFERENCES [sinistro] ([id_sinistro])
GO

ALTER TABLE [reparo] ADD CONSTRAINT [fk_reparo_sinistro] FOREIGN KEY ([id_sinistro]) REFERENCES [sinistro] ([id_sinistro])
GO

ALTER TABLE [reclamacao] ADD CONSTRAINT [fk_reclamacao_cliente] FOREIGN KEY ([id_cliente]) REFERENCES [cliente] ([id_cliente])
GO

ALTER TABLE [reclamacao] ADD CONSTRAINT [fk_reclamacao_contrato] FOREIGN KEY ([id_contrato]) REFERENCES [contrato] ([id_contrato])
GO

ALTER TABLE [reclamacao] ADD CONSTRAINT [fk_reclamacao_contrato_titular] FOREIGN KEY ([id_contrato], [id_cliente]) REFERENCES [contrato] ([id_contrato], [id_cliente])
GO
