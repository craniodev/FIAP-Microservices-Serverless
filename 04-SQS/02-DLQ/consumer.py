from sqsHandler import SqsHandler

sqs = SqsHandler('<url da sua fila>')


while(True):
    # long polling de 20s: sem ele a chamada volta vazia enquanto as mensagens
    # estao invisiveis e o loop encerra antes de a redelivery levar tudo para a DLQ
    response = sqs.getMessage(10, 20)

    # a SQS omite a chave 'Messages' quando nao ha nada visivel na fila
    if('Messages' not in response):
        break

    for msg in response['Messages']:
        print(msg['MessageId'])
