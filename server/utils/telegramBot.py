from dotenv import load_dotenv
import os
import requests

class TelegramBot():
    def __init__(self):
        load_dotenv()
        self.apiToken = os.getenv("TELEGRAMBOT_API_TOKEN")
        self.chatId = os.getenv("TELEGRAMBOT_CHAT_ID")

        print(self.apiToken, self.chatId)

    def send(self, message):
        url = f"https://api.telegram.org/bot{self.apiToken}/sendMessage"
        payload = {
            "chat_id": self.chatId,
            "text": message
        }

        response = requests.post(url, data=payload)

        print(response.json())