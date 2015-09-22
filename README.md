# Tribute To The Tragicomic Tale Told Through Ten Trivial Tests
> *a.k.a "T"* * *10* # the hard way ex45

## Synopsis

A text adventure game as an exercise 45 from [LRTHW] by Zed Shaw. Hero will go
trough ten rooms and solve trials and tests to open the final room and find the
answers within. The game is witten in ruby.

You can read development details in the DEVCORE.md document.

At this point only 2 rooms are fully implemented (entrance and exit as well).

## Features

- Hero, has limited hit points (can be damaged and healed)
- Randomly generated room layout on every new game.
- Save/Load support
- Inventory
- Events

## Documentation

Documentation is written using the YARD syntax. So either install the [YARD] gem
and run `$ yard` in the main project directory, or read the source files.

Or read it online at: http://www.rubydoc.info/github/mbrand12/t10

## Installing & Running

- Install ruby if you haven't.
- Clone using:
     `$ git clone -b master git@github.com:mbrand12/t10.git`
     or
     `$ git clone -b master https://git@github.com/mbrand12/t10.git`
- Run `$ ruby bin/t10` in the main project directory.
## Usage

Use `enter left, right, ahead or back` to navigate trough the dungeon after
entering it. I'll leave how to enter and exit the dungeon to you :)

## Changelog

See CHANGELOG.md document for a list of changes.

## License

T10 is licensed under the MIT license. Read the LICENCE document supplied with
this project for more information.

## Contributing

This project uses [gitflow]

1. Fork it ( https://github.com/mbrand12/t10/fork )
2. Initialize the flow (`git flow init -d`)
3. Create your feature branch (`git flow feature start my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git flow feature publish my-new-feature`)
6. Create a new Pull Request

or the typical way:

1. Fork it ( https://github.com/mbrand12/t10/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[YARD]: https://github.com/lsegal/yard
[LRTHW]: http://learnrubythehardway.org/
[gitflow]: https://github.com/nvie/gitflow
