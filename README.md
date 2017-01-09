# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions

## Deployment

#### Development

Deploy development environment using docker

        docker build -t hackathon .
        docker run --rm -it -p 3000:3000 -v `pwd`:/var/www/hackathon:z hackathon rails server -b 0.0.0.0

The web server is then accesible on http://localhost:3000

#### Production

Deploy using docker-compose

        docker-compose up

## Contributing

### Git commit message guidelines

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

[read more](http://chris.beams.io/posts/git-commit/)
