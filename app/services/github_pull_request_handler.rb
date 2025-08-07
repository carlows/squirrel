# frozen_string_literal: true

class GithubPullRequestHandler
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def handle
    action = payload["action"]

    if action == "opened"
      pr = payload["pull_request"]
      installation_id = payload["installation"]["id"]

      GithubClient.new(installation_id).add_comment(
        pr["head"]["repo"]["full_name"],
        pr["number"],
        "🕵️‍♂️🐿️ *Agent Squirrel reporting for duty!*\n\n" \
        "Greetings Agent #{pr["user"]["login"]}! I've infiltrated your PR and while my operatives analyze the code, " \
        "here's a classified joke from our intelligence department:\n\n" \
        "#{ruby_jokes.sample} 😄\n\n" \
        "*This message will self-destruct... just kidding, it's a permanent git commit!* 🌰"
      )
    end
  end

  private

  def ruby_jokes
    [
      "Why do Ruby developers always carry a first aid kit? In case they get a NIL pointer! 💎",
      "What's a Ruby developer's favorite drink? Gem and tonic! 🍸",
      "Why did the Ruby on Rails developer go broke? Too many dependencies! 🚂",
      "What's a Git user's favorite dance? Pull-ka! 💃",
      "Why do programmers prefer dark mode? Because light attracts bugs! 🐛",
      "How do you comfort a JavaScript developer? You console them! 🤗",
      "Why did the developer quit their job? They didn't get arrays! 📊",
      "What did the pair programmer say to their partner? You complete my code! ❤️",
      "Why do programmers hate nature? It has too many bugs! 🌲",
      "What's a developer's favorite place in the house? The RESTroom! ��"
    ]
  end
end
