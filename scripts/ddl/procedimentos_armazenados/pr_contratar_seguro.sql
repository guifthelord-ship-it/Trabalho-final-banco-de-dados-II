--contrata o seguro de um celular: cria o contrato (apólice) e gera todas as mensalidades em uma única transação. Se qualquer passo falhar, nada é gravado.
--validações:
--quantidade de meses entre 1 e 24 e forma de pagamento válida
--celular e plano precisam existir (o cliente do contrato é buscado no celular)
--o celular não pode ter outro contrato ATIVO ou SUSPENSO no mesmo período
--número da apólice: APL-AAAAMMDD-<id do celular com 6 dígitos>  (ex.: APL-20261120-000050)

-- mensalidades: uma por mês, a partir da data de início, no valor mensal do plano.
--exemplo:
 --declare @novo int;
--exec pr_contratar_seguro @id_celular = 50, @id_plano = 2, @forma_pagamento = 'PIX',
--@id_contrato = @novo output;

create procedure pr_contratar_seguro
    @id_celular      int,
    @id_plano        int,
    @forma_pagamento varchar(30),
    @data_inicio     date    = null,
    @qt_meses        tinyint = 12,
    @id_contrato     int     output
as
begin
    set nocount on;
    set xact_abort on;   -- qualquer erro desfaz a transação inteira

    declare @valor_mensal   decimal(10,2),
            @id_cliente     int,
            @data_fim       date,
            @numero_apolice varchar(30),
            @n              tinyint = 1;

    set @data_inicio = isnull(@data_inicio, cast(getdate() as date));

    if @qt_meses is null or @qt_meses not between 1 and 24
        throw 50001, 'A quantidade de meses deve estar entre 1 e 24.', 1;

    if @forma_pagamento is null or @forma_pagamento not in ('BOLETO','CARTAO','PIX','DEBITO')
        throw 50002, 'Forma de pagamento inválida (use BOLETO, CARTAO, PIX ou DEBITO).', 1;

-- o titular do contrato é sempre o dono do celular
select @id_cliente = id_cliente
from celular
     where id_celular = @id_celular;

	if @id_cliente is null
	throw 50003, 'Celular não encontrado.', 1;

select @valor_mensal = valor_mensal
from plano_seguro
     where id_plano = @id_plano;

	if @valor_mensal is null
	throw 50004, 'Plano de seguro não encontrado.', 1;

set @data_fim = dateadd(month, @qt_meses, @data_inicio);

    if exists (select 1
                 from contrato
                where id_celular = @id_celular
                  and status in ('ATIVO','SUSPENSO')
                  and data_inicio < @data_fim
                  and data_fim    > @data_inicio)
        throw 50005, 'Este celular já possui contrato vigente no período.', 1;

set @numero_apolice = 'APL-' + convert(char(8), @data_inicio, 112) + '-'
                        + right('000000' + cast(@id_celular as varchar(10)), 6);

begin transaction;

	insert into contrato (id_cliente, id_celular, id_plano, numero_apolice, data_inicio, data_fim, status)
	values (@id_cliente, @id_celular, @id_plano, @numero_apolice, @data_inicio, @data_fim, 'ATIVO');

set @id_contrato = scope_identity();

	while @n <= @qt_meses
	begin
	insert into pagamento (id_contrato, data_vencimento, valor, forma_pagamento, status)
	values (@id_contrato, dateadd(month, @n - 1, @data_inicio), @valor_mensal, @forma_pagamento, 'PENDENTE');

	set @n += 1;
end

    commit transaction;
end
go
