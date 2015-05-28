.bail ON
.mode columns
.headers on
.nullvalue NULL
PRAGMA foreign_keys = ON;

--um carro nao pode ser alugado na mesma data por clientes diferentes
--apaga o mais antigo (dá preferência ao mais recente)
CREATE TRIGGER ApagaAlugueresIncompativeis
AFTER INSERT ON FRANQUIA
FOR EACH ROW
BEGIN
	DELETE FROM FRANQUIA
		WHERE not(FRANQUIA.id_aluguer = NEW.id_aluguer) and 
			id_veiculo = NEW.id_veiculo and 
			(select julianday(Data_de_inicio) from ALUGUER
				where NEW.id_aluguer = ALUGUER.id_aluguer) <
			(select julianday(Data_de_fim) from ALUGUER
				where ALUGUER.id_aluguer in
					(select FRANQUIA.id_aluguer from FRANQUIA
						where id_veiculo = NEW.id_veiculo
							and not(FRANQUIA.id_aluguer = NEW.id_aluguer)));
END;

CREATE VIEW clientesExpirados as
SELECT id_cliente, date('now') - data_de_fim as anosPassados
FROM (select id_cliente, Data_de_fim from ALUGUER)
WHERE anosPassados < 1;

--Apagar TaxasRisco de clientes que Não fazem alugueres há mais de um ano
CREATE TRIGGER ApagaClientesInativos
AFTER INSERT ON TAXA_RISCO
FOR EACH ROW
BEGIN
	DELETE FROM TAXA_RISCO
		WHERE 
		not(id_cliente IN (SELECT id_cliente FROM clientesExpirados));
END;