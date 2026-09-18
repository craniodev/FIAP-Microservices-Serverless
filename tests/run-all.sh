#!/usr/bin/env bash
# Valida OFFLINE os artefatos de codigo que os READMEs dos labs mandam o aluno criar
# (serverless.yml/handler/json schema/scripts shell), sem depender de credenciais AWS.
#
# Convencao: stdout carrega so o resultado (linhas PASS/FAIL, uma por check).
# stderr carrega progresso/avisos. Idempotente: cada execucao limpa e recria seu
# proprio diretorio de trabalho e a imagem docker, sem depender de estado anterior.
set -euo pipefail

log() { printf '%s\n' "$*" >&2; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_TAG="fiap-lab-test:latest"
WORK_DIR="$(mktemp -d /tmp/lab-validate-run.XXXXXX)"
trap 'rm -rf "$WORK_DIR"' EXIT

log "== Diretorio de trabalho temporario: $WORK_DIR =="

log "-- Build da imagem de teste ($IMAGE_TAG) a partir de .devcontainer/Dockerfile.test --"
docker build -q -f "$REPO_ROOT/.devcontainer/Dockerfile.test" -t "$IMAGE_TAG" "$REPO_ROOT" >&2

REF="${1:-master}"
log "-- Materializando artefatos extraidos dos READMEs (git show $REF:<arquivo>) em $WORK_DIR --"

mkdir -p \
  "$WORK_DIR/03-api-gw-02-validacao" \
  "$WORK_DIR/03-api-gw-01" \
  "$WORK_DIR/05-atividade-final" \
  "$WORK_DIR/02-lambda-01-intro" \
  "$WORK_DIR/02-lambda-02-layers" \
  "$WORK_DIR/04-sqs-shell" \
  "$WORK_DIR/04-sqs-existentes"

# --- 03-API-Gateway/02-Validacao-Autenticacao: handler python + json schema + bodies ---
cat > "$WORK_DIR/03-api-gw-02-validacao/handler.py" <<'PYEOF'
import json

def lambda_handler(event, context):

    print(json.dumps(event))
    response = json.loads(event["body"])
    response["Response"]="Validated API"

    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
PYEOF

cat > "$WORK_DIR/03-api-gw-02-validacao/UserCreateRequest.schema.json" <<'JSONEOF'
{
    "title": "Root Schema",
    "type": "object",
    "required": ["name", "age", "dateofregistry"],
    "additionalProperties": false,
    "properties": {
        "name": {"title": "The name Schema", "type": "string"},
        "age": {"title": "The age Schema", "minimum": 0, "maximum": 100, "type": "integer"},
        "dateofregistry": {"title": "The dateofregistry Schema", "pattern": "^\\d{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01])$", "type": "string"}
    }
}
JSONEOF

echo '{"message": "$context.error.message", "error": "$context.error.validationErrorString"}' \
  > "$WORK_DIR/03-api-gw-02-validacao/error-response-body.json"

cat > "$WORK_DIR/03-api-gw-02-validacao/test-body-valid.json" <<'JSONEOF'
{"name": "Jose Silva", "age": 43, "dateofregistry": "1989-10-13"}
JSONEOF

cat > "$WORK_DIR/03-api-gw-02-validacao/test-body-invalid-missing-age.json" <<'JSONEOF'
{"name": "Jose Silva", "dateofregistry": "1989-10-13"}
JSONEOF

echo '{"type": "dog", "price": 249.99}' > "$WORK_DIR/03-api-gw-01/test-body-pets.json"

# --- 05-Atividade-final: yaml fragments + python + json de exemplo ---
cat > "$WORK_DIR/05-atividade-final/serverless-http.yml" <<'YMLEOF'
functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: post
          cors: true
YMLEOF

cat > "$WORK_DIR/05-atividade-final/serverless-schema.yml" <<'YMLEOF'
functions:
  create:
    handler: posts.create
    events:
      - http:
          path: posts/create
          method: post
          request:
            schemas:
              application/json: ${file(create_request.json)}
YMLEOF

cat > "$WORK_DIR/05-atividade-final/dynamo_insert.py" <<'PYEOF'
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FeedbacksReclamacoes')

def inserir_feedback(id_cliente, descricao, categoria, data_hora):
    response = table.put_item(
        Item={
            'id_cliente': id_cliente,
            'descricao': descricao,
            'categoria': categoria,
            'data_hora': data_hora
        }
    )
    return response
PYEOF

echo '{"id_cliente": "12345", "descricao": "teste", "categoria": "reclamação", "data_hora": "2024-07-29T14:48:00Z"}' \
  > "$WORK_DIR/05-atividade-final/exemplo1.json"

cat > "$WORK_DIR/05-atividade-final/create-queue.sh" <<'SHEOF'
aws sqs create-queue --queue-name FeedbacksReclamacoesQueue
SHEOF

cat > "$WORK_DIR/05-atividade-final/create-dynamodb.sh" <<'SHEOF'
aws dynamodb create-table \
   --table-name FeedbacksReclamacoes \
   --attribute-definitions AttributeName=id_cliente,AttributeType=S AttributeName=data_hora,AttributeType=S \
   --key-schema AttributeName=id_cliente,KeyType=HASH AttributeName=data_hora,KeyType=RANGE \
   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
SHEOF

# --- 04-SQS: comandos shell dos READMEs (validacao sintatica, exigem credencial pra rodar de verdade) ---
cat > "$WORK_DIR/04-sqs-shell/purge-queues.sh" <<'SHEOF'
for queue_url in $(aws sqs list-queues --query 'QueueUrls[*]' --output text); do
    aws sqs purge-queue --queue-url "$queue_url"
    echo "Purged queue: $queue_url"
done
SHEOF

cat > "$WORK_DIR/04-sqs-shell/get-queue-arn.sh" <<'SHEOF'
demoqueueURL=`aws sqs get-queue-url --queue-name demoqueue | jq -r .QueueUrl` && aws sqs get-queue-attributes --queue-url $demoqueueURL --attribute-names QueueArn | jq -r .Attributes.QueueArn
SHEOF

# --- 02-Lambda/02-Layers: requirements.txt real do repo ---
cp "$REPO_ROOT/04-SQS/01-Standard-Queue/requirements.txt" "$WORK_DIR/02-lambda-02-layers/requirements.txt" 2>/dev/null \
  || echo "boto3" > "$WORK_DIR/02-lambda-02-layers/requirements.txt"

# --- 04-SQS: arquivos .py JA existentes no repo (nao vem do README, sao commitados) ---
for lab in 01-Standard-Queue 02-DLQ 03-Lambda; do
  mkdir -p "$WORK_DIR/04-sqs-existentes/$lab"
  for f in "$REPO_ROOT/04-SQS/$lab"/*.py; do
    [ -f "$f" ] && cp "$f" "$WORK_DIR/04-sqs-existentes/$lab/"
  done
done

log "-- Rodando checks dentro do container (${IMAGE_TAG}) --"

RESULTS="$(docker run --rm -v "$WORK_DIR:/work" "$IMAGE_TAG" bash -c '
set +e
pip3 install --break-system-packages --quiet jsonschema >/dev/null 2>&1

for f in $(find /work -name "*.py"); do
  python3 -m py_compile "$f" >/tmp/err 2>&1 && echo "PASS py_compile ${f#/work/}" || echo "FAIL py_compile ${f#/work/}: $(cat /tmp/err | tail -1)"
done

for f in $(find /work -name "*.json"); do
  python3 -c "import json; json.load(open(\"$f\"))" >/tmp/err 2>&1 && echo "PASS json ${f#/work/}" || echo "FAIL json ${f#/work/}: $(cat /tmp/err | tail -1)"
done

for f in $(find /work -name "*.yml" -o -name "*.yaml"); do
  python3 -c "import yaml; yaml.safe_load(open(\"$f\"))" >/tmp/err 2>&1 && echo "PASS yaml ${f#/work/}" || echo "FAIL yaml ${f#/work/}: $(cat /tmp/err | tail -1)"
done

for f in $(find /work -name "*.sh"); do
  bash -n "$f" >/tmp/err 2>&1 && echo "PASS shell-syntax ${f#/work/}" || echo "FAIL shell-syntax ${f#/work/}: $(cat /tmp/err | tail -1)"
done

python3 - <<PYEOF
import json, jsonschema
schema = json.load(open("/work/03-api-gw-02-validacao/UserCreateRequest.schema.json"))
valid = json.load(open("/work/03-api-gw-02-validacao/test-body-valid.json"))
invalid = json.load(open("/work/03-api-gw-02-validacao/test-body-invalid-missing-age.json"))
try:
    jsonschema.validate(valid, schema)
    print("PASS jsonschema-semantica aceita body valido")
except Exception as e:
    print(f"FAIL jsonschema-semantica deveria aceitar body valido: {e}")
try:
    jsonschema.validate(invalid, schema)
    print("FAIL jsonschema-semantica deveria rejeitar body sem age mas aceitou")
except jsonschema.exceptions.ValidationError:
    print("PASS jsonschema-semantica rejeita body sem campo obrigatorio")
PYEOF

cd /work/02-lambda-01-intro && sls create --template "aws-python3" >/tmp/err 2>&1 \
  && echo "PASS sls-create aws-python3 (scaffold 02-Lambda)" \
  || echo "FAIL sls-create aws-python3: $(tail -1 /tmp/err)"
sls print >/tmp/err 2>&1 && echo "PASS sls-print resolve serverless.yml offline" || echo "FAIL sls-print: $(tail -1 /tmp/err)"
sls package >/tmp/err 2>&1 && echo "PASS sls-package empacota offline" || echo "FAIL sls-package: $(tail -1 /tmp/err)"

cd /work/02-lambda-02-layers && pip3 install --break-system-packages -q -r requirements.txt -t layer >/tmp/err 2>&1 \
  && [ -d layer/boto3 ] \
  && echo "PASS pip-install-layer boto3 instalado em layer/ (02-Lambda/02-Layers)" \
  || echo "FAIL pip-install-layer: $(tail -1 /tmp/err)"
')"

log "-- Checks concluidos --"

echo "$RESULTS"

echo "$RESULTS" | grep -q '^FAIL' && exit 1 || exit 0
