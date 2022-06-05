package main

import (
	"bufio"
	"log"

	"os"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
)

func main() {
	telegramBotToken := os.Args[1]
	bot, err := tgbotapi.NewBotAPI(telegramBotToken)
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message != nil { // If we got a message
			log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, update.Message.Text)

			// open file sh.csv and read it
			file, err := os.Open("sh.csv")
			if err != nil {
				log.Panic(err)
			}

			defer file.Close()

			// read file line per line
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				msg.Text += scanner.Text()
				break
			}

			msg.ReplyToMessageID = update.Message.MessageID

			bot.Send(msg)
		}
	}
}
