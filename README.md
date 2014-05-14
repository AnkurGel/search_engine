# Search Engine


This is a basic web search engine in **Ruby** to study different constituents of search engine architecture -

- Web crawler (currently in progress)
- Index-er.
- Query component

Another prime motive during the process is to learn more about different page-ranking algorithms such as **PageRank** algorithm, **Frequency Ranking**, **Distance Ranking**, **Location Ranking** etc.

This project also features a small _web appliation_ for better user experience and to visually analyze the ranking algorithms :wink:
![Screenshot of index page of application](https://dl.dropboxusercontent.com/u/102071534/scr2/Screenshot%20from%202014-05-12%2004%3A32%3A19.png)

The results look something like [this](https://dl.dropboxusercontent.com/u/102071534/scr2/Screenshot%20from%202014-05-12%2004%3A57%3A40.png) and [this](https://dl.dropboxusercontent.com/u/102071534/scr2/Screenshot%20from%202014-05-12%2004%3A17%3A50.png).
## Note

It is **NOT recommended** for use in any critical program. This project is a learning experiment and is subjected to many bugs.

Feel free to improve the project by contributing with tests, bug-reports and improvements.

## To setup

`bundle install`

In [seeds.yaml](seeds.yaml), setup the initial seeds for crawling+indexing process to begin.


## To run

1. Begin by crawling and indexing of pages by - `ruby spider.rb`
2. After you have substantial data for ranking; compute **PageRank** iteratively by - `ruby pagerank.rb`
3. Now, run our web application by `ruby web.rb`. This will run the local server on http://localhost:4567, by default.
4. Query and analyze! :sunglasses:

## Dependencies

- [**Nokogiri**](http://nokogiri.org/) - An HTML, XML parser with awesome ability to traverse documents via XPath and CSS selectors.
- [**DataMapper**](http://datamapper.org) - A robust ORM in Ruby.
- [**Sinatra**](www.sinatrarb.com) - A lightweight framework for quickly creating web applications in Ruby.
- [**SQLite**](http://www.sqlite.org/) - One of the most popular and easily-configurable database engine.
- **Debugger** - The Holy-Grail.

## TODO
All TO-DOs are being tracked here - [Issue #1](https://github.com/AnkurGel/search_engine/issues/1).


Copyright (c) [Ankur Goel](http://github.com/AnkurGel) & [Nitish Sharma](https://github.com/sharma1nitish).
