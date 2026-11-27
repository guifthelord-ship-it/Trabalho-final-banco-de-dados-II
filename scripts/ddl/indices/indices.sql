
-- FK + trigger
drop index if exists idx_analise_id_sinistro on analise_sinistro
go
create nonclustered index idx_analise_id_sinistro
    on analise_sinistro (id_sinistro)
    include (resultado, valor_aprovado)
go


-- Q3
drop index if exists idx_analise_resultado on analise_sinistro
go
create nonclustered index idx_analise_resultado
    on analise_sinistro (resultado)
    include (id_sinistro, valor_aprovado)
go

-- FK
drop index if exists idx_celular_id_cliente on celular
go
create nonclustered index idx_celular_id_cliente
    on celular (id_cliente)
go

-- Ordenação e busca do CRUD por nome
drop index if exists idx_cliente_nome on cliente
go
create nonclustered index idx_cliente_nome
    on cliente (nome)
go

-- FK + Q1
drop index if exists idx_contrato_id_celular on contrato
go
create nonclustered index idx_contrato_id_celular
    on contrato (id_celular)
    include (status)
go

-- FK + Q2 (inadimplentes)
drop index if exists idx_contrato_id_cliente on contrato
go
create nonclustered index idx_contrato_id_cliente
    on contrato (id_cliente)
go

-- FK + Q3
drop index if exists idx_contrato_id_plano on contrato
go
create nonclustered index idx_contrato_id_plano
    on contrato (id_plano)
go

-- Q4 (índice filtrado; INCLUDE evita Key Lookup)
drop index if exists idx_contrato_vencimento_ativo on contrato
go
create nonclustered index idx_contrato_vencimento_ativo
    on contrato (data_fim)
    include (id_cliente, id_celular, id_plano, numero_apolice, status)
    where status = 'ATIVO'
go

-- Q3 (índice filtrado: só mensalidades pagas)
drop index if exists idx_pagamento_pago on pagamento
go
create nonclustered index idx_pagamento_pago
    on pagamento (id_contrato)
    include (valor, status)
    where status = 'PAGO'
go

-- Q2 (índice filtrado: só mensalidades em aberto)
drop index if exists idx_pagamento_pendente on pagamento
go
create nonclustered index idx_pagamento_pendente
    on pagamento (data_vencimento)
    include (id_contrato, valor, status)
    where status = 'PENDENTE'
go