--DEMONSTRAÇÃO DA FUNÇÃO, DA PROCEDURE E DO TRIGGER (rodar depois do popula_tabelas.sql).


--funcao indenização calculada para cada sinistro aprovado x valor gravado na análise
select s.numero_protocolo,
       s.valor_prejuizo,
       dbo.fn_calcula_indenizacao(s.id_sinistro) as vl_calculado_pela_funcao,
       a.valor_aprovado                          as vl_gravado_na_analise
  from sinistro s
  join analise_sinistro a on a.id_sinistro = s.id_sinistro and a.resultado = 'APROVADO'
 order by s.id_sinistro;
go

-- procedure contrata um novo seguro para o celular 50 (o contrato anterior dele foi CANCELADO)
declare @novo_contrato int;

exec pr_contratar_seguro
     @id_celular      = 50,
     @id_plano        = 2,
     @forma_pagamento = 'PIX',
     @qt_meses        = 12,
     @id_contrato     = @novo_contrato output;

select * from contrato  where id_contrato = @novo_contrato;
select * from pagamento where id_contrato = @novo_contrato order by data_vencimento;
go

-- procedure barrando regra de negócio: o celular 1 já tem contrato ATIVO → erro 50005 (nada é gravado)
begin try
    declare @x int;
    exec pr_contratar_seguro @id_celular = 1, @id_plano = 2, @forma_pagamento = 'PIX', @id_contrato = @x output;
end try
begin catch
    select error_number() as nr_erro, error_message() as ds_erro;
end catch
go

--TRIGGER Antes: dois sinistros ABERTOS 
select id_sinistro, numero_protocolo, status from sinistro where id_sinistro in (14, 15);

insert into analise_sinistro (id_sinistro, parecer, resultado)
values (14, 'Documentação completa, sinistro coberto pelo plano.', 'APROVADO'),
       (15, 'Aguardando o boletim de ocorrência.',                 'PENDENTE');

-- Depois: 14 = APROVADO (com valor calculado pela função) e 15 = EM_ANALISE
select s.id_sinistro, s.numero_protocolo, s.status, a.resultado, a.valor_aprovado
  from sinistro s
  join analise_sinistro a on a.id_sinistro = s.id_sinistro
 where s.id_sinistro in (14, 15)
 order by a.id_analise;
go
