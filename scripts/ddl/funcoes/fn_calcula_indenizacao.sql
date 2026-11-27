--a função calcula quanto a seguradora deve indenizar em um sinistro, seguindo as regras do plano contratado:
-- a data da ocorrência precisa estar dentro da vigência do contrato (senão retorna 0,00)
-- o teto da indenização é o percentual do aparelho coberto pelo plano: celular.valor_aparelho x plano_seguro.percentual_cobertura / 100
--a indenização é o MENOR valor entre o prejuízo declarado (sinistro.valor_prejuizo) e esse teto.
-- usada pelo trigger tg_analise_sinistro (preenche o valor aprovado) e pela consulta Q5 (indenização estimada).

create function fn_calcula_indenizacao (
    @id_sinistro int
)
returns decimal(10,2)
as
begin
    declare @valor_prejuizo  decimal(10,2),
            @data_ocorrencia date,
            @data_inicio     date,
            @data_fim        date,
            @teto_aparelho   decimal(10,2);

    select @valor_prejuizo  = s.valor_prejuizo,
           @data_ocorrencia = s.data_ocorrencia,
           @data_inicio     = c.data_inicio,
           @data_fim        = c.data_fim,
           @teto_aparelho   = round(ce.valor_aparelho * p.percentual_cobertura / 100, 2)
      from sinistro s
      join contrato     c  on c.id_contrato = s.id_contrato
      join celular      ce on ce.id_celular = c.id_celular
      join plano_seguro p  on p.id_plano    = c.id_plano
     where s.id_sinistro = @id_sinistro;

-- regra 1: sinistro inexistente ou fora da vigência
if @valor_prejuizo is null or @data_ocorrencia < @data_inicio or @data_ocorrencia > @data_fim
        return 0;

-- regras 2 e 3: menor valor entre prejuízo e percentual do aparelho
return case when @valor_prejuizo < @teto_aparelho then @valor_prejuizo else @teto_aparelho end;
end
go
