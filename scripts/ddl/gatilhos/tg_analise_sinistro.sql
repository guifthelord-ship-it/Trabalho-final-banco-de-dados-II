--toda vez que uma análise de sinistro é registrada:
--se o resultado for APROVADO e o valor aprovado não foi informado, calcula o valor com a função fn_calcula_indenizacao (regra única de cálculo para todo o sistema)
-- ou atualiza a situação do sinistro conforme a análise MAIS RECENTE de cada sinistro: APROVADO -> APROVADO - NEGADO -> NEGADO - PENDENTE -> EM_ANALISE (sinistros já INDENIZADOS não voltam de situação).
-- é set-based (usa a tabela virtual inserted), então funciona com INSERT de várias linhas de uma vez.

create trigger tg_analise_sinistro on analise_sinistro
after insert
as
begin

set nocount on;
if not exists (select 1 from inserted)
return;

-- calculando o valor aprovado quando não foi informado
update a
set valor_aprovado = dbo.fn_calcula_indenizacao(a.id_sinistro)
from analise_sinistro a
join inserted i on i.id_analise = a.id_analise
	where i.resultado = 'APROVADO'
	and i.valor_aprovado is null;

-- atualizando a situação do sinistro pela analise mais recente
update s
set status = case u.resultado
	when 'APROVADO' then 'APROVADO'
	when 'NEGADO'   then 'NEGADO'
	else 'EM_ANALISE'
end
from sinistro s
join (select i.id_sinistro,
		i.resultado,
		row_number() over (partition by i.id_sinistro
		order by i.data_analise desc, i.id_analise desc) as rn

from inserted i) u
	on u.id_sinistro = s.id_sinistro
	and u.rn = 1
	where s.status <> 'INDENIZADO';
end
go
