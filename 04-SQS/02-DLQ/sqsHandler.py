import boto3

class SqsHandler:
    def __init__(self,queueUrl):
        self.__sqs = boto3.client('sqs')
        self.__queueUrl = queueUrl

    def getMessage(self,qtdMsgs,waitTimeSeconds=0):
        # waitTimeSeconds > 0 habilita long polling: sem ele receive_message volta vazio
        # enquanto as mensagens estao invisiveis, e o consumidor encerra antes da redelivery
        response = self.__sqs.receive_message(
            QueueUrl=self.__queueUrl,
            MaxNumberOfMessages=qtdMsgs,
            WaitTimeSeconds=waitTimeSeconds
        )
        return response

    def deleteMessage(self,receiptHandle):
        response = self.__sqs.delete_message(
            QueueUrl=self.__queueUrl,
            ReceiptHandle=receiptHandle
        )
        return response
    
    def deleteBatch(self,lista):
        response = self.__sqs.delete_message_batch(
            QueueUrl=self.__queueUrl,
            Entries=lista
        )
        print(response)

    def sendBatch(self,lista):
        response = self.__sqs.send_message_batch(
            QueueUrl=self.__queueUrl,
            Entries=lista
        )
        print(response)
    
    def send(self,msg):
        response = self.__sqs.send_message(
            QueueUrl=self.__queueUrl,
            MessageBody=msg
        )
        print(response)
    