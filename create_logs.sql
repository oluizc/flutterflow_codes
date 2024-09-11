-- Trigger exemple
CREATE TRIGGER trigger_log_client_changes
AFTER UPDATE ON clientes
FOR EACH ROW
EXECUTE FUNCTION log_client_changes();

-- Insert
CREATE OR REPLACE FUNCTION log_client_insert()
RETURNS TRIGGER AS $$
DECLARE
  user_nome TEXT;
  user_email TEXT;
BEGIN
  -- Buscar o nome e o e-mail do usuário que fez a inserção
  SELECT u.user_nome, u.user_email
  INTO user_nome, user_email
  FROM users u
  WHERE u.user_id = auth.uid()::uuid;  -- Cast explícito de auth.uid() para UUID

  -- Inserir o log para a inserção, incluindo todos os campos do cliente
  INSERT INTO logs_clientes (cliente_id, created_at, data, ref_tipo_log_id)
  VALUES (
    NEW.cliente_id,  -- ID do cliente inserido
    now(),           -- Data e hora da inserção
    jsonb_build_object(
      'user_nome', user_nome,
      'user_email', user_email,
      'cliente_id', NEW.cliente_id,
      'razao_social', NEW.razao_social,
      'cnpj', NEW.cnpj,
      'data', to_jsonb(NEW)  -- Inclui todas as colunas do cliente no log
    ),  -- Inclui as informações do usuário e o log de inserção com todos os dados do cliente
    2  -- ID do tipo de log, que corresponde a "insert"
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Delete
CREATE OR REPLACE FUNCTION log_client_delete()
RETURNS TRIGGER AS $$
DECLARE
  user_nome TEXT;
  user_email TEXT;
BEGIN
  -- Buscar o nome e o e-mail do usuário que fez a exclusão
  SELECT u.user_nome, u.user_email
  INTO user_nome, user_email
  FROM users u
  WHERE u.user_id = auth.uid()::uuid;  -- Cast explícito de auth.uid() para UUID

  -- Inserir o log para a exclusão
  INSERT INTO logs_clientes (cliente_id, created_at, data, ref_tipo_log_id)
  VALUES (
    NULL,  -- Definir cliente_id como NULL, já que o cliente está sendo excluído
    now(),           -- Data e hora da exclusão
    jsonb_build_object(
      'user_nome', user_nome,
      'user_email', user_email,
      'razao_social', OLD.razao_social,
      'cnpj', OLD.cnpj,
      'data', jsonb_build_object(
        'cliente', 'Excluído com sucesso'
      )
    ),  -- Inclui as informações do usuário e o log de exclusão
    3  -- ID do tipo de log, que corresponde a "delete"
  );

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;


-- Update
CREATE OR REPLACE FUNCTION log_client_changes()
RETURNS TRIGGER AS $$
DECLARE
  user_nome TEXT;
  user_email TEXT;
  cliente_razao_social TEXT;
  cliente_cnpj TEXT;
  cliente_id_val INT;
BEGIN
  -- Buscar o nome e o e-mail do usuário que fez a alteração
  SELECT u.user_nome, u.user_email
  INTO user_nome, user_email
  FROM users u
  WHERE u.user_id = auth.uid()::uuid;  -- Cast explícito de auth.uid() para UUID

  -- Buscar as informações do cliente
  SELECT NEW.razao_social, NEW.cnpj, NEW.cliente_id
  INTO cliente_razao_social, cliente_cnpj, cliente_id_val;

  -- Inserir o log para a alteração
  INSERT INTO logs_clientes (cliente_id, created_at, data, ref_tipo_log_id)
  VALUES (
    NEW.cliente_id,  -- ID do cliente sendo alterado
    now(),           -- Data e hora da alteração
    jsonb_build_object(
      'user_nome', user_nome,
      'user_email', user_email,
      'cliente_id', cliente_id_val,
      'razao_social', cliente_razao_social,
      'cnpj', cliente_cnpj,
      'data', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'column', old_data.key, 
            'old', old_val, 
            'new', new_val
          )
        )
        FROM jsonb_each_text(to_jsonb(OLD)) AS old_data(key, old_val)
        JOIN jsonb_each_text(to_jsonb(NEW)) AS new_data(key, new_val)
        ON old_data.key = new_data.key
        WHERE old_val IS DISTINCT FROM new_val
      )
    ),  -- Inclui as informações do usuário e os dados alterados
    1  -- ID do tipo de log, que corresponde a "update"
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
