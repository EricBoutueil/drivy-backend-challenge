# Drivy Challenges by Alexandre Ferraille

Hi there, this is my backend test for Drivy
I spent 1 day of work to reach on level 6

I tried to build this exercise as extensible as possible by using OOP and a MVC approach
Main is the "controller", which receive a json file and pass it to the "database"
The "Database" read and parse the data with different models and store them in arrays 

You can test each levels by doing :

Choose the level
````
$ cd level[1..6]
````
Run IRB
````
$ irb -r ./main.rb
````
Instantiate Main class
````
$ m = Main.new
````
Use the export function to get output.json
````
$ m.export_prices
````
