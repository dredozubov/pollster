pollster
========

Simple git-based poll application written in ruby/sinatra. Idea is: you add yaml-formatted poll to git repo, commit, push it and get nice page with your questions.
There is one database backend for now - mongodb. It just clicks with pollster.

###### Question types currently supported
1. Single choice
2. Multiple choice
3. Text input
4. Multiple choice + text input
5. Q methodology-likey 