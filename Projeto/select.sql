.bail ON
.mode columns
.headers on
.nullvalue NULL
PRAGMA foreign_keys = ON;

--Alugueres de cada funcionario
select funcionario, franquia, cliente
	from
		(select Nome_pessoa AS funcionario, id_aluguer as id2
			from PESSOA natural join FUNCIONARIO, ALUGUER
				where FUNCIONARIO.id_funcionario = ALUGUER.id_funcionario),			
		(select Nome_pessoa as cliente, id_aluguer as id1
			from PESSOA natural join CLIENTE, ALUGUER
				where CLIENTE.id_cliente = ALUGUER.id_cliente),
		(select Valor_franquia as franquia, id_aluguer as id3
			from FRANQUIA)
	where id1 = id2 and id1 = id3;

--Veiculos que nao foram alugados
select Matricula, Preco_aluguer
		from VEICULO where id_veiculo not in (select id_veiculo from ALUGUER);

--Media de precos dos carros, o somatorio, o numero de carros, o maior e menor preco		
select avg(Preco_aluguer) as "Media", sum(Preco_aluguer) as "ValorTotal", count(*) as "totalCarros", max(Preco_aluguer) as "Maximo", min(Preco_aluguer) as "Minimo"
	from VEICULO;
	
--Numero de alugueres por marca
select Nome_marca, count(distinct Nome_marca) as "Numero de alugueres" from MARCA_VEICULO where id_Marca in
(select id_Marca from MODELO_VEICULO where idModeloVeiculo in
(select idModeloVeiculo from VEICULO where id_veiculo in
(select id_veiculo
	from FRANQUIA
	intersect select id_veiculo from VEICULO)))
	group by Nome_marca;
	
--clientes e o numero total de dias de alugueres realizado pelo mesmo
select Nome_pessoa, sum(julianday(Data_de_fim) - julianday(Data_de_inicio)) as "Total de Dias"
	from ALUGUER, CLIENTE, PESSOA
	where PESSOA.id_pessoa = CLIENTE.id_pessoa and ALUGUER.id_cliente = CLIENTE.id_cliente
	group by ALUGUER.id_cliente;
	
--Marca dos veiculos cujo tipo de combustível é Gasóleo
select MARCA_VEICULO.Nome_marca AS Marca, TIPO_COMBUSTIVEL.Nome_combustivel
	from MARCA_VEICULO, MODELO_VEICULO, VEICULO, TIPO_COMBUSTIVEL
		where ((TIPO_COMBUSTIVEL.id_tipoCombustivel = VEICULO.id_tipoCombustivel)
		and (VEICULO.idModeloVeiculo = MODELO_VEICULO.idModeloVeiculo)
		and (MODELO_VEICULO.id_Marca = MARCA_VEICULO.id_Marca)
		and (TIPO_COMBUSTIVEL.Nome_combustivel = "GASOLEO"));

--Funcionarios em part_time
select PESSOA.Nome_pessoa AS Nome, TIPO_CONTRATO.Designacao_contrato
	from PESSOA, FUNCIONARIO, TIPO_CONTRATO
		where ((PESSOA.id_pessoa = FUNCIONARIO.id_pessoa)
			and (FUNCIONARIO.id_tipoContrato = TIPO_CONTRATO.id_tipoContrato)
			and (TIPO_CONTRATO.Designacao_contrato = "PART-TIME"));

--Estado atual de todos os veiculos (mostrando a sua marca e modelo)
select id_veiculo AS "ID Veiculo", Nome_marca AS "Marca", Nome_modelo AS "Modelo", Nome_estado AS "Estado atual do Veiculo"
	from VEICULO, ESTADO_ATUAL, MODELO_VEICULO, MARCA_VEICULO
		where ((VEICULO.id_estadoAtual = ESTADO_ATUAL.id_estadoAtual)
			and (VEICULO.idModeloVeiculo = MODELO_VEICULO.idModeloVeiculo)
			and (MODELO_VEICULO.id_Marca = MARCA_VEICULO.id_Marca));

--Qual a matricula do(s) carro(s) com o segundo aluguer mais duradouro
select  ALUGUER.id_aluguer AS "ID", FRANQUIA.id_veiculo AS "ID do Veiculo", MAX(julianday(ALUGUER.Data_de_fim) - julianday(ALUGUER.Data_de_inicio)) AS "Dias de aluguer"
	from ALUGUER, FRANQUIA
		where julianday(ALUGUER.Data_de_fim) - julianday(ALUGUER.Data_de_inicio)

			NOT IN (select MAX(julianday(ALUGUER.Data_de_fim) - julianday(ALUGUER.Data_de_inicio))
											from ALUGUER
												);
												
--Funcionarios que vivem na mesma localidade(GAIA)
select Nome_pessoa AS Funcionario, Nome_localidade
	from PESSOA natural join LOCALIDADE
		where (LOCALIDADE.id_localidade = PESSOA.id_localidade) and (LOCALIDADE.Nome_localidade = "GAIA"); --e so mudar este ultimo campo para obter localidades diferentes
