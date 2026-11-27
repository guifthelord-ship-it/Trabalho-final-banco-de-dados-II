--remove todos os objetos para recriar o banco do zero (ordem inversa das FKs).

drop trigger   if exists tg_analise_sinistro
drop procedure if exists pr_contratar_seguro
drop function  if exists fn_calcula_indenizacao
go
drop table if exists reclamacao
drop table if exists reparo
drop table if exists analise_sinistro
drop table if exists sinistro
drop table if exists tipo_sinistro
drop table if exists pagamento
drop table if exists contrato
drop table if exists celular
drop table if exists cliente
drop table if exists plano_cobertura
drop table if exists cobertura
drop table if exists plano_seguro
drop table if exists seguradora
go
