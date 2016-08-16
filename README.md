# rubytogether-lita

Welcome! This is the Lita chat bot for Ruby Together's Slack. You can use it to tweet, so far.

Make sure you set these ENV variables:

| Variable                    | Data           |
| ----------------------------|:--------------:|
| SLACK_TOKEN                 | API token from Slack's apps dashboard (if not set, Lita uses the Shell interface) |
| REDISTOGO_URL               | Will be automatically set if you enable the RedisToGo addon on Heroku |
| TWITTER_CONSUMER_KEY        | Twitter consumer key |
| TWITTER_CONSUMER_SECRET     | Twitter consumer secret |
| TWITTER_ACCOUNTS            | Hash of Twitter accounts and access tokens |

## Testing

`./bin/lita` to run lita in the slack channel

`./bin/lita-shell` to run in a shell
